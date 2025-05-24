//=============================================================================
// client.qc - FQX Mod - Client Connection, Disconnection, Spawning, Rules
// ##IDSOFT    - ##Quedra: Base code from id Software, Quake Rerelease.
// ##FQXCUSTOM - ##Quedra: Integrated FQX systems (Loadout, Fire Modes, Recoil).
// ##FQXCUSTOM - ##Quedra: Applied KEX compatibility fixes and FQX styling.
// ##Quedra: Version 1.7 - Uses KEX standard EF_QUADLIGHT & EF_PENTALIGHT. Mitigated opcode errors.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text from client.qc Source ID 6089)
    See file, 'COPYING', for details.
*/

//=============================================================================
// ##Quedra: FORWARD DECLARATIONS (Functions used in this file, defined elsewhere)
//=============================================================================
// --- From standard QuakeC modules (ensure globally declared, e.g., in defs_2.qc or via progs.src order) ---
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

// --- From FQX Custom Modules (ensure globally declared, e.g., in defs_2.qc) ---
void Loadout_EncodeParms(entity player);
void Loadout_DecodeParms(entity player);
void Loadout_SetDefaults(entity player);
void AM_InitRecoilSystem(void);
void AM_RecoilThink(void);
//=============================================================================

//=============================================================================
// ##Quedra: GLOBALISH VARIABLES FOR THIS FILE
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
    if (skill == 3 && !deathmatch) { parm2 = 50; } else { parm2 = 100; }
    parm3 = 0; parm4 = 25; parm5 = 0; parm6 = 0; parm7 = 0; 
    parm8 = IT_SLOT_HOLDOUT; // ##FQXCUSTOM
    parm9 = 0; parm10 = 0; parm11 = 0; parm12 = 0; 
    parm13 = 0; parm14 = 0; parm15 = 0; parm16 = 0; // ##FQXCUSTOM: Init FQX parms
};

//-----------------------------------------------------------------------------
// ##Quedra: DecodeLevelParms
//-----------------------------------------------------------------------------
void() DecodeLevelParms =
{
    if (serverflags) { if (world.model == "maps/start.bsp") { SetNewParms (); } }
    self.items = parm1; self.health = parm2; self.armorvalue = parm3;
    self.ammo_shells = parm4; self.ammo_nails = parm5; self.ammo_rockets = parm6; self.ammo_cells = parm7;
    self.weapon = parm8; self.armortype = parm9 * 0.01;

    float temp_packed_modes = parm15; // ##FQXCUSTOM
    self.firemode_slot_aux3      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX3)      & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux3 * FIREMODE_PLACE_VALUE_SLOT_AUX3);
    self.firemode_slot_aux2      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX2)      & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux2 * FIREMODE_PLACE_VALUE_SLOT_AUX2);
    self.firemode_slot_aux1      = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_AUX1)      & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_aux1 * FIREMODE_PLACE_VALUE_SLOT_AUX1);
    self.firemode_slot_utility   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_UTILITY)   & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_utility * FIREMODE_PLACE_VALUE_SLOT_UTILITY);
    self.firemode_slot_heavy     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HEAVY)     & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_heavy * FIREMODE_PLACE_VALUE_SLOT_HEAVY);
    self.firemode_slot_primary   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_PRIMARY)   & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_primary * FIREMODE_PLACE_VALUE_SLOT_PRIMARY);
    self.firemode_slot_secondary = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_SECONDARY) & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_secondary * FIREMODE_PLACE_VALUE_SLOT_SECONDARY);
    self.firemode_slot_holdout   = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_HOLDOUT)   & FIREMODE_PERSIST_MASK; temp_packed_modes = temp_packed_modes - (self.firemode_slot_holdout * FIREMODE_PLACE_VALUE_SLOT_HOLDOUT);
    self.firemode_slot_melee     = floor(temp_packed_modes / FIREMODE_PLACE_VALUE_SLOT_MELEE)     & FIREMODE_PERSIST_MASK;
};

//-----------------------------------------------------------------------------
// ##Quedra: FindIntermission, GotoNextMap, ExitIntermission, IntermissionThink, execute_changelevel, changelevel_touch, trigger_changelevel
// ##Quedra: Standard level progression logic, adapted from QRRQC-client.qc
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
			if (!spot) { spot = find(world, classname, "info_intermission"); } // Restart search if end of chain
			cyc = cyc - 1;
		}
		return spot;
	}
	spot = find(world, classname, "info_player_start");
	if (spot) { return spot; }
	spot = find(world, classname, "testplayerstart");
	if (spot) { return spot; }
	objerror("FindIntermission: no spot");
	return world;
};

void() GotoNextMap =
{
	if (cvar("samelevel")) { changelevel(mapname); }
	else { changelevel(nextmap); }
};

void() ExitIntermission =
{
	if (deathmatch) { GotoNextMap(); return; }
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); if (!cvar("registered")) { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1_shareware"); } else { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e1"); } return; }
		else if (world.model == "maps/e2m6.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e2"); return; }
		else if (world.model == "maps/e3m6.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e3"); return; }
		else if (world.model == "maps/e4m7.bsp") { WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 2); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_e4"); return; }
		GotoNextMap();
	}
	if (intermission_running == 3)
	{
		if (!cvar("registered")) { WriteByte(MSG_ALL, SVC_SELLSCREEN); return; }
		if ((serverflags & 15) == 15) { WriteByte(MSG_ALL, SVC_FINALE); WriteString(MSG_ALL, "$qc_finale_all_runes"); return; }
	}
	GotoNextMap();
};

void() IntermissionThink =
{
	if (time < intermission_exittime) { return; }
	if (!self.button0 && !self.button1 && !self.button2) { return; }
	ExitIntermission();
};

void() execute_changelevel =
{
	local entity pos;
	intermission_running = 1;
	if (deathmatch) { intermission_exittime = time + 5; } else { intermission_exittime = time + 2; }
	WriteByte(MSG_ALL, SVC_CDTRACK); WriteByte(MSG_ALL, 3); WriteByte(MSG_ALL, 3);
	pos = FindIntermission();
	other = find(world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0'; other.angles = other.v_angle = pos.mangle; other.fixangle = TRUE;
		other.nextthink = time + 0.1; // QRRQC uses 0.5, KEX client.qc might use 0.01 and set other.think to IntermissionThink
		other.takedamage = DAMAGE_NO; other.solid = SOLID_NOT; other.movetype = MOVETYPE_NONE;
		other.modelindex = 0; setorigin(other, pos.origin);
		if (skill == 3) {
			if (other.fired_weapon == 0 && world.model == "maps/e1m1.bsp") { msg_entity = other; WriteByte(MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_PACIFIST"); }
			if (other.took_damage == 0 && world.model == "maps/e4m6.bsp") { msg_entity = other; WriteByte(MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_PAINLESS_MAZE"); }
		}
		other = find(other, classname, "player");
	}
	WriteByte(MSG_ALL, SVC_INTERMISSION);
	if (campaign && world.model == "maps/e1m7.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E1M7"); }
	else if (campaign && world.model == "maps/e2m6.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E2M6"); }
	else if (campaign && world.model == "maps/e3m6.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E3M6"); }
	else if (campaign && world.model == "maps/e4m7.bsp") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_COMPLETE_E4M7"); }
	if (world.model == "maps/e1m4.bsp" && nextmap == "e1m8") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E1M8"); }
	else if (world.model == "maps/e2m3.bsp" && nextmap == "e2m7") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E2M7"); }
	else if (world.model == "maps/e3m4.bsp" && nextmap == "e3m7") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E3M7"); }
	else if (world.model == "maps/e4m5.bsp" && nextmap == "e4m8") { WriteByte(MSG_ALL, SVC_ACHIEVEMENT); WriteString(MSG_ALL, "ACH_FIND_E4M8"); }
};

void() changelevel_touch =
{
	if (other.classname != "player") { return; }
	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start"))) { T_Damage(other, self, self, 50000); return; }
	if (coop || deathmatch) { bprint("$qc_exited", other.netname); }
	nextmap = self.map;
	SUB_UseTargets();
	if ((self.spawnflags & 1) && (deathmatch == 0)) { GotoNextMap(); return; } // NO_INTERMISSION
	self.touch = SUB_Null;
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION */
void() trigger_changelevel =
{
	if (!self.map) { objerror("changelevel trigger doesn't have map"); }
	self.netname = "changelevel";
	self.killstring = "$qc_ks_tried_leave";
	InitTrigger();
	self.touch = changelevel_touch;
};

//=============================================================================
// PLAYER GAME EDGE FUNCTIONS
//=============================================================================
void() respawn =
{
	if (coop) { CopyToBodyQueue(self); setspawnparms(self); PutClientInServer(); }
	else if (deathmatch) { CopyToBodyQueue(self); SetNewParms(); PutClientInServer(); }
	else { serverflags = startingserverflags; reset_flag = TRUE; localcmd("changelevel "); localcmd(mapname); localcmd("\n"); }
};

void() ClientKill =
{
	bprint("$qc_suicides", self.netname);
	set_suicide_frame();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;
	respawn();
};

float PlayerVisibleToSpawnPoint(entity point)
{
	local vector spot1, spot2;
	local entity player = find(world, classname, "player");
	while (player)
	{
		if (player.health > 0)
		{
			spot1 = point.origin + player.view_ofs;
			spot2 = player.origin + player.view_ofs;
			traceline(spot1, spot2, TRUE, point); // TRUE = ignore monsters
			if (trace_fraction >= 1) { return TRUE; } // KEX uses 1.0f
		}
		player = find(player, classname, "player");
	}
	return FALSE;
}

float IDEAL_DIST_FROM_DM_SPAWN_POINT = 384; // From QRRQC
float MIN_DIST_FROM_DM_SPAWN_POINT = 84;   // From QRRQC

entity SelectSpawnPoint(float forceSpawn)
{
	local entity spot, thing, spots_list_head;
	local float numspots, totalspots, pcount, pick_random;

	numspots = 0; totalspots = 0;
	spot = find(world, classname, "testplayerstart");
	if (spot) { return spot; }

	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world) { lastspawn = find(lastspawn, classname, "info_player_start"); }
		if (lastspawn != world) { return lastspawn; }
	}
	else if (deathmatch)
	{
		spots_list_head = world;
		spot = find(world, classname, "info_player_deathmatch");
		while (spot)
		{
			totalspots = totalspots + 1;
			thing = findradius(spot.origin, IDEAL_DIST_FROM_DM_SPAWN_POINT);
			pcount = 0;
			while (thing)
			{
				if (thing.classname == "player" && thing.health > 0) { pcount = pcount + 1; }
				thing = thing.chain;
			}
			if (pcount == 0) { if (PlayerVisibleToSpawnPoint(spot)) { pcount = pcount + 1; } }
			if (pcount == 0) { spot.goalentity = spots_list_head; spots_list_head = spot; numspots = numspots + 1; }
			spot = find(spot, classname, "info_player_deathmatch");
		}

		if (numspots == 0) // Fallback to MIN_DIST_FROM_DM_SPAWN_POINT
		{
            spots_list_head = world; numspots = 0; // Reset for re-scan
			spot = find(world, classname, "info_player_deathmatch");
			while (spot)
			{
				thing = findradius(spot.origin, MIN_DIST_FROM_DM_SPAWN_POINT);
				pcount = 0;
				while (thing)
				{
					if (thing.classname == "player" && thing.health > 0) { pcount = pcount + 1; }
					thing = thing.chain;
				}
				if (pcount == 0) { spot.goalentity = spots_list_head; spots_list_head = spot; numspots = numspots + 1; }
				spot = find(spot, classname, "info_player_deathmatch");
			}
		}

		if (!numspots) // Still no spots
		{
			if (forceSpawn == FALSE && self.spawn_deferred == 0) { return world; } // Defer if not forcing and not already deferred
            spot = find(world, classname, "info_player_deathmatch"); // Pick any
            if (!spot) { objerror("No info_player_deathmatch spawn points found!"); return world; }
            if (totalspots > 0) { pick_random = floor(random() * totalspots); } else { pick_random = 0; }
			while (pick_random > 0 && spot) { spot = find(spot, classname, "info_player_deathmatch"); pick_random = pick_random - 1; }
            if (!spot) { spot = find(world, classname, "info_player_deathmatch"); } // Should always find one if totalspots > 0
			return spot;
		}
		
        // Pick a random spot from the suitable list
		pick_random = floor(random() * numspots); // Index from 0 to numspots-1
		spot = spots_list_head;
		while (pick_random > 0) { spot = spot.goalentity; pick_random = pick_random - 1; }
		return spot;
	}

	if (serverflags) { spot = find(world, classname, "info_player_start2"); if (spot) { return spot; } }
	spot = find(world, classname, "info_player_start");
	if (!spot) { error("PutClientInServer: no info_player_start on level"); }
	return spot;
};

void() PutClientInServer =
{ 
	local entity spot;
	self.classname = "player";
	if (skill == 3 && !deathmatch) { self.health = 50; } else { self.health = 100; }
	self.takedamage = DAMAGE_AIM; self.solid = SOLID_SLIDEBOX; self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	if (skill == 3 && !deathmatch) { self.max_health = 50; } else { self.max_health = 100; }
	self.flags = FL_CLIENT; 
    self.air_finished = time + 12; 
    self.dmg = 2;  		
	self.super_damage_finished = 0; self.radsuit_finished = 0; self.invisible_finished = 0;
	self.invincible_finished = 0; self.effects = 0; self.invincible_time = 0;
	self.healthrot_nextcheck = 0; self.fired_weapon = 0; self.took_damage = 0;
	self.team = TEAM_NONE; 
    if ( coop ) { self.team = TEAM_HUMANS; }

	DecodeLevelParms ();
    Loadout_DecodeParms(self); // ##FQXCUSTOM
    if (self.loadout_id_melee == WEAPON_ID_NONE && self.loadout_id_holdout == WEAPON_ID_NONE) { Loadout_SetDefaults(self); } // ##FQXCUSTOM
	
	W_SetCurrentAmmo ();    
    AM_InitRecoilSystem();  // ##FQXCUSTOM
    
	self.attack_finished = time; 
    self.th_pain = player_pain; 
    self.th_die = PlayerDie;
	self.deadflag = DEAD_NO; 
    self.pausetime = 0;

	local float shouldTelefrag;
    if (self.spawn_deferred > 0 && time >= self.spawn_deferred) { 
        if (cvar("developer") > 0) { dprint("forcing telefrag on this spawn\n"); }
        shouldTelefrag = TRUE; 
    } else { 
        shouldTelefrag = FALSE; 
    }
	spot = SelectSpawnPoint(shouldTelefrag);

    if (spot == world) { 
		self.takedamage = DAMAGE_NO; self.solid = SOLID_NOT; self.movetype = MOVETYPE_NONE; 
        self.deadflag = DEAD_DEAD; setmodel(self, ""); self.view_ofs = '0 0 1'; 
        self.velocity = '0 0 0';
		if (self.spawn_deferred == 0) { 
            if (cvar("developer") > 0) { dprint("no spawns available! deferring\n"); }
            self.spawn_deferred = time + 1; // QRRQC uses 1 second for deferral
        }
		spot = FindIntermission(); 
        self.angles = self.v_angle = spot.mangle; 
        self.fixangle = TRUE;
		setorigin(self, spot.origin); 
        self.weaponmodel = ""; self.weaponframe = 0; self.weapon = 0;
		return;
	}
	self.spawn_deferred = 0; 

	setorigin(self, spot.origin + '0 0 1'); 
    self.angles = spot.angles; 
    self.fixangle = TRUE;		
	
	setmodel (self, "progs/eyes.mdl"); 
    modelindex_eyes = self.modelindex;
	setmodel (self, "progs/player.mdl"); 
    modelindex_player = self.modelindex;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22'; 
    self.velocity = '0 0 0';	
	
	player_stand1 ();
	
	if (deathmatch || coop) { 
        makevectorsfixed(self.angles); 
        spawn_tfog (self.origin + v_forward*20); 
    }
	spawn_tdeath (self.origin, self); 
	
	stuffcmd(self, "-attack\n"); 
};

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) */ void() info_player_start = { };
/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24) */ void() info_player_start2 = { };
/*QUAKED testplayerstart (0 0.5 0.5) (-16 -16 -24) (16 16 24) For regioned levels */ void() testplayerstart = { }; 
/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24) */ void() info_player_deathmatch = { };
/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) */ void() info_player_coop = { };

void() NextLevel = { /* ... logic from QRRQC-client.qc ... */ local entity o; if (nextmap != string_null) return; if (mapname == "start") { if (!cvar("registered")) { mapname = "e1m1"; } else if (!(serverflags & 1)) { mapname = "e1m1"; serverflags = serverflags | 1; } else if (!(serverflags & 2)) { mapname = "e2m1"; serverflags = serverflags | 2; } else if (!(serverflags & 4)) { mapname = "e3m1"; serverflags = serverflags | 4; } else if (!(serverflags & 8)) { mapname = "e4m1"; serverflags = serverflags - 7; } o = spawn(); o.map = mapname; } else { o = find(world, classname, "trigger_changelevel"); if (!o || mapname == "start") { o = spawn(); o.map = mapname; } } nextmap = o.map; gameover = TRUE; if (o.nextthink < time) { o.think = execute_changelevel; o.nextthink = time + 0.1; } };
void() CheckRules = { /* ... logic from QRRQC-client.qc ... */ local float timelimit; local float fraglimit; if (gameover) return; timelimit = cvar("timelimit") * 60; fraglimit = cvar("fraglimit"); if (timelimit && time >= timelimit && timelimit != 0) { NextLevel (); return; } if (fraglimit && self.frags >= fraglimit && fraglimit != 0) { NextLevel (); return; } };
void() PlayerDeathThink = { /* ... logic from QRRQC-client.qc ... */ local float forward; if ((self.flags & FL_ONGROUND)) { forward = vlen (self.velocity); forward = forward - 20; if (forward <= 0) self.velocity = '0 0 0'; else self.velocity = forward * normalize(self.velocity); } if (self.spawn_deferred) { local entity spot; spot = SelectSpawnPoint(FALSE); if (spot != world || time >= self.spawn_deferred) { respawn(); } return; } if (self.deadflag == DEAD_DEAD) { if (self.button2 || self.button1 || self.button0) return; self.deadflag = DEAD_RESPAWNABLE; return; } if (!self.button2 && !self.button1 && !self.button0) return; self.button0 = 0; self.button1 = 0; self.button2 = 0; respawn(); };
void() PlayerJump = { /* ... logic from QRRQC-client.qc (with KEX FL_ONGROUND) ... */ if (self.flags & FL_WATERJUMP) return; if (self.waterlevel >= 2) { if (self.watertype == CONTENT_WATER) self.velocity_z = 100; else if (self.watertype == CONTENT_SLIME) self.velocity_z = 80; else self.velocity_z = 50; if (self.swim_flag < time) { self.swim_flag = time + 1; if (random() < 0.5) sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM); else sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM); } return; } if (!(self.flags & FL_ONGROUND)) return; if ( !(self.flags & FL_JUMPRELEASED) ) return; self.flags = self.flags - (self.flags & FL_JUMPRELEASED); self.flags = self.flags - (self.flags & FL_ONGROUND); self.button2 = 0; sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM); self.velocity_z = self.velocity_z + 270; };
.float	dmgtime; 
void() WaterMove = { /* ... logic from QRRQC-client.qc ... */ if (self.movetype == MOVETYPE_NOCLIP) return; if (self.health < 0) return; if (self.waterlevel != 3) { if (self.air_finished < time) sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM); else if (self.air_finished < time + 9) sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM); self.air_finished = time + 12; self.dmg = 2; } else if (self.air_finished < time) { if (self.pain_finished < time) { self.dmg = self.dmg + 2; if (self.dmg > 15) self.dmg = 15; T_Damage (self, world, world, self.dmg); self.pain_finished = time + 1; } } if (!self.waterlevel) { if (self.flags & FL_INWATER) { sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM); self.flags = self.flags - (self.flags & FL_INWATER); } return; } if (self.watertype == CONTENT_LAVA) { if (self.dmgtime < time) { if (self.radsuit_finished > time) self.dmgtime = time + 1; else self.dmgtime = time + 0.2; T_Damage (self, world, world, 10*self.waterlevel); } } else if (self.watertype == CONTENT_SLIME) { if (self.dmgtime < time && self.radsuit_finished < time) { self.dmgtime = time + 1; T_Damage (self, world, world, 4*self.waterlevel); } } if ( !(self.flags & FL_INWATER) ) { if (self.watertype == CONTENT_LAVA) sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM); if (self.watertype == CONTENT_WATER) sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM); if (self.watertype == CONTENT_SLIME) sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM); self.flags = self.flags | FL_INWATER; self.dmgtime = 0; } if (! (self.flags & FL_WATERJUMP) ) { self.velocity = self.velocity * (1 - (0.8 * self.waterlevel * frametime)); } };
void() CheckWaterJump = { /* ... logic from QRRQC-client.qc ... */ local vector start, end; makevectorsfixed(self.angles); start = self.origin; start_z = start_z + 8; v_forward_z = 0; normalize(v_forward); end = start + v_forward*24; traceline (start, end, TRUE, self); if (trace_fraction < 1) { start_z = start_z + self.maxs_z - 8; end = start + v_forward*24; self.movedir = trace_plane_normal * -50; traceline (start, end, TRUE, self); if (trace_fraction == 1) { self.flags = self.flags | FL_WATERJUMP; self.velocity_z = 225; self.flags = self.flags - (self.flags & FL_JUMPRELEASED); self.teleport_time = time + 2; return; } } };

void() PlayerPreThink = { /* ... logic from FQX client.qc (Source ID 6089, lines 687-702), with AM_RecoilThink and FQX item logic ... */ if (intermission_running) { IntermissionThink (); return; } if (self.view_ofs == '0 0 0') return; makevectors (self.v_angle); if (deathmatch || coop) { CheckRules (); } WaterMove (); if (self.waterlevel == 2) { CheckWaterJump (); } if (self.deadflag >= DEAD_DEAD) { PlayerDeathThink (); return; } if (self.deadflag == DEAD_DYING) { return; } if (self.button2) { PlayerJump (); } else { self.flags = self.flags | FL_JUMPRELEASED; } if (time < self.pausetime) { self.velocity = '0 0 0'; } AM_RecoilThink(); if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_SLOT_MELEE && self.weapon != IT_SLOT_HOLDOUT) { self.weapon = W_BestWeapon (); W_SetCurrentAmmo (); } if (self.frags > self.loot_fragcheck) { self.loot_fragcheck = self.frags; self.loot_bonus = self.loot_bonus + 1; } };

//-----------------------------------------------------------------------------
// ##Quedra: CheckPowerups - Corrected to use KEX standard effect flags EF_PENTALIGHT and EF_QUADLIGHT
//-----------------------------------------------------------------------------
void() CheckPowerups = 
{
	if (self.health <= 0) { return; }

	// Invisibility
	if (self.invisible_finished > time) 
    {
		if (self.invisible_sound < time) { sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE); self.invisible_sound = time + ((random() * 3) + 1); }
		if (self.invisible_finished < time + 3) { if (self.invisible_time == 1) { sprint(self, "$qc_ring_fade"); stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM); self.invisible_time = time + 1; } if (self.invisible_time < time) { self.invisible_time = time + 1; stuffcmd (self, "bf\n"); } }
		self.frame = 0; self.modelindex = modelindex_eyes;
	} 
    else 
    {
        if (self.items & IT_INVISIBILITY) { self.items = self.items - IT_INVISIBILITY; } // Clear item flag if timer ran out
		self.invisible_finished = 0; self.invisible_time = 0;
        self.modelindex = modelindex_player;
    }

	// Invincibility
	if (self.invincible_finished > time) 
    {
		if (self.invincible_finished < time + 3) { if (self.invincible_time == 1) { sprint(self, "$qc_protection_fade"); stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM); self.invincible_time = time + 1; } if (self.invincible_time < time) { self.invincible_time = time + 1; stuffcmd (self, "bf\n"); } }
		self.effects = self.effects | EF_PENTALIGHT; 
	} 
    else 
    {
        if (self.items & IT_INVULNERABILITY) { self.items = self.items - IT_INVULNERABILITY; }
		self.invincible_time = 0; self.invincible_finished = 0;
        if (self.effects & EF_PENTALIGHT) { self.effects = self.effects - EF_PENTALIGHT; }
	}

	// Super Damage (Quad)
	if (self.super_damage_finished > time) 
    {
		if (self.super_damage_finished < time + 3) { if (self.super_time == 1) { sprint(self, "$qc_quad_fade"); stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM); self.super_time = time + 1; } if (self.super_time < time) { self.super_time = time + 1; stuffcmd (self, "bf\n"); } }
		self.effects = self.effects | EF_QUADLIGHT; 
	} 
    else 
    {
        if (self.items & IT_QUAD) { self.items = self.items - IT_QUAD; }
		self.super_damage_finished = 0; self.super_time = 0;
        if (self.effects & EF_QUADLIGHT) { self.effects = self.effects - EF_QUADLIGHT; }
	}	

	// Suit	
	if (self.radsuit_finished > time) 
    {
		self.air_finished = time + 12;		
		if (self.radsuit_finished < time + 3) { if (self.rad_time == 1) { sprint(self, "$qc_biosuit_fade"); stuffcmd (self, "bf\n"); sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM); self.rad_time = time + 1; } if (self.rad_time < time) { self.rad_time = time + 1; stuffcmd (self, "bf\n"); } }
	} 
    else 
    {
        if (self.items & IT_SUIT) { self.items = self.items - IT_SUIT; }
        self.rad_time = 0; self.radsuit_finished = 0;
    }	
};

void() CheckHealthRot = { /* ... logic from QRRQC-client.qc ... */ if ( !( self.items & IT_SUPERHEALTH ) ) return; if ( self.healthrot_nextcheck > time ) return; if ( self.health > self.max_health ) { self.health = self.health - 1; self.healthrot_nextcheck = time + 1; return; } self.items = self.items - ( self.items & IT_SUPERHEALTH ); self.healthrot_nextcheck = 0; };

void() PlayerPostThink = { /* ... logic from FQX client.qc (Source ID 6089, lines 782-795), with AM_RecoilThink placement corrected ... */ if (self.view_ofs != '0 0 0' && !self.deadflag) { AM_RecoilThink(); } if ( self.view_ofs == '0 0 0') return; if ( self.deadflag ) return; W_WeaponFrame (); if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0)) { if (self.watertype == CONTENT_WATER) sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM); else if (self.jump_flag < -650) { T_Damage (self, world, world, 5); sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM); if (self.health <= 0) self.deathtype = "falling"; } else sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM); self.jump_flag = 0; } if (!(self.flags & FL_ONGROUND)) { self.jump_flag = self.velocity_z; } CheckPowerups(); CheckHealthRot(); };

void() ClientConnect = { /* ... logic from QRRQC-client.qc ... */ bprint("$qc_entered", self.netname); if (intermission_running) { ExitIntermission (); } };

void() ClientDisconnect = 
{
	if (gameover) { return; }
	bprint("$qc_left_game", self.netname, ftos(self.frags));
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	
    // ##Quedra: Sequentially clear KEX standard flags to avoid opcode issues
    if (self.effects & EF_QUADLIGHT) {
        self.effects = self.effects - EF_QUADLIGHT;
    }
    if (self.effects & EF_PENTALIGHT) {
        self.effects = self.effects - EF_PENTALIGHT;
    }
	set_suicide_frame(); 
};

void(entity targ, entity attacker) ClientObituary = { /* ... logic from FQX client.qc (Source ID 6089, lines 820-887), ensuring FQX IT_SLOT_* are used for player weapon obits ... */ local float rnum; local float attackerteam, targteam; attackerteam = attacker.team; targteam = targ.team; rnum = random(); if (targ.classname == "player") { if (attacker.classname == "teledeath") { bprint("$qc_telefragged", targ.netname, attacker.owner.netname); attacker.owner.frags = attacker.owner.frags + 1; return; } if (attacker.classname == "teledeath2") { bprint("$qc_satans_power", targ.netname); targ.frags = targ.frags - 1; return; } if (attacker.classname == "player") { if (targ == attacker) { attacker.frags = attacker.frags - 1; if (targ.weapon == IT_SLOT_AUX2 && targ.waterlevel > 1) { if (targ.watertype == CONTENT_SLIME) bprint("$qc_discharge_slime", targ.netname); else if (targ.watertype == CONTENT_LAVA) bprint("$qc_discharge_lava", targ.netname); else bprint("$qc_discharge_water", targ.netname); return; } if (targ.weapon == IT_SLOT_UTILITY) bprint("$qc_suicide_pin", targ.netname); else if (rnum > 0.5) bprint("$qc_suicide_bored", targ.netname); else bprint("$qc_suicide_loaded", targ.netname); return; } else if ( (teamplay == 2) && (targteam == attackerteam) && (attackerteam != 0) ) { if (rnum < 0.25) bprint("$qc_ff_teammate", attacker.netname); else if (rnum < 0.50) bprint("$qc_ff_glasses", attacker.netname); else if (rnum < 0.75) bprint("$qc_ff_otherteam", attacker.netname); else bprint("$qc_ff_friend", attacker.netname); attacker.frags = attacker.frags - 1; return; } else { attacker.frags = attacker.frags + 1; if (attacker.weapon == IT_SLOT_MELEE) { bprint("$qc_death_ax", targ.netname, attacker.netname); return; } if (attacker.weapon == IT_SLOT_HOLDOUT) { bprint("$qc_death_sg", targ.netname, attacker.netname); return; } if (attacker.weapon == IT_SLOT_SECONDARY) { bprint("$qc_death_dbl", targ.netname, attacker.netname); return; } if (attacker.weapon == IT_SLOT_PRIMARY) { bprint("$qc_death_nail", targ.netname, attacker.netname); return; } if (attacker.weapon == IT_SLOT_HEAVY) { bprint("$qc_death_sng", targ.netname, attacker.netname); return; } if (attacker.weapon == IT_SLOT_UTILITY) { if (targ.health < -40) { bprint("$qc_death_gl1", targ.netname, attacker.netname); } else { bprint("$qc_death_gl2", targ.netname, attacker.netname); } return; } if (attacker.weapon == IT_SLOT_AUX1) { if (attacker.super_damage_finished > time && targ.health < -40) { rnum = random(); if (rnum < 0.3) { bprint("$qc_death_rl_quad1", targ.netname, attacker.netname); } else if (rnum < 0.6) { bprint("$qc_death_rl_quad2", targ.netname, attacker.netname); } else { bprint("$qc_death_rl1", targ.netname, attacker.netname); } } else { if (targ.health < -40) { bprint("$qc_death_rl2", targ.netname, attacker.netname); } else { bprint("$qc_death_rl3", targ.netname, attacker.netname); } } return; } if (attacker.weapon == IT_SLOT_AUX2) { if (attacker.waterlevel > 1) { bprint("$qc_death_lg1", targ.netname, attacker.netname); if (attacker.invincible_finished > time) { msg_entity = attacker; WriteByte (MSG_ONE, SVC_ACHIEVEMENT); WriteString(MSG_ONE, "ACH_SURVIVE_DISCHARGE"); } } else bprint("$qc_death_lg2", targ.netname, attacker.netname); return; } bprint("$qc_killed_by", targ.netname, attacker.netname); return; } } else { targ.frags = targ.frags - 1; rnum = targ.watertype; if (rnum == CONTENT_WATER) { if (random() < 0.5) bprint("$qc_death_drown1", targ.netname); else bprint("$qc_death_drown2", targ.netname); return; } else if (rnum == CONTENT_SLIME) { if (random() < 0.5) bprint("$qc_death_slime1", targ.netname); else bprint("$qc_death_slime2", targ.netname); return; } else if (rnum == CONTENT_LAVA) { if (targ.health < -15) { bprint("$qc_death_lava1", targ.netname); return; } if (random() < 0.5) bprint("$qc_death_lava2", targ.netname); else bprint("$qc_death_lava3", targ.netname); return; } if (attacker.solid == SOLID_BSP && attacker != world) { bprint("$qc_death_squish", targ.netname); return; } if (attacker.killstring != string_null) { bprint(attacker.killstring, targ.netname); return; } if (targ.deathtype == "falling") { targ.deathtype = string_null; bprint("$qc_death_fall", targ.netname); return; } bprint("$qc_death_died", targ.netname); } } };
//=============================================================================
// client.qc - FQX Mod - Client Connection, Disconnection, Spawning, Rules - END
// ##Quedra: Version 1.7
//=============================================================================