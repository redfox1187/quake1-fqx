// =======================================================================
//
//  ##File: pcl_obituary.qc
//  ##File Description: Player & Client Logic - Death Messages
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##Quedra: This module's existence is decreed by the progs.src manifest.
//    It contains the ClientObituary function, responsible for generating
//    all player death messages, segregated from the monolithic QRRQC
//    client.qc for improved modularity.
//
// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0

/*
===============================================================================
    PLAYER OBITUARY LOGIC
===============================================================================
*/

/*
===========
ClientObituary

Called when a player dies to print the correct death message.
Origin: QRRQC client.qc
============
*/
void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local   float  attackerteam, targteam;
	
	attackerteam = attacker.team;
	targteam = targ.team;

	rnum = random();
	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint("$qc_telefragged", targ.netname, attacker.owner.netname);

			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint("$qc_satans_power", targ.netname);
			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
					if (targ.watertype == CONTENT_SLIME)
						bprint("$qc_discharge_slime", targ.netname);

					else if (targ.watertype == CONTENT_LAVA)
						bprint("$qc_discharge_lava", targ.netname);

					else
						bprint("$qc_discharge_water", targ.netname);
					return;
				}
				if (targ.weapon == 16)
					bprint("$qc_suicide_pin", targ.netname);
				else if (rnum)
					bprint("$qc_suicide_bored", targ.netname);
				else
					bprint("$qc_suicide_loaded", targ.netname);
				return;
			}
			else if ( (teamplay == 2) && (targteam == attackerteam) &&
				(attackerteam != 0) )
			{
				if (rnum < 0.25)
					bprint("$qc_ff_teammate", attacker.netname);
				else if (rnum < 0.50)
					bprint("$qc_ff_glasses", attacker.netname);
				else if (rnum < 0.75)
					bprint("$qc_ff_otherteam", attacker.netname);
				else
					bprint("$qc_ff_friend", attacker.netname);

				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

				rnum = attacker.weapon;

				if (rnum == IT_AXE)
				{
					bprint("$qc_death_ax", targ.netname, attacker.netname);
					return;
				}

				if (rnum == IT_SHOTGUN)
				{
					bprint("$qc_death_sg", targ.netname, attacker.netname);
					return;
				}

				if (rnum == IT_SUPER_SHOTGUN)
				{
					bprint("$qc_death_dbl", targ.netname, attacker.netname);
					return;
				}

				if (rnum == IT_NAILGUN)
				{
					bprint("$qc_death_nail", targ.netname, attacker.netname);
					return;
				}

				if (rnum == IT_SUPER_NAILGUN)
				{
					bprint("$qc_death_sng", targ.netname, attacker.netname);
					return;
				}

				if (rnum == IT_GRENADE_LAUNCHER)
				{
					if (targ.health < -40)
					{
						bprint("$qc_death_gl1", targ.netname, attacker.netname);
						return;
					}
					else
					{
						bprint("$qc_death_gl2", targ.netname, attacker.netname);
						return;
					}
				}

				if (rnum == IT_ROCKET_LAUNCHER)
				{
					if (attacker.super_damage_finished > 0 && targ.health < -40)
					{
						rnum = random();
						if (rnum < 0.3)
						{
							bprint("$qc_death_rl_quad1", targ.netname, attacker.netname);
							return;
						}
						else if (rnum < 0.6)
						{
							bprint("$qc_death_rl_quad2", targ.netname, attacker.netname);
							return;
						}
						else
						{
							bprint("$qc_death_rl1", targ.netname, attacker.netname);
							return;
						}
					}
					else
					{
						if (targ.health < -40)
						{
							bprint("$qc_death_rl2", targ.netname, attacker.netname);
							return;
						}
						else
						{
							bprint("$qc_death_rl3", targ.netname, attacker.netname);
							return;
						}
					}
				}

				if (rnum == IT_LIGHTNING)
				{
					if (attacker.waterlevel > 1)
					{
						bprint("$qc_death_lg1", targ.netname, attacker.netname);
						if (attacker.invincible_finished)
						{
							msg_entity = attacker;
							WriteByte (MSG_ONE, SVC_ACHIEVEMENT);
							WriteString(MSG_ONE, "ACH_SURVIVE_DISCHARGE");
						}
					}
					else
						bprint("$qc_death_lg2", targ.netname, attacker.netname);
					
					return;
				}
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
			// killed self
			rnum = targ.watertype;

			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint("$qc_death_drown1", targ.netname);
				else
					bprint("$qc_death_drown2", targ.netname);

				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint("$qc_death_slime1", targ.netname);
				else
					bprint("$qc_death_slime2", targ.netname);

				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint("$qc_death_lava1", targ.netname);
					return;
				}

				if (random() < 0.5)
					bprint("$qc_death_lava2", targ.netname);
				else
					bprint("$qc_death_lava3", targ.netname);

				return;
			}

			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint("$qc_death_squish", targ.netname);
				return;
			}

			if(attacker.killstring)
			{
				bprint(attacker.killstring, targ.netname);
				return;
			}

			if (targ.deathtype == "falling")
			{
				targ.deathtype = string_null;
				bprint("$qc_death_fall", targ.netname);
				return;
			}

			bprint("$qc_death_died", targ.netname);
		}
	}
};


// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0
// =======================================================================