//=============================================================================
// op_defs.qc - FQX Mod - Definitions for Operational Systems
// Location: /progs/
// ##FQX - ##Quedra: Version 0.1.0
// ##Quedra: Purpose: Centralized definitions for op_* series modules, including the loadout UI system.
// ##Quedra: Dependencies: Relies on defs_2.qc for WEAPON_ID_* and IT_SLOT_* constants (or defs_3.qc for IT_SLOT_*).
// ##Quedra: v0.1.0 - Initial creation. Added Loadout System Data Accessors & UI Core Function forward declarations.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: FQX LOADOUT SYSTEM - DATA ACCESSOR FORWARD DECLARATIONS
//-----------------------------------------------------------------------------

/**
 * ##FQX - ##Quedra: Retrieves the canonical display name for a given FQX weapon ID.
 * Implementation resides in op_loadout.qc.
 * @param weapon_id The WEAPON_ID_* of the weapon.
 * @return The display name string.
 */
string FQX_GetWeaponDisplayName(float weapon_id);

/**
 * ##FQX - ##Quedra: Retrieves the slot eligibility bitmask for a given FQX weapon ID.
 * Implementation resides in op_loadout.qc. Reflects PoC directives for specific weapons.
 * @param weapon_id The WEAPON_ID_* of the weapon.
 * @return A float bitmask (e.g., IT_SLOT_PRIMARY | IT_SLOT_SECONDARY). Returns 0 if not eligible for any slots in PoC context.
 */
float FQX_GetWeaponSlotEligibility(float weapon_id);

//-----------------------------------------------------------------------------
// ##Quedra: FQX LOADOUT UI SYSTEM - HELPER FUNCTIONS
//-----------------------------------------------------------------------------

/**
 * ##FQX - ##Quedra: Retrieves a displayable string name for a given IT_SLOT_* flag.
 * Implementation resides in op_loadout.qc.
 * @param slot_flag The IT_SLOT_* flag.
 * @return A string representing the slot name (e.g., "Primary Slot").
 */
string GetSlotNameFromFlag(float slot_flag);

//-----------------------------------------------------------------------------
// ##Quedra: FQX LOADOUT UI SYSTEM - CORE FUNCTIONS
//-----------------------------------------------------------------------------

/**
 * ##FQX - ##Quedra: Toggles the loadout selection UI for a specific slot.
 * Call this from player input handling.
 * @param player The player entity activating the UI.
 * @param target_slot_flag The IT_SLOT_* flag for which to select a weapon.
 */
void LoadoutUI_Toggle(entity player, float target_slot_flag);

/**
 * ##FQX - ##Quedra: Displays the weapon selection list to the player.
 * Called when the UI is activated or needs refreshing.
 * @param player The player entity for whom to display the UI.
 */
void LoadoutUI_Display(entity player);

/**
 * ##FQX - ##Quedra: Processes player input when the loadout UI is active.
 * Call this from player input handling (e.g., checking self.impulse).
 * @param player The player entity providing input.
 */
void LoadoutUI_HandleInput(entity player);

/**
 * ##FQX - ##Quedra: Finalizes weapon selection and updates the player's loadout.
 * @param player The player entity.
 * @param selected_weapon_id The WEAPON_ID_* of the chosen weapon.
 */
void LoadoutUI_ConfirmSelection(entity player, float selected_weapon_id);

//=============================================================================
// op_defs.qc - FQX Mod - Definitions for Operational Systems - END
// ##FQX - ##Quedra: Version 0.1.0
//=============================================================================