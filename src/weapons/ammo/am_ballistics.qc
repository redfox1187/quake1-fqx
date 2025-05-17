/*
==============================================================================
AM_BALLISTICS.QC - Advanced Munitions Ballistics System
##Quedra: Defines projectile behavior for standard bullet-firing weapons.
##Quedra: Handles caliber types, damage, bullet types, and projectile launch.
==============================================================================
*/

// --- Bullet Entity Function Declarations ---
void() bullet_touch; // Behavior on collision
void() bullet_think; // Per-frame logic (primarily lifetime)

// --- Caliber Type Definitions ---
float CAL_22LR      = 1;
float CAL_9MM       = 2;
float CAL_45ACP     = 3;
float CAL_57MM      = 4;
float CAL_44MAG     = 5;
float CAL_556NATO   = 6;
float CAL_762x39    = 7;
float CAL_762NATO   = 8;
float CAL_50BMG     = 9;

// --- Caliber Base Damage Values ---
float DAMAGE_22LR       = 8;
float DAMAGE_9MM        = 15;
float DAMAGE_45ACP      = 18;
float DAMAGE_57MM       = 12;
float DAMAGE_44MAG      = 25;
float DAMAGE_556NATO    = 20;
float DAMAGE_762x39     = 22;
float DAMAGE_762NATO    = 26;
float DAMAGE_50BMG      = 50;

// --- Bullet Type Definitions ---
float BLT_FMJ       = 1;    // Full Metal Jacket: Standard, balanced.
float BLT_HP        = 2;    // Hollow Point: Increased damage, lower penetration.
float BLT_SP        = 3;    // Soft Point: Good damage, moderate penetration.
float BLT_BALL      = 4;    // Ballistic Tip: Improved accuracy, good damage.
float BLT_AP        = 5;    // Armor Piercing: Increased penetration, slightly lower damage.
float BLT_TRACER    = 6;    // Tracer: Standard performance, visually distinct.

// --- Bullet Type Modifiers (Applied to Caliber Base Values) ---
// Format: PEN (Penetration), DMG (Damage Multiplier), ACC (Accuracy Multiplier), KB (Knockback Factor), PAIN (Pain Chance Multiplier)
float PEN_FMJ = 1.0,    DMG_FMJ = 1.0,  ACC_FMJ = 1.0,  KB_FMJ = 1.0,   PAIN_FMJ = 1.0;
float PEN_HP = 0.6,     DMG_HP = 1.4,   ACC_HP = 0.9,   KB_HP = 1.3,    PAIN_HP = 1.5;
float PEN_SP = 0.8,     DMG_SP = 1.3,   ACC_SP = 0.95,  KB_SP = 1.2,    PAIN_SP = 1.3;
float PEN_BALL = 0.9,   DMG_BALL = 1.2, ACC_BALL = 1.1, KB_BALL = 1.15, PAIN_BALL = 1.2;
float PEN_AP = 1.5,     DMG_AP = 0.9,   ACC_AP = 1.05,  KB_AP = 0.9,    PAIN_AP = 0.8;
float PEN_TRACER = 1.0, DMG_TRACER = 1.0,ACC_TRACER = 1.0,KB_TRACER = 1.0,PAIN_TRACER = 1.0;

// --- Velocity Settings ---
float BULLET_SPEED_BASE = 3000; // Base speed units per second for projectiles.

// --- Velocity Modifiers (Multiplies BULLET_SPEED_BASE) ---
float VEL_22LR      = 0.8;
float VEL_9MM       = 0.9;
float VEL_45ACP     = 0.7;
float VEL_57MM      = 1.1;
float VEL_44MAG     = 0.85;
float VEL_556NATO   = 1.2;
float VEL_762x39    = 1.0;
float VEL_762NATO   = 1.1;
float VEL_50BMG     = 1.3;

/*
================
bullet_touch
Handles collision of a bullet entity with the world or other entities.
================
*/
void() bullet_touch =
{
    local float damage_applied;
    local float effective_penetration;
    local float knockback_mod;
    // local float pain_mod; // ##Quedra: pain_factor (self.health of bullet) is not used for T_Damage pain.

    if (pointcontents(self.origin) == CONTENT_SKY) { // Bullet flew out of the world
        remove(self);
        return;
    }
    
    damage_applied = self.dmg;                  // Base damage stored in bullet
    effective_penetration = self.frags;         // Penetration factor stored in bullet
    knockback_mod = self.armorvalue;            // Knockback factor stored in bullet
    // pain_mod = self.health;                  // Pain chance modifier stored in bullet (##Quedra: Not directly used by T_Damage)
    
    particle(self.origin, '0 0 0', 225, damage_applied * 0.5); // Generic impact particle

    if (other.takedamage) { // If the other entity can take damage
        if (other.armortype > 0 && other.armorvalue > 0) {
            damage_applied = damage_applied * effective_penetration; 
        }
        
        T_Damage(other, self, self.owner, damage_applied); // Apply damage

        if (other.flags & FL_MONSTER || other.flags & FL_CLIENT) { // Apply knockback to monsters/players
            other.velocity = other.velocity + (normalize(self.velocity) * 30 * knockback_mod); // Simplified knockback
        }
        
        SpawnBlood(self.origin, self.velocity * 0.2, damage_applied); // Visual blood effect
    } else { // Hit a non-damageable surface (a wall)
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT); // Standard wall impact puff
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
        
        if (self.effects & EF_DIMLIGHT) { // If it's a tracer round
            WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
            WriteByte(MSG_BROADCAST, TE_SPIKE); // Tracer spark effect on wall
            WriteCoord(MSG_BROADCAST, self.origin_x);
            WriteCoord(MSG_BROADCAST, self.origin_y);
            WriteCoord(MSG_BROADCAST, self.origin_z);
        }
    }
    remove(self); // Bullet is consumed on impact
};

/*
================
bullet_think
Handles bullet lifetime; removes bullet after a set time if no collision.
================
*/
void() bullet_think =
{
    remove(self); // Bullet expires
};

/*
================
launch_bullet
Spawns and initializes a single bullet projectile entity.
Parameters:
    org: Initial origin of the bullet.
    dir: Normalized direction vector for the bullet's travel.
    dmg_amount: Base damage the bullet will carry.
    pen_factor: Penetration modifier.
    kb_factor: Knockback modifier.
    pain_chance: Pain infliction modifier (##Quedra: Not directly used currently beyond T_Damage defaults).
    velocity_mod: Multiplier for BULLET_SPEED_BASE.
    is_tracer: Boolean (0 or 1) if this bullet should have tracer effects.
    source_ent: The entity that fired the bullet (usually 'self' from weapon code).
================
*/
void(vector org, vector dir, float dmg_amount, float pen_factor, float kb_factor, float pain_chance, float velocity_mod, float is_tracer, entity source_ent) launch_bullet =
{
    local entity bullet;

    bullet = spawn();
    bullet.owner = source_ent;
    bullet.movetype = MOVETYPE_FLYMISSILE; // Standard projectile movement
    bullet.solid = SOLID_BBOX;             // Collides with bounding boxes

    setmodel(bullet, "progs/bullet.mdl");  // Visual model for the bullet
    setsize(bullet, '0 0 0', '0 0 0');     // Minimal collision size, as it's a fast projectile
    
    setorigin(bullet, org);
    bullet.velocity = dir * (BULLET_SPEED_BASE * velocity_mod); // Set initial velocity
    bullet.angles = vectoangles(bullet.velocity);               // Align model with velocity vector

    // Store combat properties on the bullet entity itself
    bullet.dmg = dmg_amount;
    bullet.frags = pen_factor;      // ##Quedra: Using .frags to store penetration factor
    bullet.armorvalue = kb_factor;  // ##Quedra: Using .armorvalue to store knockback factor
    bullet.health = pain_chance;    // ##Quedra: Using .health to store pain chance modifier

    if (is_tracer > 0) {
        bullet.effects = bullet.effects | EF_DIMLIGHT; // Simple tracer effect (engine dependent)
    }
    
    bullet.touch = bullet_touch;          // Assign collision function
    bullet.nextthink = time + 5;          // Bullet lifetime (e.g., 5 seconds)
    bullet.think = bullet_think;          // Function to call when lifetime expires
};

/*
================
W_am_fire_bullet
Central function to fire a single standard bullet projectile.
Calculates origin, direction (with spread), and projectile properties.
================
*/
void(float caliber, float bullet_type, float accuracy, float is_tracer) W_am_fire_bullet =
{
    local vector dir;
    local vector src_origin; 
    local vector view_offset;
    local float base_damage_for_caliber, damage_multiplier_for_type;
    local float final_damage;
    local float penetration_for_type;
    local float knockback_for_type;
    local float pain_chance_for_type;
    local float velocity_multiplier_for_caliber;
    local float accuracy_multiplier_for_type;
    local float current_spread_factor;
    local float spread_x, spread_y;

    // --- 1. Determine Bullet Properties based on Caliber and Type ---
    if (caliber == CAL_22LR) { base_damage_for_caliber = DAMAGE_22LR; velocity_multiplier_for_caliber = VEL_22LR; }
    else if (caliber == CAL_9MM) { base_damage_for_caliber = DAMAGE_9MM; velocity_multiplier_for_caliber = VEL_9MM; }
    else if (caliber == CAL_45ACP) { base_damage_for_caliber = DAMAGE_45ACP; velocity_multiplier_for_caliber = VEL_45ACP; }
    else if (caliber == CAL_57MM) { base_damage_for_caliber = DAMAGE_57MM; velocity_multiplier_for_caliber = VEL_57MM; }
    else if (caliber == CAL_44MAG) { base_damage_for_caliber = DAMAGE_44MAG; velocity_multiplier_for_caliber = VEL_44MAG; }
    else if (caliber == CAL_556NATO) { base_damage_for_caliber = DAMAGE_556NATO; velocity_multiplier_for_caliber = VEL_556NATO; }
    else if (caliber == CAL_762x39) { base_damage_for_caliber = DAMAGE_762x39; velocity_multiplier_for_caliber = VEL_762x39; }
    else if (caliber == CAL_762NATO) { base_damage_for_caliber = DAMAGE_762NATO; velocity_multiplier_for_caliber = VEL_762NATO; }
    else if (caliber == CAL_50BMG) { base_damage_for_caliber = DAMAGE_50BMG; velocity_multiplier_for_caliber = VEL_50BMG; }
    else { base_damage_for_caliber = 15; velocity_multiplier_for_caliber = 1.0; }

    if (bullet_type == BLT_FMJ) { penetration_for_type = PEN_FMJ; damage_multiplier_for_type = DMG_FMJ; accuracy_multiplier_for_type = ACC_FMJ; knockback_for_type = KB_FMJ; pain_chance_for_type = PAIN_FMJ; }
    else if (bullet_type == BLT_HP) { penetration_for_type = PEN_HP; damage_multiplier_for_type = DMG_HP; accuracy_multiplier_for_type = ACC_HP; knockback_for_type = KB_HP; pain_chance_for_type = PAIN_HP; }
    else if (bullet_type == BLT_SP) { penetration_for_type = PEN_SP; damage_multiplier_for_type = DMG_SP; accuracy_multiplier_for_type = ACC_SP; knockback_for_type = KB_SP; pain_chance_for_type = PAIN_SP; }
    else if (bullet_type == BLT_BALL) { penetration_for_type = PEN_BALL; damage_multiplier_for_type = DMG_BALL; accuracy_multiplier_for_type = ACC_BALL; knockback_for_type = KB_BALL; pain_chance_for_type = PAIN_BALL; }
    else if (bullet_type == BLT_AP) { penetration_for_type = PEN_AP; damage_multiplier_for_type = DMG_AP; accuracy_multiplier_for_type = ACC_AP; knockback_for_type = KB_AP; pain_chance_for_type = PAIN_AP; }
    else if (bullet_type == BLT_TRACER) { penetration_for_type = PEN_TRACER; damage_multiplier_for_type = DMG_TRACER; accuracy_multiplier_for_type = ACC_TRACER; knockback_for_type = KB_TRACER; pain_chance_for_type = PAIN_TRACER; }
    else { penetration_for_type = 1.0; damage_multiplier_for_type = 1.0; accuracy_multiplier_for_type = 1.0; knockback_for_type = 1.0; pain_chance_for_type = 1.0; }

    final_damage = base_damage_for_caliber * damage_multiplier_for_type;
    accuracy = accuracy * accuracy_multiplier_for_type;
    
    local float base_spread_value = 0.03; 
    if (accuracy > 0.001) { current_spread_factor = base_spread_value / accuracy; }
    else { current_spread_factor = base_spread_value / 0.01; if (accuracy < 0) { current_spread_factor = 0.1; } }

    // --- 3. Determine Origin and Direction ---
    makevectors(self.v_angle); 
    
    // ##TESTING: Origin calculation test block
    if (cvar("developer") > 0 && (self.weaponmodel == "progs/v_ak47.mdl" || self.weaponmodel == "progs/v_rahpm1.mdl" )) 
    { // ##Quedra: Only for AK47 or M93R (using RAHP model) AND developer > 0 for this specific test
        // ##Quedra: Test: Zero out the v_right component for these specific weapons to see if it fixes "mirroring"
        view_offset = v_forward * 10 + v_up * -5; 
        // dprint("##TESTING: AK/M93R - Using ZEROED v_right for view_offset: ", vtos(view_offset), "\n"); // Optional: confirm this path is taken
    }
    else // ##Quedra: Standard calculation for UMP45 and other weapons, or if developer == 0
    {
        view_offset = v_forward * 10 + v_right * 3 + v_up * -5;
    }
    // ##TESTING: End origin calculation test block
    
    src_origin = self.origin + self.view_ofs + view_offset;
    
    spread_x = (random() - 0.5) * current_spread_factor;
    spread_y = (random() - 0.5) * current_spread_factor;
    
    dir = v_forward;                                      
    dir = dir + (v_right * spread_x) + (v_up * spread_y);   
    dir = normalize(dir);                                   
    
    // ##TESTING: Debug print block
    if (cvar("developer") > 0) // ##DEBUG: Only print if developer is enabled
    {
        if (self.weaponmodel == "progs/v_ak47.mdl" || self.weaponmodel == "progs/v_rahpm1.mdl" || self.weaponmodel == "progs/v_ump45.mdl")
        {
            local string wpn_name_debug; // ##Quedra: Use a distinct local name for safety
            if (self.weaponmodel == "progs/v_ak47.mdl") { wpn_name_debug = "AK47"; }
            else if (self.weaponmodel == "progs/v_rahpm1.mdl") { wpn_name_debug = "M93R"; }
            else if (self.weaponmodel == "progs/v_ump45.mdl") { wpn_name_debug = "UMP45"; }
            else { wpn_name_debug = "UNKNOWN_DEBUG"; }

            dprint("##TESTING Shot Info - Weapon: ", wpn_name_debug, "\n");
            dprint("  Player Origin: ", vtos(self.origin), ", Player View_ofs: ", vtos(self.view_ofs), "\n");
            dprint("  Player v_angle: ", vtos(self.v_angle), "\n");
            dprint("  Global v_forward: ", vtos(v_forward), "\n");
            dprint("  Global v_right:   ", vtos(v_right), "\n");
            dprint("  Global v_up:      ", vtos(v_up), "\n");
            dprint("  Calculated view_offset: ", vtos(view_offset), "\n");
            dprint("  Final src_origin:  ", vtos(src_origin), "\n");
            dprint("  Final dir:         ", vtos(dir), "\n");
            dprint("  Input accuracy: ", ftos(accuracy), ", Spread Factor: ", ftos(current_spread_factor), "\n");
            dprint("-----\n");
        }
    }
    // ##TESTING: End debug print block
    
    // --- 4. Visual Effect & Launch ---
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
    WriteCoord(MSG_BROADCAST, src_origin_x);
    WriteCoord(MSG_BROADCAST, src_origin_y);
    WriteCoord(MSG_BROADCAST, src_origin_z);
    
    launch_bullet(src_origin, dir, final_damage, penetration_for_type, knockback_for_type, pain_chance_for_type, velocity_multiplier_for_caliber, is_tracer, self);
};

/*
================
W_am_fire_bullets
Fires multiple bullets, typically for shotguns or special burst effects.
Calls W_am_fire_bullet repeatedly.
================
*/
void(float instances, float caliber, float bullet_type, float accuracy, float tracer_interval) W_am_fire_bullets =
{
    local float i;
    local float fire_as_tracer; 
    
    for (i = 0; i < instances; i = i + 1) 
    {
        if (tracer_interval > 0 && (i % tracer_interval) == 0) {
            fire_as_tracer = TRUE;
        } else {
            fire_as_tracer = FALSE;
        }
        
        W_am_fire_bullet(caliber, bullet_type, accuracy, fire_as_tracer);
    }
};