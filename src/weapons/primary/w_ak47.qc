//============================================================================
// Weapon: AK47 Assault Rifle (w_ak47.qc) - Property Definitions
// ##Quedra: Data sheet for the new modular ballistic weapon system. Version 2.1
//============================================================================

// --- Core Identity ---
string AK47_WEAPON_NAME_UI      = "AK-47";
string AK47_VIEWMODEL           = "progs/v_ak47.mdl";
float  AK47_WEAPON_SLOT_IT_FLAG = IT_SLOT_HEAVY;

// --- Ammunition & Magazine ---
float  AK47_AMMO_RESOURCE_ID    = AMMO_ID_NAILS; 
float  AK47_AMMO_COST_PER_SHOT  = 1;
float  AK47_MAG_CAPACITY        = 30;
float  AK47_RELOAD_TIME_SEC     = 3.8; 
float  AK47_RELOAD_TYPE         = RELOAD_TYPE_MAGAZINE_REPLACE;
float  AK47_RELOAD_COST_TOTAL   = 30; 

// --- Ballistics ---
float  AK47_CALIBER             = CAL_762x39;
float  AK47_BULLET_TYPE         = BLT_FMJ;

// --- Firing Characteristics ---
float  AK47_CYCLIC_RPM          = 600;
float  AK47_NUM_STANDARD_MODES  = 2;   // Single, Full-Auto

// --- Handling, Ergonomics, Weight ---
float  AK47_BASE_ACCURACY_SINGLE = 1.5; 
float  AK47_BASE_ACCURACY_AUTO   = 0.8; 
float  AK47_ERGONOMICS          = 5.0; 
float  AK47_HANDLING            = 6.0; 
float  AK47_WEIGHT_LBS          = 7.7; 
float  AK47_WEIGHT_CLASS        = WEIGHT_CLASS_MEDIUM;

// --- Recoil Parameters ---
// For Semi-Auto Mode:
float AK47_RECOIL_S_STR         = 1.8; float AK47_RECOIL_S_SPR         = 0.2;
float AK47_RECOIL_S_VERT_BIAS   = 1.5; float AK47_RECOIL_S_SUST_MULT   = 0.0; float AK47_RECOIL_S_MAX_SUST    = 1.0;
// For Full-Auto Mode:
float AK47_RECOIL_A_STR         = 1.6; float AK47_RECOIL_A_SPR         = 0.3;
float AK47_RECOIL_A_VERT_BIAS   = 1.8; float AK47_RECOIL_A_SUST_MULT   = 0.15;float AK47_RECOIL_A_MAX_SUST   = 3.5;
// For Debug Mode:
float AK47_RECOIL_D_STR         = 0.1; float AK47_RECOIL_D_SPR         = 0;
float AK47_RECOIL_D_VERT_BIAS   = 1.0; float AK47_RECOIL_D_SUST_MULT   = 0;   float AK47_RECOIL_D_MAX_SUST   = 1;    

vector AK47_RECOIL_PATTERN      = '-0.1 0.2 0'; // Valid 3-component vector
float  AK47_RECOIL_RECOVERY_DURATION_SCALE = 50; 

// --- Sound Definitions ---
string AK47_SOUND_FIRE_PRIMARY  = "weapons/ak47-fire-1.wav"; 
//string AK47_SOUND_FIRE_SECONDARY= "weapons/ak47-fire-2.wav"; // If you add variation
string AK47_SOUND_SWITCHMODE    = "weapons/ak47_switch.wav";
string AK47_SOUND_EMPTY         = "weapons/boltback.wav"; 
string AK47_SOUND_RELOAD_MAGOUT = "weapons/ak_magout.wav";
string AK47_SOUND_RELOAD_MAGIN  = "weapons/ak_magin.wav";
string AK47_SOUND_RELOAD_ACTION = "weapons/ak_bolt.wav";

// --- Animation Frame Placeholders ---
float AK47_FRAME_IDLE           = 0; /* ... more frames ... */

//============================================================================
// ##Quedra: Placeholder functions
//============================================================================
void w_ak47_SetCurrentAmmo() {
    self.weaponmodel = AK47_VIEWMODEL;
    self.currentammo = self.ammo_nails;
    AM_InitWeaponFireModes(AK47_NUM_STANDARD_MODES, TRUE);
}

void W_FireAk47() {
    if (self.ammo_nails >= AK47_AMMO_COST_PER_SHOT) {
        self.ammo_nails -= AK47_AMMO_COST_PER_SHOT; self.currentammo = self.ammo_nails;
        sound(self, CHAN_WEAPON, AK47_SOUND_FIRE_PRIMARY, 1, ATTN_NORM); 
        self.attack_finished = time + (60 / AK47_CYCLIC_RPM);
    } else {
        sound(self, CHAN_AUTO, AK47_SOUND_EMPTY, 1, ATTN_NORM); self.attack_finished = time + 0.5;
    }
}

void W_SwitchModeAk47() {
    AM_CycleFireMode();
    sound(self, CHAN_VOICE, AK47_SOUND_SWITCHMODE, 1, ATTN_NORM);
    local string mode_str = "Unknown";
    if(self.current_weapon_fire_mode == 0) mode_str = "Single";
    else if(self.current_weapon_fire_mode == 1) mode_str = "Auto";
    else if(self.current_weapon_fire_mode == AK47_NUM_STANDARD_MODES && cvar("developer")) mode_str = "Debug";
    sprint(self, PRINT_LOW, strcat(AK47_WEAPON_NAME_UI, ": ", mode_str, "\n"));
}