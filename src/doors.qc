//=============================================================================
// doors.qc - FQX Mod - Door and Secret Door Logic
// ##IDSOFT    - ##Quedra: Base code from id Software, Quake Rerelease.
// ##FQXCUSTOM - ##Quedra: Integrated into FQX mod structure, versioned.
// ##FQXCUSTOM - ##Quedra: Corrected th_pain/th_die/use signatures for secret doors via wrappers.
// ##Quedra: Version 1.3
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
    along with this program;
    if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

//=============================================================================
// ##Quedra: DEFINITIONS & FORWARD DECLARATIONS
//=============================================================================
float DOOR_START_OPEN   = 1;
float DOOR_DONT_LINK    = 4;
float DOOR_GOLD_KEY     = 8;
float DOOR_SILVER_KEY   = 16;
float DOOR_TOGGLE       = 32;

// --- Standard Door Functions ---
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
entity(vector fmins, vector fmaxs) spawn_field;
float (entity e1, entity e2) EntitiesTouching;
void() LinkDoors;
void() func_door;

// --- Secret Door Functions ---
void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;
void(entity attacker, float damage) fd_secret_use; // Signature for .th_pain
void() fd_secret_die_wrapper;                   // Wrapper for .th_die
void() fd_secret_use_wrapper;                    // Wrapper for .use
void() secret_blocked;
void() secret_touch;
void() func_door_secret;

// --- External Functions (Assumed globally declared e.g. in defs_*.qc) ---
// void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
// void(vector tdest, float tspeed, void() func) SUB_CalcMove;
// void() SUB_UseTargets;
// void() SUB_Null;
//=============================================================================

/*
Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.
Door.enemy chains from the master door through all doors linked in the chain.
*/

//=============================================================================
// STANDARD DOOR: THINK FUNCTIONS
//=============================================================================

void() door_blocked =
{
	T_Damage (other, self, self, self.dmg);
	
	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
		{
			door_go_up ();
		}
		else
		{
			door_go_down ();
		}
	}
};


void() door_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;

	if (self.spawnflags & DOOR_TOGGLE)
	{
		return; // don't come down automatically
	}

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
	{
		return;		// already going up
	}

	if (self.state == STATE_TOP)
	{	// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}
	
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);

	SUB_UseTargets(); // Fire targets when door starts going up
};

//=============================================================================
// STANDARD DOOR: ACTIVATION FUNCTIONS
//=============================================================================

void() door_fire =
{
	local entity oself;
	local entity starte;

	if (self.owner != self)
	{
		objerror ("door_fire: self.owner != self"); // Should be called on master door
	}
	
	if (self.items) // play use key sound if it's a key door
	{
		sound (self, CHAN_ITEM, self.noise4, 1, ATTN_NORM); // door unlock sound
	}

	self.message = string_null; // no more message
	oself = self;

	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP) // If open or opening, close it
		{
			starte = self;
			do
			{
				door_go_down ();
				self = self.enemy; // Move to next door in chain
			} while ( (self != starte) && (self != world) ); // Loop through all linked doors
	
			self = oself; // Restore self to original master
			return;
		}
	}
	
	// Default action: trigger all paired doors to go up (open)
	starte = self;
	do
	{
		door_go_up ();
		self = self.enemy;
	} while ( (self != starte) && (self != world) );

	self = oself; // Restore self
};


void() door_use =
{
	local entity oself;
	self.message = string_null;			// Door messages are for touch only
	self.owner.message = string_null;	
	if(self.enemy && self.enemy != self.owner) { self.enemy.message = string_null; } // Clear message on linked doors too
	
	oself = self;
	self = self.owner; // Operate on the master door
	door_fire ();
	self = oself; // Restore self
};


void() door_trigger_touch =
{
	if (other.health <= 0) // Don't activate if a dead thing touches
	{
		return;
	}

	if (time < self.attack_finished) // Debounce
	{
		return;
	}
	self.attack_finished = time + 1;

	activator = other;

	self = self.owner; // The trigger field's owner is the door itself (master door)
	door_use ();
};


void() door_killed =
{
	local entity oself;
	oself = self;
	self = self.owner; // Operate on master door
	self.health = 0; // Mark as "killed"
	self.takedamage = DAMAGE_NO; // No longer shootable to open
	door_use (); // Open the door
	self = oself; // Restore self
};

void() door_touch =
{
	if (other.classname != "player")
	{
		return;
	}

	if (self.owner.attack_finished > time) // Check master door's attack_finished for debounce
	{
		return;
	}
	self.owner.attack_finished = time + 2; // Debounce for 2 seconds

	if (self.owner.message != string_null)
	{
		centerprint (other, self.owner.message);
		sound (other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
	
	// Key door stuff
	if (!self.items) // Not a key door
	{
		return;
	}

	if ( (self.items & other.items) != self.items ) // Player doesn't have the required key
	{
		string key_needed_msg = "$qc_need_key_generic"; // Default/fallback message
		if (self.owner.items == IT_KEY1) // Master door holds the key type
		{
			if (world.worldtype == WORLDTYPE_BASE) { key_needed_msg = "$qc_need_silver_keycard"; }
			else if (world.worldtype == WORLDTYPE_METAL) { key_needed_msg = "$qc_need_silver_runekey"; }
			else if (world.worldtype == WORLDTYPE_MEDIEVAL) { key_needed_msg = "$qc_need_silver_key"; }
		}
		else if (self.owner.items == IT_KEY2)
		{
			if (world.worldtype == WORLDTYPE_BASE) { key_needed_msg = "$qc_need_gold_keycard"; }
			else if (world.worldtype == WORLDTYPE_METAL) { key_needed_msg = "$qc_need_gold_runekey"; }
			else if (world.worldtype == WORLDTYPE_MEDIEVAL) { key_needed_msg = "$qc_need_gold_key"; }
		}
		centerprint (other, key_needed_msg);
		if (self.noise3 != string_null && self.noise3 != "") { sound (self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); } // Locked sound

		return;
	}

	// Player has the key
	other.items = other.items - self.items; // Remove key from player
	self.touch = SUB_Null;                  // Door no longer touchable for key check

	if (self.enemy && self.enemy != self) // If part of a linked door system
	{
		self.enemy.touch = SUB_Null;	// Make paired door also not touchable for key check
	}
	door_use (); // Use the door (which will call door_fire on master)
};

//=============================================================================
// STANDARD DOOR: SPAWNING FUNCTIONS
//=============================================================================

entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity trigger;
	local	vector t1, t2;

	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self; 
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return trigger;
};

float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x) { return FALSE; }
	if (e1.mins_y > e2.maxs_y) { return FALSE; }
	if (e1.mins_z > e2.maxs_z) { return FALSE; }
	if (e1.maxs_x < e2.mins_x) { return FALSE; }
	if (e1.maxs_y < e2.mins_y) { return FALSE; }
	if (e1.maxs_z < e2.mins_z) { return FALSE; }
	return TRUE;
};

void() LinkDoors =
{
	local entity t_scan; 
	local entity starte;    // The first door found becomes the master for this chain
	local vector cmins, cmaxs; // Combined bounding box for linked doors

	if (self.owner != self) // If owner is already set to something else, it means this door was already linked as a slave
	{
		return; // Already linked by another door acting as master
	}
	// At this point, self.owner is self, meaning this door considers itself a master, or hasn't been linked yet.

	if (self.spawnflags & DOOR_DONT_LINK)
	{
		self.owner = self.enemy = self; // Points to itself, forming a chain of one
		return; 
	}

	cmins = self.mins;
	cmaxs = self.maxs;
	
	starte = self;      // This door is the starting point and the designated master
	self.owner = starte; // Explicitly ensure current self (master) points to itself as owner initially.
	self.enemy = self;   // Initialize enemy to self for loop termination if no others found
	
	t_scan = find(world, classname, self.classname); // Start search from the beginning of the entity list

	while (t_scan)
	{
        if (t_scan == starte) // Skip the master door itself in the initial part of the scan
        {
            t_scan = find(t_scan, classname, self.classname);
            continue;
        }

        if (t_scan.owner == t_scan && !(t_scan.spawnflags & DOOR_DONT_LINK)) // Found another potential unlinked door
        {
            if (EntitiesTouching(starte, t_scan) || EntitiesTouching(self, t_scan)) // Check if current end-of-chain or master touches new door
            {
                if (t_scan.enemy && t_scan.enemy != t_scan) // If t_scan is already part of ANOTHER chain (its .enemy points elsewhere)
                {
                    objerror("cross connected doors");
                }
                // Link current 'self' (which is end of current chain) to t_scan
                self.enemy = t_scan;
                t_scan.owner = starte; // Assign current master (starte) to the new door
                self = t_scan;         // Current 'self' becomes the new end of the chain
                self.enemy = starte;   // Make the chain circular for now

                // Update combined bounding box
                if (t_scan.mins_x < cmins_x) { cmins_x = t_scan.mins_x; }
                if (t_scan.mins_y < cmins_y) { cmins_y = t_scan.mins_y; }
                if (t_scan.mins_z < cmins_z) { cmins_z = t_scan.mins_z; }
                if (t_scan.maxs_x > cmaxs_x) { cmaxs_x = t_scan.maxs_x; }
                if (t_scan.maxs_y > cmaxs_y) { cmaxs_y = t_scan.maxs_y; }
                if (t_scan.maxs_z > cmaxs_z) { cmaxs_z = t_scan.maxs_z; }

                // Propagate properties to master
                if (t_scan.health > 0) { starte.max_health = starte.health = t_scan.health; } // QRRQC uses max_health for master
                if (t_scan.targetname != string_null) { starte.targetname = t_scan.targetname; }
                if (t_scan.message != string_null) { starte.message = t_scan.message; }
                if (t_scan.items > 0) { starte.items = t_scan.items; }
            }
        }
		t_scan = find (t_scan, classname, self.classname);
	}
    
    // After scanning all doors, self is the last door added to starte's chain.
    // Make its .enemy point to starte to complete the circular chain.
    self.enemy = starte; 

    // Restore self to the original door that initiated LinkDoors call
    self = starte; 

	// Spawn trigger field only for the master door if it's not shootable, targetted, or a key door
	if (self.health > 0 || self.targetname != string_null || self.items > 0)
	{
		return;
	}
	self.trigger_field = spawn_field(cmins, cmaxs);
};

/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE */
void() func_door =
{
	if (self.sounds == 0) { self.noise1 = "misc/null.wav"; self.noise2 = "misc/null.wav"; }
	else if (self.sounds == 1) { precache_sound("doors/drclos4.wav"); precache_sound("doors/doormv1.wav"); self.noise1 = "doors/drclos4.wav"; self.noise2 = "doors/doormv1.wav"; }
	else if (self.sounds == 2) { precache_sound("doors/hydro1.wav"); precache_sound("doors/hydro2.wav"); self.noise2 = "doors/hydro1.wav"; self.noise1 = "doors/hydro2.wav"; }
	else if (self.sounds == 3) { precache_sound("doors/stndr1.wav"); precache_sound("doors/stndr2.wav"); self.noise2 = "doors/stndr1.wav"; self.noise1 = "doors/stndr2.wav"; }
	else if (self.sounds == 4) { precache_sound("doors/ddoor1.wav"); precache_sound("doors/ddoor2.wav"); self.noise1 = "doors/ddoor2.wav"; self.noise2 = "doors/ddoor1.wav"; }
    else { 
        if (world.worldtype == WORLDTYPE_MEDIEVAL) { precache_sound("doors/medtry.wav"); precache_sound("doors/meduse.wav"); self.noise3 = "doors/medtry.wav"; self.noise4 = "doors/meduse.wav"; if (self.sounds > 4 || self.sounds < 0) { self.noise1 = "doors/drclos4.wav"; self.noise2 = "doors/doormv1.wav";}}
        else if (world.worldtype == WORLDTYPE_METAL) { precache_sound("doors/runetry.wav"); precache_sound("doors/runeuse.wav"); self.noise3 = "doors/runetry.wav"; self.noise4 = "doors/runeuse.wav"; if (self.sounds > 4 || self.sounds < 0) { self.noise1 = "doors/ddoor2.wav"; self.noise2 = "doors/ddoor1.wav";}}
        else if (world.worldtype == WORLDTYPE_BASE) { precache_sound("doors/basetry.wav"); precache_sound("doors/baseuse.wav"); self.noise3 = "doors/basetry.wav"; self.noise4 = "doors/baseuse.wav"; if (self.sounds > 4 || self.sounds < 0) { self.noise2 = "doors/hydro1.wav"; self.noise1 = "doors/hydro2.wav";}}
        else { self.noise1 = "misc/null.wav"; self.noise2 = "misc/null.wav"; } 
    }
    if (self.spawnflags & DOOR_SILVER_KEY && (self.noise3 == string_null || self.noise3 == "")) { precache_sound("doors/basetry.wav"); self.noise3 = "doors/basetry.wav"; }
    if (self.spawnflags & DOOR_GOLD_KEY && (self.noise3 == string_null || self.noise3 == "")) { precache_sound("doors/basetry.wav"); self.noise3 = "doors/basetry.wav"; }
    if (self.items > 0 && (self.noise4 == string_null || self.noise4 == "")) { precache_sound("doors/baseuse.wav"); self.noise4 = "doors/baseuse.wav"; }

	SetMovedir ();
	self.classname = "func_door"; 
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	
	self.owner = self; // Initialize owner to self, LinkDoors will group it
	self.enemy = world; // Initialize enemy, LinkDoors will set it

	self.blocked = door_blocked;
	self.use = door_use;
	
	if (self.spawnflags & DOOR_SILVER_KEY) { self.items = IT_KEY1; }
	if (self.spawnflags & DOOR_GOLD_KEY) { self.items = IT_KEY2; }
	
	if (!self.speed) { self.speed = 100; }
	if (self.wait == 0) { self.wait = 3; } // QRRQC uses self.wait == 0 check, not !self.wait
	if (!self.lip) { self.lip = 8; }
	if (!self.dmg) { self.dmg = 2; }

	self.pos1 = self.origin;
	vector movedir_fabs = { fabs(self.movedir_x), fabs(self.movedir_y), fabs(self.movedir_z) };
	self.pos2 = self.pos1 + ((movedir_fabs * self.size) - self.lip) * self.movedir;
	
	if (self.spawnflags & DOOR_START_OPEN)
	{
		setorigin (self, self.pos2);
		vector temp_pos = self.pos1; 
		self.pos1 = self.pos2; // self.pos1 is now the "open" position
		self.pos2 = temp_pos;  // self.pos2 is now the "closed" position
	}

	self.state = STATE_BOTTOM; // Door starts at pos1

	if (self.health > 0) 
	{
        self.max_health = self.health; 
		self.takedamage = DAMAGE_YES;
		self.th_die = door_killed;
	}
	
	if (self.items > 0) 
	{
		self.wait = -1; 
	}
	
	if (self.targetname == string_null && !(self.health > 0) ) {
        self.touch = door_touch;
    } else if (self.items > 0) { 
        self.touch = door_touch;
    }

	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1; 
};

//=============================================================================
// SECRET DOORS
//=============================================================================

float SECRET_OPEN_ONCE    = 1;		
float SECRET_1ST_LEFT     = 2;		
float SECRET_1ST_DOWN     = 4;		
float SECRET_NO_SHOOT     = 8;		
float SECRET_YES_SHOOT    = 16;	

void(entity attacker, float damage) fd_secret_use =
{
	local float temp_val; 

	if (self.origin != self.oldorigin) 
	{
		return;
	}
	
	self.message = string_null;		
	SUB_UseTargets();
	
	if (!(self.spawnflags & SECRET_NO_SHOOT)) 
	{
		self.th_pain = SUB_Null; 
		self.takedamage = DAMAGE_NO;
	}

	self.velocity = '0 0 0';
	if (self.noise1 != string_null && self.noise1 != "") { sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM); }
	
    self.nextthink = self.ltime + 0.1; 
	
    temp_val = 1; 
    if (self.spawnflags & SECRET_1ST_LEFT) { temp_val = -1; } 

	makevectors(self.mangle); 
	
	if (self.t_width == 0) 
	{
		if (self.spawnflags & SECRET_1ST_DOWN) { self.t_width = fabs(v_up * self.size); }
		else { self.t_width = fabs(v_right * self.size); }
	}
		
	if (self.t_length == 0) 
	{
		self.t_length = fabs(v_forward * self.size);
	}
    
	if (self.spawnflags & SECRET_1ST_DOWN)
    {
		self.dest1 = self.origin - (v_up * self.t_width); 
    }
	else
    {
		self.dest1 = self.origin + (v_right * (self.t_width * temp_val)); 
    }
	self.dest2 = self.dest1 + (v_forward * self.t_length); 

	self.think = fd_secret_move1; // Set think for first movement stage
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1); // This will call fd_secret_move1 upon completion
	if (self.noise2 != string_null && self.noise2 != "") { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); }
};

void () fd_secret_move1 = 
{
	self.nextthink = self.ltime + 1.0; 
	self.think = fd_secret_move2;
	if (self.noise3 != string_null && self.noise3 != "") { sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); }
};

void () fd_secret_move2 =
{
	if (self.noise2 != string_null && self.noise2 != "") { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); }
    self.think = fd_secret_move3; // Set think for next stage
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

void () fd_secret_move3 =
{
	if (self.noise3 != string_null && self.noise3 != "") { sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); }
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait; 
		self.think = fd_secret_move4;
	}
};

void () fd_secret_move4 =
{
	if (self.noise2 != string_null && self.noise2 != "") { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); }
    self.think = fd_secret_move5; // Set think for next stage
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5); 		
};

void () fd_secret_move5 = 
{
	self.nextthink = self.ltime + 1.0; 
	self.think = fd_secret_move6;
	if (self.noise3 != string_null && self.noise3 != "") { sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); }
};

void () fd_secret_move6 =
{
	if (self.noise2 != string_null && self.noise2 != "") { sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM); }
    self.think = fd_secret_done; // Set think for final stage
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done); 
};

void() fd_secret_die_wrapper =
{
    // 'self' is the door. 'attacker' and 'damage' are not directly relevant for a .th_die triggered "use".
    fd_secret_use(world, 0); 
};

void() fd_secret_use_wrapper =
{
    // 'other' is the activator for a .use function.
    // Pass 'other' as attacker, and 0 for damage.
    fd_secret_use(other, 0);
};

void () fd_secret_done =
{
	if (!self.targetname || (self.spawnflags & SECRET_YES_SHOOT) ) 
	{
		self.health = 1; 
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;	
		self.th_die = fd_secret_die_wrapper; 
	}
	if (self.noise3 != string_null && self.noise3 != "") { sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM); }
};

void () secret_blocked =
{
	if (time < self.attack_finished)
	{
		return;
	}
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg);
};

void() secret_touch =
{
	if (other.classname != "player")
	{
		return;
	}
	if (self.attack_finished > time) 
	{
		return;
	}
	self.attack_finished = time + 2;
	
	if (self.message != string_null)
	{
		centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};

/*QUAKED func_door_secret (0 .5 .8) ? OPEN_ONCE 1ST_LEFT 1ST_DOWN NO_SHOOT ALWAYS_SHOOT */
void () func_door_secret =
{
	if (self.sounds == 0) { self.sounds = 3; } 

    // ##Quedra: Aligning sound assignment with QRRQC for secret doors
    if (self.sounds == 1) { self.noise1 = "doors/latch2.wav"; self.noise2 = "doors/winch2.wav"; self.noise3 = "doors/drclos4.wav"; } // Medieval
    else if (self.sounds == 2) { self.noise1 = "doors/airdoor2.wav"; self.noise2 = "doors/airdoor1.wav"; self.noise3 = "doors/airdoor2.wav"; } // Metal
    else if (self.sounds == 3) { self.noise1 = "doors/basesec2.wav"; self.noise2 = "doors/basesec1.wav"; self.noise3 = "doors/basesec2.wav"; } // Base
    
    if (self.noise1 != string_null && self.noise1 != "") precache_sound(self.noise1);
    if (self.noise2 != string_null && self.noise2 != "") precache_sound(self.noise2);
    if (self.noise3 != string_null && self.noise3 != "") precache_sound(self.noise3);

	if (!self.dmg) { self.dmg = 2; }
		
	self.mangle = self.angles; 
	self.angles = '0 0 0';     
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.classname = "func_door_secret";
	setmodel (self, self.model);
	setorigin (self, self.origin);	
	
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	if (!self.speed) { self.speed = 50; } 
	self.use = fd_secret_use_wrapper; // ##Quedra: Use wrapper for .use

	if (!(self.spawnflags & SECRET_NO_SHOOT) || (self.spawnflags & SECRET_YES_SHOOT) )
	{
		self.health = 1; 
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;
		self.th_die = fd_secret_die_wrapper; 
	}

	self.oldorigin = self.origin; 

	if (!self.wait) { self.wait = 5; }		
};
//=============================================================================
// doors.qc - FQX Mod - Door and Secret Door Logic - END
// ##Quedra: Version 1.3
//=============================================================================