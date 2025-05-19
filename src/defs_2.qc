//=============================================================================
// defs_2.qc - FQX Mod - Part 2 of Global Definitions
// ##Quedra: Player-specific fields, Weapon System constants & IDs,
// ##Quedra: and crucial Forward Declarations for all modules.
// ##Quedra: Version meticulously revised to address compiler errors.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: GLOBAL GAME CONSTANTS & SYSTEM IDs
//-----------------------------------------------------------------------------

// --- AMMUNITION TYPE ID CONSTANTS ---
float AMMO_ID_SHELLS = 1;
float AMMO_ID_NAILS = 2;
float AMMO_ID_ROCKETS = 3;
float AMMO_ID_CELLS = 4;
// ##Quedra: Add other global ammo type IDs (e.g., AMMO_ID_FUEL) here as needed.

// --- Weapon ID Constants ---
float WEAPON_ID_NONE = 0;       // Represents an empty or unassigned slot
float WEAPON_ID_AXE = 1;
float WEAPON_ID_RAHPM1 = 2;     // RAHP M1
float WEAPON_ID_DBSHOT = 3;     // Double Barrel Shotgun
float WEAPON_ID_UMP45 = 4;      // UMP45
float WEAPON_ID_AK47 = 5;       // AK47
float WEAPON_ID_GRAPPLE = 6;    // Grappling Hook
float WEAPON_ID_RL = 7;         // Vanilla Rocket Launcher
float WEAPON_ID_LG = 8;         // Vanilla Lightning Gun
float WEAPON_ID_M93R = 9;       // Beretta M93R
// ... IDs 10 through 31 are available ...

// --- Loadout Persistence Constants (for parm13, parm14 encoding) ---
float LOADOUT_PV_P1_SLOT0 = 1;        // 32^0, Melee
float LOADOUT_PV_P1_SLOT1 = 32;       // 32^1, Holdout
float LOADOUT_PV_P1_SLOT2 = 1024;     // 32^2, Secondary
float LOADOUT_PV_P1_SLOT3 = 32768;    // 32^3, Primary
float LOADOUT_PV_P1_SLOT4 = 1048576;  // 32^4, Heavy
float LOADOUT_PV_P1_SLOT5 = 33554432; // 32^5, Utility

float LOADOUT_PV_P2_SLOT0 = 1;        // 32^0, Aux1
float LOADOUT_PV_P2_SLOT1 = 32;       // 32^1, Aux2
float LOADOUT_PV_P2_SLOT2 = 1024;     // 32^2, Aux3

float LOADOUT_WEAPONID_BITS = 5;      
float LOADOUT_WEAPONID_MASK = 31;     

// --- Fire Mode Persistence Bitmasking Constants (for client.qc) ---
float FIREMODE_PERSIST_MASK = 3; // ##Quedra: Used in client.qc for packing/unpacking
float FIREMODE_PLACE_VALUE_SLOT_MELEE     = 1;    // 2^0
float FIREMODE_PLACE_VALUE_SLOT_HOLDOUT   = 4;    // 2^2
float FIREMODE_PLACE_VALUE_SLOT_SECONDARY = 16;   // 2^4
float FIREMODE_PLACE_VALUE_SLOT_PRIMARY   = 64;   // 2^6
float FIREMODE_PLACE_VALUE_SLOT_HEAVY     = 256;  // 2^8
float FIREMODE_PLACE_VALUE_SLOT_UTILITY   = 1024; // 2^10
float FIREMODE_PLACE_VALUE_SLOT_AUX1      = 4096; // 2^12
float FIREMODE_PLACE_VALUE_SLOT_AUX2      = 16384;// 2^14
float FIREMODE_PLACE_VALUE_SLOT_AUX3      = 65536;// 2^16

// --- Generic Fire Mode Constants ---
#define FIRE_MODE_PRIMARY   0  
#define FIRE_MODE_SECONDARY 1  
#define FIRE_MODE_TERTIARY  2  
// ##Quedra: Debug mode index is dynamically self.weapon_num_standard_modes, not a fixed define.

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

// --- Global Model Indices ---
float modelindex_player;        // ##Quedra: For player.mdl; set in worldspawn()
// ##Quedra: Add other global model indices here as needed (e.g., modelindex_bolt for a generic projectile)

// --- Standard Quake Global Variables (needed by client.qc, world.qc) ---
// ##Quedra: Added these to resolve client.qc errors.
// ##Quedra: These are standard globals.
entity lastspawn;             
float startingserverflags;    


//-----------------------------------------------------------------------------
// ##Quedra: GLOBAL PLAYER ENTITY FIELDS (.float, .string, .vector, .entity)
//-----------------------------------------------------------------------------
// -- FQX Custom --
.float loot_bonus;             
.float loot_fragcheck;         

// -- Loadout System --
.float loadout_id_melee;       
.float loadout_id_holdout;     
.float loadout_id_secondary;   
.float loadout_id_primary;     
.float loadout_id_heavy;       
.float loadout_id_utility;     
.float loadout_id_aux1;        
.float loadout_id_aux2;        
.float loadout_id_aux3;        

// -- General Weapon/Player State --
.float saved_weapon;  
.float quick_melee_active;  
.float quick_melee_debug;
.float quick_melee_sequence;
.float current_weapon_fire_mode;    
.float weapon_fire_released;        
.float weapon_num_standard_modes;   
// ##Quedra: .float weapon_supports_debug_mode; -- REMOVED

// -- Reload System Fields --
.float weapon_ammo_in_magazine; 
.float weapon_is_reloading;     
.float reload_next_think_time; 

// -- Generic Burst Fire System Fields --
.float burst_active;            
.float burst_shots_total;       
.float burst_shots_left;        
.float burst_rpm;               
.float burst_post_cooldown;     
.float burst_caliber;           
.float burst_bullet_type;       
.float burst_accuracy;          
.float burst_recoil_str;        
.float burst_recoil_spr;        
.float burst_recoil_vert_bias;  
.float burst_recoil_sust_mult;  
.float burst_recoil_max_sust;   
.string burst_sound_fire;       
.string burst_empty_sound;      
.float weapon_ammo_resource_id; 
.float weapon_ammo_cost_per_shot;

// -- Fire Mode Persistence Fields --
.float  firemode_slot_melee;
.float  firemode_slot_holdout;
.float  firemode_slot_secondary;
.float  firemode_slot_primary;
.float  firemode_slot_heavy;
.float  firemode_slot_utility;
.float  firemode_slot_aux1;
.float  firemode_slot_aux2;
.float  firemode_slot_aux3;

// -- Grapple System Fields --
.entity anchor;             
.float grapple_state;       
.float last_jump_time;      
.float anchor_length;       
.float grapple_action;      
.float grapple_time;

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - Standard Game & Utility Functions
//-----------------------------------------------------------------------------
// ##Quedra: From combat.qc / subs.qc / weapons.qc (ensure definitions exist in those files)
void(entity passed_body) CopyToBodyQueue; // ##Quedra: For respawn in client.qc
void(vector org, vector vel, float damage) SpawnBlood;      
void(float damage) spawn_touchblood;                        
float() W_BestWeapon;                                       // For am_nails.qc
void() W_SetCurrentAmmo;                                    // For am_nails.qc
void() player_run;                                          // For am_firemodes.qc
string(string title) GetMapName;
// ##Quedra: Declare 'FoundTarget' here if it's a global function or add its .float/.entity field above if it's a global var.
// ##Quedra: Example if it's a function: void() FoundTarget;

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - ADVANCED MUNITIONS (AM_*) MODULES
//-----------------------------------------------------------------------------

// --- From: am_operations.qc ---
void(string model_path, float ammo_id_to_read, float items_flag) AM_InitializeWeaponView;
void(float ammo_id, float amount_to_consume) AM_ConsumeAmmo;
void(float num_standard_modes) AM_InitWeaponFireModes; 
void() AM_CycleFireMode;
void() AM_WeaponFrame_HandleFireRelease;
float() AM_CanFireSemiAuto;
float(float ammo_id) AM_GetAmmoCount;

// --- From: am_ballistics.qc ---
void(float caliber, float bullet_type, float accuracy, float is_tracer) W_am_fire_bullet;
// ##Quedra: Add forward declarations for other am_ballistics functions if called externally e.g. launch_bullet

// --- From: am_recoil.qc ---
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil;
void(vector pattern, float recovery_rate) AM_SetRecoilPattern;
void() AM_ResetSustainedRecoil; 

// --- From: am_firemodes.qc (NEW) ---
void(float p_caliber, float p_bullet_type, float p_accuracy, float p_is_tracer, float p_recoil_str, float p_recoil_spr, float p_recoil_vert_bias, float p_recoil_sust_mult, float p_recoil_max_sust, string p_fire_sound, float p_cycle_rpm) AM_ExecuteStandardFire_Parameterized;
void(float p_burst_shot_count, float p_burst_inner_rpm, float p_burst_post_delay, float p_caliber, float p_bullet_type, float p_burst_accuracy, float p_recoil_b_str, float p_recoil_b_spr, float p_recoil_b_vert_bias, float p_recoil_b_sust_mult, float p_recoil_b_max_sust, string p_first_shot_sound, string p_burst_shot_sound, string p_empty_sound) AM_StartBurstFire_Parameterized;
void() AM_Burst_Think; 

// --- From: am_buckshot.qc ---
void(vector passed_fire_origin, float instances, float ammo_type, float ammo_spread_mod) W_am_buckshot;

// --- From: am_laser.qc ---
void(float laser_type, float with_muzzleflash, float play_sound) W_am_fire_laser;

// --- From: am_nails.qc ---
void(float ox) W_FireSpikes;
void() W_FireSuperSpikes;

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - WEAPON-SPECIFIC FUNCTIONS (from w_*.qc files)
//-----------------------------------------------------------------------------
// --- Mode Switchers ---
void() W_SwitchModeUMP45;  
void() W_SwitchModeRahp;   
void() W_SwitchModeDBShot; 
void() W_SwitchModeM93R;   
void() W_SwitchModeAk47;   

// --- SetCurrentAmmo Functions ---
void w_q_snailgun_SetCurrentAmmo (void); 
void w_ak47_SetCurrentAmmo (void);    
void w_m93r_SetCurrentAmmo (void);    
void w_ump45_SetCurrentAmmo (void);
void w_dbshot_SetCurrentAmmo (void); 
void w_rahpm1_SetCurrentAmmo (void); // ##Quedra: Added for completeness
void w_grapple_SetCurrentAmmo (void); // ##Quedra: Added for completeness

// --- Fire Functions ---
void W_Fire_Q_Snailgun (void); 
void W_FireAk47 (void);               
void W_FireM93R (void);               
void W_FireUMP45 (void);
void W_FireDBShot (void); 
void W_FireRahp (void); // ##Quedra: Added for completeness
void W_FireGrapple (void); // ##Quedra: Added for completeness


//-----------------------------------------------------------------------------
// ##Quedra: BUILT-IN ALIASES (if needed for KEX engine compatibility)
//-----------------------------------------------------------------------------
// ##Quedra: Your existing aliases are fine.
string(string cvar_name) cvar_string    = #0:ex_cvar_string; 
string(string s1, string s2, ...) strcat = #0:ex_strcat;     
float(string s) strlen                  = #0:ex_strlen;       
string(string s, float start_index, float length) substring = #0:ex_substring; 
float(string s) stof                    = #0:ex_stof;         

//=============================================================================
// defs_2.qc - End of FQX Mod - Part 2 of Global Definitions
//=============================================================================