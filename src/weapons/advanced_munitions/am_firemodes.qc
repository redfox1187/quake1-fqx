//============================================================================
// am_firemodes.qc
// ##Quedra: Contains generic execution logic for weapon fire modes.
// ##Quedra: - Standard (Semi/Auto) Fire
// ##Quedra: - Burst Fire Sequence
//============================================================================

//============================================================================
// AM_ExecuteStandardFire_Parameterized
// ##Quedra: Handles a single standard shot (semi-auto or full-auto).
// ##Quedra: Called by W_Fire<WeaponName>() after mode-specific checks and parameter gathering.
//============================================================================
void AM_ExecuteStandardFire_Parameterized(
    float p_caliber, float p_bullet_type, float p_accuracy, float p_is_tracer,
    float p_recoil_str, float p_recoil_spr, float p_recoil_vert_bias, 
    float p_recoil_sust_mult, float p_recoil_max_sust,
    string p_fire_sound,
    float p_cycle_rpm
)
{
    // ##Quedra: Assumes self.weapon_ammo_resource_id and self.weapon_ammo_cost_per_shot 
    // ##Quedra: were set by the calling W_Fire<WeaponName>() function.
    AM_ConsumeAmmo(self.weapon_ammo_resource_id, self.weapon_ammo_cost_per_shot);
    sound(self, CHAN_WEAPON, p_fire_sound, 1, ATTN_NORM);
    W_am_fire_bullet(p_caliber, p_bullet_type, p_accuracy, p_is_tracer);
    AM_ApplyRecoil(p_recoil_str, p_recoil_spr, p_recoil_vert_bias, p_recoil_sust_mult, p_recoil_max_sust);
    self.attack_finished = time + (60 / p_cycle_rpm);
    
    // ##Quedra: W_Attack in weapons.qc calls player_shot1() which handles generic viewmodel animation.
    // ##Quedra: No specific self.weaponframe setting needed here for that basic animation.
}

//============================================================================
// ##Quedra: Generic Burst Fire System - MOVED HERE from am_operations.qc
//============================================================================

//----------------------------------------------------------------------------
// AM_Burst_Think
// ##Quedra: Think function for subsequent shots in a burst.
// ##Quedra: Uses self.burst_* fields populated by AM_StartBurstFire_Parameterized.
//----------------------------------------------------------------------------
void AM_Burst_Think()
{
    // ##Quedra: Check if burst should continue (e.g. player released fire, W_WeaponFrame sets self.burst_active = FALSE)
    if (self.burst_shots_left <= 0 || !self.burst_active)
    {
        self.burst_active = FALSE; 
        AM_ResetSustainedRecoil(); 
        self.attack_finished = time + self.burst_post_cooldown; 
        self.think = SUB_Null; 
        self.nextthink = -1;
        player_run(); 
        return;
    }

    // ##Quedra: self.weapon_ammo_resource_id and self.weapon_ammo_cost_per_shot are used here,
    // ##Quedra: assumed to be set by W_Fire<WeaponName>() and remain valid for the burst duration.
    if (AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.weapon_ammo_cost_per_shot)
    {
        sound(self, CHAN_AUTO, self.burst_empty_sound, 1, ATTN_NORM); // Uses self.burst_empty_sound
        self.burst_active = FALSE; 
        AM_ResetSustainedRecoil();
        self.attack_finished = time + 0.5; 
        self.think = SUB_Null;
        self.nextthink = -1;
        player_run();
        return;
    }

    AM_ConsumeAmmo(self.weapon_ammo_resource_id, self.weapon_ammo_cost_per_shot);
    sound(self, CHAN_WEAPON, self.burst_sound_fire, 1, ATTN_NORM); // Uses self.burst_sound_fire
    
    // ##Quedra: Uses self.burst_caliber, self.burst_bullet_type, self.burst_accuracy
    W_am_fire_bullet(self.burst_caliber, self.burst_bullet_type, self.burst_accuracy, FALSE); 
    
    // ##Quedra: Uses self.burst_recoil_* parameters
    AM_ApplyRecoil(self.burst_recoil_str, self.burst_recoil_spr, self.burst_recoil_vert_bias, 
                   self.burst_recoil_sust_mult, self.burst_recoil_max_sust);
    
    self.burst_shots_left = self.burst_shots_left - 1;

    if (self.burst_shots_left > 0 && self.burst_active) 
    {
        self.think = AM_Burst_Think;
        self.nextthink = time + (60 / self.burst_rpm); // Uses self.burst_rpm
        self.attack_finished = self.nextthink; 
    }
    else 
    {
        self.burst_active = FALSE;
        AM_ResetSustainedRecoil();
        self.attack_finished = time + self.burst_post_cooldown; // Uses self.burst_post_cooldown
        self.think = SUB_Null; 
        self.nextthink = -1;
        player_run();
    }
}

//----------------------------------------------------------------------------
// AM_StartBurstFire_Parameterized
// ##Quedra: Initiates a burst fire sequence. Fires the FIRST shot, then sets up AM_Burst_Think.
// ##Quedra: Called by W_Fire<WeaponName>() which passes all weapon-specific burst parameters.
//----------------------------------------------------------------------------
void AM_StartBurstFire_Parameterized(
    float p_burst_shot_count, float p_burst_inner_rpm, float p_burst_post_delay,
    float p_caliber, float p_bullet_type, float p_burst_accuracy,
    float p_recoil_b_str, float p_recoil_b_spr, float p_recoil_b_vert_bias,
    float p_recoil_b_sust_mult, float p_recoil_b_max_sust,
    string p_first_shot_sound, string p_burst_shot_sound, string p_empty_sound
)
{
    // ##Quedra: Assumes self.weapon_ammo_resource_id and self.weapon_ammo_cost_per_shot 
    // ##Quedra: were set by the calling W_Fire<WeaponName>() function.
    // ##Quedra: Also assumes ammo check for first shot was done by W_Fire<WeaponName>().

    // --- Fire the FIRST shot of the burst ---
    AM_ConsumeAmmo(self.weapon_ammo_resource_id, self.weapon_ammo_cost_per_shot); 
    sound(self, CHAN_WEAPON, p_first_shot_sound, 1, ATTN_NORM);
    W_am_fire_bullet(p_caliber, p_bullet_type, p_burst_accuracy, FALSE); // ##Quedra: No tracer for typical burst
    AM_ApplyRecoil(p_recoil_b_str, p_recoil_b_spr, p_recoil_b_vert_bias, 
                   p_recoil_b_sust_mult, p_recoil_b_max_sust); // ##Quedra: Use burst recoil for first shot too

    // --- Populate self.burst_* fields for AM_Burst_Think ---
    self.burst_shots_total = p_burst_shot_count;
    self.burst_shots_left = p_burst_shot_count - 1; // One shot just fired

    self.burst_rpm = p_burst_inner_rpm; 
    self.burst_post_cooldown = p_burst_post_delay;
    
    self.burst_caliber = p_caliber;
    self.burst_bullet_type = p_bullet_type;
    self.burst_accuracy = p_burst_accuracy; // Accuracy for subsequent shots
    
    self.burst_recoil_str = p_recoil_b_str;         // Recoil for subsequent shots
    self.burst_recoil_spr = p_recoil_b_spr;
    self.burst_recoil_vert_bias = p_recoil_b_vert_bias;
    self.burst_recoil_sust_mult = p_recoil_b_sust_mult;
    self.burst_recoil_max_sust = p_recoil_b_max_sust;
    
    self.burst_sound_fire = p_burst_shot_sound;     // Sound for subsequent shots
    self.burst_empty_sound = p_empty_sound;
    
    // --- Schedule AM_Burst_Think if more shots are due ---
    self.burst_active = TRUE;
    if (self.burst_shots_left > 0) 
    {
        self.think = AM_Burst_Think;
        self.nextthink = time + (60 / self.burst_rpm); 
        self.attack_finished = self.nextthink; 
    }
    else // ##Quedra: Burst was only 1 shot (p_burst_shot_count was 1)
    {
         self.burst_active = FALSE; 
         AM_ResetSustainedRecoil();
         self.attack_finished = time + self.burst_post_cooldown; 
         self.think = SUB_Null;
         self.nextthink = -1;
         player_run(); 
    }
}
//============================================================================
// ##Quedra: Generic Burst Fire System - END
//============================================================================