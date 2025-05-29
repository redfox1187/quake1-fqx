//=============================================================================
// am_buckshot.qc - FQX Mod - Advanced Buckshot Ammunition System
// Location: weapons/ammo/
// ##FQX - ##Quedra: Version 2.4.0
// ##Quedra: Implements dual-cone spread logic for buckshot projectiles.
// ##Quedra: Dependencies: Uses SHELL_TYPE_* constants from defs_2.qc v3.0.0+.
// ##Quedra:             Requires defs_2.qc get_buckshot_properties fwd-decl to be updated
// ##Quedra:             for new signature using 'vector &p_dual_cone_data'.
// ##Quedra: v2.4.0 - Refactored get_buckshot_properties to pass dual-cone data (ratio,
// ##Quedra:          base_core_spread, base_fringe_spread) via a single vector reference
// ##Quedra:          (&p_dual_cone_data) to potentially alleviate stack/param issues.
// ##Quedra:          W_am_fire_buckshot_parameterized updated to use this and reinstated
// ##Quedra:          full dual-cone (two-loop) firing logic.
// ##Quedra: v2.3.6 - (Diagnostic) Reverted logic to mimic old v2.2 (no crash).
//=============================================================================

// Forward declarations for projectile functions
void() buckshot_pellet_touch;
void() buckshot_pellet_think;
void launch_buckshot_pellet(vector p_origin, vector p_dir, float p_damage_this_pellet, float p_velocity_this_pellet, float p_knockback_this_pellet, entity p_shooter, float p_armor_pen_mod);

// Base constants
float BUCKSHOT_SPEED_BASE = 2000; // Base muzzle velocity for pellets

//-----------------------------------------------------------------------------
// ##Quedra: get_buckshot_properties
// ##Quedra: v2.4.0 - Dual-cone data (ratio, base_core, base_fringe) packed into p_dual_cone_data vector.
// ##Quedra: Expected forward declaration in defs_2.qc:
// ##Quedra: void get_buckshot_properties(float p_shell_type_id, float &p_damage_per_pellet, float &p_pellet_count, vector &p_dual_cone_data, float &p_velocity_mod, float &p_knockback_factor, float &p_armor_pen_mod)
//-----------------------------------------------------------------------------
void get_buckshot_properties(
    float p_shell_type_id,
    float &p_damage_per_pellet,
    float &p_pellet_count,
    vector &p_dual_cone_data,           // ##Quedra: Output: .x = core_ratio, .y = base_core_spread, .z = base_fringe_spread
    float &p_velocity_mod,
    float &p_knockback_factor,
    float &p_armor_pen_mod
)
{
    local float core_ratio, base_core_spread, base_fringe_spread; // Temporary locals

    // --- Defaults (Fallback) ---
    p_damage_per_pellet         = 4;
    p_pellet_count              = 10;
    core_ratio                  = 0.6; 
    base_core_spread            = 0.015;
    base_fringe_spread          = 0.08; 
    p_velocity_mod              = 1.0;
    p_knockback_factor          = 0.8;
    p_armor_pen_mod             = 0.6;

    if (p_shell_type_id == SHELL_TYPE_12G_000BUCK) // Defined in defs_2.qc
    {
        p_damage_per_pellet         = 8; 
        p_pellet_count              = 8; 
        core_ratio                  = 0.75;
        base_core_spread            = 0.010;
        base_fringe_spread          = 0.040;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 1.2;
        p_armor_pen_mod             = 0.8;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_00BUCK) // Defined in defs_2.qc
    {
        p_damage_per_pellet         = 7;
        p_pellet_count              = 9;
        core_ratio                  = 0.66;
        base_core_spread            = 0.012;
        base_fringe_spread          = 0.045;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 1.0;
        p_armor_pen_mod             = 0.75;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_0BUCK) // Defined in defs_2.qc
    {
        p_damage_per_pellet         = 6;
        p_pellet_count              = 12;
        core_ratio                  = 0.66;
        base_core_spread            = 0.015;
        base_fringe_spread          = 0.055;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 0.9;
        p_armor_pen_mod             = 0.7;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_NO4BUCK) // Defined in defs_2.qc
    {
        p_damage_per_pellet         = 3;
        p_pellet_count              = 27;
        core_ratio                  = 0.60;
        base_core_spread            = 0.020;
        base_fringe_spread          = 0.070;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 0.7;
        p_armor_pen_mod             = 0.65;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_BIRDSHOT) // Defined in defs_2.qc
    {
        p_damage_per_pellet         = 1;
        p_pellet_count              = 75;
        core_ratio                  = 0.40;
        base_core_spread            = 0.040; 
        base_fringe_spread          = 0.120;
        p_velocity_mod              = 0.9; 
        p_knockback_factor          = 0.3;
        p_armor_pen_mod             = 0.2;
    }

    // Pack into the output vector
    p_dual_cone_data_x = core_ratio;
    p_dual_cone_data_y = base_core_spread;
    p_dual_cone_data_z = base_fringe_spread;
}

//-----------------------------------------------------------------------------
// ##Quedra: launch_buckshot_pellet (Unchanged from v2.3.4)
//-----------------------------------------------------------------------------
void launch_buckshot_pellet(
    vector p_origin,
    vector p_dir,
    float p_damage_this_pellet,
    float p_velocity_this_pellet,
    float p_knockback_this_pellet,
    entity p_shooter,
    float p_armor_pen_mod
)
{
    local entity pellet;
    pellet = spawn();
    pellet.owner = p_shooter;
    pellet.movetype = MOVETYPE_FLYMISSILE;
    pellet.solid = SOLID_BBOX; 
    setmodel(pellet, "progs/bit.mdl"); 
    setsize(pellet, '0 0 0', '0 0 0'); 
    setorigin(pellet, p_origin);
    pellet.velocity = p_dir * p_velocity_this_pellet;
    pellet.angles = vectoangles(pellet.velocity);
    pellet.dmg = p_damage_this_pellet;
    pellet.frags = p_armor_pen_mod; 
    pellet.touch = buckshot_pellet_touch;
    pellet.nextthink = time + 2; 
    pellet.think = buckshot_pellet_think;
}

//-----------------------------------------------------------------------------
// ##Quedra: buckshot_pellet_touch (Unchanged from v2.3.4)
//-----------------------------------------------------------------------------
void() buckshot_pellet_touch =
{
    local float effective_damage;
    if (pointcontents(self.origin) == CONTENT_SKY) 
    { 
        self.solid = SOLID_NOT; 
        remove(self); 
        return; 
    }

    if (other.takedamage)
    {
        effective_damage = self.dmg;
        if (other.armortype > 0 && other.armorvalue > 0)
        {
            effective_damage = self.dmg * self.frags; 
        }
        SpawnBlood(self.origin, self.velocity * 0.01, effective_damage * 0.5); 
        T_Damage(other, self, self.owner, effective_damage);
    }
    else 
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
    }
    self.solid = SOLID_NOT; 
    remove(self);
};

//-----------------------------------------------------------------------------
// ##Quedra: buckshot_pellet_think (Unchanged from v2.3.4)
//-----------------------------------------------------------------------------
void() buckshot_pellet_think = 
{ 
    self.solid = SOLID_NOT; 
    remove(self); 
};

//-----------------------------------------------------------------------------
// ##Quedra: W_am_fire_buckshot_parameterized (Dual-Cone Version)
// ##Quedra: v2.4.0 - Uses get_buckshot_properties with vector for dual-cone data.
// ##Quedra:          Full two-loop firing logic reinstated.
//-----------------------------------------------------------------------------
void W_am_fire_buckshot_parameterized(
    vector p_fire_origin,           
    float p_num_discharges,         
    float p_shell_type_id,          
    float p_weapon_spread_modifier, 
    float p_weapon_damage_modifier, 
    string p_sound_to_play,         
    entity p_attacker               
)
{
    local float damage_per_pellet, pellet_count, velocity_mod, knockback_factor, armor_pen_mod;
    local vector dual_cone_data_from_props; // ##Quedra: To receive data from get_buckshot_properties
    local float core_pellet_ratio, base_core_spread_factor, base_fringe_spread_factor; // ##Quedra: Unpacked from vector
    local float final_damage_per_pellet, final_pellet_velocity;
    local float final_core_spread, final_fringe_spread;
    local float num_total_pellets_this_discharge;
    local float num_core_pellets_this_discharge, num_fringe_pellets_this_discharge;
    local float i, j;
    local vector aim_dir, pellet_dir;
    local float spread_x_offset, spread_y_offset;

    get_buckshot_properties(
        p_shell_type_id,
        damage_per_pellet, pellet_count,
        dual_cone_data_from_props, // ##Quedra: Pass the vector by reference
        velocity_mod, knockback_factor, armor_pen_mod
    );

    // ##Quedra: Unpack data from the vector
    core_pellet_ratio         = dual_cone_data_from_props_x;
    base_core_spread_factor   = dual_cone_data_from_props_y;
    base_fringe_spread_factor = dual_cone_data_from_props_z;

    final_damage_per_pellet = damage_per_pellet * p_weapon_damage_modifier;
    final_pellet_velocity = BUCKSHOT_SPEED_BASE * velocity_mod;

    final_core_spread = base_core_spread_factor * p_weapon_spread_modifier;
    final_fringe_spread = base_fringe_spread_factor * p_weapon_spread_modifier;

    if (p_sound_to_play != string_null && p_sound_to_play != "")
    {
        sound(p_attacker, CHAN_WEAPON, p_sound_to_play, 1, ATTN_NORM);
    }

    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
    WriteCoord(MSG_BROADCAST, p_fire_origin_x);
    WriteCoord(MSG_BROADCAST, p_fire_origin_y);
    WriteCoord(MSG_BROADCAST, p_fire_origin_z);

    makevectors(p_attacker.v_angle);
    aim_dir = v_forward;

    for (i = 0; i < p_num_discharges; i = i + 1)
    {
        num_total_pellets_this_discharge = pellet_count; 

        num_core_pellets_this_discharge = floor(num_total_pellets_this_discharge * core_pellet_ratio);
        num_fringe_pellets_this_discharge = num_total_pellets_this_discharge - num_core_pellets_this_discharge;

        // ##Quedra: Loop 1: Launch Core Pellets.
        for (j = 0; j < num_core_pellets_this_discharge; j = j + 1)
        {
            spread_x_offset = (random() - 0.5) * 2 * final_core_spread; 
            spread_y_offset = (random() - 0.5) * 2 * final_core_spread;
            pellet_dir = aim_dir + (v_right * spread_x_offset) + (v_up * spread_y_offset);
            pellet_dir = normalize(pellet_dir);
            
            launch_buckshot_pellet(p_fire_origin, pellet_dir, final_damage_per_pellet, final_pellet_velocity, knockback_factor, p_attacker, armor_pen_mod);
        }

        // ##Quedra: Loop 2: Launch Fringe Pellets.
        for (j = 0; j < num_fringe_pellets_this_discharge; j = j + 1)
        {
            spread_x_offset = (random() - 0.5) * 2 * final_fringe_spread; 
            spread_y_offset = (random() - 0.5) * 2 * final_fringe_spread;
            pellet_dir = aim_dir + (v_right * spread_x_offset) + (v_up * spread_y_offset);
            pellet_dir = normalize(pellet_dir);
            
            launch_buckshot_pellet(p_fire_origin, pellet_dir, final_damage_per_pellet, final_pellet_velocity, knockback_factor, p_attacker, armor_pen_mod);
        }
    }
}

//=============================================================================
// am_buckshot.qc - FQX Mod - Advanced Buckshot Ammunition System - END
// ##FQX - ##Quedra: Version 2.4.0
//=============================================================================