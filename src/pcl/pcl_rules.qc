// =======================================================================
//
//  ##File: pcl_rules.qc
//  ##File Description: Player & Client Logic - Game Rules
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##Quedra: This module's existence is decreed by the progs.src manifest.
//    It contains logic for deathmatch rules like timelimit and fraglimit,
//    segregated from the monolithic QRRQC client.qc to improve modularity.
//
// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0

/*
===============================================================================
    DEATHMATCH RULES
===============================================================================
*/

/*
================
NextLevel

Handles logic for progressing to the next level in deathmatch upon
timelimit or fraglimit being reached.
Origin: QRRQC client.qc
================
*/
void() NextLevel =
{
	local entity o;

	if (nextmap != string_null)
		return;
	// already done

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}
 
		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");
		if (!o || mapname == "start")
		{       // go back to same map if no trigger_changelevel
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;

	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Called every frame for each player in deathmatch to check if win
conditions have been met.
Origin: QRRQC client.qc
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};


// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0
// =======================================================================