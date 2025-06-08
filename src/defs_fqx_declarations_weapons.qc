//=============================================================================
// defs_fqx_declarations_weapons.qc - FQX Mod - Weapon Fwd Declarations
// Location: /src/
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Consolidates forward declarations for all Advanced Munitions (am_*)
// ##Quedra: and weapon-specific (w_*) modules.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: ADVANCED MUNITIONS (AM_*) MODULES (from defs_2.qc)
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
void get_buckshot_properties(float p_shell_type_id, float &p_damage_per_pellet, float &p_pellet_count, vector &p_dual_cone_data, float &p_velocity_mod, float &p_knockback_factor, float &p_armor_pen_mod);
float GetShellResourceCost(float shell_type_id);

// --- From: am_nails.qc ---
void(float ox) W_FireSpikes;
void() W_FireSuperSpikes;

// --- From: am_reload.qc ---
float() AM_CanReloadNow;
void() AM_InitiateWeaponReload;
void() AM_ReloadThink;
void() AM_ProcessReloadImpulse;

//-----------------------------------------------------------------------------
// ##Quedra: WEAPON-SPECIFIC (W_*) FUNCTIONS (from defs_2.qc)
//-----------------------------------------------------------------------------
void() W_SwitchModeUMP45;
void() W_SwitchModeRahp;
void() W_SwitchModeIZH43;
void() W_SwitchModeM93R;
void() W_SwitchModeAk47;
void() W_SwitchModeSawnoff;
void w_q_snailgun_SetCurrentAmmo (void);
void w_ak47_SetCurrentAmmo (void);
void w_m93r_SetCurrentAmmo (void);
void w_ump45_SetCurrentAmmo (void);
void w_izh43_SetCurrentAmmo (void);
void w_rahpm1_SetCurrentAmmo (void);
void w_sawnoff_SetCurrentAmmo (void);
void W_Fire_Q_Snailgun (void);
void W_FireAk47 (void);
void W_FireM93R (void);
void W_FireUMP45 (void);
void W_FireIZH43 (void);
void W_FireRahp (void);
void W_FireSawnoff (void);
void w_sawnoff_AnimateFireThink(void);
void w_izh43_AnimateFireThink(void);
void() w_q_rl_SetCurrentAmmo;
void() W_FireRL;

//=============================================================================
// defs_fqx_declarations_weapons.qc - FQX Mod - Weapon Fwd Declarations - END
// ##FQX - ##Quedra: Version 1.0.0
//=============================================================================