// ======================================================================= //
//  ##File: /defs/def_forwards.qc
//  ##Project Version: FQX Phoenix v0.5
//  ##File Description: Contains all function forward declarations for the FQX Project.
//  ##File Version: 1.0.0 (20250614.191750CDT)
//
//   v1.0.0 - Initial creation from defs.qc PART 5: FORWARD DECLARATIONS. - ##FIREFQX
//
// =======================================================================

#ifndef DEF_FORWARDS_QC_H_
#define DEF_FORWARDS_QC_H_

//-------------------------------------------------------------------------
// PART 5: FORWARD DECLARATIONS
//-------------------------------------------------------------------------

// --- QRRQC Forward Declarations ---
void(vector ang) makevectorsfixed;
void() SUB_Null;
void() SUB_UseTargets;
void(vector dest, float speed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void() SUB_CalcMoveDone;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt;
void() SUB_CalcAngleMoveDone;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity e, float healamount, float ignore) T_Heal;
float(entity targ, entity inflictor) CanDamage;

// --- FQX Project Forward Declarations ---
void() walkmonster_start;
void() flymonster_start;
void() swimmonster_start;
void() monster_use;
void() monster_death_use;
void() BecomeExplosion;
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
float() SoldierCheckAttack;
float() OgreCheckAttack;
float() ShamCheckAttack;
float() DemonCheckAttack;
float() CheckAttack;
void() knight_attack;
float() DogCheckAttack;
float() WizardCheckAttack;
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
void() InitTrigger;
string(float item_flag) GetNetName;
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
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;
void() IntermissionThink;
void() CheckRules;
entity() FindIntermission;
void() InitBodyQueue;
void(entity ent) CopyToBodyQueue;
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
void(vector org) spawn_shot_spark;
void() DecodeLevelParms;
entity(float forceSpawn) SelectSpawnPoint;
void() W_Attack;
void() W_ChangeWeapon;
void() W_SetCurrentAmmo;
void() W_WeaponFrame;
float() W_BestWeapon;
void() W_Precache;
void() W_FireAxe;
void() W_FireShotgun;
void() W_FireSuperShotgun;
void(float side) W_FireSpikes;
void() W_FireLightning;
void() W_FireGrenade;
void() W_FireRocket;
void(float num, float spread) FireBuckshot;
void(vector dir) FireNail;
void() FireGrenadeProjectile;
void() FireRocketProjectile;
void() FireLightningBeam;
void() MeleeAttack;
void(vector org, entity attacker, float damage, float radius, entity ignore, float te_effect) FQX_Explosion;
void() FQX_UnlimitedAmmoToggle;
void() FQX_QuadDamageToggle;

#endif // DEF_FORWARDS_QC_H_

// ======================================================================= //
// Project: FQX Phoenix v0.5
// File: /defs/def_forwards.qc - File Version: 1.0.0
// Last Coder: ##FIREFQX
// =======================================================================