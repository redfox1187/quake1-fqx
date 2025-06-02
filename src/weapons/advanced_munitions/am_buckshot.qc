//=============================================================================
// am_buckshot.qc - FQX Mod - Advanced Buckshot Ammunition System
// Location: weapons/ammo/
// ##FQX - ##Quedra: Version 2.6.0
// ##Quedra: Implements dual-cone spread logic for buckshot projectiles.
// ##Quedra: Dependencies: Uses SHELL_TYPE_* constants from defs_2.qc v3.0.0+.
// ##Quedra:             Requires defs_2.qc get_buckshot_properties fwd-decl to be updated
// ##Quedra:             for new signature using 'vector &p_dual_cone_data'.
// ##Quedra:             Requires SHELL_TYPE_12G_NO1BUCK constant in defs_2.qc.
// ##Quedra:             Requires forward declaration for GetShellResourceCost in defs_2.qc.
// ##Quedra: v2.6.0 - Added GetShellResourceCost() function to define resource cost per shell type.
// ##Quedra: v2.5.1 - ##Soldier: Integrated Sergeant Grave's recommended adjustments
// ##Quedra:          for secondary buckshot properties (spread, core_ratio, armor_pen).
// ##Quedra: v2.5.0 - ##Soldier: Rebalanced damage & pellet counts for all buckshot types
// ##Quedra:          as per new systematic scaling.
// ##Quedra:        - Added new SHELL_TYPE_12G_NO1BUCK with estimated secondary properties.
// ##Quedra:        - Removed SHELL_TYPE_12G_BIRDSHOT.
// ##Quedra: v2.4.0 - Refactored get_buckshot_properties to pass dual-cone data (ratio,
// ##Quedra:          base_core_spread, base_fringe_spread) via a single vector reference
// ##Quedra:          (&p_dual_cone_data) to potentially alleviate stack/param issues.
// ##Quedra:          W_am_fire_buckshot_parameterized updated to use this and reinstated
// ##Quedra:          full dual-cone (two-loop) firing logic.
//=============================================================================

// Forward declarations for projectile functions
void() buckshot_pellet_touch;
void() buckshot_pellet_think;
void launch_buckshot_pellet(vector p_origin, vector p_dir, float p_damage_this_pellet, float p_velocity_this_pellet, float p_knockback_this_pellet, entity p_shooter, float p_armor_pen_mod);

// Base constants
float BUCKSHOT_SPEED_BASE = 2000; // Base muzzle velocity for pellets

//-----------------------------------------------------------------------------
// ##Quedra: GetShellResourceCost (v2.6.0)
// Desc: Returns the global Quake Shell resource cost to load 1 magazine
//       round of the specified buckshot shell type.
// Note: Requires forward declaration in defs_2.qc if called from other files.
//-----------------------------------------------------------------------------
float GetShellResourceCost(float shell_type_id)
{
    if (shell_type_id == SHELL_TYPE_12G_NO4BUCK) { return 1; }      // Power Level 1
    else if (shell_type_id == SHELL_TYPE_12G_NO1BUCK) { return 2; } // Power Level 2
    else if (shell_type_id == SHELL_TYPE_12G_0BUCK) { return 3; }   // Power Level 3
    else if (shell_type_id == SHELL_TYPE_12G_00BUCK) { return 4; }  // Power Level 4
    else if (shell_type_id == SHELL_TYPE_12G_000BUCK) { return 5; } // Power Level 5
    
    // Fallback for unknown or non-costed shell types
    dprint("GetShellResourceCost: Unknown or non-costed shell_type_id: "); dprint(ftos(shell_type_id)); dprint("\n");
    return 1; // Default to a minimal cost to prevent gameplay stalls or errors
}

//-----------------------------------------------------------------------------
// ##Quedra: get_buckshot_properties
// ##Quedra: v2.5.1 - Integrated Sergeant Grave's secondary property adjustments.
// ##Quedra: Expected forward declaration in defs_2.qc:
// ##Quedra: void get_buckshot_properties(float p_shell_type_id, float &p_damage_per_pellet, float &p_pellet_count, vector &p_dual_cone_data, float &p_velocity_mod, float &p_knockback_factor, float &p_armor_pen_mod)
//-----------------------------------------------------------------------------
void get_buckshot_properties(
    float p_shell_type_id,
    float &p_damage_per_pellet,
    float &p_pellet_count,
    vector &p_dual_cone_data,           // Output: .x = core_ratio, .y = base_core_spread, .z = base_fringe_spread
    float &p_velocity_mod,
    float &p_knockback_factor,
    float &p_armor_pen_mod
)
{
    local float core_ratio, base_core_spread, base_fringe_spread; // Temporary locals

    // --- Defaults (Fallback) ---
    p_damage_per_pellet         = 4;    // Base damage per pellet (Soldier's rebalance sets this per type)
    p_pellet_count              = 10;   // Base pellet count (Soldier's rebalance sets this per type)
    core_ratio                  = 0.6;  // Default core pellet ratio
    base_core_spread            = 0.015;// Default base core spread
    base_fringe_spread          = 0.08; // Default base fringe spread
    p_velocity_mod              = 1.0;  // Default velocity modifier
    p_knockback_factor          = 0.8;  // Default knockback factor per pellet
    p_armor_pen_mod             = 0.6;  // Default armor penetration modifier

    if (p_shell_type_id == SHELL_TYPE_12G_000BUCK) // Defined in defs_2.qc
    {
        // v2.5.0 Damage/Pellet Counts (Locked per Sarge)
        p_damage_per_pellet         = 10.8;
        p_pellet_count              = 10;
        // v2.5.1 Secondary Properties (Confirmed by Sarge)
        core_ratio                  = 0.75;
        base_core_spread            = 0.010;
        base_fringe_spread          = 0.040;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 1.2;
        p_armor_pen_mod             = 0.8;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_00BUCK) // Defined in defs_2.qc
    {
        // v2.5.0 Damage/Pellet Counts (Locked per Sarge)
        p_damage_per_pellet         = 4.8;
        p_pellet_count              = 15;
        // v2.5.1 Secondary Properties (Confirmed by Sarge, no changes from v2.5.0 values for this type)
        core_ratio                  = 0.66;
        base_core_spread            = 0.012;
        base_fringe_spread          = 0.045;
        p_velocity_mod              = 1.0;
        p_knockback_factor          = 1.0;
        p_armor_pen_mod             = 0.75;
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_0BUCK) // Defined in defs_2.qc
    {
        // v2.5.0 Damage/Pellet Counts (Locked per Sarge)
        p_damage_per_pellet         = 2.0;
        p_pellet_count              = 18;
        // v2.5.1 Secondary Properties (Adjusted by Sarge)
        core_ratio                  = 0.60; // Was 0.66 in v2.5.0
        base_core_spread            = 0.015; // Confirmed
        base_fringe_spread          = 0.055; // Confirmed
        p_velocity_mod              = 1.0;   // Confirmed
        p_knockback_factor          = 0.9;   // Confirmed
        p_armor_pen_mod             = 0.7;   // Confirmed
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_NO1BUCK) // Ensure this constant is defined in defs_2.qc
    {
        // v2.5.0 Damage/Pellet Counts (Locked per Sarge)
        p_damage_per_pellet         = 0.75;
        p_pellet_count              = 24;
        // v2.5.1 Secondary Properties (Adjusted by Sarge from v2.5.0 defaults)
        // ##Quedra: TODO_FQX - ##Soldier: Review secondary properties (spread, knockback, etc.) for NO1BUCK. Using defaults for now. (Original comment retained)
        core_ratio                  = 0.55;  // Was 0.6 (default)
        base_core_spread            = 0.018; // Was 0.015 (default)
        base_fringe_spread          = 0.080; // Confirmed (default)
        p_velocity_mod              = 1.0;   // Confirmed (default)
        p_knockback_factor          = 0.8;   // Confirmed (default)
        p_armor_pen_mod             = 0.6;   // Confirmed (default)
    }
    else if (p_shell_type_id == SHELL_TYPE_12G_NO4BUCK) // Defined in defs_2.qc
    {
        // v2.5.0 Damage/Pellet Counts (Locked per Sarge)
        p_damage_per_pellet         = 0.219512;
        p_pellet_count              = 41;
        // v2.5.1 Secondary Properties (Adjusted by Sarge)
        core_ratio                  = 0.50;  // Was 0.60 in v2.5.0
        base_core_spread            = 0.020; // Confirmed
        base_fringe_spread          = 0.100; // Was 0.070 in v2.5.0
        p_velocity_mod              = 1.0;   // Confirmed
        p_knockback_factor          = 0.7;   // Confirmed
        p_armor_pen_mod             = 0.55;  // Was 0.65 in v2.5.0
    }
    // v2.5.0 - SHELL_TYPE_12G_BIRDSHOT block removed as per Soldier's request.

    // Pack into the output vector
    p_dual_cone_data_x = core_ratio;
    p_dual_cone_data_y = base_core_spread;
    p_dual_cone_data_z = base_fringe_spread;
}

//-----------------------------------------------------------------------------
// ##Quedra: launch_buckshot_pellet (Unchanged from v2.4.0)
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
    pellet.frags = p_armor_pen_mod;  // Represents armor penetration modifier
    pellet.touch = buckshot_pellet_touch;
    pellet.nextthink = time + 2; 
    pellet.think = buckshot_pellet_think;
}

//-----------------------------------------------------------------------------
// ##Quedra: buckshot_pellet_touch (Unchanged from v2.4.0)
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
            // Apply armor penetration. self.frags stores p_armor_pen_mod.
            // A value of 1.0 means full damage past armor, 0.0 means no damage past armor.
            // This is a simple model; TDD might specify more complex armor interaction.
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
// ##Quedra: buckshot_pellet_think (Unchanged from v2.4.0)
//-----------------------------------------------------------------------------
void() buckshot_pellet_think = 
{ 
    self.solid = SOLID_NOT; 
    remove(self); 
};

//-----------------------------------------------------------------------------
// ##Quedra: W_am_fire_buckshot_parameterized (Unchanged from v2.4.0)
// ##Quedra: Uses get_buckshot_properties with vector for dual-cone data.
// ##Quedra: Full two-loop firing logic reinstated.
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
    local vector dual_cone_data_from_props; // To receive data from get_buckshot_properties
    local float core_pellet_ratio, base_core_spread_factor, base_fringe_spread_factor;
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
        dual_cone_data_from_props, // Pass the vector by reference
        velocity_mod, knockback_factor, armor_pen_mod
    );

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

        // Loop 1: Launch Core Pellets.
        for (j = 0; j < num_core_pellets_this_discharge; j = j + 1)
        {
            spread_x_offset = (random() - 0.5) * 2 * final_core_spread;
            spread_y_offset = (random() - 0.5) * 2 * final_core_spread;
            pellet_dir = aim_dir + (v_right * spread_x_offset) + (v_up * spread_y_offset);
            pellet_dir = normalize(pellet_dir);
            
            launch_buckshot_pellet(p_fire_origin, pellet_dir, final_damage_per_pellet, final_pellet_velocity, knockback_factor, p_attacker, armor_pen_mod);
        }

        // Loop 2: Launch Fringe Pellets.
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
// ##FQX - ##Quedra: Version 2.6.0
//=============================================================================