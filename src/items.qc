//=============================================================================
// items.qc - FQX Mod - Item Pickup Logic
// ##FQXCUSTOM - ##Quedra: Version 1.1 
// ##Quedra: Based on id Software's original items.qc.
// ##Quedra: v1.1 - Modified weapon_touch, ammo_touch, and BackpackTouch to prevent
// ##Quedra:          automatic weapon switching upon item pickup, as per Soldier's request.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC

    This program is free software;
    you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation;
    either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY;
    without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program;
    if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

void() W_SetCurrentAmmo; // From weapons.qc
float() W_BestWeapon; // From weapons.qc
// ##FQXCUSTOM - ##Quedra: W_WantsToChangeWeapon is defined in weapons.qc, ensure it's globally available or forward declared if needed by other id logic.
// float(entity playerEnt, float old, float new) W_WantsToChangeWeapon; 

// ##FQXCUSTOM - ##Quedra: Forward declare local function if used before definition.
void(float old_weapon_slot, float new_weapon_slot_item_flag) Deathmatch_Weapon;


/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;	// restore original model [cite: 9]
	self.solid = SOLID_TRIGGER;	// allow it to be touched again [cite: 10]
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM); // play respawn sound [cite: 10]
	setorigin (self, self.origin); // [cite: 11]
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at"); // [cite: 11]
	dprint (vtos(self.origin)); // [cite: 12]
	dprint ("\n"); // [cite: 12]
	remove (self); // [cite: 12]
};



/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float	oldz;
	if( self.netname == string_null ) { // [cite: 13]
		if( self.items ) { // [cite: 13]
			self.netname = GetNetName( self.items ); // [cite: 13]
		} else if( self.weapon ) { // [cite: 14]
			self.netname = GetNetName( self.weapon );	 // [cite: 14]
		}
	}

	self.mdl = self.model; // so it can be restored on respawn [cite: 14]
	self.flags = FL_ITEM;		// make extra wide [cite: 15]
	self.solid = SOLID_TRIGGER; // [cite: 15]
	self.movetype = MOVETYPE_TOSS; // [cite: 15]
	self.velocity = '0 0 0'; // [cite: 16]
	self.origin_z = self.origin_z + 6; // [cite: 16]
	oldz = self.origin_z; // [cite: 16]
	if (!droptofloor()) // [cite: 17]
	{
		dprint ("Bonus item fell out of level at "); // [cite: 17]
		dprint (vtos(self.origin)); // [cite: 17]
		dprint ("\n"); // [cite: 17]
		remove(self); // [cite: 17]
		return; // [cite: 17]
	}
};
/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
	self.nextthink = time + 0.2; // items start after other solids [cite: 18]
	self.think = PlaceItem; // [cite: 19]
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0) // [cite: 19]
		return 0; // [cite: 19]
	if ((!ignore) && (e.health >= e.max_health)) // [cite: 20]
		return 0; // [cite: 20]

	healamount = ceil(healamount); // [cite: 20]

	e.health = e.health + healamount; // [cite: 20]
	if ((!ignore) && (e.health >= e.max_health)) // [cite: 21]
		e.health = e.max_health; // [cite: 21]
		
	if (e.health > 250) // [cite: 21]
		e.health = 250; // [cite: 21]

	return 1; // [cite: 21]
};
/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points. [cite: 22]
Rotten box heals 5-10 points, [cite: 23]
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second. [cite: 23]
*/

float	H_ROTTEN = 1; // [cite: 24]
float	H_MEGA = 2; // [cite: 24]
.float	healamount, healtype; // [cite: 24]
void() health_touch;

void() item_health =
{	
	self.touch = health_touch; // [cite: 24]

	if (self.spawnflags & H_ROTTEN) // [cite: 24]
	{
		precache_model("maps/b_bh10.bsp"); // [cite: 24]

		precache_sound("items/r_item1.wav"); // [cite: 24]
		setmodel(self, "maps/b_bh10.bsp"); // [cite: 25]
		self.noise = "items/r_item1.wav"; // [cite: 25]
		self.healamount = 15; // [cite: 25]
		self.healtype = 0; // [cite: 25]
	}
	else if (self.spawnflags & H_MEGA) // [cite: 25]
	{
		precache_model("maps/b_bh100.bsp"); // [cite: 25]
		precache_sound("items/r_item2.wav"); // [cite: 25]
		setmodel(self, "maps/b_bh100.bsp"); // [cite: 25]
		self.noise = "items/r_item2.wav"; // [cite: 26]
		self.healamount = 100; // [cite: 26]
		self.healtype = 2; // [cite: 26]
	}
	else
	{
		precache_model("maps/b_bh25.bsp"); // [cite: 26]
		precache_sound("items/health1.wav"); // [cite: 26]
		setmodel(self, "maps/b_bh25.bsp"); // [cite: 26]
		self.noise = "items/health1.wav"; // [cite: 26]
		self.healamount = 25; // [cite: 26]
		self.healtype = 1; // [cite: 27]
	}

	setsize (self, '0 0 0', '32 32 56'); // [cite: 27]
	StartItem (); // [cite: 27]
};

void() health_touch =
{	
	if (other.classname != "player") // [cite: 27]
		return; // [cite: 27]
	if (self.healtype == 2) // Megahealth?  Ignore max_health... [cite: 28]
	{
		if (other.health >= 250) // [cite: 28]
			return; // [cite: 28]
		if (!T_Heal(other, self.healamount, 1)) // [cite: 28]
			return; // [cite: 28]
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0)) // [cite: 28]
			return; // [cite: 29]
	}
	
	sprint(other, "$qc_item_health", ftos(self.healamount)); // [cite: 29]
	
	// health touch sound [cite: 29]
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM); // [cite: 29]

	stuffcmd (other, "bf\n"); // [cite: 29]
	
	self.model = string_null; // [cite: 29]
	self.solid = SOLID_NOT; // [cite: 29]
	if ( self.healtype == 2 ) { // If we're a MegaHealth - rot down the player's super health [cite: 30]
		other.items = other.items | IT_SUPERHEALTH; // [cite: 31]
		other.healthrot_nextcheck = time + 5; // [cite: 31]
	}

	if ( deathmatch && deathmatch != 2 ) {	// deathmatch 2 is silly old rules [cite: 31]
		if ( self.healtype == 2 ) { // [cite: 31]
			self.nextthink = time + 120; // [cite: 31]
		} else { // [cite: 32]
			self.nextthink = time + 20; // [cite: 32]
		}
	}

	self.think = SUB_regen; // [cite: 32]
	
	activator = other; // [cite: 32]
	SUB_UseTargets();				// fire all targets / killtargets [cite: 32]
};
/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch =
{
	local	float	type, value, bit;

	type = 0.3; // [cite: 33]
	value = 100; // [cite: 33]
	bit = IT_ARMOR1; // [cite: 33]
	
	if (other.health <= 0) // [cite: 33]
		return; // [cite: 33]
	if (other.classname != "player") // [cite: 34]
		return; // [cite: 34]

	if (self.classname == "item_armor1") // [cite: 34]
	{
		type = 0.3; // [cite: 34]
		value = 100; // [cite: 34]
		bit = IT_ARMOR1; // [cite: 35]
	}

	if (self.classname == "item_armor2") // [cite: 35]
	{
		type = 0.6; // [cite: 35]
		value = 150; // [cite: 35]
		bit = IT_ARMOR2; // [cite: 35]
	}

	if (self.classname == "item_armorInv") // [cite: 35]
	{
		type = 0.8; // [cite: 35]
		value = 200; // [cite: 36]
		bit = IT_ARMOR3; // [cite: 36]
	}

	if (other.armortype*other.armorvalue >= type*value) // [cite: 36]
		return; // [cite: 36]
		
	other.armortype = type; // [cite: 36]
	other.armorvalue = value; // [cite: 36]
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit; // [cite: 37]

	self.solid = SOLID_NOT; // [cite: 37]
	self.model = string_null; // [cite: 37]
	if (deathmatch && deathmatch != 2) // [cite: 38]
		self.nextthink = time + 20; // [cite: 38]

	self.think = SUB_regen; // [cite: 38]

	sprint(other, "$qc_item_armor"); // [cite: 38]
	// armor touch sound [cite: 39]
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM); // [cite: 39]
	stuffcmd (other, "bf\n"); // [cite: 39]
	
	activator = other; // [cite: 39]
	SUB_UseTargets(); // fire all targets / killtargets [cite: 40]
};


/*
QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() item_armor1 =
{
	self.touch = armor_touch; // [cite: 40]
	self.armortype = 0.3; // [cite: 41]
	self.armorvalue = 100; // [cite: 41]
	precache_model ("progs/armor.mdl"); // [cite: 41]
	setmodel (self, "progs/armor.mdl"); // [cite: 41]
	self.skin = 0; // [cite: 41]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 42]
	StartItem (); // [cite: 42]
};
/*
QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() item_armor2 =
{
	self.touch = armor_touch; // [cite: 43]
	self.armortype = 0.6; // [cite: 43]
	self.armorvalue = 150; // [cite: 44]
	precache_model ("progs/armor.mdl"); // [cite: 44]
	setmodel (self, "progs/armor.mdl"); // [cite: 44]
	self.skin = 1; // [cite: 44]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 44]
	StartItem (); // [cite: 45]
};

/*
QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() item_armorInv =
{
	self.touch = armor_touch; // [cite: 45]
	self.armortype = 0.8; // [cite: 46]
	self.armorvalue = 200; // [cite: 46]
	precache_model ("progs/armor.mdl"); // [cite: 46]
	setmodel (self, "progs/armor.mdl"); // [cite: 46]
	self.skin = 2; // [cite: 46]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 47]
	StartItem (); // [cite: 47]
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_other_ammo =
{
	if (other.ammo_shells > 300) // [cite: 47]
		other.ammo_shells = 300; // [cite: 47]
	if (other.ammo_nails > 400) // [cite: 48]
		other.ammo_nails = 400; // [cite: 48]

	if (other.ammo_rockets > 100) // [cite: 48]
		other.ammo_rockets = 100;		 // [cite: 48]

	if (other.ammo_cells > 400) // [cite: 48]
		other.ammo_cells = 400;		 // [cite: 48]
};
float(float w) RankForWeapon =
{
	if (w == IT_SLOT_AUX2) // [cite: 49]
		return 1; // [cite: 49]

	if (w == IT_SLOT_AUX1) // [cite: 49]
		return 2; // [cite: 49]

	if (w == IT_SLOT_HEAVY) // [cite: 49]
		return 3; // [cite: 49]
	if (w == IT_SLOT_UTILITY) // [cite: 50]
		return 4; // [cite: 50]

	if (w == IT_SLOT_SECONDARY) // [cite: 50]
		return 5; // [cite: 50]

	if (w == IT_SLOT_PRIMARY) // [cite: 50]
		return 6; // [cite: 50]

	return 7; // [cite: 50]
};

// ##FQXCUSTOM - ##Quedra: WeaponCode function seems unused by current FQX logic, retained from original.
float (float w) WeaponCode =
{
	if (w == IT_SLOT_SECONDARY) // [cite: 51]
		return 3; // [cite: 51]

	if (w == IT_SLOT_PRIMARY) // [cite: 51]
		return 4; // [cite: 51]

	if (w == IT_SLOT_HEAVY) // [cite: 51]
		return 5; // [cite: 51]
	if (w == IT_SLOT_UTILITY) // [cite: 52]
		return 6; // [cite: 52]

	if (w == IT_SLOT_AUX1) // [cite: 52]
		return 7; // [cite: 52]

	if (w == IT_SLOT_AUX2) // [cite: 52]
		return 8; // [cite: 52]

	return 1; // [cite: 52]
};
/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon [cite: 53]

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells; [cite: 53]
=============
*/
// ##FQXCUSTOM - ##Quedra: Note: If Deathmatch_Weapon is called, it *will* change self.weapon if criteria are met.
// ##FQXCUSTOM - ##Quedra: My changes to touch functions aim to prevent this from being called automatically on pickup.
void(float old_current_weapon_slot, float new_picked_weapon_slot_flag) Deathmatch_Weapon =
{
	local float or, nr;

	if ( self.flags & FL_ISBOT ) { // [cite: 54]
		return; // mal: let bots pick their own weapon. [cite: 55]
	} 

	// change self.weapon if desired [cite: 55]
	or = RankForWeapon (self.weapon); // [cite: 55] // Rank of currently equipped weapon
	nr = RankForWeapon (new_picked_weapon_slot_flag); // Rank of the weapon item just picked up [cite: 56]

	if ( nr < or ) // if new weapon has a "better" rank (lower number) [cite: 56]
		self.weapon = new_picked_weapon_slot_flag; // [cite: 56]
};

/*
=============
weapon_touch
=============
*/
void() weapon_touch =
{
	local	float	hadammo, new_item_flag_for_slot; // ##FQXCUSTOM - ##Quedra: Renamed 'new' to 'new_item_flag_for_slot'
	local	entity	player_entity; // ##FQXCUSTOM - ##Quedra: Store player context
	local	float	leave_item; // ##FQXCUSTOM - ##Quedra: Renamed 'leave'

	player_entity = other; // Store player

	if (!(player_entity.flags & FL_CLIENT)) // [cite: 58]
		return; // [cite: 58]

	if (coop || deathmatch == 2 || deathmatch == 3 || deathmatch == 5) // [cite: 59]
		leave_item = 1; // [cite: 59]
	else // [cite: 60]
		leave_item = 0; // [cite: 60]
	
	// Determine which weapon type this item entity represents and give appropriate ammo
	if (self.classname == "weapon_nailgun") // [cite: 60]
	{
		if (leave_item && (player_entity.items & IT_SLOT_PRIMARY) ) // [cite: 60]
			return; // [cite: 60]
		new_item_flag_for_slot = IT_SLOT_PRIMARY; // [cite: 60]
		player_entity.ammo_nails = player_entity.ammo_nails + 30; // [cite: 61]
	}
	else if (self.classname == "weapon_supernailgun") // [cite: 61]
	{
		if (leave_item && (player_entity.items & IT_SLOT_HEAVY) ) // [cite: 61]
			return; // [cite: 61]
		new_item_flag_for_slot = IT_SLOT_HEAVY; // [cite: 62]
		player_entity.ammo_nails = player_entity.ammo_nails + 30; // [cite: 62]
	}
	else if (self.classname == "weapon_supershotgun") // [cite: 62]
	{
		if (leave_item && (player_entity.items & IT_SLOT_SECONDARY) ) // [cite: 62]
			return; // [cite: 62]
		new_item_flag_for_slot = IT_SLOT_SECONDARY; // [cite: 63]
		player_entity.ammo_shells = player_entity.ammo_shells + 15; // [cite: 63]
	}
	else if (self.classname == "weapon_rocketlauncher") // [cite: 64]
	{
		if (leave_item && (player_entity.items & IT_SLOT_AUX1) ) // [cite: 64]
			return; // [cite: 64]
		new_item_flag_for_slot = IT_SLOT_AUX1; // [cite: 64]
		player_entity.ammo_rockets = player_entity.ammo_rockets + 5; // [cite: 65]
	}
	else if (self.classname == "weapon_grenadelauncher") // [cite: 65]
	{
		if (leave_item && (player_entity.items & IT_SLOT_UTILITY) ) // [cite: 65]
			return; // [cite: 65]
		new_item_flag_for_slot = IT_SLOT_UTILITY; // [cite: 66]
		player_entity.ammo_rockets = player_entity.ammo_rockets + 5; // [cite: 66]
	}
	else if (self.classname == "weapon_lightning") // [cite: 66]
	{
		if (leave_item && (player_entity.items & IT_SLOT_AUX2) ) // [cite: 66]
			return; // [cite: 66]
		new_item_flag_for_slot = IT_SLOT_AUX2; // [cite: 67]
		player_entity.ammo_cells = player_entity.ammo_cells + 30; // [cite: 67]
	}
	else
		objerror ("weapon_touch: unknown classname"); // [cite: 67]

	sprint(player_entity, "$qc_got_item", self.netname); // [cite: 67]
	sound (player_entity, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM); // [cite: 68]
	stuffcmd (player_entity, "bf\n"); // [cite: 68]

	// ##FQXCUSTOM - ##Quedra: Call bound_other_ammo with correct 'other' context if it uses 'other'
    local entity store_self_for_bound = self; // self is item
    self = player_entity; // 'other' for bound_other_ammo is the player
    bound_other_ammo(); // [cite: 68]
    self = store_self_for_bound; // Restore self to item

	player_entity.items = player_entity.items | new_item_flag_for_slot; // Grant player the item flag for the weapon slot
	
    // ##FQXCUSTOM - ##Quedra: v1.1 - Removed automatic weapon switching logic.
    // ##FQXCUSTOM - ##Quedra: Player picks up the weapon, it's added to inventory. No forced switch.
    // ##FQXCUSTOM - ##Quedra: W_SetCurrentAmmo() will refresh HUD for the *currently held* weapon.
	if (player_entity.weapon_is_reloading == FALSE)
	{
		if (player_entity.weapon != 0) 
		{
			local entity current_self_context = self;
			self = player_entity;
			W_SetCurrentAmmo();
			self = current_self_context;
		}
	}

	if (leave_item) // [cite: 70]
		return; // [cite: 70]
		
	self.model = string_null; // [cite: 71]
	self.solid = SOLID_NOT; // [cite: 71]
	if (deathmatch && deathmatch != 2) // [cite: 72]
		self.nextthink = time + 30; // [cite: 72]

	self.think = SUB_regen; // [cite: 72]
	
	activator = player_entity; // [cite: 72]
	SUB_UseTargets(); // fire all targets / killtargets [cite: 73]
};


/* QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 73]
void() weapon_supershotgun =
{
	precache_model ("progs/g_shot.mdl"); // [cite: 73]
	setmodel (self, "progs/g_shot.mdl"); // [cite: 74]
	self.weapon = IT_SLOT_SECONDARY; // This is the item flag it represents [cite: 74]
	self.netname = "$qc_double_shotgun"; // [cite: 74]
	self.touch = weapon_touch; // [cite: 74]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 74]
	StartItem (); // [cite: 75]
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 75]
void() weapon_nailgun =
{
	precache_model ("progs/g_nail.mdl"); // [cite: 75]
	setmodel (self, "progs/g_nail.mdl"); // [cite: 75]
	self.weapon = IT_SLOT_PRIMARY; // [cite: 76]
	self.netname = "$qc_nailgun"; // [cite: 76]
	self.touch = weapon_touch; // [cite: 76]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 76]
	StartItem (); // [cite: 76]
};
/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 77]
void() weapon_supernailgun =
{
	precache_model ("progs/g_nail2.mdl"); // [cite: 77]
	setmodel (self, "progs/g_nail2.mdl"); // [cite: 77]
	self.weapon = IT_SLOT_HEAVY; // [cite: 77]
	self.netname = "$qc_super_nailgun"; // [cite: 78]
	self.touch = weapon_touch; // [cite: 78]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 78]
	StartItem (); // [cite: 78]
};
/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 79]
void() weapon_grenadelauncher =
{
	precache_model ("progs/g_rock.mdl"); // [cite: 79]
	setmodel (self, "progs/g_rock.mdl"); // [cite: 79]
	self.weapon = IT_SLOT_UTILITY; // [cite: 79]
	self.netname = "$qc_grenade_launcher"; // [cite: 80]
	self.touch = weapon_touch; // [cite: 80]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 80]
	StartItem (); // [cite: 80]
};
/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 81]
void() weapon_rocketlauncher =
{
	precache_model ("progs/g_rock2.mdl"); // [cite: 81]
	setmodel (self, "progs/g_rock2.mdl"); // [cite: 81]
	self.weapon = IT_SLOT_AUX1; // [cite: 81]
	self.netname = "$qc_rocket_launcher"; // [cite: 82]
	self.touch = weapon_touch; // [cite: 82]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 82]
	StartItem (); // [cite: 82]
};
/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32) */ // [cite: 83]
void() weapon_lightning =
{
	precache_model ("progs/g_light.mdl"); // [cite: 83]
	setmodel (self, "progs/g_light.mdl"); // [cite: 83]
	self.weapon = IT_SLOT_AUX2; // [cite: 83]
	self.netname = "$qc_thunderbolt"; // [cite: 84]
	self.touch = weapon_touch; // [cite: 84]
	setsize (self, '-16 -16 0', '16 16 56'); // [cite: 84]
	StartItem (); // [cite: 84]
};

/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
	local entity player_entity; // ##FQXCUSTOM - ##Quedra: Store player
	player_entity = other;

	if (player_entity.classname != "player") // [cite: 85]
		return; // [cite: 85]

	if (player_entity.health <= 0) // [cite: 85]
		return; // [cite: 85]
	
// shotgun
	if (self.weapon == 1) // [cite: 87] // Corresponds to shells
	{
		if (player_entity.ammo_shells >= 300) // [cite: 87]
			return; // [cite: 87]
		player_entity.ammo_shells = player_entity.ammo_shells + self.aflag; // [cite: 88]
	}
// spikes
	if (self.weapon == 2) // [cite: 88] // Corresponds to nails
	{
		if (player_entity.ammo_nails >= 400) // [cite: 88]
			return; // [cite: 88]
		player_entity.ammo_nails = player_entity.ammo_nails + self.aflag; // [cite: 89]
	}
//	rockets
	if (self.weapon == 3) // [cite: 89] // Corresponds to rockets
	{
		if (player_entity.ammo_rockets >= 100) // [cite: 89]
			return; // [cite: 89]
		player_entity.ammo_rockets = player_entity.ammo_rockets + self.aflag; // [cite: 89]
	}
//	cells
	if (self.weapon == 4) // [cite: 89] // Corresponds to cells
	{
		if (player_entity.ammo_cells >= 400) // [cite: 89]
			return; // [cite: 89]
		player_entity.ammo_cells = player_entity.ammo_cells + self.aflag; // [cite: 90]
	}

    // ##FQXCUSTOM - ##Quedra: Call bound_other_ammo with correct 'other' context
    local entity current_self_context_at = self; // self is item
    self = player_entity; // 'other' for bound_other_ammo is the player
	bound_other_ammo (); // [cite: 90]
    self = current_self_context_at; // Restore self to item
	
	sprint(player_entity, "$qc_got_item", self.netname); // [cite: 90]
	sound (player_entity, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM); // [cite: 90]
	stuffcmd (player_entity, "bf\n"); // [cite: 91]

    // ##FQXCUSTOM - ##Quedra: v1.1 - Removed automatic weapon switching logic.
    // ##FQXCUSTOM - ##Quedra: The block that called W_BestWeapon was here. [original lines 91-93]
	
	// ##Quedra: MODIFICATION - Check reload state
	if (player_entity.weapon_is_reloading == FALSE)
	{
		current_self_context_at = self;
		self = player_entity;
		W_SetCurrentAmmo();
		self = current_self_context_at;
	}

	self.model = string_null; // [cite: 94]
	self.solid = SOLID_NOT; // [cite: 94]
	if (deathmatch) { // [cite: 95]
		if (deathmatch == 3 || deathmatch == 5) { // [cite: 95]
			self.nextthink = time + 15; // [cite: 95]
		} else if (deathmatch != 2) { // [cite: 96]
			self.nextthink = time + 30; // [cite: 96]
		}
	}
	self.think = SUB_regen; // [cite: 96]

	activator = player_entity; // [cite: 96]
	SUB_UseTargets(); // fire all targets / killtargets [cite: 97]
};

float WEAPON_BIG2 = 1; // [cite: 97]
/* QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big */ // [cite: 98]
void() item_shells =
{
	self.touch = ammo_touch; // [cite: 98]
	if (self.spawnflags & WEAPON_BIG2) // [cite: 99]
	{
		precache_model ("maps/b_shell1.bsp"); // [cite: 99]
		setmodel (self, "maps/b_shell1.bsp"); // [cite: 99]
		self.aflag = 40; // [cite: 99]
	}
	else
	{
		precache_model ("maps/b_shell0.bsp"); // [cite: 99]
		setmodel (self, "maps/b_shell0.bsp"); // [cite: 99]
		self.aflag = 20; // [cite: 99]
	}

	self.weapon = 1; // type for ammo_touch [cite: 100]
	self.netname = "$qc_shells"; // [cite: 100]
	setsize (self, '0 0 0', '32 32 56'); // [cite: 100]
	StartItem (); // [cite: 100]
};
/* QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big */ // [cite: 101]
void() item_spikes =
{
	self.touch = ammo_touch; // [cite: 101]
	if (self.spawnflags & WEAPON_BIG2) // [cite: 102]
	{
		precache_model ("maps/b_nail1.bsp"); // [cite: 102]
		setmodel (self, "maps/b_nail1.bsp"); // [cite: 102]
		self.aflag = 50; // [cite: 102]
	}
	else
	{
		precache_model ("maps/b_nail0.bsp"); // [cite: 102]
		setmodel (self, "maps/b_nail0.bsp"); // [cite: 102]
		self.aflag = 25; // [cite: 102]
	}

	self.weapon = 2; // type for ammo_touch [cite: 103]
	self.netname = "$qc_nails"; // [cite: 103]
	setsize (self, '0 0 0', '32 32 56'); // [cite: 103]
	StartItem (); // [cite: 103]
};
/* QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big */ // [cite: 104]
void() item_rockets =
{
	self.touch = ammo_touch; // [cite: 104]
	if (self.spawnflags & WEAPON_BIG2) // [cite: 105]
	{
		precache_model ("maps/b_rock1.bsp"); // [cite: 105]
		setmodel (self, "maps/b_rock1.bsp"); // [cite: 105]
		self.aflag = 10; // [cite: 105]
	}
	else
	{
		precache_model ("maps/b_rock0.bsp"); // [cite: 105]
		setmodel (self, "maps/b_rock0.bsp"); // [cite: 105]
		self.aflag = 5; // [cite: 105]
	}

	self.weapon = 3; // type for ammo_touch [cite: 106]
	self.netname = "$qc_rockets"; // [cite: 106]
	setsize (self, '0 0 0', '32 32 56'); // [cite: 106]
	StartItem (); // [cite: 106]
};
/* QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big */ // [cite: 107]
void() item_cells =
{
	self.touch = ammo_touch; // [cite: 107]
	if (self.spawnflags & WEAPON_BIG2) // [cite: 108]
	{
		precache_model ("maps/b_batt1.bsp"); // [cite: 108]
		setmodel (self, "maps/b_batt1.bsp"); // [cite: 108]
		self.aflag = 12; // [cite: 108]
	}
	else
	{
		precache_model ("maps/b_batt0.bsp"); // [cite: 108]
		setmodel (self, "maps/b_batt0.bsp"); // [cite: 108]
		self.aflag = 6; // [cite: 108]
	}

	self.weapon = 4; // type for ammo_touch [cite: 109]
	self.netname = "$qc_cells"; // [cite: 109]
	setsize (self, '0 0 0', '32 32 56'); // [cite: 109]
	StartItem (); // [cite: 109]
};
/*
QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! [cite: 110]
IT WILL BE REMOVED! [cite: 111]
*/

float WEAPON_SHOTGUN = 1; // [cite: 111]
float WEAPON_ROCKET = 2; // [cite: 111]
float WEAPON_SPIKES = 4; // [cite: 111]
float WEAPON_BIG = 8; // [cite: 111]
void() item_weapon =
{
	self.touch = ammo_touch; // This is for legacy "item_weapon" which is just ammo. [cite: 112]

	if (self.spawnflags & WEAPON_SHOTGUN) // [cite: 112]
	{
		if (self.spawnflags & WEAPON_BIG) // [cite: 112]
		{
			precache_model ("maps/b_shell1.bsp"); // [cite: 112]
			setmodel (self, "maps/b_shell1.bsp"); // [cite: 112]
			self.aflag = 40; // [cite: 112]
		}
		else // [cite: 113]
		{
			precache_model ("maps/b_shell0.bsp"); // [cite: 113]
			setmodel (self, "maps/b_shell0.bsp"); // [cite: 113]
			self.aflag = 20; // [cite: 113]
		}
		self.weapon = 1; // [cite: 113]
		self.netname = "$qc_shells"; // [cite: 113]
	}

	if (self.spawnflags & WEAPON_SPIKES) // [cite: 114]
	{
		if (self.spawnflags & WEAPON_BIG) // [cite: 114]
		{
			precache_model ("maps/b_nail1.bsp"); // [cite: 114]
			setmodel (self, "maps/b_nail1.bsp"); // [cite: 114]
			self.aflag = 40; // [cite: 114]
		}
		else // [cite: 114]
		{
			precache_model ("maps/b_nail0.bsp"); // [cite: 114]
			setmodel (self, "maps/b_nail0.bsp"); // [cite: 114]
			self.aflag = 20; // [cite: 115]
		}
		self.weapon = 2; // [cite: 115]
		self.netname = "$qc_spikes"; // [cite: 115]
	}

	if (self.spawnflags & WEAPON_ROCKET) // [cite: 115]
	{
		if (self.spawnflags & WEAPON_BIG) // [cite: 115]
		{
			precache_model ("maps/b_rock1.bsp"); // [cite: 115]
			setmodel (self, "maps/b_rock1.bsp"); // [cite: 115]
			self.aflag = 10; // [cite: 116]
		}
		else // [cite: 116]
		{
			precache_model ("maps/b_rock0.bsp"); // [cite: 116]
			setmodel (self, "maps/b_rock0.bsp"); // [cite: 116]
			self.aflag = 5; // [cite: 116]
		}
		self.weapon = 3; // [cite: 116]
		self.netname = "$qc_rockets"; // [cite: 116]
	}
	
	setsize (self, '0 0 0', '32 32 56'); // [cite: 117]
	StartItem (); // [cite: 117]
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
	if (other.classname != "player") // [cite: 117]
		return; // [cite: 117]
	if (other.health <= 0) // [cite: 118]
		return; // [cite: 118]

	if (other.items & self.items) // [cite: 118]
		return; // [cite: 118]

	sprint(other, "$qc_got_item", self.netname); // [cite: 118]

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM); // [cite: 118]
	stuffcmd (other, "bf\n"); // [cite: 118]
	other.items = other.items | self.items; // [cite: 119]

	if (!coop) // [cite: 119]
	{	
		self.solid = SOLID_NOT; // [cite: 119]
		self.model = string_null; // [cite: 119]
	}

	activator = other; // [cite: 119]
	SUB_UseTargets(); // fire all targets / killtargets [cite: 120]
};


void() key_setsounds =
{
	if (world.worldtype == WORLDTYPE_MEDIEVAL) // [cite: 120]
	{
		precache_sound ("misc/medkey.wav"); // [cite: 120]
		self.noise = "misc/medkey.wav"; // [cite: 120]
	}

	if (world.worldtype == WORLDTYPE_METAL) // [cite: 121]
	{
		precache_sound ("misc/runekey.wav"); // [cite: 121]
		self.noise = "misc/runekey.wav"; // [cite: 121]
	}

	if (world.worldtype == WORLDTYPE_BASE) // [cite: 121]
	{
		precache_sound2 ("misc/basekey.wav"); // [cite: 121]
		self.noise = "misc/basekey.wav"; // [cite: 121]
	}
};
/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key [cite: 122]
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key1 =
{
	if (world.worldtype == WORLDTYPE_MEDIEVAL) // [cite: 122]
	{
		precache_model ("progs/w_s_key.mdl"); // [cite: 122]
		setmodel (self, "progs/w_s_key.mdl"); // [cite: 123]
		self.netname = "$qc_silver_key"; // [cite: 123]
	}
	else if (world.worldtype == WORLDTYPE_METAL) // [cite: 123]
	{
		precache_model ("progs/m_s_key.mdl"); // [cite: 123]
		setmodel (self, "progs/m_s_key.mdl"); // [cite: 123]
		self.netname = "$qc_silver_runekey"; // [cite: 123]
	}
	else if (world.worldtype == WORLDTYPE_BASE) // [cite: 124]
	{
		precache_model2 ("progs/b_s_key.mdl"); // [cite: 124]
		setmodel (self, "progs/b_s_key.mdl"); // [cite: 124]
		self.netname = "$qc_silver_keycard"; // [cite: 124]
	}

	key_setsounds(); // [cite: 124]
	self.touch = key_touch; // [cite: 124]
	self.items = IT_KEY1; // [cite: 124]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 125]
	StartItem (); // [cite: 125]
};
/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key [cite: 126]
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (world.worldtype == WORLDTYPE_MEDIEVAL) // [cite: 126]
	{
		precache_model ("progs/w_g_key.mdl"); // [cite: 126]
		setmodel (self, "progs/w_g_key.mdl"); // [cite: 127]
		self.netname = "$qc_gold_key"; // [cite: 127]
	}

	if (world.worldtype == WORLDTYPE_METAL) // [cite: 127]
	{
		precache_model ("progs/m_g_key.mdl"); // [cite: 127]
		setmodel (self, "progs/m_g_key.mdl"); // [cite: 127]
		self.netname = "$qc_gold_runekey"; // [cite: 127]
	}

	if (world.worldtype == WORLDTYPE_BASE) // [cite: 128]
	{
		precache_model2 ("progs/b_g_key.mdl"); // [cite: 128]
		setmodel (self, "progs/b_g_key.mdl"); // [cite: 128]
		self.netname = "$qc_gold_keycard"; // [cite: 128]
	}

	key_setsounds(); // [cite: 128]
	self.touch = key_touch; // [cite: 128]
	self.items = IT_KEY2; // [cite: 128]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 129]
	StartItem (); // [cite: 129]
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{

	if (other.classname != "player") // [cite: 129]
		return; // [cite: 129]
	if (other.health <= 0) // [cite: 130]
		return; // [cite: 130]

	centerprint(other, "$qc_got_rune"); // [cite: 130]

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM); // [cite: 130]
	stuffcmd (other, "bf\n"); // [cite: 130]
	self.solid = SOLID_NOT; // [cite: 130]
	self.model = string_null; // [cite: 131]
	serverflags = serverflags | (self.spawnflags & 15); // [cite: 131]
	self.classname = string_null; // so rune doors won't find it [cite: 132]
	
	activator = other; // [cite: 132]
	SUB_UseTargets();				// fire all targets / killtargets [cite: 132]
};
/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart. [cite: 133]
*/

void() item_sigil =
{
	if (!self.spawnflags) // [cite: 134]
		objerror ("no spawnflags"); // [cite: 134]

	precache_sound ("misc/runekey.wav"); // [cite: 134]
	self.noise = "misc/runekey.wav"; // [cite: 134]

	if (self.spawnflags & 1) // [cite: 134]
	{
		precache_model ("progs/end1.mdl"); // [cite: 134]
		setmodel (self, "progs/end1.mdl"); // [cite: 134]
	}

	if (self.spawnflags & 2) // [cite: 135]
	{
		precache_model2 ("progs/end2.mdl"); // [cite: 135]
		setmodel (self, "progs/end2.mdl"); // [cite: 135]
	}

	if (self.spawnflags & 4) // [cite: 135]
	{
		precache_model2 ("progs/end3.mdl"); // [cite: 135]
		setmodel (self, "progs/end3.mdl"); // [cite: 135]
	}

	if (self.spawnflags & 8) // [cite: 136]
	{
		precache_model2 ("progs/end4.mdl"); // [cite: 136]
		setmodel (self, "progs/end4.mdl"); // [cite: 136]
	}
	
	self.touch = sigil_touch; // [cite: 136]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 136]
	StartItem (); // [cite: 137]
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{

	if (other.classname != "player") // [cite: 137]
		return; // [cite: 137]

	if (other.health <= 0) // [cite: 137]
		return; // [cite: 137]

	sprint(other, "$qc_got_item", self.netname); // [cite: 137]
	if (deathmatch) // [cite: 138]
	{
		self.mdl = self.model; // [cite: 138]
		
		if ((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility")) // [cite: 138]
			self.nextthink = time + 60*5; // [cite: 138]
		else // [cite: 139]
			self.nextthink = time + 60; // [cite: 139]
		
		self.think = SUB_regen; // [cite: 139]
	}	

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM); // [cite: 139]
	stuffcmd (other, "bf\n"); // [cite: 139]
	self.solid = SOLID_NOT; // [cite: 139]
	other.items = other.items | self.items; // [cite: 140]
	self.model = string_null; // [cite: 140]

	// do the apropriate action [cite: 140]
	if (self.classname == "item_artifact_envirosuit") // [cite: 140]
	{
		other.rad_time = 1; // [cite: 140]
		other.radsuit_finished = time + 30; // [cite: 141]
	}
	
	if (self.classname == "item_artifact_invulnerability") // [cite: 141]
	{
		other.invincible_time = 1; // [cite: 141]
		other.invincible_finished = time + 30; // [cite: 141]
	}
	
	if (self.classname == "item_artifact_invisibility") // [cite: 142]
	{
		other.invisible_time = 1; // [cite: 142]
		other.invisible_finished = time + 30; // [cite: 142]
	}

	if (self.classname == "item_artifact_super_damage") // [cite: 142]
	{
		other.super_time = 1; // [cite: 142]
		other.super_damage_finished = time + 30; // [cite: 143]
	}	

	activator = other; // [cite: 143]
	SUB_UseTargets();				// fire all targets / killtargets [cite: 143]
};
/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds [cite: 144]
*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch; // [cite: 144]
	precache_model ("progs/invulner.mdl"); // [cite: 145]
	precache_sound ("items/protect.wav"); // [cite: 145]
	precache_sound ("items/protect2.wav"); // [cite: 145]
	precache_sound ("items/protect3.wav"); // [cite: 145]
	self.noise = "items/protect.wav"; // [cite: 145]
	setmodel (self, "progs/invulner.mdl"); // [cite: 145]
	self.netname = "$qc_pentagram_of_protection"; // [cite: 145]
	self.items = IT_INVULNERABILITY; // [cite: 145]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 146]
	StartItem (); // [cite: 146]
};
/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds [cite: 147]
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch; // [cite: 147]
	precache_model ("progs/suit.mdl"); // [cite: 148]
	precache_sound ("items/suit.wav"); // [cite: 148]
	precache_sound ("items/suit2.wav"); // [cite: 148]
	self.noise = "items/suit.wav"; // [cite: 148]
	setmodel (self, "progs/suit.mdl"); // [cite: 148]
	self.netname = "$qc_biosuit"; // [cite: 148]
	self.items = IT_SUIT; // [cite: 148]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 149]
	StartItem (); // [cite: 149]
};
/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds [cite: 150]
*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch; // [cite: 150]
	precache_model ("progs/invisibl.mdl"); // [cite: 151]
	precache_sound ("items/inv1.wav"); // [cite: 151]
	precache_sound ("items/inv2.wav"); // [cite: 151]
	precache_sound ("items/inv3.wav"); // [cite: 151]
	self.noise = "items/inv1.wav"; // [cite: 151]
	setmodel (self, "progs/invisibl.mdl"); // [cite: 151]
	self.netname = "$qc_ring_of_shadows"; // [cite: 151]
	self.items = IT_INVISIBILITY; // [cite: 151]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 152]
	StartItem (); // [cite: 152]
};
/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage [cite: 153]
*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch; // [cite: 153]
	precache_model ("progs/quaddama.mdl"); // [cite: 154]
	precache_sound ("items/damage.wav"); // [cite: 154]
	precache_sound ("items/damage2.wav"); // [cite: 154]
	precache_sound ("items/damage3.wav"); // [cite: 154]
	self.noise = "items/damage.wav"; // [cite: 154]
	setmodel (self, "progs/quaddama.mdl"); // [cite: 154]
	self.netname = "$qc_quad_damage"; // [cite: 154]
	self.items = IT_QUAD; // [cite: 154]
	setsize (self, '-16 -16 -24', '16 16 32'); // [cite: 155]
	StartItem (); // [cite: 155]
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

//-----------------------------------------------------------------------------
// ##FQXCUSTOM - ##Quedra: BackpackTouch (Original logic with FQX loot system)
// ##Quedra: v1.1 - Modified to prevent automatic weapon switching.
//-----------------------------------------------------------------------------
void() BackpackTouch =
{
	local float old_items_state, new_item_flag_from_backpack; 
	local entity player_entity; 
	local float acount;
	local float r;

	player_entity = other; 

	if (player_entity.classname != "player") // [cite: 158]
		return; // [cite: 158]

	if (player_entity.health <= 0) // [cite: 158]
		return; // [cite: 158]
		
	acount = 0; // [cite: 158]
	sprint(player_entity, "$qc_backpack_got"); // [cite: 159]


	r = floor(random() * 10) + 1; //##Fox: Enemies have a chance to drop boosted ammo counts [cite: 159]
	{
        dprint("loot_bonus: "); // [cite: 159]
        dprint(ftos(r + player_entity.loot_bonus)); // [cite: 160]
        dprint("\n"); // [cite: 160]
    }
	if ((r + player_entity.loot_bonus) < 10) // [cite: 160]
		{
		//No bonus [cite: 160]
		}
	else if ((r + player_entity.loot_bonus)<15) // [cite: 160]
		{
		//Tier 1 ammo [cite: 160]
		self.ammo_shells = 15; // [cite: 160]
		self.ammo_nails = 30; // [cite: 161]
		self.ammo_rockets = 1; // [cite: 161]
		self.ammo_cells = 15; // [cite: 161]
		player_entity.loot_bonus = 0; // [cite: 161]
	}
	else if ((r + player_entity.loot_bonus)<20) // [cite: 162]
		{
		//Tier 2 ammo [cite: 162]
		self.ammo_shells = 30; // [cite: 162]
		self.ammo_nails = 50; // [cite: 162]
		self.ammo_rockets = 10; // [cite: 162]
		self.ammo_cells = 25; // [cite: 162]
		player_entity.loot_bonus = 0; // [cite: 163]
	}
	else // [cite: 163]
		{
		//Best Tier ammo [cite: 163]
		self.ammo_shells = 150; // [cite: 163]
		self.ammo_nails = 200; // [cite: 163]
		self.ammo_rockets = 50; // [cite: 163]
		self.ammo_cells = 100; // [cite: 163]
		player_entity.loot_bonus = 0; // [cite: 163]
	}
				
	if (self.items) // If backpack entity itself represents a weapon/item to be given [cite: 164]
	{	
		if ((player_entity.items & self.items) == 0) // If player doesn't have it [cite: 164]
		{
			acount = 1; // [cite: 164]
			sprint(player_entity, "{}", self.netname); // Print item name from backpack [cite: 164]
		}
 	}

	// Grant ammo
	player_entity.ammo_shells = player_entity.ammo_shells + self.ammo_shells; // [cite: 166]
	player_entity.ammo_nails = player_entity.ammo_nails + self.ammo_nails; // [cite: 167]
	player_entity.ammo_rockets = player_entity.ammo_rockets + self.ammo_rockets; // [cite: 167]
	player_entity.ammo_cells = player_entity.ammo_cells + self.ammo_cells; // [cite: 167]

	new_item_flag_from_backpack = self.items; // Item flag from the backpack entity itself (e.g. if it carried a weapon) [cite: 167]
	old_items_state = player_entity.items; // [cite: 168] // Store items before adding backpack's
	player_entity.items = player_entity.items | new_item_flag_from_backpack; // Give player items from backpack [cite: 168]
	
    // ##FQXCUSTOM - ##Quedra: Call bound_other_ammo with correct 'other' context
    local entity current_self_context_bpt = self; // self is backpack
    self = player_entity; // 'other' for bound_other_ammo is the player
	bound_other_ammo (); // [cite: 168]
    self = current_self_context_bpt; // Restore self to backpack

	if (self.ammo_shells) { if (acount) sprint(player_entity, ", "); acount = 1; sprint(player_entity, "$qc_backpack_shells", ftos(self.ammo_shells)); } // [cite: 169]
	if (self.ammo_nails) { if (acount) sprint(player_entity, ", "); acount = 1; sprint(player_entity, "$qc_backpack_nails", ftos(self.ammo_nails)); } // [cite: 170]
	if (self.ammo_rockets) { if (acount) sprint(player_entity, ", "); acount = 1; sprint(player_entity, "$qc_backpack_rockets", ftos(self.ammo_rockets)); } // [cite: 170]
	if (self.ammo_cells) { if (acount) sprint(player_entity, ", "); acount = 1; sprint(player_entity, "$qc_backpack_cells", ftos(self.ammo_cells)); } // [cite: 171]
	
	sprint (player_entity, "\n"); // [cite: 171]
	sound (player_entity, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM); // [cite: 171]
	stuffcmd (player_entity, "bf\n"); // [cite: 171]

   remove(self); // The backpack item removes itself

    // ##Quedra: MODIFICATION - Check reload state (player_entity is 'other' from touch context)
    if (player_entity.weapon_is_reloading == FALSE)
    {
	    self = player_entity; // Set context to player for W_SetCurrentAmmo
	    W_SetCurrentAmmo (); 
    }
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	local entity    item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells)) // [cite: 174]
		return; // nothing in it [cite: 175]

	item = spawn(); // [cite: 175]
	item.origin = self.origin - '0 0 24'; // [cite: 175]
	
	item.items = self.weapon; // The weapon the dying player was holding [cite: 175]
	item.classname = "item_backpack"; // added for bots. [cite: 176]

	if (item.items == IT_SLOT_MELEE) item.netname = "$qc_axe"; // [cite: 176]
	else if (item.items == IT_SLOT_HOLDOUT) item.netname = "$qc_shotgun"; // This implies the default shotgun [cite: 176]
	else if (item.items == IT_SLOT_SECONDARY) item.netname = "$qc_double_shotgun"; // [cite: 177]
	else if (item.items == IT_SLOT_PRIMARY) item.netname = "$qc_nailgun"; // [cite: 177]
	else if (item.items == IT_SLOT_HEAVY) item.netname = "$qc_super_nailgun"; // [cite: 178]
	else if (item.items == IT_SLOT_UTILITY) item.netname = "$qc_grenade_launcher"; // [cite: 178]
	else if (item.items == IT_SLOT_AUX1) item.netname = "$qc_rocket_launcher"; // [cite: 179]
	else if (item.items == IT_SLOT_AUX2) item.netname = "$qc_thunderbolt"; // [cite: 179]

	item.ammo_shells = self.ammo_shells; // [cite: 179]
	item.ammo_nails = self.ammo_nails; // [cite: 179]
	item.ammo_rockets = self.ammo_rockets; // [cite: 180]
	item.ammo_cells = self.ammo_cells; // [cite: 180]

	// include some ammo in the backpack if the weapon is being given [cite: 180]
	if (item.ammo_shells < 15 && (item.items == IT_SLOT_HOLDOUT || item.items == IT_SLOT_SECONDARY)) { // [cite: 180]
		item.ammo_shells = 15; // [cite: 180]
	}

	if (item.ammo_nails < 20 && (item.items == IT_SLOT_PRIMARY || item.items == IT_SLOT_HEAVY)) { // [cite: 181]
		item.ammo_nails = 20; // [cite: 181]
	}

	if (item.ammo_rockets < 5 && (item.items == IT_SLOT_UTILITY || item.items == IT_SLOT_AUX1)) { // [cite: 182]
		item.ammo_rockets = 5; // [cite: 182]
	}

	if (item.ammo_cells < 15 && item.items == IT_SLOT_AUX2) { // [cite: 183]
		item.ammo_cells = 15; // [cite: 183]
	}

	item.velocity_z = 300; // [cite: 183]
	item.velocity_x = -100 + (random() * 200); // [cite: 184]
	item.velocity_y = -100 + (random() * 200); // [cite: 184]
	
	item.flags = FL_ITEM; // [cite: 184]
	item.solid = SOLID_TRIGGER; // [cite: 184]
	item.movetype = MOVETYPE_TOSS; // [cite: 185]
	setmodel (item, "progs/backpack.mdl"); // [cite: 185]
	setsize (item, '-16 -16 0', '16 16 56'); // [cite: 185]
	item.touch = BackpackTouch; // [cite: 185]
	item.nextthink = time + 120;    // remove after 2 minutes [cite: 186]
	item.think = SUB_Remove; // [cite: 186]
};

//=============================================================================
// items.qc - End of FQX Mod - Item Pickup Logic
// ##FQXCUSTOM - ##Quedra: Version 1.1
//=============================================================================