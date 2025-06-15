// =======================================================================
//
//  ##File: pcl_input.qc
//  ##File Description: Player & Client Logic - Input Handling
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##Quedra: This module's existence is decreed by the progs.src manifest.
//    It contains the primary PlayerPreThink function, segregated from the
//    monolithic client.qc. This function handles all pre-physics input
//    and state checks for the player each frame.
//
// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0
// ##FIREFQX: Modified for Phase II Unlimited Ammo Cheat (20250614.065419CDT)

/*
===============================================================================
    PLAYER PRE-THINK LOGIC
===============================================================================
*/

/*
================
PlayerPreThink

Called every frame before physics are run.
Origin: QRRQC client.qc
================
*/
void() PlayerPreThink =
{
	// ##Quedra: Check for intermission state first.
	if (intermission_running)
	{
		IntermissionThink ();
// otherwise a button could be missed
		return;
	}

	// ##Quedra: If in finale or other view override, do nothing.
	if (self.view_ofs == '0 0 0')
		return;

	// ##Quedra: makevectors is used by many systems, but its call
	// ##Quedra: was originally here.
	makevectors (self.v_angle);

	// ##Quedra: Check for deathmatch win conditions.
	if (deathmatch || coop)
		CheckRules ();
	// ##Quedra: Handle player's interaction with water/slime/lava.
	WaterMove ();

	// ##Quedra: Check if player can leap out of water.
	if (self.waterlevel == 2)
		CheckWaterJump ();
		
	// ##Quedra: If player is dead, run the death think loop.
	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	// ##Quedra: If player is in the process of dying, halt further input.
	if (self.deadflag == DEAD_DYING)
		return;

	// ##Quedra: Handle jump input.
	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
	// ##Quedra: Teleporters can induce a temporary pause.
	if (time < self.pausetime)
		self.velocity = '0 0 0';
	// ##Quedra: If out of ammo, automatically switch to best available weapon.
	// ##FIREFQX: Bypass automatic weapon switch if unlimited ammo cheat is active.
	if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE && self.fqx_cheat_unlimited_ammo == FALSE)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
	}
};
// =======================================================================
// ##FQX - ##Quedra: Version 1.0.0
// ##FIREFQX: Version 1.0.1 (20250614.065419CDT)
// =======================================================================