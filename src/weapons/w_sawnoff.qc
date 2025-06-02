//=============================================================================
// w_sawnoff.qc - FQX Mod - Sawn-off Double Barrel Shotgun
// Location: \src\weapons\secondary
// ##FQX - ##Quedra: Version 1.7.0
// ##Quedra: Datasheet and logic for the Sawn-off Shotgun.
// ##Quedra: Dependencies: Uses am_reload.qc, am_buckshot.qc, defs_2.qc.
// ##Quedra:             Requires GetShellResourceCost() from am_buckshot.qc (v2.6.0+).
// ##Quedra: v1.7.0 - Updated to use GetShellResourceCost() for dynamic ammo resource cost
// ##Quedra:          based on WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY.
// ##Quedra:        - Removed SAWNOFF_GAME_AMMO_COST_PER_ROUND constant.
// ##Quedra:        - Integrated Soldier's cooldown tweaks (0.4s/0.7s).
// ##Quedra: v1.6.0 - Implemented new viewmodel animation system for firing:
// ##Quedra:        - Added SAWNOFF_FRAME_* constants for idle, fire start/end.
// ##Quedra:        - Created w_sawnoff_AnimateFireThink() to cycle through 5 fire frames.
// ##Quedra:        - Animation duration dynamically matches current fire mode's cooldown.
// ##Quedra:        - Decoupled from player_run() for viewmodel firing animation.
//=============================================================================

// --- Constants ---
string WEAPON_SAWNOFF_NAME = "Sawn-off";
string WEAPON_SAWNOFF_VIEWMODEL = "progs/v_sawnoff.mdl";
float WEAPON_SAWNOFF_SLOT = IT_SLOT_SECONDARY;
float WEAPON_SAWNOFF_AMMO_RESOURCE_ID = AMMO_ID_SHELLS;
float WEAPON_SAWNOFF_MAG_CAPACITY = 2;
float SAWNOFF_FIREMODE_IDX_SINGLE = 0;
float SAWNOFF_FIREMODE_IDX_DOUBLE = 1;
float WEAPON_SAWNOFF_AMMO_COST_SINGLE = 1;
float WEAPON_SAWNOFF_AMMO_COST_DOUBLE = 2;

//##FQX - ##Fox: Set this up for sell type testing. Only ONE of the following should be active!
// Comment out the others.
float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_000BUCK; // Uses 000 Buck ##: Intended shell type for final game.
// float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_00BUCK;
// float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_0BUCK;
// float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_NO1BUCK;
//float WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_NO4BUCK;

float WEAPON_SAWNOFF_SPREAD_MOD_PRIMARY = 2.0;
float WEAPON_SAWNOFF_DAMAGE_MOD_PRIMARY = 1.0;
float WEAPON_SAWNOFF_COOLDOWN_SINGLE = 0.4; // User's v1.6.0 tweak
float WEAPON_SAWNOFF_COOLDOWN_DOUBLE = 0.7; // User's v1.6.0 tweak

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
string SAWNOFF_SOUND_SWITCHMODE_LOADED = "weapons/weaponclick.wav";
string SAWNOFF_SOUND_SWITCHMODE_EMPTY = "weapons/weaponclick.wav";
float SAWNOFF_RELOAD_DURATION = 0.5;
// float SAWNOFF_GAME_AMMO_COST_PER_ROUND = 2 * GAME_AMMO_COST_PER_SHOTGUN_ROUND; // ##Quedra v1.7.0: Removed, now dynamic
string SAWNOFF_RELOAD_START_SOUND = SOUND_RELOAD_START_DEFAULT;
string SAWNOFF_RELOAD_FINISH_SOUND = SOUND_RELOAD_FINISH_DEFAULT;
float SAWNOFF_RELOAD_ANIM_FRAME = RELOAD_ANIM_FRAME_DEFAULT;
float SAWNOFF_CAN_MANUAL_RELOAD = TRUE;

// ##Quedra: v1.6.0 - Animation Frame Constants
float SAWNOFF_FRAME_IDLE = 0;
float SAWNOFF_FRAME_FIRE_START = 1;
float SAWNOFF_FRAME_FIRE_END = 5;
float SAWNOFF_NUM_FIRE_FRAMES = 5;

// Forward declarations
void w_sawnoff_SetCurrentAmmo (void);
void W_FireSawnoff (void);
void W_SwitchModeSawnoff (void);
void w_sawnoff_PrintCurrentMode (void);
void w_sawnoff_AnimateFireThink(void);

//-----------------------------------------------------------------------------
// ##Quedra: w_sawnoff_AnimateFireThink (v1.6.0)
//-----------------------------------------------------------------------------
void w_sawnoff_AnimateFireThink()
{
    local float fire_mode_cooldown;
    local float frame_duration_for_this_think;
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_SINGLE)
    {
        fire_mode_cooldown = WEAPON_SAWNOFF_COOLDOWN_SINGLE;
    }
    else if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE)
    {
        fire_mode_cooldown = WEAPON_SAWNOFF_COOLDOWN_DOUBLE;
    }
    else 
    {
        self.weaponframe = SAWNOFF_FRAME_IDLE;
        self.think = SUB_Null;
        self.nextthink = -1;
        return;
    }
    if (SAWNOFF_NUM_FIRE_FRAMES <= 0)
    {
         self.weaponframe = SAWNOFF_FRAME_IDLE;
         self.think = SUB_Null; 
         self.nextthink = -1;
         return;
    }
    frame_duration_for_this_think = fire_mode_cooldown / SAWNOFF_NUM_FIRE_FRAMES;
    if (self.weapon == WEAPON_SAWNOFF_SLOT && self.weaponframe >= SAWNOFF_FRAME_FIRE_START && self.weaponframe < SAWNOFF_FRAME_FIRE_END)
    {
        self.weaponframe = self.weaponframe + 1;
        self.think = w_sawnoff_AnimateFireThink;
        self.nextthink = time + frame_duration_for_this_think;
    }
    else 
    {
        if (self.weapon == WEAPON_SAWNOFF_SLOT)
        {
            self.weaponframe = SAWNOFF_FRAME_IDLE;
        }
        self.think = SUB_Null;
        self.nextthink = -1;
    }
}

//-----------------------------------------------------------------------------
// ##Quedra: w_sawnoff_PrintCurrentMode
//-----------------------------------------------------------------------------
void w_sawnoff_PrintCurrentMode () 
{ 
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_SINGLE) { sprint(self, "Sawn-off: Single Barrel\n"); } 
    else if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE) { sprint(self, "Sawn-off: Double Barrel\n"); } 
    else { sprint(self, "Sawn-off: System Debug Mode\n"); } 
}

//-----------------------------------------------------------------------------
// ##Quedra: w_sawnoff_SetCurrentAmmo
// ##Quedra: v1.7.0 - Uses GetShellResourceCost for self.current_weapon_game_ammo_cost_per_round
//-----------------------------------------------------------------------------
void w_sawnoff_SetCurrentAmmo () 
{ 
    AM_InitializeWeaponView(WEAPON_SAWNOFF_VIEWMODEL, WEAPON_SAWNOFF_AMMO_RESOURCE_ID, WEAPON_SAWNOFF_SLOT);
    self.weapon_ammo_resource_id = WEAPON_SAWNOFF_AMMO_RESOURCE_ID;
    
    // ##Quedra v1.7.0: Set resource cost dynamically based on shell type
    self.current_weapon_game_ammo_cost_per_round = GetShellResourceCost(WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY);
    
    AM_InitWeaponFireModes(2); 
    AM_SetRecoilPattern(SAWNOFF_RECOIL_PATTERN_AIM, SAWNOFF_RECOIL_RECOVERY_RATE);
    self.sawnoff_sound_toggle = 0;
    self.current_weapon_max_mag_capacity = WEAPON_SAWNOFF_MAG_CAPACITY; 
    self.current_weapon_reload_duration = SAWNOFF_RELOAD_DURATION; 
    // self.current_weapon_game_ammo_cost_per_round is now set above
    self.current_weapon_reload_start_sound = SAWNOFF_RELOAD_START_SOUND;
    self.current_weapon_reload_finish_sound = SAWNOFF_RELOAD_FINISH_SOUND;
    self.current_weapon_reload_anim_frame = SAWNOFF_RELOAD_ANIM_FRAME;
    self.current_weapon_can_manual_reload = SAWNOFF_CAN_MANUAL_RELOAD; 
    self.current_weapon_sound_empty = SAWNOFF_SOUND_EMPTY_CLICK; 
    self.weapon_is_reloading = FALSE;
    if (self.think == w_sawnoff_AnimateFireThink) {
        self.think = SUB_Null;
        self.nextthink = -1;
    }
    self.weaponframe = SAWNOFF_FRAME_IDLE;
    if (self.weapon_first_draw_init == TRUE) 
    { 
        local float rounds_to_load_initial = 0;
        if (self.ammo_shells >= (self.current_weapon_game_ammo_cost_per_round * 2)) { rounds_to_load_initial = 2; } 
        else if (self.ammo_shells >= self.current_weapon_game_ammo_cost_per_round) { rounds_to_load_initial = 1; } 
        self.weapon_ammo_in_magazine = rounds_to_load_initial; 
        self.weapon_first_draw_init = FALSE;
        w_sawnoff_PrintCurrentMode();
    } 
    self.currentammo = self.weapon_ammo_in_magazine; 
}

//-----------------------------------------------------------------------------
// ##Quedra: W_SwitchModeSawnoff
//-----------------------------------------------------------------------------
void W_SwitchModeSawnoff () 
{ 
    if (self.weapon_is_reloading == TRUE) { 
        self.weapon_is_reloading = FALSE;
        self.think = SUB_Null; 
        self.nextthink = -1; 
        self.weaponframe = SAWNOFF_FRAME_IDLE;
    } 
    if (self.think == w_sawnoff_AnimateFireThink) {
        self.think = SUB_Null;
        self.nextthink = -1;
    }
    self.weaponframe = SAWNOFF_FRAME_IDLE;
    AM_CycleFireMode();
    if (self.weapon_ammo_in_magazine > 0) { sound(self, CHAN_ITEM, SAWNOFF_SOUND_SWITCHMODE_LOADED, 1, ATTN_NORM); } 
    else { sound(self, CHAN_ITEM, SAWNOFF_SOUND_SWITCHMODE_EMPTY, 1, ATTN_NORM); } 
    w_sawnoff_PrintCurrentMode();
}

//-----------------------------------------------------------------------------
// ##Quedra: W_FireSawnoff
//-----------------------------------------------------------------------------
void W_FireSawnoff ()
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
    if (self.think == w_sawnoff_AnimateFireThink && time < self.attack_finished) { return; }

    sound_to_play_now = string_null;
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_SINGLE)
    {
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1; 
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_SINGLE; // Uses Soldier's tweaked value
        recoil_str = SAWNOFF_RECOIL_S_STRENGTH; recoil_spr = SAWNOFF_RECOIL_S_SPREAD; recoil_vbias = SAWNOFF_RECOIL_S_VERT_BIAS;
        recoil_smult = SAWNOFF_RECOIL_S_SUST_MULT; recoil_smax = SAWNOFF_RECOIL_S_MAX_SUST;
        if (self.sawnoff_sound_toggle == 0) { sound_to_play_now = SAWNOFF_SOUND_FIRE_S_P1; self.sawnoff_sound_toggle = 1; }
        else { sound_to_play_now = SAWNOFF_SOUND_FIRE_S_P2; self.sawnoff_sound_toggle = 0; }
    }
    else if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE)
    {
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_DOUBLE;
        num_discharges_this_shot = 2; 
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_DOUBLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_DOUBLE; // Uses Soldier's tweaked value
        recoil_str = SAWNOFF_RECOIL_D_STRENGTH; recoil_spr = SAWNOFF_RECOIL_D_SPREAD; recoil_vbias = SAWNOFF_RECOIL_D_VERT_BIAS;
        recoil_smult = SAWNOFF_RECOIL_D_SUST_MULT; recoil_smax = SAWNOFF_RECOIL_D_MAX_SUST;
        if (self.sawnoff_sound_toggle == 0) { sound_to_play_now = SAWNOFF_SOUND_FIRE_D_P1; self.sawnoff_sound_toggle = 1; }
        else { sound_to_play_now = SAWNOFF_SOUND_FIRE_D_P2; self.sawnoff_sound_toggle = 0; }
    }
    else {
        full_error_message = strcat("Sawn-off: Invalid fire mode (", ftos(self.current_weapon_fire_mode), ") selected for firing!\n");
        sprint(self, full_error_message);
        self.attack_finished = time + 0.1; 
        return;
    }
    if (self.current_weapon_fire_mode == SAWNOFF_FIREMODE_IDX_DOUBLE && self.weapon_ammo_in_magazine == 1)
    {
        sprint(self, "Sawn-off: Firing single shell from double mode (1 round left).\n");
        rounds_needed_for_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        num_discharges_this_shot = 1; 
        actual_ammo_cost_this_shot = WEAPON_SAWNOFF_AMMO_COST_SINGLE;
        current_cooldown = WEAPON_SAWNOFF_COOLDOWN_SINGLE; 
        recoil_str = SAWNOFF_RECOIL_S_STRENGTH; recoil_spr = SAWNOFF_RECOIL_S_SPREAD;
        recoil_vbias = SAWNOFF_RECOIL_S_VERT_BIAS; 
        recoil_smult = SAWNOFF_RECOIL_S_SUST_MULT; recoil_smax = SAWNOFF_RECOIL_S_MAX_SUST;
    }
    if (self.weapon_ammo_in_magazine < rounds_needed_for_shot)
    {
        sound(self, CHAN_VOICE, SAWNOFF_SOUND_EMPTY_CLICK, 1, ATTN_NORM);
        AM_InitiateWeaponReload(); 
        return; 
    }
    self.weapon_ammo_in_magazine -= actual_ammo_cost_this_shot;
    self.currentammo = self.weapon_ammo_in_magazine; 
    makevectors(self.v_angle);
    muzzle_origin = self.origin + self.view_ofs + v_forward * 10 + v_right * 3 + v_up * -5;
    W_am_fire_buckshot_parameterized( muzzle_origin, num_discharges_this_shot, WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY, WEAPON_SAWNOFF_SPREAD_MOD_PRIMARY, WEAPON_SAWNOFF_DAMAGE_MOD_PRIMARY, sound_to_play_now, self );
    AM_ApplyRecoil(recoil_str, recoil_spr, recoil_vbias, recoil_smult, recoil_smax);
    self.weaponframe = SAWNOFF_FRAME_FIRE_START; 
    local float frame_duration_for_next_think;
    if (SAWNOFF_NUM_FIRE_FRAMES <= 0) { frame_duration_for_next_think = current_cooldown; }
    else { frame_duration_for_next_think = current_cooldown / SAWNOFF_NUM_FIRE_FRAMES; }
    self.think = w_sawnoff_AnimateFireThink;
    self.nextthink = time + frame_duration_for_next_think;
    self.attack_finished = time + current_cooldown;
}

//=============================================================================
// w_sawnoff.qc - FQX Mod - Sawn-off Double Barrel Shotgun - END
// ##FQX - ##Quedra: Version 1.7.0
//=============================================================================