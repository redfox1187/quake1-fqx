// =======================================================================
//
//  ##File: defs_fqx_fields.qc
//  ##File Description: FQX Definitions - Entity Fields
//  ##FQX - ##FQXnote.: Version 0.3.0 (20250611.062145CDT)
//
//  ##FQXnote.
//    v0.3.0 - Added '.dmgtime' field required by player water physics logic.
//    v0.2.0 - Added '.inpain' field for Zombie logic.
//
// =======================================================================

//--[ FQX CORE SYSTEM FIELDS ]---------------------------------------------
.float  fqx_version;            // For tracking versioning on entities if needed.
.float  fqx_spawn_flags;        // Generic spawnflags for FQX entities.


//--[ FQX PLAYER FIELDS ]--------------------------------------------------
// ##Quedra: Fields extending the player entity's capabilities and state.
.float  spawn_deferred;         // From client.qc: used for deferred deathmatch spawning.
.float  healthrot_nextcheck;    // From client.qc: timer for megahealth rot.
.float  fired_weapon;           // From client.qc: achievement tracking.
.float  took_damage;            // From client.qc: achievement tracking.
.float  dmgtime;                // ##FQXnote.: ADDED - From client.qc: timer for water/slime/lava damage.
.float  loadout_weapon_s1;      // Holds weapon ID for loadout slot 1.
.float  loadout_weapon_s2;      // Holds weapon ID for loadout slot 2.
.float  loadout_weapon_s3;      // Holds weapon ID for loadout slot 3.
.float  loadout_weapon_s4;      // Holds weapon ID for loadout slot 4.
.float  loadout_weapon_s5;      // Holds weapon ID for loadout slot 5.
.float  loadout_weapon_s6;      // Holds weapon ID for loadout slot 6.
.float  loadout_weapon_s7;      // Holds weapon ID for loadout slot 7.
.float  loadout_weapon_s8;      // Holds weapon ID for loadout slot 8.
.float  loadout_weapon_s9;      // Holds weapon ID for loadout slot 9.
.float  loadout_firemode_s1;    // Holds firemode for loadout slot 1.
.float  loadout_firemode_s2;    // Holds firemode for loadout slot 2.
.float  loadout_firemode_s3;    // Holds firemode for loadout slot 3.
.float  loadout_firemode_s4;    // Holds firemode for loadout slot 4.
.float  loadout_firemode_s5;    // Holds firemode for loadout slot 5.
.float  loadout_firemode_s6;    // Holds firemode for loadout slot 6.
.float  loadout_firemode_s7;    // Holds firemode for loadout slot 7.
.float  loadout_firemode_s8;    // Holds firemode for loadout slot 8.
.float  loadout_firemode_s9;    // Holds firemode for loadout slot 9.


//--[ FQX WEAPON DATA FIELDS (AM System) ]---------------------------------
// ##Quedra: Universal fields for all weapons, used by the Advanced Munitions system.
.float  fqx_weapon_id;          // Unique FQX identifier for the weapon.
.float  fqx_firemode;           // Current firemode of the weapon.
.float  fqx_ammo_id;            // FQX ammo type this weapon uses.
.float  fqx_ammo_per_shot;      // Ammo consumed per shot.
.float  fqx_mag_capacity;       // Magazine capacity.
.float  fqx_mag_current;        // Current ammo in the magazine.
.float  fqx_refire_rate;        // Time between shots for automatic fire.
.float  fqx_recoil_strength;    // Base recoil magnitude.
.float  fqx_recoil_time;        // Time it takes for recoil to apply.
.vector fqx_recoil_pattern;     // Recoil direction/pattern.

//--[ FQX MONSTER CORE FIELDS (MC System) ]--------------------------------
// ##Quedra: Foundational fields for the future Monster Core AI system.
.string pain_sound;             // ##Quedra: ADDED - Sound to play on pain.
.string death_sound;            // ##Quedra: ADDED - Sound to play on death.
.float  inpain;                 // Used by Zombie to track special pain states.
.float  mc_state;               // Current AI state of the monster.
.float  mc_state_time;          // Time to change state.
.void() mc_think_state;         // Think function pointer for the current state.
.void() mc_pain_state;          // Pain function pointer.
.void() mc_die_state;           // Die function pointer.
.float  mc_memory;              // Generic float for monster memory/flags.
.entity mc_target_memory;       // To remember last known enemy position.


// =======================================================================
// ##FQX - ##FQXnote.: Version 0.3.0 (20250611.062145CDT)
// ##File: defs_fqx_fields.qc
// =======================================================================