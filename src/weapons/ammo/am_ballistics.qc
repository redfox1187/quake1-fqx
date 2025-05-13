/*
==============================================================================
AM_BALLISTICS - Standard Bullet system for small arms.

This file implements a physical projectile-based bullet system.
Bullets use actual entities with collision detection rather than trace attacks.

Features:
- Type of bullet based on real world firearm types, such as FMJ, Hollow Point, Armor Piercing, etc.
- bullet_type determines capability to stay on target (accuracy)
- Weapons can affect accuracy (long barreled weapons increase accuracy, short barreled decrease)
- Support for firing multiple instances (e.g., burst fire or multiple projectiles)
- Different bullet_types may affect the likelihood of weapon jamming
- Heavier rounds or rounds that transfer more energy increase chance of painframes in monsters
==============================================================================
*/

// Bullet entity function declarations
void() bullet_touch;
void() bullet_think;

// Caliber type definitions
// Caliber IDs - used for referencing in weapon files
float CAL_22LR = 1;
float CAL_9MM = 2;
float CAL_45ACP = 3;
float CAL_57MM = 4;
float CAL_44MAG = 5;
float CAL_556NATO = 6;
float CAL_762x39 = 7;
float CAL_762NATO = 8;
float CAL_50BMG = 9;

// Caliber base damage values
float DAMAGE_22LR = 8;
float DAMAGE_9MM = 15;
float DAMAGE_45ACP = 18;
float DAMAGE_57MM = 12;
float DAMAGE_44MAG = 25;
float DAMAGE_556NATO = 20;
float DAMAGE_762x39 = 22;
float DAMAGE_762NATO = 26;
float DAMAGE_50BMG = 50;

// Bullet type definitions
float BLT_FMJ = 1;    // Full Metal Jacket
float BLT_HP = 2;     // Hollow Point
float BLT_SP = 3;     // Soft Point
float BLT_BALL = 4;   // Ballistic Tip
float BLT_AP = 5;     // Armor Piercing
float BLT_TRACER = 6; // Tracer rounds

// Bullet type modifiers - multipliers for different properties
// Penetration modifiers (how well it penetrates armor/walls)
float PEN_FMJ = 1.0;    // Standard penetration
float PEN_HP = 0.6;     // Poor penetration - designed to expand
float PEN_SP = 0.8;     // Moderate penetration
float PEN_BALL = 0.9;   // Good penetration with expansion
float PEN_AP = 1.5;     // Excellent penetration
float PEN_TRACER = 1.0; // Standard penetration

// Damage modifiers (how much damage increases against unarmored targets)
float DMG_FMJ = 1.0;    // Standard damage
float DMG_HP = 1.4;     // Excellent damage - designed to expand
float DMG_SP = 1.3;     // Good damage - controlled expansion
float DMG_BALL = 1.2;   // Enhanced damage
float DMG_AP = 0.9;     // Reduced soft target damage
float DMG_TRACER = 1.0; // Standard damage

// Accuracy modifiers (how well bullet maintains trajectory)
float ACC_FMJ = 1.0;    // Standard accuracy
float ACC_HP = 0.9;     // Slightly less accurate
float ACC_SP = 0.95;    // Slightly less accurate
float ACC_BALL = 1.1;   // More accurate due to ballistic tip
float ACC_AP = 1.05;    // Slightly more accurate
float ACC_TRACER = 1.0; // Standard accuracy

// Knockback modifiers (how much target is pushed)
float KB_FMJ = 1.0;     // Standard knockback
float KB_HP = 1.3;      // High knockback - transfers more energy
float KB_SP = 1.2;      // Good knockback - transfers more energy
float KB_BALL = 1.15;   // Enhanced knockback
float KB_AP = 0.9;      // Less knockback - passes through
float KB_TRACER = 1.0;  // Standard knockback

// Pain modifiers (how likely to cause pain animation)
float PAIN_FMJ = 1.0;    // Standard pain chance
float PAIN_HP = 1.5;     // High pain chance - increased trauma
float PAIN_SP = 1.3;     // Good pain chance
float PAIN_BALL = 1.2;   // Enhanced pain chance
float PAIN_AP = 0.8;     // Lower pain chance
float PAIN_TRACER = 1.0; // Standard pain chance

// Velocity settings
float BULLET_SPEED_BASE = 3000; // Base bullet velocity

// Velocity modifiers for different calibers
float VEL_22LR = 0.8;
float VEL_9MM = 0.9;
float VEL_45ACP = 0.7;
float VEL_57MM = 1.1;
float VEL_44MAG = 0.85;
float VEL_556NATO = 1.2;
float VEL_762x39 = 1.0;
float VEL_762NATO = 1.1;
float VEL_50BMG = 1.3;

/*
================
bullet_touch
Handles collision of bullet with world or entities
================
*/
void() bullet_touch =
{
    local float damage;
    local float penetration;
    local float knockback_factor;
    local float pain_factor;
    
    // If hit sky, just remove without effect
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    // Get damage from bullet
    damage = self.dmg;
    penetration = self.frags; // Using frags to store penetration value
    knockback_factor = self.armorvalue; // Using armorvalue to store knockback factor
    pain_factor = self.health; // Using health to store pain chance
    
    // Create impact particle effect
    particle(self.origin, '0 0 0', 225, damage * 0.5);
    
    // Apply damage if hit an entity
    if (other.takedamage)
    {
        // If target has armor, apply penetration modifier
        if (other.armortype > 0 && other.armorvalue > 0)
        {
            // Reduce damage based on armor and penetration
            // Higher penetration means more damage gets through
            damage = damage * penetration;
        }
        
        // Apply damage based on bullet properties
        T_Damage(other, self, self.owner, damage);
        
        // Apply knockback
        if (other.flags & FL_MONSTER || other.flags & FL_CLIENT)
        {
            other.velocity = other.velocity + self.velocity * 0.03 * knockback_factor;
        }
        
        // Check for pain animation
		//##FOX commented out for now, compiler throwing error: weapons/ammo/am_ballistics.qc:163: error: Unknown field "pain_frame" in class "entity"
		/*
        if (other.flags & FL_MONSTER && random() < (0.4 * pain_factor) && damage > 5)
        {
            if (other.pain_finished < time)
            {
                other.pain_finished = time + 0.5;
                other.pain_frame = 0;
                
                // Trigger monster pain function if it exists
                // Note: This relies on standard monster pain function naming convention
                if (other.th_pain)
                    other.th_pain(self, damage);
            }
        }
        */
        // Add blood spray
        SpawnBlood(self.origin, self.velocity * 0.2, damage);
        
		/* ##FOX This is too over the top, and distracting.
        // If tracer, add small fire effect
        if (self.effects & EF_DIMLIGHT)
        {
            // Create a small flame effect
            WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
            WriteByte(MSG_BROADCAST, TE_EXPLOSION);
            WriteCoord(MSG_BROADCAST, self.origin_x);
            WriteCoord(MSG_BROADCAST, self.origin_y);
            WriteCoord(MSG_BROADCAST, self.origin_z);
            WriteByte(MSG_BROADCAST, 1); // Small explosion
        }
		*/
		
    }
    else
    {
        // Hit wall or object - spawn impact effect
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
        
        // If tracer, add small fire effect
        if (self.effects & EF_DIMLIGHT)
        {
            // Create a small spark effect
            WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
            WriteByte(MSG_BROADCAST, TE_SPIKE);
            WriteCoord(MSG_BROADCAST, self.origin_x);
            WriteCoord(MSG_BROADCAST, self.origin_y);
            WriteCoord(MSG_BROADCAST, self.origin_z);
        }
    }
    
    // Remove bullet after impact
    remove(self);
};

/*
================
bullet_think
Handles bullet lifetime
================
*/
void() bullet_think =
{
    // Remove bullet after lifetime expires
    // This prevents bullets from flying forever
    remove(self);
};

/*
================
launch_bullet
Creates a single bullet entity with the given parameters
================
*/
void(vector org, vector dir, float dmg_amount, float pen_factor, float kb_factor, float pain_chance, float is_tracer, entity source_ent) launch_bullet =
{
    local entity bullet;
    
    bullet = spawn();
    
    // Set the owner reference
    bullet.owner = source_ent;
    
    bullet.movetype = MOVETYPE_FLYMISSILE;
    bullet.solid = SOLID_BBOX;
    
    // Set appearance
    setmodel(bullet, "progs/bullet.mdl"); // Small model for bullet
    setsize(bullet, '0 0 0', '0 0 0');  // Tiny collision box
    
    // Set position and velocity
    setorigin(bullet, org);
    bullet.velocity = dir * BULLET_SPEED_BASE;
    bullet.angles = vectoangles(bullet.velocity);
    
    // Store damage and other properties
    bullet.dmg = dmg_amount;
    bullet.frags = pen_factor; // Using frags to store penetration value
    bullet.armorvalue = kb_factor; // Using armorvalue to store knockback factor
    bullet.health = pain_chance; // Using health to store pain chance
    
    // If it's a tracer, add light effect
    if (is_tracer > 0)
    {
        bullet.effects = bullet.effects | EF_DIMLIGHT;
    }
    
    bullet.touch = bullet_touch;
    
    // Set lifetime
    bullet.nextthink = time + 5;  // 5 second lifetime
    bullet.think = bullet_think;
};

/*
================
get_bullet_properties
Gets all properties for a given caliber and bullet type
================
*/
void(float caliber, float bullet_type, float &damage, float &penetration, float &kb_factor, float &pain_chance, float &velocity_mod, float &accuracy_mod) get_bullet_properties =
{
    // Set base damage by caliber
    if (caliber == CAL_22LR)
        damage = DAMAGE_22LR;
    else if (caliber == CAL_9MM)
        damage = DAMAGE_9MM;
    else if (caliber == CAL_45ACP)
        damage = DAMAGE_45ACP;
    else if (caliber == CAL_57MM)
        damage = DAMAGE_57MM;
    else if (caliber == CAL_44MAG)
        damage = DAMAGE_44MAG;
    else if (caliber == CAL_556NATO)
        damage = DAMAGE_556NATO;
    else if (caliber == CAL_762x39)
        damage = DAMAGE_762x39;
    else if (caliber == CAL_762NATO)
        damage = DAMAGE_762NATO;
    else if (caliber == CAL_50BMG)
        damage = DAMAGE_50BMG;
    else
        damage = 15; // Default damage
    
    // Set velocity modifier by caliber
    if (caliber == CAL_22LR)
        velocity_mod = VEL_22LR;
    else if (caliber == CAL_9MM)
        velocity_mod = VEL_9MM;
    else if (caliber == CAL_45ACP)
        velocity_mod = VEL_45ACP;
    else if (caliber == CAL_57MM)
        velocity_mod = VEL_57MM;
    else if (caliber == CAL_44MAG)
        velocity_mod = VEL_44MAG;
    else if (caliber == CAL_556NATO)
        velocity_mod = VEL_556NATO;
    else if (caliber == CAL_762x39)
        velocity_mod = VEL_762x39;
    else if (caliber == CAL_762NATO)
        velocity_mod = VEL_762NATO;
    else if (caliber == CAL_50BMG)
        velocity_mod = VEL_50BMG;
    else
        velocity_mod = 1.0; // Default velocity
    
    // Set penetration by bullet type
    if (bullet_type == BLT_FMJ)
        penetration = PEN_FMJ;
    else if (bullet_type == BLT_HP)
        penetration = PEN_HP;
    else if (bullet_type == BLT_SP)
        penetration = PEN_SP;
    else if (bullet_type == BLT_BALL)
        penetration = PEN_BALL;
    else if (bullet_type == BLT_AP)
        penetration = PEN_AP;
    else if (bullet_type == BLT_TRACER)
        penetration = PEN_TRACER;
    else
        penetration = 1.0; // Default penetration
    
    // Set damage modifier by bullet type
    if (bullet_type == BLT_FMJ)
        damage = damage * DMG_FMJ;
    else if (bullet_type == BLT_HP)
        damage = damage * DMG_HP;
    else if (bullet_type == BLT_SP)
        damage = damage * DMG_SP;
    else if (bullet_type == BLT_BALL)
        damage = damage * DMG_BALL;
    else if (bullet_type == BLT_AP)
        damage = damage * DMG_AP;
    else if (bullet_type == BLT_TRACER)
        damage = damage * DMG_TRACER;
    
    // Set accuracy modifier by bullet type
    if (bullet_type == BLT_FMJ)
        accuracy_mod = ACC_FMJ;
    else if (bullet_type == BLT_HP)
        accuracy_mod = ACC_HP;
    else if (bullet_type == BLT_SP)
        accuracy_mod = ACC_SP;
    else if (bullet_type == BLT_BALL)
        accuracy_mod = ACC_BALL;
    else if (bullet_type == BLT_AP)
        accuracy_mod = ACC_AP;
    else if (bullet_type == BLT_TRACER)
        accuracy_mod = ACC_TRACER;
    else
        accuracy_mod = 1.0; // Default accuracy
    
    // Set knockback factor by bullet type
    if (bullet_type == BLT_FMJ)
        kb_factor = KB_FMJ;
    else if (bullet_type == BLT_HP)
        kb_factor = KB_HP;
    else if (bullet_type == BLT_SP)
        kb_factor = KB_SP;
    else if (bullet_type == BLT_BALL)
        kb_factor = KB_BALL;
    else if (bullet_type == BLT_AP)
        kb_factor = KB_AP;
    else if (bullet_type == BLT_TRACER)
        kb_factor = KB_TRACER;
    else
        kb_factor = 1.0; // Default knockback
    
    // Set pain chance by bullet type
    if (bullet_type == BLT_FMJ)
        pain_chance = PAIN_FMJ;
    else if (bullet_type == BLT_HP)
        pain_chance = PAIN_HP;
    else if (bullet_type == BLT_SP)
        pain_chance = PAIN_SP;
    else if (bullet_type == BLT_BALL)
        pain_chance = PAIN_BALL;
    else if (bullet_type == BLT_AP)
        pain_chance = PAIN_AP;
    else if (bullet_type == BLT_TRACER)
        pain_chance = PAIN_TRACER;
    else
        pain_chance = 1.0; // Default pain chance
};

/*
================
W_am_fire_bullet
Fires a single bullet with the given parameters

Parameters:
  caliber - Caliber of bullet to fire
  bullet_type - Type of bullet (FMJ, HP, etc.)
  accuracy - Accuracy modifier (0.5 = half accuracy, 2.0 = double accuracy)
  is_tracer - Whether this bullet should be a tracer (1 = yes, 0 = no)
================
*/
void(float caliber, float bullet_type, float accuracy, float is_tracer) W_am_fire_bullet =
{
    local vector dir;
    local vector src;
    local vector view_offset;
    local vector muzzle_pos;
    local float damage, penetration, kb_factor, pain_chance, velocity_mod, accuracy_mod;
    local float spread;
    local float spread_x, spread_y;
    local float tracefraction;
    
    // Get properties for this bullet type
    get_bullet_properties(caliber, bullet_type, damage, penetration, kb_factor, pain_chance, velocity_mod, accuracy_mod);
    
    // Calculate final accuracy (weapon accuracy * bullet accuracy)
    accuracy = accuracy * accuracy_mod;
    
    // Base spread - lower values = more accurate
    spread = 0.03;
    
    // Apply inverse of accuracy to spread (higher accuracy = lower spread)
    spread = spread / accuracy;
    
    // Get player's aiming direction and eye position
    makevectors(self.v_angle);
    
    // Start with eye position
    src = self.origin + self.view_ofs;
    
    // Add an offset to mimic the gun barrel position
    // This fixes the issue with projectile origins being inconsistent when turning
    view_offset = v_forward * 10 + v_right * 3 + v_up * -5;
    
    // Calculate proposed muzzle position
    muzzle_pos = src + view_offset;
    
    // Do a traceline check to make sure we're not inside a wall
    traceline(src, muzzle_pos, FALSE, self);
    tracefraction = trace_fraction;
    
    if (tracefraction < 1.0)
    {
        // If there's something between eye and intended muzzle position,
        // adjust the muzzle position to be just before the obstacle
        muzzle_pos = src + (view_offset * tracefraction) - (v_forward * 0.5);
    }
    
    // Use muzzle_pos as final source
    src = muzzle_pos;
    
    // Calculate random spread direction
    spread_x = (random() - 0.5) * spread;
    spread_y = (random() - 0.5) * spread;
    
    dir = v_forward;
    dir = dir + (v_right * spread_x) + (v_up * spread_y);
    dir = normalize(dir);
    
    // Create muzzle flash at the proper position
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT);
    WriteCoord(MSG_BROADCAST, src_x);
    WriteCoord(MSG_BROADCAST, src_y);
    WriteCoord(MSG_BROADCAST, src_z);
    
    // Launch the bullet
    launch_bullet(src, dir, damage, penetration, kb_factor, pain_chance, is_tracer, self);
};

/*
================
W_am_fire_bullets
Fires multiple bullets (for burst fire or multiple projectiles)

Parameters:
  instances - Number of bullets to fire
  caliber - Caliber of bullet to fire
  bullet_type - Type of bullet (FMJ, HP, etc.)
  accuracy - Accuracy modifier (0.5 = half accuracy, 2.0 = double accuracy)
  tracer_interval - How often to make a tracer (0 = never, 1 = every bullet, 3 = every third bullet)
================
*/
void(float instances, float caliber, float bullet_type, float accuracy, float tracer_interval) W_am_fire_bullets =
{
    local float i;
    local float is_tracer;
    
    for (i = 0; i < instances; i++)
    {
        // Determine if this bullet should be a tracer
        if (tracer_interval > 0 && (i % tracer_interval) == 0)
            is_tracer = 1;
        else
            is_tracer = 0;
        
        // Fire a bullet
        W_am_fire_bullet(caliber, bullet_type, accuracy, is_tracer);
    }
};