//=============================================================================
// mc_defs.qc - FQX Mod - Monster Core System Definitions
// ##FQX - ##Quedra: Version 1.6 - Activated .mc_has_played_sight_sound field
// ##FQX - ##Quedra: Added new entity fields for monster-specific weapon handling.
//=============================================================================

//============================================================================
// ##FQXnote: MONSTER CORE AI STATE CONSTANTS
// ##FQXnote: Used by mc_bh_ai.qc and monster entities (self.mc_ai_state).
//============================================================================
#define MC_AI_STATE_SPAWN       0 // ##FQXnote: Initial state, transitioning to Idle or custom spawn anim.
#define MC_AI_STATE_IDLE        1 // ##FQXnote: Idle, patrolling, or standing still. Looking for targets.
#define MC_AI_STATE_PURSUE      2 // ##FQXnote: Actively moving towards/hunting a known enemy.
#define MC_AI_STATE_COMBAT      3 // ##FQXnote: Engaging an enemy (melee, missile, special).
#define MC_AI_STATE_PAIN        4 // ##FQXnote: Monster is in a pain animation/state.
#define MC_AI_STATE_DEAD        5 // ##FQXnote: Monster is dead or dying.
#define MC_AI_STATE_CUSTOM      6 // ##FQXnote: For unique, monster-specific behaviors not covered.

//============================================================================
// ##FQXnote: STANDARD PERCEPTION RANGE CONSTANTS
// ##FQXnote: These (RANGE_MELEE, RANGE_NEAR, RANGE_MID, RANGE_FAR) are defined
// ##FQXnote: in FQX defs_3.qc and are used by mc_ops_perception.qc.
//============================================================================

//============================================================================
// ##FQXnote: STANDARD ATTACK STATE CONSTANTS
// ##FQXnote: These (AS_STRAIGHT, AS_SLIDING, AS_MELEE, AS_MISSILE) are defined
// ##FQXnote: in FQX defs_3.qc and are used by mc_bh_ai.qc and
// ##FQXnote: monster-specific CheckAttack functions.
//============================================================================

//============================================================================
// ##FQXnote: NEW MONSTER CORE ENTITY FIELD DECLARATIONS
// ##FQXnote: These fields are added to all entities for use by the MC_* system.
//============================================================================

// --- Fields for MC_Initialize_Monster & MC_Pain_Handler/MC_Death_Handler (mc_ops_states.qc) ---
.string mc_sound_pain_primary;    // ##FQXnote: Stores path to primary pain sound.
.string mc_sound_death_primary;   // ##FQXnote: Stores path to primary death sound.
.string mc_sound_idle_primary;    // ##FQXnote: Stores path to primary idle sound.

.float mc_gib_health_threshold;  // ##FQXnote: Health threshold below which monster gibs.
.string mc_head_gib_model_path;   // ##FQXnote: Path to monster's head gib model.
.string mc_item_drop_field_name;  // ##FQXnote: String name of the ammo field (e.g., "ammo_shells").
.float mc_item_drop_amount;      // ##FQXnote: Amount of the specified item to drop.

// --- Fields for MC_AI_Master_Think system & Combat (mc_bh_ai.qc, mc_ops_combat.qc) ---
.float mc_ai_state;              // ##FQXnote: Current AI state (uses MC_AI_STATE_* constants).
.float () mc_check_attack_func;   // ##FQXnote: Pointer to monster's specific *CheckAttack function.
.float mc_melee_reach;           // ##FQXnote: Monster's specific melee attack reach distance.
.void() mc_anim_slide_func;       // ##FQXnote: Pointer to a monster's slide/strafe animation function.

.float mc_attack_finished_time;  //##Fox: Just stuffed this in here. Might not be the best section.

.float mc_has_played_sight_sound; // ##FQX - ##Quedra: Activated. Flag to control sight sound frequency.
// .float mc_next_idle_sound_time; // ##FQXnote: Timer for playing periodic idle sounds (example).
// .void() mc_custom_think_func;    // ##FQXnote: Pointer to a monster-specific custom AI think function.

// --- Fields for Monster Weapon Adaption Layer (mc_mon_weapons.qc) ---
.float mc_weapon_id;                    // ##FQX - ##Quedra: Current WEAPON_ID_* monster is using (from defs_2.qc).
.float mc_weapon_mag_capacity;          // ##FQX - ##Quedra: Max ammo for current weapon's "magazine".
.float mc_current_ammo_in_mag;        // ##FQX - ##Quedra: Current ammo in the "magazine".
.float mc_weapon_allowed_firemodes;     // ##FQX - ##Quedra: Bitmask of allowed fire modes for this monster with this weapon.
.float mc_weapon_reload_duration;       // ##FQX - ##Quedra: Specific reload duration for this monster with this weapon.
.float mc_reload_finish_time;           // ##FQX - ##Quedra: Game time when current reload finishes.
.float mc_is_reloading;                 // ##FQX - ##Quedra: Boolean (0 or 1), is monster currently in reload logic/animation.
.float mc_shots_to_fire_this_burst;     // ##FQX - ##Quedra: For monster "engagement bursts" (e.g., Grunt M93R fires 2-4 shots).
.void() th_reload_anim_func;          // ##FQX - ##Quedra: Pointer to monster's specific reload animation start function.


//============================================================================
// ##FQXnote: FORWARD DECLARATIONS FOR MONSTER CORE (MC_*) FUNCTIONS
// ##FQXnote: Ensures functions are known if this file is included before their definitions.
// ##FQXnote: Primary mechanism for availability is progs.src order.
//============================================================================

// --- From: mc_ops_states.qc ---
void(entity p_mon, float p_health, string p_model_path, vector p_mins, vector p_maxs, float p_movetype, float p_solid_type, float p_flags_to_add,
    void() p_th_stand_func, void() p_th_walk_func, void() p_th_run_func, void(entity attacker, float damage) p_th_pain_func, void() p_th_die_func,
    void() p_th_melee_func, void() p_th_missile_func,
    string p_sound_sight, string p_sound_pain_primary, string p_sound_death_primary, string p_sound_idle_primary,
    float p_yaw_speed, vector p_view_ofs, void() p_initial_think_func, float p_pausetime_if_no_target,
    float p_allow_path_find, float p_combat_style, string p_netname, string p_killstring,
    float p_gib_health_thresh, string p_head_gib_model_path, string p_item_drop_field_name, float p_item_drop_amount) MC_Initialize_Monster;
void(entity p_mon, entity p_attacker, float p_damage, void() p_pain_anim_func_ptr, string p_pain_sound_override, float p_pain_threshold, float p_pain_chance, float p_pain_duration) MC_Pain_Handler;
void(entity p_mon, entity p_attacker, void() p_death_anim_func_ptr, string p_death_sound_override, string p_gib_sound_override, void() p_gib_func_override, void() p_drop_item_func_override) MC_Death_Handler;

// --- From: mc_ops_movement.qc ---
void(entity p_mon, void() p_anim_start_func) MC_Set_Animation;
void(entity p_mon, void() p_anim_think_func, float p_start_frame, float p_end_frame, float p_loop_to_frame, void() p_end_cycle_think_func) MC_Advance_FrameCycle;
void(entity p_mon, vector p_dest_pos, float p_move_speed_scalar, float p_ideal_yaw_override, void() p_end_reach_think_func, float p_reach_threshold) MC_MoveToPoint_Direct;
float(entity p_mon, entity p_goal_entity, float p_move_dist_per_think) MC_Attempt_PathToGoal;
void(entity p_mon, entity p_target_entity) MC_Face_Target;

// --- From: mc_ops_perception.qc ---
float(entity p_seer, entity p_target, float p_ignore_other_entities) MC_Can_See;
float(entity p_observer, entity p_target) MC_Is_Infront;
float(entity p_observer, entity p_target) MC_Get_Range_Category;
entity(entity p_mon, float p_force_new_target_check) MC_Find_Best_Target;

// --- From: mc_ops_combat.qc ---
float(entity p_mon, entity p_target_enemy, float p_melee_reach, void() p_melee_anim_start_func, string p_melee_sound_override) MC_Execute_Melee;
float(entity p_mon, entity p_target_enemy, void() p_missile_anim_start_func, string p_missile_attack_sound_override) MC_Execute_Missile;
float(entity p_mon, entity p_target_enemy, float p_min_range, float p_max_range) MC_Check_Attack_Range;
float(entity p_mon, entity p_target_enemy) MC_Can_Damage_Target;

// --- From: mc_bh_ai.qc ---
void(entity p_mon) MC_AI_Think_Idle;
void(entity p_mon) MC_AI_Think_Pursuit;
void(entity p_mon) MC_AI_Think_Combat;
void(entity p_mon) MC_AI_Think_Pain;
// ##Quedra: void(entity mon) MC_AI_Think_Fallback; // Will be added when that phase is reached
void() MC_AI_Master_Think;
void(void() func_on_refire) MC_SUB_CheckRefire;

//=============================================================================
// ##Quedra: FORWARD DECLARATIONS FOR SPECIFIC MONSTER ANIMATIONS (for Diagnostics)
// ##Quedra: These are needed if MC files reference them directly, e.g., in dprints.
//=============================================================================
// --- From: grunt.qc (monster_army) ---
void() army_walk1;
void() army_stand1;
void() army_run1;
void() army_atk1;
// ##Quedra: Add other specific monster animation function forwards here if needed by MC diagnostics.
float gruntdprintcheck; 
// ##Quedra: For ensuring grunt frame dprints only fire once per map (used in grunt.qc).
//=============================================================================
// mc_defs.qc - FQX Mod - Monster Core System Definitions - END
//=============================================================================