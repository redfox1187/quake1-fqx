//============================================================================
// am_operations.qc
// Contains shared operations for weapon handling
//============================================================================

// --- Ammo ID Constants ---
// These constants are used to identify ammo types in shared functions.
const float AMMO_ID_SHELLS = 1;
const float AMMO_ID_NAILS = 2;
const float AMMO_ID_ROCKETS = 3;
const float AMMO_ID_CELLS = 4;
// Add any custom ammo type IDs here if needed in the future
// const float AMMO_ID_GRENADES = 5; // Example for a custom grenade launcher ammo

//============================================================================
// AM_InitializeWeaponView
// Sets up the player's view model, current ammo count based on the
// active weapon's ammo type, and associated item flags.
//
// Parameters:
// model_path         - The path to the weapon's view model (e.g., "progs/v_shot.mdl")
// ammo_id_to_read    - The AMMO_ID_ constant for the weapon's ammo type
// items_flag         - The IT_ flag associated with the ammo type (e.g., IT_SHELLS)
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
    // --- BEGIN EXAMPLE for custom ammo ---
    // else if (ammo_id_to_read == AMMO_ID_GRENADES) { // If you added custom grenade ammo
    //     self.currentammo = self.ammo_grenades_custom; // Assuming self.ammo_grenades_custom field
    // }
    // --- END EXAMPLE ---
    else {
        // Default or error case: if an unknown ammo_id is passed,
        // you might want to set currentammo to 0 or a default.
        // For simplicity, we'll just log an error if developer console is available.
        // dprint("AM_InitializeWeaponView: Unknown ammo_id_to_read\n");
        self.currentammo = 0; // Or handle as appropriate
    }

    // Update player's item flags to show they possess this type of ammo/weapon capability
    // Ensure items_flag is not 0 to avoid unintentionally modifying flags if no flag is relevant.
    if (items_flag != 0) {
        self.items = self.items | items_flag;
    }
}

//============================================================================
// AM_ConsumeAmmo
// Decrements the specified ammo type for the player and updates self.currentammo.
//
// Parameters:
// ammo_id            - The AMMO_ID_ constant for the ammo type to consume
// amount_to_consume  - The number of ammo units to subtract
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
    // --- BEGIN EXAMPLE for custom ammo ---
    // else if (ammo_id == AMMO_ID_GRENADES) { // If you added custom grenade ammo
    //     self.ammo_grenades_custom = self.ammo_grenades_custom - amount_to_consume;
    //     self.currentammo = self.ammo_grenades_custom;
    // }
    // --- END EXAMPLE ---
    else {
        // Error case or unknown ammo type
        // dprint("AM_ConsumeAmmo: Unknown ammo_id\n");
        // Potentially, do nothing or set currentammo to a known state
    }

    // It's good practice to ensure ammo doesn't go negative,
    // though firing logic should ideally prevent this.
    // This is a safeguard.
    if (self.ammo_shells < 0) { self.ammo_shells = 0; }
    if (self.ammo_nails < 0) { self.ammo_nails = 0; }
    if (self.ammo_rockets < 0) { self.ammo_rockets = 0; }
    if (self.ammo_cells < 0) { self.ammo_cells = 0; }
    // if (self.ammo_grenades_custom < 0) { self.ammo_grenades_custom = 0; } // Example

    // Re-assert currentammo after potential clamping, based on the consumed type
    // This is a bit redundant if clamping never occurs before currentammo is set,
    // but adds robustness.
    if (ammo_id == AMMO_ID_SHELLS) { self.currentammo = self.ammo_shells; }
    else if (ammo_id == AMMO_ID_NAILS) { self.currentammo = self.ammo_nails; }
    else if (ammo_id == AMMO_ID_ROCKETS) { self.currentammo = self.ammo_rockets; }
    else if (ammo_id == AMMO_ID_CELLS) { self.currentammo = self.ammo_cells; }
    // else if (ammo_id == AMMO_ID_GRENADES) { self.currentammo = self.ammo_grenades_custom; } // Example
}

// You would then include this am_operations.qc file in your progs.src
// and call these functions from your weapon code.

/*
Example Usage in a weapon's _SetCurrentAmmo function (e.g., w_shotgun.qc):

void() w_shotgun_SetCurrentAmmo = {
    // ... other setup ...
    AM_InitializeWeaponView("progs/v_shot.mdl", AMMO_ID_SHELLS, IT_SHELLS);
    // ... weapon-specific recoil setup, etc. ...
};

Example Usage in a weapon's fire function (e.g., W_FireShotgun):

void W_FireShotgun() {
    // ... check ammo > 0 ...
    AM_ConsumeAmmo(AMMO_ID_SHELLS, 1);
    // ... rest of firing logic ...
};

For your UMP45 (assuming it uses .ammo_nails and IT_NAILS):
In w_ump45_SetCurrentAmmo:
    AM_InitializeWeaponView("progs/v_ump45.mdl", AMMO_ID_NAILS, IT_NAILS);
    // ...rest of setup...

In W_FireUMP45_Single (or _Burst_Shot, _Auto):
    AM_ConsumeAmmo(AMMO_ID_NAILS, 1);
    // ...rest of firing...

For your DBShot (Double Barrel Shotgun, uses .ammo_shells and IT_SHELLS):
In w_dbshot_SetCurrentAmmo:
    AM_InitializeWeaponView("progs/v_dbshot.mdl", AMMO_ID_SHELLS, IT_SHELLS);
    // ...rest of setup...

In W_FireDBShot:
    // For single barrel
    AM_ConsumeAmmo(AMMO_ID_SHELLS, 1);
    // For double barrel
    // AM_ConsumeAmmo(AMMO_ID_SHELLS, 2); // (called once with 2, or twice with 1 depending on your structure)
*/