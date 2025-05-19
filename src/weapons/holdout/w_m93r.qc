//============================================================================
// Weapon: Beretta M93R Machine Pistol (w_m93r.qc) - Property Definitions
// ##Quedra: Data sheet for the modular ballistic weapon system. Version 3.0
//============================================================================

// --- Core Identity ---
string M93R_VIEWMODEL           = "progs/v_rahpm1.mdl";
float  M93R_WEAPON_SLOT_IT_FLAG = IT_SLOT_HOLDOUT;

// --- Ammunition & Magazine ---
float  M93R_AMMO_RESOURCE_ID    = AMMO_ID_SHELLS;
float  M93R_AMMO_COST_PER_SHOT  = 1;
float  M93R_MAG_CAPACITY        = 20;
float  M93R_RELOAD_TIME_SEC     = 2.8;
float  M93R_RELOAD_TYPE         = RELOAD_TYPE_MAGAZINE_REPLACE;
float  M93R_RELOAD_COST_TOTAL   = 10;

// --- Ballistics ---
float  M93R_CALIBER             = CAL_9MM;
float  M93R_BULLET_TYPE         = BLT_FMJ;

// --- Firing Characteristics ---
float  M93R_CYCLIC_RPM          = 1100; 
float  M93R_NUM_STANDARD_MODES  = 2;    // Mode 0: Semi-Auto, Mode 1: 3-Round Burst
                                        // Debug Mode will be index 2 if cvar("developer") > 0
float  M93R_BURST_SHOT_COUNT    = 3;
float  M93R_BURST_POST_DELAY    = 0.4;  // Cooldown AFTER the entire burst is complete
float  M93R_BURST_INNER_RPM     = 1100; // RPM for shots *within* a burst (can be same as CYCLIC_RPM or different)


// --- Handling, Ergonomics, Weight ---
float  M93R_BASE_ACCURACY_SEMI  = 1.8;
float  M93R_BASE_ACCURACY_BURST = 1.7; 
float  M93R_ERGONOMICS          = 7.0;
float  M93R_HANDLING            = 7.5;
float  M93R_WEIGHT_LBS          = 2.5;
float  M93R_WEIGHT_CLASS        = WEIGHT_CLASS_LIGHT;

// --- Recoil Parameters ---
// Mode 0: Semi-Auto (FIRE_MODE_PRIMARY)
float M93R_RECOIL_S_STR         = 0.8;
float M93R_RECOIL_S_SPR         = 0.3;
float M93R_RECOIL_S_VERT_BIAS   = 2.5;
float M93R_RECOIL_S_SUST_MULT   = 0.0;
float M93R_RECOIL_S_MAX_SUST    = 1.0;
// Mode 1: Burst-Fire (FIRE_MODE_SECONDARY)
float M93R_RECOIL_B_STR         = 1.0;
float M93R_RECOIL_B_SPR         = 0.35;
float M93R_RECOIL_B_VERT_BIAS   = 2.8;
float M93R_RECOIL_B_SUST_MULT   = 0.1; 
float M93R_RECOIL_B_MAX_SUST    = 1.3;
// Debug Mode (index = M93R_NUM_STANDARD_MODES)
float M93R_RECOIL_D_STR         = 0.1; 
float M93R_RECOIL_D_SPR         = 0;
float M93R_RECOIL_D_VERT_BIAS   = 1.0;
float M93R_RECOIL_D_SUST_MULT   = 0;
float M93R_RECOIL_D_MAX_SUST    = 1;

vector M93R_RECOIL_PATTERN      = '-0.1 0.15 0';
float  M93R_RECOIL_RECOVERY_RATE = 2.5;

// --- Sound Definitions ---
string M93R_SOUND_FIRE_PRIMARY    = "weapons/9mm_Pistol-1.wav"; // For Semi-auto and first shot of burst
string M93R_SOUND_FIRE_BURST      = "weapons/9mm_Pistol-2.wav"; // For subsequent shots in a burst
string M93R_SOUND_SWITCHMODE      = "weapons/9mm_Pistol_Switch-01.wav";
string M93R_SOUND_EMPTY           = "weapons/boltback.wav";
// ... (reload sounds)

//============================================================================
// ##Quedra: Weapon System Functions
//============================================================================

void W_FireM93R()
{
    self.weapon_ammo_resource_id = M93R_AMMO_RESOURCE_ID;
    self.weapon_ammo_cost_per_shot = M93R_AMMO_COST_PER_SHOT;

    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) 
    {
        if (!AM_CanFireSemiAuto()) { return; }
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) 
    {
        if (self.burst_active) { return; } 
        if (!AM_CanFireSemiAuto()) { return; }
    }

    if (AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.weapon_ammo_cost_per_shot)
    {
        sound(self, CHAN_AUTO, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        self.attack_finished = time + 0.5; 
        self.weapon_fire_released = TRUE; 
        return;
    }
    
    self.weapon_fire_released = FALSE;

    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) 
    {
        AM_ExecuteStandardFire_Parameterized(M93R_CALIBER, M93R_BULLET_TYPE, M93R_BASE_ACCURACY_SEMI, FALSE,
                                           M93R_RECOIL_S_STR, M93R_RECOIL_S_SPR, M93R_RECOIL_S_VERT_BIAS, M93R_RECOIL_S_SUST_MULT, M93R_RECOIL_S_MAX_SUST,
                                           M93R_SOUND_FIRE_PRIMARY, M93R_CYCLIC_RPM);
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) 
    {
        AM_StartBurstFire_Parameterized(M93R_BURST_SHOT_COUNT, M93R_BURST_INNER_RPM, M93R_BURST_POST_DELAY,
                                        M93R_CALIBER, M93R_BULLET_TYPE, M93R_BASE_ACCURACY_BURST,
                                        M93R_RECOIL_B_STR, M93R_RECOIL_B_SPR, M93R_RECOIL_B_VERT_BIAS,
                                        M93R_RECOIL_B_SUST_MULT, M93R_RECOIL_B_MAX_SUST,
                                        M93R_SOUND_FIRE_PRIMARY, M93R_SOUND_FIRE_BURST, M93R_SOUND_EMPTY);
    }
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) 
    {
        AM_ExecuteStandardFire_Parameterized(M93R_CALIBER, M93R_BULLET_TYPE, 100, TRUE, // Perfect accuracy, tracer
                                           M93R_RECOIL_D_STR, M93R_RECOIL_D_SPR, M93R_RECOIL_D_VERT_BIAS, M93R_RECOIL_D_SUST_MULT, M93R_RECOIL_D_MAX_SUST,
                                           M93R_SOUND_FIRE_PRIMARY, M93R_CYCLIC_RPM); // Uses main cyclic for debug auto
    }
    else
    {
        self.attack_finished = time + 0.1; 
        return;
    }
}

void w_m93r_SetCurrentAmmo() 
{
    AM_InitializeWeaponView(M93R_VIEWMODEL, M93R_AMMO_RESOURCE_ID, M93R_WEAPON_SLOT_IT_FLAG);
    AM_InitWeaponFireModes(M93R_NUM_STANDARD_MODES); 
    AM_SetRecoilPattern(M93R_RECOIL_PATTERN, M93R_RECOIL_RECOVERY_RATE);
    self.burst_active = FALSE; 
    self.attack_finished = time; 
}

void W_SwitchModeM93R() 
{
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, M93R_SOUND_SWITCHMODE, 1, ATTN_NORM);
    
    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) { sprint(self, "M93R: Semi-Auto\n"); }
    else if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) { sprint(self, "M93R: 3-Round Burst\n"); }
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) { sprint(self, "M93R: Debug Full-Auto\n"); }
    
    self.burst_active = FALSE; 
    if (self.think == AM_Burst_Think) { self.think = SUB_Null; self.nextthink = -1; }
    AM_ResetSustainedRecoil(); 
    self.attack_finished = time; 
    self.weapon_fire_released = TRUE; 
}