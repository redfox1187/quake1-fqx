/*
==============================================================================
DBSG-12 - Double Barrel Shotgun 12 Gauge

Double Barrel Shotgun with Single or Double fire modes.
- Mode 0 (Primary): Single barrel shot
- Mode 1 (Secondary): Double barrel shot
Uses generic fire mode system from am_operations.qc.
==============================================================================
*/

// External functions from am_buckshot.qc
// void(vector passed_fire_origin, float instances, float ammo_type, float ammo_spread_mod) W_am_buckshot;

// External functions from am_recoil.qc
// void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil;
// void(vector pattern, float recovery_rate) AM_SetRecoilPattern;
// void() AM_ResetSustainedRecoil;

// External functions from am_operations.qc
// void(string model_path, float ammo_id_enum, float items_flag) AM_InitializeWeaponView;
// void(float ammo_id, float amount_to_consume) AM_ConsumeAmmo;
// void(float num_standard_modes, float supports_debug_mode) AM_InitWeaponFireModes;
// void() AM_CycleFireMode;
// float() AM_CanFireSemiAuto; // Not used by DBShot as it's not semi-auto by default

// DBShot Specific Fire Mode Interpretation (maps to self.current_weapon_fire_mode indices)
float DBSHOT_FIREMODE_IDX_SINGLE = 0; // Corresponds to FIREMODE_IDX_PRIMARY
float DBSHOT_FIREMODE_IDX_DOUBLE = 1; // Corresponds to FIREMODE_IDX_SECONDARY

// Define constants for recoil characteristics
float DBSHOT_RECOIL_BASE_SINGLE = 2.0;      // Base recoil strength for single barrel
float DBSHOT_RECOIL_BASE_DOUBLE = 4.0;      // Base recoil strength for double barrel
float DBSHOT_RECOIL_VERTICAL_BIAS = 3.0;    // Strong upward kick
float DBSHOT_RECOIL_RECOVERY = 2.0;         // Recovery rate from recoil

// Forward declarations
void() w_dbshot_PrintCurrentMode;
void() W_SwitchModeDBShot;

/*
================
w_dbshot_SetCurrentAmmo
Set up the double barrel shotgun as the current weapon.
Called by W_SetCurrentAmmo in weapons.qc.
================
*/
void() w_dbshot_SetCurrentAmmo =
{
    // Initialize weapon view and base ammo display
	AM_InitializeWeaponView("progs/v_dbshot.mdl", AMMO_ID_SHELLS, IT_SHELLS);
	
    // Initialize fire modes for DBShot: 2 standard modes, no debug mode.
    AM_InitWeaponFireModes(2, FALSE);

	// Set DBShot specific recoil pattern
	AM_SetRecoilPattern('-0.05 0.3 0', DBSHOT_RECOIL_RECOVERY);
	// AM_ResetSustainedRecoil(); // Called by AM_InitWeaponFireModes

    w_dbshot_PrintCurrentMode(); // Print initial mode
};

/*
================
w_dbshot_PrintCurrentMode
Helper to print DBShot specific mode name.
================
*/
void() w_dbshot_PrintCurrentMode =
{
    if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_SINGLE)
        sprint(self, "DBShot: Single Barrel mode\n"); 
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE)
        sprint(self, "DBShot: Double Barrel mode\n"); 
};

/*
================
W_SwitchModeDBShot
Handles DBShot fire mode switching.
================
*/
void() W_SwitchModeDBShot =
{
    AM_CycleFireMode(); // Call the generic cycle function
    w_dbshot_PrintCurrentMode(); // Print DBShot specific message
    // No specific ammo display changes needed here, as W_SetCurrentAmmo handles base shell display.
    // The W_FireDBShot logic will handle if it can actually fire in the selected mode.
};


/*
================
W_FireDBShot
Main firing function for the Double Barrel Shotgun.
Called from W_Attack in weapons.qc.
================
*/
void() W_FireDBShot =
{
	local vector dir;
	local vector muzzle_offset, muzzle_origin;
	local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up;
	// local float last_fire_time; // Not used in this version, AM_ResetSustainedRecoil handles general cases

    // If trying to fire Double Barrel with only 1 shell, auto-switch to Single Barrel mode for this shot.
	if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells == 1)
	{
		sprint(self, "DBShot: Only one shell left, firing single barrel.\n");
        // Temporarily treat as single for this shot, but don't change self.current_weapon_fire_mode permanently here.
        // The player can choose to switch modes properly using the mode switch key.
        // If they fire again with 1 shell in double mode, this logic will repeat.
        // If they had 0 shells, W_HasNoAmmo (in weapons.qc) should have caught it.
	}
    // If trying to fire Double Barrel with 0 shells (should be caught by W_HasNoAmmo, but as a safeguard)
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells < 2)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); // Dry fire
		self.attack_finished = time + 0.5;
        return;
    }
    // If trying to fire Single Barrel with 0 shells
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_SINGLE && self.ammo_shells < 1)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); // Dry fire
		self.attack_finished = time + 0.5;
        return;
    }


	// Set up aim direction
	dir = aim(self, 1000); // Not used by W_am_buckshot, but good to have if direct traceline was used
	
	// Define muzzle position for effects (W_am_buckshot takes origin as parameter)
	muzzle_offset_forward = 16; // Tuned for v_dbshot.mdl
	muzzle_offset_right = 0;    // Centered muzzle flash
	muzzle_offset_up = 20;      // Adjusted height

	makevectors(self.v_angle);
	muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
	muzzle_origin = self.origin + self.view_ofs + muzzle_offset; // Start from eye position + offset

	// Fire based on current mode
	if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_SINGLE || 
       (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells == 1) ) // Single or forced single
	{
		sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	// Single barrel sound
		self.attack_finished = time + 0.7; // Cooldown for single barrel
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 1);
		
        // W_am_buckshot parameters: fire_origin, instances, ammo_type, spread_modifier
		W_am_buckshot(muzzle_origin, 1, AMT_12G000BUCK, 1); 
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_SINGLE, 0.6, DBSHOT_RECOIL_VERTICAL_BIAS, 0.3, 2.0);
		self.punchangle_x = -5; // Visual punch
	}
	else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells >= 2) // Double barrel
	{
		sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	// Double barrel sound
		self.attack_finished = time + 1.4; // Longer cooldown for double barrel
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 2);
		
		W_am_buckshot(muzzle_origin, 2, AMT_12G000BUCK, 1.1); // Fire 2 instances, slightly more spread
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_DOUBLE, 0.9, DBSHOT_RECOIL_VERTICAL_BIAS, 0.4, 4.0);
		self.punchangle_x = -10; // Stronger visual punch
	}
	
    // Since DBShot isn't semi-auto, weapon_fire_released doesn't need to be set to FALSE here.
    // The generic W_WeaponFrame will set it to TRUE when button0 is released.

	// Reset sustained recoil if player stops firing for a bit
    // This is a more general check, might be better handled in W_WeaponFrame or a generic recoil reset timer.
	// if (time - self.ump_last_fire_time > 1.0) // Using ump_last_fire_time is UMP-specific
    //    AM_ResetSustainedRecoil(); // This is now more generically handled in am_operations or W_WeaponFrame
};
