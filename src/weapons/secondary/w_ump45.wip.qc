/*
==============================================================================
w_ump45 - Potent little .45 spitter!

Features:
- Its effective recoil management allows for improved accuracy during rapid fire, making it a reliable choice for tactical applications.
- Fires at 600 round per minute.

==============================================================================
*/

// External functions from am_ballistics.qc
void(float instances, float caliber, float bullet_type, float accuracy, float tracer_interval) W_am_fire_bullets;

// External functions from am_recoil.qc
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil;
void(vector pattern, float recovery_rate) AM_SetRecoilPattern;
void() AM_ResetSustainedRecoil;

// Define constants for fire modes
float UMP_MODE_SINGLE = 0;
float UMP_MODE_BURST = 1;
float UMP_MODE_AUTO = 2;

// Define constants for UMP45 properties
float UMP_DAMAGE_MULTIPLIER = 1.0;     // Base damage multiplier
float UMP_ACCURACY_SINGLE = 1.5;       // Higher accuracy in single shot mode
float UMP_ACCURACY_BURST = 1.2;        // Good accuracy in burst mode
float UMP_ACCURACY_AUTO = 0.9;         // Lower accuracy in full auto
float UMP_RPM = 600;                   // Rounds per minute - 600 RPM

// Define recoil characteristics for UMP45
float UMP_RECOIL_BASE = 1.0;           // Base recoil strength
float UMP_RECOIL_VERTICAL_BIAS = 2.5;  // UMP45 kicks more upward than sideways
float UMP_RECOIL_RECOVERY = 3.0;       // UMP45 has good recovery due to ergonomics

// Calculate time between shots based on RPM
float UMP_FIRERATE = 60 / UMP_RPM;     // 60 seconds / RPM = time between shots

// Define fields for the player entity to track UMP45 state
.float ump_fire_mode;       // Current fire mode
.float ump_burst_count;     // Track number of rounds fired in burst
.float ump_last_fire_time;  // Last time weapon was fired (for recoil calculation)
.float ump_burst_active;    // Flag to track if we're in an active burst
.float ump_next_burst_time; // Time for next shot in a burst sequence

void() W_FireUMP45_Burst_Shot;  
void() W_FireUMP45_Burst_Think;

/*
================
w_ump45_SetCurrentAmmo
Set up the UMP45 as the current weapon
Called by W_SetCurrentAmmo in weapons.qc
================
*/
void() w_ump45_SetCurrentAmmo =
{
    self.weaponmodel = "progs/v_ump45.mdl";
    self.currentammo = self.ammo_nails;
    
    // Default to single fire mode when weapon is first selected
    if (!self.ump_fire_mode)
        self.ump_fire_mode = UMP_MODE_SINGLE;
        
    // Reset burst sequence when switching to weapon
    self.ump_burst_count = 0;
    self.ump_burst_active = 0;
    
    // Set UMP45-specific recoil pattern
    // Small rightward bias for UMP45 recoil pattern
    AM_SetRecoilPattern('0.1 0.2 0', UMP_RECOIL_RECOVERY);
    
    // Reset sustained fire counter
    AM_ResetSustainedRecoil();
};

/*
================
w_ump45_HasNoAmmo
Check if the UMP45 has ammo
Called by W_HasNoAmmo in weapons.qc
Returns TRUE if no ammo, FALSE if has ammo
================
*/
float() w_ump45_HasNoAmmo =
{
    if (self.ammo_nails >= 1)
        return FALSE;
    
    return TRUE;
};

/*
================
w_ump45_CycleFireMode
Cycle through the UMP45 fire modes
Called when the user presses the alt-fire button while UMP45 is active
================
*/
void() w_ump45_CycleFireMode =
{
    // Cycle to next fire mode
    self.ump_fire_mode = self.ump_fire_mode + 1;
    if (self.ump_fire_mode > UMP_MODE_AUTO)
        self.ump_fire_mode = UMP_MODE_SINGLE;
    
    // Give feedback to player about current mode
    if (self.ump_fire_mode == UMP_MODE_SINGLE)
        sprint(self, "UMP45: Single fire mode\n");
    else if (self.ump_fire_mode == UMP_MODE_BURST)
        sprint(self, "UMP45: 3-round burst mode\n");
    else if (self.ump_fire_mode == UMP_MODE_AUTO)
        sprint(self, "UMP45: Full auto mode\n");
    
    // Play mode switch sound
    sound(self, CHAN_ITEM, "weapons/weaponclick.wav", 0.5, ATTN_NORM);
    
    // Reset fire sequence if in progress
    self.ump_burst_count = 0;
    self.ump_burst_active = 0;
    
    // Reset sustained fire counter
    AM_ResetSustainedRecoil();
};

/*
================
W_FireUMP45_Single
Fire a single shot from the UMP45
================
*/
void() W_FireUMP45_Single =
{
    local float accuracy;
    
    // Check if we still have ammo
    if (self.ammo_nails <= 0)
    {
        // Click sound for empty gun
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        return;
    }
    
    // Use up one round
    self.currentammo = self.ammo_nails = self.ammo_nails - 1;
    
    // Set accuracy based on current stance/movement
    accuracy = UMP_ACCURACY_SINGLE;
    
    // Reduce accuracy if moving
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.7;
    
    // Fire the bullet - .45 ACP FMJ round with tracer every 5th round
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5);
    
    // Play fire sound
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
    
    // Apply recoil using new system
    // Parameters: strength, spread, vertical_bias, sustained_multiplier, max_sustained
    AM_ApplyRecoil(UMP_RECOIL_BASE * 0.8, 0.3, UMP_RECOIL_VERTICAL_BIAS, 0.2, 1.5);
    
    // Set next shot time
    self.attack_finished = time + UMP_FIRERATE;
    
    // Update last fire time
    self.ump_last_fire_time = time;
    
    // Reset sustained recoil after a delay (for single fire mode)
    if (self.ump_fire_mode == UMP_MODE_SINGLE)
    {
        // Reset sustained recoil if it's been more than 0.5 sec since last shot
        if (time - self.ump_last_fire_time > 0.5)
            AM_ResetSustainedRecoil();
    }
};

/*
================
W_FireUMP45_Burst_Start
Start a 3-round burst from the UMP45
================
*/
void() W_FireUMP45_Burst_Start =
{
    // Check if we're already in an active burst
    if (self.ump_burst_active)
        return;
        
    // Check if we have enough ammo for at least one shot
    if (self.ammo_nails <= 0)
    {
        // Click sound for empty gun
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        return;
    }
    
    // Initialize burst sequence
    self.ump_burst_active = 1;
    self.ump_burst_count = 0;
    
    // Reset sustained recoil counter at the start of a burst
    AM_ResetSustainedRecoil();
    
    // Fire first shot immediately
    W_FireUMP45_Burst_Shot();
    
    // Schedule next shots
    self.ump_next_burst_time = time + UMP_FIRERATE * 0.8; // Slightly faster in burst
    self.think = W_FireUMP45_Burst_Think;
    self.nextthink = self.ump_next_burst_time;
    
    // Set attack finished to prevent further firing until burst is complete
    self.attack_finished = time + (UMP_FIRERATE * 0.8 * 3) + 0.1;
};

/*
================
W_FireUMP45_Burst_Shot
Fire a single shot in a burst sequence
================
*/
void() W_FireUMP45_Burst_Shot =
{
    local float accuracy;
    
    // Check if we still have ammo
    if (self.ammo_nails <= 0)
    {
        // End burst sequence
        self.ump_burst_active = 0;
        
        // Click sound for empty gun
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        return;
    }
    
    // Increment burst counter
    self.ump_burst_count = self.ump_burst_count + 1;
    
    // Use up one round
    self.currentammo = self.ammo_nails = self.ammo_nails - 1;
    
    // Set accuracy based on burst progression (gets less accurate)
    accuracy = UMP_ACCURACY_BURST * (1 - (self.ump_burst_count * 0.1));
    
    // Reduce accuracy if moving
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.7;
    
    // Fire the bullet - .45 ACP FMJ round with tracer every 5th round
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5);
    
    // Play fire sound
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
    
    // Apply recoil using new system - slightly stronger in burst mode
    // Parameters: strength, spread, vertical_bias, sustained_multiplier, max_sustained
    AM_ApplyRecoil(UMP_RECOIL_BASE, 0.4, UMP_RECOIL_VERTICAL_BIAS, 0.3, 2.0);
    
    // Update last fire time
    self.ump_last_fire_time = time;
};

/*
================
W_FireUMP45_Burst_Think
Think function for handling burst fire timing
================
*/
void() W_FireUMP45_Burst_Think =
{
    // Check if burst sequence is complete
    if (self.ump_burst_count >= 3 || !self.ump_burst_active || self.ammo_nails <= 0)
    {
        // End burst sequence
        self.ump_burst_active = 0;
        
        // Reset sustained recoil after burst completes
        AM_ResetSustainedRecoil();
        return;
    }
    
    // Fire next shot in burst
    W_FireUMP45_Burst_Shot();
    
    // If we haven't completed the burst, schedule next shot
    if (self.ump_burst_count < 3 && self.ammo_nails > 0)
    {
        self.ump_next_burst_time = time + UMP_FIRERATE * 0.8; // Slightly faster in burst
        self.nextthink = self.ump_next_burst_time;
    }
    else
    {
        // End burst sequence
        self.ump_burst_active = 0;
        
        // Reset sustained recoil after burst completes
        AM_ResetSustainedRecoil();
    }
};

/*
================
W_FireUMP45_Auto
Fire automatic mode for the UMP45
================
*/
void() W_FireUMP45_Auto =
{
    local float accuracy;
    
    // Check if we still have ammo
    if (self.ammo_nails <= 0)
    {
        // Click sound for empty gun
        sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        self.attack_finished = time + 0.2;
        
        // Reset sustained fire when empty
        AM_ResetSustainedRecoil();
        return;
    }
    
    // Use up one round
    self.currentammo = self.ammo_nails = self.ammo_nails - 1;
    
    // Set accuracy based on current stance/movement
    accuracy = UMP_ACCURACY_AUTO;
    
    // Reduce accuracy if moving
    if (vlen(self.velocity) > 20)
        accuracy = accuracy * 0.6;
    
    // Further reduce accuracy for sustained fire
    if (time - self.ump_last_fire_time < UMP_FIRERATE * 3)
    {
        // Calculate how many shots recently fired (estimate)
        local float sustained_fire_time = time - self.ump_last_fire_time;
        local float shots_fired = sustained_fire_time / UMP_FIRERATE;
        if (shots_fired > 5)
            shots_fired = 5;  // Cap at 5 for calculation
            
        // Decrease accuracy by 5% per recent shot
        accuracy = accuracy * (1 - (shots_fired * 0.05));
    }
    
    // Update last fire time
    self.ump_last_fire_time = time;
    
    // Fire the bullet - .45 ACP FMJ round with tracer every 5th round
    W_am_fire_bullets(1, CAL_45ACP, BLT_FMJ, accuracy, 5);
    
    // Play fire sound
    sound(self, CHAN_WEAPON, "weapons/ump45-1.wav", 1, ATTN_NORM);
    
    // Apply recoil using new system - strongest in auto mode
    // Parameters: strength, spread, vertical_bias, sustained_multiplier, max_sustained
    AM_ApplyRecoil(UMP_RECOIL_BASE * 1.2, 0.5, UMP_RECOIL_VERTICAL_BIAS, 0.15, 3.0);
    
    // Set next shot time
    self.attack_finished = time + UMP_FIRERATE;
};

/*
================
W_FireUMP45
Main firing function for the UMP45
Called from W_Attack in weapons.qc
================
*/
void() W_FireUMP45 =
{

//Need to make a semi-auto check for weapons, to require the player to click per shot. This should be turned off for full auto mode.
    // Fire based on current mode
    if (self.ump_fire_mode == UMP_MODE_SINGLE)
    {
        W_FireUMP45_Single();
    }
    else if (self.ump_fire_mode == UMP_MODE_BURST)
    {
        if (!self.ump_burst_active)
            W_FireUMP45_Burst_Start();
    }
    else if (self.ump_fire_mode == UMP_MODE_AUTO)
    {
        W_FireUMP45_Auto();
    }
    
    // Reset sustained recoil if we stop firing for too long
    if (time - self.ump_last_fire_time > 0.5)
        AM_ResetSustainedRecoil();
};

/*
================
W_SwitchModeUMP45
Handle mode switching for UMP45
Called from W_AltAttack in weapons.qc
================
*/
void() W_SwitchModeUMP45 =
{
    w_ump45_CycleFireMode();
};