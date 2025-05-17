//============================================================================
// Weapon: Beretta M93R Machine Pistol (w_m93r.qc) - Property Definitions
// ##Quedra: Data sheet for the new modular ballistic weapon system. Version 2.1
//============================================================================

// --- Core Identity ---
string M93R_WEAPON_NAME_UI      = "Beretta M93R";
string M93R_VIEWMODEL           = "progs/v_rahpm1.mdl";
float  M93R_WEAPON_SLOT_IT_FLAG = IT_SLOT_HOLDOUT;

// --- Ammunition & Magazine ---
float  M93R_AMMO_RESOURCE_ID    = AMMO_ID_SHELLS;
float  M93R_AMMO_COST_PER_SHOT  = 1;
float  M93R_MAG_CAPACITY        = 20;
float  M93R_RELOAD_TIME_SEC     = 2.8;
float  M93R_RELOAD_TYPE         = RELOAD_TYPE_MAGAZINE_REPLACE; // ##Quedra: This MUST match a float constant from defs.qc
float  M93R_RELOAD_COST_TOTAL   = 10;

// --- Ballistics ---
float  M93R_CALIBER             = CAL_9MM;
float  M93R_BULLET_TYPE         = BLT_FMJ;

// --- Firing Characteristics ---
float  M93R_CYCLIC_RPM          = 1100;
float  M93R_NUM_STANDARD_MODES  = 2;    // Mode 0: Semi-Auto, Mode 1: 3-Round Burst
float  M93R_BURST_SHOT_COUNT    = 3;

// --- Handling, Ergonomics, Weight ---
float  M93R_BASE_ACCURACY       = 1.8;
float  M93R_ERGONOMICS          = 7.0;
float  M93R_HANDLING            = 7.5;
float  M93R_WEIGHT_LBS          = 2.5;
float  M93R_WEIGHT_CLASS        = WEIGHT_CLASS_LIGHT;

// --- Recoil Parameters ---
// For Semi-Auto Mode:
float M93R_RECOIL_S_STR         = 0.8;  float M93R_RECOIL_S_SPR         = 0.3;
float M93R_RECOIL_S_VERT_BIAS   = 2.5;  float M93R_RECOIL_S_SUST_MULT   = 0.0;  float M93R_RECOIL_S_MAX_SUST    = 1.0;
// For Burst-Fire Mode (per shot):
float M93R_RECOIL_B_STR         = 1.0;  float M93R_RECOIL_B_SPR         = 0.35;
float M93R_RECOIL_B_VERT_BIAS   = 2.8;  float M93R_RECOIL_B_SUST_MULT   = 0.2;  float M93R_RECOIL_B_MAX_SUST    = 2.5;
// For Debug Mode:
float M93R_RECOIL_D_STR         = 0.1;  float M93R_RECOIL_D_SPR         = 0;
float M93R_RECOIL_D_VERT_BIAS   = 1.0;  float M93R_RECOIL_D_SUST_MULT   = 0;    float M93R_RECOIL_D_MAX_SUST    = 1;

vector M93R_RECOIL_PATTERN      = '-0.1 0.15 0'; // This is a valid 3-component vector
float  M93R_RECOIL_RECOVERY_DURATION_SCALE = 30;

// --- Sound Definitions ---
string M93R_SOUND_FIRE_PRIMARY    = "weapons/9mm_Pistol-1.wav";
string M93R_SOUND_FIRE_SECONDARY  = "weapons/9mm_Pistol-2.wav";
string M93R_SOUND_SWITCHMODE    = "weapons/9mm_Pistol_Switch-01.wav";
string M93R_SOUND_EMPTY         = "weapons/boltback.wav";
string M93R_SOUND_RELOAD_MAGOUT = "weapons/m93r_magout.wav";
string M93R_SOUND_RELOAD_MAGIN  = "weapons/m93r_magin.wav";
string M93R_SOUND_RELOAD_ACTION = "weapons/m93r_bolt.wav";

// --- Animation Frame Placeholders ---
float M93R_FRAME_IDLE           = 0; /* ... more frames ... */

//============================================================================
// ##Quedra: Placeholder functions for the new system
//============================================================================
void w_m93r_SetCurrentAmmo() {
    self.weaponmodel = M93R_VIEWMODEL;
    self.currentammo = self.ammo_shells; // Will be replaced by AM_Weapon_Select logic
    AM_InitWeaponFireModes(M93R_NUM_STANDARD_MODES, TRUE);
}

void W_FireM93R() {
    if (self.ammo_shells >= M93R_AMMO_COST_PER_SHOT) { 
        self.ammo_shells -= M93R_AMMO_COST_PER_SHOT; self.currentammo = self.ammo_shells; 
        sound(self, CHAN_WEAPON, M93R_SOUND_FIRE_PRIMARY, 1, ATTN_NORM); 
        self.attack_finished = time + (60 / M93R_CYCLIC_RPM); 
    } else { 
        sound(self, CHAN_AUTO, M93R_SOUND_EMPTY, 1, ATTN_NORM); self.attack_finished = time + 0.5;
    }
}

void W_SwitchModeM93R() {
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, M93R_SOUND_SWITCHMODE, 1, ATTN_NORM);
    local string mode_str = "Unknown";
    if(self.current_weapon_fire_mode == 0) mode_str = "Semi-Auto";
    else if(self.current_weapon_fire_mode == 1) mode_str = "Burst";
    else if(self.current_weapon_fire_mode == M93R_NUM_STANDARD_MODES && cvar("developer")) mode_str = "Debug";
    sprint(self, PRINT_LOW, strcat(M93R_WEAPON_NAME_UI, ": ", mode_str, "\n"));
}