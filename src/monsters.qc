//=============================================================================
// monsters.qc - FQX Mod - Standard Monster Logic (DIAGNOSTIC - ROOK V3)
// Location: /
// ##ROOK: v3.0 - Added pre-initialization tap to _start functions to isolate
// ##ROOK:          the exact point of memory corruption. FINAL TEST.
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
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details. */

/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

void() monster_death_use =
{
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;
	if (!self.target)
		return;
	activator = self.enemy;
	SUB_UseTargets ();
};

void() walkmonster_start_go =
{
	// Rook's diagnostic tap V1
	dprint("SPAWN_DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), "\n");
    dprint(" - think: ", self.think, "\n");
    dprint(" - nextthink: ", ftos(self.nextthink), "\n");
    dprint(" - solid: ", ftos(self.solid), "\n");
    dprint(" - movetype: ", ftos(self.movetype), "\n");
    dprint(" - flags: ", ftos(self.flags), "\n");
    dprint(" - spawnflags: ", ftos(self.spawnflags), "\n");

	self.origin_z = self.origin_z + 1;
	droptofloor();
	if (!walkmove(0,0))
	{
		dprint ("walkmonster in wall at: ", vtos(self.origin), "\n");
	}
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;
	self.flags = self.flags | FL_MONSTER;
	if (self.target != string_null)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ", vtos(self.origin), "\n");
		}
		if (self.movetarget.classname == "path_corner")
        {
			self.th_walk ();
        }
		else
        {
			self.pausetime = 99999999;
			self.th_stand ();
        }
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	self.nextthink = self.nextthink + random()*0.5;

    // Rook's diagnostic tap V2
    dprint("DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), " completed initialization.\n");
};

void() walkmonster_start =
{
    // Rook's diagnostic tap V3
    dprint("--- walkmonster_start for ", self.classname, " at ", vtos(self.origin), " ---\n");
    dprint("  - CURRENT .think: ", self.think, "\n");

	self.nextthink = time + 0.1; // Using a fixed delay
	self.think = walkmonster_start_go;
	total_monsters = total_monsters + 1;

    // Log the state AFTER scheduling
    dprint("  - SCHEDULED .think: ", self.think, "\n");
    dprint("  - SCHEDULED .nextthink: ", ftos(self.nextthink), "\n");
};

void() flymonster_start_go =
{
    // Rook's diagnostic tap V1
	dprint("SPAWN_DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), "\n");
    dprint(" - think: ", self.think, "\n");
    dprint(" - nextthink: ", ftos(self.nextthink), "\n");
    dprint(" - solid: ", ftos(self.solid), "\n");
    dprint(" - movetype: ", ftos(self.movetype), "\n");
    dprint(" - flags: ", ftos(self.flags), "\n");
    dprint(" - spawnflags: ", ftos(self.spawnflags), "\n");

	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;
	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;
	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall at: ", vtos(self.origin), "\n");
	}
	if (self.target != string_null)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ", vtos(self.origin), "\n");
		}
		if (self.movetarget.classname == "path_corner")
        {
			self.th_walk ();
        }
		else
        {
			self.pausetime = 99999999;
			self.th_stand ();
        }
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
    self.nextthink = self.nextthink + random()*0.5;

    // Rook's diagnostic tap V2
    dprint("DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), " completed initialization.\n");
};

void() flymonster_start =
{
    // Rook's diagnostic tap V3
    dprint("--- flymonster_start for ", self.classname, " at ", vtos(self.origin), " ---\n");
    dprint("  - CURRENT .think: ", self.think, "\n");

	self.nextthink = time + 0.1; // Using a fixed delay
	self.think = flymonster_start_go;
	total_monsters = total_monsters + 1;

    // Log the state AFTER scheduling
    dprint("  - SCHEDULED .think: ", self.think, "\n");
    dprint("  - SCHEDULED .nextthink: ", ftos(self.nextthink), "\n");
};

void() swimmonster_start_go;
void() swimmonster_start =
{
    // Rook's diagnostic tap V3
    dprint("--- swimmonster_start for ", self.classname, " at ", vtos(self.origin), " ---\n");
    dprint("  - CURRENT .think: ", self.think, "\n");

	self.nextthink = time + 0.1; // Using a fixed delay
	self.think = swimmonster_start_go;
	total_monsters = total_monsters + 1;

    // Log the state AFTER scheduling
    dprint("  - SCHEDULED .think: ", self.think, "\n");
    dprint("  - SCHEDULED .nextthink: ", ftos(self.nextthink), "\n");
};

void() swimmonster_start_go =
{
    // Rook's diagnostic tap V1
	dprint("SPAWN_DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), "\n");
    dprint(" - think: ", self.think, "\n");
    dprint(" - nextthink: ", ftos(self.nextthink), "\n");
    dprint(" - solid: ", ftos(self.solid), "\n");
    dprint(" - movetype: ", ftos(self.movetype), "\n");
    dprint(" - flags: ", ftos(self.flags), "\n");
    dprint(" - spawnflags: ", ftos(self.spawnflags), "\n");

	if (deathmatch)
	{
		remove(self);
		return;
	}
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;	
	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;
	if (self.target != string_null)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ", vtos(self.origin), "\n");
		}
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	self.nextthink = self.nextthink + random()*0.5;

    // Rook's diagnostic tap V2
    dprint("DIAGNOSTIC: ", self.classname, " at ", vtos(self.origin), " completed initialization.\n");
};
//=============================================================================
// monsters.qc - FQX Mod - Standard Monster Logic (DIAGNOSTIC - ROOK V3) - END
//=============================================================================