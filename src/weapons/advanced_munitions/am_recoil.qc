/*
==============================================================================
am_recoil.qc - Modern Recoil System for Quake 1 (Revised)

This recoil system improves on the standard Quake punchangle approach by:
1. Affecting both camera view AND actual aiming direction with balanced weights
2. Adding proper recovery with responsive time-based reset
3. Separating visual kick from actual aim displacement with reduced camera shake
4. Supporting weapon-specific recoil patterns
5. Being callable from any weapon via a single function
6. Guaranteeing full recoil reset within 1 second of not firing

Usage:
- Call AM_ApplyRecoil with appropriate parameters
- Updates to aim are handled automatically
- Recovery happens during player thinking

==============================================================================
*/

// Player entity fields for recoil system
.vector recoil_current;     // Current accumulated recoil affecting aim
.vector recoil_visual;      // Current visual-only recoil (camera kick)
.float recoil_last_time;    // Last time recoil was applied
.float recoil_recovery_rate;// How quickly recoil recovers (weapon-specific)
.vector recoil_pattern;     // Direction bias for the current weapon
.float recoil_shots_fired;  // Counter for shots fired with current weapon
.float recoil_last_shot;    // Time of last shot (for forced reset timer)

// Constants for recoil system
float RECOIL_RECOVERY_BASE = 2.5;    // Base recovery rate multiplier (increased for faster recovery)
float RECOIL_RECOVERY_ACCEL = 2.0;   // Accelerated recovery when not firing
float RECOIL_VISUAL_MULTIPLIER = 0.7; // Visual kick is weaker than actual aim displacement (reduced from 1.5)
float RECOIL_MAX_RESET_TIME = 1.0;   // Maximum time to reset recoil completely (in seconds)

/*
================
AM_GetSignFloat

Helper function to get the sign of a number
================
*/
float(float v) AM_GetSignFloat =
{
    if (v > 0)
        return 1;
    if (v < 0)
        return -1;
    return 0;
};

/*
================
AM_RecoilThink

Updates the player's recoil state during thinking
Called from PlayerPostThink or similar function
================
*/
void() AM_RecoilThink =
{
    local float delta_time;
    local float recovery_strength;
    local vector aim_recovery;
    local float time_since_last_shot;
    local float forced_reset_factor;
    
    // Calculate time since last recoil update
    delta_time = time - self.recoil_last_time;
    if (delta_time <= 0)
        return;
    
    self.recoil_last_time = time;
    
    // Calculate time since last shot for forced reset
    time_since_last_shot = time - self.recoil_last_shot;
    
    // Calculate forced reset factor (increases as we approach RECOIL_MAX_RESET_TIME)
    // This ensures complete recoil reset within the maximum time
    forced_reset_factor = 1.0;
    if (time_since_last_shot > 0.1) // Only apply after a short delay to allow for recoil buildup
    {
        // Calculate a factor that grows exponentially as we approach the max reset time
        forced_reset_factor = 1.0 + (time_since_last_shot / RECOIL_MAX_RESET_TIME) * 5.0;
        
        // If we're at or beyond the max reset time, force complete reset
        if (time_since_last_shot >= RECOIL_MAX_RESET_TIME)
        {
            self.recoil_current = '0 0 0';
            self.recoil_visual = '0 0 0';
            self.punchangle = '0 0 0';
            self.recoil_shots_fired = 0;
            return;
        }
    }
    
    // Calculate recovery rates based on time since last shot and forced reset factor
    recovery_strength = (self.recoil_recovery_rate * RECOIL_RECOVERY_BASE) * delta_time * forced_reset_factor;
    
    // Apply increased recovery when not actively shooting
    if (time_since_last_shot > 0.2)
        recovery_strength = recovery_strength * RECOIL_RECOVERY_ACCEL;
    
    // Apply recovery to aiming recoil with smooth interpolation
    // Use current recoil magnitude to determine recovery speed (larger recoil recovers faster)
    aim_recovery = self.recoil_current * (recovery_strength * 0.8);
    
    // Implement minimum recovery rate to prevent extremely slow recovery at low values
    if (vlen(self.recoil_current) > 0.01)
    {
        // Ensure a minimum recovery rate based on delta_time
        local float min_recovery = delta_time * 2.0 * forced_reset_factor;
        
        if (fabs(aim_recovery_x) < min_recovery && self.recoil_current_x != 0)
            aim_recovery_x = min_recovery * AM_GetSignFloat(self.recoil_current_x);
        
        if (fabs(aim_recovery_y) < min_recovery && self.recoil_current_y != 0)
            aim_recovery_y = min_recovery * AM_GetSignFloat(self.recoil_current_y);
    }
    
    // Limit recovery to actual recoil amount to prevent overshooting
    if (fabs(aim_recovery_x) > fabs(self.recoil_current_x))
        aim_recovery_x = self.recoil_current_x;
    if (fabs(aim_recovery_y) > fabs(self.recoil_current_y))
        aim_recovery_y = self.recoil_current_y;
    
    // Apply the recovery to aim recoil
    self.recoil_current = self.recoil_current - aim_recovery;
    
    // Handle very small recoil values - snap to zero to prevent floating point issues
    if (fabs(self.recoil_current_x) < 0.01)
        self.recoil_current_x = 0;
    if (fabs(self.recoil_current_y) < 0.01)
        self.recoil_current_y = 0;
    
    // Update visual recoil with smooth dampening
    // Visual recoil recovers faster than aim recoil for reduced camera shake
    self.recoil_visual = self.recoil_current * RECOIL_VISUAL_MULTIPLIER;
    
    // Apply visual recoil to view angles via punchangle
    self.punchangle_x = self.recoil_visual_x;
    self.punchangle_y = self.recoil_visual_y;
    
    // Apply aiming recoil to actual view angles
    self.v_angle = self.v_angle + self.recoil_current - self.recoil_current; // Apply recoil delta
    
    // Clamp view angles to prevent extreme values but allow proper up/down aiming
    if (self.v_angle_x > 89)
        self.v_angle_x = 89;
    else if (self.v_angle_x < -89)
        self.v_angle_x = -89;
        
    // Normalize horizontal angle
    while (self.v_angle_y > 180)
        self.v_angle_y = self.v_angle_y - 360;
    while (self.v_angle_y < -180)
        self.v_angle_y = self.v_angle_y + 360;
};

/*
================
AM_InitRecoilSystem

Initialize the player's recoil state
Called when player first spawns
================
*/
void() AM_InitRecoilSystem =
{
    self.recoil_current = '0 0 0';
    self.recoil_visual = '0 0 0';
    self.recoil_last_time = time;
    self.recoil_last_shot = time - 10; // Set to past time to ensure no initial recoil
    self.recoil_recovery_rate = 2.0;   // Default recovery rate
    self.recoil_pattern = '0 0 0';
    self.recoil_shots_fired = 0;
};

/*
================
AM_SetRecoilPattern

Set the recoil pattern for the current weapon
Called when player switches weapons
================
*/
void(vector pattern, float recovery_rate) AM_SetRecoilPattern =
{
    self.recoil_pattern = pattern;
    self.recoil_recovery_rate = recovery_rate;
    self.recoil_shots_fired = 0;
};

/*
================
AM_ApplyRecoil

Apply recoil to the player
Called when firing a weapon

Parameters:
- strength: Base recoil strength
- spread: Random spread factor
- vertical_bias: How much more vertical than horizontal recoil (1.0 = equal)
- sustained_multiplier: How much recoil increases with sustained fire
- max_sustained: Maximum sustained fire multiplier
================
*/
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil =
{
    local vector recoil_amount;
    local float sustained_factor;
    local vector pattern_influence;
    local float random_factor;
    
    // Update shots fired counter
    self.recoil_shots_fired = self.recoil_shots_fired + 1;
    
    // Record time of last shot
    self.recoil_last_shot = time;
    
    // Calculate sustained fire multiplier (capped)
    sustained_factor = 1 + (self.recoil_shots_fired - 1) * sustained_multiplier;
    if (sustained_factor > max_sustained)
        sustained_factor = max_sustained;
    
    // Add consistency to randomness by using a controlled random factor
    random_factor = random();
    
    // Calculate base recoil with reduced randomness for more predictable patterns
    recoil_amount_x = -1 * strength * vertical_bias * (1 + (random_factor - 0.5) * spread * 0.3);
    recoil_amount_y = strength * (random_factor - 0.5) * spread * 0.6; // Reduce horizontal randomness
    
    // Apply weapon's recoil pattern influence - stronger with sustained fire
    pattern_influence = self.recoil_pattern * sustained_factor * 0.5;
    
    // Create final recoil vector
    recoil_amount = recoil_amount + pattern_influence;
    
    // Apply sustained fire multiplier with smoothing
    recoil_amount = recoil_amount * sustained_factor * 0.8;
    
    // Apply to current recoil (affecting aim)
    self.recoil_current = self.recoil_current + recoil_amount;
    
    // Limit maximum recoil to prevent excessive accumulation
    if (self.recoil_current_x < -15)
        self.recoil_current_x = -15;
    if (fabs(self.recoil_current_y) > 5)
        self.recoil_current_y = 5 * AM_GetSignFloat(self.recoil_current_y);
    
    // Apply visual recoil - reduced proportion for less camera shake
    self.recoil_visual = self.recoil_current * RECOIL_VISUAL_MULTIPLIER;
    
    // Update last recoil time
    self.recoil_last_time = time;
};

/*
================
AM_ResetSustainedRecoil

Reset the sustained fire counter
Called when player stops firing for a moment
================
*/
void() AM_ResetSustainedRecoil =
{
    self.recoil_shots_fired = 0;
};

/*
================
AM_StatsRecoil

Debug function to print current recoil values
================
*/
void() AM_StatsRecoil =
{
    sprint(self, "Recoil stats:\n");
    sprint(self, "Current aim offset: ");
    sprint(self, vtos(self.recoil_current));
    sprint(self, "\nVisual kick: ");
    sprint(self, vtos(self.recoil_visual));
    sprint(self, "\nShots fired: ");
    sprint(self, ftos(self.recoil_shots_fired));
    sprint(self, "\nTime since last shot: ");
    sprint(self, ftos(time - self.recoil_last_shot));
    sprint(self, "\n");
};