// =======================================================================
//
//  ##File: pcl_main.qc
//  ##File Description: Player & Client Logic - Main
//  ##FQX - ##FQXnote.: Version 1.3.1 (20250611.192354CDT)
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##FQXnote.
//    v1.3.1 - Corrected the function signature for SelectSpawnPoint to match
//             its forward declaration in defs_fqx_fdec_systems.qc, resolving
//             a fatal 'Type mismatch' compiler error.
//    v1.3.0 - Transcribed DecodeLevelParms, PlayerVisibleToSpawnPoint, and
//             SelectSpawnPoint from the canonical QRRQC-client.qc.txt
//             source to resolve linker errors.
//    v1.2.0 - Transcribed SetNewParms and SetChangeParms.
//    v1.1.0 - Transcribed ClientKill and respawn.
//
// =======================================================================

//===============================================================================
//  CLIENT CONNECTION & SPAWNING
//===============================================================================

/*
===========
ClientConnect

Called when a player connects to a server.
Origin: QRRQC client.qc
============
*/
void() ClientConnect =
{
	bprint("$qc_entered", self.netname);
	// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};

/*
===========
ClientDisconnect

Called when a player disconnects from a server.
Origin: QRRQC client.qc
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint("$qc_left_game", self.netname, ftos(self.frags));
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

	self.effects = 0;
	set_suicide_frame ();
};

//===============================================================================
//  CLIENT SPAWN PARAMETER MANAGEMENT
//===============================================================================

void() SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	if (skill == 3 && !deathmatch)
		parm2 = 50;
	else
		parm2 = 100;
	parm3 = 0;
	parm4 = 25;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
};

void() SetChangeParms =
{
    if(reset_flag)
    {
        setspawnparms(self);
		return;
	}

	if (self.health <= 0 || deathmatch)
	{
		SetNewParms ();
		return;
	}
 
    // remove items
	self.items = self.items - (self.items & (IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	// cap super health
	if (self.health > self.max_health)
		self.health = self.max_health;

	if (self.health < self.max_health / 2)
		self.health = self.max_health / 2;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;

	if (self.ammo_shells < 25)
		parm4 = 25;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
};

/*
===========
PutClientInServer

The primary function for spawning a player into the world. It sets up
all default player states and finds a valid spawn point.
Origin: QRRQC client.qc
============
*/
void() PutClientInServer =
{
	local	entity spot;
	self.classname = "player";
	if (skill == 3 && !deathmatch)
		self.health = 50;
	else
		self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	if (skill == 3 && !deathmatch)
		self.max_health = 50;
	else
		self.max_health = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
	self.healthrot_nextcheck = 0;
	self.fired_weapon = 0;
	self.took_damage = 0;
	self.team = TEAM_NONE;
	
	if ( coop ) { 
		self.team = TEAM_HUMANS;
	}

	DecodeLevelParms ();
	
	W_SetCurrentAmmo ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
	self.pausetime = 0;
	local float shouldTelefrag;
	if (self.spawn_deferred > 0 && time >= self.spawn_deferred) {
		dprint("forcing telefrag on this spawn\n");
		shouldTelefrag = TRUE;
	} else {
		shouldTelefrag = FALSE;
	}
	spot = SelectSpawnPoint(shouldTelefrag);
	if (spot == world) {
		self.takedamage = DAMAGE_NO;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		self.deadflag = DEAD_DEAD;
		setmodel(self, "");
		self.view_ofs = '0 0 1';
		self.velocity = '0 0 0';
		if (self.spawn_deferred == 0) {
			dprint("no spawns available! deferring\n");
			self.spawn_deferred = time + 5;
		}

		spot = FindIntermission();
		self.angles = self.v_angle = spot.mangle;
		self.fixangle = TRUE;
		self.origin = spot.origin;
		self.weaponmodel = "";
		self.weaponframe = 0;
		self.weapon = 0;
		return;
	}

	self.spawn_deferred = 0;
	self.origin = spot.origin + '0 0 1';
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
	
	if (deathmatch || coop)
	{
		makevectorsfixed(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
	
	stuffcmd(self, "-attack\n");
};

//===============================================================================
//  CLIENT DEATH & RESPAWN
//===============================================================================

void() respawn =
{
	if (coop)
	{
		CopyToBodyQueue (self);
		setspawnparms (self);
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		CopyToBodyQueue (self);
		SetNewParms ();
		PutClientInServer ();
	}
	else
	{	
		serverflags = startingserverflags;
		reset_flag = TRUE;
		localcmd ("changelevel ");
		localcmd(mapname);
		localcmd("\n");
	}
};

void() ClientKill =
{
	bprint("$qc_suicides", self.netname);
	set_suicide_frame ();
	self.modelindex = modelindex_player;
	self.frags = self.frags - 2;
	respawn ();
};

//===============================================================================
//  SPAWN POINT SELECTION & PARAMETER DECODING
//===============================================================================
// ##FQXnote.: TRANSCRIPTION - The following functions have been transcribed from
// ##FQXnote.: QRRQC-client.qc.txt to resolve 'function has no body' errors.
void() DecodeLevelParms =
{
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();
	}
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
};

float(entity point) PlayerVisibleToSpawnPoint = {
	local vector spot1, spot2;
	local entity player = find( world, classname, "player" );
	while ( player ) {
		if ( player.health > 0 ) {
			spot1 = point.origin + player.view_ofs;
			spot2 = player.origin + player.view_ofs;
			traceline( spot1, spot2, TRUE, point );
			if ( trace_fraction >= 1.0 ) {
				return TRUE;
			}
		}
		player = find( player, classname, "player" );
	}
	return FALSE;
};

// ##FQXnote.: CORRECTED - Added the 'forceSpawn' parameter to the function signature
// ##FQXnote.: to match the forward declaration and resolve the fatal compiler error.
entity(float forceSpawn) SelectSpawnPoint =
{
	local   entity spot, thing;
	local   float   numspots, totalspots;
	local   float   pcount;
	local	entity spots;
	numspots = 0;
	totalspots = 0;

	spot = find( world, classname, "testplayerstart" );
	if ( spot )
		return spot;
	if ( coop ) {
		lastspawn = find( lastspawn, classname, "info_player_coop" );
		if ( lastspawn == world ) {
			lastspawn = find( lastspawn, classname, "info_player_start" );
		}
		if ( lastspawn != world ) {
			return lastspawn;
		}
	} else if ( deathmatch ) {
		spots = world;
		spot = find( world, classname, "info_player_deathmatch" );       
		while( spot ) {
			totalspots = totalspots + 1;
			thing = findradius( spot.origin, 384 ); // IDEAL_DIST_FROM_DM_SPAWN_POINT
			pcount = 0;
			while( thing ) {
				if ( thing.classname == "player" && thing.health > 0 ) {
					pcount = pcount + 1;
				}
				thing = thing.chain;      
			}
			if ( pcount == 0 ) {
				if ( PlayerVisibleToSpawnPoint( spot ) ) {
					pcount = pcount + 1;
				}
			}
			if ( pcount == 0 ) { 
				spot.goalentity = spots;
				spots = spot;
				numspots = numspots + 1;
			}
			spot = find( spot, classname, "info_player_deathmatch" );
		}
		totalspots = totalspots - 1;
		if ( numspots == 0 ) {
			spot = find( world, classname, "info_player_deathmatch" );
			while( spot ) {
				thing = findradius( spot.origin, 84 ); // MIN_DIST_FROM_DM_SPAWN_POINT
				pcount = 0;
				while( thing ) {
					if ( thing.classname == "player" && thing.health > 0 ) {
						pcount = pcount + 1;
					}
					thing = thing.chain;      
				}
				if ( pcount == 0 ) {
					spot.goalentity = spots;
					spots = spot;
					numspots = numspots + 1;
				}
				spot = find( spot, classname, "info_player_deathmatch" );
			}             
		}

		if ( !numspots ) {
			if (forceSpawn == FALSE) {
				return world;
			} 
			totalspots = rint( ( random() * totalspots ) );
			spot = find( world, classname, "info_player_deathmatch" );
			while( totalspots > 0 ) {
				totalspots = totalspots - 1;
				spot = find( spot, classname, "info_player_deathmatch" );
			}
			return spot;
		}
		
		numspots = numspots - 1;
		numspots = rint( ( random() * numspots ) );
		spot = spots;
		while( numspots > 0 ) {
			spot = spot.goalentity;
			numspots = numspots - 1;
		}
	
		return spot;
	}

	if ( serverflags ) {
		spot = find( world, classname, "info_player_start2" );
		if ( spot ) {
			return spot;
		}
	}
	
	spot = find( world, classname, "info_player_start" );
	if ( !spot ) {
		error( "PutClientInServer: no info_player_start on level" );
	}
	
	return spot;
};

//===============================================================================
//  SPAWN POINT DEFINITIONS
//===============================================================================

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) */
void() info_player_start = { };
/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24) */
void() info_player_start2 = { };
/* saved out by quaked in region mode */
void() testplayerstart = { };
/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24) */
void() info_player_deathmatch = { };
/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) */
void() info_player_coop = { };

// =======================================================================
// ##FQX - ##FQXnote.: Version 1.3.1 (20250611.192354CDT)
// ##File: pcl_main.qc
// =======================================================================