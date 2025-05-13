/*
==============================================================================
AM_BUCKSHOT - Buckshot Ammunition System
This file implements a physical projectile-based shotgun pellet system.
Pellets use actual entities with collision detection rather than trace attacks.
Features:
- Customizable pellet count per shot
- Adjustable spread patterns
- Multiple ammo types with different damage values
- Support for firing multiple instances (e.g., double barrel)
- Muzzle flash at fire origin
==============================================================================
*/

// Pellet entity for physical projectiles
void() buckshot_pellet_touch;
void() buckshot_pellet_think;

// --- Ammo Type Properties Definitions ---
// (AMMO_12G000BUCK_DAMAGE, SPREAD_12G000BUCK, PELLETS_12G000BUCK, etc. remain the same)
float AMMO_12G000BUCK_DAMAGE = 8;
float AMMO_12G00BUCK_DAMAGE = 7;
float AMMO_12G0BUCK_DAMAGE = 6;
float AMMO_12G1BUCK_DAMAGE = 5;
float AMMO_12G4BUCK_DAMAGE = 4;
float AMMO_12GBIRD_DAMAGE = 2;

float SPREAD_12G000BUCK = 5;
float SPREAD_12G00BUCK = 7;
float SPREAD_12G0BUCK = 8;
float SPREAD_12G1BUCK = 10;
float SPREAD_12G4BUCK = 12;
float SPREAD_12GBIRD = 15;

float PELLETS_12G000BUCK = 8;
float PELLETS_12G00BUCK = 9;
float PELLETS_12G0BUCK = 10;
float PELLETS_12G1BUCK = 12;
float PELLETS_12G4BUCK = 16;
float PELLETS_12GBIRD = 24;

// Velocity settings
float BUCKSHOT_SPEED = 2000;

// --- Ammo Type Constants for Weapons ---
// (AMT_12G000BUCK, etc. remain the same)
float AMT_12G000BUCK = 1;
float AMT_12G00BUCK = 2;
float AMT_12G0BUCK = 3;
float AMT_12G1BUCK = 4;
float AMT_12G4BUCK = 5;
float AMT_12GBIRD = 6;


/*
================
buckshot_pellet_touch
================
*/
void() buckshot_pellet_touch = {
    local float damage;
    if (pointcontents(self.origin) == CONTENT_SKY) {
        remove(self);
        return;
    }
    damage = self.dmg;
    particle(self.origin, '0 0 0', 225, damage * 2);
    if (other.takedamage) {
        T_Damage(other, self, self.owner, damage);
        SpawnBlood(self.origin, self.velocity * 0.2, damage * 2);
    } else {
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
buckshot_pellet_think
================
*/
void() buckshot_pellet_think = {
    remove(self);
};

/*
================
launch_buckshot_pellet
================
*/
void(vector launch_org, vector dir, float dmg_amount, entity shooter) launch_buckshot_pellet = {
    local entity pellet;
    pellet = spawn();
    pellet.owner = shooter;
    pellet.movetype = MOVETYPE_FLYMISSILE;
    pellet.solid = SOLID_BBOX;
    setmodel(pellet, "progs/bit.mdl"); // Consider a more visible pellet model if needed
    setsize(pellet, '0 0 0', '0 0 0');
    setorigin(pellet, launch_org); // Use the passed launch_org
    pellet.velocity = dir * BUCKSHOT_SPEED;
    pellet.angles = vectoangles(pellet.velocity);
    pellet.dmg = dmg_amount;
    pellet.touch = buckshot_pellet_touch;
    pellet.nextthink = time + 2; // 2 second lifetime
    pellet.think = buckshot_pellet_think;
};

/*
================
get_ammo_properties
Gets damage, spread and pellet count for given ammo type.
This function NO LONGER handles muzzle flash.
================
*/
void(float ammo_type, float &damage_ref, float &spread_ref, float &pellet_count_ref) get_ammo_properties = {
    // Set default values
    damage_ref = 5;
    spread_ref = 10;
    pellet_count_ref = 12;

    if (ammo_type == AMT_12G000BUCK) {
        damage_ref = AMMO_12G000BUCK_DAMAGE;
        spread_ref = SPREAD_12G000BUCK;
        pellet_count_ref = PELLETS_12G000BUCK;
    } else if (ammo_type == AMT_12G00BUCK) {
        damage_ref = AMMO_12G00BUCK_DAMAGE;
        spread_ref = SPREAD_12G00BUCK;
        pellet_count_ref = PELLETS_12G00BUCK;
    } else if (ammo_type == AMT_12G0BUCK) {
        damage_ref = AMMO_12G0BUCK_DAMAGE;
        spread_ref = SPREAD_12G0BUCK;
        pellet_count_ref = PELLETS_12G0BUCK;
    } else if (ammo_type == AMT_12G1BUCK) {
        damage_ref = AMMO_12G1BUCK_DAMAGE;
        spread_ref = SPREAD_12G1BUCK;
        pellet_count_ref = PELLETS_12G1BUCK;
    } else if (ammo_type == AMT_12G4BUCK) {
        damage_ref = AMMO_12G4BUCK_DAMAGE;
        spread_ref = SPREAD_12G4BUCK;
        pellet_count_ref = PELLETS_12G4BUCK;
    } else if (ammo_type == AMT_12GBIRD) {
        damage_ref = AMMO_12GBIRD_DAMAGE;
        spread_ref = SPREAD_12GBIRD;
        pellet_count_ref = PELLETS_12GBIRD;
    }
    // Muzzle flash code has been MOVED OUT of this function.
};

/*
================
W_am_buckshot
Fires one or more instances of buckshot with the given parameters.

Parameters:
  passed_fire_origin - The actual muzzle position for effects and pellet launch
  instances          - Number of shotgun blasts to fire (e.g., 2 for double barrel)
  ammo_type          - Type of buckshot ammunition to use
  ammo_spread_mod    - Spread tuning modifier from weapon (e.g., barrel length)
================
*/
void(vector passed_fire_origin, float instances, float ammo_type, float ammo_spread_mod) W_am_buckshot = {
    local vector dir;
    // local vector src; // No longer using eye position as primary src for pellets
    local float base_damage, base_spread, base_pellet_count;
    local float i, j;
    local float current_spread_val;
    local float spread_x_offset, spread_y_offset;

    // Get base properties for this ammo type
    get_ammo_properties(ammo_type, base_damage, base_spread, base_pellet_count);

    // --- Create Muzzle Flash AT THE MUZZLE ---
    // This is done ONCE per call to W_am_buckshot, regardless of instances,
    // assuming one muzzle flash for the weapon firing action.
    // If double-barrel needs two distinct flashes, this needs more complex handling
    // or the weapon file calls W_am_buckshot twice for each barrel.
    // For now, one flash per W_am_buckshot call.
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT); // Or TE_SMALLFLASH for shotguns
    WriteCoord(MSG_BROADCAST, passed_fire_origin_x);
    WriteCoord(MSG_BROADCAST, passed_fire_origin_y);
    WriteCoord(MSG_BROADCAST, passed_fire_origin_z);

    // Convert base_spread from degrees to a QuakeC spread factor
    // (0.01745 is approx pi/180 for deg to rad)
    current_spread_val = (base_spread * 0.01745) * 0.1; // Original spread factor calculation
                                                       // ammo_spread_mod can further adjust this.
                                                       // A mod of 1.0 means no change.
    current_spread_val = current_spread_val * ammo_spread_mod;


    makevectors(self.v_angle); // To get v_forward, v_right, v_up for spread calculation

    // Fire multiple instances if requested (e.g., both barrels of a double-barrel shotgun)
    for (i = 0; i < instances; i++) {
        // Fire all pellets for this instance
        for (j = 0; j < base_pellet_count; j++) {
            // Calculate random spread direction based on player's aim
            spread_x_offset = (random() - 0.5) * current_spread_val; // Adjusted your original spread application
            spread_y_offset = (random() - 0.5) * current_spread_val; // to use the single current_spread_val

            dir = v_forward;
            // Your original spread logic: dir = dir + (v_right * spread_x * (ammo_spread*10)) + (v_up * spread_y * (ammo_spread*10));
            // Let's simplify/clarify: current_spread_val already incorporates the base_spread and a modifier.
            // The *10 might have been to counteract the earlier *0.1, or to make spread_x/y more like vector components.
            // If current_spread_val is now the desired "max offset component", then:
            dir = dir + (v_right * spread_x_offset) + (v_up * spread_y_offset);
            dir = normalize(dir);

            // Launch the pellet FROM THE MUZZLE
            launch_buckshot_pellet(passed_fire_origin, dir, base_damage, self);
        }
    }
};