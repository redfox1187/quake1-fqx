//=============================================================================
// defs_fqx_declarations_monsters.qc - FQX Mod - Monster Fwd Declarations
// Location: /src/
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Consolidates forward declarations for the Monster Core (mc_*)
// ##Quedra: system and any specific monster animations.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: MONSTER CORE (MC_*) FUNCTIONS (from mc_defs.qc)
//-----------------------------------------------------------------------------

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
void() MC_AI_Master_Think;
void(void() func_on_refire) MC_SUB_CheckRefire;

//-----------------------------------------------------------------------------
// ##Quedra: SPECIFIC MONSTER ANIMATIONS (from mc_defs.qc)
//-----------------------------------------------------------------------------
// --- From: grunt.qc (monster_army) ---
void() army_walk1;
void() army_stand1;
void() army_run1;
void() army_atk1;

//=============================================================================
// defs_fqx_declarations_monsters.qc - FQX Mod - Monster Fwd Declarations - END
// ##FQX - ##Quedra: Version 1.0.0
//=============================================================================