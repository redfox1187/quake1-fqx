// =======================================================================
//
//  ##File: defs_fqx_globals.qc
//  ##File Description: FQX Definitions - Custom Global Variables
//  ##FQX - ##FQXnote.: Version 1.1.0 (20250611.193127CDT)
//
//  ##FQXCUSTOM - This file is an original FQX module.
//
//  ##FQXnote.
//    v1.1.0 - Added 'lastspawn' entity declaration. This variable was moved
//             from bgs_world.qc to this central file to resolve an
//             'Unknown value' compilation error in pcl_main.qc.
//    v1.0.0 - Initial creation to house FQX-specific global variables,
//             respecting the immutability of defs_quake_core.qc.
//
// =======================================================================

// ##FQXnote.: These globals are required for logic segregated from their
// ##FQXnote.: original monolithic files (e.g., world.qc, client.qc).
// ##FQXnote.: Declaring them here makes them accessible to all modules.

float startingserverflags;
// Stores the serverflags at the start of a map.
float reset_flag;
// Used to signal a parameter reset for the client.
entity lastspawn;
// ##FQXnote.: Holds the last used spawn point for player spawning logic.

// =======================================================================
// ##FQX - ##FQXnote.: Version 1.1.0
// ##File: defs_fqx_globals.qc
// =======================================================================