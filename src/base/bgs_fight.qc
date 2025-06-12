//=============================================================================
// bgs_fight.qc - FQX Mod - Base Game Systems: Combat Engagement
// Location: /src/base/
// ##FQX - ##FQXnote.: Version 1.2.0 (20250611.194510CDT)
//
// ##FQXnote.
//   v1.2.0 - Transcribed the body for the 'ChooseTurn' function from the
//            canonical QRRQC source to resolve a 'function has no body'
//            linker error.
//   v1.1.0 - Removed redundant definition of 'CheckAttack' to resolve a
//            'redeclaration of function body' error. The canonical version
//            is now in bgs_ai.qc.
// ##Quedra:
//   v1.0.1 - Removed redundant/conflicting function definitions.
//   v1.0.0 - Initial refactoring for FQX Phoenix.
//=============================================================================

/*
A monster is in fight mode if it thinks it can effectively attack its
enemy. When it decides it can't attack, it goes into hunt mode.
*/

// ##Quedra: These globals are defined here. They are not functions.
float	enemy_visible, enemy_infront, enemy_range;
float	enemy_yaw;

// ##Quedra: These are forward declarations for functions within this file.
void() knight_atk1;
void() knight_runatk1;
void() ogre_smash1;
void() ogre_swing1;
void() sham_smash1;
void() sham_swingr1;
void() sham_swingl1;
float()	DemonCheckAttack;
void(float side)	Demon_Melee;

// ##FQXnote.: TRANSCRIPTION - Added function body to resolve linker error.
void(vector dest) ChooseTurn =
{
	self.ideal_yaw = vectoyaw(dest - self.origin);
};

void() knight_attack =
{
	local float		len;
	
	// decide if now is a good swing time
	len = vlen(self.enemy.origin+self.enemy.view_ofs - (self.origin+self.view_ofs));
	
	if (len<80)
		knight_atk1 ();
	else
		knight_runatk1 ();
};

//=============================================================================

/*
=============
ai_melee
=============
*/
void() ai_melee =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	ldmg = (random() + random() + random()) * 3;
	T_Damage (self.enemy, self, self, ldmg);
};

void() ai_melee_side =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	ai_charge_side();
	
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ldmg = (random() + random() + random()) * 3;
	T_Damage (self.enemy, self, self, ldmg);
};

//=============================================================================

/*
===========
SoldierCheckAttack
============
*/
float() SoldierCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;

	if (trace_ent != targ)
		return FALSE;
	if (time < self.attack_finished)
		return FALSE;
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if (enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 0;

	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (1 + random());
		if (random() < 0.3)
			self.lefty = !self.lefty;

		return TRUE;
	}

	return FALSE;
};

//=============================================================================

/*
===========
ShamCheckAttack
============
*/
float() ShamCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_visible)
		return FALSE;
		
	targ = self.enemy;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	if (vlen(spot1 - spot2) > 600)
		return FALSE;

	traceline (spot1, spot2, FALSE, self);
	if (trace_inopen && trace_inwater)
		return FALSE;

	if (trace_ent != targ)
	{
		return FALSE;
	}

	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (2 + 2*random());
	return TRUE;
};

//============================================================================

/*
===========
OgreCheckAttack
============
*/
float() OgreCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	local float		chance;

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	if (!enemy_visible)
		return FALSE;
	targ = self.enemy;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);
	if (trace_inopen && trace_inwater)
		return FALSE;

	if (trace_ent != targ)
	{
		return FALSE;
	}

	if (time < self.attack_finished)
		return FALSE;
	if (enemy_range == RANGE_FAR)
		return FALSE;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.10;
	else if (enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 0;

	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (1 + 2*random());
	return TRUE;
};

// =======================================================================
// ##FQX - ##FQXnote.: Version 1.2.0
// ##File: bgs_fight.qc
// =======================================================================