//=============================================================================
// defs_2.qc - FQX Mod - Part 2 of Global Definitions
// Location: /<PATH_TO_FQX_MOD>/progs/
// ##FQX - ##Quedra: Version 3.1.0
// ##Quedra: Centralizes FQX-specific constants, entity fields, and module forward declarations.
// ##Quedra: Dependencies: Relies on defs_1.qc for base Quake definitions. Used by all FQX modules.
// ##Quedra: v3.1.0 - Updated forward declaration for get_buckshot_properties to use
// ##Quedra:          'vector &p_dual_cone_data' (for am_buckshot.qc v2.4.0+).
// ##Quedra: v3.0.0 - Added SHELL_TYPE_* constants for 12G_00BUCK, 0BUCK, NO4BUCK, BIRDSHOT.
// ##Quedra: v2.9.1 - Corrected forward declaration for get_buckshot_properties (old signature).
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: GLOBAL GAME CONSTANTS & SYSTEM IDs
//-----------------------------------------------------------------------------

// --- AMMUNITION TYPE ID CONSTANTS ---
float AMMO_ID_SHELLS = 1; 
float AMMO_ID_NAILS = 2; 
float AMMO_ID_ROCKETS = 3; 
float AMMO_ID_CELLS = 4; 

// --- Shell Type ID Constants (for am_buckshot.qc) ---
float SHELL_TYPE_12G_000BUCK  = 1; 
float SHELL_TYPE_12G_00BUCK   = 2; // ##Quedra: Added in v3.0.0
float SHELL_TYPE_12G_0BUCK    = 3; // ##Quedra: Added in v3.0.0
float SHELL_TYPE_12G_NO1BUCK = 5; // ##Fox: Just plopping this in right here.
float SHELL_TYPE_12G_NO4BUCK  = 4; // ##Quedra: Added in v3.0.0

// ##Quedra: TODO_FQX - ##Soldier: Define any further SHELL_TYPE_* constants here as needed.

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

// --- Global Model Indices ---
float modelindex_player; 

// --- Standard Quake Global Variables ---
entity lastspawn;            
float startingserverflags; 

// --- Debug Toggles ---
float mc_debug_prints_enabled; 

//-----------------------------------------------------------------------------
// ##Quedra: GLOBAL PLAYER ENTITY FIELDS (.float, .string, .vector, .entity)
//-----------------------------------------------------------------------------
.float loot_bonus;          
.float loot_fragcheck; 
.float loadout_id_melee; 
.float loadout_id_holdout;     
.float loadout_id_secondary;   
.float loadout_id_primary;     
.float loadout_id_heavy;       
.float loadout_id_utility;     
.float loadout_id_aux1;      
.float loadout_id_aux2; 
.float loadout_id_aux3;       
.float saved_weapon;  
.float quick_melee_active; 
.float quick_melee_debug;
.float quick_melee_sequence;
.float current_weapon_fire_mode;    
.float weapon_fire_released; 
.float weapon_num_standard_modes;   
.float weapon_first_draw_init; 
.float dmgtime; 
.float weapon_ammo_in_magazine; 
.float weapon_is_reloading; 
.float reload_next_think_time; 
.float reload_time_finished; 
.float reload_rounds_to_add; 
.float  current_weapon_max_mag_capacity; 
.float  current_weapon_reload_duration; 
.float  current_weapon_game_ammo_cost_per_round; 
.string current_weapon_reload_start_sound; 
.string current_weapon_reload_finish_sound; 
.float  current_weapon_reload_anim_frame; 
.float  current_weapon_can_manual_reload; 
.string current_weapon_sound_empty; 
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
.float  firemode_slot_melee; 
.float  firemode_slot_holdout; 
.float  firemode_slot_secondary; 
.float  firemode_slot_primary; 
.float  firemode_slot_heavy; 
.float  firemode_slot_utility; 
.float  firemode_slot_aux1; 
.float  firemode_slot_aux2; 
.float  firemode_slot_aux3; 
.float rahp_primary_sound_toggle; 
.float sawnoff_sound_toggle; 
.float izh43_sound_toggle; 
.string noise_impact; 
.string noise_crit_impact; 
.float ebolt_type_field; 
.float impact_effect_field; 
.float crit_impact_effect_field; 

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - Standard Game & Utility Functions
//-----------------------------------------------------------------------------
void(entity passed_body) CopyToBodyQueue; 
const void(vector org, vector vel, float damage) SpawnBlood; 
void(float damage) spawn_touchblood;                       
float() W_BestWeapon; 
void() W_SetCurrentAmmo; 
void() player_run; 
string(string title) GetMapName; 
void() bubble_bob; 
void() ToggleMonsterCoreDebugPrints; 
void() FQX_MasterPrecache; 

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

// --- From: am_recoil.qc ---
void(float strength, float spread, float vertical_bias, float sustained_multiplier, float max_sustained) AM_ApplyRecoil; 
void(vector pattern, float recovery_rate) AM_SetRecoilPattern; 
void() AM_ResetSustainedRecoil;  
void() AM_RecoilThink; 

// --- From: am_firemodes.qc ---
void(float p_caliber, float p_bullet_type, float p_accuracy, float p_is_tracer, float p_recoil_str, float p_recoil_spr, float p_recoil_vert_bias, float p_recoil_sust_mult, float p_recoil_max_sust, string p_fire_sound, float p_cycle_rpm) AM_ExecuteStandardFire_Parameterized; 
void(float p_burst_shot_count, float p_burst_inner_rpm, float p_burst_post_delay, float p_caliber, float p_bullet_type, float p_burst_accuracy, float p_recoil_b_str, float p_recoil_b_spr, float p_recoil_b_vert_bias, float p_recoil_b_sust_mult, float p_recoil_b_max_sust, string p_first_shot_sound, string p_burst_shot_sound, string p_empty_sound) AM_StartBurstFire_Parameterized; 
void() AM_Burst_Think;  

// --- From: am_buckshot.qc ---
void(vector p_fire_origin, float p_num_discharges, float p_shell_type_id, float p_weapon_spread_modifier, float p_weapon_damage_modifier, string p_sound_to_play, entity p_attacker) W_am_fire_buckshot_parameterized; 
// ##Quedra: v3.1.0 - Updated for am_buckshot.qc v2.4.0+ (uses vector for dual-cone data)
void get_buckshot_properties(float p_shell_type_id, float &p_damage_per_pellet, float &p_pellet_count, vector &p_dual_cone_data, float &p_velocity_mod, float &p_knockback_factor, float &p_armor_pen_mod);

// --- From: am_nails.qc ---
void(float ox) W_FireSpikes; 
void() W_FireSuperSpikes; 

// --- From: am_reload.qc ---
float() AM_CanReloadNow; 
void() AM_InitiateWeaponReload; 
void() AM_ReloadThink; 
void() AM_ProcessReloadImpulse; 

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - WEAPON-SPECIFIC FUNCTIONS (from w_*.qc files)
//-----------------------------------------------------------------------------
void() W_SwitchModeUMP45; 
void() W_SwitchModeRahp; void() W_SwitchModeIZH43;  
void() W_SwitchModeM93R; void() W_SwitchModeAk47; void() W_SwitchModeSawnoff;  
void w_q_snailgun_SetCurrentAmmo (void); 
void w_ak47_SetCurrentAmmo (void); 
void w_m93r_SetCurrentAmmo (void); void w_ump45_SetCurrentAmmo (void); 
void w_izh43_SetCurrentAmmo (void); void w_rahpm1_SetCurrentAmmo (void); 
void w_sawnoff_SetCurrentAmmo (void); 
void W_Fire_Q_Snailgun (void); void W_FireAk47 (void); void W_FireM93R (void);              
void W_FireUMP45 (void); void W_FireIZH43 (void); 
void W_FireRahp (void);  
void W_FireSawnoff (void); 

//-----------------------------------------------------------------------------
// ##Quedra: FORWARD DECLARATIONS - OPERATIONAL SYSTEMS (op_*.qc files)
//-----------------------------------------------------------------------------
void(entity player) Loadout_EncodeParms; 
void(entity player) Loadout_DecodeParms; 
void(entity player) Loadout_SetDefaults; 
float(entity p_player, float p_it_slot_flag) GetWeaponIDForITSlot; 

//-----------------------------------------------------------------------------
// ##Quedra: BUILT-IN ALIASES (if needed for KEX engine compatibility)
//-----------------------------------------------------------------------------
string(string cvar_name) cvar_string    = #0:ex_cvar_string; 
string(string s1, string s2, ...) strcat = #0:ex_strcat; 
float(string s) strlen                  = #0:ex_strlen; 
string(string s, float start_index, float length) substring = #0:ex_substring; 
float(string s) stof                    = #0:ex_stof; 

//=============================================================================
// defs_2.qc - FQX Mod - Part 2 of Global Definitions - END
// ##FQX - ##Quedra: Version 3.1.0
//=============================================================================