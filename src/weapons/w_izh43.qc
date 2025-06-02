//=============================================================================
// w_izh43.qc - FQX Mod - IZh-43 Double Barrel Shotgun (Long Barrel)
// Location: \src\weapons\secondary 
// ##FQX - ##Quedra: Version 1.2.0
// ##Quedra: Datasheet and logic for the IZh-43.
// ##Quedra: Dependencies: Uses am_reload.qc, am_buckshot.qc, defs_2.qc.
// ##Quedra:             Requires GetShellResourceCost() from am_buckshot.qc (v2.6.0+).
// ##Quedra: v1.2.0 - Updated to use GetShellResourceCost() for dynamic ammo resource cost
// ##Quedra:          based on WEAPON_IZH43_SHELL_TYPE_PRIMARY.
// ##Quedra:        - Removed IZH43_GAME_AMMO_COST_PER_ROUND constant.
// ##Quedra: v1.1.0 - Integrated Soldier's cooldown adjustments and intended model.
// ##Quedra:        - Corrected w_izh43_AnimateFireThink to use GetWeaponIDForITSlot for robust slot handling.
// ##Quedra: v1.0.0 - Based on w_sawnoff.qc v1.6.0. Represents a long-barrel variant.
// ##Quedra:          Models and sounds initially shared with Sawn-off. Implemented dynamic animation.
//=============================================================================

// --- Constants ---
string WEAPON_IZH43_NAME = "IZh-43";
string WEAPON_IZH43_VIEWMODEL = "progs/v_izh-43.mdl";
float WEAPON_IZH43_SLOT = IT_SLOT_SECONDARY;
float WEAPON_IZH43_AMMO_RESOURCE_ID = AMMO_ID_SHELLS;
float WEAPON_IZH43_MAG_CAPACITY = 2;
float IZH43_FIREMODE_IDX_SINGLE = 0;
float IZH43_FIREMODE_IDX_DOUBLE = 1;
float WEAPON_IZH43_AMMO_COST_SINGLE = 1;
float WEAPON_IZH43_AMMO_COST_DOUBLE = 2;
float WEAPON_IZH43_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_000BUCK;

float WEAPON_IZH43_SPREAD_MOD_PRIMARY = 1.0;
float WEAPON_IZH43_DAMAGE_MOD_PRIMARY = 1.0;
float WEAPON_IZH43_COOLDOWN_SINGLE = 0.4;
float WEAPON_IZH43_COOLDOWN_DOUBLE = 0.6;

float IZH43_RECOIL_S_STRENGTH         = 2.0;
float IZH43_RECOIL_S_SPREAD           = 0.6;
float IZH43_RECOIL_S_VERT_BIAS      = 1.5;
float IZH43_RECOIL_S_SUST_MULT      = 0.1;
float IZH43_RECOIL_S_MAX_SUST       = 1.2;
float IZH43_RECOIL_D_STRENGTH         = 4.0;
float IZH43_RECOIL_D_SPREAD           = 0.8;
float IZH43_RECOIL_D_VERT_BIAS      = 1.8;
float IZH43_RECOIL_D_SUST_MULT      = 0.1;
float IZH43_RECOIL_D_MAX_SUST       = 1.2;
vector IZH43_RECOIL_PATTERN_AIM       = '-0.1 0.15 0';
float  IZH43_RECOIL_RECOVERY_RATE     = 1.8;

string IZH43_SOUND_FIRE_S_P1 = "weapons/guncock.wav";
string IZH43_SOUND_FIRE_S_P2 = "weapons/guncock.wav";
string IZH43_SOUND_FIRE_D_P1 = "weapons/shotgn2.wav";
string IZH43_SOUND_FIRE_D_P2 = "weapons/shotgn2.wav";
string IZH43_SOUND_EMPTY_CLICK = "weapons/boltback.wav";
string IZH43_SOUND_SWITCHMODE_LOADED = "weapons/weaponclick.wav";
string IZH43_SOUND_SWITCHMODE_EMPTY = "weapons/weaponclick.wav";
float IZH43_RELOAD_DURATION = 0.5;
// float IZH43_GAME_AMMO_COST_PER_ROUND = 2 * GAME_AMMO_COST_PER_SHOTGUN_ROUND; // ##Quedra v1.2.0: Removed
string IZH43_RELOAD_START_SOUND = SOUND_RELOAD_START_DEFAULT;
string IZH43_RELOAD_FINISH_SOUND = SOUND_RELOAD_FINISH_DEFAULT;
float IZH43_RELOAD_ANIM_FRAME = RELOAD_ANIM_FRAME_DEFAULT;
float IZH43_CAN_MANUAL_RELOAD = TRUE;

float IZH43_FRAME_IDLE = 0;
float IZH43_FRAME_FIRE_START = 1;
float IZH43_FRAME_FIRE_END = 5;
float IZH43_NUM_FIRE_FRAMES = 5;

// Forward declarations
void w_izh43_SetCurrentAmmo (void);
void W_FireIZH43 (void);
void W_SwitchModeIZH43 (void);
void w_izh43_PrintCurrentMode (void);
void w_izh43_AnimateFireThink(void);

//-----------------------------------------------------------------------------
// ##Quedra: w_izh43_AnimateFireThink (v1.1.0)
//-----------------------------------------------------------------------------
void w_izh43_AnimateFireThink()
{
    local float fire_mode_cooldown;
    local float frame_duration_for_this_think;
    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_SINGLE) { fire_mode_cooldown = WEAPON_IZH43_COOLDOWN_SINGLE; }
    else if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE) { fire_mode_cooldown = WEAPON_IZH43_COOLDOWN_DOUBLE; }
    else { self.weaponframe = IZH43_FRAME_IDLE; self.think = SUB_Null; self.nextthink = -1; return; }
    if (IZH43_NUM_FIRE_FRAMES <= 0) { self.weaponframe = IZH43_FRAME_IDLE; self.think = SUB_Null; self.nextthink = -1; return; }
    frame_duration_for_this_think = fire_mode_cooldown / IZH43_NUM_FIRE_FRAMES;
    if (GetWeaponIDForITSlot(self, self.weapon) == WEAPON_ID_IZH43 && self.weaponframe >= IZH43_FRAME_FIRE_START && self.weaponframe < IZH43_FRAME_FIRE_END)
    {
        self.weaponframe = self.weaponframe + 1;
        self.think = w_izh43_AnimateFireThink;
        self.nextthink = time + frame_duration_for_this_think;
    }
    else 
    {
        if (GetWeaponIDForITSlot(self, self.weapon) == WEAPON_ID_IZH43) { self.weaponframe = IZH43_FRAME_IDLE; }
        self.think = SUB_Null; 
        self.nextthink = -1;
    }
}

//-----------------------------------------------------------------------------
// ##Quedra: w_izh43_PrintCurrentMode
//-----------------------------------------------------------------------------
void w_izh43_PrintCurrentMode () 
{ 
    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_SINGLE) { sprint(self, "IZh-43: Single Barrel\n"); } 
    else if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE) { sprint(self, "IZh-43: Double Barrel\n"); } 
    else { sprint(self, "IZh-43: System Debug Mode\n"); } 
}

//-----------------------------------------------------------------------------
// ##Quedra: w_izh43_SetCurrentAmmo
// ##Quedra: v1.2.0 - Uses GetShellResourceCost for self.current_weapon_game_ammo_cost_per_round
//-----------------------------------------------------------------------------
void w_izh43_SetCurrentAmmo () 
{ 
    AM_InitializeWeaponView(WEAPON_IZH43_VIEWMODEL, WEAPON_IZH43_AMMO_RESOURCE_ID, WEAPON_IZH43_SLOT);
    self.weapon_ammo_resource_id = WEAPON_IZH43_AMMO_RESOURCE_ID;
    
    // ##Quedra v1.2.0: Set resource cost dynamically based on shell type
    self.current_weapon_game_ammo_cost_per_round = GetShellResourceCost(WEAPON_IZH43_SHELL_TYPE_PRIMARY);
    
    AM_InitWeaponFireModes(2); 
    AM_SetRecoilPattern(IZH43_RECOIL_PATTERN_AIM, IZH43_RECOIL_RECOVERY_RATE);
    self.izh43_sound_toggle = 0;
    self.current_weapon_max_mag_capacity = WEAPON_IZH43_MAG_CAPACITY; 
    self.current_weapon_reload_duration = IZH43_RELOAD_DURATION;
    // self.current_weapon_game_ammo_cost_per_round is now set above
    self.current_weapon_reload_start_sound = IZH43_RELOAD_START_SOUND;
    self.current_weapon_reload_finish_sound = IZH43_RELOAD_FINISH_SOUND; 
    self.current_weapon_reload_anim_frame = IZH43_RELOAD_ANIM_FRAME;
    self.current_weapon_can_manual_reload = IZH43_CAN_MANUAL_RELOAD; 
    self.current_weapon_sound_empty = IZH43_SOUND_EMPTY_CLICK;
    self.weapon_is_reloading = FALSE;
    if (self.think == w_izh43_AnimateFireThink) { self.think = SUB_Null; self.nextthink = -1; }
    self.weaponframe = IZH43_FRAME_IDLE;
    if (self.weapon_first_draw_init == TRUE) 
    { 
        local float rounds_to_load_initial = 0;
        if (self.ammo_shells >= (self.current_weapon_game_ammo_cost_per_round * 2)) { rounds_to_load_initial = 2; } 
        else if (self.ammo_shells >= self.current_weapon_game_ammo_cost_per_round) { rounds_to_load_initial = 1; } 
        self.weapon_ammo_in_magazine = rounds_to_load_initial; 
        self.weapon_first_draw_init = FALSE;
        w_izh43_PrintCurrentMode();
    } 
    self.currentammo = self.weapon_ammo_in_magazine; 
}

//-----------------------------------------------------------------------------
// ##Quedra: W_SwitchModeIZH43
//-----------------------------------------------------------------------------
void W_SwitchModeIZH43 () 
{ 
    if (self.weapon_is_reloading == TRUE) { self.weapon_is_reloading = FALSE; self.think = SUB_Null; self.nextthink = -1; self.weaponframe = IZH43_FRAME_IDLE; } 
    if (self.think == w_izh43_AnimateFireThink) { self.think = SUB_Null; self.nextthink = -1; }
    self.weaponframe = IZH43_FRAME_IDLE;
    AM_CycleFireMode();
    if (self.weapon_ammo_in_magazine > 0) { sound(self, CHAN_ITEM, IZH43_SOUND_SWITCHMODE_LOADED, 1, ATTN_NORM); } 
    else { sound(self, CHAN_ITEM, IZH43_SOUND_SWITCHMODE_EMPTY, 1, ATTN_NORM); } 
    w_izh43_PrintCurrentMode();
}

//-----------------------------------------------------------------------------
// ##Quedra: W_FireIZH43
//-----------------------------------------------------------------------------
void W_FireIZH43 ()
{
    local float rounds_needed_for_shot;
    local float num_discharges_this_shot;
    local float actual_ammo_cost_this_shot;
    local string sound_to_play_now;
    local vector muzzle_origin;
    local float current_cooldown; 
    local float recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax;
    local string full_error_message;

    if (self.weapon_is_reloading == TRUE) { return; }
    if (self.think == w_izh43_AnimateFireThink && time < self.attack_finished) { return; }

    sound_to_play_now = string_null;
    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_SINGLE)
    {
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1; 
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_SINGLE;
        recoil_str = IZH43_RECOIL_S_STRENGTH; recoil_spr = IZH43_RECOIL_S_SPREAD; recoil_vbias = IZH43_RECOIL_S_VERT_BIAS;
        recoil_smult = IZH43_RECOIL_S_SUST_MULT; recoil_smax = IZH43_RECOIL_S_MAX_SUST;
        if (self.izh43_sound_toggle == 0) { sound_to_play_now = IZH43_SOUND_FIRE_S_P1; self.izh43_sound_toggle = 1; }
        else { sound_to_play_now = IZH43_SOUND_FIRE_S_P2; self.izh43_sound_toggle = 0; }
    }
    else if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE)
    {
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_DOUBLE;
        num_discharges_this_shot = 2; 
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_DOUBLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_DOUBLE;
        recoil_str = IZH43_RECOIL_D_STRENGTH; recoil_spr = IZH43_RECOIL_D_SPREAD; recoil_vbias = IZH43_RECOIL_D_VERT_BIAS;
        recoil_smult = IZH43_RECOIL_D_SUST_MULT; recoil_smax = IZH43_RECOIL_D_MAX_SUST;
        if (self.izh43_sound_toggle == 0) { sound_to_play_now = IZH43_SOUND_FIRE_D_P1; self.izh43_sound_toggle = 1; }
        else { sound_to_play_now = IZH43_SOUND_FIRE_D_P2; self.izh43_sound_toggle = 0; }
    }
    else 
    {
        full_error_message = strcat("IZh-43: Invalid fire mode (", ftos(self.current_weapon_fire_mode), ") selected for firing!\n");
        sprint(self, full_error_message);
        self.attack_finished = time + 0.1; 
        return;
    }
    if (self.current_weapon_fire_mode == IZH43_FIREMODE_IDX_DOUBLE && self.weapon_ammo_in_magazine == 1)
    {
        sprint(self, "IZh-43: Firing single shell from double mode (1 round left).\n");
        rounds_needed_for_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1; 
        actual_ammo_cost_this_shot = WEAPON_IZH43_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_IZH43_COOLDOWN_SINGLE; 
        recoil_str = IZH43_RECOIL_S_STRENGTH; recoil_spr = IZH43_RECOIL_S_SPREAD;
        recoil_vbias = IZH43_RECOIL_S_VERT_BIAS; 
        recoil_smult = IZH43_RECOIL_S_SUST_MULT; recoil_smax = IZH43_RECOIL_S_MAX_SUST;
    }
    if (self.weapon_ammo_in_magazine < rounds_needed_for_shot)
    {
        sound(self, CHAN_VOICE, IZH43_SOUND_EMPTY_CLICK, 1, ATTN_NORM);
        AM_InitiateWeaponReload(); 
        return; 
    }
    self.weapon_ammo_in_magazine -= actual_ammo_cost_this_shot;
    self.currentammo = self.weapon_ammo_in_magazine; 
    makevectors(self.v_angle);
    muzzle_origin = self.origin + self.view_ofs + v_forward * 10 + v_right * 3 + v_up * -5;
    W_am_fire_buckshot_parameterized( muzzle_origin, num_discharges_this_shot, WEAPON_IZH43_SHELL_TYPE_PRIMARY, WEAPON_IZH43_SPREAD_MOD_PRIMARY, WEAPON_IZH43_DAMAGE_MOD_PRIMARY, sound_to_play_now, self );
    AM_ApplyRecoil(recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax);
    self.weaponframe = IZH43_FRAME_FIRE_START; 
    local float frame_duration_for_next_think;
    if (IZH43_NUM_FIRE_FRAMES <= 0) { frame_duration_for_next_think = current_cooldown; }
    else { frame_duration_for_next_think = current_cooldown / IZH43_NUM_FIRE_FRAMES; }
    self.think = w_izh43_AnimateFireThink;
    self.nextthink = time + frame_duration_for_next_think;
    self.attack_finished = time + current_cooldown;
}

//=============================================================================
// w_izh43.qc - FQX Mod - IZh-43 Double Barrel Shotgun (Long Barrel) - END
// ##FQX - ##Quedra: Version 1.2.0
//=============================================================================