//============================================================================
// am_operations.qc
// Contains shared operations for weapon handling
//============================================================================

// --- Ammo ID Constants ---
float AMMO_ID_SHELLS = 1;
float AMMO_ID_NAILS = 2;
float AMMO_ID_ROCKETS = 3;
float AMMO_ID_CELLS = 4;

//============================================================================
// AM_InitializeWeaponView
//============================================================================
void AM_InitializeWeaponView(string model_path, float ammo_id_to_read, float items_flag) {
    self.weaponmodel = model_path;

    if (ammo_id_to_read == AMMO_ID_SHELLS) {
        self.currentammo = self.ammo_shells;
    } else if (ammo_id_to_read == AMMO_ID_NAILS) {
        self.currentammo = self.ammo_nails;
    } else if (ammo_id_to_read == AMMO_ID_ROCKETS) {
        self.currentammo = self.ammo_rockets;
    } else if (ammo_id_to_read == AMMO_ID_CELLS) {
        self.currentammo = self.ammo_cells;
    }
    else {
        self.currentammo = 0;
    }

    if (items_flag != 0) {
        self.items = self.items | items_flag;
    }
}

//============================================================================
// AM_ConsumeAmmo
//============================================================================
void AM_ConsumeAmmo(float ammo_id, float amount_to_consume) {
    if (ammo_id == AMMO_ID_SHELLS) {
        self.ammo_shells = self.ammo_shells - amount_to_consume;
        self.currentammo = self.ammo_shells;
    } else if (ammo_id == AMMO_ID_NAILS) {
        self.ammo_nails = self.ammo_nails - amount_to_consume;
        self.currentammo = self.ammo_nails;
    } else if (ammo_id == AMMO_ID_ROCKETS) {
        self.ammo_rockets = self.ammo_rockets - amount_to_consume;
        self.currentammo = self.ammo_rockets;
    } else if (ammo_id == AMMO_ID_CELLS) {
        self.ammo_cells = self.ammo_cells - amount_to_consume;
        self.currentammo = self.ammo_cells;
    }

    if (self.ammo_shells < 0) { self.ammo_shells = 0; }
    if (self.ammo_nails < 0) { self.ammo_nails = 0; }
    if (self.ammo_rockets < 0) { self.ammo_rockets = 0; }
    if (self.ammo_cells < 0) { self.ammo_cells = 0; }

    if (ammo_id == AMMO_ID_SHELLS) { self.currentammo = self.ammo_shells; }
    else if (ammo_id == AMMO_ID_NAILS) { self.currentammo = self.ammo_nails; }
    else if (ammo_id == AMMO_ID_ROCKETS) { self.currentammo = self.ammo_rockets; }
    else if (ammo_id == AMMO_ID_CELLS) { self.currentammo = self.ammo_cells; }
}

//============================================================================
// AM_InitWeaponFireModes
// Initializes fire mode settings, loading the persisted mode for the current slot.
//============================================================================
void AM_InitWeaponFireModes(float num_standard_modes, float supports_debug_mode)
{
    self.weapon_num_standard_modes = num_standard_modes;
    self.weapon_supports_debug_mode = supports_debug_mode;

    float slot_weapon_id = self.weapon; // self.weapon holds the IT_SLOT_ flag
    float mode_to_load = FIRE_MODE_PRIMARY; // Default to primary

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

    // Validate the loaded mode against the actual capabilities of the *current physical weapon*
    // in this slot. This handles cases where a slot might have stored a mode index
    // that is too high for the weapon currently populating that slot.
    float max_allowed_mode_idx = self.weapon_num_standard_modes - 1; // Max index for standard modes
    if (self.weapon_supports_debug_mode == TRUE && cvar("developer") > 0)
    {
        max_allowed_mode_idx = self.weapon_num_standard_modes; // Debug mode is at index weapon_num_standard_modes
    }
    // Ensure max_allowed_mode_idx is not negative if weapon_num_standard_modes is 0 or 1.
    if (max_allowed_mode_idx < 0) { max_allowed_mode_idx = 0; }


    if (mode_to_load > max_allowed_mode_idx)
    {
        mode_to_load = FIRE_MODE_PRIMARY; // If stored mode is invalid for this weapon, reset to primary
        // And update the stored slot value to this valid default
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
    AM_ResetSustainedRecoil();
}

//============================================================================
// AM_WeaponFrame_HandleFireRelease
//============================================================================
void AM_WeaponFrame_HandleFireRelease()
{
    if (!self.button0) 
    {
        self.weapon_fire_released = TRUE;
    }
}

//============================================================================
// AM_CanFireSemiAuto
//============================================================================
float AM_CanFireSemiAuto()
{
    if (self.weapon_fire_released == TRUE)
    {
        return TRUE; 
    }
    return FALSE; 
}

//============================================================================
// AM_CycleFireMode
// Cycles fire modes and saves the new mode to the current weapon's slot.
//============================================================================
void AM_CycleFireMode()
{
    float num_total_modes_available;
    
    num_total_modes_available = self.weapon_num_standard_modes;

    if (self.weapon_supports_debug_mode == TRUE && cvar("developer") > 0)
    {
        num_total_modes_available = num_total_modes_available + 1;
    }

    if (num_total_modes_available <= 1)
    {
        self.weapon_fire_released = TRUE;
        AM_ResetSustainedRecoil();
        return;
    }
    
    self.current_weapon_fire_mode = self.current_weapon_fire_mode + 1;

    float loop_reset_point;
    if (self.weapon_supports_debug_mode == TRUE && cvar("developer") > 0)
    {
        loop_reset_point = self.weapon_num_standard_modes + 1; 
    }
    else
    {
        loop_reset_point = self.weapon_num_standard_modes;
    }

    if (self.current_weapon_fire_mode >= loop_reset_point)
    {
        self.current_weapon_fire_mode = FIRE_MODE_PRIMARY;
    }
    
    // Save the newly set fire mode to the corresponding slot field
    float current_slot_id = self.weapon; // self.weapon is the IT_SLOT_ flag of the active weapon
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


