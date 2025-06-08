//=============================================================================
// gpe_client_3.qc - FQX Mod - PlayerPreThink Logic
// Location: /src/
// ##FQXCUSTOM - ##Quedra: Version 2.3.2
// ##Quedra: Purpose: Contains PlayerPreThink, including FQX impulse handling and UI refresh logic.
// ##Quedra: Derived from client.qc v2.3.1 logic. Original header noted v2.2.
// ##Quedra: v2.3.2 - Added LoadoutUI_Display refresh call in PlayerPreThink if UI is active.
// ##Quedra: v2.2 (original file header) - Modified ammo check logic for FQX magazine weapons.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: PlayerPreThink - Main per-frame client logic BEFORE physics
//-----------------------------------------------------------------------------
void() PlayerPreThink = 
{ 
    // ##FQXDEBUG - ##Fox: PlayerPreThink Entry
    dprint(strcat("PlayerPreThink (gpe_client_3.qc): Running for ", self.netname, " Impulse: ", ftos(self.impulse), "\n")); 

    if (intermission_running) 
    {
        IntermissionThink(); 
        return; 
    }  
    if (self.view_ofs == '0 0 0') // Not fully spawned in 
    {
        return; 
    }  

    makevectors(self.v_angle); // For global v_forward, etc. 
    if (deathmatch || coop) 
    {
        CheckRules(); 
    }  
    
    WaterMove(); 
    if (self.waterlevel == 2) // If waist deep 
    {
        CheckWaterJump(); 
    }  

    if (self.deadflag >= DEAD_DEAD) 
    {
        PlayerDeathThink(); 
        return; 
    }  
    if (self.deadflag == DEAD_DYING) 
    {
        return; 
    // Playing death animation 
    }  

    if (self.button2) // Check for jump 
    {
        PlayerJump(); 
    }  
    else
    {
        self.flags = self.flags | FL_JUMPRELEASED; // Jump button released 
    }  

    if (time < self.pausetime) // Player is frozen 
    {
        self.velocity = '0 0 0'; 
    }  

    // ##FQX - ##Quedra: Handle Manual Reload Impulse 
    if (self.impulse == 23) 
    {
        AM_ProcessReloadImpulse(); 
        self.impulse = 0; 
    }

    // ##FQX - ##Quedra: Handle Monster Core Debug Print Toggle Impulse 
    if (self.impulse == 24) 
    {
        ToggleMonsterCoreDebugPrints(); 
        self.impulse = 0; 
    }
    
    // ##FQX - ##Quedra: START - Loadout UI Impulse Handling (v2.3.0 client.qc Addition) 
    // ##Quedra: Impulse 30 is used to toggle the primary slot loadout UI. 
    // ##Quedra: This should be bound by the player (e.g., bind x "impulse 30"). 
    if (self.impulse == 30)  
    {
        // ##FQXDEBUG - ##Fox: Impulse 30 Detected 
        dprint("PlayerPreThink (gpe_client_3.qc): Impulse 30 DETECTED. Calling LoadoutUI_Toggle.\n"); 
        LoadoutUI_Toggle(self, IT_SLOT_PRIMARY); 
        self.impulse = 0; // Consume the impulse 
    }
    // ##Quedra: If the UI is active, pass other impulses to its input handler. 
    // ##Quedra: LoadoutUI_HandleInput will check self.impulse for selections (e.g., 1-5) and consume it. 
    else if (self.loadout_ui_active == TRUE && self.impulse != 0)  
    {
        LoadoutUI_HandleInput(self); 
        // ##Quedra: LoadoutUI_HandleInput is responsible for consuming self.impulse if used. 
    }
    // ##FQX - ##Quedra: END - Loadout UI Impulse Handling 

    // ##FQX - ##Quedra: START - Loadout UI Display Refresh (v2.3.2 gpe_client_3.qc)
    if (self.loadout_ui_active == TRUE)
    {
        // ##Quedra: This dprint might be very spammy once the UI is visible.
        // ##FQXDEBUG - ##Fox:
        dprint("PlayerPreThink (gpe_client_3.qc): UI active, REFRESHING LoadoutUI_Display.\n");
        LoadoutUI_Display(self); 
    }
    // ##FQX - ##Quedra: END - Loadout UI Display Refresh
    
    AM_RecoilThink(); // Process recoil recovery 

    // ##FQXCUSTOM - ##Quedra: v2.2 - Refined "out of ammo" check for FQX systems. 
    // ##Quedra: This check runs if the player is not attacking and their current weapon might be empty. 
    // ##Quedra: It ensures that magazine weapons only trigger W_BestWeapon if truly out of all resources. 
    if (time > self.attack_finished && self.weapon != IT_SLOT_MELEE && self.weapon != IT_SLOT_HOLDOUT) 
    { 
        local float truly_out_of_ammo = FALSE; 
        if (self.current_weapon_max_mag_capacity > 0) // Check if current weapon uses FQX magazine system 
        {
            // Magazine weapon is truly out if mag is empty AND cannot reload from global resource 
            if (self.weapon_ammo_in_magazine <= 0) 
            {
                // Ensure current_weapon_game_ammo_cost_per_round is valid  
                // AND (weapon_ammo_resource_id is validly set by weapon's SetCurrentAmmo AND global ammo for that resource is less than cost) 
                if (self.current_weapon_game_ammo_cost_per_round <= 0 || 
                    AM_GetAmmoCount(self.weapon_ammo_resource_id) < self.current_weapon_game_ammo_cost_per_round) 
                {
                    truly_out_of_ammo = TRUE; 
                }
            }
        }
        else // Standard (non-magazine) weapon 
        {
            if (self.currentammo <= 0) 
            {
                truly_out_of_ammo = TRUE; 
            }
        }

        if (truly_out_of_ammo) 
        {
            self.weapon = W_BestWeapon(); 
            self.weapon_first_draw_init = TRUE; 
            W_SetCurrentAmmo(); 
        }
    } 
    
    if (self.frags > self.loot_fragcheck) 
    { 
        self.loot_bonus = self.loot_bonus + (self.frags - self.loot_fragcheck); 
        self.loot_fragcheck = self.frags; 
    } 
};

//=============================================================================
// gpe_client_3.qc - FQX Mod - PlayerPreThink Logic - END
// ##FQXCUSTOM - ##Quedra: Version 2.3.2
//=============================================================================