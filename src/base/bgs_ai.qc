// =======================================================================
//
//  ##File: bgs_ai.qc
//  ##File Description: Base Game Systems - Core AI Logic
//  ##FQX - ##FQXnote.: Version 1.4.2 (20250612.043459CDT)
//
//  ##FQXnote.
//   v1.4.2 - Corrected a formatting error where authortags were not
//            properly commented out.
//   v1.4.1 - Corrected call to non-standard 'makevectorsfixed'. Replaced
//            with the standard 'makevectors' built-in to resolve
//            compiler error while preserving the function's intent.
//
// =======================================================================

// ##FQXnote.: Global variables used by the AI think frames.
float enemy_visible, enemy_infront, enemy_range, enemy_yaw;

entity	sight_entity;
float	sight_entity_time;

float(float v) anglemod =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

// =======================================================================
// SIGHT & RANGE
// =======================================================================
float(entity viewer, entity target) visible =
{
	local vector	spot1, spot2;

	spot1 = viewer.origin + viewer.view_ofs;
	spot2 = target.origin + target.view_ofs;
	traceline (spot1, spot2, TRUE, viewer);

	if (trace_inopen && trace_inwater)
		return FALSE;

	if (trace_ent == target)
		return TRUE;
	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};

float(entity targ) range =
{
	local vector	spot1, spot2;
	local float		r;
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	r = vlen (spot1 - spot2);
	if (r < 120)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

float(entity targ) infront =
{
	local vector	vec;
	local float		dot;

	makevectors(self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;

	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};

// =======================================================================
// TARGETING & AI STATE UTILITIES
// =======================================================================
void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;
	self.attack_finished = time + normal;
};

void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);
};

void() SightSound =
{
	if ( self.classname == "enforcer" ) {
		local float rsnd;
		rsnd = rint( random() * 3 );
		if (rsnd == 1)
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
		else if (rsnd == 2)
			sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		else if (rsnd == 0)
			sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, self.noise4, 1, ATTN_NORM);
	} else {
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
};

void() FoundTarget =
{
	if (self.enemy.classname == "player")
	{
		sight_entity = self;
		sight_entity_time = time;
	}

	self.show_hostile = time + 1;

	SightSound ();
	HuntTarget ();
};

void() FindTarget =
{
	local entity	client;
	local float		r;

	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return;
	}

	if (client == self.enemy)
		return;

	if (client.flags & FL_NOTARGET)
		return;
	if (client.items & IT_INVISIBILITY)
		return;

	r = range (client);
	if (r == RANGE_FAR)
		return;

	if (!visible(self, client))
		return;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return;
	}
	else if (r == RANGE_MID)
	{
		if ( !infront (client))
			return;
	}

	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return;
		}
	}

	FoundTarget ();
};


//==============================================================================
// CORE AI MOVEMENT & STATE LOGIC
//==============================================================================

void(float dist) ai_forward = { walkmove (self.angles_y, dist); };
void(float dist) ai_back = { walkmove ( (self.angles_y+180), dist); };
void(float dist) ai_pain = { ai_back (dist); };
void(float dist) ai_painforward = { walkmove (self.ideal_yaw, dist); };

void(float dist) ai_walk =
{
	movedist = dist;
	FindTarget();
	if(self.enemy)
		return;
	movetogoal (dist);
};

void() ai_stand =
{
	FindTarget();
	if (self.enemy)
		return;
	if (time > self.pausetime)
	{
		self.th_walk ();
		return;
	}
};

void() ai_turn =
{
	FindTarget();
	if (self.enemy)
		return;
	ChangeYaw ();
};

float() FacingIdeal =
{
	local	float	delta;
	delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};

void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();

	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};

void() ai_run_slide =
{
	local float	ofs;
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;

	if (walkmove (self.ideal_yaw + ofs, movedist))
		return;
	self.lefty = 1 - self.lefty;
	walkmove (self.ideal_yaw - ofs, movedist);
};

void(float dist) ai_run =
{
	movedist = dist;

	if (self.enemy.health <= 0)
	{
		self.enemy = world;
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{
			if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();
		return;
		}
	}

	self.show_hostile = time + 1;
	if (visible(self, self.enemy))
		self.search_time = time + 5;

	if (coop && self.search_time < time)
	{
		FindTarget();
		if (self.enemy)
			return;
	}

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);

	if (self.attack_state == AS_MISSILE)
	{
		ai_run_missile ();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
		ai_run_melee ();
		return;
	}

	if (CheckAnyAttack ())
		return;

	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide ();
		return;
	}

	movetogoal( dist );
};

//==============================================================================
// CORE AI ACTION & ATTACK LOGIC
//==============================================================================

float() CheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	local float		chance;

	targ = self.enemy;

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE;

	if (trace_inopen && trace_inwater)
		return FALSE;

	if (enemy_range == RANGE_MELEE)
	{
		if (self.th_melee)
		{
			if (self.classname == "monster_knight")
				knight_attack ();
			else
				self.th_melee ();
			return TRUE;
		}
	}

	if (!self.th_missile)
		return FALSE;

	if (time < self.attack_finished)
		return FALSE;

	if (enemy_range == RANGE_FAR)
		return FALSE;

	if (enemy_range == RANGE_MELEE)
	{
		chance = 0.9;
		self.attack_finished = 0;
	}
	else if (enemy_range == RANGE_NEAR)
	{
		if (self.th_melee)
			chance = 0.2;
		else
			chance = 0.4;
	}
	else if (enemy_range == RANGE_MID)
	{
		if (self.th_melee)
			chance = 0.05;
		else
			chance = 0.1;
	}
	else
		chance = 0;

	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
};

float() CheckAnyAttack =
{
	if (!enemy_visible)
		return FALSE;
	if (self.classname == "monster_army")
		return SoldierCheckAttack ();
	if (self.classname == "monster_ogre")
		return OgreCheckAttack ();
	if (self.classname == "monster_shambler")
		return ShamCheckAttack ();
	if (self.classname == "monster_demon1")
		return DemonCheckAttack ();
	if (self.classname == "monster_dog")
		return DogCheckAttack ();
	if (self.classname == "monster_wizard")
		return WizardCheckAttack ();
	return CheckAttack ();
};

float() ai_checkattack = { return CheckAttack(); };

void() ai_face =
{
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();
};

void(entity monster, float d) ai_charge =
{
	ai_face ();
	movetogoal (d);
};

void() ai_charge_side =
{
	local	vector	dtemp;
	local	float	heading;

	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw ();

	// ##FQXnote.. Corrected to use the standard 'makevectors' built-in.
	// ##FQXnote.. This preserves the intended strafing logic.
	makevectors(self.angles);

	dtemp = self.enemy.origin - 30*v_right;
	heading = vectoyaw(dtemp - self.origin);

	walkmove(heading, 20);
};

// =======================================================================
// ##FQX - ##FQXnote.: Version 1.4.2
// ##File: bgs_ai.qc
// =======================================================================