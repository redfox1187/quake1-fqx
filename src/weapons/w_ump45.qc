//============================================================================
// Weapon: UMP45 SMG (w_ump45.qc) - Property Definitions
// ##Quedra: Data sheet for the modular ballistic weapon system. Version 2.9
//============================================================================

// --- Core Identity ---
string UMP45_VIEWMODEL          = "progs/v_ump45.mdl";
float  UMP45_WEAPON_SLOT_IT_FLAG= IT_SLOT_PRIMARY; // ##Quedra: Or IT_SLOT_SECONDARY based on your progs.src folder for it

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
float  UMP45_NUM_STANDARD_MODES = 3;   // Mode 0: Single, Mode 1: Burst, Mode 2: Auto
                                        // Debug Mode will be index 3 if cvar("developer") > 0
float  UMP45_BURST_SHOT_COUNT   = 3;
float  UMP45_BURST_POST_DELAY   = 0.01; 
float  UMP45_BURST_INNER_RPM    = 600; // RPM for shots *within* a burst

// --- Handling, Ergonomics, Weight ---
float  UMP45_BASE_ACCURACY_SINGLE = 1.5; 
float  UMP45_BASE_ACCURACY_BURST  = 1.2;
float  UMP45_BASE_ACCURACY_AUTO   = 0.9; 
float  UMP45_ERGONOMICS         = 8.0;
float  UMP45_HANDLING           = 8.5;
float  UMP45_WEIGHT_LBS         = 5.0;
float  UMP45_WEIGHT_CLASS       = WEIGHT_CLASS_MEDIUM;

// --- Recoil Parameters ---
// Mode 0: Semi-Auto (FIRE_MODE_PRIMARY)
float UMP45_RECOIL_S_STR        = 1.2; 
float UMP45_RECOIL_S_SPR        = 0.35;
float UMP45_RECOIL_S_VERT_BIAS  = 1.8;
float UMP45_RECOIL_S_SUST_MULT  = 0.0; 
float UMP45_RECOIL_S_MAX_SUST   = 1.0;
// Mode 1: Burst-Fire (FIRE_MODE_SECONDARY)
float UMP45_RECOIL_B_STR        = 1.3; 
float UMP45_RECOIL_B_SPR        = 0.4;
float UMP45_RECOIL_B_VERT_BIAS  = 2.0;
float UMP45_RECOIL_B_SUST_MULT  = 0.1; 
float UMP45_RECOIL_B_MAX_SUST   = 1.4;
// Mode 2: Auto-Fire (FIRE_MODE_TERTIARY)
float UMP45_RECOIL_A_STR        = 1.1; 
float UMP45_RECOIL_A_SPR        = 0.5;
float UMP45_RECOIL_A_VERT_BIAS  = 1.6;
float UMP45_RECOIL_A_SUST_MULT  = 0.12; 
float UMP45_RECOIL_A_MAX_SUST   = 2.5;  
// Debug Mode (index = UMP45_NUM_STANDARD_MODES)
float UMP45_RECOIL_D_STR        = 0.1; 
float UMP45_RECOIL_D_SPR        = 0;
float UMP45_RECOIL_D_VERT_BIAS  = 1.0;
float UMP45_RECOIL_D_SUST_MULT  = 0;   
float UMP45_RECOIL_D_MAX_SUST   = 1;

vector UMP45_RECOIL_PATTERN     = '0.05 0.1 0'; 
float  UMP45_RECOIL_RECOVERY_RATE = 2.8;       

// --- Sound Definitions ---
string UMP45_SOUND_FIRE_PRIMARY   = "weapons/ump45-1.wav"; // For Single, Auto, and first shot of Burst
string UMP45_SOUND_FIRE_BURST     = "weapons/ump45-1.wav"; // For subsequent shots in burst
string UMP45_SOUND_SWITCHMODE   = "weapons/weaponclick.wav";
string UMP45_SOUND_EMPTY        = "weapons/boltback.wav";
// ... (reload sounds)

//============================================================================
// ##Quedra: Weapon System Functions
//============================================================================

void W_FireUMP45() 
{
    self.weapon_ammo_resource_id = UMP45_AMMO_RESOURCE_ID;
    self.weapon_ammo_cost_per_shot = UMP45_AMMO_COST_PER_SHOT;

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
        sound(self, CHAN_AUTO, UMP45_SOUND_EMPTY, 1, ATTN_NORM);
        self.attack_finished = time + 0.5;
        self.weapon_fire_released = TRUE;
        return;
    }

    self.weapon_fire_released = FALSE;

    if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) 
    {
        AM_ExecuteStandardFire_Parameterized(UMP45_CALIBER, UMP45_BULLET_TYPE, UMP45_BASE_ACCURACY_SINGLE, FALSE,
                                           UMP45_RECOIL_S_STR, UMP45_RECOIL_S_SPR, UMP45_RECOIL_S_VERT_BIAS, UMP45_RECOIL_S_SUST_MULT, UMP45_RECOIL_S_MAX_SUST,
                                           UMP45_SOUND_FIRE_PRIMARY, UMP45_CYCLIC_RPM);
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) 
    {
        AM_StartBurstFire_Parameterized(UMP45_BURST_SHOT_COUNT, UMP45_BURST_INNER_RPM, UMP45_BURST_POST_DELAY,
                                        UMP45_CALIBER, UMP45_BULLET_TYPE, UMP45_BASE_ACCURACY_BURST,
                                        UMP45_RECOIL_B_STR, UMP45_RECOIL_B_SPR, UMP45_RECOIL_B_VERT_BIAS,
                                        UMP45_RECOIL_B_SUST_MULT, UMP45_RECOIL_B_MAX_SUST,
                                        UMP45_SOUND_FIRE_PRIMARY, UMP45_SOUND_FIRE_BURST, UMP45_SOUND_EMPTY);
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_TERTIARY) // Full-Auto
    {
        AM_ExecuteStandardFire_Parameterized(UMP45_CALIBER, UMP45_BULLET_TYPE, UMP45_BASE_ACCURACY_AUTO, FALSE,
                                           UMP45_RECOIL_A_STR, UMP45_RECOIL_A_SPR, UMP45_RECOIL_A_VERT_BIAS, UMP45_RECOIL_A_SUST_MULT, UMP45_RECOIL_A_MAX_SUST,
                                           UMP45_SOUND_FIRE_PRIMARY, UMP45_CYCLIC_RPM);
    }
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) 
    {
        AM_ExecuteStandardFire_Parameterized(UMP45_CALIBER, UMP45_BULLET_TYPE, 100, TRUE, 
                                           UMP45_RECOIL_D_STR, UMP45_RECOIL_D_SPR, UMP45_RECOIL_D_VERT_BIAS, UMP45_RECOIL_D_SUST_MULT, UMP45_RECOIL_D_MAX_SUST,
                                           UMP45_SOUND_FIRE_PRIMARY, UMP45_CYCLIC_RPM);
    }
    else
    {
        self.attack_finished = time + 0.1; 
        return;
    }
}

void w_ump45_SetCurrentAmmo() {
    AM_InitializeWeaponView(UMP45_VIEWMODEL, UMP45_AMMO_RESOURCE_ID, UMP45_WEAPON_SLOT_IT_FLAG);
    AM_InitWeaponFireModes(UMP45_NUM_STANDARD_MODES); 
    AM_SetRecoilPattern(UMP45_RECOIL_PATTERN, UMP45_RECOIL_RECOVERY_RATE);
    self.burst_active = FALSE;
    self.attack_finished = time;
}

void W_SwitchModeUMP45() {
    AM_CycleFireMode(); 
    sound(self, CHAN_VOICE, UMP45_SOUND_SWITCHMODE, 1, ATTN_NORM);
    
    if(self.current_weapon_fire_mode == FIRE_MODE_PRIMARY) { sprint(self, "UMP45: Single Shot\n"); }
    else if(self.current_weapon_fire_mode == FIRE_MODE_SECONDARY) { sprint(self, "UMP45: 3-Round Burst\n"); }
    else if(self.current_weapon_fire_mode == FIRE_MODE_TERTIARY) { sprint(self, "UMP45: Full-Auto\n"); }
    else if(self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0) { sprint(self, "UMP45: Debug Full-Auto\n"); }
    
    self.burst_active = FALSE;
    if (self.think == AM_Burst_Think) { self.think = SUB_Null; self.nextthink = -1; }
    AM_ResetSustainedRecoil();
    self.attack_finished = time;
    self.weapon_fire_released = TRUE;
}