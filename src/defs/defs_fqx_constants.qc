// =======================================================================
//
//  ##File: defs_fqx_constants.qc
//  ##File Description: FQX Definitions - System Constants
//
//  ##FQX - This file is an original FQX module.
//    It defines all global constants for FQX systems, including weapons,
//    fire modes, ammunition types, and other gameplay values.
//
// =======================================================================
// ##FQX - ##Quedra: Version 0.1.0

//--[ BOOLEAN / SYSTEM CONSTANTS ]-----------------------------------------
#define TRUE                                1
#define FALSE                               0

#define FQX_PERSISTENCE_SAVE_V1             20250609 // FQX persistence save version identifier

//--[ FQX WEAPON ID CONSTANTS ]--------------------------------------------
// ##Quedra: These constants provide a unique identifier for each weapon
// ##Quedra: in the Advanced Munitions System.

// -- VANILLA WEAPONS --
#define FQX_WEAPON_NULL                     0
#define FQX_WEAPON_AXE                      1
#define FQX_WEAPON_SHOTGUN                  2
#define FQX_WEAPON_SUPERSHOTGUN             3
#define FQX_WEAPON_NAILGUN                  4
#define FQX_WEAPON_SUPERNAILGUN             5
#define FQX_WEAPON_GRENADELAUNCHER          6
#define FQX_WEAPON_ROCKETLAUNCHER           7
#define FQX_WEAPON_THUNDERBOLT              8

// -- FQX CUSTOM WEAPONS (PLACEHOLDERS) --
// ##Quedra: Stubs for future expansion.
#define FQX_WEAPON_REPEATER                 9
#define FQX_WEAPON_AK47                     10


//--[ FQX AMMO ID CONSTANTS ]----------------------------------------------
// ##Quedra: Centralized IDs for ammunition types.

#define FQX_AMMO_NULL                       0
#define FQX_AMMO_SHELLS                     1
#define FQX_AMMO_NAILS                      2
#define FQX_AMMO_ROCKETS                    3
#define FQX_AMMO_CELLS                      4


//--[ FQX FIREMODE CONSTANTS ]---------------------------------------------
// ##Quedra: Defines the available fire modes for weapons.

#define FQX_FIREMODE_NULL                   0
#define FQX_FIREMODE_PRIMARY                1   // Default fire mode
#define FQX_FIREMODE_SECONDARY              2   // Often for alt-fire
#define FQX_FIREMODE_SINGLE                 3
#define FQX_FIREMODE_BURST                  4
#define FQX_FIREMODE_AUTO                   5


//--[ FQX LOADOUT PERSISTENCE CONSTANTS ]----------------------------------
// ##Quedra: Constants for managing the LOADOUT system's persistence
// ##Quedra: across level changes. 

#define FQX_LOADOUT_SLOT_1                  0
#define FQX_LOADOUT_SLOT_2                  1
#define FQX_LOADOUT_SLOT_3                  2
#define FQX_LOADOUT_SLOT_4                  3
#define FQX_LOADOUT_SLOT_5                  4
#define FQX_LOADOUT_SLOT_6                  5
#define FQX_LOADOUT_SLOT_7                  6
#define FQX_LOADOUT_SLOT_8                  7
#define FQX_LOADOUT_SLOT_9                  8

// =======================================================================
// ##FQX - ##Quedra: Version 0.1.0
// =======================================================================