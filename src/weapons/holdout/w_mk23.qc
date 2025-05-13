/*
==============================================================================
MK23 SOCOM - .45 ACP Pistol

SOCOM Mk.23 Pistol with standard and suppressed firing modes
- Primary fire (FIRE_MODE_PRIMARY): Standard fire
- Secondary fire (FIRE_MODE_SECONDARY): Suppressed fire (with attached suppressor)

Will be used as a foundation for a magazine-based reloading system.

v_mk23.mdl
==============================================================================
*/

// Forward declarations
void(float caliber, float bullet_type, float accuracy, float is_tracer) W_am_fire_bullet; // External function from am_ballistics.qc
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil; // External function from am_recoil.qc



// Magazine system constants
float MK23_MAG_CAPACITY = 12;    // Standard magazine capacity
float MK23_RELOAD_TIME = 1.8;    // Reload time in seconds

// Mk23-specific entity fields
.float mk23_mag_count;           // Number of rounds in current magazine
.float mk23_reload_time;         // Time when reload will be completed
.float mk23_is_reloading;        // Flag to check if currently reloading
.float reload_frame_time;         // Time between reload animation frames
.float reload_next_frame;         // Next frame index in the reload sequence

/*
================
w_mk23_SetCurrentAmmo
Set up the Mk23 as the current weapon
Called by W_SetCurrentAmmo in weapons.qc
================
*/
void() w_mk23_SetCurrentAmmo =
{
    self.weaponmodel = "progs/v_mk23.mdl";
    
    // First-time initialization of magazine
    if (!self.mk23_mag_count)
    {
        self.mk23_mag_count = MK23_MAG_CAPACITY;
    }
    
    // Expose mag count to the HUD via currentammo
    self.currentammo = self.mk23_mag_count;
    
    // Show .45 ACP as the ammo type
    self.items = self.items | IT_SHELLS;
    
    // Set up recoil pattern for Mk23
    // Using am_recoil.qc pattern system: (vertical, horizontal tendency, roll)
    // Mk23 has moderate vertical recoil with slight right drift
    AM_SetRecoilPattern('1.5 0.2 0', 4.0);
}

/*
void() w_mk23_precachelist = 
	{	
	precache_model ("progs/v_mk23.mdl");	// mk23 gun model
	precache_sound ("weapons/usp-reload_magin.wav");
	precache_sound ("weapons/usp-reload_magout.wav");
	precache_sound ("weapons/usp_unsil-1.wav");
	precache_sound ("weapons/usp_unsil-2.wav");
	precache_sound ("weapons/usp-suppressed-1.wav");
	};
*/


void() w_mk23_reload;
/*
================
MK23_HasNoAmmo check update
Update to check if reload is complete based on animation timing
================
*/
float() w_mk23_HasNoAmmo =
{
	// Check if we're in the middle of reloading
	if (self.mk23_is_reloading)
	{
		// Check if reload is complete
		if (time >= self.mk23_reload_time)
		{
			// Reload completed, fill magazine
			local float ammo_needed;
			ammo_needed = MK23_MAG_CAPACITY - self.mk23_mag_count;

			// Only use as much ammo as we have
			if (ammo_needed > self.ammo_shells)
				ammo_needed = self.ammo_shells;

			self.mk23_mag_count = self.mk23_mag_count + ammo_needed;
			self.ammo_shells = self.ammo_shells - ammo_needed;
			self.currentammo = self.mk23_mag_count;

			// Clear reloading flag
			self.mk23_is_reloading = FALSE;

			// Note: Sound is now handled by the animation system
			// Return FALSE to indicate we now have ammo
			return FALSE;
		}
		else
		{
			// Still reloading
			return TRUE;
		}
	}

	// If not reloading, return TRUE if magazine is empty, FALSE otherwise
	return (self.mk23_mag_count <= 0);
};

/*
================
w_mk23_BestMode
Determine the best firing mode
Called by W_WeaponBestMode in weapons.qc
Returns the best firing mode to use
================
*/
float() w_mk23_BestMode =
{
    // Always default to standard fire mode
    return FIRE_MODE_PRIMARY;
}

/*
================
w_mk23_reload
Initiate a reload sequence for the Mk23
Called when attempting to fire with an empty magazine
================
*/
void() w_mk23_reload =
{
    // Only reload if we have ammo and aren't already reloading
    if (self.ammo_shells <= 0 || self.mk23_is_reloading)
        return;

    // Set reloading flag
    self.mk23_is_reloading = TRUE;

    // Set time when reload will complete
    self.mk23_reload_time = time + MK23_RELOAD_TIME;

    // Play reload start sound
    // Note: This is now handled by the animation system
    // sound(self, CHAN_WEAPON, "weapons/usp-reload_magout.wav", 1, ATTN_NORM);

    // Start the reload animation sequence
    MK23_ReloadAnimation();

    // Set next think time (this might need adjustment based on your overall weapon logic)
    self.attack_finished = time + MK23_RELOAD_TIME;
};

/*
================
W_FireMk23
Main firing function for the Mk23 SOCOM
Called from W_Attack in weapons.qc
================
*/
void() W_FireMk23 =
{
    local vector dir;
    local vector muzzle_offset, muzzle_origin;
    local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up;
    local float accuracy_modifier;

    // Note: Ammo checking is now handled by W_HasNoAmmo before this is called

    // Set up aim direction
    dir = aim(self, 100000);

    // Define muzzle position for effects
    muzzle_offset_forward = 10;
    muzzle_offset_right = 3;
    muzzle_offset_up = -5;

    // Calculate muzzle world position
    makevectors(self.v_angle);
    muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
    muzzle_origin = self.origin + muzzle_offset;

    // Accuracy is affected by movement
    accuracy_modifier = 1.0;
    if (vlen(self.velocity) > 100)
        accuracy_modifier = 0.7; // Lower accuracy while moving

    // Use one round from magazine
    self.mk23_mag_count = self.mk23_mag_count - 1;
    self.currentammo = self.mk23_mag_count;

    // Primary fire mode: Standard fire
    if (self.weapon_mode_secondary == FIRE_MODE_PRIMARY)
    {
        // Randomly pick a firing sound
        if (random() < 0.5)
        {
            // Play the first firing sound
            sound(self, CHAN_WEAPON, "weapons/usp_unsil-1.wav", 1, ATTN_NORM);
        }
        else
        {
            // Play the second firing sound
            sound(self, CHAN_WEAPON, "weapons/usp_unsil-2.wav", 1, ATTN_NORM);
            // Replace with your second sound
        }

        // Set next attack time
        self.attack_finished = time + 0.2;
        // Fire a .45 ACP FMJ round
        W_am_fire_bullet(CAL_45ACP, BLT_FMJ, accuracy_modifier, 0);
        // Caliber, bullet type, accuracy, tracer

        // Apply recoil: strength, spread, vertical bias, sustained multiplier, max sustained
        AM_ApplyRecoil(2.0, 0.7, 1.2, 0.1, 2.0);
    }
    // Secondary fire mode: Suppressed fire
    else if (self.weapon_mode_secondary == FIRE_MODE_SECONDARY)
    {
        // Play the suppressed firing sound
        sound(self, CHAN_WEAPON, "weapons/usp-suppressed-1.wav", 0.6, ATTN_NORM);
        // Set next attack time
        self.attack_finished = time + 0.25; // Slightly slower with suppressor

        // Fire a .45 ACP FMJ round
        W_am_fire_bullet(CAL_45ACP, BLT_FMJ, accuracy_modifier * 0.95, 0); // Suppressor slightly reduces accuracy

        // Apply recoil: strength, spread, vertical bias, sustained multiplier, max sustained
        AM_ApplyRecoil(1.7, 0.7, 1.2, 0.1, 2.0); // Slightly reduced recoil with suppressor
    }

    // Reset sustained recoil counter if player hasn't fired for a while
    if (time - self.attack_finished > 0.5)
        AM_ResetSustainedRecoil();
    // Check for empty magazine and auto-reload
    if (self.mk23_mag_count <= 0 && self.ammo_shells > 0)
    {
        w_mk23_reload();
    }

    // Create muzzle flash at the proper position
    if (self.weapon_mode_secondary == FIRE_MODE_PRIMARY)
    {
        // Standard fire has muzzle flash
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, muzzle_origin_x);
        WriteCoord(MSG_BROADCAST, muzzle_origin_y);
        WriteCoord(MSG_BROADCAST, muzzle_origin_z);
    }
    else
    {
        // Suppressed fire has smaller flash
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_SPIKE);
        WriteCoord(MSG_BROADCAST, muzzle_origin_x);
        WriteCoord(MSG_BROADCAST, muzzle_origin_y);
        WriteCoord(MSG_BROADCAST, muzzle_origin_z);
    }

    MK23_FireAnimation(); // Call the fire animation here
}

/*
================
w_mk23_PickupAmmo
Handle ammo pickup for MK23
Called when the player picks up shells
================
*/

/*
void() w_mk23_PickupAmmo =
{
    // Increase the player's .45 ACP ammo reserve
    self.ammo_shells = self.ammo_shells + 12;
    
    // Update currentammo if this is the current weapon
    if (self.weapon == IT_MK23)
        self.currentammo = self.mk23_mag_count;
}
*/