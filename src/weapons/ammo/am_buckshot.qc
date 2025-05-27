//=============================================================================
// am_buckshot.qc - FQX Mod - Advanced Buckshot Ammunition System
// ##FQX - ##Quedra: Version 2.2
// ##Quedra: Reworked for data-driven shell properties and parameterized firing.
// ##Quedra: Aligns with am_ballistics.qc principles for damage and armor interaction.
// ##Quedra: v2.1 - Corrected T_Damage call in buckshot_pellet_touch.
// ##Quedra: v2.2 - Added unconditional dprint statements to W_am_fire_buckshot_parameterized for diagnostics.
//=============================================================================

// Forward declarations for projectile functions
void() buckshot_pellet_touch;
void() buckshot_pellet_think;

// Base constants
float BUCKSHOT_SPEED_BASE = 2000; // Base muzzle velocity for pellets

//-----------------------------------------------------------------------------
// ##Quedra: get_buckshot_properties
//-----------------------------------------------------------------------------
void get_buckshot_properties(
    float p_shell_type_id, 
    float &p_damage_per_pellet, 
    float &p_pellet_count, 
    float &p_base_spread_factor, 
    float &p_velocity_mod,      
    float &p_knockback_factor,  
    float &p_armor_pen_mod      
)
{
    p_damage_per_pellet = 5;
    p_pellet_count = 8;
    p_base_spread_factor = 0.087; 
    p_velocity_mod = 1.0;
    p_knockback_factor = 1;       
    p_armor_pen_mod = 0.75;       

    if (p_shell_type_id == SHELL_TYPE_12G_000BUCK)
    {
        p_damage_per_pellet = 8;
        p_pellet_count = 8;
        p_base_spread_factor = 0.087; 
        p_velocity_mod = 1.0;
        p_knockback_factor = 1.2;
        p_armor_pen_mod = 0.8;
    }
}

//-----------------------------------------------------------------------------
// ##Quedra: launch_buckshot_pellet
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
// ##Quedra: buckshot_pellet_touch
//-----------------------------------------------------------------------------
void() buckshot_pellet_touch =
{
    local float effective_damage;
    if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }
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
    remove(self);
}

//-----------------------------------------------------------------------------
// ##Quedra: buckshot_pellet_think
//-----------------------------------------------------------------------------
void() buckshot_pellet_think = { remove(self); };

//-----------------------------------------------------------------------------
// ##Quedra: W_am_fire_buckshot_parameterized (Diagnostic Version)
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
    local float damage_per_pellet, pellet_count, base_spread_factor, velocity_mod, knockback_factor, armor_pen_mod;
    local float final_damage_per_pellet, final_pellet_velocity;
    local float i, j;
    local vector aim_dir, pellet_dir;
    local float spread_x_offset, spread_y_offset;
    local float current_shot_total_spread_factor;

    dprint("WAFBP: Entered. SoundIn='", p_sound_to_play, "', DischargesIn=", ftos(p_num_discharges), ", ShellTypeID=", ftos(p_shell_type_id), "\n");

    get_buckshot_properties(p_shell_type_id, damage_per_pellet, pellet_count, base_spread_factor, velocity_mod, knockback_factor, armor_pen_mod);
    dprint("WAFBP: GotProps: Dmg/Pellet=", ftos(damage_per_pellet), " PelletCount=", ftos(pellet_count), " BaseSpread=", ftos(base_spread_factor), "\n");

    final_damage_per_pellet = damage_per_pellet * p_weapon_damage_modifier;
    final_pellet_velocity = BUCKSHOT_SPEED_BASE * velocity_mod;
    current_shot_total_spread_factor = base_spread_factor * p_weapon_spread_modifier;
    dprint("WAFBP: FinalDmg=", ftos(final_damage_per_pellet), " FinalVel=", ftos(final_pellet_velocity), " TotalSpread=", ftos(current_shot_total_spread_factor), "\n");

    if (p_sound_to_play != string_null && p_sound_to_play != "")
    {
        dprint("WAFBP: Playing sound: '", p_sound_to_play, "'\n");
        sound(p_attacker, CHAN_WEAPON, p_sound_to_play, 1, ATTN_NORM);
    }
    else
    {
        dprint("WAFBP: No sound to play (null or empty).\n");
    }

    dprint("WAFBP: Creating muzzle flash.\n");
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT); 
    WriteCoord(MSG_BROADCAST, p_fire_origin_x);
    WriteCoord(MSG_BROADCAST, p_fire_origin_y);
    WriteCoord(MSG_BROADCAST, p_fire_origin_z);

    makevectors(p_attacker.v_angle); 
    aim_dir = v_forward;

    dprint("WAFBP: Starting discharge loop. NumDischarges=", ftos(p_num_discharges), "\n");
    for (i = 0; i < p_num_discharges; i = i + 1)
    {
        dprint("WAFBP: Discharge #", ftos(i+1), ". Starting pellet loop. PelletCount=", ftos(pellet_count), "\n");
        for (j = 0; j < pellet_count; j = j + 1)
        {
            dprint("WAFBP: Pellet #", ftos(j+1), " for discharge #", ftos(i+1),"\n");
            spread_x_offset = (random() - 0.5) * 2 * current_shot_total_spread_factor; 
            spread_y_offset = (random() - 0.5) * 2 * current_shot_total_spread_factor;

            pellet_dir = aim_dir + (v_right * spread_x_offset) + (v_up * spread_y_offset);
            pellet_dir = normalize(pellet_dir);
            
            dprint("WAFBP: Launching pellet. Dir='", vtos(pellet_dir), "'\n");
            launch_buckshot_pellet(p_fire_origin, pellet_dir, final_damage_per_pellet, final_pellet_velocity, knockback_factor, p_attacker, armor_pen_mod);
        }
        dprint("WAFBP: Finished pellet loop for discharge #", ftos(i+1),"\n");
    }
    dprint("WAFBP: Finished discharge loop. Exiting.\n");
}

//=============================================================================
// am_buckshot.qc - End of FQX Mod - Advanced Buckshot Ammunition System
// ##FQX - ##Quedra: Version 2.2
//=============================================================================