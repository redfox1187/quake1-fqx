//=============================================================================
// defs_fqx_fields.qc - FQX Mod - Custom Entity Field Definitions
// Location: /src/
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Consolidates all custom FQX entity field definitions from various
// ##Quedra: previous defs files (defs_2, mc_defs). This file MUST be loaded
// ##Quedra: after 'defs_quake_core.qc' in progs.src to ensure binary compatibility.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: Player & General Weapon System Fields (from defs_2.qc)
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
.float weapon_ammo_resource_id;
.float weapon_ammo_cost_per_shot;
.float firemode_slot_melee;
.float firemode_slot_holdout;
.float firemode_slot_secondary;
.float firemode_slot_primary;
.float firemode_slot_heavy;
.float firemode_slot_utility;
.float firemode_slot_aux1;
.float firemode_slot_aux2;
.float firemode_slot_aux3;
.float rahp_primary_sound_toggle;
.float sawnoff_sound_toggle;
.float izh43_sound_toggle;
.string noise_impact;
.string noise_crit_impact;
.float ebolt_type_field;
.float impact_effect_field;
.float crit_impact_effect_field;

//-----------------------------------------------------------------------------
// ##Quedra: Magazine & Reload System Fields (from defs_2.qc)
//-----------------------------------------------------------------------------
.float weapon_ammo_in_magazine;
.float weapon_is_reloading;
.float reload_next_think_time;
.float reload_time_finished;
.float reload_rounds_to_add;
.float current_weapon_max_mag_capacity;
.float current_weapon_reload_duration;
.float current_weapon_game_ammo_cost_per_round;
.string current_weapon_reload_start_sound;
.string current_weapon_reload_finish_sound;
.float current_weapon_reload_anim_frame;
.float current_weapon_can_manual_reload;
.string current_weapon_sound_empty;

//-----------------------------------------------------------------------------
// ##Quedra: Burst Fire System Fields (from defs_2.qc)
//-----------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------
// ##Quedra: Loadout Selection UI State Fields (from defs_2.qc)
//-----------------------------------------------------------------------------
.float loadout_ui_active;
.float loadout_ui_target_slot_flag;
.float loadout_ui_item_count;
.float loadout_ui_item_id_1;
.float loadout_ui_item_id_2;
.float loadout_ui_item_id_3;
.float loadout_ui_item_id_4;
.float loadout_ui_item_id_5;

//=============================================================================
// defs_fqx_fields.qc - FQX Mod - Custom Entity Field Definitions - END
// ##FQX - ##Quedra: Version 1.0.0
//=============================================================================