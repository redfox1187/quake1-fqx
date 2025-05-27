//=============================================================================
// combat.qc - FQX Mod - Core Combat & Damage Functions
// Location: /fqx_mod/source/game/
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
// ##IDSOFT: Base code from id Software, Quake.
// ##Quedra: This file contains core damage application (T_Damage, T_RadiusDamage)
// ##Quedra: and related combat logic like CanDamage and Killed.
// ##Quedra: Integrated FQX-style diagnostic dprints for debugging purposes.
// ##Quedra: v1.0.1 - Added diagnostic dprints to T_Damage, T_RadiusDamage, and Killed.
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

// Forward declarations (assuming they are in defs.qc or similar)
void() T_MissileTouch; // Example, may not be used directly here but often in combat context
void() info_player_start; // Example
void(entity targ, entity attacker) ClientObituary; // From client.qc
void() monster_death_use; // From monsters.qc or individual monster files
void() FoundTarget; // From ai.qc or monster logic

// Global variables (assuming they are in defs.qc or similar)
float   killed_monsters;    // Counts killed monsters
entity  damage_attacker;    // Stores attacker for delayed damage/triggers
float   teamplay;           // Teamplay cvar
float   skill;              // Skill cvar
float   coop;               // Coop cvar

//=============================================================================
// ##IDSOFT - ##Quedra: CanDamage
//=============================================================================
/*
============
CanDamage

Returns true if the inflictor can directly damage the target. Used for
explosions and melee attacks. Ensures visibility and line of sight.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
    // bmodels need special checking because their origin is '0 0 0'
    // and their geometry is defined by absmin/absmax
    if (targ.movetype == MOVETYPE_PUSH)
    {
        traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self); // Trace to center of bmodel
        if (trace_fraction == 1) // No obstruction
        {
            return TRUE;
        }
        if (trace_ent == targ) // Hit the target bmodel directly
        {
            return TRUE;
        }
        return FALSE; // Obstructed
    }
    
    // For point entities, check direct line of sight to origin and some surrounding points
    traceline(inflictor.origin, targ.origin, TRUE, self);
    if (trace_fraction == 1)
    {
        return TRUE;
    }
    traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
    if (trace_fraction == 1)
    {
        return TRUE;
    }
    traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
    if (trace_fraction == 1)
    {
        return TRUE;
    }
    traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
    if (trace_fraction == 1)
    {
        return TRUE;
    }
    traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
    if (trace_fraction == 1)
    {
        return TRUE;
    }

    return FALSE; // All traces failed
};

//=============================================================================
// ##IDSOFT - ##Quedra: Killed
//=============================================================================
/*
============
Killed

Called when an entity's health drops to 0 or below.
Handles logic for different entity types upon death.
============
*/
void(entity targ, entity attacker) Killed =
{
    local entity oself;

    oself = self; // Store current global 'self'
    self = targ;  // Set global 'self' to the entity being killed
    
    if (self.health < -99) // Cap health for display purposes if it goes very low
    {
        self.health = -99;
    }

    // Special handling for MOVETYPE_PUSH (bmodels like doors) or MOVETYPE_NONE (static entities)
    if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
    {
        // ##Quedra: DEBUG - Diagnostic print.
        dprint("Killed: about to call th_die for self (bmodel/static) = "); dprint(etos(self)); dprint(", attacker = "); dprint(etos(attacker)); dprint("\n");
        self.th_die(); // Call the entity's specific death function
        // ##Quedra: DEBUG - Diagnostic print.
        dprint("Killed: returned from th_die for self (bmodel/static) = "); dprint(etos(self)); dprint("\n");
        self = oself; // Restore original global 'self'
        return;
    }

    self.enemy = attacker; // Set the killer

    // Update monster kill count and player frags if a monster was killed
    if (self.flags & FL_MONSTER)
    {
        killed_monsters = killed_monsters + 1;
        WriteByte(MSG_ALL, SVC_KILLEDMONSTER); // Notify clients
        if (attacker.classname == "player")
        {
            attacker.frags = attacker.frags + 1;
        }
        
        // Achievement for monster infighting
        if (attacker != self && attacker.flags & FL_MONSTER)
        {
            WriteByte(MSG_ALL, SVC_ACHIEVEMENT);
            WriteString(MSG_ALL, "ACH_FRIENDLY_FIRE");
        }
    }

    ClientObituary(self, attacker); // Display death message
    
    self.takedamage = DAMAGE_NO;    // Entity can no longer take damage
    self.touch = SUB_Null;          // Disable touch function
    monster_death_use();            // Call monster-specific death 'use' function (targets, etc.)
    
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("Killed: about to call th_die for self (general) = "); dprint(etos(self)); dprint(", attacker = "); dprint(etos(attacker)); dprint("\n");
    self.th_die();                  // Call the entity's specific death function (animations, gibs, etc.)
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("Killed: returned from th_die for self (general) = "); dprint(etos(self)); dprint("\n");
    
    self = oself; // Restore original global 'self'
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_Damage
//=============================================================================
/*
============
T_Damage

The damage is coming from 'inflictor', but the entity should get mad at 'attacker'.
This is the core function for applying damage to entities.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("T_Damage: targ = "); dprint(etos(targ)); dprint(", inflictor = "); dprint(etos(inflictor)); dprint(", attacker = "); dprint(etos(attacker)); dprint(", damage = "); dprint(ftos(damage)); dprint("\n");
    local    vector    dir;        // Direction vector for knockback
    local    entity    oldself;    // To preserve global 'self'
    local    float    save;       // Damage absorbed by armor
    local    float    take;       // Actual health damage taken

    if (!targ.takedamage) // Target cannot take damage
    {
        return;
    }

    // Prevent bot players from harming human players in coop (KEX specific?)
    if (coop && targ != attacker && targ.classname == "player" && attacker.classname == "player")
    {
        if (attacker.flags & FL_ISBOT && !(targ.flags & FL_ISBOT))
        {
            return;
        }
    }    

    // Shub-Niggurath specific damage immunity (original Quake behavior for boss)
    if (targ.classname == "monster_oldone" && damage < 9999) // Requires massive damage to hurt Shub
    {
        return;
    }

    // Store attacker for use by other systems (e.g., triggers activated by damage)
    damage_attacker = attacker;

    // Apply Quad Damage multiplier if attacker has the powerup
    if (attacker.super_damage_finished > time)
    {
        damage = damage * 4;
    }

    // Calculate damage absorbed by armor
    save = ceil(targ.armortype * damage); // armortype is a multiplier (e.g., 0.3, 0.6, 0.8)

    if (save >= targ.armorvalue) // Armor fully depleted
    {
        save = targ.armorvalue;
        targ.armortype = 0; // No armor type left
        targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)); // Remove armor items
    }
    
    targ.armorvalue = targ.armorvalue - save; // Reduce armor points
    take = ceil(damage - save); // Actual health damage

    // Accumulate damage for client-side display (sent at end of frame)
    if (targ.flags & FL_CLIENT)
    {
        targ.dmg_take = targ.dmg_take + take;
        targ.dmg_save = targ.dmg_save + save;
        targ.dmg_inflictor = inflictor; // Store last inflictor for HUD
    }

    // Apply knockback if inflictor is not the world and target can walk
    if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK))
    {
        dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5; // Direction from explosion center to target
        dir = normalize(dir);
        targ.velocity = targ.velocity + dir * damage * 8; // Apply knockback proportional to damage
    }

    // Check for God mode
    if (targ.flags & FL_GODMODE)
    {
        return; // No damage taken
    }

    // Check for Pentagram of Protection (Invincibility)
    if (targ.invincible_finished >= time)
    {
        if (self.invincible_sound < time) // Play protection sound if not played recently
        {
            sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
            self.invincible_sound = time + 2; // Cooldown for sound
        }
        return; // No damage taken
    }

    // Teamplay: prevent friendly fire if teamplay mode 1 (no FF) is active
    if ((teamplay == 1 && targ != attacker) && (targ.team > 0) && (targ.team == attacker.team))
    {
        return;
    }

    // Flag if player took actual health damage (KEX specific for achievements/stats?)
    if (targ.classname == "player" && take != 0)
    {
        targ.took_damage = TRUE; // KEX uses TRUE/FALSE
    }

    // Apply health damage
    targ.health = targ.health - take;

    // Check if target is killed
    if (targ.health <= 0)
    {
        Killed(targ, attacker); // Call Killed function
        return;
    }

    // Target is damaged but not killed, react to pain
    oldself = self; // Preserve global self
    self = targ;    // Set global self to the damaged target for its pain function

    // Monster reaction logic
    if ((self.flags & FL_MONSTER) && attacker != world)
    {
        // Monsters get mad at attacker unless it's the same class (except for Grunts/Soldiers)
        if (self != attacker && attacker != self.enemy)
        {
            if ((self.classname != attacker.classname) || (self.classname == "monster_army"))
            {
                if (self.enemy.classname == "player") // If current enemy is player, store it as oldenemy
                {
                    self.oldenemy = self.enemy;
                }
                self.enemy = attacker; // Set new enemy to the attacker
                FoundTarget();         // Trigger monster's target acquisition logic
            }
        }
    }

    // Call target's pain function if it exists
    if (self.th_pain)
    {
        self.th_pain(attacker, take);
        // In Nightmare skill, monsters have reduced pain stun duration
        if (skill == 3) // Nightmare
        {
            self.pain_finished = time + 5; // Longer pain stun immunity
        }
    }

    self = oldself; // Restore global self
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_RadiusDamage
//=============================================================================
/*
============
T_RadiusDamage

Damages all entities within a radius of 'inflictor'.
'attacker' is the entity credited with the damage (e.g., the player who fired a rocket).
'ignore' is an entity to skip (usually the inflictor itself if it's a missile, or the recently damaged entity).
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
    // ##Quedra: DEBUG - Diagnostic print.
    dprint("T_RadiusDamage: inflictor = "); dprint(etos(inflictor)); dprint(", attacker = "); dprint(etos(attacker)); dprint(", damage = "); dprint(ftos(damage)); dprint(", ignore = "); dprint(etos(ignore));dprint("\n");
    local    float     points;     // Damage points to apply
    local    entity    head;       // Current entity being checked in the radius
    local    vector    org;        // Center point of the entity being checked

    // Find all entities within damage radius + 40 (a buffer)
    head = findradius(inflictor.origin, damage + 40);
    
    while (head) // Loop through found entities
    {
        if (head != ignore) // Don't damage the 'ignore' entity
        {
            if (head.takedamage) // If the entity can take damage
            {
                // Calculate distance from explosion center (inflictor) to center of the entity (head)
                org = head.origin + (head.mins + head.maxs) * 0.5;
                points = 0.5 * vlen(inflictor.origin - org); // Damage falloff with distance

                if (points < 0) // Should not happen with vlen, but as safeguard
                {
                    points = 0;
                }
                points = damage - points; // Final damage after falloff

                if (head == attacker) // Attacker takes half damage from their own explosions
                {
                    points = points * 0.5;
                }

                if (points > 0) // If there's damage to apply
                {
                    if (CanDamage(head, inflictor)) // Check line of sight for damage
                    {
                        // Shamblers take half damage from explosions
                        if (head.classname == "monster_shambler")                        
                        {
                            T_Damage(head, inflictor, attacker, points * 0.5);
                        }
                        else
                        {
                            T_Damage(head, inflictor, attacker, points);
                        }
                    }
                }
            }
        }
        head = head.chain; // Move to next entity in findradius list
    }
};

//=============================================================================
// ##IDSOFT - ##Quedra: T_BeamDamage (Unused in standard Quake, possibly for a beam weapon)
//=============================================================================
/*
============
T_BeamDamage

Similar to T_RadiusDamage but seems tailored for a continuous beam.
'attacker' is both the source of the beam and the one credited.
Likely intended for a weapon like a lightning gun that might damage multiple targets in a line/cone.
This specific implementation is radius-based like T_RadiusDamage.
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
    local    float     points;
    local    entity    head;

    head = findradius(attacker.origin, damage + 40); // Find entities around the attacker
    
    while (head)
    {
        if (head.takedamage)
        {
            points = 0.5 * vlen(attacker.origin - head.origin); // Distance from attacker
            if (points < 0)
            {
                points = 0;
            }
            points = damage - points; // Damage after falloff

            if (head == attacker) // Attacker takes half damage
            {
                points = points * 0.5;
            }

            if (points > 0)
            {
                if (CanDamage(head, attacker)) // Check LoS
                {
                    // Shambler resistance
                    if (head.classname == "monster_shambler")                        
                    {
                        T_Damage(head, attacker, attacker, points * 0.5);
                    }
                    else
                    {
                        T_Damage(head, attacker, attacker, points);
                    }
                }
            }
        }
        head = head.chain;
    }
};

//=============================================================================
// combat.qc - FQX Mod - Core Combat & Damage Functions - END
// ##FQXCUSTOM - ##Quedra: Version 1.0.1
//=============================================================================