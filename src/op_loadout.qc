//=============================================================================
// op_loadout.qc - FQX Mod - Weapon Loadout Configuration
// Location: /src/
// ##FQXCUSTOM - ##Fox: Version 1.4.30 
// ##Fox: Purpose: Removed Loadout UI elements.
// ##FQXCUSTOM - ##Quedra: Version 1.4.29
// ##Quedra: Purpose: Handles weapon loadout configuration, persistence, and the selection UI.
// ##Quedra: Dependencies: Uses WEAPON_ID_* and IT_SLOT_* from core defs (defs_2.qc/defs_3.qc).
// ##Quedra:             Uses functions declared in op_defs.qc.
// ##Quedra: v1.4.29 - Corrected sprint call in LoadoutUI_ConfirmSelection to remove invalid PRINT_HIGH argument.
// ##Quedra: v1.4.28 - Corrected sprint calls in LoadoutUI_Display to remove invalid PRINT_HIGH argument.
// ##Quedra: v1.4.27 - Corrected erroneous sprint call in LoadoutUI_Toggle's deactivation block to use centerprint("", player);
//=============================================================================

//=============================================================================
// ##Quedra: Loadout Persistence Logic
//=============================================================================

/*
====================
Loadout_SetDefaults
====================
*/
// ##FQXCUSTOM - ##Quedra: Setting default loadout for playable test
void Loadout_SetDefaults(entity player) {
    player.loadout_id_melee = WEAPON_ID_AXE;          // Slot 1 (Usually IT_SLOT_MELEE)
    player.loadout_id_holdout = WEAPON_ID_RAHPM1;       // Slot 2 (Usually IT_SLOT_HOLDOUT)
    player.loadout_id_secondary = WEAPON_ID_IZH43;      // Slot 3 (Usually IT_SLOT_SECONDARY)
    player.loadout_id_primary = WEAPON_ID_UMP45;        // Slot 4 (Usually IT_SLOT_PRIMARY)
    player.loadout_id_heavy = WEAPON_ID_AK47;        // Slot 5 (Usually IT_SLOT_HEAVY1)
    player.loadout_id_utility = WEAPON_ID_RL;            // Slot 6 (Usually IT_SLOT_HEAVY2)
    player.loadout_id_aux2 = WEAPON_ID_NONE;       // Slot 7 (Usually IT_SLOT_UTILITY)
    player.loadout_id_aux2 = WEAPON_ID_NONE;          // Slot 8 (Usually IT_SLOT_AUX1)
    player.loadout_id_aux3 = WEAPON_ID_NONE;          // Slot 9 (Usually IT_SLOT_AUX2) // TDD refers to IT_SLOT_AUX3, ensure field names match defs_2.qc

    // ##Quedra: If FQX has a function to force save/apply these immediately after setting, call it here.
    // ##Quedra: Otherwise, these will apply on next map load or player spawn that calls SetDefaults.
    // ##Quedra: Consider if Loadout_EncodeParms() needs to be called if this is for an existing save.
    // ##Quedra: For a quick test, this should suffice for new player spawns.
}

/*
====================
Loadout_EncodeParms
====================
*/
void Loadout_EncodeParms(entity player)
{
    float p13_val, p14_val;

    p13_val = 0;
    p13_val = p13_val + (player.loadout_id_melee     * LOADOUT_PV_P1_SLOT0);
    p13_val = p13_val + (player.loadout_id_holdout   * LOADOUT_PV_P1_SLOT1);
    p13_val = p13_val + (player.loadout_id_secondary * LOADOUT_PV_P1_SLOT2);
    p13_val = p13_val + (player.loadout_id_primary   * LOADOUT_PV_P1_SLOT3);
    p13_val = p13_val + (player.loadout_id_heavy     * LOADOUT_PV_P1_SLOT4);
    p13_val = p13_val + (player.loadout_id_utility   * LOADOUT_PV_P1_SLOT5);
    parm13 = p13_val;

    p14_val = 0;
    p14_val = p14_val + (player.loadout_id_aux1 * LOADOUT_PV_P2_SLOT0);
    p14_val = p14_val + (player.loadout_id_aux2 * LOADOUT_PV_P2_SLOT1);
    p14_val = p14_val + (player.loadout_id_aux3 * LOADOUT_PV_P2_SLOT2);
    parm14 = p14_val;
}

/*
====================
Loadout_DecodeParms
====================
*/
void Loadout_DecodeParms(entity player)
{
    float p13_source, p14_source;
    float temp_val_for_subtraction;

    p13_source = parm13;
    p14_source = parm14;

    player.loadout_id_utility   = floor(p13_source / LOADOUT_PV_P1_SLOT5);
    temp_val_for_subtraction    = player.loadout_id_utility * LOADOUT_PV_P1_SLOT5;
    p13_source                  = p13_source - temp_val_for_subtraction;
    player.loadout_id_heavy     = floor(p13_source / LOADOUT_PV_P1_SLOT4);
    temp_val_for_subtraction    = player.loadout_id_heavy * LOADOUT_PV_P1_SLOT4;
    p13_source                  = p13_source - temp_val_for_subtraction;
    player.loadout_id_primary   = floor(p13_source / LOADOUT_PV_P1_SLOT3);
    temp_val_for_subtraction    = player.loadout_id_primary * LOADOUT_PV_P1_SLOT3;
    p13_source                  = p13_source - temp_val_for_subtraction;
    player.loadout_id_secondary = floor(p13_source / LOADOUT_PV_P1_SLOT2);
    temp_val_for_subtraction    = player.loadout_id_secondary * LOADOUT_PV_P1_SLOT2;
    p13_source                  = p13_source - temp_val_for_subtraction;
    player.loadout_id_holdout   = floor(p13_source / LOADOUT_PV_P1_SLOT1);
    temp_val_for_subtraction    = player.loadout_id_holdout * LOADOUT_PV_P1_SLOT1;
    p13_source                  = p13_source - temp_val_for_subtraction;
    player.loadout_id_melee     = floor(p13_source / LOADOUT_PV_P1_SLOT0);
    
    player.loadout_id_melee     = player.loadout_id_melee     & LOADOUT_WEAPONID_MASK;
    player.loadout_id_holdout   = player.loadout_id_holdout   & LOADOUT_WEAPONID_MASK;
    player.loadout_id_secondary = player.loadout_id_secondary & LOADOUT_WEAPONID_MASK;
    player.loadout_id_primary   = player.loadout_id_primary   & LOADOUT_WEAPONID_MASK;
    player.loadout_id_heavy     = player.loadout_id_heavy     & LOADOUT_WEAPONID_MASK;
    player.loadout_id_utility   = player.loadout_id_utility   & LOADOUT_WEAPONID_MASK;

    player.loadout_id_aux3      = floor(p14_source / LOADOUT_PV_P2_SLOT2);
    temp_val_for_subtraction    = player.loadout_id_aux3 * LOADOUT_PV_P2_SLOT2;
    p14_source                  = p14_source - temp_val_for_subtraction;
    player.loadout_id_aux2      = floor(p14_source / LOADOUT_PV_P2_SLOT1);
    temp_val_for_subtraction    = player.loadout_id_aux2 * LOADOUT_PV_P2_SLOT1;
    p14_source                  = p14_source - temp_val_for_subtraction;
    player.loadout_id_aux1      = floor(p14_source / LOADOUT_PV_P2_SLOT0);
    
    player.loadout_id_aux1      = player.loadout_id_aux1 & LOADOUT_WEAPONID_MASK;
    player.loadout_id_aux2      = player.loadout_id_aux2 & LOADOUT_WEAPONID_MASK;
    player.loadout_id_aux3      = player.loadout_id_aux3 & LOADOUT_WEAPONID_MASK;
}

/*
====================
GetWeaponIDForITSlot
====================
*/
float GetWeaponIDForITSlot(entity player, float it_slot_flag)
{
    if (it_slot_flag == IT_SLOT_MELEE)      { return player.loadout_id_melee; }
    if (it_slot_flag == IT_SLOT_HOLDOUT)    { return player.loadout_id_holdout; }
    if (it_slot_flag == IT_SLOT_SECONDARY)  { return player.loadout_id_secondary; }
    if (it_slot_flag == IT_SLOT_PRIMARY)    { return player.loadout_id_primary; }
    if (it_slot_flag == IT_SLOT_HEAVY)      { return player.loadout_id_heavy; }
    if (it_slot_flag == IT_SLOT_UTILITY)    { return player.loadout_id_utility; }
    if (it_slot_flag == IT_SLOT_AUX1)       { return player.loadout_id_aux1; }
    if (it_slot_flag == IT_SLOT_AUX2)       { return player.loadout_id_aux2; }
    if (it_slot_flag == IT_SLOT_AUX3)       { return player.loadout_id_aux3; }

    dprint("##Quedra GetWeaponIDForITSlot: Warning - Unknown IT_SLOT_ flag: ");
    dprint(ftos(it_slot_flag)); 
    dprint("\n");
    return WEAPON_ID_NONE;
}

//=============================================================================
// ##FQX - ##Quedra: Loadout UI - Data Accessor Implementations
//=============================================================================

string FQX_GetWeaponDisplayName(float weapon_id)
{
    if (weapon_id == WEAPON_ID_UMP45)       { return "UMP-45 SMG"; }
    else if (weapon_id == WEAPON_ID_AK47)   { return "AK-47 Rifle"; }
    else if (weapon_id == WEAPON_ID_IZH43)  { return "IZH-43 Double Barrel"; }
    else if (weapon_id == WEAPON_ID_RAHPM1) { return "RAHP-M1 Pistol"; }
    else if (weapon_id == WEAPON_ID_SAWNOFF){ return "Sawn-off Shotgun"; }
    else if (weapon_id == WEAPON_ID_M93R)   { return "M93R Pistol"; }
    
    dprint("##Quedra FQX_GetWeaponDisplayName: Warning - Unhandled WEAPON_ID: ");
    dprint(ftos(weapon_id));
    dprint("\n");
    return "Unknown Weapon";
}

float FQX_GetWeaponSlotEligibility(float weapon_id)
{
    if (weapon_id == WEAPON_ID_UMP45)       { return IT_SLOT_PRIMARY; }
    else if (weapon_id == WEAPON_ID_AK47)   { return IT_SLOT_PRIMARY; }
    else if (weapon_id == WEAPON_ID_IZH43)  { return IT_SLOT_PRIMARY; }
    else if (weapon_id == WEAPON_ID_RAHPM1) { return IT_SLOT_HOLDOUT; } 
    else if (weapon_id == WEAPON_ID_SAWNOFF){ return IT_SLOT_SECONDARY; }
    else if (weapon_id == WEAPON_ID_M93R)   { return IT_SLOT_HOLDOUT; }
    
    return 0; 
}


//=============================================================================
// op_loadout.qc - FQX Mod - Weapon Loadout Configuration - END
// ##FQXCUSTOM - ##Fox: Version 1.4.30
//=============================================================================