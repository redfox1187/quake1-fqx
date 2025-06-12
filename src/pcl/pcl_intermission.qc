// =======================================================================
//
//  ##File: pcl_intermission.qc
//  ##File Description: Player & Client Logic - Intermission
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##Quedra: This module contains all logic for handling intermissions,
//    level transitions, and end-of-episode finale sequences. This logic
//    was segregated from the monolithic QRRQC client.qc to improve
//    modularity and adhere to the FQX Phoenix architecture.
//
// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0

//=============================================================================
//  MODULE-SPECIFIC GLOBALS & DECLARATIONS
//=============================================================================

// ##Quedra: These global variables were originally defined in client.qc.
// ##Quedra: They are placed here because all functions within this module
// ##Quedra: depend on them. Defining them here resolves the 'Unknown value'
// ##Quedra: errors encountered during our previous compilation attempts.
string  nextmap;
float   intermission_running;
float   intermission_exittime;

// ##Quedra: This forward declaration is necessary because the function
// ##Quedra: 'trigger_changelevel' makes a call to 'changelevel_touch'
// ##Quedra: before it has been defined later in this same file.
void() changelevel_touch;

//=============================================================================
//  INTERMISSION & LEVEL CHANGE LOGIC
//=============================================================================

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.
'pitch roll yaw'
*/
void() info_intermission =
{
	// ##Quedra: This is an entity definition, no logic needed.
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;
	
	// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

	// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
	// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
	objerror ("FindIntermission: no spot");
	return world;
};


void() GotoNextMap =
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};


void() ExitIntermission =
{
	// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	// run some text if at the end of an episode
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
	
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "$qc_finale_e1_shareware");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "$qc_finale_e1");
			}
	
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "$qc_finale_e2");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "$qc_finale_e3");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "$qc_finale_e4");
			return;
		}
		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "$qc_finale_all_runes");
			return;
		}
	}
	GotoNextMap();
};


/*
============
IntermissionThink
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;
	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};


void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;
	
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		
		if (skill == 3)
		{
			if (other.fired_weapon == 0 && world.model == "maps/e1m1.bsp")
			{
				msg_entity = other;
				WriteByte (MSG_ONE, SVC_ACHIEVEMENT);
				WriteString(MSG_ONE, "ACH_PACIFIST");
			}
			if (other.took_damage == 0 && world.model == "maps/e4m6.bsp")
			{
				msg_entity = other;
				WriteByte (MSG_ONE, SVC_ACHIEVEMENT);
				WriteString(MSG_ONE, "ACH_PAINLESS_MAZE");
			}
		}
		
		other = find (other, classname, "player");
	}	

	WriteByte (MSG_ALL, SVC_INTERMISSION);

	if (campaign && world.model == "maps/e1m7.bsp")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_COMPLETE_E1M7");
	}
	else if (campaign && world.model == "maps/e2m6.bsp")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_COMPLETE_E2M6");
	}
	else if (campaign && world.model == "maps/e3m6.bsp")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_COMPLETE_E3M6");
	}
	else if (campaign && world.model == "maps/e4m7.bsp")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_COMPLETE_E4M7");
	}

	if (world.model == "maps/e1m4.bsp" && nextmap == "e1m8")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E1M8");
	}
	else if (world.model == "maps/e2m3.bsp" && nextmap == "e2m7")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E2M7");
	}
	else if (world.model == "maps/e3m4.bsp" && nextmap == "e3m7")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E3M7");
	}
	else if (world.model == "maps/e4m5.bsp" && nextmap == "e4m8")
	{
		WriteByte (MSG_ALL, SVC_ACHIEVEMENT);
		WriteString(MSG_ALL, "ACH_FIND_E4M8");
	}
};


/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION */
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("changelevel trigger doesn't have map");

	self.netname = "changelevel";
	self.killstring = "$qc_ks_tried_leave";
	
	InitTrigger ();
	self.touch = changelevel_touch;
};

void() changelevel_touch =
{
	if (other.classname != "player")
		return;
	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self, 50000);
		return;
	}

	if (coop || deathmatch)
	{
		bprint("$qc_exited", other.netname);
	}
	
	nextmap = self.map;

	SUB_UseTargets ();
	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0
// =======================================================================