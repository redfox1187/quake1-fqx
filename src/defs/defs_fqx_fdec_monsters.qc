// =======================================================================
//
//  ##File: defs_fqx_fdec_monsters.qc
//  ##File Description: FQX Definitions - Monster System Forward Declarations
//  ##FQX - ##FQXnote.: Version 0.7.0 (20250611.040115CDT)
//
//  ##FQXnote.
//    v0.7.0 - Added DogCheckAttack and WizardCheckAttack declarations to
//             resolve 'Unknown value' errors from bgs_ai.qc.
//    v0.6.0 - Added forward declaration for 'knight_attack'.
//    v0.5.0 - Standardized the 'ai_charge' signature to void(entity, float).
//
// =======================================================================

//--[ GENERIC MONSTER INITIALIZATION ]-------------------------------------
void() walkmonster_start;
void() flymonster_start;
void() swimmonster_start;
void() monster_use;
void() monster_death_use;
void() BecomeExplosion;

//--[ CORE AI STATE FUNCTIONS ]--------------------------------------------
void() ai_stand;
void(float dist) ai_walk;
void(float dist) ai_run;
void() ai_run_melee;
void() ai_run_missile;
void() ai_run_slide;
void() ai_melee_side;
void(float dist) ai_pain;
void(entity monster, float dist) ai_charge;
void() ai_charge_side;
float() ai_checkattack;
float() CheckAnyAttack;
void() ai_face;

//--[ AI UTILITY & CHECK FUNCTIONS ]---------------------------------------
void(float dist) ai_painforward;
void(float dist) ai_forward;
void(float dist) ai_back;
void() ai_turn;

//--[ MONSTER-SPECIFIC ATTACK CHECKS ]-------------------------------------
float() SoldierCheckAttack;
float() OgreCheckAttack;
float() ShamCheckAttack;
float() DemonCheckAttack;
float() CheckAttack;
void() knight_attack;
float() DogCheckAttack;     // ##FQXnote.: Added to resolve dependency from bgs_ai.qc.
float() WizardCheckAttack;  // ##FQXnote.: Added to resolve dependency from bgs_ai.qc.

//--[ VANILLA MONSTER SPAWN FUNCTIONS ]------------------------------------
void() monster_army;
void() monster_ogre;
void() monster_knight;
void() monster_hell_knight;
void() monster_demon1;
void() monster_shambler;
void() monster_wizard;
void() monster_dog;
void() monster_zombie;
void() monster_fish;
void() monster_shalrath;
void() monster_enforcer;
void() monster_tarbaby;
void() monster_boss;
void() monster_chton;
void() monster_shubniggurath;

// =======================================================================
// ##FQX - ##FQXnote.: Version 0.7.0
// ##File: defs_fqx_fdec_monsters.qc
// =======================================================================