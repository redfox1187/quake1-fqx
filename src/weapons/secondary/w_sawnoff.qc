//=============================================================================
// w_sawnoff.qc - FQX Mod - Sawn-off Double Barrel Shotgun (Diagnostic)
// ##FQX - ##Quedra: Version 1.2
// ##Quedra: Datasheet and logic for the Sawn-off Shotgun.
// ##Quedra: Uses am_reload.qc and am_buckshot.qc V2.0+ systems.
// ##Quedra: v1.1 - Added unconditional dprint statements for diagnosing firing issue.
// ##Quedra: v1.2 - Explicitly set self.weapon_ammo_resource_id in w_sawnoff_SetCurrentAmmo
// ##Quedra:          to ensure PlayerPreThink has correct resource ID for ammo checks.
//=============================================================================

// --- Constants (Same as Version 1.0) ---
string WEAPON_SAWNOFF_NAME = "Sawn-off";
string WEAPON_SAWNOFF_VIEWMODEL = "progs/v_sawnoff.mdl";
float WEAPON_SAWNOFF_SLOT = IT_SLOT_SECONDARY;
float WEAPON_SAWNOFF_AMMO_RESOURCE_ID = AMMO_ID_SHELLS;
float WEAPON_SAWNOFF_MAG_CAPACITY = 2;
float SAWNOFF_FIREMODE_IDX_SINGLE = 0; 
float SAWNOFF_FIREMODE_IDX_DOUBLE = 1; 
float WEAPON_SAWNOFF_AMMO_COST_SINGLE = 1;
float WEAPON_SAWNOFF_AMMO_COST_DOUBLE = 2; 
float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_000BUCK; 
float WEAPON_SAWNOFF_SPREAD_MOD_PRIMARY = 1.15; 
float WEAPON_SAWNOFF_DAMAGE_MOD_PRIMARY = 1.0;  
float WEAPON_SAWNOFF_COOLDOWN_SINGLE = 0.75;
float WEAPON_SAWNOFF_COOLDOWN_DOUBLE = 1.5;  
float SAWNOFF_RECOIL_S_STRENGTH         = 2.5;
float SAWNOFF_RECOIL_S_SPREAD           = 0.7;
float SAWNOFF_RECOIL_S_VERT_BIAS      = 1.8;
float SAWNOFF_RECOIL_S_SUST_MULT      = 0.1;
float SAWNOFF_RECOIL_S_MAX_SUST       = 1.2;
float SAWNOFF_RECOIL_D_STRENGTH         = 5.0;
float SAWNOFF_RECOIL_D_SPREAD           = 0.9;
float SAWNOFF_RECOIL_D_VERT_BIAS      = 2.2;
float SAWNOFF_RECOIL_D_SUST_MULT      = 0.1;
float SAWNOFF_RECOIL_D_MAX_SUST       = 1.2;
vector SAWNOFF_RECOIL_PATTERN_AIM       = '-0.1 0.15 0';
float  SAWNOFF_RECOIL_RECOVERY_RATE     = 1.8;
string SAWNOFF_SOUND_FIRE_S_P1 = "weapons/guncock.wav";
string SAWNOFF_SOUND_FIRE_S_P2 = "weapons/guncock.wav";
string SAWNOFF_SOUND_FIRE_D_P1 = "weapons/shotgn2.wav";
string SAWNOFF_SOUND_FIRE_D_P2 = "weapons/shotgn2.wav";
string SAWNOFF_SOUND_EMPTY_CLICK = "weapons/boltback.wav";
string SAWNOFF_SOUND_SWITCHMODE_LOADED = "weapons/pkup.wav";
string SAWNOFF_SOUND_SWITCHMODE_EMPTY = "weapons/weapon.wav";
float SAWNOFF_RELOAD_DURATION = 0.5;
float SAWNOFF_GAME_AMMO_COST_PER_ROUND = GAME_AMMO_COST_PER_SHOTGUN_ROUND;
string SAWNOFF_RELOAD_START_SOUND = SOUND_RELOAD_START_DEFAULT;
string SAWNOFF_RELOAD_FINISH_SOUND = SOUND_RELOAD_FINISH_DEFAULT;
float SAWNOFF_RELOAD_ANIM_FRAME = RELOAD_ANIM_FRAME_DEFAULT;
float SAWNOFF_CAN_MANUAL_RELOAD = TRUE;

// Forward declarations
void w_sawnoff_SetCurrentAmmo (void);
void W_FireSawnoff (void);
void W_SwitchModeSawnoff (void);
void w_sawnoff_PrintCurrentMode (void);

void w_sawnoff_PrintCurrentMode () 
{ 
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_SINGLE) 
    { 
        sprint(self, PRINT_LOW, "Sawn-off: Single Barrel\n");
    } 
    else if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE) 
    { 
        sprint(self, PRINT_LOW, "Sawn-off: Double Barrel\n");
    } 
    else 
    { 
        sprint(self, PRINT_LOW, "Sawn-off: System Debug Mode\n"); 
    } 
}

void w_sawnoff_SetCurrentAmmo () 
{ 
    AM_InitializeWeaponView(WEAPON_SAWNOFF_VIEWMODEL, WEAPON_SAWNOFF_AMMO_RESOURCE_ID, WEAPON_SAWNOFF_SLOT);
    self.weapon_ammo_resource_id = WEAPON_SAWNOFF_AMMO_RESOURCE_ID; // ##FQXCUSTOM - ##Quedra: v1.2 - Ensure this is set
    AM_InitWeaponFireModes(2); 
    AM_SetRecoilPattern(SAWNOFF_RECOIL_PATTERN_AIM, SAWNOFF_RECOIL_RECOVERY_RATE); 
    self.sawnoff_sound_toggle = 0; 
    self.current_weapon_max_mag_capacity = WEAPON_SAWNOFF_MAG_CAPACITY; 
    self.current_weapon_reload_duration = SAWNOFF_RELOAD_DURATION; 
    self.current_weapon_game_ammo_cost_per_round = SAWNOFF_GAME_AMMO_COST_PER_ROUND; 
    self.current_weapon_reload_start_sound = SAWNOFF_RELOAD_START_SOUND;
    self.current_weapon_reload_finish_sound = SAWNOFF_RELOAD_FINISH_SOUND; 
    self.current_weapon_reload_anim_frame = SAWNOFF_RELOAD_ANIM_FRAME; 
    self.current_weapon_can_manual_reload = SAWNOFF_CAN_MANUAL_RELOAD; 
    self.current_weapon_sound_empty = SAWNOFF_SOUND_EMPTY_CLICK; 
    self.weapon_is_reloading = FALSE;
    if (self.weapon_first_draw_init == TRUE) 
    { 
        local float rounds_to_load_initial = 0; 
        if (self.ammo_shells >= (SAWNOFF_GAME_AMMO_COST_PER_ROUND * 2)) 
        { 
            rounds_to_load_initial = 2;
        } 
        else if (self.ammo_shells >= SAWNOFF_GAME_AMMO_COST_PER_ROUND) 
        { 
            rounds_to_load_initial = 1; 
        } 
        self.weapon_ammo_in_magazine = rounds_to_load_initial; 
        self.weapon_first_draw_init = FALSE;
    } 
    self.currentammo = self.weapon_ammo_in_magazine; 
    w_sawnoff_PrintCurrentMode(); 
}

void W_SwitchModeSawnoff () 
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
        sound(self, CHAN_ITEM, SAWNOFF_SOUND_SWITCHMODE_LOADED, 1, ATTN_NORM); 
    } 
    else 
    { 
        sound(self, CHAN_ITEM, SAWNOFF_SOUND_SWITCHMODE_EMPTY, 1, ATTN_NORM); 
    } 
    w_sawnoff_PrintCurrentMode();
}

void W_FireSawnoff ()
{
    local float rounds_needed_for_shot;
    local float num_discharges_this_shot;
    local float actual_ammo_cost_this_shot;
    local string sound_to_play_now;
    local vector muzzle_origin;
    local float current_cooldown;
    local float recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax;
    
    bprint ("--- W_FireSawnoff CALLED! (Sawn-off v1.1 Diagnostic Prints Active) ---\n"); // ##Quedra: Retained from user's v1.1 for their diagnostics
    dprint("W_FireSawnoff: Entered. Mode=", ftos(self.current_weapon_fire_mode), " Mag=", ftos(self.weapon_ammo_in_magazine), "\n");

    if (self.weapon_is_reloading == TRUE) 
    {
        dprint("W_FireSawnoff: Currently reloading, exiting.\n");
        return;
    }
    
    sound_to_play_now = string_null;
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_SINGLE)
    {
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1;
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_SINGLE;
        recoil_str = SAWNOFF_RECOIL_S_STRENGTH; recoil_spr = SAWNOFF_RECOIL_S_SPREAD; recoil_vbias = SAWNOFF_RECOIL_S_VERT_BIAS;
        recoil_smult = SAWNOFF_RECOIL_S_SUST_MULT; recoil_smax = SAWNOFF_RECOIL_S_MAX_SUST;
        if (self.sawnoff_sound_toggle == 0) { sound_to_play_now = SAWNOFF_SOUND_FIRE_S_P1; self.sawnoff_sound_toggle = 1; }
        else { sound_to_play_now = SAWNOFF_SOUND_FIRE_S_P2; self.sawnoff_sound_toggle = 0; }
        dprint("W_FireSawnoff: Single fire mode selected. Sound='", sound_to_play_now, "'\n");
    }
    else if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE)
    {
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_DOUBLE;
        num_discharges_this_shot = 2;
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_DOUBLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_DOUBLE;
        recoil_str = SAWNOFF_RECOIL_D_STRENGTH; recoil_spr = SAWNOFF_RECOIL_D_SPREAD; recoil_vbias = SAWNOFF_RECOIL_D_VERT_BIAS;
        recoil_smult = SAWNOFF_RECOIL_D_SUST_MULT; recoil_smax = SAWNOFF_RECOIL_D_MAX_SUST;
        if (self.sawnoff_sound_toggle == 0) { sound_to_play_now = SAWNOFF_SOUND_FIRE_D_P1; self.sawnoff_sound_toggle = 1; }
        else { sound_to_play_now = SAWNOFF_SOUND_FIRE_D_P2; self.sawnoff_sound_toggle = 0; }
        dprint("W_FireSawnoff: Double fire mode selected. Sound='", sound_to_play_now, "'\n");
    }
    else 
    {
        sprint(self, PRINT_LOW, "Sawn-off: Invalid fire mode (", ftos(self.current_weapon_fire_mode), ") selected for firing!\n");
        dprint("W_FireSawnoff: Invalid fire mode. Sound='", sound_to_play_now, "' Exiting.\n");
        self.attack_finished = time + 0.1;
        return;
    }

    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE && self.weapon_ammo_in_magazine == 1)
    {
        dprint("W_FireSawnoff: Double mode, 1 in mag. Forcing single shot params.\n");
        sprint(self, PRINT_LOW, "Sawn-off: Firing single shell from double mode (1 round left).\n");
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1;
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_SINGLE; 
        recoil_str = SAWNOFF_RECOIL_S_STRENGTH; recoil_spr = SAWNOFF_RECOIL_S_SPREAD; recoil_vbias = SAWNOFF_RECOIL_S_VERT_BIAS; recoil_smult = SAWNOFF_RECOIL_S_SUST_MULT;
        recoil_smax = SAWNOFF_RECOIL_S_MAX_SUST;
    }

    dprint("W_FireSawnoff: Rounds needed=", ftos(rounds_needed_for_shot), " Mag before check=", ftos(self.weapon_ammo_in_magazine), "\n");
    if (self.weapon_ammo_in_magazine < rounds_needed_for_shot)
    {
        dprint("W_FireSawnoff: Not enough ammo in mag. Attempting reload.\n");
        AM_InitiateWeaponReload(); 
        return; 
    }

    dprint("W_FireSawnoff: Consuming ammo. Cost=", ftos(actual_ammo_cost_this_shot), "\n");
    self.weapon_ammo_in_magazine -= actual_ammo_cost_this_shot;
    self.currentammo = self.weapon_ammo_in_magazine;

    makevectors(self.v_angle);
    muzzle_origin = self.origin + self.view_ofs + v_forward * 10 + v_right * 3 + v_up * -5;
    dprint("W_FireSawnoff: Calling W_am_fire_buckshot_parameterized. Sound='", sound_to_play_now, "', Discharges=", ftos(num_discharges_this_shot),"\n");
    W_am_fire_buckshot_parameterized(
        muzzle_origin, 
        num_discharges_this_shot, 
        WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY, 
        WEAPON_SAWNOFF_SPREAD_MOD_PRIMARY, 
        WEAPON_SAWNOFF_DAMAGE_MOD_PRIMARY, 
        sound_to_play_now, 
        self
    );
    dprint("W_FireSawnoff: Applying recoil.\n");
    AM_ApplyRecoil(recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax);

    self.attack_finished = time + current_cooldown;
    player_run(); 
    dprint("W_FireSawnoff: Exiting normally.\n");
}

//=============================================================================
// w_sawnoff.qc - FQX Mod - Sawn-off Double Barrel Shotgun (Diagnostic) - END
// ##FQX - ##Quedra: Version 1.2
//=============================================================================