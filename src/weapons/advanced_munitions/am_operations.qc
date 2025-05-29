//============================================================================
// am_operations.qc
// Contains shared operations for weapon handling, selection, and mode cycling.
// ##Quedra: Version 2.4 - Universal Debug Mode logic. Burst functions moved to am_firemodes.qc.
//============================================================================

//============================================================================
// AM_GetAmmoCount
// ##Quedra: Returns the current ammo count for a given ammo resource ID.
//============================================================================
float AM_GetAmmoCount(float ammo_id)
{
    if (ammo_id == AMMO_ID_SHELLS) { return self.ammo_shells; }
    else if (ammo_id == AMMO_ID_NAILS) { return self.ammo_nails; }
    else if (ammo_id == AMMO_ID_ROCKETS) { return self.ammo_rockets; }
    else if (ammo_id == AMMO_ID_CELLS) { return self.ammo_cells; }
    return 0; 
}

//============================================================================
// AM_InitializeWeaponView
// ##Quedra: Sets weapon model and current ammo display based on weapon's primary ammo type.
//============================================================================
void AM_InitializeWeaponView(string model_path, float ammo_id_to_read, float items_flag) 
{
    self.weaponmodel = model_path;
    if (ammo_id_to_read == AMMO_ID_SHELLS) { self.currentammo = self.ammo_shells; }
    else if (ammo_id_to_read == AMMO_ID_NAILS) { self.currentammo = self.ammo_nails; }
    else if (ammo_id_to_read == AMMO_ID_ROCKETS) { self.currentammo = self.ammo_rockets; }
    else if (ammo_id_to_read == AMMO_ID_CELLS) { self.currentammo = self.ammo_cells; }
    else { self.currentammo = 0; } // Should ideally not happen with valid ID

    if (items_flag != 0) { self.items = self.items | items_flag; }
}

//============================================================================
// AM_ConsumeAmmo
// ##Quedra: Deducts specified amount from the given ammo resource and updates currentammo.
//============================================================================
void AM_ConsumeAmmo(float ammo_id, float amount_to_consume) 
{
    if (ammo_id == AMMO_ID_SHELLS) {
        self.ammo_shells = self.ammo_shells - amount_to_consume;
        if (self.ammo_shells < 0) { self.ammo_shells = 0; }
        self.currentammo = self.ammo_shells;
    } else if (ammo_id == AMMO_ID_NAILS) {
        self.ammo_nails = self.ammo_nails - amount_to_consume;
        if (self.ammo_nails < 0) { self.ammo_nails = 0; }
        self.currentammo = self.ammo_nails;
    } else if (ammo_id == AMMO_ID_ROCKETS) {
        self.ammo_rockets = self.ammo_rockets - amount_to_consume;
        if (self.ammo_rockets < 0) { self.ammo_rockets = 0; }
        self.currentammo = self.ammo_rockets;
    } else if (ammo_id == AMMO_ID_CELLS) {
        self.ammo_cells = self.ammo_cells - amount_to_consume;
        if (self.ammo_cells < 0) { self.ammo_cells = 0; }
        self.currentammo = self.ammo_cells;
    }
}

//============================================================================
// AM_InitWeaponFireModes
// ##Quedra: Version 2.4 - Initializes fire mode based on persisted slot preference.
// ##Quedra: Debug mode is universally available if cvar("developer") > 0.
// ##Quedra: The 'supports_debug_mode_flag' parameter was removed.
//============================================================================
void AM_InitWeaponFireModes(float num_standard_modes)
{
    self.weapon_num_standard_modes = num_standard_modes;
    // ##Quedra: self.weapon_supports_debug_mode field is no longer used by this system.

    float slot_weapon_id = self.weapon; 
    float mode_to_load = FIRE_MODE_PRIMARY; 

    // Load the stored fire mode for the current weapon's slot
    if (slot_weapon_id == IT_SLOT_MELEE) { mode_to_load = self.firemode_slot_melee; }
    else if (slot_weapon_id == IT_SLOT_HOLDOUT) { mode_to_load = self.firemode_slot_holdout; }
    else if (slot_weapon_id == IT_SLOT_SECONDARY) { mode_to_load = self.firemode_slot_secondary; }
    else if (slot_weapon_id == IT_SLOT_PRIMARY) { mode_to_load = self.firemode_slot_primary; }
    else if (slot_weapon_id == IT_SLOT_HEAVY) { mode_to_load = self.firemode_slot_heavy; }
    else if (slot_weapon_id == IT_SLOT_UTILITY) { mode_to_load = self.firemode_slot_utility; }
    else if (slot_weapon_id == IT_SLOT_AUX1) { mode_to_load = self.firemode_slot_aux1; }
    else if (slot_weapon_id == IT_SLOT_AUX2) { mode_to_load = self.firemode_slot_aux2; }
    else if (slot_weapon_id == IT_SLOT_AUX3) { mode_to_load = self.firemode_slot_aux3; }

    float max_standard_mode_idx = self.weapon_num_standard_modes - 1;
    if (max_standard_mode_idx < 0) { max_standard_mode_idx = 0; } 

    float debug_mode_idx_for_this_weapon = self.weapon_num_standard_modes; // Debug mode is at this index
    local float original_loaded_mode = mode_to_load; 

    if (cvar("developer") > 0)
    {
        // Debug mode is potentially available
        if (mode_to_load != debug_mode_idx_for_this_weapon && mode_to_load > max_standard_mode_idx)
        {
            // Loaded mode is not this weapon's debug index AND is out of standard bounds
            mode_to_load = FIRE_MODE_PRIMARY;
        }
        // If mode_to_load == debug_mode_idx_for_this_weapon, it's a valid debug mode selection.
        // If mode_to_load <= max_standard_mode_idx, it's a valid standard mode.
    }
    else
    {
        // Debug mode is NOT available (developer cvar is 0)
        if (mode_to_load == debug_mode_idx_for_this_weapon) // Was saved as debug, but dev cvar is off
        {
            mode_to_load = FIRE_MODE_PRIMARY;
        }
        else if (mode_to_load > max_standard_mode_idx) 
        {
            // Loaded mode is out of standard bounds (and cannot be debug)
            mode_to_load = FIRE_MODE_PRIMARY;
        }
    }
    
    // If mode_to_load was defaulted, update the persisted slot value
    if (mode_to_load != original_loaded_mode)
    {
        if (slot_weapon_id == IT_SLOT_MELEE) { self.firemode_slot_melee = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_HOLDOUT) { self.firemode_slot_holdout = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_SECONDARY) { self.firemode_slot_secondary = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_PRIMARY) { self.firemode_slot_primary = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_HEAVY) { self.firemode_slot_heavy = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_UTILITY) { self.firemode_slot_utility = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_AUX1) { self.firemode_slot_aux1 = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_AUX2) { self.firemode_slot_aux2 = mode_to_load; }
        else if (slot_weapon_id == IT_SLOT_AUX3) { self.firemode_slot_aux3 = mode_to_load; }
    }
    
    self.current_weapon_fire_mode = mode_to_load;
    self.weapon_fire_released = TRUE;
    AM_ResetSustainedRecoil(); // Assumes AM_ResetSustainedRecoil is defined (e.g. in am_recoil.qc)
}

//============================================================================
// AM_WeaponFrame_HandleFireRelease
// ##Quedra: Sets weapon_fire_released to TRUE if fire button is not held.
//============================================================================
void AM_WeaponFrame_HandleFireRelease()
{
    if (!self.button0) { self.weapon_fire_released = TRUE; }
}

//============================================================================
// AM_CanFireSemiAuto
// ##Quedra: Checks if a semi-automatic (or first shot of burst/auto) can be fired.
//============================================================================
float AM_CanFireSemiAuto()
{
    if (self.weapon_fire_released == TRUE) { return TRUE; }
    return FALSE; 
}

//============================================================================
// AM_CycleFireMode
// ##Quedra: Version 2.4 - Cycles to dynamic debug index self.weapon_num_standard_modes.
// ##Quedra: Debug mode availability depends only on cvar("developer").
//============================================================================
void AM_CycleFireMode()
{
    float num_std_modes = self.weapon_num_standard_modes;
    float developer_active = (cvar("developer") > 0);
    float debug_idx = num_std_modes; // The index for debug mode for this weapon (e.g., if 2 std modes, debug is index 2)

    // ##Quedra: Determine if this weapon effectively has more than one mode to cycle through
    float total_possible_modes = num_std_modes;
    if (developer_active) { total_possible_modes = num_std_modes + 1; } // (or just num_std_modes if num_std_modes already includes the conceptual slot for debug)
                                                                    // Let's be clearer: if num_std_modes is 2 (0,1), debug_idx is 2. Total distinct values are 3.
    
    if (num_std_modes == 0 && !developer_active) { self.current_weapon_fire_mode = 0; return; } // Weapon has 0 modes, no debug
    if (num_std_modes == 1 && !developer_active) { self.current_weapon_fire_mode = 0; return; } // Weapon has 1 mode (0), no debug

    // ##Quedra: Current state determination
    float current_is_debug = (self.current_weapon_fire_mode == debug_idx && developer_active);
    float current_is_last_standard = (self.current_weapon_fire_mode == (num_std_modes - 1));
    if (num_std_modes == 0) { current_is_last_standard = FALSE; } // Avoids index -1 if num_std_modes is 0.

    // ##Quedra: Cycling logic
    if (current_is_debug) 
    {
        self.current_weapon_fire_mode = FIRE_MODE_PRIMARY; // Cycle from debug to primary
    }
    else if (current_is_last_standard) // Current is the last standard mode
    {
        if (developer_active)
        {
            self.current_weapon_fire_mode = debug_idx; // Go to this weapon's debug mode index
        }
        else
        {
            self.current_weapon_fire_mode = FIRE_MODE_PRIMARY; // No debug, cycle back to primary
        }
    }
    else // Current mode is a standard mode but not the last one (or num_std_modes is 0 but dev is active)
    {
        if (num_std_modes > 0 && self.current_weapon_fire_mode < (num_std_modes - 1) )
        {
             self.current_weapon_fire_mode = self.current_weapon_fire_mode + 1; // Next standard mode
        }
        else if (developer_active) // Only option left is debug (e.g. current was 0, num_std_modes was 0 or 1)
        {
             self.current_weapon_fire_mode = debug_idx;
        }
        else // Fallback: should be only FIRE_MODE_PRIMARY if num_std_modes is 1 and no dev
        {
            self.current_weapon_fire_mode = FIRE_MODE_PRIMARY;
        }
    }
    
    // Save the newly set fire mode
    float current_slot_id = self.weapon; 
    if (current_slot_id == IT_SLOT_MELEE) { self.firemode_slot_melee = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_HOLDOUT) { self.firemode_slot_holdout = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_SECONDARY) { self.firemode_slot_secondary = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_PRIMARY) { self.firemode_slot_primary = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_HEAVY) { self.firemode_slot_heavy = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_UTILITY) { self.firemode_slot_utility = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_AUX1) { self.firemode_slot_aux1 = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_AUX2) { self.firemode_slot_aux2 = self.current_weapon_fire_mode; }
    else if (current_slot_id == IT_SLOT_AUX3) { self.firemode_slot_aux3 = self.current_weapon_fire_mode; }

    self.weapon_fire_released = TRUE;
    AM_ResetSustainedRecoil();        
}

// ##Quedra: Burst fire functions (AM_StartBurstFire, AM_Burst_Think) have been MOVED to am_firemodes.qc