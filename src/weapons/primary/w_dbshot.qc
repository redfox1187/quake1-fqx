//=============================================================================
// w_dbshot.qc - FQX Mod - Double Barrel Shotgun
// ##FQXCUSTOM - ##Quedra: Weapon data sheet and logic for DBShot.
// ##Quedra: Version 1.1 - Updated AM_InitWeaponFireModes call.
//=============================================================================

// External functions from am_buckshot.qc (Assumed forward declared in defs_2.qc)
// void(vector passed_fire_origin, float instances, float ammo_type, float ammo_spread_mod) W_am_buckshot;

// External functions from am_recoil.qc (Assumed forward declared in defs_2.qc)
// void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil;
// void(vector pattern, float recovery_rate) AM_SetRecoilPattern;
// void() AM_ResetSustainedRecoil;

// External functions from am_operations.qc (Assumed forward declared in defs_2.qc)
// void(string model_path, float ammo_id_enum, float items_flag) AM_InitializeWeaponView;
// void(float ammo_id, float amount_to_consume) AM_ConsumeAmmo;
// void(float num_standard_modes) AM_InitWeaponFireModes; // ##Quedra: Corrected signature
// void() AM_CycleFireMode;
// float() AM_CanFireSemiAuto; 

// DBShot Specific Fire Mode Interpretation (maps to self.current_weapon_fire_mode indices)
float DBSHOT_FIREMODE_IDX_SINGLE = 0; // Corresponds to FIREMODE_IDX_PRIMARY
float DBSHOT_FIREMODE_IDX_DOUBLE = 1; // Corresponds to FIREMODE_IDX_SECONDARY

// Define constants for recoil characteristics
float DBSHOT_RECOIL_BASE_SINGLE = 2.0;      // Base recoil strength for single barrel
float DBSHOT_RECOIL_BASE_DOUBLE = 4.0;      // Base recoil strength for double barrel
float DBSHOT_RECOIL_VERTICAL_BIAS = 3.0;    // Strong upward kick
float DBSHOT_RECOIL_RECOVERY = 2.0;         // Recovery rate from recoil

// Forward declarations for functions within this file
void() w_dbshot_PrintCurrentMode;
void() W_SwitchModeDBShot;
void() w_dbshot_SetCurrentAmmo;
void() W_FireDBShot;

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
	AM_InitializeWeaponView("progs/v_doublebarrel.mdl", AMMO_ID_SHELLS, IT_SLOT_SECONDARY); // ##Quedra: Assuming IT_SLOT_SECONDARY based on typical role
    // Initialize fire modes for DBShot: 2 standard modes.
    AM_InitWeaponFireModes(2); // ##Quedra: Corrected call, removed second parameter
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
    {
        sprint(self, "DBShot: Single Barrel mode\n");
    }
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE)
    {
        sprint(self, "DBShot: Double Barrel mode\n"); 
    }
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

    // If trying to fire Double Barrel with only 1 shell, auto-switch to Single Barrel mode for this shot.
    if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells == 1)
	{
		sprint(self, "DBShot: Only one shell left, firing single barrel.\n");
	}
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells < 2)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); // Dry fire
		self.attack_finished = time + 0.5;
        return;
    }
    else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_SINGLE && self.ammo_shells < 1)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); // Dry fire
		self.attack_finished = time + 0.5;
        return;
    }

	// Set up aim direction (though W_am_buckshot uses self.v_angle directly)
	dir = aim(self, 1000); 
	
	// Define muzzle position for effects
	muzzle_offset_forward = 16; 
	muzzle_offset_right = 0;    
	muzzle_offset_up = 20;      

	makevectors(self.v_angle);
	muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
	muzzle_origin = self.origin + self.view_ofs + muzzle_offset;

	// Fire based on current mode
	if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_SINGLE || 
       (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells == 1) ) // Single or forced single
	{
		sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM); // Single barrel sound
		self.attack_finished = time + 0.7; // Cooldown for single barrel
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 1);
		W_am_buckshot(muzzle_origin, 1, AMT_12G000BUCK, 1); 
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_SINGLE, 0.6, DBSHOT_RECOIL_VERTICAL_BIAS, 0.3, 2.0);
		self.punchangle_x = -5; // Visual punch
	}
	else if (self.current_weapon_fire_mode == DBSHOT_FIREMODE_IDX_DOUBLE && self.ammo_shells >= 2) // Double barrel
	{
		sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM); // Double barrel sound
		self.attack_finished = time + 1.4; // Longer cooldown for double barrel
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 2);
		W_am_buckshot(muzzle_origin, 2, AMT_12G000BUCK, 1.1); // Fire 2 instances, slightly more spread
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_DOUBLE, 0.9, DBSHOT_RECOIL_VERTICAL_BIAS, 0.4, 4.0);
		self.punchangle_x = -10; // Stronger visual punch
	}
};
//=============================================================================
// w_dbshot.qc - FQX Mod - Double Barrel Shotgun - END
// ##Quedra: Version 1.1
//=============================================================================