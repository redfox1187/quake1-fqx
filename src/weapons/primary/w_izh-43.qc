//=============================================================================
// w_izh-43.qc - FQX Mod - IZh-43 Double Barrel Shotgun
// ##FQX - ##Fox: Version 2.5 - just sneaking in some tuning numbers for testing. Sorry 'Q'
// ##FQXCUSTOM - ##Quedra: Version 2.4.0
// ##Quedra: Formerly w_dbshot.qc. Renamed internal constants, functions,
// ##Quedra: and display strings to IZh-43 as per Soldier's request.
// ##Quedra: Uses am_reload.qc and am_buckshot.qc V2.0+ systems.
// ##Quedra: v2.3 (as w_dbshot) - Explicitly set self.weapon_ammo_resource_id.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: IZh-43 Double Barrel Shotgun - Constants & Properties
//-----------------------------------------------------------------------------

// --- Meta Information & View ---
string WEAPON_IZH43_DISPLAY_NAME = "IZh-43"; // ##Quedra: Changed for in-game display
string WEAPON_IZH43_VIEWMODEL = "progs/v_doublebarrel.mdl"; // ##Quedra: Viewmodel path retained

// --- Inventory & Ammo ---
// ##Quedra: WEAPON_ID_DBSHOT (the underlying ID from defs_2.qc) is still assumed for system compatibility.
// ##Quedra: This file's local constants use the new IZH43 prefix.
float WEAPON_IZH43_SLOT = IT_SLOT_SECONDARY;
float WEAPON_IZH43_AMMO_RESOURCE_ID = AMMO_ID_SHELLS;
float WEAPON_IZH43_MAG_CAPACITY = 2;

// --- Fire Modes & Costs ---
float IZH43_FIREMODE_IDX_SINGLE = 0;
float IZH43_FIREMODE_IDX_DOUBLE = 1; 
float WEAPON_IZH43_AMMO_COST_SINGLE = 1;
float WEAPON_IZH43_AMMO_COST_DOUBLE = 2;
// --- Projectile & Damage (Primary: 000 Buck) ---
float WEAPON_IZH43_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_000BUCK; 
float WEAPON_IZH43_SPREAD_MOD_PRIMARY = 0.16; 
float WEAPON_IZH43_DAMAGE_MOD_PRIMARY = 1.0;
// --- Cooldowns ---
float WEAPON_IZH43_COOLDOWN_SINGLE = 0.8;  
float WEAPON_IZH43_COOLDOWN_DOUBLE = 1.6;
// --- Recoil Parameters (Single Shot) ---
float IZH43_RECOIL_S_STRENGTH         = 2.2;
float IZH43_RECOIL_S_SPREAD           = 0.6;
float IZH43_RECOIL_S_VERT_BIAS      = 1.7;
float IZH43_RECOIL_S_SUST_MULT      = 0.1;
float IZH43_RECOIL_S_MAX_SUST       = 1.2;
// --- Recoil Parameters (Double Shot) ---
float IZH43_RECOIL_D_STRENGTH         = 4.5;
float IZH43_RECOIL_D_SPREAD           = 0.8;
float IZH43_RECOIL_D_VERT_BIAS      = 2.0;
float IZH43_RECOIL_D_SUST_MULT      = 0.1;
float IZH43_RECOIL_D_MAX_SUST       = 1.2;
// --- Common Recoil Parameters ---
vector IZH43_RECOIL_PATTERN_AIM       = '-0.05 0.1 0';
float  IZH43_RECOIL_RECOVERY_RATE     = 2.0;          

// --- Sound Paths ---
string IZH43_SOUND_FIRE_S_P1 = "weapons/guncock.wav";
string IZH43_SOUND_FIRE_S_P2 = "weapons/guncock.wav";
string IZH43_SOUND_FIRE_D_P1 = "weapons/shotgn2.wav";
string IZH43_SOUND_FIRE_D_P2 = "weapons/shotgn2.wav";
string IZH43_SOUND_EMPTY_CLICK = "weapons/boltback.wav";
string IZH43_SOUND_SWITCHMODE_LOADED = "weapons/pkup.wav";
string IZH43_SOUND_SWITCHMODE_EMPTY = "weapons/weapon.wav";

// --- Reload Parameters ---
float IZH43_RELOAD_DURATION = 0.7; 
float IZH43_GAME_AMMO_COST_PER_ROUND = GAME_AMMO_COST_PER_SHOTGUN_ROUND;
string IZH43_RELOAD_START_SOUND = SOUND_RELOAD_START_DEFAULT;
string IZH43_RELOAD_FINISH_SOUND = SOUND_RELOAD_FINISH_DEFAULT;
float IZH43_RELOAD_ANIM_FRAME = RELOAD_ANIM_FRAME_DEFAULT;
float IZH43_CAN_MANUAL_RELOAD = TRUE;

// Forward declarations for functions within this file
void w_izh43_SetCurrentAmmo (void); // ##Quedra: Renamed
void W_FireIZH43 (void); // ##Quedra: Renamed
void W_SwitchModeIZH43 (void); // ##Quedra: Renamed
void w_izh43_PrintCurrentMode (void); // ##Quedra: Renamed

//-----------------------------------------------------------------------------
// ##Quedra: w_izh43_PrintCurrentMode
// ##Quedra: Helper function to display current fire mode.
//-----------------------------------------------------------------------------
void w_izh43_PrintCurrentMode () // ##Quedra: Renamed
{
    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_SINGLE)
    {
        sprint(self, PRINT_LOW, "IZh-43: Single Barrel\n"); // ##Quedra: Updated display string
    }
    else if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE)
    {
        sprint(self, PRINT_LOW, "IZh-43: Double Barrel\n"); // ##Quedra: Updated display string
    }
    else 
    {
        sprint(self, PRINT_LOW, "IZh-43: System Debug Mode\n"); // ##Quedra: Updated display string
    }
}

//-----------------------------------------------------------------------------
// ##Quedra: w_izh43_SetCurrentAmmo
// ##Quedra: Sets up the IZh-43 as the current weapon.
//-----------------------------------------------------------------------------
void w_izh43_SetCurrentAmmo () // ##Quedra: Renamed
{
    AM_InitializeWeaponView(WEAPON_IZH43_VIEWMODEL, WEAPON_IZH43_AMMO_RESOURCE_ID, WEAPON_IZH43_SLOT);
    self.weapon_ammo_resource_id = WEAPON_IZH43_AMMO_RESOURCE_ID; 
    AM_InitWeaponFireModes(2); 
    AM_SetRecoilPattern(IZH43_RECOIL_PATTERN_AIM, IZH43_RECOIL_RECOVERY_RATE);

    self.izh43_sound_toggle = 0; // ##Quedra: Renamed field (ensure defs_2.qc is updated if this is global)

    self.current_weapon_max_mag_capacity = WEAPON_IZH43_MAG_CAPACITY;
    self.current_weapon_reload_duration = IZH43_RELOAD_DURATION;
    self.current_weapon_game_ammo_cost_per_round = IZH43_GAME_AMMO_COST_PER_ROUND;
    self.current_weapon_reload_start_sound = IZH43_RELOAD_START_SOUND;
    self.current_weapon_reload_finish_sound = IZH43_RELOAD_FINISH_SOUND;
    self.current_weapon_reload_anim_frame = IZH43_RELOAD_ANIM_FRAME;
    self.current_weapon_can_manual_reload = IZH43_CAN_MANUAL_RELOAD;
    self.current_weapon_sound_empty = IZH43_SOUND_EMPTY_CLICK;

    self.weapon_is_reloading = FALSE;

    if (self.weapon_first_draw_init == TRUE) 
    {
        local float rounds_to_load_initial = 0;
        if (self.ammo_shells >= (IZH43_GAME_AMMO_COST_PER_ROUND * 2)) 
        { 
            rounds_to_load_initial = 2;
        }
        else if (self.ammo_shells >= IZH43_GAME_AMMO_COST_PER_ROUND) 
        { 
            rounds_to_load_initial = 1;
        }
        self.weapon_ammo_in_magazine = rounds_to_load_initial;
        self.weapon_first_draw_init = FALSE;
    }
    
    self.currentammo = self.weapon_ammo_in_magazine;
    w_izh43_PrintCurrentMode(); // ##Quedra: Renamed
}

//-----------------------------------------------------------------------------
// ##Quedra: W_SwitchModeIZH43
// ##Quedra: Handles IZh-43 fire mode switching.
//-----------------------------------------------------------------------------
void W_SwitchModeIZH43 () // ##Quedra: Renamed
{
    if (self.weapon_is_reloading == TRUE) 
    {
        self.weapon_is_reloading = FALSE;
        self.think = SUB_Null;
        self.nextthink = -1;
        self.weaponframe = 0; 
    }

    AM_CycleFireMode();
    if (self.weapon_ammo_in_magazine > 0)
    {
        sound(self, CHAN_ITEM, IZH43_SOUND_SWITCHMODE_LOADED, 1, ATTN_NORM);
    }
    else
    {
        sound(self, CHAN_ITEM, IZH43_SOUND_SWITCHMODE_EMPTY, 1, ATTN_NORM);
    }
    w_izh43_PrintCurrentMode(); // ##Quedra: Renamed
}

//-----------------------------------------------------------------------------
// ##Quedra: W_FireIZH43
// ##Quedra: Main firing function for the IZh-43.
//-----------------------------------------------------------------------------
void W_FireIZH43 () // ##Quedra: Renamed
{
    local float rounds_needed_for_shot;
    local float num_discharges_this_shot;
    local float actual_ammo_cost_this_shot;
    local string sound_to_play_now;
    local vector muzzle_origin;
    local float current_cooldown;
    local float recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax;

    if (self.weapon_is_reloading == TRUE)
    {
        return;
    }

    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_SINGLE)
    {
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1;
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_SINGLE;
        recoil_str = IZH43_RECOIL_S_STRENGTH;
        recoil_spr = IZH43_RECOIL_S_SPREAD;
        recoil_vbias = IZH43_RECOIL_S_VERT_BIAS;
        recoil_smult = IZH43_RECOIL_S_SUST_MULT;
        recoil_smax = IZH43_RECOIL_S_MAX_SUST;
        if (self.izh43_sound_toggle == 0) { sound_to_play_now = IZH43_SOUND_FIRE_S_P1; self.izh43_sound_toggle = 1; } // ##Quedra: Renamed field
        else { sound_to_play_now = IZH43_SOUND_FIRE_S_P2; self.izh43_sound_toggle = 0; } // ##Quedra: Renamed field
    }
    else if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE)
    {
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_DOUBLE;
        num_discharges_this_shot = 2;
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_DOUBLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_DOUBLE;
        recoil_str = IZH43_RECOIL_D_STRENGTH;
        recoil_spr = IZH43_RECOIL_D_SPREAD;
        recoil_vbias = IZH43_RECOIL_D_VERT_BIAS;
        recoil_smult = IZH43_RECOIL_D_SUST_MULT;
        recoil_smax = IZH43_RECOIL_D_MAX_SUST;
        if (self.izh43_sound_toggle == 0) { sound_to_play_now = IZH43_SOUND_FIRE_D_P1; self.izh43_sound_toggle = 1; } // ##Quedra: Renamed field
        else { sound_to_play_now = IZH43_SOUND_FIRE_D_P2; self.izh43_sound_toggle = 0; } // ##Quedra: Renamed field
    }
    else 
    {
        sprint(self, PRINT_LOW, "IZh-43: Invalid fire mode selected for firing!\n"); // ##Quedra: Updated display string
        self.attack_finished = time + 0.1;
        return;
    }

    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE && self.weapon_ammo_in_magazine == 1)
    {
        sprint(self, PRINT_LOW, "IZh-43: Firing single shell from double mode (1 round left).\n"); // ##Quedra: Updated display string
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1;
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_SINGLE;
        recoil_str = IZH43_RECOIL_S_STRENGTH;
        recoil_spr = IZH43_RECOIL_S_SPREAD;
        recoil_vbias = IZH43_RECOIL_S_VERT_BIAS;
        recoil_smult = IZH43_RECOIL_S_SUST_MULT;
        recoil_smax = IZH43_RECOIL_S_MAX_SUST;
    }

    if (self.weapon_ammo_in_magazine < rounds_needed_for_shot)
    {
        AM_InitiateWeaponReload();
        return; 
    }

    self.weapon_ammo_in_magazine -= actual_ammo_cost_this_shot;
    self.currentammo = self.weapon_ammo_in_magazine;

    makevectors(self.v_angle);
    muzzle_origin = self.origin + self.view_ofs + v_forward * 10 + v_right * 3 + v_up * -5;
    W_am_fire_buckshot_parameterized(
        muzzle_origin, 
        num_discharges_this_shot, 
        WEAPON_IZH43_SHELL_TYPE_PRIMARY, 
        WEAPON_IZH43_SPREAD_MOD_PRIMARY, 
        WEAPON_IZH43_DAMAGE_MOD_PRIMARY, 
        sound_to_play_now, 
        self
    );
    AM_ApplyRecoil(recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax);

    self.attack_finished = time + current_cooldown;
    player_run();
}

//=============================================================================
// w_izh-43.qc - FQX Mod - IZh-43 Double Barrel Shotgun - END
// ##FQXCUSTOM - ##Quedra: Version 2.4.0
//=============================================================================