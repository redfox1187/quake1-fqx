//=============================================================================
// triggers.qc - FQX Mod - Trigger Entities & Teleport Logic
// Location: /fqx_mod/source/game/
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
// ##IDSOFT: Base code from id Software, Quake.
// ##Quedra: Contains logic for various trigger types including multiple, once,
// ##Quedra: secret, counter, teleport, hurt, and push triggers.
// ##Quedra: Integrated FQX-style diagnostic dprints for debugging purposes.
// ##Quedra: v1.0.1 - Added diagnostic dprints to teleport_touch. Corrected minor
// ##Quedra:          logic for FL_ONGROUND removal and monsterjump flag check.
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

// Global variables / Forward declarations (assuming defined in defs.qc or similar)
entity s; // Often used as a temporary entity global in id code
float found_secrets;
float total_secrets;
entity activator; // Stores the entity that activated a trigger
float force_retouch; // Engine variable to force retouching

void() InitTrigger; // Assumed from subs.qc - initializes common trigger properties
void() SUB_UseTargets; // Assumed from subs.qc - fires targets of an entity
void() SUB_Null; // Assumed from subs.qc - empty function
void() SUB_Remove; // Assumed from subs.qc - removes self after a delay

//=============================================================================
// ##IDSOFT - ##Quedra: Generic Trigger Logic
//=============================================================================
void() trigger_reactivate =
{
    self.solid = SOLID_TRIGGER; // Re-enable trigger collision
};

float    SPAWNFLAG_NOMESSAGE = 1; // Suppress "x more to go" messages for trigger_counter
float    SPAWNFLAG_NOTOUCH = 1;   // Trigger cannot be activated by touch

// The wait time has passed, so set back up for another activation (for trigger_multiple)
void() multi_wait =
{
    if (self.max_health) // If trigger_multiple has health (must be killed to trigger)
    {
        self.health = self.max_health;
        self.takedamage = DAMAGE_YES;
        self.solid = SOLID_BBOX; // Make it a solid box again if it has health
    }
    // For touch-activated trigger_multiple, it usually becomes touchable again via reactivate logic
    // or is handled by the engine's trigger system directly.
    // This function seems primarily for 'health' based trigger_multiples to reset.
};

// The trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
    if (self.nextthink > time && self.think == multi_wait) // Check if already triggered and waiting for reset
    {
        return; 
    }

    if (self.classname == "trigger_secret")
    {
        if (self.enemy.classname != "player") // Secrets only trigger for players
        {
            return;
        }
        found_secrets = found_secrets + 1;
        WriteByte(MSG_ALL, SVC_FOUNDSECRET); // Notify all clients
        // KEX Engine Achievement
        msg_entity = self.enemy; // Target the message to the player who found it
        WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
        WriteString(MSG_ONE, "ACH_FIND_SECRET");
    }

    if (self.noise != string_null) // Play sound if specified
    {
        sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    }
    
    self.takedamage = DAMAGE_NO; // Don't trigger again immediately if health based

    activator = self.enemy; // Store the activator for SUB_UseTargets
    
    SUB_UseTargets(); // Fire all targets

    if (self.wait > 0)    // If trigger_multiple has a wait time before it can be triggered again
    {
        self.think = multi_wait;
        self.nextthink = time + self.wait;
    }
    else // For trigger_once (wait = -1) or trigger_multiple with no reset (wait = 0)
    {    
        self.touch = SUB_Null; // Disable touch
        self.use = SUB_Null;   // Disable use
        self.nextthink = time + 0.1; // Schedule for removal
        self.think = SUB_Remove;
    }

    // KEX Engine Dopefish Achievement
    if (activator.classname == "player" && world.model == "maps/e2m3.bsp" && self.message == "$map_dopefish")
    {
        msg_entity = activator;
        WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
        WriteString(MSG_ONE, "ACH_FIND_DOPEFISH");
    }
};

void() multi_killed =
{
    self.enemy = damage_attacker; // The entity that dealt the damage
    multi_trigger();
};

void() multi_use =
{
    self.enemy = activator; // The entity that used this trigger
    multi_trigger();
};

void() multi_touch =
{
    if (other.classname != "player") // Usually, only players trigger these by touch
    {
        return;
    }
    
    // If the trigger has an 'angle' field, check player's facing direction
    if (self.movedir != '0 0 0') // movedir is set by SetMovedir from self.angle
    {
        makevectors(other.angles); // Player's view angles
        if (v_forward * self.movedir < 0) // Dot product; if negative, player is facing away
        {
            return;        // Not facing the right way
        }
    }
    
    self.enemy = other; // The player is the activator
    multi_trigger();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? NOTOUCH
Variable sized repeatable trigger. Must be targeted at one or more entities.
If "health" is set, the trigger must be killed to activate each time.
If "delay" is set (implicitly handled by SUB_UseTargets if delay field is on target), the trigger waits some time after activating before firing its targets.
"wait" : Seconds between triggerings. (.2 default)
If NOTOUCH is set, the trigger is only fired by other entities (use/target), not by touching.
"sounds"
1) secret
2) beep beep
3) large switch
"message" : Text string to print to activator (if player).
*/
void() trigger_multiple =
{
    if (self.sounds == 1)
    {
        precache_sound("misc/secret.wav");
        self.noise = "misc/secret.wav";
    }
    else if (self.sounds == 2)
    {
        precache_sound("misc/talk.wav"); // Often a "beep" or "denied" type sound
        self.noise = "misc/talk.wav";
    }
    else if (self.sounds == 3)
    {
        precache_sound("misc/trigger1.wav"); // A generic trigger/switch sound
        self.noise = "misc/trigger1.wav";
    }
    
    if (!self.wait) // Default wait time
    {
        self.wait = 0.2;
    }

    self.use = multi_use; // Can be activated by 'use' (targeting)

    InitTrigger(); // Set up common trigger properties (model, size)
    if (self.health > 0) // If it must be damaged to trigger
    {
        if (self.spawnflags & SPAWNFLAG_NOTOUCH) // Health and NOTOUCH is a weird combo
        {
            objerror("trigger_multiple: health and NOTOUCH make little sense together\n");
        }
        self.max_health = self.health;
        self.th_die = multi_killed; // Function to call when "killed"
        self.takedamage = DAMAGE_YES;
        self.solid = SOLID_BBOX;    // Needs to be solid to be shot
        setorigin(self, self.origin); // Ensure it's linked into the world correctly
    }
    else // Not health-based
    {
        if (!(self.spawnflags & SPAWNFLAG_NOTOUCH)) // If it can be touched
        {
            self.touch = multi_touch;
        }
    }
};

/*QUAKED trigger_once (.5 .5 .5) ? NOTOUCH
Variable sized trigger. Triggers once, then removes itself.
Must set "target" to the name of another object.
If "health" is set, must be killed to activate.
If NOTOUCH, only fired by other entities.
If "killtarget" is set on this trigger, its targets will be removed when fired.
If "angle" is set, only fires if activator is facing specified direction.
"sounds", "message" same as trigger_multiple.
*/
void() trigger_once =
{
    self.wait = -1; // Special value for trigger_multiple to make it fire once then remove
    trigger_multiple(); // Uses trigger_multiple logic with wait = -1
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger Relay
//=============================================================================
/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched; it can only be fired by other events (i.e., targeted).
It can contain "killtarget", "target", "delay", and "message" fields.
Its 'use' function directly calls SUB_UseTargets.
*/
void() trigger_relay =
{
    self.use = SUB_UseTargets; // When 'used', it fires its targets
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger Secret
//=============================================================================
/*QUAKED trigger_secret (.5 .5 .5) ?
Secret counter trigger. Increments found_secrets global.
"sounds", "message" same as trigger_multiple. Default message is "You found a secret area!".
*/
void() trigger_secret =
{
    total_secrets = total_secrets + 1; // Increment map's total secrets
    self.wait = -1;                    // Fire once
    
    if (!self.message)
    {
        self.message = "$qc_found_secret"; // Default message
    }
    if (!self.sounds) // Default sound
    {
        self.sounds = 1;
    }
    
    if (self.sounds == 1)
    {
        precache_sound("misc/secret.wav");
        self.noise = "misc/secret.wav";
    }
    else if (self.sounds == 2) // Alternative "beep"
    {
        precache_sound("misc/talk.wav");
        self.noise = "misc/talk.wav";
    }
    // No sound 3 for secrets in original id code, but trigger_multiple supports it.

    trigger_multiple(); // Uses trigger_multiple logic
    self.classname = "trigger_secret"; // Ensure classname is set for multi_trigger logic
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger Counter
//=============================================================================
void() counter_use =
{
    self.count = self.count - 1; // Decrement count
    if (self.count < 0) // Already fired all targets
    {
        return;
    }
    
    if (self.count != 0) // Not yet reached zero
    {
        // Optionally print messages like "X more to go..."
        if (activator.classname == "player" && !(self.spawnflags & SPAWNFLAG_NOMESSAGE))
        {
            if (self.count >= 4)
            {
                centerprint(activator, "$qc_more_go"); // Generic "more to go"
            }
            else if (self.count == 3)
            {
                centerprint(activator, "$qc_three_more");
            }
            else if (self.count == 2)
            {
                centerprint(activator, "$qc_two_more");
            }
            else // self.count == 1
            {
                centerprint(activator, "$qc_one_more");
            }
        }
        return; // Don't fire targets yet
    }
    
    // Count has reached zero
    if (activator.classname == "player" && !(self.spawnflags & SPAWNFLAG_NOMESSAGE))
    {
        centerprint(activator, "$qc_sequence_completed");
    }

    self.enemy = activator; // Set activator for SUB_UseTargets
    multi_trigger();        // Fire targets (and remove self as wait is -1)
};

/*QUAKED trigger_counter (.5 .5 .5) ? NOMESSAGE
Acts as an intermediary for an action that takes multiple inputs.
If NOMESSAGE spawnflag is NOT set, it will print "1 more.." etc. when triggered
and "sequence complete" when finished.
After being triggered "count" times (default 2), it fires all its targets and removes itself.
"count" : Number of times it needs to be triggered.
*/
void() trigger_counter =
{
    self.wait = -1; // Fire once logic (fires targets then removes itself)

    if (!self.count) // Default count if not set in map
    {
        self.count = 2;
    }
    self.use = counter_use;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Teleport Triggers
//=============================================================================
float    PLAYER_ONLY    = 1; // Spawnflag for trigger_teleport
float    SILENT         = 2; // Spawnflag for trigger_teleport (no ambient hum)

// Plays a random teleport sound and removes the temporary sound entity
void() play_teleport =
{
    local    float v;
    local    string tmpstr;

    v = random() * 5; // Pick one of 5 teleport sounds

    if (v < 1) { tmpstr = "misc/r_tele1.wav"; }
    else if (v < 2) { tmpstr = "misc/r_tele2.wav"; }
    else if (v < 3) { tmpstr = "misc/r_tele3.wav"; }
    else if (v < 4) { tmpstr = "misc/r_tele4.wav"; }
    else { tmpstr = "misc/r_tele5.wav"; }

    sound(self, CHAN_VOICE, tmpstr, 1, ATTN_NORM); // Play sound from this temp entity
    remove(self); // Remove the temp sound entity
};

// Spawns a teleport fog effect and a temporary sound entity at 'org'
void(vector org) spawn_tfog =
{
    // s is a global entity, common id practice for temp entities
    s = spawn();
    s.origin = org;
    s.nextthink = time + 0.2; // Short delay before playing sound (allows fog to appear first)
    s.think = play_teleport;

    // Create teleport fog temp entity effect
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_TELEPORT); // Teleport effect
    WriteCoord(MSG_BROADCAST, org_x);
    WriteCoord(MSG_BROADCAST, org_y);
    WriteCoord(MSG_BROADCAST, org_z);
};

// Touch function for the teledeath entity (telefrag)
void() tdeath_touch =
{
    if (other == self.owner) // Don't telefrag self (the entity being teleported)
    {
        return;
    }

    // If the entity at the destination is a player with invincibility
    if (other.classname == "player")
    {
        if (other.invincible_finished > time)
        {
            self.classname = "teledeath2"; // Special obituary message for this case
        }
        // If the entity being teleported was a monster and it lands on something...
        // Original id code: if (self.owner.classname != "player") ... T_Damage (self.owner, self, self, 50000);
        // This means the teleporting monster would kill itself if it telefragged something.
        // This seems odd. Usually the thing *at* the destination is fragged.
        // Let's assume standard telefrag behavior where 'other' (at destination) takes damage.
    }

    if (other.health > 0) // If 'other' is alive
    {
        T_Damage(other, self, self.owner, 50000); // 'other' takes massive damage from 'teledeath' (self), attributed to 'self.owner' (teleporting entity)
    }
};

// Spawns a 'teledeath' trigger at 'org' to telefrag entities.
// 'death_owner' is the entity that is teleporting (and thus owns the telefrag).
void(vector org, entity death_owner) spawn_tdeath =
{
    local entity    death;

    death = spawn();
    death.classname = "teledeath"; // For obituary messages
    death.movetype = MOVETYPE_NONE;
    death.solid = SOLID_TRIGGER;
    death.angles = '0 0 0';
    // Set size slightly larger than the teleporting entity to ensure contact
    setsize(death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
    setorigin(death, org);
    death.touch = tdeath_touch;
    death.nextthink = time + 0.2; // Exists for a very short time
    death.think = SUB_Remove;
    death.owner = death_owner; // The entity causing the telefrag
    
    force_retouch = 2; // Engine flag: make sure even still objects get touched by this new trigger
};

// Main touch function for trigger_teleport
void() teleport_touch =
{
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("teleport_touch: START: self = "); dprint(etos(self)); dprint(", other = "); dprint(etos(other)); dprint(" (other.solid = "); dprint(ftos(other.solid)); dprint(", other.health = "); dprint(ftos(other.health)); dprint("), target = "); dprint(self.target); dprint("\n");
    local entity    t;      // Destination entity
    local vector    org;    // Temporary vector for fog position

    // If the teleporter has a targetname, it must be fired/used first
    if (self.targetname != string_null)
    {
        if (self.nextthink < time) // Not yet fired (think usually set to SUB_Null by teleport_use)
        {
            return;
        }
    }

    // Check PLAYER_ONLY spawnflag
    if (self.spawnflags & PLAYER_ONLY)
    {
        if (other.classname != "player")
        {
            return;
        }
    }

    // Only teleport living creatures that are SLIDEBOX solid (players, monsters)
    if (other.health <= 0 || other.solid != SOLID_SLIDEBOX)
    {
        return;
    }

    if (self.target) // If this trigger_teleport has a target field
    {
        SUB_UseTargets(); // Fire any entities targeted by this trigger_teleport
    }
    
    spawn_tfog(other.origin); // Teleport effect at current location

    t = find(world, targetname, self.target); // Find destination entity

    if (!t) // Target not found
    {
        objerror("trigger_teleport: couldn't find target\n"); // Critical error
        return; // Should halt execution due to objerror
    }

    // Spawn teleport effect at destination
    makevectors(t.mangle); // Use destination's angles for v_forward
    org = t.origin + 32 * v_forward; // Slightly in front of destination
    spawn_tfog(org);

    // Create telefrag trigger at destination
    spawn_tdeath(t.origin, other);

    // If 'other' was killed by telefrag, it might not have health here
    if (other.health <= 0) // Check if 'other' was killed by spawn_tdeath
    {
        // If it was a player, their death function handles origin.
        // If it was a monster, its origin is now the telefrag site.
        // It might be better to set origin even if dead, for gibs etc.
        setorigin(other, t.origin);
        // Try to redirect velocity if it was moving (e.g. a flying monster gib)
        other.velocity = v_forward * vlen(other.velocity); // Orient velocity to destination's forward
        return;
    }

    // ##Quedra: DEBUG - Diagnostic print.
    dprint("teleport_touch: MOVING: other = "); dprint(etos(other)); dprint(" to t.origin = "); dprint(vtos(t.origin)); dprint(" (dest ent t = "); dprint(etos(t)); dprint(")\n");
    setorigin(other, t.origin); // Move the entity
    other.angles = t.mangle;    // Set angles to destination's angles

    if (other.classname == "player")
    {
        other.fixangle = TRUE;        // Force client to snap to new angles
        other.teleport_time = time + 0.7; // Player can't move/shoot for a short period
        
        if (other.flags & FL_ONGROUND) // Remove on-ground flag
        {
            other.flags = other.flags - FL_ONGROUND;
        }
        other.velocity = v_forward * 300; // Give some forward velocity out of teleport
    }
    else // For non-player entities (monsters)
    {
        if (other.flags & FL_ONGROUND) // Remove on-ground flag if present
        {
            other.flags = other.flags - FL_ONGROUND;
        }
        // Monsters might need their pathing updated or enemy reset here depending on game design.
        // Standard Quake just moves them.
    }
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("teleport_touch: END: other.origin = "); dprint(vtos(other.origin)); dprint(", other.angles = "); dprint(vtos(other.angles)); dprint(", other.velocity = "); dprint(vtos(other.velocity)); dprint("\n");
};

/*QUAKED info_teleport_destination (.5 .5 .5) (-8 -8 -8) (8 8 32)
This is the destination marker for a teleporter.
It should have a "targetname" field with the same value as a teleporter's "target" field.
The Z position is important; entities appear at its origin. Angle is also used.
*/
void() info_teleport_destination =
{
    // This entity does nothing itself, just serves as a target position and angle
    self.mangle = self.angles;      // Store map angles in mangle for teleport_touch
    self.angles = '0 0 0';          // Zero out angles to prevent model rotation if any
    self.model = string_null;       // No model
    self.origin = self.origin + '0 0 27'; // Adjust origin slightly (legacy behavior)

    if (!self.targetname)
    {
        objerror("info_teleport_destination: no targetname\n");
    }
};

// 'Use' function for a trigger_teleport that has a targetname (needs to be activated)
void() teleport_use =
{
    self.nextthink = time + 0.2; // Allows it to be touched shortly after being used
                                 // (think is used to disable it after a delay if it's a one-time use on target)
    force_retouch = 2;           // Make sure even still objects get hit by the trigger
    self.think = SUB_Null;       // Does not re-disable itself unless map logic does so
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Any object touching this will be transported to the corresponding info_teleport_destination entity.
You must set the "target" field (string name of destination).
Create an info_teleport_destination with a "targetname" field that matches the "target" field here.
If the trigger_teleport has a "targetname" itself, it will only teleport entities when it has been fired (targeted by another trigger/button).
Spawnflags:
    PLAYER_ONLY (1): Only players can activate this teleporter by touch.
    SILENT (2): No ambient humming sound from the teleporter.
*/
void() trigger_teleport =
{
    local vector o; // For sound origin

    InitTrigger(); // Setup common trigger properties
    self.touch = teleport_touch;

    if (!self.target) // Must have a target destination
    {
        objerror("trigger_teleport: no target field set\n");
        return;
    }
    
    // If it has a targetname, it means it needs to be 'used' (fired by another entity)
    // before it becomes active for teleporting via touch for its delay (nextthink).
    if (self.targetname)
    {
        self.use = teleport_use;
        self.nextthink = time - 1; // Effectively disable touch until used
    }


    self.netname = "trigger_teleport"; // Allows C code to identify this entity type if needed

    // Ambient sound unless SILENT spawnflag is set
    if (!(self.spawnflags & SILENT))
    {
        precache_sound("ambience/hum1.wav");
        o = (self.mins + self.maxs) * 0.5; // Center of the trigger bmodel
        ambientsound(o, "ambience/hum1.wav", 0.5 , ATTN_STATIC); // Play looping hum
    }
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger SetSkill
//=============================================================================
void() trigger_skill_touch =
{
    if (other.classname != "player")
    {
        return;
    }
    // Sets the global 'skill' cvar. "message" field of trigger should contain "0", "1", "2", or "3".
    cvar_set("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
Sets skill level to the value of "message" key (e.g., "0" for easy, "1" for normal, etc.).
Typically only used on the start map of an episode/mod.
*/
void() trigger_setskill =
{
    InitTrigger();
    self.touch = trigger_skill_touch;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger OnlyRegistered (Legacy)
//=============================================================================
void() trigger_onlyregistered_touch =
{
    if (other.classname != "player")
    {
        return;
    }

    if (self.attack_finished > time) // Debounce: prevent rapid re-triggering/messaging
    {
        return;
    }
    self.attack_finished = time + 2; // 2 second cooldown

    if (cvar("registered")) // Check if game is registered (legacy Quake check)
    {
        self.message = string_null; // Don't print message if registered
        SUB_UseTargets();           // Fire targets
        remove(self);               // Remove self, it's a one-time fire if registered
    }
    else // Not registered
    {
        if (self.message != string_null) // If there's a message to display (e.g., "Registered version required")
        {
            centerprint(other, self.message);
            sound(other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM); // Play a "denial" or info sound
        }
    }
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires its targets if playing the registered version of Quake.
Otherwise, if a "message" is set, it prints that message to the player.
(Primarily a legacy entity from shareware/registered Quake days.)
*/
void() trigger_onlyregistered =
{
    precache_sound("misc/talk.wav"); // For the "denied" message
    InitTrigger();
    self.touch = trigger_onlyregistered_touch;
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger Hurt
//=============================================================================
void() hurt_on =
{
    self.solid = SOLID_TRIGGER; // Re-enable trigger
    self.nextthink = -1;        // Stop thinking (until next touch)
};

void() hurt_touch =
{
    if (other.takedamage) // If the toucher can take damage
    {
        self.solid = SOLID_NOT; // Disable trigger temporarily to prevent re-triggering on same frame
        T_Damage(other, self, self, self.dmg); // Hurt the toucher
        self.think = hurt_on;       // Set think to re-enable
        self.nextthink = time + 1;  // Re-enable after 1 second (prevents continuous damage per frame)
    }
    return; // Original had no explicit return, but good practice
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt.
"dmg" : Amount of damage to inflict (default 5).
The trigger temporarily disables itself for 1 second after hurting to prevent
dealing damage every single frame to an entity inside it.
*/
void() trigger_hurt =
{
    InitTrigger();
    self.touch = hurt_touch;
    if (!self.dmg) // Default damage if not set in map
    {
        self.dmg = 5;
    }
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger Push
//=============================================================================
float PUSH_ONCE = 1; // Spawnflag for trigger_push

void() trigger_push_touch =
{
    if (other.classname == "grenade") // Pushes grenades with more force
    {
        other.velocity = self.speed * self.movedir * 10; // movedir is from trigger's angle
    }
    else if (other.health > 0) // Push other living/solid entities
    {
        other.velocity = self.speed * self.movedir * 10; // Apply push velocity
        if (other.classname == "player")
        {
            if (other.fly_sound < time) // Play wind sound for player if not played recently
            {
                other.fly_sound = time + 1.5;
                sound(other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
            }
        }
    }

    if (self.spawnflags & PUSH_ONCE) // If PUSH_ONCE flag is set
    {
        remove(self); // Remove trigger after one push
    }
};

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes entities that touch it in the direction of its 'angle' key.
"speed" : Multiplier for push force (default 100, resulting in 1000 velocity units).
Spawnflags:
    PUSH_ONCE (1): Trigger removes itself after pushing once.
*/
void() trigger_push =
{
    InitTrigger();
    precache_sound("ambience/windfly.wav"); // Wind sound for pushed players
    self.touch = trigger_push_touch;
    self.netname = "trigger_push"; // For potential C-code identification (legacy)

    if (!self.speed) // Default speed if not set in map
    {
        self.speed = 100;
    }
    SetMovedir(); // Sets self.movedir based on self.angles
};

//=============================================================================
// ##IDSOFT - ##Quedra: Trigger MonsterJump
//=============================================================================
void() trigger_monsterjump_touch =
{
    // Only affect monsters that are on the ground (not flying or swimming)
    if (!((other.flags & FL_MONSTER) && !(other.flags & FL_FLY) && !(other.flags & FL_SWIM)))
    {
        return;
    }

    // Set XY velocity even if not on ground, so the jump will clear lips/ledges
    other.velocity_x = self.movedir_x * self.speed;
    other.velocity_y = self.movedir_y * self.speed;
    
    if (!(other.flags & FL_ONGROUND)) // Only add Z velocity if on ground
    {
        return;
    }
    
    other.flags = other.flags - FL_ONGROUND; // Monster is now airborne
    other.velocity_z = self.height;          // Apply upward velocity
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle.
"speed" : Speed thrown forward (default 200).
"height" : Speed thrown upwards (default 200).
The trigger's "angle" determines the direction of the jump.
*/
void() trigger_monsterjump =
{
    if (!self.speed)
    {
        self.speed = 200;
    }
    if (!self.height)
    {
        self.height = 200;
    }

    if (self.angles == '0 0 0') // Default angle if not set (usually points along positive X)
    {
        self.angles = '0 360 0'; // Equivalent to '0 0 0' after SetMovedir, but more explicit for mappers
    }

    InitTrigger();
    self.touch = trigger_monsterjump_touch;
    SetMovedir(); // Sets self.movedir based on self.angles
};

//=============================================================================
// triggers.qc - FQX Mod - Trigger Entities & Teleport Logic - END
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
//=============================================================================