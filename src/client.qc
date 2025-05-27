//=============================================================================
// client.qc - FQX Mod - Client Connection, Disconnection, Spawning, Rules
// ##IDSOFT    - ##Quedra: Base code from id Software, Quake Rerelease.
// ##FQXCUSTOM - ##Quedra: Integrated FQX systems (Loadout, Fire Modes, Recoil).
// ##FQXCUSTOM - ##Quedra: Applied KEX compatibility fixes and FQX styling.
// ##Quedra: Version 2.1 - Added 'const' to CheckWaterJump definition. [cite: 190]
// ##Quedra: Version 2.2 - Modified PlayerPreThink to correctly handle ammo checks [cite: 188]
// ##Quedra:                 for FQX magazine weapons before calling W_BestWeapon. [cite: 188]
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text - Original Source ID 6089) [cite: 191]
    See file, 'COPYING', for details. [cite: 191]
*/

//=============================================================================
// ##Quedra: FORWARD DECLARATIONS (Functions used in this file, defined elsewhere or locally below)
//=============================================================================
// --- From standard QuakeC modules (ensure globally declared in defs_*.qc or via progs.src order) ---
void W_WeaponFrame(void); // [cite: 192]
void W_SetCurrentAmmo(void);  // [cite: 193]
void player_pain(entity attacker, float damage);  // [cite: 193]
void player_stand1(void);  // [cite: 193]
void PlayerDie(void);  // [cite: 193]
void set_suicide_frame(void);  // [cite: 193]
void spawn_tfog(vector org); // [cite: 193]
void spawn_tdeath(vector org, entity death_owner);  // [cite: 194]
void T_Damage(entity targ, entity inflictor, entity attacker, float damage);  // [cite: 194]
void CopyToBodyQueue(entity corpse_to_copy);  // [cite: 194]
void InitTrigger(void); // [cite: 194]
void SUB_UseTargets(void);  // [cite: 195]
void SUB_Null(void);  // [cite: 195]
float W_BestWeapon(void);  // [cite: 195]

// --- From FQX Custom Modules (ensure globally declared in defs_2.qc) ---
void Loadout_EncodeParms(entity player); // [cite: 195]
void Loadout_DecodeParms(entity player);  // [cite: 196]
void Loadout_SetDefaults(entity player);  // [cite: 196]
void AM_InitRecoilSystem(void);  // [cite: 196]
void AM_RecoilThink(void);  // [cite: 196]
void AM_ProcessReloadImpulse(void);  // [cite: 196]
void ToggleMonsterCoreDebugPrints(void); // [cite: 196]
float AM_GetAmmoCount(float ammo_id); // ##Quedra: Added for PlayerPreThink, from am_operations.qc

// --- Functions defined locally within this file (client.qc) ---
void() SetChangeParms; // [cite: 197]
void() SetNewParms; // [cite: 197]
void() DecodeLevelParms; // [cite: 197]
entity() FindIntermission; // [cite: 197]
void() GotoNextMap; // [cite: 197]
void() ExitIntermission; // [cite: 198]
void() IntermissionThink; // [cite: 198]
void() execute_changelevel; // [cite: 198]
void() changelevel_touch; // [cite: 198]
void() trigger_changelevel; // [cite: 198]
void() respawn; // [cite: 198]
void() ClientKill; // [cite: 198]
float PlayerVisibleToSpawnPoint(entity point); // [cite: 198]
entity SelectSpawnPoint(float forceSpawn); // [cite: 198]
void() PutClientInServer; // [cite: 199]
void() info_player_start; // [cite: 199]
void() info_player_start2; // [cite: 199]
void() testplayerstart; // [cite: 199]
void() info_player_deathmatch; // [cite: 199]
void() info_player_coop; // [cite: 199]
void() NextLevel; // [cite: 199]
void() CheckRules; // [cite: 199]
void() PlayerDeathThink; // [cite: 199]
void() PlayerJump; // [cite: 199]
void() WaterMove; // [cite: 200]
const void() CheckWaterJump; // ##Quedra: Forward declaration for local function  // [cite: 200]
void() PlayerPreThink; // [cite: 200]
void() CheckPowerups; // [cite: 200]
void() CheckHealthRot; // [cite: 200]
void() PlayerPostThink; // [cite: 200]
void() ClientConnect; // [cite: 201]
void() ClientDisconnect; // [cite: 201]
void(entity targ, entity attacker) ClientObituary; // [cite: 201]
//=============================================================================

//=============================================================================
// ##Quedra: GLOBALISH VARIABLES FOR THIS FILE (from original client.qc)
//=============================================================================
float	modelindex_eyes;  // [cite: 201]
float	modelindex_player; // [cite: 201]
float	intermission_running;  // [cite: 202]
float	intermission_exittime;  // [cite: 202]
float	reset_flag;  // [cite: 202]
string  nextmap;     // [cite: 202]
entity  lastspawn;   // [cite: 202]
//=============================================================================

/*
=============================================================================
                LEVEL CHANGING / INTERMISSION
=============================================================================
*/

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16) */ // [cite: 202]
void() info_intermission = { }; // ##Quedra: Position marker  // [cite: 202]

//-----------------------------------------------------------------------------
// ##Quedra: SetChangeParms 
// ##Quedra: Encodes player state into global parm1-parm15 for level transitions. [cite: 203]
//-----------------------------------------------------------------------------
void() SetChangeParms =
{
    if (reset_flag)  // [cite: 204]
    {
        setspawnparms(self); // [cite: 204]
        return;  // [cite: 205]
    }

    if (self.health <= 0 || deathmatch)  // [cite: 205]
    {
        SetNewParms (); // [cite: 205]
        return;  // [cite: 206]
    }
 
    self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) ); // [cite: 206]
    if (self.health > self.max_health)  // [cite: 207]
    {
        self.health = self.max_health; // [cite: 207]
    }
    if (self.health < self.max_health / 2)   // [cite: 208]
    {
        self.health = self.max_health / 2; // [cite: 208]
    }
    
    parm1 = self.items;  // [cite: 209]
    parm2 = self.health;  // [cite: 209]
    parm3 = self.armorvalue; // [cite: 209]
    if (self.ammo_shells < 25)   // [cite: 210]
    {
        parm4 = 25; // [cite: 210]
    }
    else // [cite: 211]
    {
        parm4 = self.ammo_shells; // [cite: 211]
    }
        
    parm5 = self.ammo_nails;  // [cite: 212]
    parm6 = self.ammo_rockets; // [cite: 212]
    parm7 = self.ammo_cells;  // [cite: 213]
    parm8 = self.weapon;         // [cite: 213]
    parm9 = self.armortype * 100;  // [cite: 213]

    Loadout_EncodeParms(self); // ##FQXCUSTOM  // [cite: 213]
    
    float packed_fire_modes = 0; // ##FQXCUSTOM  // [cite: 215]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_melee     & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_MELEE); // [cite: 215]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_holdout   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_HOLDOUT);  // [cite: 216]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_secondary & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_SECONDARY); // [cite: 216]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_primary   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_PRIMARY); // [cite: 217]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_heavy     & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_HEAVY); // [cite: 218]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_utility   & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_UTILITY); // [cite: 219]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux1      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX1); // [cite: 220]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux2      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX2); // [cite: 221]
    packed_fire_modes = packed_fire_modes + ((self.firemode_slot_aux3      & FIREMODE_PERSIST_MASK) * FIREMODE_PLACE_VALUE_SLOT_AUX3);  // [cite: 222]
    parm15 = packed_fire_modes;  // [cite: 222]
};
//-----------------------------------------------------------------------------
// ##Quedra: SetNewParms 
//-----------------------------------------------------------------------------
void() SetNewParms =
{
    parm1 = IT_SLOT_HOLDOUT | IT_SLOT_MELEE; // ##FQXCUSTOM  // [cite: 223]
    if (skill == 3 && !deathmatch) { parm2 = 50; // [cite: 224]
    } else { parm2 = 100; }  // [cite: 225]
    parm3 = 0; parm4 = 25; // [cite: 225]
    parm5 = 0; parm6 = 0; parm7 = 0;  // [cite: 226]
    parm8 = IT_SLOT_HOLDOUT; // ##FQXCUSTOM  // [cite: 226]
    parm9 = 0; parm10 = 0; parm11 = 0; parm12 = 0; // [cite: 227]
    parm13 = 0; parm14 = 0; parm15 = 0; parm16 = 0; // ##FQXCUSTOM: Init FQX parms  // [cite: 228]
};

//-----------------------------------------------------------------------------
// ##Quedra: DecodeLevelParms 
//-----------------------------------------------------------------------------
void() DecodeLevelParms =
{
    if (serverflags) { if (world.model == "maps/start.bsp") { SetNewParms(); // [cite: 229]
    } }  // [cite: 230]
    self.items = parm1; self.health = parm2; self.armorvalue = parm3; // [cite: 230]
    self.ammo_shells = parm4; self.ammo_nails = parm5; self.ammo_rockets = parm6; self.ammo_cells = parm7; // [cite: 231]
    self.weapon = parm8; self.armortype = parm9 * 0.01; // [cite: 232]
    
    float temp_packed_modes = parm15; // ##FQXCUSTOM  // [cite: 233]
    self.firemode_slot_aux3      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX3)      & FIREMODE_PERSIST_MASK; // [cite: 233]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux3 * FIREMODE_PLACE_VALUE_SLOT_AUX3); // [cite: 234]
    self.firemode_slot_aux2      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX2)      & FIREMODE_PERSIST_MASK; // [cite: 235]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux2 * FIREMODE_PLACE_VALUE_SLOT_AUX2); // [cite: 236]
    self.firemode_slot_aux1      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX1)      & FIREMODE_PERSIST_MASK; // [cite: 237]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux1 * FIREMODE_PLACE_VALUE_SLOT_AUX1); // [cite: 238]
    self.firemode_slot_utility   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_UTILITY)   & FIREMODE_PERSIST_MASK; // [cite: 239]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_utility * FIREMODE_PLACE_VALUE_SLOT_UTILITY); // [cite: 240]
    self.firemode_slot_heavy     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HEAVY)     & FIREMODE_PERSIST_MASK; // [cite: 241]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_heavy * FIREMODE_PLACE_VALUE_SLOT_HEAVY); // [cite: 242]
    self.firemode_slot_primary   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_PRIMARY)   & FIREMODE_PERSIST_MASK; // [cite: 243]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_primary * FIREMODE_PLACE_VALUE_SLOT_PRIMARY); // [cite: 244]
    self.firemode_slot_secondary = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_SECONDARY) & FIREMODE_PERSIST_MASK; // [cite: 245]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_secondary * FIREMODE_PLACE_VALUE_SLOT_SECONDARY); // [cite: 246]
    self.firemode_slot_holdout   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HOLDOUT)   & FIREMODE_PERSIST_MASK; // [cite: 247]
    temp_packed_modes = temp_packed_modes - (self.firemode_slot_holdout * FIREMODE_PLACE_VALUE_SLOT_HOLDOUT); // [cite: 248]
    self.firemode_slot_melee     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_MELEE)     & FIREMODE_PERSIST_MASK; // [cite: 249]
};

//-----------------------------------------------------------------------------
// ##Quedra: Standard level progression logic (FindIntermission, GotoNextMap, etc.) -
//-----------------------------------------------------------------------------
entity() FindIntermission = { local entity spot; // [cite: 250]
local float cyc; spot = find(world, classname, "info_intermission"); if (spot) { cyc = random() * 4; // [cite: 251]
while (cyc > 1) { spot = find(spot, classname, "info_intermission"); if (!spot) { spot = find(world, classname, "info_intermission"); // [cite: 252]
} cyc = cyc - 1; } return spot; } spot = find(world, classname, "info_player_start"); if (spot) { return spot; // [cite: 253]
} spot = find(world, classname, "testplayerstart"); if (spot) { return spot; } objerror("FindIntermission: no spot"); return world; }; // [cite: 254]
void() GotoNextMap = { if (cvar("samelevel")) { changelevel(mapname); } else { changelevel(nextmap); } }; // [cite: 255]
void() ExitIntermission = { if (deathmatch) { GotoNextMap(); return; } intermission_exittime = time + 1; intermission_running = intermission_running + 1; // [cite: 256]
if (intermission_running == 2) { if (world.model == "maps/e1m7.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); // [cite: 257]
if (!cvar("registered")) { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1_shareware"); } else { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1"); } return; // [cite: 258]
} else if (world.model == "maps/e2m6.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e2"); return; // [cite: 259]
} else if (world.model == "maps/e3m6.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e3"); return; // [cite: 260]
} else if (world.model == "maps/e4m7.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e4"); return; } GotoNextMap(); // [cite: 261]
} if (intermission_running == 3) { if (!cvar("registered")) { WriteByte(MSG_ALL, SVC_SELLSCREEN); return; // [cite: 262]
} if ((serverflags & 15) == 15) { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_all_runes"); return; } } GotoNextMap(); }; // [cite: 263]
void() IntermissionThink = { if (time < intermission_exittime) { return; } if (!self.button0 && !self.button1 && !self.button2) { return; // [cite: 264]
} ExitIntermission(); }; // [cite: 265]
void() execute_changelevel = { local entity pos; intermission_running = 1; // [cite: 265]
if (deathmatch) { intermission_exittime = time + 5; } else { intermission_exittime = time + 2; } WriteByte(MSG_ALL, SVC_CDTRACK); // [cite: 266]
WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, 3); pos = FindIntermission(); other = find(world, classname, "player"); // [cite: 267]
while (other != world && other !=world) { other.view_ofs = '0 0 0'; other.angles = other.v_angle = pos.mangle; // [cite: 268]
other.fixangle = TRUE; other.nextthink = time + 0.1; other.think = IntermissionThink; other.takedamage = DAMAGE_NO; other.solid = SOLID_NOT; other.movetype = MOVETYPE_NONE; // [cite: 269]
other.modelindex = 0; setorigin(other, pos.origin); if (skill == 3) { if (other.fired_weapon == 0 && world.model == "maps/e1m1.bsp") { msg_entity = other; // [cite: 270]
WriteByte(MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_PACIFIST"); } if (other.took_damage == 0 && world.model == "maps/e4m6.bsp") { msg_entity = other; WriteByte(MSG_ONE, SVC_ACHIEVEMENT); // [cite: 271]
WriteString(MSG_ONE, "ACH_PAINLESS_MAZE"); } } other = find(other, classname, "player"); } WriteByte(MSG_ALL, SVC_INTERMISSION); // [cite: 272]
if (campaign && world.model == "maps/e1m7.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E1M7"); // [cite: 273]
} else if (campaign && world.model == "maps/e2m6.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E2M6"); // [cite: 274]
} else if (campaign && world.model == "maps/e3m6.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E3M6"); // [cite: 275]
} else if (campaign && world.model == "maps/e4m7.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E4M7"); // [cite: 276]
} if (world.model == "maps/e1m4.bsp" && nextmap == "e1m8") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E1M8"); // [cite: 277]
} else if (world.model == "maps/e2m3.bsp" && nextmap == "e2m7") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E2M7"); // [cite: 278]
} else if (world.model == "maps/e3m4.bsp" && nextmap == "e3m7") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E3M7"); // [cite: 279]
} else if (world.model == "maps/e4m5.bsp" && nextmap == "e4m8") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E4M8"); } }; // [cite: 280]
void() changelevel_touch = { if (other.classname != "player") { return; // [cite: 281]
} if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start"))) { T_Damage(other, self, self, 50000); return; // [cite: 282]
} if (coop || deathmatch) { bprint("$qc_exited ", other.netname, "\n"); } nextmap = self.map; SUB_UseTargets(); // [cite: 283]
if ((self.spawnflags & 1) && (deathmatch == 0)) { GotoNextMap(); return; } self.touch = SUB_Null; self.think = execute_changelevel; // [cite: 284]
self.nextthink = time + 0.1; }; // [cite: 285]
/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION */ // [cite: 286]
void() trigger_changelevel = { if (!self.map) { objerror("changelevel trigger doesn't have map"); } self.netname = "changelevel"; // [cite: 286]
self.killstring = "$qc_ks_tried_leave"; InitTrigger(); self.touch = changelevel_touch; }; // [cite: 287]

//=============================================================================
// ##Quedra: PLAYER GAME EDGE FUNCTIONS 
//=============================================================================
void() respawn = { if (coop) { CopyToBodyQueue(self); // [cite: 287]
setspawnparms(self); PutClientInServer(); } else if (deathmatch) { CopyToBodyQueue(self); SetNewParms(); PutClientInServer(); } else { serverflags = startingserverflags; reset_flag = TRUE; // [cite: 288]
localcmd("changelevel "); localcmd(mapname); localcmd("\n"); } }; // [cite: 289]
void() ClientKill = { bprint("$qc_suicides ", self.netname, "\n"); set_suicide_frame(); self.modelindex = modelindex_player; // [cite: 289]
self.frags = self.frags - 2; respawn(); }; // [cite: 290]
float PlayerVisibleToSpawnPoint(entity point) { local vector spot1, spot2; // [cite: 290]
local entity player = find(world, classname, "player"); while (player) { if (player.health > 0) { spot1 = point.origin + player.view_ofs; // [cite: 291]
spot2 = player.origin + player.view_ofs; traceline(spot1, spot2, TRUE, point); if (trace_fraction >= 1) { return TRUE; // [cite: 292]
} } player = find(player, classname, "player"); } return FALSE; } // [cite: 293]
entity SelectSpawnPoint(float forceSpawn) { local entity spot, thing, spots_list_head; // [cite: 293]
local float numspots, totalspots, pcount, pick_random; numspots = 0; totalspots = 0; spot = find(world, classname, "testplayerstart"); // [cite: 294]
if (spot) { return spot; } if (coop) { lastspawn = find(lastspawn, classname, "info_player_coop"); // [cite: 295]
if (lastspawn == world || !lastspawn) { lastspawn = find(world, classname, "info_player_start"); // [cite: 296]
} if (lastspawn != world && lastspawn) { return lastspawn; } } else if (deathmatch) { spots_list_head = world; // [cite: 297]
spot = find(world, classname, "info_player_deathmatch"); while (spot) { totalspots = totalspots + 1; thing = findradius(spot.origin, IDEAL_DIST_FROM_DM_SPAWN_POINT); pcount = 0; // [cite: 298]
while (thing) { if (thing.classname == "player" && thing.health > 0) { pcount = pcount + 1; // [cite: 299]
} thing = thing.chain; } if (pcount == 0) { if (PlayerVisibleToSpawnPoint(spot)) { pcount = pcount + 1; // [cite: 300]
} } if (pcount == 0) { spot.goalentity = spots_list_head; spots_list_head = spot; numspots = numspots + 1; // [cite: 301]
} spot = find(spot, classname, "info_player_deathmatch"); } if (numspots == 0) { spots_list_head = world; numspots = 0; // [cite: 302]
spot = find(world, classname, "info_player_deathmatch"); while (spot) { thing = findradius(spot.origin, MIN_DIST_FROM_DM_SPAWN_POINT); pcount = 0; // [cite: 303]
while (thing) { if (thing.classname == "player" && thing.health > 0) { pcount = pcount + 1; // [cite: 304]
} thing = thing.chain; } if (pcount == 0) { spot.goalentity = spots_list_head; spots_list_head = spot; // [cite: 305]
numspots = numspots + 1; } spot = find(spot, classname, "info_player_deathmatch"); // [cite: 306]
} } if (!numspots) { if (forceSpawn == FALSE && self.spawn_deferred == 0) { return world; // [cite: 307]
} spot = find(world, classname, "info_player_deathmatch"); if (!spot) { objerror("No info_player_deathmatch spawn points found!"); return world; // [cite: 308]
} if (totalspots > 0) { pick_random = floor(random() * totalspots); } else { pick_random = 0; // [cite: 309]
} while (pick_random > 0 && spot) { spot = find(spot, classname, "info_player_deathmatch"); pick_random = pick_random - 1; // [cite: 310]
} if (!spot) { spot = find(world, classname, "info_player_deathmatch"); } return spot; } pick_random = floor(random() * numspots); // [cite: 311]
spot = spots_list_head; while (pick_random > 0) { spot = spot.goalentity; pick_random = pick_random - 1; } return spot; // [cite: 312]
} if (serverflags) { spot = find(world, classname, "info_player_start2"); if (spot) { return spot; // [cite: 313]
} } spot = find(world, classname, "info_player_start"); if (!spot) { error("PutClientInServer: no info_player_start on level"); } return spot; }; // [cite: 314]
void() PutClientInServer = { local entity spot; self.classname = "player"; if (skill == 3 && !deathmatch) { self.health = 50; // [cite: 315]
} else { self.health = 100; } self.takedamage = DAMAGE_AIM; self.solid = SOLID_SLIDEBOX; self.movetype = MOVETYPE_WALK; self.show_hostile = 0; // [cite: 316]
if (skill == 3 && !deathmatch) { self.max_health = 50; } else { self.max_health = 100; } self.flags = FL_CLIENT; // [cite: 317]
self.air_finished = time + 12; self.dmg = 2; self.super_damage_finished = 0; self.radsuit_finished = 0; self.invisible_finished = 0; self.invincible_finished = 0; // [cite: 318]
self.effects = 0; self.invincible_time = 0; self.healthrot_nextcheck = 0; self.fired_weapon = 0; self.took_damage = 0; self.team = 0; // [cite: 319]
if ( coop ) { self.team = 1; } DecodeLevelParms (); Loadout_DecodeParms(self); // [cite: 320]
if (self.loadout_id_melee == WEAPON_ID_NONE && self.loadout_id_holdout == WEAPON_ID_NONE) { Loadout_SetDefaults(self); } self.weapon_first_draw_init = TRUE; W_SetCurrentAmmo (); AM_InitRecoilSystem(); self.attack_finished = time; // [cite: 321]
self.th_pain = player_pain; self.th_die = PlayerDie; self.deadflag = DEAD_NO; self.pausetime = 0; local float shouldTelefrag; // [cite: 322]
if (self.spawn_deferred > 0 && time >= self.spawn_deferred) { if (cvar("developer") > 0) { dprint("forcing telefrag on this spawn\n"); // [cite: 323]
} shouldTelefrag = TRUE; } else { shouldTelefrag = FALSE; } spot = SelectSpawnPoint(shouldTelefrag); // [cite: 324]
if (spot == world) { self.takedamage = DAMAGE_NO; self.solid = SOLID_NOT; self.movetype = MOVETYPE_NONE; self.deadflag = DEAD_DEAD; setmodel(self, ""); // [cite: 325]
self.view_ofs = '0 0 1'; self.velocity = '0 0 0'; // [cite: 326]
if (self.spawn_deferred == 0) { if (cvar("developer") > 0) { dprint("no spawns available! deferring\n"); } self.spawn_deferred = time + 1; // [cite: 327]
} spot = FindIntermission(); self.angles = self.v_angle = spot.mangle; self.fixangle = TRUE; setorigin(self, spot.origin); self.weaponmodel = ""; self.weaponframe = 0; // [cite: 328]
self.weapon = 0; return; } self.spawn_deferred = 0; setorigin(self, spot.origin + '0 0 1'); self.angles = spot.angles; self.fixangle = TRUE; // [cite: 329]
setmodel(self, "progs/eyes.mdl"); modelindex_eyes = self.modelindex; setmodel(self, "progs/player.mdl"); modelindex_player = self.modelindex; setsize (self, VEC_HULL_MIN, VEC_HULL_MAX); self.view_ofs = '0 0 22'; // [cite: 330]
self.velocity = '0 0 0'; player_stand1 (); if (deathmatch || coop) { makevectorsfixed(self.angles); spawn_tfog (self.origin + v_forward*20); // [cite: 331]
} spawn_tdeath (self.origin, self); stuffcmd(self, "-attack\n"); }; // [cite: 332]
/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) */ void() info_player_start = { }; // [cite: 332]
/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24) */ void() info_player_start2 = { }; // [cite: 333]
/*QUAKED testplayerstart (0 0.5 0.5) (-16 -16 -24) (16 16 24) For regioned levels */ void() testplayerstart = { }; // [cite: 334]
/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24) */ void() info_player_deathmatch = { }; // [cite: 335]
/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) */ void() info_player_coop = { }; // [cite: 336]
void() NextLevel = { local entity o; if (nextmap != string_null && nextmap != "") { return; // [cite: 337]
} if (mapname == "start") { if (!cvar("registered")) { mapname = "e1m1"; // [cite: 338]
} else if (!(serverflags & 1)) { mapname = "e1m1"; serverflags = serverflags | 1; // [cite: 339]
} else if (!(serverflags & 2)) { mapname = "e2m1"; serverflags = serverflags | 2; // [cite: 340]
} else if (!(serverflags & 4)) { mapname = "e3m1"; serverflags = serverflags | 4; // [cite: 341]
} else if (!(serverflags & 8)) { mapname = "e4m1"; serverflags = serverflags - 7; } o = spawn(); // [cite: 342]
o.map = mapname; } else { o = find(world, classname, "trigger_changelevel"); // [cite: 343]
if (!o || mapname == "start") { o = spawn(); o.map = mapname; } } nextmap = o.map; // [cite: 344]
gameover = TRUE; if (o.nextthink < time) { o.think = execute_changelevel; o.nextthink = time + 0.1; } }; // [cite: 345]
void() CheckRules = { local float timelimit; local float fraglimit; if (gameover) { return; // [cite: 346]
} timelimit = cvar("timelimit") * 60; fraglimit = cvar("fraglimit"); if (timelimit > 0 && time >= timelimit) { NextLevel (); // [cite: 347]
return; } if (fraglimit > 0 && self.frags >= fraglimit) { NextLevel (); return; } }; // [cite: 348]
void() PlayerDeathThink = { local float forward; if ((self.flags & FL_ONGROUND)) { forward = vlen(self.velocity); // [cite: 349]
forward = forward - 20; if (forward <= 0) { self.velocity = '0 0 0'; // [cite: 350]
} else { self.velocity = forward * normalize(self.velocity); } } if (self.spawn_deferred != 0) { local entity spot; // [cite: 351]
spot = SelectSpawnPoint(FALSE); if (spot != world || time >= self.spawn_deferred) { respawn(); } return; // [cite: 352]
} if (self.deadflag == DEAD_DEAD) { self.deadflag = DEAD_RESPAWNABLE; return; // [cite: 353]
} if (self.deadflag == DEAD_RESPAWNABLE && (self.button0 || self.button1 || self.button2) ) { respawn(); } }; // [cite: 354]
void() PlayerJump = { if (self.flags & FL_WATERJUMP) { return; // [cite: 355]
} if (self.waterlevel >= 2) { if (self.watertype == CONTENT_WATER) { self.velocity_z = 100; // [cite: 356]
} else if (self.watertype == CONTENT_SLIME) { self.velocity_z = 80; } else { self.velocity_z = 50; // [cite: 357]
} if (self.swim_flag < time) { self.swim_flag = time + 1; // [cite: 358]
if (random() < 0.5) sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM); else sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM); } return; // [cite: 359]
} if (!(self.flags & FL_ONGROUND)) { return; } if ( !(self.flags & FL_JUMPRELEASED) ) { return; // [cite: 360]
} self.flags = self.flags - FL_JUMPRELEASED; self.flags = self.flags - FL_ONGROUND; sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM); // [cite: 361]
self.velocity_z = self.velocity_z + 270; }; 
void() WaterMove = { if (self.movetype == MOVETYPE_NOCLIP) { return; // [cite: 362]
} if (self.health < 0) { return; } if (self.waterlevel != 3) { if (self.air_finished < time) { sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM); // [cite: 363]
} else if (self.air_finished < time + 9) { sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM); // [cite: 364]
} self.air_finished = time + 12; self.dmg = 2; } else if (self.air_finished < time) { if (self.pain_finished < time) { self.dmg = self.dmg + 2; // [cite: 365]
if (self.dmg > 15) { self.dmg = 15; } T_Damage (self, world, world, self.dmg); self.pain_finished = time + 1; // [cite: 366]
} } if (self.waterlevel == 0) { if (self.flags & FL_INWATER) { sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM); // [cite: 367]
self.flags = self.flags - FL_INWATER; } return; } if (self.watertype == CONTENT_LAVA) { if (self.dmgtime < time) { if (self.radsuit_finished > time) { self.dmgtime = time + 1; // [cite: 368]
} else { self.dmgtime = time + 0.2; } T_Damage (self, world, world, 10 * self.waterlevel); // [cite: 369]
} } else if (self.watertype == CONTENT_SLIME) { if (self.dmgtime < time && self.radsuit_finished < time) { self.dmgtime = time + 1; // [cite: 370]
T_Damage (self, world, world, 4 * self.waterlevel); } } if ( !(self.flags & FL_INWATER) ) { if (self.watertype == CONTENT_LAVA) { sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM); // [cite: 371]
} if (self.watertype == CONTENT_WATER) { sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM); // [cite: 372]
} if (self.watertype == CONTENT_SLIME) { sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM); } self.flags = self.flags | FL_INWATER; // [cite: 373]
self.dmgtime = 0; } if (! (self.flags & FL_WATERJUMP) ) { self.velocity = self.velocity * (1 - (0.8 * self.waterlevel * frametime)); // [cite: 374]
} }; 

const void() CheckWaterJump = // ##Quedra: Changed to const to match compiler error expectation  // [cite: 200]
{ 
    local vector start, end;
    makevectorsfixed(self.angles);  // [cite: 376]
    start = self.origin;  // [cite: 376]
    start_z = start_z + 8;  // [cite: 376]
    v_forward_z = 0;  // [cite: 376]
    normalize(v_forward);  // [cite: 376]
    end = start + v_forward * 24; // [cite: 376]
    traceline (start, end, TRUE, self);  // [cite: 377]
    if (trace_fraction < 1)  // [cite: 377]
    { 
        start_z = start_z + self.maxs_z - 8; // [cite: 377]
        end = start + v_forward * 24;         // [cite: 378]
        traceline (start, end, TRUE, self); // [cite: 378]
        if (trace_fraction == 1)  // [cite: 379]
        { 
            self.flags = self.flags | FL_WATERJUMP;  // [cite: 380]
            self.velocity_z = 225;                   // [cite: 380]
            self.flags = self.flags - FL_JUMPRELEASED;  // [cite: 380]
            self.teleport_time = time + 2;  // [cite: 380]
            return; // [cite: 380]
        } 
    } 
}; 

//-----------------------------------------------------------------------------
// ##Quedra: PlayerPreThink - Main per-frame client logic BEFORE physics
// ##Quedra: v2.2 - Modified ammo check logic for FQX magazine weapons.
//-----------------------------------------------------------------------------
void() PlayerPreThink = 
{ 
    if (intermission_running) { IntermissionThink(); return; }  // [cite: 381]
    if (self.view_ofs == '0 0 0') { return; }  // [cite: 382]

    makevectors(self.v_angle); // [cite: 382]
    if (deathmatch || coop) { CheckRules(); }  // [cite: 383]
    
    WaterMove(); // [cite: 383]
    if (self.waterlevel == 2) { CheckWaterJump(); }  // [cite: 384]

    if (self.deadflag >= DEAD_DEAD) { PlayerDeathThink(); return; }  // [cite: 384]
    if (self.deadflag == DEAD_DYING) { return; }  // [cite: 385]

    if (self.button2) { PlayerJump(); }  // [cite: 385]
    else { self.flags = self.flags | FL_JUMPRELEASED; }  // [cite: 386]

    if (time < self.pausetime) { self.velocity = '0 0 0'; }  // [cite: 387]

    // ##FQX - ##Quedra: Handle Manual Reload Impulse
    if (self.impulse == 23)  // [cite: 388]
    {
        AM_ProcessReloadImpulse(); // [cite: 388]
        self.impulse = 0; // [cite: 389]
    }

    // ##FQX - ##Quedra: Handle Monster Core Debug Print Toggle Impulse
    if (self.impulse == 24)  // [cite: 389]
    {
        ToggleMonsterCoreDebugPrints(); // [cite: 389]
        self.impulse = 0; // [cite: 390]
    }
    
    AM_RecoilThink(); // Process recoil recovery [cite: 391]

    // ##FQXCUSTOM - ##Quedra: v2.2 - Refined "out of ammo" check for FQX systems.
    // ##Quedra: This check runs if the player is not attacking and their current weapon might be empty.
    // ##Quedra: It ensures that magazine weapons only trigger W_BestWeapon if truly out of all resources.
    if (time > self.attack_finished && self.weapon != IT_SLOT_MELEE && self.weapon != IT_SLOT_HOLDOUT)  // [cite: 391]
    { 
        local float truly_out_of_ammo = FALSE;
        if (self.current_weapon_max_mag_capacity > 0) // Check if current weapon uses FQX magazine system
        {
            // Magazine weapon is truly out if mag is empty AND cannot reload from global resource
            if (self.weapon_ammo_in_magazine <= 0)
            {
                // Ensure current_weapon_game_ammo_cost_per_round is valid 
                // AND (weapon_ammo_resource_id is validly set by weapon's SetCurrentAmmo AND global ammo for that resource is less than cost)
                if (self.current_weapon_game_ammo_cost_per_round <= 0 || 
                    AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.current_weapon_game_ammo_cost_per_round)
                {
                    truly_out_of_ammo = TRUE;
                }
            }
        }
        else // Standard (non-magazine) weapon
        {
            if (self.currentammo <= 0)
            {
                truly_out_of_ammo = TRUE;
            }
        }

        if (truly_out_of_ammo)
        {
            self.weapon = W_BestWeapon(); // [cite: 391]
            self.weapon_first_draw_init = TRUE;  // [cite: 392]
            W_SetCurrentAmmo();  // [cite: 392]
        }
    } 
    
    if (self.frags > self.loot_fragcheck)  // [cite: 392]
    { 
        self.loot_bonus = self.loot_bonus + (self.frags - self.loot_fragcheck); // [cite: 392]
        self.loot_fragcheck = self.frags;  // [cite: 393]
    } 
};

//-----------------------------------------------------------------------------
// ##Quedra: CheckPowerups, PlayerPostThink, ClientConnect, ClientDisconnect, ClientObituary
//-----------------------------------------------------------------------------
void() CheckPowerups = { if (self.health <= 0) { return; // [cite: 393]
} if (self.invisible_finished > time) { if (self.invisible_sound < time) { sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE); // [cite: 394]
self.invisible_sound = time + ((random() * 3) + 1); } if (self.invisible_finished < time + 3 && self.invisible_finished > time) { if (self.invisible_time == 1) { sprint(self, PRINT_LOW, "$qc_ring_fade\n"); // [cite: 395]
stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM); self.invisible_time = time + 1; // [cite: 396]
} if (self.invisible_time < time) { self.invisible_time = time + 1; stuffcmd (self, "bf\n"); } } self.frame = 0; // [cite: 397]
self.modelindex = modelindex_eyes; } else { if (self.items & IT_INVISIBILITY) { self.items = self.items - IT_INVISIBILITY; } self.invisible_finished = 0; // [cite: 398]
self.invisible_time = 0; self.modelindex = modelindex_player; } if (self.invincible_finished > time) { if (self.invincible_finished < time + 3 && self.invincible_finished > time) { if (self.invincible_time == 1) { sprint(self, PRINT_LOW, "$qc_protection_fade\n"); // [cite: 399]
stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM); self.invincible_time = time + 1; // [cite: 400]
} if (self.invincible_time < time) { self.invincible_time = time + 1; stuffcmd (self, "bf\n"); } } self.effects = self.effects | EF_PENTALIGHT; // [cite: 401]
} else { if (self.items & IT_INVULNERABILITY) { self.items = self.items - IT_INVULNERABILITY; } self.invincible_time = 0; // [cite: 402]
self.invincible_finished = 0; if (self.effects & EF_PENTALIGHT) { self.effects = self.effects - EF_PENTALIGHT; // [cite: 403]
} } if (self.super_damage_finished > time) { if (self.super_damage_finished < time + 3 && self.super_damage_finished > time) { if (self.super_time == 1) { sprint(self, PRINT_LOW, "$qc_quad_fade\n"); // [cite: 404]
stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM); self.super_time = time + 1; // [cite: 405]
} if (self.super_time < time) { self.super_time = time + 1; stuffcmd (self, "bf\n"); } } self.effects = self.effects | EF_QUADLIGHT; // [cite: 406]
} else { if (self.items & IT_QUAD) { self.items = self.items - IT_QUAD; } self.super_damage_finished = 0; // [cite: 407]
self.super_time = 0; if (self.effects & EF_QUADLIGHT) { self.effects = self.effects - EF_QUADLIGHT; // [cite: 408]
} } if (self.radsuit_finished > time) { self.air_finished = time + 12; // [cite: 409]
if (self.radsuit_finished < time + 3 && self.radsuit_finished > time) { if (self.rad_time == 1) { sprint(self, PRINT_LOW, "$qc_biosuit_fade\n"); // [cite: 410]
stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM); self.rad_time = time + 1; // [cite: 411]
} if (self.rad_time < time) { self.rad_time = time + 1; stuffcmd (self, "bf\n"); // [cite: 412]
} } } else { if (self.items & IT_SUIT) { self.items = self.items - IT_SUIT; } self.rad_time = 0; // [cite: 413]
self.radsuit_finished = 0; } }; 
void() CheckHealthRot = { if ( !( self.items & IT_SUPERHEALTH ) ) { return; // [cite: 414]
} if ( self.healthrot_nextcheck > time ) { return; } if ( self.health > self.max_health ) { self.health = self.health - 1; // [cite: 415]
self.healthrot_nextcheck = time + 1; return; } self.items = self.items - ( self.items & IT_SUPERHEALTH ); self.healthrot_nextcheck = 0; }; // [cite: 416]
void() PlayerPostThink = { if ( self.view_ofs == '0 0 0') { return; // [cite: 417]
} if ( self.deadflag ) { return; } W_WeaponFrame (); // [cite: 418]
if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0)) { if (self.watertype == CONTENT_WATER) sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM); // [cite: 419]
else if (self.jump_flag < -650) { T_Damage (self, world, world, 5); sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM); // [cite: 420]
if (self.health <= 0) { self.deathtype = "falling"; } } else sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM); self.jump_flag = 0; // [cite: 421]
} if (!(self.flags & FL_ONGROUND)) { self.jump_flag = self.velocity_z; } CheckPowerups(); CheckHealthRot(); }; // [cite: 422]
void() ClientConnect = { bprint("$qc_entered ", self.netname, "\n"); if (intermission_running) { ExitIntermission (); } }; // [cite: 423]
void() ClientDisconnect = { if (gameover) { return; } bprint("$qc_left_game ", self.netname, " with ", ftos(self.frags), " frags.\n"); // [cite: 424]
sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE); if (self.effects & EF_QUADLIGHT) { self.effects = self.effects - EF_QUADLIGHT; // [cite: 425]
} if (self.effects & EF_PENTALIGHT) { self.effects = self.effects - EF_PENTALIGHT; } set_suicide_frame(); }; // [cite: 426]
void(entity targ, entity attacker) ClientObituary = { local float rnum; local float attackerteam, targteam; attackerteam = attacker.team; // [cite: 427]
targteam = targ.team; rnum = random(); if (targ.classname == "player") { if (attacker.classname == "teledeath") { bprint("$qc_telefragged ", targ.netname, " by ", attacker.owner.netname, "\n"); // [cite: 428]
attacker.owner.frags = attacker.owner.frags + 1; return; } if (attacker.classname == "teledeath2") { bprint("$qc_satans_power ", targ.netname, "\n"); // [cite: 429]
targ.frags = targ.frags - 1; return; } if (attacker.classname == "player") { if (targ == attacker) { attacker.frags = attacker.frags - 1; // [cite: 430]
if (targ.weapon == IT_SLOT_AUX2 && targ.waterlevel > 1) { if (targ.watertype == CONTENT_SLIME) bprint("$qc_discharge_slime ", targ.netname, "\n"); // [cite: 431]
else if (targ.watertype == CONTENT_LAVA) bprint("$qc_discharge_lava ", targ.netname, "\n"); else bprint("$qc_discharge_water ", targ.netname, "\n"); return; // [cite: 432]
} if (targ.weapon == IT_SLOT_UTILITY) bprint("$qc_suicide_pin ", targ.netname, "\n"); else if (rnum > 0.5) bprint("$qc_suicide_bored ", targ.netname, "\n"); // [cite: 433]
else bprint("$qc_suicide_loaded ", targ.netname, "\n"); return; } else if ( (teamplay == 2) && (targteam == attackerteam) && (attackerteam != 0) ) { if (rnum < 0.25) bprint("$qc_ff_teammate ", attacker.netname, "\n"); // [cite: 434]
else if (rnum < 0.50) bprint("$qc_ff_glasses ", attacker.netname, "\n"); else if (rnum < 0.75) bprint("$qc_ff_otherteam ", attacker.netname, "\n"); // [cite: 435]
else bprint("$qc_ff_friend ", attacker.netname, "\n"); attacker.frags = attacker.frags - 1; return; } else { attacker.frags = attacker.frags + 1; // [cite: 436]
if (attacker.weapon == IT_SLOT_MELEE) { bprint("$qc_death_ax ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 437]
} if (attacker.weapon == IT_SLOT_HOLDOUT) { bprint("$qc_death_sg ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 438]
} if (attacker.weapon == IT_SLOT_SECONDARY) { bprint("$qc_death_dbl ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 439]
} if (attacker.weapon == IT_SLOT_PRIMARY) { bprint("$qc_death_nail ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 440]
} if (attacker.weapon == IT_SLOT_HEAVY) { bprint("$qc_death_sng ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 441]
} if (attacker.weapon == IT_SLOT_UTILITY) { if (targ.health < -40) { bprint("$qc_death_gl1 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 442]
} else { bprint("$qc_death_gl2 ", targ.netname, " by ", attacker.netname, "\n"); } return; // [cite: 443]
} if (attacker.weapon == IT_SLOT_AUX1) { if (attacker.super_damage_finished > time && targ.health < -40) { rnum = random(); // [cite: 444]
if (rnum < 0.3) { bprint("$qc_death_rl_quad1 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 445]
} else if (rnum < 0.6) { bprint("$qc_death_rl_quad2 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 446]
} else { bprint("$qc_death_rl1 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 447]
} } else { if (targ.health < -40) { bprint("$qc_death_rl2 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 448]
} else { bprint("$qc_death_rl3 ", targ.netname, " by ", attacker.netname, "\n"); } } return; // [cite: 449]
} if (attacker.weapon == IT_SLOT_AUX2) { if (attacker.waterlevel > 1) { bprint("$qc_death_lg1 ", targ.netname, " by ", attacker.netname, "\n"); // [cite: 450]
if (attacker.invincible_finished > time) { msg_entity = attacker; WriteByte (MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_SURVIVE_DISCHARGE"); // [cite: 451]
} } else bprint("$qc_death_lg2 ", targ.netname, " by ", attacker.netname, "\n"); return; // [cite: 452]
} bprint("$qc_killed_by ", targ.netname, " by ", attacker.netname, "\n"); return; } } else { targ.frags = targ.frags - 1; // [cite: 453]
rnum = targ.watertype; if (rnum == CONTENT_WATER) { if (random() < 0.5) bprint("$qc_death_drown1 ", targ.netname, "\n"); // [cite: 454]
else bprint("$qc_death_drown2 ", targ.netname, "\n"); return; } else if (rnum == CONTENT_SLIME) { if (random() < 0.5) bprint("$qc_death_slime1 ", targ.netname, "\n"); // [cite: 455]
else bprint("$qc_death_slime2 ", targ.netname, "\n"); return; } else if (rnum == CONTENT_LAVA) { if (targ.health < -15) { bprint("$qc_death_lava1 ", targ.netname, "\n"); // [cite: 456]
return; } if (random() < 0.5) bprint("$qc_death_lava2 ", targ.netname, "\n"); else bprint("$qc_death_lava3 ", targ.netname, "\n"); return; // [cite: 457]
} if (attacker.solid == SOLID_BSP && attacker != world) { bprint("$qc_death_squish ", targ.netname, "\n"); return; // [cite: 458]
} if (attacker.killstring != string_null && attacker.killstring != "") { bprint(attacker.killstring, " ", targ.netname, "\n"); return; // [cite: 459]
} if (targ.deathtype == "falling") { targ.deathtype = string_null; bprint("$qc_death_fall ", targ.netname, "\n"); return; } bprint("$qc_death_died ", targ.netname, "\n"); // [cite: 460]
} } }; 

//=============================================================================
// client.qc - FQX Mod - Client Connection, Disconnection, Spawning, Rules - END
// ##IDSOFT    - ##Quedra: Base code from id Software, Quake Rerelease. [cite: 462]
// ##FQXCUSTOM - ##Quedra: Integrated FQX systems (Loadout, Fire Modes, Recoil). [cite: 462]
// ##FQXCUSTOM - ##Quedra: Applied KEX compatibility fixes and FQX styling. [cite: 463]
// ##Quedra: Version 2.2 - Modified PlayerPreThink. [cite: 464]
//=============================================================================