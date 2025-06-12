// =======================================================================
//
//  ##File: bgs_subs.qc
//  ##File Description: Base Game Systems - General Subroutines
//  ##FQX - ##FQXnote.: Version 1.3.0 (20250611.054522CDT)
//
//  ##FQXnote.
//    v1.3.0 - Removed SUB_AttackFinished. The function has been relocated
//             to bgs_ai.qc to resolve a circular dependency.
//    v1.2.1 - Reverted incorrect 'strcat' implementation.
//    v1.2.0 - Transcribed 'makevectorsfixed'.
//    v1.1.0 - Corrected 'visible' function call.
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

	// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	// calculate length of vector
	len = vlen (vdestdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;
	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;
	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);
	// qcc won't take vec/float
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
	// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	// calculate length of vector
	len = vlen (destdelta);

	// divide by speed to get time to reach dest
	traveltime = len / tspeed;
	// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;
	// scale the destdelta vector by the time spent traveling to get velocity
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
	//
	// check for a delay
	//
	if (self.delay)
	{
		// create a temp object to fire at a later time
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


//
// print the message
//
	if (activator.classname == "player" && self.message != string_null)
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	//
	// kill the killtagets
	//
	if (self.killtarget != string_null)
	{
		t = find (world, targetname, self.killtarget);
		while( t )
		{
			remove (t);
			t = find (t, targetname, self.killtarget);
		}
	}

	//
	// fire targets
	//
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
// ##FQX - ##FQXnote.: Version 1.3.0
// ##File: bgs_subs.qc
// =======================================================================