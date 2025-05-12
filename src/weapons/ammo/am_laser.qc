/*
==============================================================================
AM_LASER - Laser Projectile System

This file implements a physical projectile-based laser system.
Laser projectiles use actual entities with collision detection rather than trace attacks.

Features:
- Different laser types/powers
- Customizable damage values, velocities, and effects
- Support for different laser properties and behaviors
- Can be used by both player weapons and monster attacks

==============================================================================
*/

// Laser entity function declarations
void() laser_small_touch;
void() laser_medium_touch;
void() laser_big_touch;
void() laser_think;

// Laser type definitions
float LASER_SMALL = 1;    // Small, rapid laser - low damage but fast fire rate
float LASER_MEDIUM = 2;   // Medium laser - balanced damage and speed
float LASER_BIG = 3;      // Big, heavy laser - high damage but slow fire rate

// Laser base damage values
float DAMAGE_LASER_SMALL = 9;       // Fast but weaker
float DAMAGE_LASER_MEDIUM = 15;     // Balanced damage
float DAMAGE_LASER_BIG = 18;        // Base damage for heavy laser (additional random damage added)

// Velocity settings
float LASER_SPEED_SMALL = 900;      // Slower projectile
float LASER_SPEED_MEDIUM = 1200;    // Medium speed
float LASER_SPEED_BIG = 1500;       // Fast projectile

// Model specifications
// Note: Using standard laser.mdl for now, could be customized per type later
string LASER_MODEL = "progs/laser.mdl";

// Visual Effects
float EF_MUZZLEFLASH = 2;  // For reference - engine-defined muzzle flash effect

// Sound specifications 
string LASER_SOUND_SMALL = "enforcer/enfire.wav";
string LASER_SOUND_MEDIUM = "enforcer/enfire.wav";
string LASER_SOUND_BIG = "enforcer/enfire.wav";
string LASER_SOUND_BIG_SUPPLEMENT = "weapons/rocket1i.wav"; // Additional sound for big laser

/*
================
laser_small_touch
Handles collision of small laser with world or entities
================
*/
void() laser_small_touch =
{
    if (other == self.owner)
        return;

    if (other.solid == SOLID_TRIGGER)
        return;	// trigger field, do nothing

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    // hit something that bleeds
    if (other.takedamage)
    {
        spawn_touchblood(DAMAGE_LASER_SMALL);
        T_Damage(other, self, self.owner, DAMAGE_LASER_SMALL);
    }
    else
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
    }

    remove(self);
};

/*
================
laser_medium_touch
Handles collision of medium laser with world or entities
================
*/
void() laser_medium_touch =
{
    if (other == self.owner)
        return;

    if (other.solid == SOLID_TRIGGER)
        return;	// trigger field, do nothing

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    // hit something that bleeds
    if (other.takedamage)
    {
        spawn_touchblood(DAMAGE_LASER_MEDIUM);
        T_Damage(other, self, self.owner, DAMAGE_LASER_MEDIUM);
    }
    else
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
    }

    remove(self);
};

/*
================
laser_big_touch
Handles collision of big laser with world or entities
================
*/
void() laser_big_touch =
{
    local float r;
    
    if (other == self.owner)
        return;

    if (other.solid == SOLID_TRIGGER)
        return;	// trigger field, do nothing

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    
    // Calculate random damage bonus (5, 10, 15, 20, or 25)
    r = floor((random() * 5) + 1) * 5;
    
    // hit something that bleeds
    if (other.takedamage)
    {
        spawn_touchblood(DAMAGE_LASER_BIG + r);
        T_Damage(other, self, self.owner, DAMAGE_LASER_BIG + r);
    }
    else
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
        
        // Add additional visual effect for big laser
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_SPIKE);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
    }

    remove(self);
};

/*
================
laser_think
Handles laser lifetime
================
*/
void() laser_think =
{
    // Remove laser after lifetime expires
    // This prevents lasers from flying forever
    remove(self);
};

/*
================
launch_laser
Creates a single laser entity with the given parameters

Parameters:
  org - Origin point for the laser
  dir - Direction vector for the laser
  laser_type - Type of laser (LASER_SMALL, LASER_MEDIUM, LASER_BIG)
  source_ent - Entity that fired the laser (for owner reference)
================
*/
entity(vector org, vector dir, float laser_type, entity source_ent) launch_laser =
{
    local entity laser;
    
    laser = spawn();
    
    // Set the owner reference
    laser.owner = source_ent;
    
    laser.movetype = MOVETYPE_FLYMISSILE;
    laser.solid = SOLID_BBOX;
    
    // Set appearance
    setmodel(laser, LASER_MODEL);
    setsize(laser, VEC_ORIGIN, VEC_ORIGIN); // Zero-sized collision box
    
    // Set position
    setorigin(laser, org);
    
    // Set properties based on laser type
    if (laser_type == LASER_SMALL)
    {
        laser.classname = "laser_small";
        laser.touch = laser_small_touch;
        laser.velocity = dir * LASER_SPEED_SMALL;
        laser.dmg = DAMAGE_LASER_SMALL;
    }
    else if (laser_type == LASER_MEDIUM)
    {
        laser.classname = "laser_medium";
        laser.touch = laser_medium_touch;
        laser.velocity = dir * LASER_SPEED_MEDIUM;
        laser.dmg = DAMAGE_LASER_MEDIUM;
    }
    else if (laser_type == LASER_BIG)
    {
        laser.classname = "laser_big";
        laser.touch = laser_big_touch;
        laser.velocity = dir * LASER_SPEED_BIG;
        laser.dmg = DAMAGE_LASER_BIG;
    }
    else
    {
        // Default to small laser if invalid type
        laser.classname = "laser_small";
        laser.touch = laser_small_touch;
        laser.velocity = dir * LASER_SPEED_SMALL;
        laser.dmg = DAMAGE_LASER_SMALL;
    }
    
    laser.angles = vectoangles(laser.velocity);
    
    // Set lifetime
    laser.nextthink = time + 6;  // 6 second lifetime
    laser.think = laser_think;
    
    return laser;
};

/*
================
W_am_fire_laser
Fire a laser with the specified parameters

Parameters:
  laser_type - Type of laser to fire (LASER_SMALL, LASER_MEDIUM, LASER_BIG)
  with_muzzleflash - Whether to create a muzzle flash effect (1 = yes, 0 = no)
  play_sound - Whether to play the firing sound (1 = yes, 0 = no)
================
*/
void(float laser_type, float with_muzzleflash, float play_sound) W_am_fire_laser =
{
    local vector dir;
    local vector muzzle_offset, muzzle_origin;
    local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up;
    local entity laser_ent;
    
    // Get player's aiming direction and eye position
    makevectors(self.v_angle);
    
    // Set up standard muzzle position - adjusted for proper weapon position
    muzzle_offset_forward = 10;  // Reduced forward offset to bring it closer to player
    muzzle_offset_right = 6;     // Slight right offset to position it where the weapon would be
    muzzle_offset_up = -7;       // Lowered to be at weapon height instead of head height
    
    // Calculate the muzzle's world origin
    muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
    muzzle_origin = self.origin + self.view_ofs + muzzle_offset;
    
    // Get aim direction
    dir = aim(self, 1000);
    
    // Play appropriate sound if requested
    if (play_sound)
    {
        if (laser_type == LASER_SMALL)
        {
            sound(self, CHAN_WEAPON, LASER_SOUND_SMALL, 1, ATTN_NORM);
        }
        else if (laser_type == LASER_MEDIUM)
        {
            sound(self, CHAN_WEAPON, LASER_SOUND_MEDIUM, 1, ATTN_NORM);
        }
        else if (laser_type == LASER_BIG)
        {
            sound(self, CHAN_WEAPON, LASER_SOUND_BIG, 1, ATTN_NORM);
            // Add supplementary sound for big laser
            sound(self, CHAN_ITEM, LASER_SOUND_BIG_SUPPLEMENT, 1, ATTN_NORM);
        }
    }
    
    // Launch the laser and get the entity reference
    laser_ent = launch_laser(muzzle_origin, dir, laser_type, self);
    
    // Create muzzle flash effect if requested
    if (with_muzzleflash)
    {
        // Add engine muzzle flash effect
        self.effects = self.effects | EF_MUZZLEFLASH;
        
        // Add a brief light flash at muzzle position
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, muzzle_origin_x);
        WriteCoord(MSG_BROADCAST, muzzle_origin_y);
        WriteCoord(MSG_BROADCAST, muzzle_origin_z);
    }
    
    // Apply appropriate recoil based on laser type
    if (laser_type == LASER_SMALL)
    {
        self.punchangle_x = -1;
    }
    else if (laser_type == LASER_MEDIUM)
    {
        self.punchangle_x = -1.5;
    }
    else if (laser_type == LASER_BIG)
    {
        self.punchangle_x = -2;
    }
};

/*
================
W_am_fire_laser_from_entity
Fire a laser from any entity with the specified parameters
Useful for monster attacks

Parameters:
  ent - Entity that's firing the laser
  org - Origin point for the laser
  dir - Direction vector for the laser
  laser_type - Type of laser to fire (LASER_SMALL, LASER_MEDIUM, LASER_BIG)
  with_effects - Whether to create visual/sound effects (1 = yes, 0 = no)
================
*/
void(entity ent, vector org, vector dir, float laser_type, float with_effects) W_am_fire_laser_from_entity =
{
    local entity laser_ent;
    
    // Play appropriate sound if requested
    if (with_effects)
    {
        if (laser_type == LASER_SMALL)
        {
            sound(ent, CHAN_WEAPON, LASER_SOUND_SMALL, 1, ATTN_NORM);
        }
        else if (laser_type == LASER_MEDIUM)
        {
            sound(ent, CHAN_WEAPON, LASER_SOUND_MEDIUM, 1, ATTN_NORM);
        }
        else if (laser_type == LASER_BIG)
        {
            sound(ent, CHAN_WEAPON, LASER_SOUND_BIG, 1, ATTN_NORM);
            
            // Add supplementary sound for big laser
            if (laser_type == LASER_BIG)
            {
                sound(ent, CHAN_ITEM, LASER_SOUND_BIG_SUPPLEMENT, 1, ATTN_NORM);
            }
        }
    }
    
    // Launch the laser
    laser_ent = launch_laser(org, dir, laser_type, ent);
};