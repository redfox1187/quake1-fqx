// ##Quedra: Client-Side QuakeC Definitions for FQX (Ironwail Target) ##
// This file sets up the CSQC environment by including fteextensions.qc.
// Custom CSQC-specific global constants and variables for FQX can be defined *after* the include.

#pragma TARGET FTE // Specifies that we are compiling for an FTEQW-family engine (like Ironwail).

// CRITICAL: Define CSQC *before* including fteextensions.qc.
// This tells fteextensions.qc to expose all CSQC-specific built-in functions,
// global variables (like key codes K_*, view flags VF_*, etc.), and core entry points.
#define CSQC

// Include the standard FTE engine extensions. This file contains the vast majority
// of built-in declarations you will need for CSQC.
// Ensure fteextensions.qc is present in the same directory as this file, or adjust path.
#include "fteextensions.qc"

// --- FQX Custom CSQC Definitions ---
// Add any global constants or variables specific to your CSQC mod *here*,
// after fteextensions.qc has been processed.

// Example: Drawing flags if not covered or if you prefer explicit naming.
// fteextensions.qc does not define DRAWFLAG_NORMAL, so this is a useful custom constant.
const float DRAWFLAG_NORMAL = 0;            // Standard drawing behavior
const float DRAWFLAG_ADDITIVE = 1;          // For additive blending (if supported directly by a drawflag number)
const float DRAWFLAG_ALIGN_LEFT = 0;        // Usually default
const float DRAWFLAG_ALIGN_CENTER = 8;      // Common value for horizontal centering, verify for Ironwail if using generic drawflags
const float DRAWFLAG_ALIGN_RIGHT = 16;     // Common value for horizontal right alignment

// Note on STAT_* constants:
// Standard stats like STAT_HEALTH, STAT_ITEMS, STAT_ACTIVEWEAPON, STAT_AMMO,
// and STAT_USER (for custom stats starting at index 32) are already defined
// in fteextensions.qc when CSQC is defined. You do not need to redefine them.
// Your custom stats for the loadout system (e.g., STAT_LOADOUT_SLOT1_WID)
// should use indices greater than or equal to STAT_USER.
// For example:
// const float STAT_LOADOUT_MELEE_WID = STAT_USER + 0;
// const float STAT_LOADOUT_HOLDOUT_WID = STAT_USER + 1;
// ... and so on for your loadout slots.

// Any other CSQC-specific global variables your UI might need:
// float example_csqc_global_variable;
// string example_csqc_string_global;

// End of csqc_defs.qc