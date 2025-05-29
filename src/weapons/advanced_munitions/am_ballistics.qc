/*
==============================================================================
AM_BALLISTICS - Standard Bullet system for small arms.
// ... (header comments remain the same) ...
==============================================================================
*/

// Bullet entity function declarations
void() bullet_touch;
void() bullet_think;

// Caliber type definitions
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

// Bullet type modifiers
float PEN_FMJ = 1.0;    float DMG_FMJ = 1.0;    float ACC_FMJ = 1.0;    float KB_FMJ = 1.0;    float PAIN_FMJ = 1.0;
float PEN_HP = 0.6;     float DMG_HP = 1.4;     float ACC_HP = 0.9;     float KB_HP = 1.3;     float PAIN_HP = 1.5;
float PEN_SP = 0.8;     float DMG_SP = 1.3;     float ACC_SP = 0.95;    float KB_SP = 1.2;     float PAIN_SP = 1.3;
float PEN_BALL = 0.9;   float DMG_BALL = 1.2;   float ACC_BALL = 1.1;   float KB_BALL = 1.15;  float PAIN_BALL = 1.2;
float PEN_AP = 1.5;     float DMG_AP = 0.9;     float ACC_AP = 1.05;    float KB_AP = 0.9;     float PAIN_AP = 0.8;
float PEN_TRACER = 1.0; float DMG_TRACER = 1.0; float ACC_TRACER = 1.0; float KB_TRACER = 1.0; float PAIN_TRACER = 1.0;

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
    
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    damage = self.dmg;
    penetration = self.frags; 
    knockback_factor = self.armorvalue; 
    pain_factor = self.health; 
    
    particle(self.origin, '0 0 0', 225, damage * 0.5);
    
    if (other.takedamage)
    {
        if (other.armortype > 0 && other.armorvalue > 0)
        {
            damage = damage * penetration;
        }
        
        T_Damage(other, self, self.owner, damage);
        
        if (other.flags & FL_MONSTER || other.flags & FL_CLIENT)
        {
            other.velocity = other.velocity + self.velocity * 0.03 * knockback_factor;
        }
        
        SpawnBlood(self.origin, self.velocity * 0.2, damage);
    }
    else
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
        
        if (self.effects & EF_DIMLIGHT) 
        {
            WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
            WriteByte(MSG_BROADCAST, TE_SPIKE); 
            WriteCoord(MSG_BROADCAST, self.origin_x);
            WriteCoord(MSG_BROADCAST, self.origin_y);
            WriteCoord(MSG_BROADCAST, self.origin_z);
        }
    }
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
    remove(self);
};

/*
================
launch_bullet
Creates a single bullet entity with the given parameters.
================
*/
void(vector org, vector dir, float dmg_amount, float pen_factor, float kb_factor, float pain_chance, float velocity_mod, float is_tracer, entity source_ent) launch_bullet =
{
    local entity bullet;
    
    bullet = spawn();
    bullet.owner = source_ent;
    bullet.movetype = MOVETYPE_FLYMISSILE;
    bullet.solid = SOLID_BBOX;
    
    setmodel(bullet, "progs/bullet.mdl"); 
    setsize(bullet, '0 0 0', '0 0 0');  
    
    setorigin(bullet, org);
    bullet.velocity = dir * BULLET_SPEED_BASE * velocity_mod;
    bullet.angles = vectoangles(bullet.velocity);
    
    bullet.dmg = dmg_amount;
    bullet.frags = pen_factor; 
    bullet.armorvalue = kb_factor; 
    bullet.health = pain_chance; 
    
    if (is_tracer > 0)
    {
        bullet.effects = bullet.effects | EF_DIMLIGHT;
    }
    
    bullet.touch = bullet_touch;
    bullet.nextthink = time + 5; 
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
    // Set base damage and velocity_mod by caliber
    if (caliber == CAL_22LR) { damage = DAMAGE_22LR; velocity_mod = VEL_22LR; }
    else if (caliber == CAL_9MM) { damage = DAMAGE_9MM; velocity_mod = VEL_9MM; }
    else if (caliber == CAL_45ACP) { damage = DAMAGE_45ACP; velocity_mod = VEL_45ACP; }
    else if (caliber == CAL_57MM) { damage = DAMAGE_57MM; velocity_mod = VEL_57MM; }
    else if (caliber == CAL_44MAG) { damage = DAMAGE_44MAG; velocity_mod = VEL_44MAG; }
    else if (caliber == CAL_556NATO) { damage = DAMAGE_556NATO; velocity_mod = VEL_556NATO; }
    else if (caliber == CAL_762x39) { damage = DAMAGE_762x39; velocity_mod = VEL_762x39; }
    else if (caliber == CAL_762NATO) { damage = DAMAGE_762NATO; velocity_mod = VEL_762NATO; }
    else if (caliber == CAL_50BMG) { damage = DAMAGE_50BMG; velocity_mod = VEL_50BMG; }
    else { damage = 15; velocity_mod = 1.0; } // Default
    
    // Set modifiers by bullet type
    if (bullet_type == BLT_FMJ) { penetration = PEN_FMJ; damage = damage * DMG_FMJ; accuracy_mod = ACC_FMJ; kb_factor = KB_FMJ; pain_chance = PAIN_FMJ; }
    else if (bullet_type == BLT_HP) { penetration = PEN_HP; damage = damage * DMG_HP; accuracy_mod = ACC_HP; kb_factor = KB_HP; pain_chance = PAIN_HP; }
    else if (bullet_type == BLT_SP) { penetration = PEN_SP; damage = damage * DMG_SP; accuracy_mod = ACC_SP; kb_factor = KB_SP; pain_chance = PAIN_SP; }
    else if (bullet_type == BLT_BALL) { penetration = PEN_BALL; damage = damage * DMG_BALL; accuracy_mod = ACC_BALL; kb_factor = KB_BALL; pain_chance = PAIN_BALL; }
    else if (bullet_type == BLT_AP) { penetration = PEN_AP; damage = damage * DMG_AP; accuracy_mod = ACC_AP; kb_factor = KB_AP; pain_chance = PAIN_AP; }
    else if (bullet_type == BLT_TRACER) { penetration = PEN_TRACER; damage = damage * DMG_TRACER; accuracy_mod = ACC_TRACER; kb_factor = KB_TRACER; pain_chance = PAIN_TRACER; }
    else { penetration = 1.0; accuracy_mod = 1.0; kb_factor = 1.0; pain_chance = 1.0; } // Default
};

/*
================
W_am_fire_bullet
Fires a single bullet.
Origin offset is consistent. Spread calculation is now re-enabled.
================
*/
void(float caliber, float bullet_type, float accuracy, float is_tracer) W_am_fire_bullet =
{
    local vector dir;
    local vector src_origin; 
    local vector view_offset;
    local float damage, penetration, kb_factor, pain_chance, velocity_mod, accuracy_mod;
    local float current_spread_factor; // Determines the magnitude of spread
    local float spread_x, spread_y; 
    
    get_bullet_properties(caliber, bullet_type, damage, penetration, kb_factor, pain_chance, velocity_mod, accuracy_mod);
    
    // Combine weapon's current accuracy with bullet type's inherent accuracy modifier.
    // Higher 'accuracy' value means less spread.
    accuracy = accuracy * accuracy_mod;
    
    // Define a base for how much spread is applied.
    // This value is divided by the 'accuracy', so a higher accuracy results in a smaller divisor for random offsets.
    // Adjust this base_spread_value to tune overall weapon spread.
    // Smaller value = tighter cone of fire overall.
    local float base_spread_value = 0.03; // Example: results in ~1.7 degrees half-angle spread at accuracy=1

    if (accuracy > 0.001) // Prevent division by zero or excessively large spread if accuracy is tiny
    {
        current_spread_factor = base_spread_value / accuracy;
    }
    else // Handles accuracy <= 0 or very close to 0, implying maximum spread
    {
         current_spread_factor = base_spread_value / 0.01; // Effectively a very high spread
         if (accuracy < 0) current_spread_factor = 0.1; // Cap for negative accuracy
    }
    // Optional: Cap maximum spread factor to prevent extreme values
    // if (current_spread_factor > 0.2) current_spread_factor = 0.2;


    makevectors(self.v_angle);
    
    // --- ORIGIN CALCULATION: Using consistent offset from previous successful test ---
    view_offset = v_forward * 10 + v_right * 3 + v_up * -5; 
    src_origin = self.origin + self.view_ofs + view_offset;
    
    // --- DIRECTION CALCULATION: Re-introducing spread ---
    // random() returns a value from 0 to 1. (random() - 0.5) gives -0.5 to 0.5.
    // This creates a symmetrical random offset.
    spread_x = (random() - 0.5) * current_spread_factor;
    spread_y = (random() - 0.5) * current_spread_factor;
    
    dir = v_forward; // Start with the player's exact forward aiming vector
    // Add the random horizontal (v_right) and vertical (v_up) spread components
    dir = dir + (v_right * spread_x) + (v_up * spread_y); 
    dir = normalize(dir); // Ensure the final direction vector is a unit vector
    
    // Create muzzle flash effect at the calculated origin
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
    WriteCoord(MSG_BROADCAST, src_origin_x);
    WriteCoord(MSG_BROADCAST, src_origin_y);
    WriteCoord(MSG_BROADCAST, src_origin_z);
    
    // Launch the bullet
    launch_bullet(src_origin, dir, damage, penetration, kb_factor, pain_chance, velocity_mod, is_tracer, self); 
};

/*
================
W_am_fire_bullets
Fires multiple bullets (for burst fire or multiple projectiles)
================
*/
void(float instances, float caliber, float bullet_type, float accuracy, float tracer_interval) W_am_fire_bullets =
{
    local float i;
    local float is_tracer;
    
    for (i = 0; i < instances; i = i + 1) 
    {
        if (tracer_interval > 0 && (i % tracer_interval) == 0) 
            is_tracer = 1;
        else
            is_tracer = 0;
        
        W_am_fire_bullet(caliber, bullet_type, accuracy, is_tracer);
    }
};
