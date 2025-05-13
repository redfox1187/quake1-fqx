// am_nails.qc

/*
==============================================================================
AM_NAILS - Nail and Spike Projectile System

This file implements the projectile system for nailguns and spike-based weapons.
Features:
- Standard nails
- Super spikes (higher damage)
- Collision and damage handling for nail/spike projectiles
==============================================================================
*/

// Function Declarations
void() spike_touch;
void() superspike_touch;
void(vector org, vector dir) launch_spike;
void() W_FireSuperSpikes; // Fires the centered super nail volley
void(float ox) W_FireSpikes; // Can fire single offset nails OR delegate to SuperSpikes

/*
===============
launch_spike

Used for both the player and the ogre.
The 'newmis' global entity is set by this function.
===============
*/
void(vector org, vector dir) launch_spike =
{
    newmis = spawn ();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;

    newmis.angles = vectoangles(dir);
    
    newmis.touch = spike_touch;      // Default to regular spike
    newmis.classname = "spike"; 
    setmodel (newmis, "progs/spike.mdl"); 
    
    newmis.think = SUB_Remove;
    newmis.nextthink = time + 6;

    setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);       
    setorigin (newmis, org);

    newmis.velocity = dir * 1000;
};

/*
================
spike_touch
Handles collision for regular nails.
================
*/
void() spike_touch =
{
    if (other == self.owner)
        return;
    if (other.solid == SOLID_TRIGGER)
        return;

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    if (other.takedamage)
    {
        spawn_touchblood (9);
        T_Damage (other, self, self.owner, 9);
    }
    else
    {
        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        if (self.classname == "wizard_spike")
            WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
        else if (self.classname == "knight_spike")
            WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
        else
            WriteByte (MSG_BROADCAST, TE_SPIKE);
        WriteCoord (MSG_BROADCAST, self.origin_x);
        WriteCoord (MSG_BROADCAST, self.origin_y);
        WriteCoord (MSG_BROADCAST, self.origin_z);
    }
    remove(self);
};

/*
================
superspike_touch
Handles collision for super nails (Super Nailgun).
================
*/
void() superspike_touch =
{
    if (other == self.owner)
        return;
    if (other.solid == SOLID_TRIGGER)
        return;

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    if (other.takedamage)
    {
        spawn_touchblood (18);
        T_Damage (other, self, self.owner, 18);
    }
    else
    {
        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
        WriteCoord (MSG_BROADCAST, self.origin_x);
        WriteCoord (MSG_BROADCAST, self.origin_y);
        WriteCoord (MSG_BROADCAST, self.origin_z);
    }
    remove(self);
};

/*
================
W_FireSuperSpikes
Handles firing logic for the Super Nailgun's main centered volley.
This function sets all properties for the super shot.
================
*/
void() W_FireSuperSpikes =
{
    local vector    dir;
    
    sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    
    self.attack_finished = time + 0.2; // Cooldown for Super Nailgun volley
    self.currentammo = self.ammo_nails = self.ammo_nails - 2;
    
    dir = aim (self, 1000);
    
    // Launch spike from center view
    launch_spike (self.origin + '0 0 16', dir); 
    
    // Configure the launched spike (newmis) for super properties
    newmis.classname = "super_spike";
    newmis.touch = superspike_touch;
    setmodel (newmis, "progs/s_spike.mdl");
    
    self.punchangle_x = -2;
};

/*
================
W_FireSpikes
This function is typically called by player_nail1() (or equivalent in player.qc).
It handles firing single nails (potentially offset by 'ox') OR
delegates to W_FireSuperSpikes if the current weapon is IT_SLOT_HEAVY (Super Nailgun)
and conditions for a super shot are met.

'ox' is an X-offset for alternating nail fire position for standard nailguns.
If IT_SLOT_HEAVY calls this and fires a super shot, 'ox' is ignored for that shot.
================
*/
void(float ox) W_FireSpikes =
{
    local vector    dir;

    // Check if the current weapon is the Super Nailgun (IT_SLOT_HEAVY)
    // and if it should fire its special volley.
    // This assumes the primary fire of IT_SLOT_HEAVY is the super volley.
    // If IT_SLOT_HEAVY has fire modes, player_nail1() or this function would need mode checks.
    if (self.weapon == IT_SLOT_HEAVY)
    {
        if (self.ammo_nails >= 2) // Enough ammo for super volley
        {
            // Optionally, check self.weapon_mode_heavy if SNG has multiple fire modes
            // For example, if primary mode is super volley:
            // if (self.weapon_mode_heavy == FIRE_MODE_PRIMARY || !self.weapon_mode_heavy) // Assuming 0 or primary is super
            // {
            W_FireSuperSpikes(); // Fire the centered super volley
            return; // Important: exit after firing super volley
            // }
            // If SNG's primary fire was single centered nails, it would be:
            // launch_spike(self.origin + '0 0 16', aim(self,1000)); ammo--; etc.
            // And W_FireSuperSpikes would be for its alt-fire.
            // But user report implies SNG's main fire is super volley and should be centered.
        }
        else // Not enough ammo for SNG super volley, try single nail (if SNG can fire single)
        {
             if (self.ammo_nails < 1) // No ammo at all
             {
                self.weapon = W_BestWeapon();
                W_SetCurrentAmmo();
                return;
             }
             // Fall through to fire a single, centered nail for SNG with <2 ammo.
             // The 'ox' passed by player_nail1 (if it's for alternating) should be overridden to 0.
             ox = 0; // Force center fire for SNG single shot fallback
        }
    }

    // --- Standard Nailgun logic OR SNG single nail fallback ---
    if (self.ammo_nails < 1) // Double check ammo for standard nailgun path
    {
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        return;
    }

    makevectors (self.v_angle); // For v_right if ox is used
    sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM); // Standard nail sound
    
    // Adjust attack_finished and punchangle for single nails
    self.attack_finished = time + 0.1; // Potentially faster ROF for single nails
    self.punchangle_x = -1; // Potentially less view kick for single nails

    self.currentammo = self.ammo_nails = self.ammo_nails - 1; // Consume 1 nail
    dir = aim (self, 1000);
    
    // Launch a single nail. If ox is non-zero, it will be offset.
    // If this is SNG fallback (ox=0), it fires from center.
    launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
    // newmis gets default spike properties from launch_spike
};