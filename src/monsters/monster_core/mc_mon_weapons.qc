//=============================================================================
// mc_mon_weapons.qc - FQX Mod - Monster Core: Monster Weapon Adaption Layer
// ##FQX - ##Quedra: Version 0.6.5 - Made dprint on LOS break in FWT even more
// ##FQX - ##Quedra: cautious about accessing self.enemy fields.
// ##FQX - ##Quedra: Previous: Version 0.6.4 - Simplified LOS break interruption.
//=============================================================================

//============================================================================
// ##Quedra: FORWARD DECLARATIONS (within this file)
//============================================================================
void() MC_Mon_FireWeaponThink;

//============================================================================
// ##Quedra: MONSTER-SPECIFIC WEAPON CONFIGURATION CONSTANTS
//============================================================================

// --- Grunt M93R Configuration ---
#define GRUNT_M93R_WEAPON_ID                WEAPON_ID_M93R
#define GRUNT_M93R_MAG_CAPACITY             15
#define GRUNT_M93R_RELOAD_DURATION          2.0
#define GRUNT_M93R_ALLOWED_FIREMODES_MASK   (1 << FIRE_MODE_PRIMARY)

#define GRUNT_M93R_SHOTS_PER_ENGAGEMENT_MIN 2
#define GRUNT_M93R_SHOTS_PER_ENGAGEMENT_MAX 4

#define GRUNT_M93R_INTER_SHOT_DELAY_BASE    0.3
#define GRUNT_M93R_INTER_SHOT_DELAY_VARIABLE 0.1

#define GRUNT_M93R_SOUND_FIRE               "weapons/9mm_Pistol-1.wav"
#define GRUNT_M93R_ENGAGEMENT_COOLDOWN      1.5

//============================================================================
// ##Quedra: MONSTER WEAPON API FUNCTIONS
//============================================================================

void(entity mon, float wpn_id, float monster_mag_cap, float monster_allowed_modes_mask, float monster_reload_duration, void() mon_reload_anim_func) MC_Mon_InitializeWeaponProfile =
{
    mon.mc_weapon_id = wpn_id;
    mon.mc_weapon_mag_capacity = monster_mag_cap;
    mon.mc_current_ammo_in_mag = monster_mag_cap;
    mon.mc_weapon_allowed_firemodes = monster_allowed_modes_mask;
    mon.mc_weapon_reload_duration = monster_reload_duration;
    
    mon.mc_reload_finish_time = time;     
    mon.mc_is_reloading = FALSE;
    mon.mc_shots_to_fire_this_burst = 0;  

    mon.th_reload_anim_func = mon_reload_anim_func; 
    
    if (cvar("developer") > 0) {
        dprint(mon.netname, " mc_mon_weapons (v0.6.5) profile init for WID: ", ftos(wpn_id), "\n");
        dprint("  Mag: ", ftos(monster_mag_cap), ", Modes: ", ftos(monster_allowed_modes_mask), "\n");
        dprint("  ReloadT: ", ftos(monster_reload_duration), "\n");
    }
};

float(entity mon) MC_Mon_CheckAttackConditions =
{
    if (!mon.enemy || mon.enemy == world || mon.enemy.health <= 0) { 
        return FALSE;
    }
    if (!MC_Can_See(mon, mon.enemy, FALSE)) { 
        return FALSE;
    }
    return TRUE; 
};

float(entity mon) MC_Mon_CanFireSingleShot =
{
    if (mon.mc_current_ammo_in_mag <= 0) { 
        return FALSE;
    }
    if (mon.mc_is_reloading == TRUE) { 
        return FALSE;
    }
    if (time < mon.mc_reload_finish_time) { 
        return FALSE;
    }
    if (time < mon.attack_finished) { 
        return FALSE;
    }
    return TRUE; 
};

void(entity mon) MC_Mon_StartReload =
{
    if (mon.mc_is_reloading == TRUE) { 
        if (cvar("developer") > 0) { dprint(mon.netname, " mc_mon_weapons (v0.6.5) attempted to start reload, but already reloading.\n"); }
        return; 
    }
    mon.mc_is_reloading = TRUE;
    mon.mc_reload_finish_time = time + mon.mc_weapon_reload_duration; 
    
    if (mon.th_reload_anim_func != SUB_Null) { 
        MC_Set_Animation(mon, mon.th_reload_anim_func);
    } else {
        mon.think = MC_AI_Master_Think; 
        mon.nextthink = mon.mc_reload_finish_time; 
        if (cvar("developer") > 0) { dprint(mon.netname, " mc_mon_weapons (v0.6.5) started reload (no anim), finishes at ", ftos(mon.mc_reload_finish_time), "\n"); }
    }
    if (cvar("developer") > 0 && mon.th_reload_anim_func != SUB_Null) {
        dprint(mon.netname, " mc_mon_weapons (v0.6.5) started reload with animation, finishes at ", ftos(mon.mc_reload_finish_time), "\n");
    }
};

void(entity mon) MC_Mon_FinishReload =
{
    mon.mc_current_ammo_in_mag = mon.mc_weapon_mag_capacity;
    mon.mc_is_reloading = FALSE;
    if (cvar("developer") > 0) {
        dprint(mon.netname, " mc_mon_weapons (v0.6.5) finished reload logic. Mag: ", ftos(mon.mc_current_ammo_in_mag), "\n");
    }
    mon.think = MC_AI_Master_Think;
    mon.nextthink = time + 0.1;
};

void(entity mon) MC_Mon_ExecutePrimaryAttack =
{
    mon.mc_shots_to_fire_this_burst = GRUNT_M93R_SHOTS_PER_ENGAGEMENT_MIN + floor(random() * (GRUNT_M93R_SHOTS_PER_ENGAGEMENT_MAX - GRUNT_M93R_SHOTS_PER_ENGAGEMENT_MIN + 1));
    if (cvar("developer") > 0) {
        dprint(mon.netname, " mc_mon_weapons (v0.6.5) to fire engagement burst of ", ftos(mon.mc_shots_to_fire_this_burst), " shots.\n");
    }
    MC_Mon_FireWeaponThink(); 
};

void() MC_Mon_FireWeaponThink =
{
    local vector aim_dir, spread_vector;
    local float fire_delay;

    // Block 1: Handles burst completion or interruption (enemy invalid, self dead, or shots run out from LOS break)
    if (self.mc_shots_to_fire_this_burst <= 0 || !self.enemy || self.enemy == world || self.enemy.health <= 0 || self.health <= 0) { 
        self.attack_finished = time + 0.5; 
        self.mc_attack_finished_time = time + GRUNT_M93R_ENGAGEMENT_COOLDOWN; 

        if (self.health > 0) { 
            if (cvar("developer") > 0) {
                local string enemy_info_str;
                if (!self.enemy) { 
                    enemy_info_str = "is NULL_ENTITY";
                } else if (self.enemy == world) {
                    enemy_info_str = "is world_entity";
                } else { // self.enemy is not NULL and not world
                    if (self.enemy.classname != string_null && self.enemy.classname != "") {
                        enemy_info_str = strcat("is class '", self.enemy.classname, "'");
                        if (self.enemy.flags & FL_CLIENT && self.enemy.netname != string_null && self.enemy.netname != "") {
                            enemy_info_str = strcat(enemy_info_str, " netname '", self.enemy.netname, "'");
                        }
                        enemy_info_str = strcat(enemy_info_str, " (H:", ftos(self.enemy.health), ")");
                    } else { // classname is null/empty - implies bad/freed entity
                        enemy_info_str = "is Non-world, Non-null entity with NO CLASSNAME (SUSPECT FREED/INVALID)";
                    }
                }
                dprint(self.netname, " mc_mon_weapons (v0.6.5) FWT_EndBurstLogic: Enemy ", enemy_info_str, ". Setting think to MC_AI_Master_Think.\n");
            }
            self.think = MC_AI_Master_Think;
            self.nextthink = time + 0.1; 
        }
        // Log if burst was cut short and monster is still alive (original_shots_to_fire might be needed for perfect log)
        if (cvar("developer") > 0 && self.mc_shots_to_fire_this_burst > 0 && self.health > 0) { 
            // This dprint might be confusing now since we set mc_shots_to_fire_this_burst = 0 right before calling self.think()
            // It's better to indicate an interruption path was taken.
        }
        self.mc_shots_to_fire_this_burst = 0; // Ensure it's zeroed
        return; 
    }

    // Block 2: Enemy validity check (somewhat redundant with above but an early out if state changed rapidly)
    if (!self.enemy || self.enemy == world || self.enemy.health <= 0) { 
        if(cvar("developer") > 0) dprint(self.netname, " mc_mon_weapons (v0.6.5) FireWeaponThink: Enemy became invalid before LOS/Fire. Interrupting.\n");
        self.mc_shots_to_fire_this_burst = 0; // Mark burst as done
        // Directly transition to AI logic
        self.mc_attack_finished_time = time + GRUNT_M93R_ENGAGEMENT_COOLDOWN;
        self.attack_finished = time + 0.5; 
        if(self.health > 0) { self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }
        return;
    }
    
    // Block 3: LOS Check for this specific shot
    if (!visible(self.enemy)) {
        if(cvar("developer") > 0) {
            local string enemy_netname_safe = "[ENEMY_NETNAME_UNSAFE_OR_NULL]";
            // Attempt to get netname safely only if enemy seems valid enough for it
            if (self.enemy && self.enemy != world && self.enemy.classname != string_null && self.enemy.classname != "") {
                if (self.enemy.flags & FL_CLIENT && self.enemy.netname != string_null && self.enemy.netname != "") {
                    enemy_netname_safe = self.enemy.netname;
                } else {
                    enemy_netname_safe = strcat("[NonClient:", self.enemy.classname, "]");
                }
            } else if (self.enemy == world) {
                 enemy_netname_safe = "[world]";
            } else if (!self.enemy) {
                 enemy_netname_safe = "[null_enemy]";
            }
            dprint(self.netname, " mc_mon_weapons (v0.6.5) FireWeaponThink: Target '", enemy_netname_safe ,"' no longer visible. Interrupting burst.\n");
        }
        self.mc_shots_to_fire_this_burst = 0; 
        self.mc_attack_finished_time = time + GRUNT_M93R_ENGAGEMENT_COOLDOWN;
        self.attack_finished = time + 0.5;
        if(self.health > 0) { self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }
        return; 
    }
    
    // Block 4: Check if can fire (ammo, reload, inter-shot cooldown)
    if (!MC_Mon_CanFireSingleShot(self)) { 
        if (self.mc_current_ammo_in_mag <= 0 && self.mc_is_reloading == FALSE) { 
            if (cvar("developer") > 0) { dprint(self.netname, " mc_mon_weapons (v0.6.5) needs reload during burst. Mag: ", ftos(self.mc_current_ammo_in_mag),"\n"); }
            MC_Mon_StartReload(self); 
        } else {
             if (cvar("developer") > 0) { dprint(self.netname, " mc_mon_weapons (v0.6.5) cannot fire shot during burst (reloading/cooldown).\n"); }
        }
        self.mc_attack_finished_time = time + GRUNT_M93R_ENGAGEMENT_COOLDOWN;
        self.think = MC_AI_Master_Think; 
        self.nextthink = time + 0.1; 
        self.mc_shots_to_fire_this_burst = 0; 
        return; 
    }

    // Block 5: Fire the shot
    self.mc_current_ammo_in_mag = self.mc_current_ammo_in_mag - 1; 
    
    if (self.mc_weapon_id == WEAPON_ID_M93R) { 
        sound(self, CHAN_WEAPON, GRUNT_M93R_SOUND_FIRE, 1, ATTN_NORM); 
        self.effects = self.effects | EF_MUZZLEFLASH; 

        MC_Face_Target(self, self.enemy); 
        makevectors(self.angles); 
        aim_dir = normalize(self.enemy.origin - (self.origin + self.view_ofs)); 
        
        spread_vector = '0.03 0.03 0'; 
        FireBullets(1, aim_dir, spread_vector); 
    } else {
        if (cvar("developer") > 0) { dprint("MC_Mon_FireWeaponThink (v0.6.5): Unhandled weapon ID for firing effects: ", ftos(self.mc_weapon_id), "\n"); }
    }
    
    if (cvar("developer") > 0) {
        dprint(self.netname, " mc_mon_weapons (v0.6.5) fired shot. Mag: ", ftos(self.mc_current_ammo_in_mag), ", Shots left in burst: ", ftos(self.mc_shots_to_fire_this_burst -1), "\n");
    }
    
    // Block 6: Decrement shots for this burst and set up next shot or end burst
    self.mc_shots_to_fire_this_burst = self.mc_shots_to_fire_this_burst - 1; 
    self.attack_finished = time + GRUNT_M93R_INTER_SHOT_DELAY_BASE; 

    if (self.mc_shots_to_fire_this_burst > 0) { 
        fire_delay = GRUNT_M93R_INTER_SHOT_DELAY_BASE + (random() * GRUNT_M93R_INTER_SHOT_DELAY_VARIABLE); 
        self.think = MC_Mon_FireWeaponThink; 
        self.nextthink = time + fire_delay; 
    } else { // Burst is finished (all shots fired)
        self.mc_attack_finished_time = time + GRUNT_M93R_ENGAGEMENT_COOLDOWN; 
        if (cvar("developer") > 0) {
            local string enemy_status_str_norm;
            if (!self.enemy) { 
                enemy_status_str_norm = "NULL_ENTITY"; 
            } else if (self.enemy == world) { 
                enemy_status_str_norm = "world_entity"; 
            } else { 
                if (self.enemy.classname != string_null && self.enemy.classname != "") {
                    enemy_status_str_norm = strcat("is class '", self.enemy.classname, "'");
                    if (self.enemy.flags & FL_CLIENT && self.enemy.netname != string_null && self.enemy.netname != "") {
                         enemy_status_str_norm = strcat(enemy_status_str_norm, " netname '", self.enemy.netname, "'");
                    }
                    enemy_status_str_norm = strcat(enemy_status_str_norm, " (H:", ftos(self.enemy.health), ")");
                } else {
                     enemy_status_str_norm = "is Non-world, Non-null entity with no classname (possibly invalid)";
                }
            }
            dprint(self.netname, " mc_mon_weapons (v0.6.5) FWT_EndBurst_Norm: Enemy ", enemy_status_str_norm, ". Setting think to MC_AI_Master_Think.\n");
        }
        self.think = MC_AI_Master_Think; 
        self.nextthink = time + 0.1; 
        if (cvar("developer") > 0) {
            dprint(self.netname, " mc_mon_weapons (v0.6.5) engagement burst finished logic.\n");
        }
    }
};
//=============================================================================
// mc_mon_weapons.qc - FQX Mod - Monster Core: Monster Weapon Adaption Layer
// ##Quedra: Version 0.6.5 - End of File
//=============================================================================