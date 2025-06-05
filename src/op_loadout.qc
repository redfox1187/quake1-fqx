//=============================================================================
// op_loadout.qc - FQX Mod - Weapon Loadout Configuration & UI
// Location: /src/
// ##FQXCUSTOM - ##Quedra: Version 1.4.29
// ##Quedra: Purpose: Handles weapon loadout configuration, persistence, and the selection UI.
// ##Quedra: Dependencies: Uses WEAPON_ID_* and IT_SLOT_* from core defs (defs_2.qc/defs_3.qc).
// ##Quedra:             Uses functions declared in op_defs.qc.
// ##Quedra: v1.4.29 - Corrected sprint call in LoadoutUI_ConfirmSelection to remove invalid PRINT_HIGH argument.
// ##Quedra: v1.4.28 - Corrected sprint calls in LoadoutUI_Display to remove invalid PRINT_HIGH argument.
// ##Quedra: v1.4.27 - Corrected erroneous sprint call in LoadoutUI_Toggle's deactivation block to use centerprint("", player);
// ##Quedra: v1.4.26 - LoadoutUI_Display: Replaced centerprint calls with sprint(PRINT_HIGH, ...) for testing visibility.
//=============================================================================

//=============================================================================
// ##Quedra: Loadout Persistence Logic
//=============================================================================

/*
====================
Loadout_SetDefaults
====================
*/
void Loadout_SetDefaults(entity player)
{
    player.loadout_id_melee     = WEAPON_ID_AXE;
    player.loadout_id_holdout   = WEAPON_ID_M93R;
    player.loadout_id_secondary = WEAPON_ID_SAWNOFF;
    player.loadout_id_primary   = WEAPON_ID_IZH43;
    player.loadout_id_heavy     = WEAPON_ID_AK47;
    player.loadout_id_utility   = WEAPON_ID_GRAPPLE;
    player.loadout_id_aux1      = WEAPON_ID_RL;
    player.loadout_id_aux2      = WEAPON_ID_LG;
    player.loadout_id_aux3      = WEAPON_ID_NONE;
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

//-----------------------------------------------------------------------------
// ##FQX - ##Quedra: Loadout UI - Helper Functions
//-----------------------------------------------------------------------------
string GetSlotNameFromFlag(float slot_flag)
{
    if (slot_flag == IT_SLOT_PRIMARY)       { return "Primary Slot"; }
    if (slot_flag == IT_SLOT_SECONDARY)     { return "Secondary Slot"; }
    if (slot_flag == IT_SLOT_HEAVY)         { return "Heavy Slot"; }
    if (slot_flag == IT_SLOT_HOLDOUT)       { return "Holdout Slot"; }
    if (slot_flag == IT_SLOT_MELEE)         { return "Melee Slot"; }
    if (slot_flag == IT_SLOT_UTILITY)       { return "Utility Slot"; }
    if (slot_flag == IT_SLOT_AUX1)          { return "Auxiliary Slot 1"; }
    if (slot_flag == IT_SLOT_AUX2)          { return "Auxiliary Slot 2"; }
    if (slot_flag == IT_SLOT_AUX3)          { return "Auxiliary Slot 3"; }
    
    dprint("##Quedra GetSlotNameFromFlag: Warning - Unknown slot_flag: ");
    dprint(ftos(slot_flag));
    dprint("\n");
    return "Unknown Slot";
}

//-----------------------------------------------------------------------------
// ##FQX - ##Quedra: Loadout UI - Core Logic
//-----------------------------------------------------------------------------

void LoadoutUI_Toggle(entity player, float target_slot_flag)
{
    dprint("!!!! LoadoutUI_Toggle: FULL LOGIC v1.4.29 DIAGNOSTIC ENTERED !!!!\n"); 

    if (!player) 
    { 
        dprint("LoadoutUI_Toggle (v1.4.29): FATAL - player entity IS NULL ON ENTRY!\n"); 
        return; 
    }
    
    dprint(strcat("LoadoutUI_Toggle (v1.4.29 Info): TSF: ", ftos(target_slot_flag), ", Initial .loadout_ui_active: ", ftos(player.loadout_ui_active), "\n"));
    dprint("LoadoutUI_Toggle (v1.4.29): Pre-logic dprints complete. Evaluating deactivation block...\n");

    if (player.loadout_ui_active == TRUE && 
        (player.loadout_ui_target_slot_flag == target_slot_flag || target_slot_flag == 0))
    {
        dprint("LoadoutUI_Toggle (v1.4.29): Deactivation block ENTERED.\n");
        player.loadout_ui_active = FALSE;
        player.loadout_ui_target_slot_flag = 0;
        player.loadout_ui_item_count = 0;
        centerprint(player, ""); // ##Quedra: Correct way to clear centerprint
        dprint("LoadoutUI_Toggle (v1.4.29): Deactivation COMPLETE. Returning.\n");
        return;
    }
    dprint("LoadoutUI_Toggle (v1.4.29): Deactivation block SKIPPED. Evaluating activation block...\n");

    if (target_slot_flag != 0) 
    {
        dprint("LoadoutUI_Toggle (v1.4.29): Activation block (target_slot_flag != 0) ENTERED.\n");
        dprint(strcat("LoadoutUI_Toggle (v1.4.29): Activating. .loadout_ui_active (was ", ftos(player.loadout_ui_active), ") will be TRUE.\n"));
        player.loadout_ui_active = TRUE; 
        player.loadout_ui_target_slot_flag = target_slot_flag;
        
        if (!player) 
        {
            dprint("LoadoutUI_Toggle (v1.4.29): FATAL - player IS NULL before LoadoutUI_Display!\n");
            return; 
        }
        dprint("LoadoutUI_Toggle (v1.4.29): Valid player. Attempting LoadoutUI_Display.\n"); 
        LoadoutUI_Display(player);
    }
    else 
    {
        dprint("LoadoutUI_Toggle (v1.4.29): Activation ELSE block (target_slot_flag == 0 and UI wasn't already active) ENTERED.\n"); 
        local string s_loadout_active_value_str; 
        s_loadout_active_value_str = ftos(player.loadout_ui_active);
        dprint(strcat("LoadoutUI_Toggle (v1.4.29): .loadout_ui_active was: ", s_loadout_active_value_str, ". No action taken for activation.\n"));
    }
    dprint("LoadoutUI_Toggle (v1.4.29): Function END.\n");
}

// ##FQX - ##Quedra: v1.4.28 - LoadoutUI_Display: Corrected sprint calls
void LoadoutUI_Display(entity player)
{
    dprint("!!!! LoadoutUI_Display: v1.4.28 LOGIC ENTERED (sprint test)!!!!\n"); // ##Quedra: Keeping v1.4.28 in dprint for consistency with the sprint test logic within

    if (!player)
    {
        dprint("LoadoutUI_Display (v1.4.28): ERROR - player entity IS NULL ON ENTRY!\n");
        return;
    }
    if (player.netname != string_null && player.netname != "") { dprint(player.netname); dprint(" is valid player (v1.4.28).\n"); } else {dprint ("Player name not available (v1.4.28).\n");}

    if (player.loadout_ui_active == FALSE)
    {
        dprint("LoadoutUI_Display (v1.4.28): UI not active. Returning early.\n");
        return; 
    }
    dprint("LoadoutUI_Display (v1.4.28): UI is active. Proceeding.\n");
    
    local string display_str; 
    local string temp_weapon_name;
    local float current_weapon_id;
    local float is_eligible_mask;
    local float list_idx;
    local string slot_name_str;
    dprint("LoadoutUI_Display (v1.4.28): Local variables declared.\n");

    player.loadout_ui_item_count = 0;
    player.loadout_ui_item_id_1 = WEAPON_ID_NONE; 
    player.loadout_ui_item_id_2 = WEAPON_ID_NONE;
    player.loadout_ui_item_id_3 = WEAPON_ID_NONE;
    player.loadout_ui_item_id_4 = WEAPON_ID_NONE;
    player.loadout_ui_item_id_5 = WEAPON_ID_NONE;
    list_idx = 0;
    dprint("LoadoutUI_Display (v1.4.28): Player UI fields initialized.\n");

    slot_name_str = GetSlotNameFromFlag(player.loadout_ui_target_slot_flag);
    dprint(strcat("LoadoutUI_Display (v1.4.28): Got slot name: '", slot_name_str, "'. Building header string...\n"));
    
    display_str = strcat("Select Weapon for ", slot_name_str, " (", player.netname, "):\n");
    display_str = strcat(display_str, "----------------------------------\n");
    dprint("LoadoutUI_Display (v1.4.28): Header string built.\n");

    dprint("LoadoutUI_Display (v1.4.28): Starting weapon processing sequence...\n");

    // Simplified dprints within weapon processing
    dprint("LoadoutUI_Display (v1.4.28): Processing UMP45...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_UMP45; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }
    dprint("LoadoutUI_Display (v1.4.28): Processing AK47...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_AK47; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }
    dprint("LoadoutUI_Display (v1.4.28): Processing IZH43...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_IZH43; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }
    dprint("LoadoutUI_Display (v1.4.28): Processing RAHPM1...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_RAHPM1; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }
    dprint("LoadoutUI_Display (v1.4.28): Processing SAWNOFF...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_SAWNOFF; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }
    dprint("LoadoutUI_Display (v1.4.28): Processing M93R...\n");
    if (list_idx < 5) { current_weapon_id = WEAPON_ID_M93R; is_eligible_mask = FQX_GetWeaponSlotEligibility(current_weapon_id); if (is_eligible_mask & player.loadout_ui_target_slot_flag) { list_idx = list_idx + 1; player.loadout_ui_item_count = list_idx; if (list_idx == 1) player.loadout_ui_item_id_1 = current_weapon_id; else if (list_idx == 2) player.loadout_ui_item_id_2 = current_weapon_id; else if (list_idx == 3) player.loadout_ui_item_id_3 = current_weapon_id; else if (list_idx == 4) player.loadout_ui_item_id_4 = current_weapon_id; else if (list_idx == 5) player.loadout_ui_item_id_5 = current_weapon_id; temp_weapon_name = FQX_GetWeaponDisplayName(current_weapon_id); display_str = strcat(display_str, ftos(list_idx), ". ", temp_weapon_name, "\n"); } }

    if (player.loadout_ui_item_count == 0)
    {
        display_str = strcat(display_str, "No eligible weapons for this slot.\n");
    }
    dprint("LoadoutUI_Display (v1.4.28): Finished weapon processing. Building footer.\n");
    
    display_str = strcat(display_str, "----------------------------------\n");
    display_str = strcat(display_str, "Enter # to select, or UI key to close.\n");
    dprint("LoadoutUI_Display (v1.4.28): Footer appended. display_str fully built.\n");
    
    dprint("LoadoutUI_Display (v1.4.28): Attempting SANITY sprint BEFORE actual UI sprint.\n");
    sprint(player, "SPRINT SANITY (v1.4.28)\n"); // Corrected
    dprint("LoadoutUI_Display (v1.4.28): SANITY sprint executed. Now attempting actual UI sprint.\n");
        
    sprint(player, strcat("SPRINT UI for: ", GetSlotNameFromFlag(player.loadout_ui_target_slot_flag), "\n")); // Corrected
    dprint("LoadoutUI_Display (v1.4.28): Actual UI sprint called. Function END.\n");
}

//-----------------------------------------------------------------------------
// ##FQX - ##Quedra: Loadout UI - Input & Confirmation Logic
//-----------------------------------------------------------------------------

void LoadoutUI_HandleInput(entity player)
{
    local float selection_impulse;
    local float selected_weapon_id;

    if (player.loadout_ui_active == FALSE)
    {
        return; 
    }

    selection_impulse = player.impulse;
    if (selection_impulse >= 1 && selection_impulse <= player.loadout_ui_item_count)
    {
        if (selection_impulse == 1)         { selected_weapon_id = player.loadout_ui_item_id_1; }
        else if (selection_impulse == 2)    { selected_weapon_id = player.loadout_ui_item_id_2; }
        else if (selection_impulse == 3)    { selected_weapon_id = player.loadout_ui_item_id_3; }
        else if (selection_impulse == 4)    { selected_weapon_id = player.loadout_ui_item_id_4; } 
        else if (selection_impulse == 5)    { selected_weapon_id = player.loadout_ui_item_id_5; } 
        else                                { selected_weapon_id = WEAPON_ID_NONE; }

        if (selected_weapon_id != WEAPON_ID_NONE)
        {
            LoadoutUI_ConfirmSelection(player, selected_weapon_id);
        }
        player.impulse = 0; 
    }
}

void LoadoutUI_ConfirmSelection(entity player, float selected_weapon_id)
{
    local string weapon_name;
    local string slot_name;

    if (selected_weapon_id == WEAPON_ID_NONE)
    {
        sprint(player, "Invalid selection.\n"); 
        LoadoutUI_Toggle(player, 0); 
        return;
    }

    if (player.loadout_ui_target_slot_flag == IT_SLOT_PRIMARY)
    {
        player.loadout_id_primary = selected_weapon_id;
    } 
    else
    {
        dprint("##Quedra LoadoutUI_ConfirmSelection: Error - UI was active for an unhandled slot_flag: ");
        dprint(ftos(player.loadout_ui_target_slot_flag));
        dprint("\n");
        LoadoutUI_Toggle(player, 0); 
        return;
    }
    
    weapon_name = FQX_GetWeaponDisplayName(selected_weapon_id);
    slot_name = GetSlotNameFromFlag(player.loadout_ui_target_slot_flag);
    sprint(player, strcat(weapon_name, " selected for ", slot_name, "!\n")); // Corrected 
    dprint(strcat("LoadoutUI_ConfirmSelection: Confirmed: ", weapon_name, " for ", slot_name, "\n")); // Added dprint for confirmation

    LoadoutUI_Toggle(player, 0);
}

//=============================================================================
// op_loadout.qc - FQX Mod - Weapon Loadout Configuration & UI - END
// ##FQXCUSTOM - ##Quedra: Version 1.4.29
//=============================================================================