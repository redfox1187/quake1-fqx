// =======================================================================
//
//  ##File: bgs_subs.qc
//  ##File Description: Base Game Systems - General Subroutines
//  ##FIREFQX: Version 1.4.0 (20250612.062154CDT)
//
//  ##FIREFQX
//   v1.4.0 - Added missing path_corner and movetarget_f functions from
//            QRRQC source to fix train pathing.
//   v1.3.0 - Relocated SUB_AttackFinished to bgs_ai.qc.
//
// =======================================================================

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};

/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors(self.angles);
		self.movedir = v_forward;
	}

	self.angles = '0 0 0';
};

void makevectorsfixed(vector ang)
{
	ang_x *= -1;
	makevectors(ang);
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
	// trigger angles are used for one-way touches.
	// An angle of 0 is assumed
	// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = string_null;
};

// ##FIREFQX.. Added functions from QRRQC-ai.qc.txt
void() t_movetarget =
{
	local entity	temp;
	if (other.movetarget != self)
		return;

	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;
	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);

	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};

void() movetarget_f =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	movetarget_f ();
};


/*
=============
SUB_CalcMove
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
	local vector	vdestdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	vdestdelta = tdest - self.origin;
	len = vlen (vdestdelta);

	if (len == 0) // ##FIREFQX.. Avoid division by zero if already at destination
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	traveltime = len / tspeed;
	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	self.nextthink = self.ltime + traveltime;
	self.velocity = vdestdelta * (1/traveltime);
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;

	if (self.think1)
		self.think1();
};

/*
=============
SUB_CalcAngleMove
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
	local vector	destdelta;
	local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	destdelta = destangle - self.angles;
	len = vlen (destdelta);

	if(len == 0)
	{
		self.avelocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		self.think = SUB_CalcAngleMoveDone;
		self.finalangle = destangle;
		self.think1 = func;
		return;
	}

	traveltime = len / tspeed;
	self.nextthink = self.ltime + traveltime;
	self.avelocity = destdelta * (1 / traveltime);
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};

//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets
==============================
*/
void() SUB_UseTargets =
{
	local entity t, act, stemp, otemp;

	if (self.delay)
	{
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}

	if (activator.classname == "player" && self.message != string_null)
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	if (self.killtarget != string_null)
	{
		t = find (world, targetname, self.killtarget);
		while( t )
		{
			remove (t);
			t = find (t, targetname, self.killtarget);
		}
	}

	if (self.target != string_null)
	{
		act = activator;
		t = find (world, targetname, self.target);
		while( t )
		{
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
				self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
			t = find (t, targetname, self.target);
		}
	}
};

void() SUB_CheckRefire =
{
	if (self.attack_finished > time)
		return;

	if (self.enemy == world)
	{
		FindTarget ();
		return;
	}

	if (!visible(self, self.enemy))
	{
		FindTarget ();
		return;
	}

	if (self.attack_finished < time - 2)
		self.attack_finished = time;

	ai_run_missile ();
};

// =======================================================================
// Project: FQX Phoenix
// File: base/bgs_subs.qc - File Version: 1.4.0
// Last Coder: ##FIREFQX
// =======================================================================