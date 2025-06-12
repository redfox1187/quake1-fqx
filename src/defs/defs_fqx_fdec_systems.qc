// =======================================================================
//
//  ##File: defs_fqx_fdec_systems.qc
//  ##File Description: FQX Definitions - General System Forward Declarations
//  ##FQX - ##FQXnote.: Version 0.6.0 (20250611.063120CDT)
//
//  ##FQXnote.
//    v0.6.0 - Added forward declaration for FindIntermission().
//    v0.5.0 - Added forward declaration for respawn().
//    v0.4.0 - Corrected declaration for 'movetogoal'.
//
// =======================================================================

//--[ GENERAL SUBROUTINES & UTILITIES ]------------------------------------
void() SUB_Null;
void() SUB_UseTargets;
void(vector dest, float speed, void() func) SUB_CalcMove;
void() SUB_CalcMoveDone;
void() InitTrigger;
string(float item_flag) GetNetName;
float(float yaw, float dist) walkmove;
void(float dist) movetogoal = #67;

//--[ CORE PLAYER STATE FUNCTIONS ]----------------------------------------
void(entity attacker, float damage) player_pain;
void() PlayerDie;
void() set_suicide_frame;
void() PlayerJump;
void() WaterMove;
void() CheckWaterJump;
void() PlayerDeathThink;
void() CheckPowerups;
void() CheckHealthRot;
void(float num_bubbles) DeathBubbles;
void() DropBackpack;
void() respawn;

//--[ PLAYER ANIMATION FUNCTIONS ]-----------------------------------------
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_rocket1;
void() player_light1;

//--[ PCL MODULE CROSS-DEPENDENCY FUNCTIONS ]-----------------------------
void() IntermissionThink;
void() CheckRules;
entity() FindIntermission; // ##FQXnote.: Added to resolve dependency from pcl_main.qc

//--[ SPAWN & BODY QUEUE ]-------------------------------------------------
void() InitBodyQueue;
void(entity ent) CopyToBodyQueue;
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
void(vector org) spawn_shot_spark;
void() DecodeLevelParms;
entity(float forceSpawn) SelectSpawnPoint;

// =======================================================================
// ##FQX - ##FQXnote.: Version 0.6.0 (20250611.063120CDT)
// ##File: defs_fqx_fdec_systems.qc
// =======================================================================