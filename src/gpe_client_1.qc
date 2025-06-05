//=============================================================================
// client.qc - FQX Mod - Client Logic, Player Lifecycle, and Input Handling
// Location: /progs/
// ##FQXCUSTOM - ##Quedra: Version 2.3.1
// ##Quedra: Manages client connection, player state, input, and FQX UI impulse handling.
// ##Quedra: Dependencies: Uses defs_*.qc, op_defs.qc, op_loadout.qc, and various FQX system modules.
// ##Quedra: v2.3.1 - Added dprint debug statements to PlayerPreThink for impulse 30 and UI active checks. Corrected headers/footers.
// ##Quedra: v2.3.0 - Integrated Loadout UI toggle (impulse 30) and input handling in PlayerPreThink.
// ##Quedra: v2.2.0 - Modified PlayerPreThink to correctly handle ammo checks for FQX magazine weapons before calling W_BestWeapon.
// ##Quedra: v2.1.0 - Added 'const' to CheckWaterJump definition.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text - Original Source ID 6089)
    See file, 'COPYING', for details. 
*/

//=============================================================================
// ##Quedra: FORWARD DECLARATIONS (Functions used in this file, defined elsewhere or locally below)
// ##Quedra: This block is preserved as per the user's original client.qc.txt.
// ##Quedra: New UI functions LoadoutUI_Toggle and LoadoutUI_HandleInput are declared in op_defs.qc
// ##Quedra: and expected to be known via progs.src ordering.
//=============================================================================
// --- From standard QuakeC modules (ensure globally declared in defs_*.qc or via progs.src order) ---
void W_WeaponFrame(void);
void W_SetCurrentAmmo(void);
void player_pain(entity attacker, float damage);
void player_stand1(void);
void PlayerDie(void);
void set_suicide_frame(void);
void spawn_tfog(vector org);
void spawn_tdeath(vector org, entity death_owner);
void T_Damage(entity targ, entity inflictor, entity attacker, float damage);
void CopyToBodyQueue(entity corpse_to_copy);
void InitTrigger(void);
void SUB_UseTargets(void);
void SUB_Null(void);
float W_BestWeapon(void);
// --- From FQX Custom Modules (ensure globally declared in defs_2.qc or op_defs.qc) ---
void Loadout_EncodeParms(entity player);
void Loadout_DecodeParms(entity player);
void Loadout_SetDefaults(entity player);
void AM_InitRecoilSystem(void);
void AM_RecoilThink(void);
void AM_ProcessReloadImpulse(void);
void ToggleMonsterCoreDebugPrints(void);
float AM_GetAmmoCount(float ammo_id);
// --- Functions defined locally within this file (client.qc) ---
void() SetChangeParms;
void() SetNewParms;
void() DecodeLevelParms;
entity() FindIntermission;
void() GotoNextMap;
void() ExitIntermission;
void() IntermissionThink;
void() execute_changelevel;
void() changelevel_touch;
void() trigger_changelevel;
void() respawn;
void() ClientKill;
float PlayerVisibleToSpawnPoint(entity point);
entity SelectSpawnPoint(float forceSpawn);
void() PutClientInServer;
void() info_player_start;
void() info_player_start2;
void() testplayerstart;
void() info_player_deathmatch;
void() info_player_coop;
void() NextLevel;
void() CheckRules;
void() PlayerDeathThink;
void() PlayerJump;
void() WaterMove;
const void() CheckWaterJump; // ##Quedra: Forward declaration for local function
void() PlayerPreThink;
void() CheckPowerups;
void() CheckHealthRot;
void() PlayerPostThink;
void() ClientConnect;
void() ClientDisconnect;
void(entity targ, entity attacker) ClientObituary;
//=============================================================================

//=============================================================================
// ##Quedra: GLOBALISH VARIABLES FOR THIS FILE (from original client.qc)
//=============================================================================
float	modelindex_eyes;
float	modelindex_player;
float	intermission_running;
float	intermission_exittime;
float	reset_flag;
string  nextmap;
entity  lastspawn;
//=============================================================================

/*
=============================================================================
                LEVEL CHANGING / INTERMISSION
=============================================================================
*/

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16) */
void() info_intermission = { }; // ##Quedra: Position marker

//-----------------------------------------------------------------------------
// ##Quedra: SetChangeParms 
// ##Quedra: Encodes player state into global parm1-parm15 for level transitions.
//-----------------------------------------------------------------------------
void() SetChangeParms =
{
    if (reset_flag)
    {
        setspawnparms(self);
        return;
    }

    if (self.health <= 0 || deathmatch)
    {
        SetNewParms ();
        return;
    }
 
    self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
    if (self.health > self.max_health)
    {
        self.health = self.max_health;
    }
    if (self.health < self.max_health / 2)
    {
        self.health = self.max_health / 2;
    }
    
    parm1 = self.items;
    parm2 = self.health;
    parm3 = self.armorvalue;
    if (self.ammo_shells < 25)
    {
        parm4 = 25;
    }
    else
    {
        parm4 = self.ammo_shells;
    }
        
    parm5 = self.ammo_nails;
    parm6 = self.ammo_rockets;
    parm7 = self.ammo_cells;
    parm8 = self.weapon;
    parm9 = self.armortype * 100;

    Loadout_EncodeParms(self); // ##FQXCUSTOM
    
    float packed_fire_modes = 0; // ##FQXCUSTOM
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_melee     & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_MELEE);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_holdout   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_HOLDOUT);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_secondary & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_SECONDARY);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_primary   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_PRIMARY);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_heavy     & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_HEAVY);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_utility   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_UTILITY);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux1      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX1);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux2      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX2);
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux3      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX3);
    parm15 = packed_fire_modes;
};
//-----------------------------------------------------------------------------
// ##Quedra: SetNewParms 
//-----------------------------------------------------------------------------
void() SetNewParms =
{
    parm1 = IT_SLOT_HOLDOUT | IT_SLOT_MELEE; // ##FQXCUSTOM
    if (skill == 3 && !deathmatch) { parm2 = 50; } else { parm2 = 100;
    }
    parm3 = 0; parm4 = 25;
    parm5 = 0;
    parm6 = 0; parm7 = 0;
    parm8 = IT_SLOT_HOLDOUT; // ##FQXCUSTOM
    parm9 = 0;
    parm10 = 0;
    parm11 = 0; parm12 = 0;
    parm13 = 0;
    parm14 = 0; parm15 = 0; parm16 = 0; // ##FQXCUSTOM: Init FQX parms
};
//-----------------------------------------------------------------------------
// ##Quedra: DecodeLevelParms 
//-----------------------------------------------------------------------------
void() DecodeLevelParms =
{
    if (serverflags) { if (world.model == "maps/start.bsp") { SetNewParms(); } }
    self.items = parm1;
    self.health = parm2; self.armorvalue = parm3;
    self.ammo_shells = parm4; self.ammo_nails = parm5;
    self.ammo_rockets = parm6; self.ammo_cells = parm7;
    self.weapon = parm8; self.armortype = parm9 * 0.01;
    
    float temp_packed_modes = parm15; // ##FQXCUSTOM
    self.firemode_slot_aux3      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX3)      & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux3 * FIREMODE_PLACE_VALUE_SLOT_AUX3);
    self.firemode_slot_aux2      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX2)      & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux2 * FIREMODE_PLACE_VALUE_SLOT_AUX2);
    self.firemode_slot_aux1      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX1)      & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux1 * FIREMODE_PLACE_VALUE_SLOT_AUX1);
    self.firemode_slot_utility   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_UTILITY)   & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_utility * FIREMODE_PLACE_VALUE_SLOT_UTILITY);
    self.firemode_slot_heavy     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HEAVY)     & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_heavy * FIREMODE_PLACE_VALUE_SLOT_HEAVY);
    self.firemode_slot_primary   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_PRIMARY)   & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_primary * FIREMODE_PLACE_VALUE_SLOT_PRIMARY);
    self.firemode_slot_secondary = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_SECONDARY) & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_secondary * FIREMODE_PLACE_VALUE_SLOT_SECONDARY);
    self.firemode_slot_holdout   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HOLDOUT)   & FIREMODE_PERSIST_MASK;
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_holdout * FIREMODE_PLACE_VALUE_SLOT_HOLDOUT);
    self.firemode_slot_melee     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_MELEE)     & FIREMODE_PERSIST_MASK;
};

//-----------------------------------------------------------------------------
// ##Quedra: Standard level progression logic (FindIntermission, GotoNextMap, etc.) -
//-----------------------------------------------------------------------------
entity() FindIntermission =
{
    local entity spot;
    local float cyc;

    spot = find(world, classname, "info_intermission");
    if (spot)
    {
        cyc = random() * 4;
        while (cyc > 1)
        {
            spot = find(spot, classname, "info_intermission");
            if (!spot)
            {
                spot = find(world, classname, "info_intermission");
            }
            cyc = cyc - 1;
        }
        return spot;
    }
    spot = find(world, classname, "info_player_start");
    if (spot)
    {
        return spot;
    }
    spot = find(world, classname, "testplayerstart");
    if (spot)
    {
        return spot;
    }
    objerror("FindIntermission: no spot");
    return world; // Should not reach here
};

void() GotoNextMap =
{
    if (cvar("samelevel"))
    {
        changelevel(mapname);
    }
    else
    {
        changelevel(nextmap);
    }
};

void() ExitIntermission =
{
    if (deathmatch)
    {
        GotoNextMap();
        return;
    }
    intermission_exittime = time + 1;
    intermission_running = intermission_running + 1;
    if (intermission_running == 2)
    {
        if (world.model == "maps/e1m7.bsp")
        {
            WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3);
            if (!cvar("registered"))
            {
                WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1_shareware");
            }
            else
            {
                WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1");
            }
            return;
        }
        else if (world.model == "maps/e2m6.bsp")
        {
            WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3);
            WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e2");
            return;
        }
        else if (world.model == "maps/e3m6.bsp")
        {
            WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3);
            WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e3");
            return;
        }
        else if (world.model == "maps/e4m7.bsp")
        {
            WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3);
            WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e4");
            return;
        }
        GotoNextMap();
    }
    if (intermission_running == 3)
    {
        if (!cvar("registered"))
        {
            WriteByte(MSG_ALL, SVC_SELLSCREEN);
            return;
        }
        if ((serverflags & 15) == 15)
        {
            WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_all_runes");
            return;
        }
    }
    GotoNextMap();
};

void() IntermissionThink =
{
    if (time < intermission_exittime)
    {
        return;
    }
    if (!self.button0 && !self.button1 && !self.button2)
    {
        return;
    }
    ExitIntermission();
};

void() execute_changelevel =
{
    local entity pos;
    intermission_running = 1;

    if (deathmatch)
    {
        intermission_exittime = time + 5;
    }
    else
    {
        intermission_exittime = time + 2;
    }
    WriteByte(MSG_ALL, SVC_CDTRACK);
    WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, 3);
    pos = FindIntermission();
    other = find(world, classname, "player");
    while (other != world && other != world) // ##Quedra: Original code has 'other !=world' twice. Preserving.
    {
        other.view_ofs = '0 0 0';
        other.angles = other.v_angle = pos.mangle;
        other.fixangle = TRUE;
        other.nextthink = time + 0.1;
        other.think = IntermissionThink;
        other.takedamage = DAMAGE_NO;
        other.solid = SOLID_NOT;
        other.movetype = MOVETYPE_NONE;
        other.modelindex = 0;
        setorigin(other, pos.origin);
        if (skill == 3)
        {
            if (other.fired_weapon == 0 && world.model == "maps/e1m1.bsp")
            {
                msg_entity = other;
                WriteByte(MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_PACIFIST");
            }
            if (other.took_damage == 0 && world.model == "maps/e4m6.bsp")
            {
                msg_entity = other;
                WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
                WriteString(MSG_ONE, "ACH_PAINLESS_MAZE");
            }
        }
        other = find(other, classname, "player");
    }
    WriteByte(MSG_ALL, SVC_INTERMISSION);
    if (campaign && world.model == "maps/e1m7.bsp")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E1M7");
    }
    else if (campaign && world.model == "maps/e2m6.bsp")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E2M6");
    }
    else if (campaign && world.model == "maps/e3m6.bsp")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E3M6");
    }
    else if (campaign && world.model == "maps/e4m7.bsp")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E4M7");
    }
    if (world.model == "maps/e1m4.bsp" && nextmap == "e1m8")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E1M8");
    }
    else if (world.model == "maps/e2m3.bsp" && nextmap == "e2m7")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E2M7");
    }
    else if (world.model == "maps/e3m4.bsp" && nextmap == "e3m7")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E3M7");
    }
    else if (world.model == "maps/e4m5.bsp" && nextmap == "e4m8")
    {
        WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E4M8");
    }
};

void() changelevel_touch =
{
    if (other.classname != "player")
    {
        return;
    }
    if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
    {
        T_Damage(other, self, self, 50000);
        return;
    }
    if (coop || deathmatch)
    {
        bprint("$qc_exited ", other.netname, "\n");
    }
    nextmap = self.map;
    SUB_UseTargets();
    if ((self.spawnflags & 1) && (deathmatch == 0))
    {
        GotoNextMap();
        return;
    }
    self.touch = SUB_Null;
    self.think = execute_changelevel;
    self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION */
void() trigger_changelevel =
{
    if (!self.map)
    {
        objerror("changelevel trigger doesn't have map");
    }
    self.netname = "changelevel";
    self.killstring = "$qc_ks_tried_leave";
    InitTrigger();
    self.touch = changelevel_touch;
};
