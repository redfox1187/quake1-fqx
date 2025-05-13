/*
==============================================================================
RAHP - Republic Army Holdout Pistol

Fires rapid weak shots (primary mode), or alternate fire to switch to
moderate speed but boosted damage shots that costs Cells (secondary mode).
Uses generic fire mode system from am_operations.qc.
View Model: v_rahpm1.mdl
==============================================================================
*/

// External functions from am_laser.qc
// void(float laser_type, float with_muzzleflash, float play_sound) W_am_fire_laser;
// float LASER_SMALL;
// float LASER_BIG;

// External functions from am_operations.qc
// void(float num_standard_modes, float supports_debug_mode) AM_InitWeaponFireModes;
// void() AM_CycleFireMode;
// void() AM_ResetSustainedRecoil; // If needed directly, though AM_Init/Cycle call it.

// External function from items.qc (or wherever AM_InitializeWeaponView and AM_ConsumeAmmo are)
// void(string model_path, float ammo_id_enum, float item_flag_bit) AM_InitializeWeaponView;
// void(float ammo_id_enum, float amount_to_consume) AM_ConsumeAmmo; // For cell consumption

// RAHP Specific Fire Mode Interpretation (maps to self.current_weapon_fire_mode indices)
float RAHP_FIREMODE_IDX_SMALL_LASER = 0; // Corresponds to FIREMODE_IDX_PRIMARY
float RAHP_FIREMODE_IDX_BIG_LASER = 1;   // Corresponds to FIREMODE_IDX_SECONDARY

// Forward declarations
void() w_rahpm1_PrintCurrentMode;
void() W_SwitchModeRahp;

/*
================
w_rahpm1_SetCurrentAmmo
Sets up the RAHP when selected.
================
*/
void() w_rahpm1_SetCurrentAmmo =
{
    // Initialize weapon view. Primary mode doesn't show ammo, secondary shows cells.
    // We'll manage self.currentammo and self.items directly based on the fire mode.
    self.weaponmodel = "progs/v_rahpm1.mdl";

    // Initialize fire modes for RAHP: 2 standard modes, no debug mode.
    AM_InitWeaponFireModes(2, FALSE); 

    // Update ammo display based on the (potentially newly initialized) fire mode.
    if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_BIG_LASER) 
    {
        self.currentammo = self.ammo_cells;
        self.items = self.items | IT_CELLS;
    }
    else // Default to primary mode display (no ammo shown or specific item type)
    {
        self.currentammo = 0; 
        self.items = self.items - (self.items & IT_CELLS); // Ensure IT_CELLS is not set for primary
    }
    w_rahpm1_PrintCurrentMode();
};

/*
================
w_rahpm1_PrintCurrentMode
Helper to print RAHP specific mode name.
================
*/
void() w_rahpm1_PrintCurrentMode =
{
    if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_SMALL_LASER)
        sprint(self, "RAHP: Standard Laser mode\n"); 
    else if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_BIG_LASER)
        sprint(self, "RAHP: Charged Laser mode (Uses Cells)\n"); 
};

/*
================
W_SwitchModeRahp
Handles RAHP fire mode switching.
================
*/
void() W_SwitchModeRahp =
{
    AM_CycleFireMode(); // Call the generic cycle function
    
    // After cycling, update ammo display specifically for RAHP
    if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_BIG_LASER) 
    {
        self.currentammo = self.ammo_cells;
        self.items = self.items | IT_CELLS;
    }
    else 
    {
        self.currentammo = 0;
        self.items = self.items - (self.items & IT_CELLS);
    }
    w_rahpm1_PrintCurrentMode(); // Print RAHP specific message
};

/*
================
W_FireRahp
Handles firing the RAHP based on the current fire mode.
================
*/
void() W_FireRahp =
{
    // Primary fire mode (small laser, no ammo cost)
    if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_SMALL_LASER) 
    {
        self.attack_finished = time + 0.2; // Cooldown for small laser
        // W_am_fire_laser is from am_laser.qc
        // Parameters: laser_type, with_muzzleflash, play_sound
        W_am_fire_laser(LASER_SMALL, FALSE, TRUE); 
    }
    // Secondary fire mode (big laser, costs cells)
    else if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_BIG_LASER)
    {
        // Check for cell ammo
        if (self.ammo_cells < 1)
        {
            // Out of cells, automatically switch to primary mode and notify player
            sprint(self, "RAHP: No cells for charged shot. Switching to standard mode.\n");
            self.current_weapon_fire_mode = RAHP_FIREMODE_IDX_SMALL_LASER;
            // Update ammo display for the new mode
            self.currentammo = 0;
            self.items = self.items - (self.items & IT_CELLS);
            sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM); // Dry fire sound
            self.attack_finished = time + 0.5; // Longer cooldown after failed attempt
            return;
        }

        self.attack_finished = time + 0.6; // Cooldown for big laser
        
        // Consume cell ammo using generic function (if AMMO_ID_CELLS is defined)
        // Or directly: self.currentammo = self.ammo_cells = self.ammo_cells - 1;
        AM_ConsumeAmmo(AMMO_ID_CELLS, 1); // Assuming AMMO_ID_CELLS is defined in am_operations or globally

        W_am_fire_laser(LASER_BIG, FALSE, TRUE); 
    }
};
