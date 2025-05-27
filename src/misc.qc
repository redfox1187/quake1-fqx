//=============================================================================
// misc.qc - FQX Mod - Miscellaneous Entities & Logic (Explosives, Lights, etc.)
// Location: /fqx_mod/source/game/
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
// ##IDSOFT: Base code from id Software, Quake.
// ##Quedra: This file contains standard miscellaneous map entities.
// ##Quedra: Integrated FQX-style diagnostic dprints for debugging purposes.
// ##Quedra: v1.0.1 - Added diagnostic dprints to barrel_detonate and barrel_explode.
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

/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
    remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//=============================================================================
// ##IDSOFT - ##Quedra: Lights
//=============================================================================
float START_OFF = 1;

void() light_use =
{
    if (self.spawnflags & START_OFF)
    {
        lightstyle(self.style, "m");
        self.spawnflags = self.spawnflags - START_OFF;
    }
    else
    {
        lightstyle(self.style, "a");
        self.spawnflags = self.spawnflags + START_OFF;
    }
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
    if (!self.targetname)
    {   // inert light
        remove(self);
        return;
    }
    
    if (self.style >= 32)
    {
        self.use = light_use;
        if (self.spawnflags & START_OFF)
        {
            lightstyle(self.style, "a");
        }
        else
        {
            lightstyle(self.style, "m");
        }
    }
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
    if (self.style >= 32)
    {
        self.use = light_use;
        if (self.spawnflags & START_OFF)
        {
            lightstyle(self.style, "a");
        }
        else
        {
            lightstyle(self.style, "m");
        }
    }
    
    precache_sound("ambience/fl_hum1.wav");
    ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
    if (!self.style)
    {
        self.style = 10;
    }
    precache_sound("ambience/buzz1.wav");
    ambientsound(self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
    precache_model("progs/s_light.spr");
    setmodel(self, "progs/s_light.spr");
    makestatic(self);
};

void() FireAmbient =
{
    precache_sound("ambience/fire1.wav");
    // attenuate fast
    ambientsound(self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
    precache_model("progs/flame.mdl");
    setmodel(self, "progs/flame.mdl");
    FireAmbient();
    makestatic(self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    self.frame = 1;
    FireAmbient();
    makestatic(self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    FireAmbient();
    makestatic(self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
    precache_model("progs/flame2.mdl");
    setmodel(self, "progs/flame2.mdl");
    FireAmbient();
    makestatic(self);
};

//=============================================================================
// ##IDSOFT - ##Quedra: Lava Balls
//=============================================================================
void() fire_fly;
void() fire_touch;

/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/
void() misc_fireball =
{    
    precache_model("progs/lavaball.mdl");
    self.classname = "fireball";
    self.nextthink = time + (random() * 5);
    self.think = fire_fly;
    self.netname = "$qc_lava_ball";
    self.killstring = "$qc_ks_lavaball";

    if (!self.speed)
    {
        self.speed = 1000;
    }
};

void() fire_fly =
{
    local entity    fireball;

    fireball = spawn();
    fireball.solid = SOLID_TRIGGER;
    fireball.movetype = MOVETYPE_TOSS;
    fireball.velocity = '0 0 1000';
    fireball.velocity_x = (random() * 100) - 50;
    fireball.velocity_y = (random() * 100) - 50;
    fireball.velocity_z = self.speed + (random() * 200);
    fireball.classname = "fireball";
    setmodel(fireball, "progs/lavaball.mdl");
    setsize(fireball, '0 0 0', '0 0 0');
    setorigin(fireball, self.origin);
    fireball.nextthink = time + 5;
    fireball.think = SUB_Remove;
    fireball.touch = fire_touch;

    self.netname = "$qc_lava_ball";
    self.killstring = "$qc_ks_lavaball";
    
    self.nextthink = time + (random() * 5) + 3;
    self.think = fire_fly;
};


void() fire_touch =
{
    T_Damage(other, self, self, 20);
    remove(self);
};

//=============================================================================
// ##IDSOFT - ##Quedra: Explosive Barrels
//=============================================================================
void() barrel_explode =
{
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("barrel_explode: self = "); dprint(etos(self)); dprint(", self.enemy = "); dprint(etos(self.enemy)); dprint("\n");
    // did say self.owner in original id code comment, but it's self.enemy (attacker) for T_RadiusDamage
    T_RadiusDamage(self, self.enemy, 160, world);
    sound(self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);
    particle(self.origin, '0 0 0', 75, 255); // Sparkle Crazyness!

    self.origin_z = self.origin_z + 32;
    BecomeExplosion();
};

void() barrel_detonate =
{
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("barrel_detonate: self = "); dprint(etos(self)); dprint(", self.enemy = "); dprint(etos(self.enemy)); dprint("\n");
    self.classname = "explo_box"; // So it doesn't spawn other entities from death
    self.takedamage = DAMAGE_NO;
    self.think = barrel_explode;
    self.nextthink = self.ltime + 0.3; // Short delay before explosion
};

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
Exploding box.
Health: 20
*/
void() misc_explobox =
{
    local float    oldz;
    
    if (!self.mdl) 
    {
        self.mdl = "maps/b_explob.bsp";
    }
    self.solid = SOLID_BSP;
    self.movetype = MOVETYPE_PUSH; // Allow it to be pushed by players/explosions
    
    precache_model(self.mdl);
    setmodel(self, self.mdl);
    precache_sound("weapons/r_exp3.wav"); // Explosion sound
    
    self.health = 20;
    self.th_die = barrel_detonate;
    self.takedamage = DAMAGE_AIM; // Can be damaged
    
    self.netname = "$qc_exploding_barrel";
    self.killstring = "$qc_ks_blew_up";

    // Droptofloor logic
    self.origin_z = self.origin_z + 2; // Lift slightly before dropping
    oldz = self.origin_z;
    droptofloor();
    if (oldz - self.origin_z > 250) // Check if it fell too far (out of level)
    {
        dprint("explobox fell out of level at ");
        dprint(vtos(self.origin));
        dprint("\n");
        remove(self);
    }
};

/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY. (FQX Note: 'Registered' status is legacy)
Health: 20
*/
void() misc_explobox2 =
{
    self.mdl = "maps/b_exbox2.bsp"; // Different model for variety
    misc_explobox(); // Use the same core logic
};

//=============================================================================
// ##IDSOFT - ##Quedra: Spike Traps
//=============================================================================
float SPAWNFLAG_SUPERSPIKE    = 1;
float SPAWNFLAG_LASER         = 2;

void(vector org, vector vec) LaunchLaser; // Assumed defined elsewhere (e.g. enforcer.qc)
void() spikeshooter_use =
{
    if (self.spawnflags & SPAWNFLAG_LASER)
    {
        sound(self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
        LaunchLaser(self.origin, self.movedir); // Requires LaunchLaser to be defined
    }
    else
    {
        sound(self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
        launch_spike(self.origin, self.movedir); // Standard spike
        if (newmis) // Ensure newmis was spawned by launch_spike
        {
            newmis.velocity = self.movedir * 500;
            if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
            {
                newmis.touch = superspike_touch; // Assumed defined (e.g. items.qc or weapons.qc)
            }
        }
    }
};

void() shooter_think =
{
    spikeshooter_use();
    self.nextthink = time + self.wait;
    // newmis.velocity = self.movedir * 500; // This line seems redundant here, newmis is local to spikeshooter_use's scope if launch_spike handles it locally
};

/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike/laser in the direction set in QuakeEd.
"movedir" is set by SetMovedir based on angles.
*/
void() trap_spikeshooter =
{
    SetMovedir();
    self.use = spikeshooter_use;
    self.netname = "$qc_spike_trap";
    self.killstring ="$qc_ks_spiked";

    if (self.spawnflags & SPAWNFLAG_LASER)
    {
        precache_model2("progs/laser.mdl"); // KEX engine should handle .mdl if available
        precache_sound2("enforcer/enfire.wav");
        precache_sound2("enforcer/enfstop.wav"); // Often unused by single shot lasers
    }
    else
    {
        precache_sound("weapons/spike2.wav");
    }
};

/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes/lasers.
"wait" : time between shots (1.0 default).
"nextthink" : delay before firing first shot (can be used to stagger multiple shooters).
*/
void() trap_shooter =
{
    trap_spikeshooter(); // Initialize common properties
    
    if (self.wait == 0)
    {
        self.wait = 1;
    }

    // self.ltime is set by the engine at spawn. Add current time for absolute nextthink.
    self.nextthink = time + self.nextthink + self.wait; // If map editor set nextthink as delay, this adds it.
    self.think = shooter_think;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Air Bubbles
//=============================================================================
void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)
Decorative air bubbles. Removed in deathmatch.
*/
void() air_bubbles =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }

    precache_model("progs/s_bubble.spr"); // Bubble sprite
    self.nextthink = time + 1; // Initial delay
    self.think = make_bubbles;
};

void() make_bubbles =
{
    local entity    bubble;

    bubble = spawn();
    setmodel(bubble, "progs/s_bubble.spr");
    setorigin(bubble, self.origin);
    bubble.movetype = MOVETYPE_NOCLIP; // Bubbles ignore collision
    bubble.solid = SOLID_NOT;
    bubble.velocity = '0 0 15'; // Bubbles rise
    bubble.nextthink = time + 0.5;
    bubble.think = bubble_bob;    // Bobbing motion
    bubble.touch = bubble_remove; // Remove if touched (e.g. by player)
    bubble.classname = "bubble";
    bubble.frame = 0; // Initial sprite frame
    bubble.cnt = 0;   // Counter for lifespan/split logic
    setsize(bubble, '-8 -8 -8', '8 8 8'); // Small trigger size

    self.nextthink = time + random() + 0.5; // Next bubble spawn time
    self.think = make_bubbles;
};

void() bubble_split =
{
    local entity    bubble;

    // Create a new bubble when one splits (original behavior was for one bubble to become two smaller ones effectively)
    bubble = spawn();
    setmodel(bubble, "progs/s_bubble.spr");
    setorigin(bubble, self.origin);
    bubble.movetype = MOVETYPE_NOCLIP;
    bubble.solid = SOLID_NOT;
    bubble.velocity = self.velocity; // Inherit velocity
    bubble.nextthink = time + 0.5;
    bubble.think = bubble_bob;
    bubble.touch = bubble_remove;
    bubble.classname = "bubble";
    bubble.frame = 1; // Different frame for split bubble (if sprite has it)
    bubble.cnt = 10;  // Reset counter for new bubble
    setsize(bubble, '-8 -8 -8', '8 8 8');

    // Modify original bubble
    self.frame = 1; // Change frame of original bubble
    self.cnt = 10;  // Reset counter

    if (self.waterlevel != 3) // Remove if out of deep water
    {
        remove(self);
    }
};

void() bubble_remove =
{
    if (other.classname == self.classname) // Don't remove if touched by another bubble
    {
        return;
    }
    remove(self);
};

void() bubble_bob =
{
    local float        rnd1, rnd2, rnd3;

    self.cnt = self.cnt + 1;
    if (self.cnt == 4) // Original split condition
    {
        bubble_split();
    }

    if (self.cnt == 20) // Lifespan
    {
        remove(self);
        return; // Ensure no further processing after removal
    }

    // Randomize velocity slightly for bobbing effect
    rnd1 = self.velocity_x + (-10 + (random() * 20));
    rnd2 = self.velocity_y + (-10 + (random() * 20));
    rnd3 = self.velocity_z + 10 + random() * 10; // Tend to rise

    // Clamp horizontal drift
    if (rnd1 > 10) { rnd1 = 5; }
    if (rnd1 < -10) { rnd1 = -5; }
    if (rnd2 > 10) { rnd2 = 5; }
    if (rnd2 < -10) { rnd2 = -5; }
    // Clamp vertical rise
    if (rnd3 < 10) { rnd3 = 15; }
    if (rnd3 > 30) { rnd3 = 25; }
    
    self.velocity_x = rnd1;
    self.velocity_y = rnd2;
    self.velocity_z = rnd3;
        
    self.nextthink = time + 0.5;
    self.think = bubble_bob;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Viewthing (Debug)
//=============================================================================
/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)
For debugging. Displays player model. Avoid use in final maps.
*/
void() viewthing =
{
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    precache_model("progs/player.mdl");
    setmodel(self, "progs/player.mdl");
};

//=============================================================================
// ##IDSOFT - ##Quedra: Simple BModels (func_wall, func_illusionary, etc.)
//=============================================================================
void() func_wall_use =
{    // change to alternate textures (if frame 1 is defined in .map for alternate skin)
    self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
A bmodel that is solid. Can be made to toggle texture frame if targeted.
*/
void() func_wall =
{
    self.angles = '0 0 0';
    self.classname = "func_wall";
    self.movetype = MOVETYPE_PUSH;    // So it doesn't get pushed by anything
    self.solid = SOLID_BSP;
    self.use = func_wall_use;       // If targeted, allow frame toggle
    setmodel(self, self.model);     // Set brush model
};

/*QUAKED func_illusionary (0 .5 .8) ?
A bmodel that looks solid but allows entities to pass through.
*/
void() func_illusionary =
{
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;         // Not solid
    setmodel(self, self.model);
    makestatic(self);               // Not affect by physics, doesn't move
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the specified episode (spawnflags: E1=1, E2=2, E3=4, E4=8)
has already been completed, preventing re-entry.
*/
void() func_episodegate =
{
    // serverflags stores completed episodes (bitwise)
    if (!(serverflags & self.spawnflags))
    {
        return;            // Episode not completed, gate remains inactive/gone
    }
    // Episode completed, make gate solid
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    self.use = func_wall_use; // Allow texture toggle if desired
    setmodel(self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils (runes).
Used to block access to the final boss (end.bsp) until all episodes are done.
*/
void() func_bossgate =
{
    // serverflags bit 0-3 for episodes 1-4. (1+2+4+8 = 15)
    if ((serverflags & 15) == 15)
    {
        return;        // All episodes completed, gate inactive/gone
    }
    // Not all sigils collected, make gate solid
    self.angles = '0 0 0';
    self.movetype = MOVETYPE_PUSH;
    self.solid = SOLID_BSP;
    self.use = func_wall_use;
    setmodel(self, self.model);
};

//=============================================================================
// ##IDSOFT - ##Quedra: Ambient Sound Emitters
//=============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a sucking wind sound.
*/
void() ambient_suck_wind =
{
    precache_sound("ambience/suck1.wav");
    ambientsound(self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a droning ambient sound.
*/
void() ambient_drone =
{
    precache_sound("ambience/drone6.wav");
    ambientsound(self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a fluorescent light buzzing sound.
*/
void() ambient_flouro_buzz =
{
    precache_sound("ambience/buzz1.wav");
    ambientsound(self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a dripping sound.
*/
void() ambient_drip =
{
    precache_sound("ambience/drip1.wav");
    ambientsound(self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a computer humming sound.
*/
void() ambient_comp_hum =
{
    precache_sound("ambience/comp1.wav");
    ambientsound(self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a thunder sound.
*/
void() ambient_thunder =
{
    precache_sound("ambience/thunder1.wav");
    ambientsound(self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays a light buzzing sound (often fluorescent hum).
*/
void() ambient_light_buzz =
{
    precache_sound("ambience/fl_hum1.wav");
    ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays swamp ambient sound variant 1.
*/
void() ambient_swamp1 =
{
    precache_sound("ambience/swamp1.wav");
    ambientsound(self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
Plays swamp ambient sound variant 2.
*/
void() ambient_swamp2 =
{
    precache_sound("ambience/swamp2.wav");
    ambientsound(self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

//=============================================================================
// ##IDSOFT - ##Quedra: Noise Maker (Debug)
//=============================================================================
void() noise_think =
{
    self.nextthink = time + 0.5;
    sound(self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
    sound(self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
    sound(self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
    sound(self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
    sound(self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
    sound(self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
    sound(self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)
For optimization testing; starts many sounds. Avoid in final maps.
*/
void() misc_noisemaker =
{
    precache_sound2("enforcer/enfire.wav"); // KEX engine uses precache_sound2 for some legacy compatibility
    precache_sound2("enforcer/enfstop.wav");
    precache_sound2("enforcer/sight1.wav");
    precache_sound2("enforcer/sight2.wav");
    precache_sound2("enforcer/sight3.wav");
    precache_sound2("enforcer/sight4.wav");
    precache_sound2("enforcer/pain1.wav");
    precache_sound2("enforcer/pain2.wav");
    precache_sound2("enforcer/death1.wav");
    precache_sound2("enforcer/idle1.wav");

    self.nextthink = time + 0.1 + random(); // Stagger start
    self.think = noise_think;
};

//=============================================================================
// misc.qc - FQX Mod - Miscellaneous Entities & Logic - END
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
//=============================================================================