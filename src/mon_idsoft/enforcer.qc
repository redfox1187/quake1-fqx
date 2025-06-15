// =======================================================================
//
// ##File: mon_idsoft/enforcer.qc
// ##Project Version: FQX Phoenix v0.5.0
// ##File Description: AI logic for the Enforcer entity.
// ##File Version: 2.0.1 (20250614.221814CDT)
//
// v2.0.1 - Corrected model reference for Enforcer head from 'progs/h_enfor.mdl'
//          to 'progs/h_mega.mdl' to resolve "Mod_NumForName: ... not found"
//          error upon map transition, ensuring vanilla asset compatibility. ##FIREFQX:
// v2.0.0 - Complete re-analysis from a clean slate to ensure absolute accuracy.
//        - Corrected function name collision while preserving original QuakeC
//          assignment syntax to guarantee parser compatibility.
//        - Corrected self-induced syntax hallucination on 'enforcer_fire' function.
//        - Reverted unnecessary changes to 'setsize' to maintain original logic.
//        - Verified and retained all necessary annotations for external dependencies.
//
// ##IDSOFT - This is a vanilla QuakeC file.
//
// =======================================================================

// ##FQXnote.: Internal forward declarations to prevent "used before defined" errors.
void() enf_stand1;
void() enf_walk1;
void() enf_run1;
void() enf_atk1;
void() enforcer_die;
void(entity attacker, float damage) enforcer_pain;
void() enf_die1;

$cd /raid/quake/id1/models
$origin 0 0 24
$base base
$skin skin

$frame enf_stn1 enf_stn2 enf_stn3 enf_stn4 enf_stn5
$frame enf_run1 enf_run2 enf_run3 enf_run4 enf_run5 enf_run6 enf_run7 enf_run8 enf_run9 enf_run10 enf_run11 enf_run12
$frame enf_pain1 enf_pain2 enf_pain3
$frame enf_painb1 enf_painb2 enf_painb3
$frame enf_painc1 enf_painc2 enf_painc3 enf_painc4 enf_painc5
$frame enf_paind1 enf_paind2 enf_paind3 enf_paind4 enf_paind5 enf_paind6 enf_paind7 enf_paind8 enf_paind9 enf_paind10 enf_paind11 enf_paind12 enf_paind13
$frame enf_die1 enf_die2 enf_die3 enf_die4 enf_die5 enf_die6 enf_die7 enf_die8 enf_die9 enf_die10 enf_die11 enf_die12
$frame enf_a1 enf_a2 enf_a3 enf_a4 enf_a5 enf_a6 enf_a7 enf_a8 enf_a9 enf_a10 enf_a11 enf_a12 enf_a13 enf_a14 enf_a15


// ==================================================================
// Stand - Enforcer Stand Animations
// ==================================================================
void() enf_stand1 = [$enf_stn1, enf_stand2] {ai_stand();};
void() enf_stand2 = [$enf_stn2, enf_stand3] {ai_stand();};
void() enf_stand3 = [$enf_stn3, enf_stand4] {ai_stand();};
void() enf_stand4 = [$enf_stn4, enf_stand5] {ai_stand();};
void() enf_stand5 = [$enf_stn5, enf_stand1] {ai_stand();};


// ==================================================================
// Walk - Enforcer Walk Animations
// ==================================================================
void() enf_walk1  = [$enf_run1,  enf_walk2]  {ai_walk(5);};
void() enf_walk2  = [$enf_run2,  enf_walk3]  {ai_walk(5);};
void() enf_walk3  = [$enf_run3,  enf_walk4]  {ai_walk(5);};
void() enf_walk4  = [$enf_run4,  enf_walk5]  {ai_walk(5);};
void() enf_walk5  = [$enf_run5,  enf_walk6]  {ai_walk(5);};
void() enf_walk6  = [$enf_run6,  enf_walk7]  {ai_walk(5);};
void() enf_walk7  = [$enf_run7,  enf_walk8]  {ai_walk(5);};
void() enf_walk8  = [$enf_run8,  enf_walk9]  {ai_walk(5);};
void() enf_walk9  = [$enf_run9,  enf_walk10] {ai_walk(5);};
void() enf_walk10 = [$enf_run10, enf_walk11] {ai_walk(5);};
void() enf_walk11 = [$enf_run11, enf_walk12] {ai_walk(5);};
void() enf_walk12 = [$enf_run12, enf_walk1]  {ai_walk(5);};

// ==================================================================
// Run - Enforcer Run Animations
// ==================================================================
void() enf_run1  = [$enf_run1,  enf_run2]  {ai_run(12);};
void() enf_run2  = [$enf_run2,  enf_run3]  {ai_run(12);};
void() enf_run3  = [$enf_run3,  enf_run4]  {ai_run(12);};
void() enf_run4  = [$enf_run4,  enf_run5]  {ai_run(12);};
void() enf_run5  = [$enf_run5,  enf_run6]  {ai_run(12);};
void() enf_run6  = [$enf_run6,  enf_run7]  {ai_run(12);};
void() enf_run7  = [$enf_run7,  enf_run8]  {ai_run(12);};
void() enf_run8  = [$enf_run8,  enf_run9]  {ai_run(12);};
void() enf_run9  = [$enf_run9,  enf_run10] {ai_run(12);};
void() enf_run10 = [$enf_run10, enf_run11] {ai_run(12);};
void() enf_run11 = [$enf_run11, enf_run12] {ai_run(12);};
void() enf_run12 = [$enf_run12, enf_run1]  {ai_run(12);};


// ==================================================================
// Attack - Enforcer Attack Logic
// ==================================================================

// ##FQXnote.: EXTERNAL DEPENDENCY: Functions 'spawn_shot_spark' and 'LaunchLaser'
// ##FQXnote.: must have forward declarations in the global 'defs/' files to resolve
// ##FQXnote.: the 'Unknown value' compilation error.
void enforcer_fire(float side)
{
	local vector	dir;

	sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	self.effects = self.effects | EF_MUZZLEFLASH;

	makevectors (self.angles);
	dir = normalize (self.enemy.origin - self.origin);
	traceline(self.origin + self.view_ofs, self.enemy.origin, FALSE, self);

	if(trace_ent.classname=="player")
		spawn_shot_spark(trace_endpos);
	LaunchLaser (self.origin + self.view_ofs + v_forward*20 + side*v_right, dir);
}

void() enf_atk1  = [$enf_a1,  enf_atk2]  {};
void() enf_atk2  = [$enf_a2,  enf_atk3]  {};
void() enf_atk3  = [$enf_a3,  enf_atk4]  {};
void() enf_atk4  = [$enf_a4,  enf_atk5]  {};
void() enf_atk5  = [$enf_a5,  enf_atk6]  {};
void() enf_atk6  = [$enf_a6,  enf_atk7]  {enforcer_fire(8);};
void() enf_atk7  = [$enf_a7,  enf_atk8]  {};
void() enf_atk8  = [$enf_a8,  enf_atk9]  {};
void() enf_atk9  = [$enf_a9,  enf_atk10] {};
void() enf_atk10 = [$enf_a10, enf_atk11] {enforcer_fire(-8);};
void() enf_atk11 = [$enf_a11, enf_atk12] {};
void() enf_atk12 = [$enf_a12, enf_atk13] {};
void() enf_atk13 = [$enf_a13, enf_atk14] {};
void() enf_atk14 = [$enf_a14, enf_atk15] { self.weaponframe = 0; SUB_CheckRefire(); };
void() enf_atk15 = [$enf_a15, enf_run1]  {};


// ==================================================================
// Pain - Enforcer Pain Animations
// ==================================================================

// ##FQXnote.: CORRECTED: Renamed from 'enf_pain' to 'enforcer_pain_action' to resolve
// ##FQXnote.: a critical name collision with the main pain handler. This definition
// ##FQXnote.: preserves the original file's assignment syntax to ensure compatibility.
void() enforcer_pain_action =
{
	self.weaponframe = 0;
	ai_pain(3);
};
void() enf_pain1  = [$enf_pain1,  enf_pain2]  {};
void() enf_pain2  = [$enf_pain2,  enf_pain3]  {};
// ##FQXnote.: CORRECTED: Call updated to the new, non-conflicting function name.
void() enf_pain3  = [$enf_pain3,  enf_run1]   {enforcer_pain_action();};

void() enf_painb1 = [$enf_painb1, enf_painb2] {};
void() enf_painb2 = [$enf_painb2, enf_painb3] {};
// ##FQXnote.: CORRECTED: Call updated to the new, non-conflicting function name.
void() enf_painb3 = [$enf_painb3, enf_run1]   {enforcer_pain_action();};

void() enf_painc1 = [$enf_painc1, enf_painc2] {};
void() enf_painc2 = [$enf_painc2, enf_painc3] {};
void() enf_painc3 = [$enf_painc3, enf_painc4] {};
void() enf_painc4 = [$enf_painc4, enf_painc5] {};
// ##FQXnote.: CORRECTED: Call updated to the new, non-conflicting function name.
void() enf_painc5 = [$enf_painc5, enf_run1]   {enforcer_pain_action();};

// ##FQXnote.: EXTERNAL DEPENDENCY: The 'too many parameters' warning for 'ai_painforward'
// ##FQXnote.: confirms its forward declaration in 'defs/defs_fqx_fdec_monsters.qc'
// ##FQXnote.: is incorrect (likely 'void()') and must be corrected to 'void(float dist)'.
void() enf_paind1  = [$enf_paind1,  enf_paind2]  {};
void() enf_paind2  = [$enf_paind2,  enf_paind3]  {};
void() enf_paind3  = [$enf_paind3,  enf_paind4]  {};
void() enf_paind4  = [$enf_paind4,  enf_paind5]  {ai_painforward(1);};
void() enf_paind5  = [$enf_paind5,  enf_paind6]  {ai_painforward(1);};
void() enf_paind6  = [$enf_paind6,  enf_paind7]  {};
void() enf_paind7  = [$enf_paind7,  enf_paind8]  {};
void() enf_paind8  = [$enf_paind8,  enf_paind9]  {};
void() enf_paind9  = [$enf_paind9,  enf_paind10] {};
void() enf_paind10 = [$enf_paind10, enf_paind11] {};
void() enf_paind11 = [$enf_paind11, enf_paind12] {ai_painforward(1);};
void() enf_paind12 = [$enf_paind12, enf_paind13] {ai_painforward(1);};
void() enf_paind13 = [$enf_paind13, enf_run1]    {ai_painforward(1);};

void(entity attacker, float damage) enforcer_pain =
{
	local float r;

	if (self.pain_finished > time)
		return;

	r = random();
	if (r < 0.25)
	{
		sound (self, CHAN_VOICE, "enforcer/enf_pain1.wav", 1, ATTN_NORM);
		self.pain_finished = time + 1;
		enf_pain1 ();
	}
	else if (r < 0.5)
	{
		sound (self, CHAN_VOICE, "enforcer/enf_pain2.wav", 1, ATTN_NORM);
		self.pain_finished = time + 1;
		enf_painb1 ();
	}
	else if (r < 0.75)
	{
		sound (self, CHAN_VOICE, "enforcer/enf_pain1.wav", 1, ATTN_NORM);
		self.pain_finished = time + 1;
		enf_painc1 ();
	}
	else
	{
		sound (self, CHAN_VOICE, "enforcer/enf_pain2.wav", 1, ATTN_NORM);
		self.pain_finished = time + 1;
		enf_paind1 ();
	}
};

// ==================================================================
// Death - Enforcer Death Logic
// ==================================================================
void() enforcer_die =
{
// check for gib
	if (self.health < -40)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", -30);
		ThrowGib ("progs/gib2.mdl", -30);
		ThrowGib ("progs/gib3.mdl", -30);
		ThrowHead ("progs/h_mega.mdl", -30); // Corrected model reference
		self.deadflag = DEAD_DEAD;
		return;
	}

	sound (self, CHAN_VOICE, "enforcer/enf_deth.wav", 1, ATTN_NORM);
	self.think = enf_die1;
	self.nextthink = time;
};

// ##FQXnote.: EXTERNAL DEPENDENCY: The 'too many parameters' warning for 'ai_forward'
// ##FQXnote.: confirms its forward declaration in 'defs/defs_fqx_fdec_monsters.qc'
// ##FQXnote.: is incorrect (likely 'void()') and must be corrected to 'void(float dist)'.
void() enf_die1  = [$enf_die1,  enf_die2]  {};
void() enf_die2  = [$enf_die2,  enf_die3]  {};
void() enf_die3  = [$enf_die3,  enf_die4]  {ai_forward(2);};
void() enf_die4  = [$enf_die4,  enf_die5]  {ai_forward(3);};
void() enf_die5  = [$enf_die5,  enf_die6]  {ai_forward(5);};
void() enf_die6  = [$enf_die6,  enf_die7]  {};
void() enf_die7  = [$enf_die7,  enf_die8]  {};
void() enf_die8  = [$enf_die8,  enf_die9]  {ai_forward(1);};
void() enf_die9  = [$enf_die9,  enf_die10] {ai_forward(3);};
void() enf_die10 = [$enf_die10, enf_die11] {ai_forward(2);};
void() enf_die11 = [$enf_die11, enf_die12] {ai_forward(1);};
void() enf_die12 = [$enf_die12, enf_die12] {self.solid=SOLID_NOT;};


// ==================================================================
// Spawn - Enforcer Spawn Function
// ==================================================================

/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 24)
*/
void() monster_enforcer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/enforcer.mdl");
	precache_model ("progs/h_mega.mdl"); // Corrected model reference
	precache_sound ("enforcer/enf_pain1.wav");
	precache_sound ("enforcer/enf_pain2.wav");
	precache_sound ("enforcer/enf_deth.wav");
	precache_sound ("enforcer/enfire.wav");
	precache_sound ("enforcer/enf_idle1.wav");
	precache_sound ("enforcer/enf_sight.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/enforcer.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 80;

	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_die = enforcer_die;
	self.th_missile = enf_atk1;
	self.th_pain = enforcer_pain;

	walkmonster_start();
};

// =======================================================================
//
// Project: FQX Phoenix v0.5.0
// File: mon_idsoft/enforcer.qc - File Version: 2.0.1
// Last Coder: ##FIREFQX:
// =======================================================================