//============================================================================
// Weapon: AK47 Assault Rifle (w_ak47.qc) - Property Definitions
// ##Quedra: Data sheet for the modular ballistic weapon system. Version 2.8
//============================================================================

// --- Core Identity ---
string AK47_VIEWMODEL           = "progs/v_ak47.mdl";
float  AK47_WEAPON_SLOT_IT_FLAG = IT_SLOT_HEAVY; // ##Quedra: Or IT_SLOT_PRIMARY based on your progs.src folder for it

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
float  AK47_NUM_STANDARD_MODES  = 2;   // Mode 0: Single, Mode 1: Full-Auto
                                        // Debug Mode will be index 2 if cvar("developer") > 0

// --- Handling, Ergonomics, Weight ---
float  AK47_BASE_ACCURACY_SINGLE = 1.5;
float  AK47_BASE_ACCURACY_AUTO   = 0.8; 
float  AK47_ERGONOMICS          = 5.0;
float  AK47_HANDLING            = 6.0;
float  AK47_WEIGHT_LBS          = 7.7;
float  AK47_WEIGHT_CLASS        = WEIGHT_CLASS_MEDIUM;

// --- Recoil Parameters ---
// Mode 0: Semi-Auto (FIRE_MODE_PRIMARY)
float AK47_RECOIL_S_STR         = 1.8;
float AK47_RECOIL_S_SPR         = 0.2;
float AK47_RECOIL_S_VERT_BIAS   = 1.5;
float AK47_RECOIL_S_SUST_MULT   = 0.0; 
float AK47_RECOIL_S_MAX_SUST    = 1.0;
// Mode 1: Full-Auto (FIRE_MODE_SECONDARY)
float AK47_RECOIL_A_STR         = 1.6;
float AK47_RECOIL_A_SPR         = 0.3;
float AK47_RECOIL_A_VERT_BIAS   = 1.8;
float AK47_RECOIL_A_SUST_MULT   = 0.15;
float AK47_RECOIL_A_MAX_SUST    = 3.5;
// Debug Mode (index = AK47_NUM_STANDARD_MODES)
float AK47_RECOIL_D_STR         = 0.1; 
float AK47_RECOIL_D_SPR         = 0;
float AK47_RECOIL_D_VERT_BIAS   = 1.0;
float AK47_RECOIL_D_SUST_MULT   = 0;   
float AK47_RECOIL_D_MAX_SUST    = 1;

vector AK47_RECOIL_PATTERN      = '-0.1 0.2 0'; 
float  AK47_RECOIL_RECOVERY_RATE = 2.0;

// --- Sound Definitions ---
string AK47_SOUND_FIRE_PRIMARY  = "weapons/ak47-fire-1.wav"; 
string AK47_SOUND_SWITCHMODE    = "weapons/ak47_switch.wav";
string AK47_SOUND_EMPTY         = "weapons/boltback.wav"; 
// ... (reload sounds)

//============================================================================
// ##Quedra: Weapon System Functions
//============================================================================
void w_ak47_SetCurrentAmmo() {
    AM_InitializeWeaponView(AK47_VIEWMODEL, AK47_AMMO_RESOURCE_ID, AK47_WEAPON_SLOT_IT_FLAG);
    AM_InitWeaponFireModes(AK47_NUM_STANDARD_MODES); // ##Quedra: Removed second param
    AM_SetRecoilPattern(AK47_RECOIL_PATTERN, AK47_RECOIL_RECOVERY_RATE);
    self.burst_active = FALSE; // ##Quedra: AK47 doesn't use burst, good practice
    self.attack_finished = time;
}

void W_FireAk47() {
    self.weapon_ammo_resource_id = AK47_AMMO_RESOURCE_ID;
    self.weapon_ammo_cost_per_shot = AK47_AMMO_COST_PER_SHOT;

    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) 
    {
        if (!AM_CanFireSemiAuto()) { return; }
    }
    // ##Quedra: For Full-Auto (FIRE_MODE_SECONDARY) and Debug mode, W_WeaponFrame handles re-fire

    if (AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.weapon_ammo_cost_per_shot) {
        sound(self, CHAN_AUTO, AK47_SOUND_EMPTY, 1, ATTN_NORM); 
        self.attack_finished = time + 0.5;
        self.weapon_fire_released = TRUE;
        return;
    }
    
    self.weapon_fire_released = FALSE;

    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) 
    {
        AM_ExecuteStandardFire_Parameterized(AK47_CALIBER, AK47_BULLET_TYPE, AK47_BASE_ACCURACY_SINGLE, FALSE,
                                           AK47_RECOIL_S_STR, AK47_RECOIL_S_SPR, AK47_RECOIL_S_VERT_BIAS, AK47_RECOIL_S_SUST_MULT, AK47_RECOIL_S_MAX_SUST,
                                           AK47_SOUND_FIRE_PRIMARY, AK47_CYCLIC_RPM);
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) // Full-Auto
    {
        AM_ExecuteStandardFire_Parameterized(AK47_CALIBER, AK47_BULLET_TYPE, AK47_BASE_ACCURACY_AUTO, FALSE,
                                           AK47_RECOIL_A_STR, AK47_RECOIL_A_SPR, AK47_RECOIL_A_VERT_BIAS, AK47_RECOIL_A_SUST_MULT, AK47_RECOIL_A_MAX_SUST,
                                           AK47_SOUND_FIRE_PRIMARY, AK47_CYCLIC_RPM);
    }
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) 
    {
        AM_ExecuteStandardFire_Parameterized(AK47_CALIBER, AK47_BULLET_TYPE, 100, TRUE, 
                                           AK47_RECOIL_D_STR, AK47_RECOIL_D_SPR, AK47_RECOIL_D_VERT_BIAS, AK47_RECOIL_D_SUST_MULT, AK47_RECOIL_D_MAX_SUST,
                                           AK47_SOUND_FIRE_PRIMARY, AK47_CYCLIC_RPM);
    }
    else
    {
        self.attack_finished = time + 0.1; 
        return;
    }
}

void W_SwitchModeAk47() {
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, AK47_SOUND_SWITCHMODE, 1, ATTN_NORM);
    
    if(self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) { sprint(self, "AK-47: Single Shot\n"); }
    else if(self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) { sprint(self, "AK-47: Full-Auto\n"); }
    else if(self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) { sprint(self, "AK-47: Debug Full-Auto\n"); }
    
    AM_ResetSustainedRecoil(); 
    self.attack_finished = time;
    self.weapon_fire_released = TRUE;
}