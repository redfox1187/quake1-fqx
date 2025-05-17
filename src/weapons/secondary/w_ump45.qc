//============================================================================
// Weapon: UMP45 SMG (w_ump45.qc) - Property Definitions
// ##Quedra: Data sheet for the new modular ballistic weapon system. Version 2.1
//============================================================================

// --- Core Identity ---
string UMP45_WEAPON_NAME_UI     = "UMP-45";
string UMP45_VIEWMODEL          = "progs/v_ump45.mdl";
float  UMP45_WEAPON_SLOT_IT_FLAG= IT_SLOT_PRIMARY;

// --- Ammunition & Magazine ---
float  UMP45_AMMO_RESOURCE_ID   = AMMO_ID_NAILS; 
float  UMP45_AMMO_COST_PER_SHOT = 1;
float  UMP45_MAG_CAPACITY       = 25;
float  UMP45_RELOAD_TIME_SEC    = 3.0; 
float  UMP45_RELOAD_TYPE        = RELOAD_TYPE_MAGAZINE_REPLACE;
float  UMP45_RELOAD_COST_TOTAL  = 20; 

// --- Ballistics ---
float  UMP45_CALIBER            = CAL_45ACP;
float  UMP45_BULLET_TYPE        = BLT_FMJ;

// --- Firing Characteristics ---
float  UMP45_CYCLIC_RPM         = 600;
float  UMP45_NUM_STANDARD_MODES = 3;   // Single, 3-Round Burst, Full-Auto
float  UMP45_BURST_SHOT_COUNT   = 3;

// --- Handling, Ergonomics, Weight ---
float  UMP45_BASE_ACCURACY_SINGLE = 1.5; 
float  UMP45_BASE_ACCURACY_BURST  = 1.2; 
float  UMP45_BASE_ACCURACY_AUTO   = 0.9; 
float  UMP45_ERGONOMICS         = 8.0; 
float  UMP45_HANDLING           = 8.5; 
float  UMP45_WEIGHT_LBS         = 5.0; 
float  UMP45_WEIGHT_CLASS       = WEIGHT_CLASS_MEDIUM;

// --- Recoil Parameters ---
// For Semi-Auto Mode:
float UMP45_RECOIL_S_STR        = 0.8; float UMP45_RECOIL_S_SPR        = 0.3;
float UMP45_RECOIL_S_VERT_BIAS  = 2.5; float UMP45_RECOIL_S_SUST_MULT  = 0.2; float UMP45_RECOIL_S_MAX_SUST   = 1.5;
// For Burst-Fire Mode:
float UMP45_RECOIL_B_STR        = 1.0; float UMP45_RECOIL_B_SPR        = 0.4;
float UMP45_RECOIL_B_VERT_BIAS  = 2.5; float UMP45_RECOIL_B_SUST_MULT  = 0.3; float UMP45_RECOIL_B_MAX_SUST   = 2.0;
// For Auto-Fire Mode:
float UMP45_RECOIL_A_STR        = 1.1; float UMP45_RECOIL_A_SPR        = 0.5;
float UMP45_RECOIL_A_VERT_BIAS  = 2.5; float UMP45_RECOIL_A_SUST_MULT  = 0.15;float UMP45_RECOIL_A_MAX_SUST  = 3.0;
// For Debug Mode:
float UMP45_RECOIL_D_STR        = 0.1; float UMP45_RECOIL_D_SPR        = 0;
float UMP45_RECOIL_D_VERT_BIAS  = 1.0; float UMP45_RECOIL_D_SUST_MULT  = 0;   float UMP45_RECOIL_D_MAX_SUST   = 1;

vector UMP45_RECOIL_PATTERN     = '0.1 0.2 0'; // Valid 3-component vector
float  UMP45_RECOIL_RECOVERY_DURATION_SCALE = 20;

// --- Sound Definitions ---
string UMP45_SOUND_FIRE_PRIMARY = "weapons/ump45-1.wav";
string UMP45_SOUND_SWITCHMODE   = "weapons/weaponclick.wav"; 
string UMP45_SOUND_EMPTY        = "weapons/boltback.wav";
string UMP45_SOUND_RELOAD_MAGOUT= "weapons/ump45_magout.wav";
string UMP45_SOUND_RELOAD_MAGIN = "weapons/ump45_magin.wav";
string UMP45_SOUND_RELOAD_ACTION= "weapons/ump45_bolt.wav";

// --- Animation Frame Placeholders ---
float UMP45_FRAME_IDLE          = 0; /* ... more frames ... */

//============================================================================
// ##Quedra: Placeholder functions
//============================================================================
void w_ump45_SetCurrentAmmo() {
    self.weaponmodel = UMP45_VIEWMODEL;
    self.currentammo = self.ammo_nails;
    AM_InitWeaponFireModes(UMP45_NUM_STANDARD_MODES, TRUE);
}

void W_FireUMP45() {
    if (self.ammo_nails >= UMP45_AMMO_COST_PER_SHOT) {
        self.ammo_nails -= UMP45_AMMO_COST_PER_SHOT; self.currentammo = self.ammo_nails;
        sound(self, CHAN_WEAPON, UMP45_SOUND_FIRE_PRIMARY, 1, ATTN_NORM);
        self.attack_finished = time + (60 / UMP45_CYCLIC_RPM);
    } else {
        sound(self, CHAN_AUTO, UMP45_SOUND_EMPTY, 1, ATTN_NORM); self.attack_finished = time + 0.5;
    }
}

void W_SwitchModeUMP45() {
    AM_CycleFireMode();
    sound(self, CHAN_VOICE, UMP45_SOUND_SWITCHMODE, 1, ATTN_NORM);
    local string mode_str = "Unknown";
    if(self.current_weapon_fire_mode == 0) mode_str = "Single";
    else if(self.current_weapon_fire_mode == 1) mode_str = "Burst";
    else if(self.current_weapon_fire_mode == 2) mode_str = "Auto";
    else if(self.current_weapon_fire_mode == UMP45_NUM_STANDARD_MODES && cvar("developer")) mode_str = "Debug";
    sprint(self, PRINT_LOW, strcat(UMP45_WEAPON_NAME_UI, ": ", mode_str, "\n"));
}