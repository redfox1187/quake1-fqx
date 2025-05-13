/*
==============================================================================
DBSG-12 - Double Barrel Shotgun 12 Gauge

Double Barrel Shotgun with Single or Double fire modes
- Primary fire (FIRE_MODE_PRIMARY): Single barrel shot
- Secondary fire (FIRE_MODE_SECONDARY): Double barrel shot

Features:
- The 12-gauge shotgun shells deliver devastating close-range stopping power, with
  the option to fire both barrels simultaneously for maximum damage.
- The classic break-action design ensures reliability even in adverse conditions.
- Distinct visual feedback with improved recoil simulation for authentic weapon feel.

==============================================================================
*/


// External functions from am_buckshot.qc
void(vector passed_fire_origin, float instances, float ammo_type, float ammo_spread_mod) W_am_buckshot;

// External functions from am_recoil.qc
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil;
void(vector pattern, float recovery_rate) AM_SetRecoilPattern;
void() AM_ResetSustainedRecoil;

// Define constants for recoil characteristics
float DBSHOT_RECOIL_BASE_SINGLE = 2.0;      // Base recoil strength for single barrel
float DBSHOT_RECOIL_BASE_DOUBLE = 4.0;      // Base recoil strength for double barrel
float DBSHOT_RECOIL_VERTICAL_BIAS = 3.0;    // Strong upward kick
float DBSHOT_RECOIL_RECOVERY = 2.0;         // Recovery rate from recoil

/*
================
w_dbshot_SetCurrentAmmo
Set up the double barrel shotgun as the current weapon
Called by W_SetCurrentAmmo in weapons.qc
================
*/
void() w_dbshot_SetCurrentAmmo =
{

	AM_InitializeWeaponView("progs/v_dbshot.mdl", AMMO_ID_SHELLS, IT_SHELLS);
	
	// Set DBSG-12 specific recoil pattern
	// Slightly left-biased recoil pattern for the double barrel
	AM_SetRecoilPattern('-0.05 0.3 0', DBSHOT_RECOIL_RECOVERY);
	
	// Reset sustained fire counter
	AM_ResetSustainedRecoil();
}

/*
================
w_dbshot_HasNoAmmo
Check if the double barrel shotgun has ammo for its current mode
Called by W_HasNoAmmo in weapons.qc
Returns TRUE if no ammo, FALSE if has ammo
================
*/
float() w_dbshot_HasNoAmmo =
{
	// Primary mode needs 1 shell, secondary needs 2
	if (self.weapon_mode_secondary == FIRE_MODE_PRIMARY && self.ammo_shells >= 1)
		return FALSE;
	else if (self.weapon_mode_secondary == FIRE_MODE_SECONDARY && self.ammo_shells >= 2)
		return FALSE;
	else if (self.weapon_mode_secondary == FIRE_MODE_SECONDARY && self.ammo_shells == 1)
	{
		// Automatically switch to single shot mode if only one shell left
		self.weapon_mode_secondary = FIRE_MODE_PRIMARY;
		sprint(self, "Only one shell left. Switching to single mode.\n");
		return FALSE;
	}
	
	// No ammo
	return TRUE;
}

/*
================
w_dbshot_BestMode
Determine the best firing mode based on available ammo
Called by W_WeaponBestMode in weapons.qc
Returns the best firing mode to use
================
*/
float() w_dbshot_BestMode =
{
	// If we have enough shells for double barrel mode, use it
	if (self.ammo_shells >= 2)
		return FIRE_MODE_SECONDARY;
	
	// Otherwise use single barrel mode
	return FIRE_MODE_PRIMARY;
}

/*
================
W_FireDBShot
Main firing function for the Double Barrel Shotgun
Called from W_Attack in weapons.qc
================
*/
void() W_FireDBShot =
{
	local vector dir;
	local vector muzzle_offset, muzzle_origin;
	local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up;
	local float last_fire_time;

	// Note: Ammo checking is now handled by W_HasNoAmmo before this is called
	// But we still need to handle the case where we have 1 shell but are in secondary mode
	if (self.ammo_shells < 2 && self.weapon_mode_secondary == FIRE_MODE_SECONDARY)
	{
		// Not enough ammo for double shot, fall back to single shot
		self.weapon_mode_secondary = FIRE_MODE_PRIMARY;
	}

	// Store last fire time for recoil calculations
	last_fire_time = time;

	// Set up aim direction
	dir = aim(self, 1000);
	
	// Define muzzle position for effects
	muzzle_offset_forward = 16;
	muzzle_offset_right = 0;
	muzzle_offset_up = 20;

	// Calculate muzzle world position
	makevectors(self.v_angle);
	muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
	muzzle_origin = self.origin + muzzle_offset;

	// Primary fire mode: Single barrel
	if (self.weapon_mode_secondary == FIRE_MODE_PRIMARY)
	{
		// Play the single-shot sound
		sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

		// Use up one shell
		self.attack_finished = time + 0.7;
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 1);
		
		// Fire a single shot of triple-aught buckshot
		W_am_buckshot(muzzle_origin, 1, AMT_12G000BUCK, 1); // Number of shots fired, Shell type, and spread modifier

		// Apply recoil using new system
		// Parameters: strength, spread, vertical_bias, sustained_multiplier, max_sustained
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_SINGLE, 0.6, DBSHOT_RECOIL_VERTICAL_BIAS, 0.3, 2.0);
		
		// Apply visual feedback (camera punch)
		self.punchangle_x = -5;
	}
	// Secondary fire mode: Double barrel
	else if (self.weapon_mode_secondary == FIRE_MODE_SECONDARY)
	{
		// Play the double-shot sound
		sound(self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

		// Use up two shells
		self.attack_finished = time + 1.4;
		AM_ConsumeAmmo(AMMO_ID_SHELLS, 2);
		
		// Fire both barrels with triple-aught buckshot
		W_am_buckshot(muzzle_origin, 2, AMT_12G000BUCK, 1.1); // Number of shots fired, Shell type, and spread modifier
                                               // Increased spread for double barrel

		// Apply recoil using new system - much stronger for double barrel
		// Parameters: strength, spread, vertical_bias, sustained_multiplier, max_sustained
		AM_ApplyRecoil(DBSHOT_RECOIL_BASE_DOUBLE, 0.9, DBSHOT_RECOIL_VERTICAL_BIAS, 0.4, 4.0);
		
		// Apply stronger visual feedback (camera punch)
		self.punchangle_x = -10;
	}
	
	// Reset sustained recoil after a longer delay (shotguns have longer recovery)
	if (time - last_fire_time > 1.0)
		AM_ResetSustainedRecoil();
}