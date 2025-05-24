// op_loadout.qc
// Handles weapon loadout configuration and persistence.
// ##Quedra: Core logic for the dynamic weapon loadout system.

/*
====================
Loadout_SetDefaults ##Quedra

Sets a default weapon loadout on the given player entity.
This is called for new games or when persistent loadout data isn't found/is invalid.
The actual weapon IDs assigned here define your mod's starting "default loadout".
====================
*/
void Loadout_SetDefaults(entity player) {
    player.loadout_id_melee     = WEAPON_ID_AXE;
	// player.loadout_id_holdout   = WEAPON_ID_RAHPM1; // This will be the default once the player's select LOADOUT features are implemented.
	//player.loadout_id_holdout   = WEAPON_ID_RAHPM1; // This will be the default once the player's select LOADOUT features are implemented.
	player.loadout_id_holdout   = WEAPON_ID_M93R;
    player.loadout_id_secondary = WEAPON_ID_UMP45;
    player.loadout_id_primary   = WEAPON_ID_DBSHOT;
    player.loadout_id_heavy     = WEAPON_ID_AK47;
    player.loadout_id_utility   = WEAPON_ID_GRAPPLE;
    player.loadout_id_aux1      = WEAPON_ID_RL;
    player.loadout_id_aux2      = WEAPON_ID_LG;
    player.loadout_id_aux3      = WEAPON_ID_NONE;
}

/*
====================
Loadout_EncodeParms ##Quedra

Packs the player's current 'loadout_id_*' fields (which are true entity fields)
into the GLOBAL 'parm13' and 'parm14' variables. These global parms are then
used by the engine for persistence across level changes.
The 'player' entity parameter specifies whose loadout_id_* fields to read.
====================
*/
void Loadout_EncodeParms(entity player) {
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
Loadout_DecodeParms ##Quedra

Unpacks the GLOBAL 'parm13' and 'parm14' (which were restored by the engine
after a level transition or set by SetNewParms) into the 'player' entity's
'loadout_id_*' fields.
====================
*/
void Loadout_DecodeParms(entity player) {
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
GetWeaponIDForITSlot ##Quedra

Given a player and an 'IT_SLOT_*' flag (e.g., IT_SLOT_PRIMARY), 
returns the configured Weapon ID (e.g., WEAPON_ID_DBSHOT)
for that slot from the player's currently decoded loadout fields.
====================
*/
float GetWeaponIDForITSlot(entity player, float it_slot_flag) {
    if (it_slot_flag == IT_SLOT_MELEE) { return player.loadout_id_melee; }
    if (it_slot_flag == IT_SLOT_HOLDOUT) { return player.loadout_id_holdout; }
    if (it_slot_flag == IT_SLOT_SECONDARY) { return player.loadout_id_secondary; }
    if (it_slot_flag == IT_SLOT_PRIMARY) { return player.loadout_id_primary; }
    if (it_slot_flag == IT_SLOT_HEAVY) { return player.loadout_id_heavy; }
    if (it_slot_flag == IT_SLOT_UTILITY) { return player.loadout_id_utility; }
    if (it_slot_flag == IT_SLOT_AUX1) { return player.loadout_id_aux1; }
    if (it_slot_flag == IT_SLOT_AUX2) { return player.loadout_id_aux2; }
    if (it_slot_flag == IT_SLOT_AUX3) { return player.loadout_id_aux3; }

    dprint("##Quedra GetWeaponIDForITSlot: Warning - Unknown IT_SLOT_ flag: "); // This dprint is fine.
    dprint(ftos(it_slot_flag)); 
    dprint("\n");
    return WEAPON_ID_NONE;
}

// ##Quedra: All functions related to Master Loadout Key (cvar input) have been removed.
// ##Quedra: Reverted to core loadout ID persistence logic only.