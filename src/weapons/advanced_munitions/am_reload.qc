//=============================================================================
// am_reload.qc - FQX Mod - Core Reload Operations
// ##FQX - ##Quedra: Version 1.2
// ##Quedra: Provides generic functions for weapon reloading, including
// ##Quedra: manual impulse-driven reloads and reload-on-empty logic.
// ##Quedra: Handles magazine discard, ammo consumption, and state management.
// ##Quedra: v1.2 - AM_CanReloadNow now checks self.attack_finished to prevent reload during fire cooldown.
// ##Quedra:        - AM_CanReloadNow now uses AM_GetAmmoCount for generic ammo resource check.
// ##Quedra: v1.1 - Corrected use of non-existent 'min' function.
//=============================================================================

// ##Quedra: Forward declaration for function from am_operations.qc (ensure globally available via defs_2.qc or progs.src order)
float AM_GetAmmoCount(float ammo_id);

//-----------------------------------------------------------------------------
// ##Quedra: AM_CanReloadNow
// ##Quedra: Checks if the player can currently initiate a manual reload.
// ##Quedra: Relies on self.current_weapon_* fields being set by active weapon.
//-----------------------------------------------------------------------------
float AM_CanReloadNow()
{
    // ##Quedra: v1.2 - Added check for attack_finished
    if (time < self.attack_finished) // Player is still in attack/fire cooldown
    {
        return FALSE;
    }

    if (self.weapon_is_reloading == TRUE) // Already reloading
    {
        return FALSE;
    }

    if (self.current_weapon_can_manual_reload == FALSE) // Weapon doesn't support manual reload
    {
        return FALSE;
    }

    if (self.weapon_ammo_in_magazine >= self.current_weapon_max_mag_capacity) // Magazine is already full
    {
        return FALSE;
    }

    // ##Quedra: v1.2 - Changed to use generic ammo resource check
    // Check if there's enough global game ammo for at least one actual weapon round
    if (self.current_weapon_game_ammo_cost_per_round <= 0) // Cannot reload if cost is zero or invalid
    {
        // dprint("AM_CanReloadNow: current_weapon_game_ammo_cost_per_round is zero or negative.\n"); // Optional debug
        return FALSE;
    }
    if (AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.current_weapon_game_ammo_cost_per_round)
    {
        // dprint("AM_CanReloadNow: Not enough global ammo resource.\n"); // Optional debug
        return FALSE;
    }

    return TRUE;
}

//-----------------------------------------------------------------------------
// ##Quedra: AM_InitiateWeaponReload
// ##Quedra: Core function to start a reload sequence for the current weapon.
// ##Quedra: Assumes self.current_weapon_* fields are populated by the active
// ##Quedra: weapon's _SetCurrentAmmo function.
// ##Quedra: Implements "discard remaining rounds" logic as per TDD principles.
//-----------------------------------------------------------------------------
void AM_InitiateWeaponReload()
{
    if (self.weapon_is_reloading == TRUE) // Safety check
    {
        return;
    }

    // Discard Rule: If magazine has rounds, they are lost before reloading.
    if (self.weapon_ammo_in_magazine > 0)
    {
        self.weapon_ammo_in_magazine = 0;
    }

    local float rounds_possible_to_load_based_on_game_ammo;
    if (self.current_weapon_game_ammo_cost_per_round > 0) // Avoid division by zero
    {
        // ##Quedra: Use AM_GetAmmoCount for the specific resource type
        rounds_possible_to_load_based_on_game_ammo = floor(AM_GetAmmoCount(self.weapon_ammo_resource_id) / self.current_weapon_game_ammo_cost_per_round);
    }
    else
    {
        rounds_possible_to_load_based_on_game_ammo = 0; // Cannot load if cost is zero or less
    }
    
    local float rounds_needed_for_full_mag;
    rounds_needed_for_full_mag = self.current_weapon_max_mag_capacity; // Magazine is now considered empty

    // ##Quedra: Replaced non-existent 'min' function with conditional logic.
    if (rounds_needed_for_full_mag < rounds_possible_to_load_based_on_game_ammo)
    {
        self.reload_rounds_to_add = rounds_needed_for_full_mag;
    }
    else
    {
        self.reload_rounds_to_add = rounds_possible_to_load_based_on_game_ammo;
    }

    if (self.reload_rounds_to_add <= 0) // Cannot load any rounds
    {
        if (self.current_weapon_sound_empty != string_null && self.current_weapon_sound_empty != "")
        {
            sound(self, CHAN_WEAPON, self.current_weapon_sound_empty, 1, ATTN_NORM);
        }
        self.attack_finished = time + 0.3; 
        return;
    }

    self.weapon_is_reloading = TRUE; 
    self.reload_time_finished = time + self.current_weapon_reload_duration;
    if (self.current_weapon_reload_start_sound != string_null && self.current_weapon_reload_start_sound != "")
    {
        sound(self, CHAN_WEAPON, self.current_weapon_reload_start_sound, 1, ATTN_NORM);
    }

    self.weaponframe = self.current_weapon_reload_anim_frame;
    self.attack_finished = self.reload_time_finished; 

    self.think = AM_ReloadThink;
    self.nextthink = self.reload_time_finished;
}

//-----------------------------------------------------------------------------
// ##Quedra: AM_ReloadThink
// ##Quedra: Called when the reload timer finishes. Consumes global ammo,
// ##Quedra: adds rounds to magazine, plays sound, and resets state.
// ##Quedra: Calls W_SetCurrentAmmo() to refresh weapon state and HUD.
//-----------------------------------------------------------------------------
void AM_ReloadThink()
{
    self.weapon_is_reloading = FALSE; 

    local float game_ammo_to_consume;
    game_ammo_to_consume = self.reload_rounds_to_add * self.current_weapon_game_ammo_cost_per_round;

    // ##Quedra: Consume the correct ammo type
    if (self.weapon_ammo_resource_id == AMMO_ID_SHELLS) { self.ammo_shells -= game_ammo_to_consume; if (self.ammo_shells < 0) self.ammo_shells = 0; }
    else if (self.weapon_ammo_resource_id == AMMO_ID_NAILS) { self.ammo_nails -= game_ammo_to_consume; if (self.ammo_nails < 0) self.ammo_nails = 0; }
    else if (self.weapon_ammo_resource_id == AMMO_ID_ROCKETS) { self.ammo_rockets -= game_ammo_to_consume; if (self.ammo_rockets < 0) self.ammo_rockets = 0; }
    else if (self.weapon_ammo_resource_id == AMMO_ID_CELLS) { self.ammo_cells -= game_ammo_to_consume; if (self.ammo_cells < 0) self.ammo_cells = 0; }
    // else { dprint("AM_ReloadThink: Unknown weapon_ammo_resource_id!\n"); } // Optional debug

    self.weapon_ammo_in_magazine += self.reload_rounds_to_add;
    
    if (self.weapon_ammo_in_magazine > self.current_weapon_max_mag_capacity) 
    {
        self.weapon_ammo_in_magazine = self.current_weapon_max_mag_capacity;
    }

    if (self.current_weapon_reload_finish_sound != string_null && self.current_weapon_reload_finish_sound != "")
    {
        sound(self, CHAN_VOICE, self.current_weapon_reload_finish_sound, 1, ATTN_NORM);
    }
    
    self.weaponframe = 0; 

    self.think = SUB_Null; 
    self.nextthink = -1;   

    W_SetCurrentAmmo();
}

//-----------------------------------------------------------------------------
// ##Quedra: AM_ProcessReloadImpulse
// ##Quedra: Handles the player's manual reload impulse. Checks conditions
// ##Quedra: via AM_CanReloadNow() then calls AM_InitiateWeaponReload().
//-----------------------------------------------------------------------------
void AM_ProcessReloadImpulse()
{
    if (self.health <= 0 || (self.flags & FL_NOTARGET)) 
    {
        return;
    }
    
    if (AM_CanReloadNow())
    {
        AM_InitiateWeaponReload();
    }
}

//=============================================================================
// am_reload.qc - End of FQX Mod - Core Reload Operations
// ##FQX - ##Quedra: Version 1.2
//=============================================================================