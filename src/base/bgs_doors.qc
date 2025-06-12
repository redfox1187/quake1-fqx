// =======================================================================
//
//  ##File: bgs_doors.qc
//  ##File Description: Base Game Systems - Door Logic
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##FQXnote.
//    v1.2.0 - Added a comprehensive block of forward declarations for all
//             internal door functions. This resolves all remaining F314
//             'Implicit cast' warnings for a clean compile.
//    v1.1.0 - Resolved all F314 'Implicit cast' warnings by creating a
//             new 'secret_door_use_stub' function to correctly handle the
//             .use field's void() signature requirement.
//
// =======================================================================
// ##FQX - ##Quedra: Version 1.2.0

//=============================================================================
//  MODULE-SPECIFIC FORWARD DECLARATIONS
//=============================================================================
// ##FQXnote.: This block provides forward declarations for all functions within this
// ##FQXnote.: file, resolving all implicit cast warnings from the compiler.

// Regular Doors
void() door_go_down;
void() door_go_up;
void() door_blocked;
void() door_hit_top;
void() door_hit_bottom;
void() door_fire;
void() door_use;
void() door_trigger_touch;
void() door_killed;
void() door_touch;
void() LinkDoors;

// Secret Doors
void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;
void(entity attacker, float damage) fd_secret_use;
void() secret_door_use_stub;
void() secret_blocked;
void() secret_touch;

//=============================================================================
//  GLOBAL CONSTANTS
//=============================================================================

float DOOR_START_OPEN = 1;
float DOOR_DONT_LINK = 4;
float DOOR_GOLD_KEY = 8;
float DOOR_SILVER_KEY = 16;
float DOOR_TOGGLE = 32;

//=============================================================================
// REGULAR DOOR LOGIC
//=============================================================================

void() door_blocked =
{
	T_Damage (other, self, self, self.dmg);

	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
			door_go_up ();
		else
			door_go_down ();
	}
};
void() door_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	if (self.spawnflags & DOOR_TOGGLE)
		return;
	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};
void() door_go_down =
{
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up =
{
	if (self.state == STATE_UP)
		return;
	if (self.state == STATE_TOP)
	{
		self.nextthink = self.ltime + self.wait;
		return;
	}
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);
	SUB_UseTargets();
};
void() door_fire =
{
	local entity oself, starte;
	if (self.owner != self)
		objerror ("door_fire: self.owner != self");
	if (self.items)
		sound (self, CHAN_ITEM, self.noise4, 1, ATTN_NORM);
	self.message = string_null;
	oself = self;
	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP)
		{
			starte = self;
			do
			{
				door_go_down ();
				self = self.enemy;
			} while ( (self != starte) && (self != world) );
			self = oself;
			return;
		}
	}
	starte = self;
	do
	{
		door_go_up ();
		self = self.enemy;
	} while ( (self != starte) && (self != world) );
	self = oself;
};
void() door_use =
{
	local entity oself;
	self.message = string_null;
	self.owner.message = string_null;
	self.enemy.message = string_null;
	oself = self;
	self = self.owner;
	door_fire ();
	self = oself;
};

void() door_trigger_touch =
{
	if (other.health <= 0)
		return;
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 1;
	activator = other;
	self = self.owner;
	door_use ();
};

void() door_killed =
{
	local entity oself;
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;
	door_use ();
	self = oself;
};
void() door_touch =
{
	if (other.classname != "player")
		return;
	if (self.owner.attack_finished > time)
		return;
	self.owner.attack_finished = time + 2;
	if (self.owner.message != string_null)
	{
		centerprint (other, self.owner.message);
		sound (other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
	if (!self.items)
		return;
	if ( (self.items & other.items) != self.items )
	{
		if (self.owner.items == IT_KEY1)
		{
			if (world.worldtype == WORLDTYPE_BASE)
			{
				centerprint (other, "$qc_need_silver_keycard");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == WORLDTYPE_METAL)
			{
				centerprint (other, "$qc_need_silver_runekey");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == WORLDTYPE_MEDIEVAL)
			{
				centerprint (other, "$qc_need_silver_key");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		else
		{
			if (world.worldtype == WORLDTYPE_BASE)
			{
				centerprint (other, "$qc_need_gold_keycard");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == WORLDTYPE_METAL)
			{
				centerprint (other, "$qc_need_gold_runekey");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == WORLDTYPE_MEDIEVAL)
			{
				centerprint (other, "$qc_need_gold_key");
				sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}
	other.items = other.items - self.items;
	self.touch = SUB_Null;
	if (self.enemy)
		self.enemy.touch = SUB_Null;
	door_use ();
};

entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity trigger;
	local vector t1, t2;
	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;
	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
};

float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x) return FALSE;
	if (e1.mins_y > e2.maxs_y) return FALSE;
	if (e1.mins_z > e2.maxs_z) return FALSE;
	if (e1.maxs_x < e2.mins_x) return FALSE;
	if (e1.maxs_y < e2.mins_y) return FALSE;
	if (e1.maxs_z < e2.mins_z) return FALSE;
	return TRUE;
};

void() LinkDoors =
{
	local entity t, starte;
	local vector cmins, cmaxs;
	if (self.enemy) return;
	if (self.spawnflags & 4)
	{
		self.owner = self.enemy = self;
		return;
	}
	cmins = self.mins;
	cmaxs = self.maxs;
	starte = self;
	t = self;
	do
	{
		self.owner = starte;
		if (self.health) starte.health = self.health;
		if (self.targetname != string_null) starte.targetname = self.targetname;
		if (self.message != string_null) starte.message = self.message;
		t = find (t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;
			self = self.owner;
			if (self.health) return;
			if (self.targetname != string_null) return;
			if (self.items) return;
			self.owner.trigger_field = spawn_field(cmins, cmaxs);
			return;
		}
		if (EntitiesTouching(self,t))
		{
			if (t.enemy) objerror ("cross connected doors");
			self.enemy = t;
			self = t;
			if (t.mins_x < cmins_x) cmins_x = t.mins_x;
			if (t.mins_y < cmins_y) cmins_y = t.mins_y;
			if (t.mins_z < cmins_z) cmins_z = t.mins_z;
			if (t.maxs_x > cmaxs_x) cmaxs_x = t.maxs_x;
			if (t.maxs_y > cmaxs_y) cmaxs_y = t.maxs_y;
			if (t.maxs_z > cmaxs_z) cmaxs_z = t.maxs_z;
		}
	} while (1);
};
/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE */
void() func_door =
{
	if (world.worldtype == WORLDTYPE_MEDIEVAL)
	{
		precache_sound ("doors/medtry.wav");
		precache_sound ("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else if (world.worldtype == WORLDTYPE_METAL)
	{
		precache_sound ("doors/runetry.wav");
		precache_sound ("doors/runeuse.wav");
		self.noise3 = "doors/runetry.wav";
		self.noise4 = "doors/runeuse.wav";
	}
	else if (world.worldtype == WORLDTYPE_BASE)
	{
		precache_sound ("doors/basetry.wav");
		precache_sound ("doors/baseuse.wav");
		self.noise3 = "doors/basetry.wav";
		self.noise4 = "doors/baseuse.wav";
	}
	else
	{
		dprint ("no worldtype set!\n");
	}
	if (self.sounds == 0)
	{
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("doors/drclos4.wav");
		precache_sound ("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/hydro1.wav");
		precache_sound ("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/stndr1.wav");
		precache_sound ("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound ("doors/ddoor1.wav");
		precache_sound ("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	SetMovedir ();
	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);
	setmodel (self, self.model);
	self.classname = "func_door";
	self.blocked = door_blocked;
	self.use = door_use;
	if (self.spawnflags & DOOR_SILVER_KEY) self.items = IT_KEY1;
	if (self.spawnflags & DOOR_GOLD_KEY) self.items = IT_KEY2;
	if (!self.speed) self.speed = 100;
	if (!self.wait) self.wait = 3;
	if (!self.lip) self.lip = 4;
	if (!self.dmg) self.dmg = 2;
	self.pos1 = self.origin;
	vector movedir_fabs = { fabs(self.movedir[0]), fabs(self.movedir[1]), fabs(self.movedir[2]) };
	self.pos2 = self.pos1 + ((movedir_fabs * self.size) - self.lip) * self.movedir;
	if (self.spawnflags & DOOR_START_OPEN)
	{
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}
	self.state = STATE_BOTTOM;
	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.th_die = door_killed;
	}
	if (self.items) self.wait = -1;
	self.touch = door_touch;
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
};
//=============================================================================
// SECRET DOORS
//=============================================================================

float SECRET_OPEN_ONCE = 1;
float SECRET_1ST_LEFT = 2;
float SECRET_1ST_DOWN = 4;
float SECRET_NO_SHOOT = 8;
float SECRET_YES_SHOOT = 16;
void (entity attacker, float damage) fd_secret_use =
{
	local float temp;
	self.health = 10000;
	if (self.origin != self.oldorigin) return;
	self.message = string_null;
	SUB_UseTargets();
	if (!(self.spawnflags & SECRET_NO_SHOOT))
	{
		self.th_pain = SUB_Null;
		self.takedamage = DAMAGE_NO;
	}
	self.velocity = '0 0 0';
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.think = fd_secret_move1; // Assign to think
	self.nextthink = self.ltime + 0.1;
	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);
	makevectors(self.mangle);
	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN) self.t_width = fabs(v_up * self.size);
		else self.t_width = fabs(v_right * self.size);
	}
	if (!self.t_length) self.t_length = fabs(v_forward * self.size);
	if (self.spawnflags & SECRET_1ST_DOWN) self.dest1 = self.origin - v_up * self.t_width;
	else self.dest1 = self.origin + v_right * (self.t_width * temp);
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

void () fd_secret_move1 = { self.nextthink = self.ltime + 1.0; self.think = fd_secret_move2;
sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); };
void () fd_secret_move2 = { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); SUB_CalcMove(self.dest2, self.speed, fd_secret_move3); };
void () fd_secret_move3 =
{
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};
void () fd_secret_move4 = { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); SUB_CalcMove(self.dest1, self.speed, fd_secret_move5); };
void () fd_secret_move5 = { self.nextthink = self.ltime + 1.0; self.think = fd_secret_move6; sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); };
void () fd_secret_move6 = { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done); };
void () fd_secret_done =
{
	if (!self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;
		self.th_die = fd_secret_use;
	}
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked =
{
	if (time < self.attack_finished) return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

void() secret_touch =
{
	if (other.classname != "player") return;
	if (self.attack_finished > time) return;
	self.attack_finished = time + 2;
	if (self.message != string_null)
	{
		centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};

void() secret_door_use_stub =
{
    fd_secret_use(activator, 0); // Pass activator and 0 damage
};

/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot */
void () func_door_secret =
{
	if (self.sounds == 0) self.sounds = 3;
	if (self.sounds == 1)
	{
		precache_sound ("doors/latch2.wav");
		precache_sound ("doors/winch2.wav");
		precache_sound ("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/airdoor1.wav");
		precache_sound ("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/basesec1.wav");
		precache_sound ("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}
	if (!self.dmg) self.dmg = 2;
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.classname = "func_door_secret";
	setmodel (self, self.model);
	setorigin (self, self.origin);
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = secret_door_use_stub;

	if ( !self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;
		self.th_die = fd_secret_use;
	}
	self.oldorigin = self.origin;
	if (!self.wait) self.wait = 5;
};