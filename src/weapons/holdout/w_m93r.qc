//============================================================================
// Weapon: Beretta M93R Machine Pistol (w_m93r.qc)
// Refined by Quedra, Weaver of Eldritch Code.
//============================================================================

// --- Weapon Behavior Constants ---
float M93R_RPM_CYCLIC_SEMI       = 400;  // Effective tap-fire RPM for semi-auto
float M93R_RPM_CYCLIC_BURST      = 1100; // True cyclic RPM during a burst
float M93R_FIRERATE_SEMI         = 60 / M93R_RPM_CYCLIC_SEMI; // Max interval between semi shots if tapped perfectly
float M93R_FIRERATE_BURST_SHOT   = 60 / M93R_RPM_CYCLIC_BURST; // Time between shots *within* a burst
float M93R_BURST_DELAY           = 0.35; // Delay after a full burst before another action

string M93R_SOUND_FIRE_1        = "weapons/9mm_Pistol-1.wav";
string M93R_SOUND_FIRE_2        = "weapons/9mm_Pistol-2.wav";
string M93R_SOUND_SWITCHMODE    = "weapons/9mm_Pistol_Switch-01.wav";
string M93R_SOUND_EMPTY         = "weapons/boltback.wav";

string M93R_VIEWMODEL           = "progs/v_rahpm1.mdl";

float  M93R_AMMO_ID             = AMMO_ID_SHELLS;
float  M93R_CALIBER             = CAL_9MM;
float  M93R_BULLET_TYPE         = BLT_FMJ;

// Accuracy (Higher is more accurate)
float  M93R_ACCURACY_SEMI       = 1.8;  // Good for a pistol in semi-auto
float  M93R_ACCURACY_BURST      = 1.1;  // Less accurate during burst
float  M93R_ACCURACY_DEBUG      = 9999;

// Recoil Parameters: Strength, Spread, Vertical Bias, Sustained Multiplier, Max Sustained Multiplier
// Semi-Auto Recoil
float M93R_R_S_STR          = 0.8;  // Base strength of semi-auto shot
float M93R_R_S_SPR          = 0.3;  // Randomness factor
float M93R_R_S_VERT_BIAS    = 2.5;  // How much it tends to kick upwards
float M93R_R_S_SUST_MULT    = 0.0;  // No sustained increase for single shots
float M93R_R_S_MAX_SUST     = 1.0;  // Cap for sustained (not used if mult is 0)
// Burst-Fire Recoil (per shot within burst)
float M93R_R_B_STR          = 1.0;  // Sharper kick per shot in burst
float M93R_R_B_SPR          = 0.35; // Slightly more spread/randomness
float M93R_R_B_VERT_BIAS    = 2.8;  // Stronger upward tendency in burst
float M93R_R_B_SUST_MULT    = 0.2;  // Makes 2nd/3rd shots climb more
float M93R_R_B_MAX_SUST     = 2.5;  // Caps the climb effect
// Debug Recoil
float M93R_R_D_STR          = 0.1; float M93R_R_D_SPR = 0; float M93R_R_D_VERT_BIAS = 1.0; float M93R_R_D_SUST_MULT = 0; float M93R_R_D_MAX_SUST = 1;

float FRAME_MUZZLEFLASH_OFF      = 0;

// Fire Mode Indices for M93R
float M93R_FIREMODE_IDX_SEMI   = 0; // FIRE_MODE_PRIMARY
float M93R_FIREMODE_IDX_BURST  = 1; // FIRE_MODE_SECONDARY
float M93R_FIREMODE_IDX_DEBUG  = 2; // Corresponds to weapon_num_standard_modes if developer > 0

// Player entity fields for M93R burst state (ensure these are in defs.qc)
// .float m93r_burst_count;
// .float m93r_burst_active;
// .float m93r_next_burst_time;

// Forward declarations
void m93r_ready_state(void);
void w_m93r_fire_semi(void);
void w_m93r_fire_burst_start(void);
void w_m93r_fire_burst_shot(void);
void w_m93r_fire_burst_think(void);
void w_m93r_fire_debug(void);
void W_FireM93R(void);               // Main dispatcher called by W_Attack
void W_SwitchModeM93R(void);         // Called by ToggleFireMode impulse
void w_m93r_PrintCurrentMode(void);
void w_m93r_play_fire_sound(void);

void w_m93r_play_fire_sound() {
    if (random() < 0.5) {
        sound(self, CHAN_WEAPON, M93R_SOUND_FIRE_1, 1, ATTN_NORM);
    } else {
        sound(self, CHAN_WEAPON, M93R_SOUND_FIRE_2, 1, ATTN_NORM);
    }
}

//============================================================================
// M93R - SETUP & SELECTION
//============================================================================
void w_m93r_SetCurrentAmmo() {
    local float num_standard_modes;
    local float supports_debug_mode;

    AM_InitializeWeaponView(M93R_VIEWMODEL, M93R_AMMO_ID, IT_SLOT_HOLDOUT);

    num_standard_modes = 2; // Semi, Burst
    supports_debug_mode = TRUE;
    AM_InitWeaponFireModes(num_standard_modes, supports_debug_mode);

    AM_SetRecoilPattern('-0.1 0.15 0', 2.5); // Base pattern: slight up, moderate right. Recovery: 2.5

    self.m93r_burst_count = 0;
    self.m93r_burst_active = 0;

    w_m93r_PrintCurrentMode();
    m93r_ready_state();
}

//============================================================================
// M93R - PRINT CURRENT MODE (Debug/Info)
//============================================================================
void w_m93r_PrintCurrentMode() {
    if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_SEMI) {
        sprint(self, PRINT_LOW, "M93R: Semi-Auto\n");
    } else if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_BURST) {
        sprint(self, PRINT_LOW, "M93R: 3-Round Burst\n");
    } else if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_DEBUG && cvar("developer") > 0) {
        sprint(self, PRINT_LOW, "M93R: DEBUG (Max Accuracy)\n");
    }
}

//============================================================================
// M93R - FIRE MODE SWITCHING
//============================================================================
void W_SwitchModeM93R() {
    AM_CycleFireMode();
    sound(self, CHAN_VOICE, M93R_SOUND_SWITCHMODE, 1, ATTN_NORM);
    w_m93r_PrintCurrentMode();

    self.m93r_burst_count = 0;
    self.m93r_burst_active = 0;
    m93r_ready_state();
}

//============================================================================
// M93R - UTILITY (Ready State / Clear Flash)
//============================================================================
void m93r_ready_state() {
    self.weaponframe = FRAME_MUZZLEFLASH_OFF;
    if (self.effects & EF_MUZZLEFLASH) {
        self.effects = self.effects - EF_MUZZLEFLASH;
    }
}

//============================================================================
// M93R - PRIMARY FIRE (Dispatcher, called by W_Attack)
//============================================================================
void W_FireM93R() {
    if (self.ammo_shells < 1) {
        sound(self, CHAN_AUTO, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        W_BestWeapon();
        return;
    }

    if (self.attack_finished > time) {
        if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_SEMI && !self.weapon_fire_released) {
            // Let w_m93r_fire_semi handle flash cleanup if button is held
        } else {
            return; 
        }
    }
    
    // player_shot1() in W_Attack typically sets self.weaponframe = 1 and adds EF_MUZZLEFLASH.

    if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_DEBUG && cvar("developer") > 0) {
        w_m93r_fire_debug();
    } else if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_SEMI) {
        w_m93r_fire_semi();
    } else if (self.current_weapon_fire_mode == M93R_FIREMODE_IDX_BURST) {
        if (!self.m93r_burst_active) { 
            w_m93r_fire_burst_start();
        }
    }
    
    if (!self.m93r_burst_active && ((time - self.ump_last_fire_time) > 0.5)) 
    {
        if (self.current_weapon_fire_mode != M93R_FIREMODE_IDX_SEMI || self.weapon_fire_released)
        {
            AM_ResetSustainedRecoil();
        }
    }
}

//============================================================================
// M93R - SEMI-AUTO FIRE ACTION
//============================================================================
void w_m93r_fire_semi() {
    local float accuracy;

    if (!AM_CanFireSemiAuto()) {
        if (self.weaponframe != FRAME_MUZZLEFLASH_OFF) { self.weaponframe = FRAME_MUZZLEFLASH_OFF; }
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        if (time >= self.attack_finished) { self.attack_finished = time + 0.05; }
        return;
    }

    if (self.ammo_shells < 1) {
        sound(self, CHAN_WEAPON, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        self.weapon_fire_released = TRUE;
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        if (self.weaponframe != 0) { self.weaponframe = 0; }
        return;
    }

    AM_ConsumeAmmo(M93R_AMMO_ID, 1);
    w_m93r_play_fire_sound();

    accuracy = M93R_ACCURACY_SEMI;
    if (vlen(self.velocity) > 20) { accuracy = accuracy * 0.75; }

    W_am_fire_bullet(M93R_CALIBER, M93R_BULLET_TYPE, accuracy, FALSE);
    AM_ApplyRecoil(M93R_R_S_STR, M93R_R_S_SPR, M93R_R_S_VERT_BIAS, M93R_R_S_SUST_MULT, M93R_R_S_MAX_SUST);
    
    self.weapon_fire_released = FALSE; 
    self.attack_finished = time + M93R_FIRERATE_SEMI;
    self.ump_last_fire_time = time; 
}

//============================================================================
// M93R - BURST FIRE ACTIONS
//============================================================================
void w_m93r_fire_burst_start() {
    if (self.m93r_burst_active) { return; }
    if (!AM_CanFireSemiAuto()) { 
        if (self.weaponframe != FRAME_MUZZLEFLASH_OFF) { self.weaponframe = FRAME_MUZZLEFLASH_OFF; }
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        if (time >= self.attack_finished) { self.attack_finished = time + 0.05; }
        return;
    }
    if (self.ammo_shells < 1) { // Technically needs < 3 for full burst, but first shot needs >=1
        sound(self, CHAN_WEAPON, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        self.weapon_fire_released = TRUE;
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        if (self.weaponframe != 0) { self.weaponframe = 0; }
        return;
    }

    self.m93r_burst_active = TRUE;
    self.m93r_burst_count = 0;
    AM_ResetSustainedRecoil(); 

    // First shot is handled by W_Attack -> W_FireM93R -> player_shot1 -> this function.
    // player_shot1 sets the flash.
    w_m93r_fire_burst_shot(); 

    self.m93r_next_burst_time = time + M93R_FIRERATE_BURST_SHOT;
    self.think = w_m93r_fire_burst_think;
    self.nextthink = self.m93r_next_burst_time;

    self.attack_finished = time + (M93R_FIRERATE_BURST_SHOT * 2) + M93R_BURST_DELAY; 
    self.weapon_fire_released = FALSE;
}

void w_m93r_fire_burst_shot() {
    local float accuracy;

    if (self.ammo_shells < 1) {
        self.m93r_burst_active = FALSE; 
        sound(self, CHAN_WEAPON, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        if (self.weaponframe != FRAME_MUZZLEFLASH_OFF) { self.weaponframe = FRAME_MUZZLEFLASH_OFF; }
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        return;
    }

    self.m93r_burst_count = self.m93r_burst_count + 1;
    AM_ConsumeAmmo(M93R_AMMO_ID, 1);
    w_m93r_play_fire_sound(); 

    accuracy = M93R_ACCURACY_BURST;
    accuracy = accuracy * (1 - ((self.m93r_burst_count -1) * 0.1)); // Subsequent burst shots slightly less accurate
    if (vlen(self.velocity) > 20) { accuracy = accuracy * 0.8; }

    W_am_fire_bullet(M93R_CALIBER, M93R_BULLET_TYPE, accuracy, FALSE);
    AM_ApplyRecoil(M93R_R_B_STR, M93R_R_B_SPR, M93R_R_B_VERT_BIAS, M93R_R_B_SUST_MULT, M93R_R_B_MAX_SUST);
    self.ump_last_fire_time = time; 
}

void w_m93r_fire_burst_think() {
    if (self.m93r_burst_active) { 
        self.weaponframe = 1; 
        self.effects = self.effects | EF_MUZZLEFLASH; 
    }

    w_m93r_fire_burst_shot(); 

    if (self.effects & EF_MUZZLEFLASH) { // Attempt to clear flash for this non-player_shot1-initiated shot
        self.effects = self.effects - EF_MUZZLEFLASH;
    }
    // self.weaponframe should be reset by animation or m93r_ready_state when burst ends.

    if (self.m93r_burst_count >= 3 || !self.m93r_burst_active || self.ammo_shells < 1) {
        self.m93r_burst_active = FALSE;
        AM_ResetSustainedRecoil();
        self.think = SUB_Null;
        self.nextthink = -1;
        self.attack_finished = time + M93R_BURST_DELAY; 
        m93r_ready_state(); 
        return;
    }

    if (self.m93r_burst_active) { 
        self.m93r_next_burst_time = time + M93R_FIRERATE_BURST_SHOT;
        self.nextthink = self.m93r_next_burst_time;
    } else { 
        AM_ResetSustainedRecoil();
        self.think = SUB_Null;
        self.nextthink = -1;
        self.attack_finished = time + M93R_BURST_DELAY;
        m93r_ready_state();
    }
}

//============================================================================
// M93R - DEBUG FIRE ACTION
//============================================================================
void w_m93r_fire_debug() {
    if (self.ammo_shells < 1) {
        sound(self, CHAN_WEAPON, M93R_SOUND_EMPTY, 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        self.weapon_fire_released = TRUE;
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; }
        if (self.weaponframe != 0) { self.weaponframe = 0; }
        return;
    }

    AM_ConsumeAmmo(M93R_AMMO_ID, 1);
    w_m93r_play_fire_sound(); 

    W_am_fire_bullet(M93R_CALIBER, M93R_BULLET_TYPE, M93R_ACCURACY_DEBUG, FALSE);
    AM_ApplyRecoil(M93R_R_D_STR, M93R_R_D_SPR, M93R_R_D_VERT_BIAS, M93R_R_D_SUST_MULT, M93R_R_D_MAX_SUST);
    
    self.weapon_fire_released = FALSE; 
    self.attack_finished = time + (60 / 1200); // Very fast for debug
    self.ump_last_fire_time = time;
}