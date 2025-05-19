//============================================================================
<<<<<<< Updated upstream
// Weapon: Ak47 Assault Rifle (w_ak47.qc)
// For FQX Mod - Aligning with W_Attack, player_shot1, and UMP45 specific cleanup
//============================================================================

// --- Weapon Behavior Constants (File-Scope Globals) ---
float AK47_RPM_CYCLIC            = 600;
float AK47_FIRERATE_BASE         = 60 / AK47_RPM_CYCLIC;

float AK47_FIRERATE_SINGLE       = AK47_FIRERATE_BASE;
float AK47_FIRERATE_AUTO         = AK47_FIRERATE_BASE;
float AK47_FIRERATE_DEBUG        = AK47_FIRERATE_BASE;

string AK47_SOUND_FIRE          = "weapons/ak47-fire-1.wav";
string AK47_SOUND_SWITCHMODE    = "weapons/ak47_switch.wav";
string AK47_VIEWMODEL           = "progs/v_ak47.mdl";
=======
// Weapon: AK47 Assault Rifle (w_ak47.qc) - Property Definitions
// ##Quedra: Data sheet for the modular ballistic weapon system. Version 2.8
//============================================================================

// --- Core Identity ---
string AK47_VIEWMODEL           = "progs/v_ak47.mdl";
float  AK47_WEAPON_SLOT_IT_FLAG = IT_SLOT_HEAVY; // ##Quedra: Or IT_SLOT_PRIMARY based on your progs.src folder for it
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

float  AK47_AMMO_ID             = AMMO_ID_NAILS;

float  AK47_CALIBER             = CAL_762x39;
float  AK47_BULLET_TYPE         = BLT_FMJ;

<<<<<<< Updated upstream
float  AK47_ACCURACY_SINGLE     = 1.5;
float  AK47_ACCURACY_AUTO       = 0.8;
float  AK47_ACCURACY_DEBUG      = 9999;

vector AK47_RECOIL_PATTERN      = '-0.1 0.2 0';
float  AK47_RECOIL_RECOVERY     = 2.0;

float R_S_STR = 1.8, R_S_SPR = 0.2, R_S_VERT_BIAS = 1.5, R_S_SUST_MULT = 0.0, R_S_MAX_SUST = 1.0;
float R_A_STR = 1.6, R_A_SPR = 0.3, R_A_VERT_BIAS = 1.8, R_A_SUST_MULT = 0.15, R_A_MAX_SUST = 3.5;
float R_D_STR = 0.1, R_D_SPR = 0,   R_D_VERT_BIAS = 1.0, R_D_SUST_MULT = 0,    R_D_MAX_SUST = 1;

float FRAME_MUZZLEFLASH_OFF = 0;

float AK47_FIREMODE_IDX_SINGLE = 0;
float AK47_FIREMODE_IDX_AUTO   = 1;
float AK47_FIREMODE_IDX_DEBUG  = 2;

// Forward declarations
void ak47_ready_state(void);
void ak47_fire_single(void);
void ak47_fire_auto(void);
void ak47_fire_debug(void);

//============================================================================
// AK47 - SETUP & SELECTION
//============================================================================
void w_ak47_SetCurrentAmmo() {
    local float num_standard_modes;
    local float supports_debug_mode;

    AM_InitializeWeaponView(AK47_VIEWMODEL, AK47_AMMO_ID, IT_SLOT_HEAVY);
    num_standard_modes = 2;
    supports_debug_mode = TRUE;
    AM_InitWeaponFireModes(num_standard_modes, supports_debug_mode);
    AM_SetRecoilPattern(AK47_RECOIL_PATTERN, AK47_RECOIL_RECOVERY);
    ak47_ready_state();
=======
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
<<<<<<< Updated upstream
    }
>>>>>>> Stashed changes
}

//============================================================================
// AK47 - FIRE MODE SWITCHING
//============================================================================
void W_SwitchModeAk47() {
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, AK47_SOUND_SWITCHMODE, 1, ATTN_NORM);
<<<<<<< Updated upstream
    ak47_ready_state();
}

//============================================================================
// AK47 - UTILITY
//============================================================================
void ak47_ready_state() {
    self.weaponframe = FRAME_MUZZLEFLASH_OFF;
    if (self.effects & EF_MUZZLEFLASH) { // Also clear EF_MUZZLEFLASH if set
        self.effects = self.effects - EF_MUZZLEFLASH;
    }
}

//============================================================================
// AK47 - PRIMARY FIRE (Dispatcher)
//============================================================================
void W_FireAk47() {
    if (self.ammo_nails < 1) {
        sound(self, CHAN_AUTO, "weapons/boltback.wav", 1, ATTN_NORM);
        W_BestWeapon();
        return;
    }

    if (self.attack_finished > time) {
        if (self.current_weapon_fire_mode == AK47_FIREMODE_IDX_SINGLE && !self.weapon_fire_released) {
            // Allow fall-through for semi-auto "button held" state.
            // ak47_fire_single will handle the flash cleanup if AM_CanFireSemiAuto is false.
        } else {
            return;
        }
    }
    // player_shot1() in W_Attack has set self.weaponframe = 1 and added EF_MUZZLEFLASH

    if (self.current_weapon_fire_mode == AK47_FIREMODE_IDX_DEBUG && cvar("developer") > 0) {
        ak47_fire_debug();
    } else if (self.current_weapon_fire_mode == AK47_FIREMODE_IDX_SINGLE) {
        ak47_fire_single();
    } else if (self.current_weapon_fire_mode == AK47_FIREMODE_IDX_AUTO) {
        ak47_fire_auto();
    }
}

//============================================================================
// AK47 - FIRE ACTIONS
//============================================================================
void ak47_fire_single() {
    if (!AM_CanFireSemiAuto()) {
        // Button held after a successful shot, or not a fresh press for semi-auto.
        // player_shot1() was just called by W_Attack, setting weaponframe ON and adding EF_MUZZLEFLASH. Clean them up.
        if (self.weaponframe != FRAME_MUZZLEFLASH_OFF) {
            self.weaponframe = FRAME_MUZZLEFLASH_OFF;
        }
        if (self.effects & EF_MUZZLEFLASH) { // Mirror UMP45's cleanup of self.effects
            self.effects = self.effects - EF_MUZZLEFLASH;
        }
        if (time >= self.attack_finished) {
            self.attack_finished = time + 0.05;
        }
        return;
    }

    // Successful semi-auto shot. Flash (weaponframe & effects) was set ON by player_shot1().
    sound(self, CHAN_WEAPON, AK47_SOUND_FIRE, 1, ATTN_NORM);
    W_am_fire_bullet(AK47_CALIBER, AK47_BULLET_TYPE, AK47_ACCURACY_SINGLE, FALSE);
    AM_ConsumeAmmo(AK47_AMMO_ID, 1);
    AM_ApplyRecoil(R_S_STR, R_S_SPR, R_S_VERT_BIAS, R_S_SUST_MULT, R_S_MAX_SUST);
    self.weapon_fire_released = FALSE;

    self.attack_finished = time + AK47_FIRERATE_SINGLE;
    // Flash (weaponframe & EF_MUZZLEFLASH) off is assumed to be handled by player animation sequence ending
    // or by AM_WeaponFrame_HandleFireRelease -> ak47_ready_state() when button0 is confirmed released.
}

void ak47_fire_auto() {
    // Flash (weaponframe & effects) was set ON by player_shot1().
    sound(self, CHAN_WEAPON, AK47_SOUND_FIRE, 1, ATTN_NORM);
    W_am_fire_bullet(AK47_CALIBER, AK47_BULLET_TYPE, AK47_ACCURACY_AUTO, FALSE);
    AM_ConsumeAmmo(AK47_AMMO_ID, 1);
    AM_ApplyRecoil(R_A_STR, R_A_SPR, R_A_VERT_BIAS, R_A_SUST_MULT, R_A_MAX_SUST);
    self.weapon_fire_released = FALSE;

    self.attack_finished = time + AK47_FIRERATE_AUTO;
    // W_WeaponFrame will call W_Attack again for next shot if button0 is held.
    // Loop termination (button release / no ammo) should ensure flash is ultimately off.
    // When button0 is released, AM_WeaponFrame_HandleFireRelease calls AM_ResetSustainedRecoil.
    // The player animation should return to idle, clearing weaponframe.
    // If not, ak47_ready_state() (which clears both) might need to be called by AM_WeaponFrame_HandleFireRelease.
}

void ak47_fire_debug() {
    // Flash (weaponframe & effects) was set ON by player_shot1().
    sound(self, CHAN_WEAPON, AK47_SOUND_FIRE, 1, ATTN_NORM);
    W_am_fire_bullet(AK47_CALIBER, AK47_BULLET_TYPE, AK47_ACCURACY_DEBUG, FALSE);
    AM_ConsumeAmmo(AK47_AMMO_ID, 1);
    AM_ApplyRecoil(R_D_STR, R_D_SPR, R_D_VERT_BIAS, R_D_SUST_MULT, R_D_MAX_SUST);
    self.weapon_fire_released = FALSE;

    self.attack_finished = time + AK47_FIRERATE_DEBUG;
=======
=======
    }
}

void W_SwitchModeAk47() {
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, AK47_SOUND_SWITCHMODE, 1, ATTN_NORM);
>>>>>>> Stashed changes
    
    if(self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) { sprint(self, "AK-47: Single Shot\n"); }
    else if(self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) { sprint(self, "AK-47: Full-Auto\n"); }
    else if(self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) { sprint(self, "AK-47: Debug Full-Auto\n"); }
    
    AM_ResetSustainedRecoil(); 
    self.attack_finished = time;
    self.weapon_fire_released = TRUE;
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
}