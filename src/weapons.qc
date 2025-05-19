/* Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// Standard game functions
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
	
	precache_sound ("enforcer/enfire.wav");		// laser sound
		precache_model ("progs/laser.mdl");	// laser model
		precache_model ("progs/v_rahpm1.mdl"); // RAHP view model

	precache_sound ("weapons/usp-reload_magin.wav");
	precache_sound ("weapons/usp-reload_magout.wav");
	precache_sound ("weapons/usp_unsil-1.wav");
	precache_sound ("weapons/usp_unsil-2.wav");
	precache_sound ("weapons/usp-suppressed-1.wav");

		precache_model ("progs/bit.mdl");	// model to use for shotgun pellet
		precache_model ("progs/v_dbshot.mdl");	// Double Barrel Shotgun view model

		precache_model ("progs/bullet.mdl"); // Small model for bullet
		precache_model ("progs/v_ump45.mdl");	// UMP45 view model
	precache_sound ("weapons/ump45-1.wav");		// UMP shot sound
	precache_sound ("weapons/boltback.wav");	// dry weapon sound (UMP)
	precache_sound ("weapons/weaponclick.wav");		// weapon switch/click sound
	
	    precache_model("progs/v_ak47.mdl"); // Ak47 view model
    precache_sound("weapons/ak47-fire-1.wav");      // Ak47 firing sound
    precache_sound("weapons/ak47-fire-2.wav");      // Ak47 firing sound
    precache_sound("weapons/ak47_switch.wav");    // Ak47 mode switch/select sound
	
	// ##Quedra: M93R Sounds (Using RAHP view model, already precached)
	precache_sound ("weapons/9mm_Pistol-1.wav");        // ##Quedra: New
	precache_sound ("weapons/9mm_Pistol-2.wav");        // ##Quedra: New
	precache_sound ("weapons/9mm_Pistol_Switch-01.wav"); // ##Quedra: New
	// ##Quedra: End M93R Precache
	
		precache_model ("progs/grapple_anchor.mdl");	// grapple's hook
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20); // Assuming SpawnBlood is defined elsewhere
		T_Damage (trace_ent, self, self, 20);
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================
vector() wall_velocity =
{
	local vector	vel;
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};

void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectorsfixed(self.angles); // Assuming makevectorsfixed is defined elsewhere (e.g. subs.qc)

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
	missile.nextthink = time + 1;
	missile.think = SUB_Remove; // Assuming SUB_Remove is defined

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

void(float damage) spawn_touchblood =
{
	local vector	vel;
	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};

void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

//==============================================================================
// MULTI-DAMAGE
//==============================================================================
entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

//==============================================================================
// BULLETS (TraceAttack based - for original Shotgun/SuperShotgun)
//==============================================================================
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	makevectors(self.v_angle);

	src = self.origin + v_forward*10; 
	src_z = self.absmin_z + self.size_z * 0.7; 

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction); 

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};



//==============================================================================
// ROCKETS
//==============================================================================
void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr"); 
	self.solid = SOLID_NOT;
	s_explode1 (); 
};

void() T_MissileTouch =
{
	local float	damg;
	if (other == self.owner) return;		
	if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }
	damg = 100 + random()*20;
	if (other.health) { if (other.classname == "monster_shambler") damg = damg * 0.5; T_Damage (other, self, self.owner, damg ); }
	T_RadiusDamage (self, self.owner, 120, other); 
	self.origin = self.origin - 8*normalize(self.velocity); 
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY); WriteByte (MSG_BROADCAST, TE_EXPLOSION); 
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y); WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion ();
};

void() W_FireRocket =
{
	local	entity missile;
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM); 
	self.punchangle_x = -2;
	missile = spawn (); missile.owner = self; missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX; missile.classname = "missile";
	makevectors (self.v_angle); missile.velocity = aim(self, 1000); 
	missile.velocity = missile.velocity * 1000; missile.angles = vectoangles(missile.velocity);
	missile.touch = T_MissileTouch; missile.nextthink = time + 5; missile.think = SUB_Remove;
	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*8 + '0 0 16'); 
};

//===============================================================================
// LIGHTNING
//===============================================================================
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity e1, e2; local vector f_spread, beam_dir;
	beam_dir = normalize(p2 - p1); 
    f_spread_x = -beam_dir_y; f_spread_y = beam_dir_x; f_spread_z = 0; 
	f_spread = normalize(f_spread) * 16;
	e1 = e2 = world; 
	traceline (p1, p2, FALSE, from); 
	if (trace_ent.takedamage) { particle (trace_endpos, '0 0 100', 225, damage*4);
	T_Damage (trace_ent, from, from, damage); }
	e1 = trace_ent; 
	traceline (p1 + f_spread, p2 + f_spread, FALSE, from);
	if (trace_ent != e1 && trace_ent.takedamage) { particle (trace_endpos, '0 0 100', 225, damage*4); T_Damage (trace_ent, from, from, damage); }
	e2 = trace_ent; 
	traceline (p1 - f_spread, p2 - f_spread, FALSE, from);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage) { particle (trace_endpos, '0 0 100', 225, damage*4);
	T_Damage (trace_ent, from, from, damage); }
};

void() W_FireLightning =
{
	local vector org; local float cells_consumed;
	if (self.ammo_cells < 1) { self.weapon = W_BestWeapon (); W_SetCurrentAmmo (); return; }
	if (self.waterlevel > 1) { cells_consumed = self.ammo_cells;
	self.ammo_cells = 0; W_SetCurrentAmmo (); T_RadiusDamage (self, self, 35 * cells_consumed, world); return; }
	if (self.t_width < time) { sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM); self.t_width = time + 0.6; }
	self.punchangle_x = -2;
	self.currentammo = self.ammo_cells = self.ammo_cells - 1; 
	org = self.origin + '0 0 16'; 
    makevectors(self.v_angle);
	traceline (org, org + v_forward*600, TRUE, self); 
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY); WriteByte (MSG_BROADCAST, TE_LIGHTNING2); 
	WriteEntity (MSG_BROADCAST, self); WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y); WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x); WriteCoord (MSG_BROADCAST, trace_endpos_y); WriteCoord (MSG_BROADCAST, trace_endpos_z);
	LightningDamage (org, trace_endpos + v_forward*4, self, 30); 
};

//=============================================================================
// GRENADES
//=============================================================================
void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 120, world); 
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION); 
	WriteCoord (MSG_BROADCAST, self.origin_x); WriteCoord (MSG_BROADCAST, self.origin_y); WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion (); 
};

void() GrenadeTouch =
{
	if (other == self.owner) return;		
	if (other.takedamage == DAMAGE_AIM) { GrenadeExplode(); return; }
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0') self.avelocity = '0 0 0'; 
};

void() W_FireGrenade =
{
	local entity missile;
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1; 
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM); 
	self.punchangle_x = -2;
	missile = spawn ();
	missile.owner = self; missile.movetype = MOVETYPE_BOUNCE; missile.solid = SOLID_BBOX; missile.classname = "grenade";
	makevectors (self.v_angle);
	if (self.v_angle_x) missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else { missile.velocity = aim(self, 10000);
	missile.velocity = missile.velocity * 600; missile.velocity_z = 200; }
	missile.avelocity = '300 300 300'; missile.angles = vectoangles(missile.velocity);
	missile.touch = GrenadeTouch;
	missile.nextthink = time + 2.5; missile.think = GrenadeExplode;
	setmodel (missile, "progs/grenade.mdl"); setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin); 
};

//===============================================================================
// PLAYER WEAPON USE
//===============================================================================
void() w_rahpm1_SetCurrentAmmo;

void() w_dbshot_SetCurrentAmmo;
void() w_ump45_SetCurrentAmmo;
void() w_ak47_SetCurrentAmmo;
void() w_m93r_SetCurrentAmmo;

void() W_SetCurrentAmmo =
{
	player_run ();		
	self.weaponframe = 0;
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
	if (self.weapon == IT_SLOT_MELEE)
	{
		self.currentammo = 0; 
		self.weaponmodel = "progs/v_axe.mdl";
	}
	else if (self.weapon == IT_SLOT_HOLDOUT) 
{
    // ##Quedra: Check which holdout weapon is equipped via loadout system
    if (GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT) == WEAPON_ID_M93R)
    {
        w_m93r_SetCurrentAmmo();
    }
    else // Default to RAHP M1 if not M93R or if GetWeaponIDForITSlot isn't fully implemented yet
    {
        w_rahpm1_SetCurrentAmmo();
    }
}
	else if (self.weapon == IT_SLOT_SECONDARY) 
	{
		w_dbshot_SetCurrentAmmo (); 
	}
	else if (self.weapon == IT_SLOT_PRIMARY) 
	{
		w_ump45_SetCurrentAmmo ();
	}
	else if (self.weapon == IT_SLOT_HEAVY) 
	{
		w_ak47_SetCurrentAmmo (); 
	}
	else if (self.weapon == IT_SLOT_UTILITY) 
	{
		self.currentammo = 0; 
		self.weaponmodel = "progs/v_axe.mdl";
	}
	else if (self.weapon == IT_SLOT_AUX1) 
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_SLOT_AUX2) 
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.items = self.items | IT_CELLS;
	}
	else 
	{
		self.currentammo = 0;
		self.weaponmodel = string_null;
	}
};

void(string msg) Quick_Melee_DebugPrint; 
void() Quick_Melee_End;

float() W_BestWeapon =
{
	local	float	it;
	it = self.items;
    if (self.quick_melee_active == 1) 
    {
        Quick_Melee_DebugPrint("Already in quick melee, canceling");
        Quick_Melee_End();
    }

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_SLOT_AUX2) )
		return IT_SLOT_AUX2;
	else if(self.ammo_nails >= 1 && (it & IT_SLOT_HEAVY) ) 
		return IT_SLOT_HEAVY;
	else if(self.ammo_shells >= 1 && (it & IT_SLOT_SECONDARY) )
		return IT_SLOT_SECONDARY;
	else if(self.ammo_nails >= 1 && (it & IT_SLOT_PRIMARY) ) 
		return IT_SLOT_PRIMARY;

	return IT_SLOT_HOLDOUT; 
};

float(entity playerEnt, float old, float new) W_WantsToChangeWeapon =
{
	float playerFlags = CheckPlayerEXFlags(playerEnt); // Assuming CheckPlayerEXFlags is defined
	if((playerFlags & PEF_CHANGENEVER) != 0) { return 0; }
	if(((playerFlags & PEF_CHANGEONLYNEW) != 0) && old == new) { return 0; }
	return 1;
};

float() W_HasNoAmmo =
{
	if (self.currentammo > 0) return FALSE;
	if (self.weapon == IT_SLOT_MELEE) return FALSE;
    if (self.weapon == IT_SLOT_HOLDOUT) 
    {
        // RAHP's primary mode has currentammo = 0 but can fire.
        // Assumes RAHP_FIREMODE_IDX_SMALL_LASER is globally defined as 0 (e.g. in defs.qc)
        if (self.current_weapon_fire_mode == RAHP_FIREMODE_IDX_SMALL_LASER) 
             return FALSE;
    }
	self.weapon = W_BestWeapon ();
	W_SetCurrentAmmo ();
	return TRUE;
};

/*
============
W_Attack
============
*/
void()	player_axe1; void() player_axeb1; void() player_axec1; void() player_axed1;
void()	player_shot1; void() player_nail1;
void() player_light1; void() player_rocket1;

void()	W_FireRahp; void() W_FireDBShot; void() W_FireUMP45; void() W_FireAk47; void() W_FireM93R;
// W_FireShotgun, W_FireSuperShotgun, W_FireRocket, W_FireLightning are defined above.

void() W_Attack =
{
	local	float	r;
	if (self.quick_melee_active == 1) { Quick_Melee_DebugPrint("Already in quick melee, canceling"); Quick_Melee_End(); return; }
	if ( W_HasNoAmmo() ) { return; }
	makevectors	(self.v_angle);
	self.show_hostile = time + 1;	
	if (!(self.weapon == IT_SLOT_MELEE || self.weapon == IT_SLOT_HOLDOUT)) { self.fired_weapon = 1; }

	if (self.weapon == IT_SLOT_MELEE)
	{ sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM); r = random();
		if (r < 0.25) player_axe1 ();
		else if (r<0.5) player_axeb1 (); else if (r<0.75) player_axec1 (); else player_axed1 ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SLOT_HOLDOUT) 
	{ 
		player_shot1(); // Assuming generic firing animation start
		if (GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT) == WEAPON_ID_M93R)
		{
			W_FireM93R();
		}
		else // Default to RAHP M1
		{
			W_FireRahp(); 
		}
	}
	else if (self.weapon == IT_SLOT_SECONDARY) { player_shot1 (); W_FireDBShot (); } 
	else if (self.weapon == IT_SLOT_PRIMARY) { player_shot1 (); W_FireUMP45 (); }
	else if (self.weapon == IT_SLOT_HEAVY) { player_shot1 (); W_FireAk47 (); }
	else if (self.weapon == IT_SLOT_UTILITY) { player_rocket1(); }
	else if (self.weapon == IT_SLOT_AUX1) { player_rocket1(); W_FireRocket(); self.attack_finished = time + 0.8; }
	else if (self.weapon == IT_SLOT_AUX2) { player_light1();
	sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM); W_FireLightning(); /* attack_finished handled by W_FireLightning */}
    // Need to add cases for standard Shotgun and SuperShotgun if they are distinct weapon slots
    // and not just alternate fire modes of IT_SLOT_SECONDARY or IT_SLOT_HOLDOUT.
    // For now, assuming they are not primary selectable weapons that W_Attack dispatches to.
    // If they were, e.g., IT_SHOTGUN, you'd add:
    // else if (self.weapon == IT_SHOTGUN) { player_shot1(); W_FireShotgun(); self.attack_finished = time + 0.5; } // Example cooldown
};

/*
============
W_ChangeWeapon
============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl; fl = it = self.items;
	am = 0; 
	if (self.impulse == 1) { fl = IT_SLOT_MELEE; }
	else if (self.impulse == 2) { fl = IT_SLOT_HOLDOUT; } 
	else if (self.impulse == 3) { fl = IT_SLOT_SECONDARY; if (self.ammo_shells < 1) am = 1; }		
	else if (self.impulse == 4) { fl = IT_SLOT_PRIMARY; if (self.ammo_nails < 1) am = 1; }
	else if (self.impulse == 5) { fl = IT_SLOT_HEAVY; if (self.ammo_nails < 1) am = 1; }
	else if (self.impulse == 6) { fl = IT_SLOT_UTILITY; }
	else if (self.impulse == 7) { fl = IT_SLOT_AUX1; if (self.ammo_rockets < 1) am = 1; }
	else if (self.impulse == 8) { fl = IT_SLOT_AUX2; if (self.ammo_cells < 1) am = 1; }
	self.impulse = 0; 
	if (!(self.items & fl)) { sprint (self, "$qc_no_weapon"); return; }
	if (am) { sprint (self, "$qc_not_enough_ammo"); return; }
	self.weapon = fl; W_SetCurrentAmmo (); 
};

/*
============
CheatCommand
============
*/
void CheatCommand() {
	if ( ( deathmatch || coop ) && cvar("developer") == 0 ) { return; } // Use cvar("developer")
	self.ammo_rockets = 100; self.ammo_nails = 200; self.ammo_shells = 100;
	self.items = self.items | IT_SLOT_MELEE | IT_SLOT_HOLDOUT | IT_SLOT_SECONDARY |
		IT_SLOT_PRIMARY | IT_SLOT_HEAVY | IT_SLOT_UTILITY | IT_SLOT_AUX1 | IT_KEY1 | IT_KEY2;
	self.ammo_cells = 200; self.items = self.items | IT_SLOT_AUX2;
	self.armortype = 0.8; self.armorvalue = 200;
	self.items = self.items - ( self.items & ( IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3 ) ) + IT_ARMOR3;
	self.weapon = IT_SLOT_AUX1; self.impulse = 0; W_SetCurrentAmmo ();
};

// CycleWeaponCommand, ServerflagsCommand, QuadCheat
//void() CycleWeaponCommand; // Assuming defined elsewhere or stub
//void() CycleWeaponReverseCommand; // Assuming defined elsewhere or stub
void() ServerflagsCommand = { serverflags = serverflags * 2 + 1; };
void() QuadCheat = { if (cvar("developer") == 0 && (deathmatch || coop)) return; self.super_time = 1;
self.super_damage_finished = time + 30; self.items = self.items | IT_QUAD; dprint ("quad cheat\n"); };

/*
============
ToggleFireMode - Updated to use new generic system for supported weapons
============
*/
void() ToggleFireMode =
{
	if (self.weapon == IT_SLOT_HOLDOUT) 
	{ 
		if (GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT) == WEAPON_ID_M93R)
		{
			W_SwitchModeM93R();
		}
		else // Default to RAHP M1
		{
			W_SwitchModeRahp();
		}
	}
    else if (self.weapon == IT_SLOT_SECONDARY) { W_SwitchModeDBShot(); }
    else if (self.weapon == IT_SLOT_PRIMARY) { W_SwitchModeUMP45(); }
    else if (self.weapon == IT_SLOT_HEAVY) { W_SwitchModeAk47(); }
    else if (self.weapon == IT_SLOT_UTILITY) { sprint(self, "Utility slot mode switch TBD\n"); }
    else if (self.weapon == IT_SLOT_AUX1) { sprint(self, "Rocket Launcher mode switch TBD\n"); }
    else if (self.weapon == IT_SLOT_AUX2) { sprint(self, "Lightning Gun mode switch TBD\n"); }
};

/*
============
Quick Grenade (Restored from earlycopy_weapons.txt)
============
*/
void() Quick_Grenade =
{
    // float previousWeapon = self.weapon;
    // Not needed if W_FireGrenade doesn't change self.weapon
    if (self.ammo_rockets >=1)
    {
        W_FireGrenade();
        self.attack_finished = time + 0.6;
    }
    else
    {
        sprint(self, "$qc_not_enough_ammo");
        // Optionally play a dry fire sound
        // sound(self, CHAN_WEAPON, "weapons/boltback.wav", 1, ATTN_NORM);
        return;
    }
};

/*
============
Quick Melee
============
*/
void(string msg) Quick_Melee_DebugPrint =
{
    if (self.quick_melee_debug) { dprint("QuickMelee: "); dprint(msg); dprint("\n"); }
};

void() Quick_Melee_End =
{
    Quick_Melee_DebugPrint("Melee End start func");
    if (self.quick_melee_active && self.saved_weapon)
    {
        self.think = SUB_Null;
        self.quick_melee_active = 0; self.quick_melee_sequence = 0;
        float weapon_to_restore = self.saved_weapon; self.saved_weapon = 0;
        Quick_Melee_DebugPrint("Switching back to saved weapon");
        player_run();
        self.weapon = weapon_to_restore; W_SetCurrentAmmo();
    }
    else
    {
        Quick_Melee_DebugPrint("End called but not active or no saved weapon");
        self.quick_melee_active = 0; self.saved_weapon = 0;
        self.quick_melee_sequence = 0; self.think = SUB_Null;
    }
};

void() Quick_Melee_FrameAdvance =
{
    if (self.weaponframe < 5)  // Assuming axe animation frames
    {
        self.weaponframe = self.weaponframe + 1;
        if (self.weaponframe == 3) // Hit frame
        { W_FireAxe(); Quick_Melee_DebugPrint("Frame 3: Calling W_FireAxe()"); }
    }
    else
    { self.weaponframe = 0; Quick_Melee_End(); return; }
    self.think = Quick_Melee_FrameAdvance; self.nextthink = time + 0.1;
};

void() Quick_Melee_Start =
{
    Quick_Melee_DebugPrint("Start called");
    if (self.weapon == IT_SLOT_MELEE) { Quick_Melee_DebugPrint("Already using axe, normal attack"); W_Attack(); return; }
    if (self.quick_melee_active == 1) { Quick_Melee_DebugPrint("Already in quick melee, canceling"); Quick_Melee_End(); return; }
    
    // Check if self.weapon is a valid weapon that can be saved, not 0 or melee.
    if (self.weapon && self.weapon != IT_SLOT_MELEE) 
    {
        self.saved_weapon = self.weapon;
        self.quick_melee_active = 1;
        Quick_Melee_DebugPrint("Saved weapon and switching to axe");
        self.quick_melee_sequence = floor(random() * 4); // For varied axe animations
        self.weapon = IT_SLOT_MELEE; W_SetCurrentAmmo();
        self.weaponframe = 1; // Start axe animation
        sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
        self.think = Quick_Melee_FrameAdvance;
        self.nextthink = time + 0.1;
    }
    else
    { Quick_Melee_DebugPrint("No valid weapon to save for Quick Melee or already axe."); }
};

void() Quick_Melee_ToggleDebug =
{
    self.quick_melee_debug = !self.quick_melee_debug;
    if (self.quick_melee_debug) sprint(self, "Quick Melee Debug: ON\n");
    else sprint(self, "Quick Melee Debug: OFF\n");
};

void() Quick_Melee_ForceCancel =
{
    self.quick_melee_active = 0; self.saved_weapon = 0;
    self.quick_melee_sequence = 0; self.think = SUB_Null;
    sprint(self, "Quick Melee state reset\n");
};

/*
============
ImpulseCommands
============
*/
//void() grapple_release; // Forward declaration for grapple logic

void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8) W_ChangeWeapon ();
	if (self.impulse == 9) CheatCommand ();
//	if (self.impulse == 10) CycleWeaponCommand (); 
	if (self.impulse == 11) ServerflagsCommand ();
//	if (self.impulse == 12) CycleWeaponReverseCommand(); 
	if (self.impulse == 20) Quick_Grenade();	
    if (self.impulse == 21 && self.quick_melee_active != 1) Quick_Melee_Start();
	if (self.impulse == 22) ToggleFireMode();	
    // Grappling hook impulses (23, 24, 25) from your file
    if (self.impulse == 200) Quick_Melee_ToggleDebug();
    if (self.impulse == 201) Quick_Melee_ForceCancel();
	// ##Quedra: Impulse to apply the loadout defined by the 'ql_master_key' cvar
	// ##Quedra: This block is being removed as per reversion process.
	// if (self.impulse == 211) 
	// {
	// 	Loadout_ApplyMasterKeyConfig();
	// 	self.impulse = 0; 
	// }
	if (self.impulse == 255) QuadCheat ();
	self.impulse = 0;
};


/*
============
W_WeaponFrame
============
*/
void() W_WeaponFrame =
{
    if (time < self.attack_finished) 
    {
        // ##Quedra: Weapon is in cooldown.
        if (self.button0) 
        {
            // ##Quedra: Player is pressing/holding the fire button DURING cooldown.
            // ##Quedra: This action "spoils" any previous release. The player must release
            // ##Quedra: and press again *after* the cooldown to fire a new semi/burst action.
            self.weapon_fire_released = FALSE;
        }
        else
        {
            // ##Quedra: Player is NOT pressing fire button during cooldown.
            // ##Quedra: This means they released it. AM_WeaponFrame_HandleFireRelease will set weapon_fire_released = TRUE.
            // ##Quedra: Also, handle burst interruption if fire released during an active burst.
            AM_WeaponFrame_HandleFireRelease(); // ##Quedra: Sets self.weapon_fire_released = TRUE

            // ##Quedra: Generalized burst stop logic if fire button is released mid-burst.
            if (self.burst_active) 
            {
                self.burst_active = FALSE; // ##Quedra: Signal AM_Burst_Think to stop.
                                           // ##Quedra: AM_Burst_Think will handle nulling its own think, 
                                           // ##Quedra: setting attack_finished, and resetting recoil on its next execution.
            }
        }
        return; // ##Quedra: Done for this frame, weapon is busy.
    }

    // ##Quedra: If we reach here, cooldown is OVER (time >= self.attack_finished).
    if (self.impulse)
    {
        ImpulseCommands();
        // ##Quedra: If an impulse changed the weapon, W_SetCurrentAmmo would have been called.
    }
    
    if (self.button0) // ##Quedra: Player is pressing fire, and cooldown is over.
    {
        SuperDamageSound(); 
        W_Attack(); // ##Quedra: W_Attack will call the weapon's W_Fire<WeaponName> function.
                    // ##Quedra: That function uses AM_CanFireSemiAuto() which checks self.weapon_fire_released.
    }
    else // ##Quedra: Player is NOT pressing fire, and cooldown is over.
    {
        AM_WeaponFrame_HandleFireRelease(); // ##Quedra: This will correctly set weapon_fire_released = TRUE.
        
        // ##Quedra: Generalized burst stop logic if fire button is released (also handles cases where cooldown might have just ended).
        // ##Quedra: This is a bit redundant if the above block during cooldown already caught it, but ensures state is correct.
        if (self.burst_active) 
        {
            self.burst_active = FALSE; 
        }
    }
};

/*
========
SuperDamageSound
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};