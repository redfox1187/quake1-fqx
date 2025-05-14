/*
==============================================================================
w_ump45 - Potent little .45 spitter!

The UMP .45 stands out for its combination of compact size, lightweight polymer construction, 
and powerful .45 ACP caliber, making it an excellent choice for close-quarters engagements. 
Its manageable recoil allows for quick follow-up shots, while the simple blowback operating 
system ensures reliability in various conditions. Additionally, the UMP's versatility is 
enhanced by its compatibility with various accessories, making it adaptable for law enforcement 
and tactical operations.

Features:
- The .45 ACP round provides significant stopping power with a larger projectile, ensuring quick 
  incapacitation while minimizing over-penetration risks in urban environments. Its effective 
  recoil management allows for improved accuracy during rapid fire, making it a reliable choice 
  for tactical applications.
- Features three fire modes (Single, 3-Round Burst, Full Auto) plus a developer Debug mode.
- Uses generic fire mode system from am_operations.qc.
- Single fire mode is semi-automatic.
- Fires at 600 round per minute.

==============================================================================
*/

// Define constants for UMP45 properties
float UMP_ACCURACY_SINGLE = 1.5;       
float UMP_ACCURACY_BURST = 1.2;        
float UMP_ACCURACY_AUTO = 0.9;         
float UMP_RPM = 600;                   
float UMP_RECOIL_BASE = 1.0;           
float UMP_RECOIL_VERTICAL_BIAS = 2.5;  
float UMP_RECOIL_RECOVERY = 3.0;       
float UMP_FIRERATE = 60 / UMP_RPM;     


// Forward declarations for functions within this file
void() W_FireUMP45_Burst_Shot;  
void() W_FireUMP45_Burst_Think;
void() w_ump45_PrintCurrentMode; // Helper to print UMP specific mode names
void() W_FireUMP45_Single;
void() W_FireUMP45_Burst_Start;
void() W_FireUMP45_Auto;
void() W_FireUMP45; // Main firing dispatcher
void() W_SwitchModeUMP45; // Handles UMP45 mode switching


/*
================
w_ump45_SetCurrentAmmo
Sets up the UMP45 when selected by the player.
Called by the engine's W_SetCurrentAmmo (in weapons.qc).
================
*/
void() w_ump45_SetCurrentAmmo =
{
    // Initialize the weapon's view model and ammo display.
    // AMMO_ID_NAILS and IT_NAILS are placeholders for your UMP45 ammo type and item flag.
    AM_InitializeWeaponView("progs/v_ump45.mdl", AMMO_ID_NAILS, IT_NAILS); 
    
    // Configure the generic fire mode system for the UMP45.
    // It has 3 standard modes (Single, Burst, Auto) and supports a debug mode.
    AM_InitWeaponFireModes(3, TRUE); 

    // Initialize UMP45-specific state variables.
    self.ump_burst_count = 0;       
    self.ump_burst_active = 0;      
    // self.ump_last_fire_time is not reset here; firing functions will manage it.

    // Set the recoil pattern for the UMP45 (if using a recoil system).
    AM_SetRecoilPattern('0.1 0.2 0', UMP_RECOIL_RECOVERY); 
    // AM_ResetSustainedRecoil(); // This is called by AM_InitWeaponFireModes.
    
    // Optionally, print the initial fire mode to the console.
    w_ump45_PrintCurrentMode();
};

/*
================
w_ump45_HasNoAmmo
Checks if the UMP45 has ammunition.
Called by W_HasNoAmmo (in weapons.qc).
================
*/
float() w_ump45_HasNoAmmo =
{
    // Replace self.ammo_nails with the actual player field for UMP45 ammo.
    if (self.ammo_nails >= 1) 
        return FALSE; // Has ammo
    return TRUE;  // No ammo
};

/*
================
w_ump45_PrintCurrentMode
Helper function to print the UMP45's current fire mode to the console.
================
*/
void() w_ump45_PrintCurrentMode =
{
    // Uses the generic self.current_weapon_fire_mode to determine UMP45's specific mode.
    if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_SINGLE)
        sprint(self, "UMP45: Single fire mode\n"); 
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_BURST)
        sprint(self, "UMP45: 3-round burst mode\n"); 
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_AUTO)
        sprint(self, "UMP45: Full auto mode\n"); 
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_DEBUG && cvar("developer") > 0) 
        sprint(self, "UMP45: DEBUG (Max Accuracy) mode\n");
};

/*
================
W_SwitchModeUMP45
Handles the UMP45's fire mode switching.
This function is typically called when the player presses an alt-fire or mode switch key.
================
*/
void() W_SwitchModeUMP45 =
{
    AM_CycleFireMode();         // Call the generic function to cycle the mode index.
    w_ump45_PrintCurrentMode(); // Print the UMP45-specific name for the new mode.
    
    // Reset UMP45-specific burst state when changing modes.
    self.ump_burst_count = 0; 
    self.ump_burst_active = 0; 
    // AM_ResetSustainedRecoil(); // This is called by AM_CycleFireMode.
};

/*
================
W_FireUMP45_Single
Handles firing a single shot in semi-automatic mode.
================
*/
void() W_FireUMP45_Single =
{
    local float accuracy;

    if (!AM_CanFireSemiAuto()) 
    {
        // Player is holding the fire button, but a semi-auto shot is not allowed yet.
        // Try to explicitly clear any player-side muzzle flash.
        // EF_MUZZLEFLASH is the standard Quake C effect for this.
        if (self.effects & EF_MUZZLEFLASH)
        {
            self.effects = self.effects - EF_MUZZLEFLASH;
        }

        // Also, to prevent the weapon's attack animation from restarting immediately
        // (which might re-apply a muzzle flash or keep it in a "firing" pose),
        // set a very short attack_finished delay. This gives one frame for
        // W_WeaponFrame (or equivalent) to process an idle state.
        if (time >= self.attack_finished) // Only apply if not already in a longer cooldown
        {
            self.attack_finished = time + 0.05; // A very small delay
        }
        
        // Resetting weaponframe can also help ensure it goes to an idle animation.
        if (self.weaponframe != 0)
        {
            self.weaponframe = 0;
        }
        return; // Don't fire
    }
    
    // Check for ammo (this part remains the same)
    if (self.ammo_nails <= 0)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); 
        self.attack_finished = time + 0.2;
        self.weapon_fire_released = TRUE; 
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; } // Clear flash on dry fire too
        if (self.weaponframe != 0) { self.weaponframe = 0; }
        return;
    }
    
    // Actual firing logic (this part remains the same)
    AM_ConsumeAmmo(AMMO_ID_NAILS, 1);
    accuracy = UMP_ACCURACY_SINGLE;
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.7;
    
    // IMPORTANT: How is the UMP45's player-side muzzle flash normally triggered?
    // Is it by W_am_fire_bullets? Or is it part of the view model animation sequence
    // handled in W_WeaponFrame (weapons.qc) which sets self.effects based on self.weaponframe?
    // For now, we assume W_am_fire_bullets OR the animation sequence handles *setting* it briefly.
    // Our fix above focuses on *clearing* it if it lingers.
    
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5); 
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
    AM_ApplyRecoil(UMP_RECOIL_BASE * 0.8, 0.3, UMP_RECOIL_VERTICAL_BIAS, 0.2, 1.5); 
    
    self.attack_finished = time + UMP_FIRERATE;
    self.ump_last_fire_time = time;
    self.weapon_fire_released = FALSE; // CRITICAL: Set flag to require button release for next shot
};

/*
================
W_FireUMP45_Burst_Start
Initiates a 3-round burst. Burst fire logic is specific to the UMP45.
================
*/

void() W_FireUMP45_Burst_Start =
{
    // Don't start a new burst if one is already in progress.
    if (self.ump_burst_active) 
        return; 
        
    // Check if this burst action is allowed (like semi-auto)
    if (!AM_CanFireSemiAuto())
    {
        // Player is holding the fire button, but a new burst is not allowed yet.
        // Apply the same muzzle flash clearing logic as used in semi-auto.
        if (self.effects & EF_MUZZLEFLASH)
        {
            self.effects = self.effects - EF_MUZZLEFLASH;
        }

        // Set a very short attack_finished delay to prevent immediate re-evaluation
        // of attack animations, allowing the muzzle flash to visually clear.
        if (time >= self.attack_finished) // Only apply if not already in a longer cooldown
        {
            self.attack_finished = time + 0.05; // A very small delay
        }
        
        // Resetting weaponframe can also help ensure it goes to an idle animation.
        if (self.weaponframe != 0)
        {
            self.weaponframe = 0;
        }
        return; // Trigger not released and re-pressed, or already handled.
    }
    
    // Check for ammo.
    if (self.ammo_nails <= 0)
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        self.attack_finished = time + 0.2; 
        self.weapon_fire_released = TRUE; // Allow next fire attempt even if out of ammo.
        if (self.effects & EF_MUZZLEFLASH) { self.effects = self.effects - EF_MUZZLEFLASH; } // Clear flash on dry fire
        if (self.weaponframe != 0) { self.weaponframe = 0; } // Reset animation
        return;
    }
    
    // ---- Rest of the function remains the same as your last working version for burst ----
    self.ump_burst_active = 1;       // Mark burst as active.
    self.ump_burst_count = 0;        // Reset shots fired in this burst.
    AM_ResetSustainedRecoil();       // Reset recoil at the start of a burst.
    
    W_FireUMP45_Burst_Shot();        // Fire the first shot immediately.
    
    // Schedule the think function to fire subsequent shots in the burst.
    self.ump_next_burst_time = time + UMP_FIRERATE * 0.8; // Burst shots are slightly faster.
    self.think = W_FireUMP45_Burst_Think;                 
    self.nextthink = self.ump_next_burst_time;
    
    // Set overall weapon cooldown for the duration of the burst.
    self.attack_finished = time + (UMP_FIRERATE * 0.8 * 3) + 0.1; 

    self.weapon_fire_released = FALSE; // Mark the trigger pull as consumed for this burst action
};

/*
================
W_FireUMP45_Burst_Shot
Fires a single shot as part of an ongoing burst sequence.
================
*/
void() W_FireUMP45_Burst_Shot =
{
    local float accuracy;
    
    if (self.ammo_nails <= 0) // Replace self.ammo_nails.
    {
        self.ump_burst_active = 0; // Stop burst if out of ammo.
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); 
        return;
    }
    
    self.ump_burst_count = self.ump_burst_count + 1; 
    AM_ConsumeAmmo(AMMO_ID_NAILS, 1); // Replace AMMO_ID_NAILS.
    
    // Accuracy degrades slightly for each subsequent shot in the burst.
    accuracy = UMP_ACCURACY_BURST * (1 - (self.ump_burst_count * 0.1)); 
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.7; 
    
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5); 
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM); 
    
    AM_ApplyRecoil(UMP_RECOIL_BASE, 0.4, UMP_RECOIL_VERTICAL_BIAS, 0.3, 2.0); 
    self.ump_last_fire_time = time; 
};

/*
================
W_FireUMP45_Burst_Think
Player think function that manages firing subsequent shots in a burst.
================
*/
void() W_FireUMP45_Burst_Think =
{
    // Stop burst if 3 shots fired, burst flag cleared, or out of ammo.
    if (self.ump_burst_count >= 3 || !self.ump_burst_active || self.ammo_nails <= 0) 
    {
        self.ump_burst_active = 0; 
        AM_ResetSustainedRecoil(); 
        self.think = SUB_Null;    // Clear this think function.
        self.nextthink = -1;      // Stop thinking.
        return;
    }
    
    W_FireUMP45_Burst_Shot(); // Fire the next shot.
    
    // If burst isn't finished and still have ammo, schedule the next shot.
    if (self.ump_burst_count < 3 && self.ammo_nails > 0) 
    {
        self.ump_next_burst_time = time + UMP_FIRERATE * 0.8; 
        self.nextthink = self.ump_next_burst_time; 
    }
    else // Burst is done or out of ammo.
    {
        self.ump_burst_active = 0; 
        AM_ResetSustainedRecoil(); 
        self.think = SUB_Null;
        self.nextthink = -1;
    }
};

/*
================
W_FireUMP45_Auto
Handles firing in full-automatic mode.
================
*/
void() W_FireUMP45_Auto =
{
    local float accuracy;
    
    if (self.ammo_nails <= 0) // Replace self.ammo_nails.
    {
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); 
        self.attack_finished = time + 0.2; 
        AM_ResetSustainedRecoil(); 
        return;
    }
    
    AM_ConsumeAmmo(AMMO_ID_NAILS, 1); // Replace AMMO_ID_NAILS.
    accuracy = UMP_ACCURACY_AUTO; 
    
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.6; 
    
    // Accuracy degrades during sustained automatic fire.
    if ((time - self.ump_last_fire_time) < (UMP_FIRERATE * 3)) 
    {
        local float sustained_fire_time_delta = time - self.ump_last_fire_time; 
        local float shots_fired_estimate = sustained_fire_time_delta / UMP_FIRERATE;
        if (shots_fired_estimate > 5) shots_fired_estimate = 5; // Cap the effect.
        accuracy = accuracy * (1 - (shots_fired_estimate * 0.05)); 
    }
    
    self.ump_last_fire_time = time; 
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5); 
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM); 
    
    AM_ApplyRecoil(UMP_RECOIL_BASE * 1.1, 0.5, UMP_RECOIL_VERTICAL_BIAS, 0.15, 3.0); 
    self.attack_finished = time + UMP_FIRERATE; 
    self.weapon_fire_released = FALSE; // In auto mode, fire button is considered held.
};

/*
================
W_FireUMP45
Main firing dispatcher for the UMP45.
Called from W_Attack (in weapons.qc) when the player attempts to fire.
================
*/
void() W_FireUMP45 =
{
    // Dispatch to the correct firing function based on the current generic fire mode index.
    if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_DEBUG && cvar("developer") > 0) 
    {
        // Debug mode firing logic.
        // Example: allow rapid fire for testing, or use AM_CanFireSemiAuto for single-shot debug.
        // if (!AM_CanFireSemiAuto() && cvar("developer") < 2) { return; } // Optional semi-auto for debug

        if (self.ammo_nails <= 0) // Replace self.ammo_nails.
        {
            sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
            self.attack_finished = time + 0.2;
            self.weapon_fire_released = TRUE; // Allow next attempt.
            return;
        }
        AM_ConsumeAmmo(AMMO_ID_NAILS, 1); // Replace AMMO_ID_NAILS.
        W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, 9999, 0); // Max accuracy, no tracers.
        sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
        self.attack_finished = time + UMP_FIRERATE; 
        self.ump_last_fire_time = time;
        self.weapon_fire_released = FALSE; // Treat debug mode like auto-fire unless specifically made semi-auto.
    }
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_SINGLE)
    {
        W_FireUMP45_Single(); 
    }
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_BURST)
    {
        if (!self.ump_burst_active) // Only start a new burst if one isn't already active.
            W_FireUMP45_Burst_Start(); 
    }
    else if (self.current_weapon_fire_mode == UMP_FIREMODE_IDX_AUTO)
    {
        W_FireUMP45_Auto(); 
    }
    
    // General logic for resetting sustained recoil if firing stops for a bit.
    // This applies unless a burst is actively firing.
    if (!self.ump_burst_active && ((time - self.ump_last_fire_time) > 0.5)) 
    {
        // Only reset if not in single fire mode OR if single fire has been released
        // (to prevent resetting recoil immediately after a single shot if player taps fast).
        if (self.current_weapon_fire_mode != UMP_FIREMODE_IDX_SINGLE || self.weapon_fire_released)
        {
            AM_ResetSustainedRecoil(); 
        }
    }
};
