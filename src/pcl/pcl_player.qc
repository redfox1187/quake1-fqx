// =======================================================================
//
//  ##File: pcl_player.qc
//  ##File Description: Player & Client Logic - Core Player
//  ##FQX - ##FQXnote.: Version 1.2.0 (20250611.060430CDT)
//
//  ##FQXCUSTOM - This file is part of the FQX Phoenix codebase.
//
//  ##FQXnote.
//    v1.2.0 - Transcribed core player state functions (player_pain, PlayerJump,
//             WaterMove, etc.) from QRRQC sources to resolve linker errors.
//    v1.1.0 - Transcribed PlayerPostThink and its dependencies.
//  ##Quedra:
//    v1.0.0 - Initial refactoring and consolidation.
//
// =======================================================================

//=============================================================================
//  MODULE-SPECIFIC GLOBALS & DECLARATIONS
//=============================================================================

float	modelindex_eyes;
float	modelindex_player;

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void() player_die_ax1;
void() DropBackpack;
void() bubble_bob;


//==============================================================================
// PLAYER ANIMATION FRAMES
//==============================================================================

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

// running
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6
// standing
$frame stand1 stand2 stand3 stand4 stand5
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12
// pain
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6
$frame pain1 pain2 pain3 pain4 pain5 pain6
// death
$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6 axdeth7 axdeth8 axdeth9
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8 deatha9 deatha10 deatha11
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8 deathb9
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8 deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15
$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7 deathd8 deathd9
$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7 deathe8 deathe9
// attacks
$frame nailatt1 nailatt2
$frame light1 light2
$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6
$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6
$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6
$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6
$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6

//==============================================================================
// PLAYER ANIMATION LOGIC
//==============================================================================

void() player_run;

void()	player_stand1 =[	$axstnd1,	player_stand1	]
{
	self.weaponframe = 0;
	if (self.velocity_x || self.velocity_y) { self.walkframe=0; player_run(); return; }
	if (self.weapon == IT_AXE)
	{
		if (self.walkframe >= 12) self.walkframe = 0;
		self.frame = $axstnd1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 5) self.walkframe = 0;
		self.frame = $stand1 + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;	
};

void()	player_run =[	$rockrun1,	player_run	]
{
	self.weaponframe = 0;
	if (!self.velocity_x && !self.velocity_y) { self.walkframe=0; player_stand1(); return; }
	if (self.weapon == IT_AXE)
	{
		if (self.walkframe == 6) self.walkframe = 0;
		self.frame = $axrun1 + self.walkframe;
	}
	else
	{
		if (self.walkframe == 6) self.walkframe = 0;
		self.frame = self.frame + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};

void()	player_shot1 =	[$shotatt1, player_shot2	] { self.weaponframe = 1; self.effects = self.effects | EF_MUZZLEFLASH; };
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.weaponframe=2;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.weaponframe=3;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.weaponframe=4;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.weaponframe=5;};
void()	player_shot6 =	[$shotatt6, player_run	] {self.weaponframe=6;};

void()	player_axe1 =	[$axatt1, player_axe2	] {self.weaponframe=1;};
void()	player_axe2 =	[$axatt2, player_axe3	] {self.weaponframe=2;};
void()	player_axe3 =	[$axatt3, player_axe4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axe4 =	[$axatt4, player_run	] {self.weaponframe=4;};

void()	player_axeb1 =	[$axattb1, player_axeb2	] {self.weaponframe=5;};
void()	player_axeb2 =	[$axattb2, player_axeb3	] {self.weaponframe=6;};
void()	player_axeb3 =	[$axattb3, player_axeb4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axeb4 =	[$axattb4, player_run	] {self.weaponframe=8;};

void()	player_axec1 =	[$axattc1, player_axec2	] {self.weaponframe=1;};
void()	player_axec2 =	[$axattc2, player_axec3	] {self.weaponframe=2;};
void()	player_axec3 =	[$axattc3, player_axec4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axec4 =	[$axattc4, player_run	] {self.weaponframe=4;};

void()	player_axed1 =	[$axattd1, player_axed2	] {self.weaponframe=5;};
void()	player_axed2 =	[$axattd2, player_axed3	] {self.weaponframe=6;};
void()	player_axed3 =	[$axattd3, player_axed4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axed4 =	[$axattd4, player_run	] {self.weaponframe=8;};

void() player_nail1   =[$nailatt1, player_nail2  ] 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	if (!self.button0) {player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9) self.weaponframe = 1;
	SuperDamageSound();
	W_FireSpikes (4);
	self.attack_finished = time + 0.2;
};
void() player_nail2   =[$nailatt2, player_nail1  ]
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	if (!self.button0) {player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9) self.weaponframe = 1;
	SuperDamageSound();
	W_FireSpikes (-4);
	self.attack_finished = time + 0.2;
};

void() player_light1   =[$light1, player_light2  ] 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	if (!self.button0) {player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5) self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};
void() player_light2   =[$light2, player_light1  ]
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	if (!self.button0) {player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5) self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};

void() player_rocket1   =[$rockatt1, player_rocket2  ] { self.weaponframe = 1; self.effects = self.effects | EF_MUZZLEFLASH; };
void() player_rocket2   =[$rockatt2, player_rocket3  ] {self.weaponframe=2;};
void() player_rocket3   =[$rockatt3, player_rocket4  ] {self.weaponframe=3;};
void() player_rocket4   =[$rockatt4, player_rocket5  ] {self.weaponframe=4;};
void() player_rocket5   =[$rockatt5, player_rocket6  ] {self.weaponframe=5;};
void() player_rocket6   =[$rockatt6, player_run  ] {self.weaponframe=6;};

//==============================================================================
// PLAYER STATE & PHYSICS LOGIC
//==============================================================================
void() PainSound =
{
	local float rs;
	if (self.health < 0) return;
	if (damage_attacker.classname == "teledeath") { sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE); return; }
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5) sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}
	if (self.watertype == CONTENT_SLIME)
	{
		if (random() > 0.5) sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}
	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5) sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}
	if (self.pain_finished > time) { self.axhitme = 0; return; }
	self.pain_finished = time + 0.5;
	if (self.axhitme == 1) { self.axhitme = 0; sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM); return; }
	rs = rint((random() * 5) + 1);
	self.noise = string_null;
	if (rs == 1) self.noise = "player/pain1.wav";
	else if (rs == 2) self.noise = "player/pain2.wav";
	else if (rs == 3) self.noise = "player/pain3.wav";
	else if (rs == 4) self.noise = "player/pain4.wav";
	else if (rs == 5) self.noise = "player/pain5.wav";
	else self.noise = "player/pain6.wav";
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
};

void()	player_pain1 =	[	$pain1,	player_pain2	] {PainSound();self.weaponframe=0;};
void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {PainSound();self.weaponframe=0;};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run	] {};

void() PlayerDead =
{
	self.nextthink = -1;
	self.deadflag = DEAD_DEAD;
};
void() DeathBubblesSpawn =
{
	local entity bubble;
	if (self.owner.waterlevel != 3) return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count) remove(self);
};

void(float num_bubbles) DeathBubbles =
{
	local entity bubble_spawner;
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
};

void() DeathSound =
{
	local float rs;
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	rs = rint ((random() * 4) + 1);
	if (rs == 1) self.noise = "player/death1.wav";
	else if (rs == 2) self.noise = "player/death2.wav";
	else if (rs == 3) self.noise = "player/death3.wav";
	else if (rs == 4) self.noise = "player/death4.wav";
	else if (rs == 5) self.noise = "player/death5.wav";
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
};

vector(float dm) VelocityForDamage =
{
	local vector v;
	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();
	if (dm > -50) v = v * 0.7;
	else if (dm > -200) v = v * 2;
	else v = v * 10;
	return v;
};

void(string gibname, float dm) ThrowGib =
{
	local	entity new;
	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	if (cvar("pr_checkextension")) if (checkextension("EX_MOVETYPE_GIB")) new.movetype = MOVETYPE_GIB;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	if (cvar("pr_checkextension")) if (checkextension("EX_MOVETYPE_GIB")) self.movetype = MOVETYPE_GIB;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = VelocityForDamage (dm);
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};

void() GibPlayer =
{
	ThrowHead ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);
	self.deadflag = DEAD_DEAD;
	if (damage_attacker.classname == "teledeath" || damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
	if (random() < 0.5) sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	local float i;
	self.items = self.items - (self.items & ( IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD ) );
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.effects = 0;
	self.modelindex = modelindex_player;
	if (deathmatch || coop) DropBackpack();
	self.weaponmodel = string_null;
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10) self.velocity_z = self.velocity_z + random()*300;
	if (self.health < -40) { GibPlayer (); return; }
	DeathSound();
	self.angles_x = 0;
	self.angles_z = 0;
	i = ( 1 + floor( random() * 6 ) );
	if (self.weapon == IT_AXE) player_die_ax1 ();
	else if (i == 1) player_diea1();
	else if (i == 2) player_dieb1();
	else if (i == 3) player_diec1();
	else if (i == 4) player_died1();
	else player_diee1();
};

void() set_suicide_frame =
{
	if (self.model != "progs/player.mdl") return;
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};

// Death animation chains
void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead();};
void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};
void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};
void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};
void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};
void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead();};

//==============================================================================
// PLAYER STATE HANDLERS
//==============================================================================
// ##FQXnote.: TRANSCRIPTION - The following functions have been transcribed from
// ##FQXnote.: QRRQC-player.qc.txt and QRRQC-client.qc.txt to resolve 'function has
// ##FQXnote.: no body' errors.

void(entity attacker, float damage) player_pain =
{
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;

	if (self.weapon == IT_AXE)
		player_axpain1 ();
	else
		player_pain1 ();
};

void() PlayerDeathThink =
{
	local float forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;

		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

	if (self.spawn_deferred)
	{
		local entity spot;
		
		spot = SelectSpawnPoint(FALSE);
		if (spot != world || time >= self.spawn_deferred) {
			respawn();
		}
		return;
	}

	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;

		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};

void() PlayerJump =
{	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}
		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	self.flags = self.flags - FL_ONGROUND;
	
	self.button2 = 0;
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};

void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;

	if (self.health < 0)
		return;
		
	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}
	
	if (self.watertype == CONTENT_LAVA)
	{
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;
			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
			
		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

	makevectors(self.v_angle);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;
			return;
		}
	}
};

//==============================================================================
// PLAYER POST-THINK & POWERUP LOGIC
//==============================================================================

/*
================
CheckPowerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

	// invisibility
	if (self.invisible_finished)
	{
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}

		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint(self, "$qc_ring_fade");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}
		
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;
	
	// invincibility
	if (self.invincible_finished)
	{
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint(self, "$qc_protection_fade");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_PENTALIGHT;
		else
			self.effects = self.effects - (self.effects & EF_PENTALIGHT);
	}

	// super damage
	if (self.super_damage_finished)
	{
		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint(self, "$qc_quad_fade");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  
			
			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_QUADLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_QUADLIGHT);
	}	

	// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;

		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint(self, "$qc_biosuit_fade");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	
};

/*
================
CheckHealthRot
================
*/
void() CheckHealthRot =
{
	if ( !( self.items & IT_SUPERHEALTH ) )
	{
		return;
	}

	if ( self.healthrot_nextcheck > time )
	{
		return;
	}

	if ( self.health > self.max_health )
	{
		self.health = self.health - 1;
		self.healthrot_nextcheck = time + 1;
		return;
	}

	self.items = self.items - ( self.items & IT_SUPERHEALTH );
	self.healthrot_nextcheck = 0;
};

/*
================
PlayerPostThink
================
*/
void() PlayerPostThink =
{
	if ( self.view_ofs == '0 0 0')
		return;

	if ( self.deadflag )
		return;
		
	W_WeaponFrame ();

	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			if (self.health <= 5)
				self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups();
	CheckHealthRot();
};


// =======================================================================
// ##FQX - ##FQXnote.: Version 1.2.0 (20250611.060430CDT)
// ##File: pcl_player.qc
// =======================================================================