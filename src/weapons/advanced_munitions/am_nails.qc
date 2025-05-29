//=============================================================================
// am_nails.qc - FQX Mod - Nail and Spike Projectile System
// Location: /fqx_mod/source/weapons/ammo/ 
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Initial Quedra-audited version. Conforms to FQX commenting and
// ##Quedra: formatting standards.
// ##Quedra: This file implements the projectile system for nailguns and
// ##Quedra: spike-based weapons, including map traps that utilize these.
// ##Quedra: Dependencies: Uses SUB_Remove from subs.qc. Projectile models
// ##Quedra: ("progs/spike.mdl", "progs/s_spike.mdl") must be precached
// ##Quedra: (typically in op_precache.qc).
// ##Quedra: v1.0.0 - ##Quedra: Applied FQX standard header, footer, and commenting.
// ##Quedra:          No logical changes from originally provided user file.
//=============================================================================

/*
==============================================================================
AM_NAILS - Nail and Spike Projectile System (Original Header)

This file implements the projectile system for nailguns and spike-based weapons.
Features:
- Standard nails
- Super spikes (higher damage)
- Collision and damage handling for nail/spike projectiles
==============================================================================
*/

//=============================================================================
// ##FQX - ##Quedra: FORWARD DECLARATIONS
//=============================================================================
void() spike_touch;                                     // ##FQXCUSTOM - ##Quedra: IDSOFT base, FQX context.
void() superspike_touch;                                // ##FQXCUSTOM - ##Quedra: IDSOFT base, FQX context.
void(vector org, vector dir) launch_spike;              // ##FQXCUSTOM - ##Quedra: IDSOFT base, FQX context.
void() W_FireSuperSpikes;                               // ##FQXCUSTOM - ##Quedra: IDSOFT base, FQX context.
void(float ox) W_FireSpikes;                            // ##FQXCUSTOM - ##Quedra: IDSOFT base, FQX context.

//=============================================================================
// ##FQXCUSTOM - ##Quedra: launch_spike
// ##IDSOFT: Based on id Software's original launch_spike.
// ##Quedra: Used for both the player and map traps (e.g., ogre, trap_spikeshooter).
// ##Quedra: The 'newmis' global entity is set by this function.
//=============================================================================
void(vector org, vector dir) launch_spike =
{
    newmis = spawn ();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;

    newmis.angles = vectoangles(dir);
    
    newmis.touch = spike_touch;         // Default to regular spike
    newmis.classname = "spike"; 
    // ##Quedra: CRITICAL - "progs/spike.mdl" MUST be precached in op_precache.qc
    setmodel (newmis, "progs/spike.mdl"); 
    
    newmis.think = SUB_Remove;          // Assumes SUB_Remove is globally available (e.g. from subs.qc)
    newmis.nextthink = time + 6;

    setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);       
    setorigin (newmis, org);

    newmis.velocity = dir * 1000;
};

//=============================================================================
// ##FQXCUSTOM - ##Quedra: spike_touch
// ##IDSOFT: Based on id Software's original spike_touch.
// ##Quedra: Handles collision for regular nails.
//=============================================================================
void() spike_touch =
{
    if (other == self.owner)
        return;
    if (other.solid == SOLID_TRIGGER) // ##Quedra: Do not interact with trigger fields
        return; 
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    // ##Quedra: Ensure 'spawn_touchblood' is available, and T_Damage is correctly defined.
    if (other.takedamage)
    {
        spawn_touchblood (9);       // Assumes spawn_touchblood is available (e.g. from weapons.qc)
        T_Damage (other, self, self.owner, 9);
    }
    else
    {
        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        if (self.classname == "wizard_spike")       // Example classname check from original
            WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
        else if (self.classname == "knight_spike")  // Example classname check from original
            WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
        else
            WriteByte (MSG_BROADCAST, TE_SPIKE);    // Standard spike temp entity
        WriteCoord (MSG_BROADCAST, self.origin_x);
        WriteCoord (MSG_BROADCAST, self.origin_y);
        WriteCoord (MSG_BROADCAST, self.origin_z);
    }
    remove(self);
};

//=============================================================================
// ##FQXCUSTOM - ##Quedra: superspike_touch
// ##IDSOFT: Based on id Software's original superspike_touch.
// ##Quedra: Handles collision for super nails (Super Nailgun).
//=============================================================================
void() superspike_touch =
{
    if (other == self.owner)
        return;
    if (other.solid == SOLID_TRIGGER) // ##Quedra: Do not interact with trigger fields
        return; 
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    if (other.takedamage)
    {
        spawn_touchblood (18);      // Assumes spawn_touchblood is available
        T_Damage (other, self, self.owner, 18);
    }
    else
    {
        WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte (MSG_BROADCAST, TE_SUPERSPIKE); // Super spike temp entity
        WriteCoord (MSG_BROADCAST, self.origin_x);
        WriteCoord (MSG_BROADCAST, self.origin_y);
        WriteCoord (MSG_BROADCAST, self.origin_z);
    }
    remove(self);
};

//=============================================================================
// ##FQXCUSTOM - ##Quedra: W_FireSuperSpikes
// ##IDSOFT: Based on id Software's original.
// ##Quedra: Handles firing logic for the Super Nailgun's main centered volley.
// ##Quedra: This function sets all properties for the super shot.
//=============================================================================
void() W_FireSuperSpikes =
{
    local vector    dir;
    
    // ##Quedra: Sound assumed to be precached (e.g. in op_precache.qc)
    sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    self.attack_finished = time + 0.2;      // Cooldown for Super Nailgun volley
    self.currentammo = self.ammo_nails = self.ammo_nails - 2; // Consume ammo
    
    dir = aim (self, 1000);                 // Assumes aim() is available
    
    // Launch spike from center view
    // ##Quedra: self.origin for player is typically at feet; + '0 0 16' approximates eye/weapon level.
    launch_spike (self.origin + '0 0 16', dir);
    
    // Configure the launched spike (newmis global) for super properties
    if (newmis) // ##Quedra: Good practice to check if newmis was successfully spawned
    {
        newmis.classname = "super_spike";
        newmis.touch = superspike_touch;
        // ##Quedra: CRITICAL - "progs/s_spike.mdl" MUST be precached in op_precache.qc
        setmodel (newmis, "progs/s_spike.mdl");
    }
    
    self.punchangle_x = -2;                 // Recoil
};

//=============================================================================
// ##FQXCUSTOM - ##Quedra: W_FireSpikes
// ##IDSOFT: Based on id Software's original.
// ##Quedra: This function is typically called by player_nail1() (or equivalent).
// ##Quedra: It handles firing single nails OR delegates to W_FireSuperSpikes.
// ##Quedra: 'ox' is an X-offset for alternating nail fire (standard nailgun).
//=============================================================================
void(float ox) W_FireSpikes =
{
    local vector    dir;

    // ##Quedra: Check if current weapon is Super Nailgun (IT_SLOT_HEAVY assumed)
    // ##Quedra: and if it should fire its special volley.
    if (self.weapon == IT_SLOT_HEAVY) // ##Quedra: Assuming IT_SLOT_HEAVY is Super Nailgun
    {
        if (self.ammo_nails >= 2)       // Enough ammo for super volley
        {
            // ##Quedra: Could add fire mode check here if SNG has modes.
            W_FireSuperSpikes();        // Fire the centered super volley
            return;                     // Exit after firing super volley
        }
        else // ##Quedra: Not enough ammo for SNG super volley, try single nail.
        {
             if (self.ammo_nails < 1)   // No ammo at all
             {
                // ##Quedra: W_BestWeapon() and W_SetCurrentAmmo() assumed available (e.g. from weapons.qc)
                self.weapon = W_BestWeapon(); 
                W_SetCurrentAmmo();
                return;
             }
             // ##Quedra: Fall through to fire a single, centered nail for SNG with <2 ammo.
             ox = 0;                    // Force center fire for SNG single shot fallback
        }
    }

    // --- Standard Nailgun logic OR SNG single nail fallback ---
    if (self.ammo_nails < 1)            // Double check ammo for standard nailgun path
    {
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        return;
    }

    makevectors (self.v_angle);         // For v_right if ox is used
    // ##Quedra: Sound assumed precached (e.g. "weapons/rocket1i.wav" is often nailgun sound)
    sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
    
    self.attack_finished = time + 0.1;  // Standard nailgun ROF
    self.punchangle_x = -1;             // Standard nailgun recoil

    self.currentammo = self.ammo_nails = self.ammo_nails - 1; // Consume 1 nail
    dir = aim (self, 1000);
    
    // ##Quedra: Launch a single nail. If ox is non-zero, it will be offset.
    // ##Quedra: If this is SNG fallback (ox=0), it fires from center.
    launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
    // ##Quedra: newmis (global) gets default spike properties from launch_spike.
};

//=============================================================================
// am_nails.qc - FQX Mod - Nail and Spike Projectile System - END
// ##FQX - ##Quedra: Version 1.0.0
//=============================================================================