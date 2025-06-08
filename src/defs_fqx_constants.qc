//=============================================================================
// defs_fqx_constants.qc - FQX Mod - Custom Constants & Globals
// Location: /src/
// ##FQX - ##Quedra: Version 1.1.0
// ##Quedra: Consolidates all custom FQX global constants, definitions, and
// ##Quedra: global variables. This file MUST be loaded after 'defs_fqx_fields.qc'.
// ##Quedra: v1.1.0 - Added missing IT_SLOT_* constants, which were erroneously
// ##Quedra:          discarded during the purge of the old defs_3.qc.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: FQX ITEM SLOT DEFINITIONS (from original defs_3.qc)
//-----------------------------------------------------------------------------
float   IT_SLOT_MELEE           = 4096;
float   IT_SLOT_HOLDOUT         = 1;
float   IT_SLOT_SECONDARY       = 2;
float   IT_SLOT_PRIMARY         = 4;
float   IT_SLOT_HEAVY           = 8;
float   IT_SLOT_UTILITY         = 16;
float   IT_SLOT_AUX1            = 32;
float   IT_SLOT_AUX2            = 64;
float   IT_SLOT_AUX3            = 128;

//-----------------------------------------------------------------------------
// ##Quedra: AMMUNITION & WEAPON ID CONSTANTS (from defs_2.qc)
//-----------------------------------------------------------------------------

// --- AMMUNITION TYPE ID CONSTANTS ---
float AMMO_ID_SHELLS = 1;
float AMMO_ID_NAILS = 2;
float AMMO_ID_ROCKETS = 3;
float AMMO_ID_CELLS = 4;

// --- Shell Type ID Constants (for am_buckshot.qc) ---
float SHELL_TYPE_12G_000BUCK  = 1;
float SHELL_TYPE_12G_00BUCK   = 2;
float SHELL_TYPE_12G_0BUCK    = 3;
float SHELL_TYPE_12G_NO4BUCK  = 4;
float SHELL_TYPE_12G_NO1BUCK  = 5;

// --- Weapon ID Constants ---
float WEAPON_ID_NONE = 0;
float WEAPON_ID_AXE = 1;
float WEAPON_ID_RAHPM1 = 2;
float WEAPON_ID_IZH43 = 3;
float WEAPON_ID_UMP45 = 4;
float WEAPON_ID_AK47 = 5;
float WEAPON_ID_GRAPPLE = 6;
float WEAPON_ID_RL = 7;
float WEAPON_ID_LG = 8;
float WEAPON_ID_M93R = 9;
float WEAPON_ID_SAWNOFF = 10;

// --- Centralized Weapon Data Constants ---
float SAWNOFF_DATA_SHELL_TYPE_PRIMARY = SHELL_TYPE_12G_000BUCK;
float IZH43_DATA_SHELL_TYPE_PRIMARY   = SHELL_TYPE_12G_000BUCK;

//-----------------------------------------------------------------------------
// ##Quedra: PERSISTENCE & FIRE MODE CONSTANTS (from defs_2.qc)
//-----------------------------------------------------------------------------

// --- Loadout Persistence Constants ---
float LOADOUT_PV_P1_SLOT0 = 1;
float LOADOUT_PV_P1_SLOT1 = 32;
float LOADOUT_PV_P1_SLOT2 = 1024;
float LOADOUT_PV_P1_SLOT3 = 32768;
float LOADOUT_PV_P1_SLOT4 = 1048576;
float LOADOUT_PV_P1_SLOT5 = 33554432;
float LOADOUT_PV_P2_SLOT0 = 1;
float LOADOUT_PV_P2_SLOT1 = 32;
float LOADOUT_PV_P2_SLOT2 = 1024;
float LOADOUT_WEAPONID_BITS = 5;
float LOADOUT_WEAPONID_MASK = 31;

// --- Fire Mode Persistence Bitmasking Constants ---
float FIREMODE_PERSIST_MASK = 3;
float FIREMODE_PLACE_VALUE_SLOT_MELEE     = 1;
float FIREMODE_PLACE_VALUE_SLOT_HOLDOUT   = 4;
float FIREMODE_PLACE_VALUE_SLOT_SECONDARY = 16;
float FIREMODE_PLACE_VALUE_SLOT_PRIMARY   = 64;
float FIREMODE_PLACE_VALUE_SLOT_HEAVY     = 256;
float FIREMODE_PLACE_VALUE_SLOT_UTILITY   = 1024;
float FIREMODE_PLACE_VALUE_SLOT_AUX1      = 4096;
float FIREMODE_PLACE_VALUE_SLOT_AUX2      = 16384;
float FIREMODE_PLACE_VALUE_SLOT_AUX3      = 65536;

// --- Generic Fire Mode Constants ---
#define FIRE_MODE_PRIMARY   0
#define FIRE_MODE_SECONDARY 1
#define FIRE_MODE_TERTIARY  2

//-----------------------------------------------------------------------------
// ##Quedra: GENERIC GAMEPLAY SYSTEM CONSTANTS (from defs_2.qc)
//-----------------------------------------------------------------------------

// --- Reload Type Constants ---
float RELOAD_TYPE_NONE                 = 0;
float RELOAD_TYPE_MAGAZINE_REPLACE     = 1;
float RELOAD_TYPE_SINGLE_ROUND_LOAD    = 2;
float RELOAD_TYPE_FIXED_MAG_CLIP_LOAD  = 3;
float RELOAD_TYPE_REVOLVER_CHAMBER     = 4;
float RELOAD_TYPE_REVOLVER_SPEEDLOADER = 5;

// --- Weapon Weight Class Constants ---
float WEIGHT_CLASS_LIGHT        = 1;
float WEIGHT_CLASS_MEDIUM       = 2;
float WEIGHT_CLASS_HEAVY        = 3;
float WEIGHT_CLASS_VERY_HEAVY   = 4;

// --- Grapple System Constants ---
float GRAPPLE_NONE = 0;
float GRAPPLE_FLYING = 1;
float GRAPPLE_ATTACHED = 2;
float GRAPPLE_CYCLE_SPEED = 15;
float GRAPPLE_CONTINUOUS_SPEED = 5;
float GRAPPLE_ACTION_NONE = 0;
float GRAPPLE_ACTION_EXTEND = 1;
float GRAPPLE_ACTION_RETRACT = 2;

// --- Printing Constants ---
float PRINT_LOW    = 0;
float PRINT_MEDIUM = 1;
float PRINT_HIGH   = 2;
float PRINT_CHAT   = 3;

// --- Generic Reload System Constants ---
float GAME_AMMO_COST_PER_SHOTGUN_ROUND = 2;
string SOUND_RELOAD_START_DEFAULT = "weapons/weaponclick.wav";
string SOUND_RELOAD_FINISH_DEFAULT = "weapons/ak47_switch.wav";
float RELOAD_ANIM_FRAME_DEFAULT = 3;

// --- Deathmatch Spawn Logic Constants ---
float IDEAL_DIST_FROM_DM_SPAWN_POINT = 384;
float MIN_DIST_FROM_DM_SPAWN_POINT = 84;

//-----------------------------------------------------------------------------
// ##Quedra: MONSTER CORE (MC) AI STATE CONSTANTS (from mc_defs.qc)
//-----------------------------------------------------------------------------
#define MC_AI_STATE_SPAWN       0
#define MC_AI_STATE_IDLE        1
#define MC_AI_STATE_PURSUE      2
#define MC_AI_STATE_COMBAT      3
#define MC_AI_STATE_PAIN        4
#define MC_AI_STATE_DEAD        5
#define MC_AI_STATE_CUSTOM      6

//-----------------------------------------------------------------------------
// ##Quedra: GLOBAL VARIABLES
// ##Quedra: Note: These are not constants, but are defined at the global scope.
//-----------------------------------------------------------------------------

// --- Standard Quake Global Variables (from defs_2.qc) ---
entity lastspawn;
float startingserverflags;

// --- Global Model Indices (from defs_2.qc) ---
float modelindex_player;

// --- FQX Debug Toggles (from defs_2.qc & mc_defs.qc) ---
float mc_debug_prints_enabled;
float gruntdprintcheck;

//=============================================================================
// defs_fqx_constants.qc - FQX Mod - Custom Constants & Globals - END
// ##FQX - ##Quedra: Version 1.1.0
//=============================================================================