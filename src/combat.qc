//=============================================================================
// combat.qc - FQX Mod - Core Combat & Damage Functions (DIAGNOSTIC)
// Location: /src/
// ##FQXCUSTOM - ##Quedra: Version 1.0.2d
// ##Quedra: Diagnostic version to test engine-level function call integrity
// ##Quedra: between T_Damage and FoundTarget.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    ... (license text remains the same) ...
    See file, 'COPYING', for details. */

// Forward declarations
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
void() monster_death_use;
void() FoundTarget;

// Global variables
float   killed_monsters;
entity  damage_attacker;
float   teamplay;
float   skill;
float   coop;

//=============================================================================
// ##IDSOFT - ##Quedra: CanDamage
//=============================================================================
float(entity targ, entity inflictor) CanDamage =
{
	// bmodels need special checking because their origin is '0 0 0'
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Killed
//=============================================================================
void(entity targ, entity attacker) Killed =
{
	local entity oself;
	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99;

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, etc.
		self.th_die();
		self = oself;
		return;
	}

	self.enemy = attacker;

	if (self.flags & FL_MONSTER)
	{
		killed_monsters = killed_monsters + 1;
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
		if (attacker.classname == "player")
			attacker.frags = attacker.frags + 1;
		
		if (attacker != self && attacker.flags & FL_MONSTER)
		{
			WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
			WriteString(MSG_ALL, "ACH_FRIENDLY_FIRE");
		}
	}

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	monster_death_use();
	self.th_die();
	
	self = oself;
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_Damage
//=============================================================================
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local vector dir;
	local entity oldself;
	local float save;
	local float take;

	if (!targ.takedamage)
		return;

	if (coop && targ != attacker && targ.classname == "player" && attacker.classname == "player")
	{
		if (attacker.flags & FL_ISBOT && !(targ.flags & FL_ISBOT))
			return;
	}    

	if (targ.classname == "monster_oldone" && damage < 9999)
		return;

	damage_attacker = attacker;
	if (attacker.super_damage_finished > time)
		damage = damage * 4;

	save = ceil(targ.armortype * damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage - save);

	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK))
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir * damage * 8;
	}

	if (targ.flags & FL_GODMODE)
		return;

	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

	if ((teamplay == 1 && targ != attacker) && (targ.team > 0) && (targ.team == attacker.team))
		return;

	if (targ.classname == "player" && take != 0)
		targ.took_damage = TRUE;

	targ.health = targ.health - take;
	if (targ.health <= 0)
	{
		Killed(targ, attacker);
		return;
	}

	oldself = self;
	self = targ;

	if ((self.flags & FL_MONSTER) && attacker != world)
	{
		if (self != attacker && attacker != self.enemy)
		{
			if ((self.classname != attacker.classname) || (self.classname == "monster_army"))
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				// ##Quedra: This is the diagnostic check.
				if (cvar("developer") > 0) { dprint("T_Damage: Attempting to call FoundTarget for ", self.classname, "\n"); }
				FoundTarget();
			}
		}
	}

	if (self.th_pain)
	{
		self.th_pain(attacker, take);
		if (skill == 3)
			self.pain_finished = time + 5;
	}

	self = oldself;
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_RadiusDamage
//=============================================================================
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local float points;
	local entity head;
	local vector org;

	head = findradius(inflictor.origin, damage + 40);
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs) * 0.5;
				points = 0.5 * vlen(inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;

				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage(head, inflictor))
					{
						if (head.classname == "monster_shambler")                        
							T_Damage(head, inflictor, attacker, points * 0.5);
						else
							T_Damage(head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_BeamDamage
//=============================================================================
void(entity attacker, float damage) T_BeamDamage =
{
	local float points;
	local entity head;

	head = findradius(attacker.origin, damage + 40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5 * vlen(attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage(head, attacker))
				{
					if (head.classname == "monster_shambler")                        
						T_Damage(head, attacker, attacker, points * 0.5);
					else
						T_Damage(head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};

//=============================================================================
// combat.qc - FQX Mod - Core Combat & Damage Functions - END
// ##FQXCUSTOM - ##Quedra: Version 1.0.2d
//=============================================================================