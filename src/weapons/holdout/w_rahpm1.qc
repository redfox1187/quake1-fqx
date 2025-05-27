//============================================================================
// Weapon: Republic Army Holdout Pistol M1 (w_rahpm1.qc) - Property Definitions
// ##FQXCUSTOM - ##Quedra: Data sheet using am_ebolt.qc. Version 3.4
// ##Quedra: Constants tuned. Auto-switch. Redundant player_shot1() removed.
//============================================================================

// --- Core Identity ---
string RAHPM1_VIEWMODEL           = "progs/v_rahpm1.mdl";
float  RAHPM1_WEAPON_SLOT_IT_FLAG = IT_SLOT_HOLDOUT;

// --- Ammunition & Magazine ---
// Primary "Varmint" Ebolt Mode is NO COST
float  RAHPM1_AMMO_RESOURCE_ID_SECONDARY  = AMMO_ID_CELLS;
float  RAHPM1_AMMO_COST_PER_SHOT_SECONDARY= 1; // Original cost was 1 cell

// --- Ebolt Projectile Types ---
float  RAHPM1_EBOLT_TYPE_PRIMARY          = EBOLT_VARMINT; // Damage: 9 (crit: 18) from am_ebolt.qc
float  RAHPM1_EBOLT_TYPE_SECONDARY        = EBOLT_SDR;     // Damage: 28 (fixed) from am_ebolt.qc

// --- Firing Characteristics ---
float  RAHPM1_COOLDOWN_PRIMARY            = 0.2;  // Original primary cooldown
float  RAHPM1_COOLDOWN_SECONDARY          = 0.6;  // Original secondary cooldown

float  RAHPM1_NUM_STANDARD_MODES  = 2;    // Mode 0: Varmint Ebolt (Semi-Auto, No Cost)
                                        // Mode 1: SDR Ebolt (Semi-Auto, Cell Cost)
                                        // Debug Mode will be index 2 if cvar("developer") > 0

// --- Handling, Ergonomics, Weight ---
float  RAHPM1_BASE_ACCURACY_PRIMARY   = 0.98; // Very accurate, as lasers were
float  RAHPM1_BASE_ACCURACY_SECONDARY = 1.0;  // Perfectly accurate
float  RAHPM1_BASE_ACCURACY_DEBUG     = 1.0;  // Uses Varmint type, perfect accuracy

float  RAHPM1_ERGONOMICS              = 8.5;  // Example value
float  RAHPM1_HANDLING                = 9.0;  // Example value
float  RAHPM1_WEIGHT_LBS              = 1.5;  // Example value
float  RAHPM1_WEIGHT_CLASS            = WEIGHT_CLASS_LIGHT; // Example value

// --- Recoil Parameters ---
// ##Quedra: Tuned to approximate original punchangles with AM_ApplyRecoil.
// Mode 0: Primary "Varmint" Ebolt (Original punchangle_x = -1)
float RAHPM1_RECOIL_P_STR         = 0.4;
float RAHPM1_RECOIL_P_SPR         = 0.05;
float RAHPM1_RECOIL_P_VERT_BIAS   = 2.5;
float RAHPM1_RECOIL_P_SUST_MULT   = 0.0;
float RAHPM1_RECOIL_P_MAX_SUST    = 1.0;

// Mode 1: Secondary "SDR" Ebolt (Original punchangle_x = -2)
float RAHPM1_RECOIL_S_STR         = 0.8;
float RAHPM1_RECOIL_S_SPR         = 0.05;
float RAHPM1_RECOIL_S_VERT_BIAS   = 2.5;
float RAHPM1_RECOIL_S_SUST_MULT   = 0.0;
float RAHPM1_RECOIL_S_MAX_SUST    = 1.0;

// Debug Mode (index = RAHPM1_NUM_STANDARD_MODES) - minimal recoil
float RAHPM1_RECOIL_D_STR         = 0.1;
float RAHPM1_RECOIL_D_SPR         = 0.0;
float RAHPM1_RECOIL_D_VERT_BIAS   = 1.0;
float RAHPM1_RECOIL_D_SUST_MULT   = 0.0;
float RAHPM1_RECOIL_D_MAX_SUST    = 1.0;

vector RAHPM1_RECOIL_PATTERN      = '0 0 0'; // Original had no defined pattern beyond vertical kick
float  RAHPM1_RECOIL_RECOVERY_RATE = 3.2;   // Reasonably fast recovery

// --- Sound Definitions ---
string RAHPM1_SOUND_FIRE_PRIMARY_1    = "enforcer/enfire.wav";
string RAHPM1_SOUND_FIRE_PRIMARY_2    = "weapons/ric2.wav"; // Alternate primary sound
string RAHPM1_SOUND_FIRE_SECONDARY_MAIN = "enforcer/enfire.wav"; // Base for SDR ebolt
string RAHPM1_SOUND_FIRE_SECONDARY_SUPP = "weapons/rocket1i.wav"; // Supplementary sound for SDR
string RAHPM1_SOUND_SWITCHMODE        = "weapons/change.wav";
string RAHPM1_SOUND_EMPTY_SECONDARY   = "weapons/scock.wav"; // For secondary mode out of cells

// ##Quedra: Player specific field for alternating sound - declared in defs_2.qc
// .float rahp_primary_sound_toggle;

//============================================================================
// ##Quedra: Weapon System Functions
//============================================================================

void W_FireRahp()
{
    local string current_fire_sound;

    // ##Quedra: Handle Secondary "SDR" Ebolt mode first due to potential auto-switch
    if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY)
    {
        if (!AM_CanFireSemiAuto()) { return; }

        if (AM_GetAmmoCount(RAHPM1_AMMO_RESOURCE_ID_SECONDARY) < RAHPM1_AMMO_COST_PER_SHOT_SECONDARY)
        {
            sound(self, CHAN_WEAPON, RAHPM1_SOUND_EMPTY_SECONDARY, 1, ATTN_NORM);
            sprint(self, "RAHP-M1: No cells for SDR Ebolt. Switching to Varmint mode.\n");
            
            self.current_weapon_fire_mode = FIRE_MODE_PRIMARY;
            if (self.weapon == IT_SLOT_HOLDOUT) { self.firemode_slot_holdout = FIRE_MODE_PRIMARY; } // Persist change
            self.currentammo = 0; 
            self.items = self.items - (self.items & IT_CELLS); 
            
            self.attack_finished = time + 0.3; 
            self.weapon_fire_released = TRUE;
            return;
        }
        
        self.weapon_fire_released = FALSE;
        AM_ConsumeAmmo(RAHPM1_AMMO_RESOURCE_ID_SECONDARY, RAHPM1_AMMO_COST_PER_SHOT_SECONDARY);
        
        current_fire_sound = RAHPM1_SOUND_FIRE_SECONDARY_MAIN;
        sound(self, CHAN_ITEM, RAHPM1_SOUND_FIRE_SECONDARY_SUPP, 1, ATTN_NORM); // Play supplementary sound

        W_am_fire_ebolt(RAHPM1_EBOLT_TYPE_SECONDARY, current_fire_sound, RAHPM1_BASE_ACCURACY_SECONDARY,
                        TRUE, RAHPM1_RECOIL_S_STR, RAHPM1_RECOIL_S_SPR, RAHPM1_RECOIL_S_VERT_BIAS,
                        RAHPM1_RECOIL_S_SUST_MULT, RAHPM1_RECOIL_S_MAX_SUST);
        
        self.attack_finished = time + RAHPM1_COOLDOWN_SECONDARY;
    }
    // ##Quedra: Primary "Varmint" Ebolt mode (No Cost)
    else if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY)
    {
        if (!AM_CanFireSemiAuto()) { return; } 

        self.weapon_fire_released = FALSE;

        // Alternating primary fire sound
        if (self.rahp_primary_sound_toggle)
            current_fire_sound = RAHPM1_SOUND_FIRE_PRIMARY_1;
        else
            current_fire_sound = RAHPM1_SOUND_FIRE_PRIMARY_2;
        self.rahp_primary_sound_toggle = !self.rahp_primary_sound_toggle;

        W_am_fire_ebolt(RAHPM1_EBOLT_TYPE_PRIMARY, current_fire_sound, RAHPM1_BASE_ACCURACY_PRIMARY,
                        TRUE, RAHPM1_RECOIL_P_STR, RAHPM1_RECOIL_P_SPR, RAHPM1_RECOIL_P_VERT_BIAS,
                        RAHPM1_RECOIL_P_SUST_MULT, RAHPM1_RECOIL_P_MAX_SUST);
        
        self.attack_finished = time + RAHPM1_COOLDOWN_PRIMARY;
    }
    // ##Quedra: Debug "Varmint" Ebolt mode
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0)
    {
        // No AM_CanFireSemiAuto check for debug, allowing spam/auto if button held

        if (self.rahp_primary_sound_toggle) { current_fire_sound = RAHPM1_SOUND_FIRE_PRIMARY_1; }
        else { current_fire_sound = RAHPM1_SOUND_FIRE_PRIMARY_2; }
        self.rahp_primary_sound_toggle = !self.rahp_primary_sound_toggle;

        W_am_fire_ebolt(RAHPM1_EBOLT_TYPE_PRIMARY, current_fire_sound, RAHPM1_BASE_ACCURACY_DEBUG,
                        TRUE, RAHPM1_RECOIL_D_STR, RAHPM1_RECOIL_D_SPR, RAHPM1_RECOIL_D_VERT_BIAS,
                        RAHPM1_RECOIL_D_SUST_MULT, RAHPM1_RECOIL_D_MAX_SUST);
        
        self.attack_finished = time + RAHPM1_COOLDOWN_PRIMARY * 0.5; // Faster for debug
    }
    else // Fallback for unknown mode
    {
        self.attack_finished = time + 0.1; 
        return;
    }
    // ##Quedra: Generic animation call handled by W_Attack() in weapons.qc for IT_SLOT_HOLDOUT
}

void w_rahpm1_SetCurrentAmmo()
{
    AM_InitWeaponFireModes(RAHPM1_NUM_STANDARD_MODES); // Call this first to load persisted fire mode

    // ##Quedra: Update viewmodel and ammo display based on the (potentially newly initialized) fire mode.
    if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY)
    {
        // Show Cell count for secondary mode
        AM_InitializeWeaponView(RAHPM1_VIEWMODEL, RAHPM1_AMMO_RESOURCE_ID_SECONDARY, RAHPM1_WEAPON_SLOT_IT_FLAG);
    }
    else // Primary (no-cost) or Debug mode
    {
        // For Primary or Debug, show 0 ammo and ensure IT_CELLS isn't improperly shown by AM_InitializeWeaponView
        // if it were called with AMMO_ID_CELLS. Instead, we manage HUD explicitly for no-cost.
        self.weaponmodel = RAHPM1_VIEWMODEL;
        self.currentammo = 0; 
        self.items = self.items | RAHPM1_WEAPON_SLOT_IT_FLAG; // Ensure player "has" the weapon
        // Clear all ammo type item flags, then add back if needed for the specific mode
        self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
        // No ammo item flag needed for primary no-cost mode.
    }
    
    AM_SetRecoilPattern(RAHPM1_RECOIL_PATTERN, RAHPM1_RECOIL_RECOVERY_RATE);
    self.burst_active = FALSE; // Ensure burst is not active if switching to this weapon
    self.attack_finished = time;
    self.rahp_primary_sound_toggle = FALSE; // Reset sound toggle on weapon select
}

void W_SwitchModeRahp()
{
    AM_CycleFireMode(); // This updates self.current_weapon_fire_mode and persists it
    sound(self, CHAN_VOICE, RAHPM1_SOUND_SWITCHMODE, 1, ATTN_NORM);

    // ##Quedra: Update ammo display and sprint message based on newly selected mode
    if (self.current_weapon_fire_mode == FIRE_MODE_SECONDARY)
    {
        self.currentammo = AM_GetAmmoCount(RAHPM1_AMMO_RESOURCE_ID_SECONDARY);
        self.items = self.items | IT_CELLS; // Ensure HUD shows cell icon
        sprint(self, "RAHP-M1: SDR Ebolt Mode (1 Cell)\n");
    }
    else if (self.current_weapon_fire_mode == FIRE_MODE_PRIMARY)
    {
        self.currentammo = 0; 
        self.items = self.items - (self.items & IT_CELLS); // Clear cell icon if switching to no-cost mode
        sprint(self, "RAHP-M1: Varmint Ebolt Mode\n");
    }
    else if (self.current_weapon_fire_mode == self.weapon_num_standard_modes && cvar("developer") > 0)
    {
        self.currentammo = 0; 
        self.items = self.items - (self.items & IT_CELLS);
        sprint(self, "RAHP-M1: Debug Varmint Ebolt\n");
    }
    
    self.attack_finished = time; // Allow immediate fire after mode switch
    self.weapon_fire_released = TRUE; 
    self.rahp_primary_sound_toggle = FALSE; // Reset sound toggle on mode switch
}
//============================================================================
// w_rahpm1.qc - End of File
//============================================================================