//=============================================================================
// grunt.qc - FQX Mod - Grunt Monster (Monster Core Implementation)
// ##FQX - ##Quedra: Version 2.21.0
// ##Quedra: Integrated mc_debug_prints_enabled toggle for all dprint statements.
// ##Quedra: Previous: Version 2.20.2 - Revised army_atk animation handling. 
//=============================================================================

//============================================================================
// ##Quedra: GRUNT MODEL AND FRAME DEFINITIONS (from QRRQC-grunt.qc)
//============================================================================
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 
$frame death1 death2 death3 death4 death5 death6 death7 death8 death9 death10 
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8 deathc9 deathc10 deathc11 
$frame load1 load2 load3 load4 load5 load6 load7 load8 load9 load10 load11 
$frame pain1 pain2 pain3 pain4 pain5 pain6 
$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10 painb11 painb12 painb13 painb14 
$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8 painc9 painc10 painc11 painc12 painc13 
$frame run1 run2 run3 run4 run5 run6 run7 run8 
$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9 
$frame prowl_1 prowl_2 prowl_3 prowl_4 prowl_5 prowl_6 prowl_7 prowl_8 prowl_9 prowl_10 prowl_11 prowl_12 prowl_13 prowl_14 prowl_15 prowl_16 prowl_17 prowl_18 prowl_19 prowl_20 prowl_21 prowl_22 prowl_23 prowl_24 

//============================================================================
// ##Quedra: MONSTER-SPECIFIC FORWARD DECLARATIONS (within this file)
//============================================================================
void() army_stand1; void() army_stand2; void() army_stand3; void() army_stand4; void() army_stand5; void() army_stand6; void() army_stand7; void() army_stand8; // 
void() army_walk1; void() army_walk2; void() army_walk3; void() army_walk4; void() army_walk5; void() army_walk6; void() army_walk7; void() army_walk8; void() army_walk9; void() army_walk10; void() army_walk11; void() army_walk12; void() army_walk13; void() army_walk14; void() army_walk15; void() army_walk16; void() army_walk17; void() army_walk18; void() army_walk19; void() army_walk20; void() army_walk21; void() army_walk22; void() army_walk23; void() army_walk24; // 
void() army_run1; void() army_run2; void() army_run3; void() army_run4; void() army_run5; void() army_run6; void() army_run7; void() army_run8; // 

void() army_atk1; // 
void() army_atk_anim_2; void() army_atk_anim_3; void() army_atk_anim_4; void() army_atk_anim_5; // 
void() army_atk_anim_6; void() army_atk_anim_7; void() army_atk_anim_8; void() army_atk_anim_9; // 
void() army_atk_anim_done; // 

void() army_pain1; void() army_pain2; void() army_pain3; void() army_pain4; void() army_pain5; void() army_pain6; // 
void() army_pain_end; // 
void() army_die1; void() army_die2; void() army_die3; void() army_die4; void() army_die5; void() army_die6; void() army_die7; void() army_die8; void() army_die9; void() army_die10; // 
void() army_dead; // 

void() grunt_reload_anim_start; // 
void() grunt_load_2; void() grunt_load_3; void() grunt_load_4; void() grunt_load_5; void() grunt_load_6; // 
void() grunt_load_7; void() grunt_load_8; void() grunt_load_9; void() grunt_load_10; void() grunt_load_11; // 
void() grunt_reload_wait_for_finish; // 

void(entity attacker, float damage) grunt_pain; void() grunt_die; // 
float() grunt_check_attack; // 
void() MC_Precache_Grunt; // 
float(entity mon) infight; // 

//============================================================================
// ##Quedra: GRUNT-SPECIFIC WEAPON CONSTANTS
//============================================================================
float GRUNT_WEAPONID_PRIMARY            = WEAPON_ID_M93R; // 
#define GRUNT_MAX_ENGAGEMENT_RANGE 500 // 
#define GRUNT_MIN_ENGAGEMENT_RANGE 0 // 

//============================================================================
// ##Quedra: MONSTER CORE AI UTILITY FUNCTIONS
//============================================================================
float(entity mon) infight = // 
{
    local vector dir_to_enemy; // 
    local float dot_product; // 
    if (!mon || !mon.enemy || mon.enemy == world) { return FALSE; } // 
    dir_to_enemy = normalize(mon.enemy.origin - mon.origin); // 
    makevectors(mon.angles); // 
    dot_product = v_forward * dir_to_enemy; // 
    if (dot_product < 0.3) { return FALSE; } // 
    return TRUE; // 
};

//============================================================================
// ##Quedra: GRUNT ANIMATION FUNCTIONS
//============================================================================

// --- Stand Animation ---
void() army_stand1 = { self.frame = $stand1; self.think = army_stand2; self.nextthink = time + 0.2; }; // 
void() army_stand2 = { self.frame = $stand2; self.think = army_stand3; self.nextthink = time + 0.2; }; // 
void() army_stand3 = { self.frame = $stand3; self.think = army_stand4; self.nextthink = time + 0.2; }; // 
void() army_stand4 = { self.frame = $stand4; self.think = army_stand5; self.nextthink = time + 0.2; }; // 
void() army_stand5 = { self.frame = $stand5; self.think = army_stand6; self.nextthink = time + 0.2; }; // 
void() army_stand6 = { self.frame = $stand6; self.think = army_stand7; self.nextthink = time + 0.2; }; // 
void() army_stand7 = { self.frame = $stand7; self.think = army_stand8; self.nextthink = time + 0.2; }; // 
void() army_stand8 = { self.frame = $stand8; self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }; // 

// --- Walk Animation ---
void() army_walk1  = { self.frame = $prowl_1; if (random() < 0.2) { sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE); } MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk2;  self.nextthink = time + 0.1; }; // 
void() army_walk2  = { self.frame = $prowl_2;  MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk3;  self.nextthink = time + 0.1; }; // 
void() army_walk3  = { self.frame = $prowl_3;  MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk4;  self.nextthink = time + 0.1; }; // 
void() army_walk4  = { self.frame = $prowl_4;  MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk5;  self.nextthink = time + 0.1; }; // 
void() army_walk5  = { self.frame = $prowl_5;  MC_Attempt_PathToGoal(self, self.goalentity, 2); self.think = army_walk6;  self.nextthink = time + 0.1; }; // 
void() army_walk6  = { self.frame = $prowl_6;  MC_Attempt_PathToGoal(self, self.goalentity, 3); self.think = army_walk7;  self.nextthink = time + 0.1; }; // 
void() army_walk7  = { self.frame = $prowl_7;  MC_Attempt_PathToGoal(self, self.goalentity, 4); self.think = army_walk8;  self.nextthink = time + 0.1; }; // 
void() army_walk8  = { self.frame = $prowl_8;  MC_Attempt_PathToGoal(self, self.goalentity, 4); self.think = army_walk9;  self.nextthink = time + 0.1; }; // 
void() army_walk9  = { self.frame = $prowl_9;  MC_Attempt_PathToGoal(self, self.goalentity, 2); self.think = army_walk10; self.nextthink = time + 0.1; }; // 
void() army_walk10 = { self.frame = $prowl_10; MC_Attempt_PathToGoal(self, self.goalentity, 2); self.think = army_walk11; self.nextthink = time + 0.1; }; // 
void() army_walk11 = { self.frame = $prowl_11; MC_Attempt_PathToGoal(self, self.goalentity, 2); self.think = army_walk12; self.nextthink = time + 0.1; }; // 
void() army_walk12 = { self.frame = $prowl_12; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk13; self.nextthink = time + 0.1; }; // 
void() army_walk13 = { self.frame = $prowl_13; MC_Attempt_PathToGoal(self, self.goalentity, 0); self.think = army_walk14; self.nextthink = time + 0.1; }; // 
void() army_walk14 = { self.frame = $prowl_14; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk15; self.nextthink = time + 0.1; }; // 
void() army_walk15 = { self.frame = $prowl_15; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk16; self.nextthink = time + 0.1; }; // 
void() army_walk16 = { self.frame = $prowl_16; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk17; self.nextthink = time + 0.1; }; // 
void() army_walk17 = { self.frame = $prowl_17; MC_Attempt_PathToGoal(self, self.goalentity, 3); self.think = army_walk18; self.nextthink = time + 0.1; }; // 
void() army_walk18 = { self.frame = $prowl_18; MC_Attempt_PathToGoal(self, self.goalentity, 3); self.think = army_walk19; self.nextthink = time + 0.1; }; // 
void() army_walk19 = { self.frame = $prowl_19; MC_Attempt_PathToGoal(self, self.goalentity, 3); self.think = army_walk20; self.nextthink = time + 0.1; }; // 
void() army_walk20 = { self.frame = $prowl_20; MC_Attempt_PathToGoal(self, self.goalentity, 3); self.think = army_walk21; self.nextthink = time + 0.1; }; // 
void() army_walk21 = { self.frame = $prowl_21; MC_Attempt_PathToGoal(self, self.goalentity, 2); self.think = army_walk22; self.nextthink = time + 0.1; }; // 
void() army_walk22 = { self.frame = $prowl_22; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk23; self.nextthink = time + 0.1; }; // 
void() army_walk23 = { self.frame = $prowl_23; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = army_walk24; self.nextthink = time + 0.1; }; // 
void() army_walk24 = { self.frame = $prowl_24; MC_Attempt_PathToGoal(self, self.goalentity, 1); self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }; // 

// --- Run Animation Chain ---
void() GruntRunFrameLogic = { // 
    local string current_think_name_cache; // 
    if (self && self.think != SUB_Null) { current_think_name_cache = "ACTIVE_THINK_FN_NAME_UNAVAILABLE"; } else { current_think_name_cache = "INVALID_THINK_CTX"; } // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // 
        if (self && self != world && self.goalentity) { dprint(self.netname, " ", current_think_name_cache," (v2.20.2): PRE MC_Attempt_PathToGoal. Goal: ", self.goalentity.netname, "\n"); } // 
        else if (self && self != world) { dprint(self.netname, " ", current_think_name_cache," (v2.20.2): PRE MC_Attempt_PathToGoal. GoalEnt is world or null.\n"); } // 
        else { dprint("DBG_GRFL_PRE_PATH: ", current_think_name_cache," (v2.20.2): PRE MC_Attempt_PathToGoal. self (not netname) is world or NULL.\n"); } // 
    }
    if (self && self != world) { // 
        MC_Attempt_PathToGoal(self, self.goalentity, 11); // 
        if (!(self.flags & FL_ONGROUND) && self.movetype != MOVETYPE_FLY && self.movetype != MOVETYPE_NOCLIP) { // 
            if (droptofloor() && cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { dprint(self.netname, " GruntRunFrameLogic (v2.20.2): Dropped to floor.\n"); } // 
        }
    } else { 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // 
            if (self == world) { dprint("DBG_GRFL (v2.20.2): SKIPPED MC_Attempt_PathToGoal: self is 'world' entity.\n"); } // 
            else { dprint("DBG_GRFL (v2.20.2): SKIPPED MC_Attempt_PathToGoal: self is NULL entity.\n"); } // 
        }
        return; // 
    }
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {  // 
        local string post_think_name_cache; // 
        if (self && self.think != SUB_Null) { post_think_name_cache = "ACTIVE_THINK_FN_NAME_UNAVAILABLE_POST"; } else { post_think_name_cache = "INVALID_THINK_CTX_POST"; } // 
        if (!self) { dprint(post_think_name_cache, " (v2.20.2): POST MC_Attempt_PathToGoal. self IS NULL.\n"); } // 
        else if (self == world) { dprint("WORLD_ENTITY ", post_think_name_cache, " (v2.20.2): POST MC_Attempt_PathToGoal. self IS WORLD.\n"); } // 
        else { dprint(self.netname, " ", post_think_name_cache, " (v2.20.2): POST MC_Attempt_PathToGoal. Self (", self.classname, ") OK.\n"); } // 
        if (!self || self == world) { // 
            local string critical_think_name; // 
            if (self && self != world && self.think != SUB_Null) critical_think_name = "ACTIVE_THINK_FN_NAME_UNAVAILABLE_CRIT"; else if (self == world) critical_think_name = "WORLD_CTX_CRIT";  else critical_think_name = "NULL_SELF_CTX_CRIT"; // 
            dprint(critical_think_name," (v2.20.2): CRITICAL - self invalid AFTER MC_Attempt_PathToGoal! Halting chain.\n"); // 
            if (self && self != world) { self.think = SUB_Null; self.nextthink = -1; } // 
            return; // 
        }
    }
};
void() army_run1 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run1 (v2.20.2): --- ENTRY --- \n"); self.frame = $run1; if (random() < 0.2) { sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE); } GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run2;  self.nextthink = time + 0.1; } }; // 
void() army_run2 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run2 (v2.20.2): --- ENTRY --- \n"); self.frame = $run2; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run3;  self.nextthink = time + 0.1; } }; // 
void() army_run3 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run3 (v2.20.2): --- ENTRY --- \n"); self.frame = $run3; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run4;  self.nextthink = time + 0.1; } }; // 
void() army_run4 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run4 (v2.20.2): --- ENTRY --- \n"); self.frame = $run4; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run5;  self.nextthink = time + 0.1; } }; // 
void() army_run5 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run5 (v2.20.2): --- ENTRY --- \n"); self.frame = $run5; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run6;  self.nextthink = time + 0.1; } }; // 
void() army_run6 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run6 (v2.20.2): --- ENTRY --- \n"); self.frame = $run6; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run7;  self.nextthink = time + 0.1; } }; // 
void() army_run7 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run7 (v2.20.2): --- ENTRY --- \n"); self.frame = $run7; GruntRunFrameLogic(); if (self.think != SUB_Null) { self.think = army_run8;  self.nextthink = time + 0.1; } }; // 
void() army_run8 = { if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run8 (v2.20.2): --- ENTRY --- \n"); self.frame = $run8; GruntRunFrameLogic(); if (self.think != SUB_Null) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_run8 (v2.20.2): End of chain, scheduling MC_AI_Master_Think.\n"); self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; } }; // 

// --- Attack Sequence ---
void() army_atk1 = { // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_atk1 (v2.20.2): --- Visual Attack Sequence Start --- \n"); // 
    MC_Face_Target(self, self.enemy);  // 
    MC_Mon_ExecutePrimaryAttack(self);  // 
    self.frame = $shoot1; // 
    self.nextthink = time + 0.1; // 
    self.think = army_atk_anim_2; // 
};

void() army_atk_anim_2 = { self.frame = $shoot2; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_3; }; // 
void() army_atk_anim_3 = { self.frame = $shoot3; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_4; }; // 
void() army_atk_anim_4 = { self.frame = $shoot4; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_5; }; // 
void() army_atk_anim_5 = { self.frame = $shoot5; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_6; }; // 
void() army_atk_anim_6 = { self.frame = $shoot6; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_7; }; // 
void() army_atk_anim_7 = { self.frame = $shoot7; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_8; }; // 
void() army_atk_anim_8 = { self.frame = $shoot8; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1; self.think = army_atk_anim_9; }; // 
void() army_atk_anim_9 = { self.frame = $shoot9; MC_Face_Target(self, self.enemy); self.nextthink = time + 0.1;  self.think = army_atk_anim_done; }; // 
void() army_atk_anim_done = { // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_atk_anim_done (v2.20.2): Visual attack animation frames complete.\n"); // 
    if (self.think == army_atk_anim_done) { // 
         if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " army_atk_anim_done (v2.20.2): Fallback - Think was self. Setting to MC_AI_Master_Think.\n"); // 
         self.think = MC_AI_Master_Think; self.nextthink = time + 0.1;  // 
    }
};

// --- Pain ---
void() army_pain_end = { self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }; // 
void() army_pain1 = { self.frame = $pain1; self.think = army_pain2; self.nextthink = time + 0.1; }; // 
void() army_pain2 = { self.frame = $pain2; self.think = army_pain3; self.nextthink = time + 0.1; }; // 
void() army_pain3 = { self.frame = $pain3; self.think = army_pain4; self.nextthink = time + 0.1; }; // 
void() army_pain4 = { self.frame = $pain4; self.think = army_pain5; self.nextthink = time + 0.1; }; // 
void() army_pain5 = { self.frame = $pain5; self.think = army_pain6; self.nextthink = time + 0.1; }; // 
void() army_pain6 = { self.frame = $pain6; self.think = army_pain_end; self.nextthink = time + 0.1; }; // 

// --- Death ---
void() army_dead = { self.deadflag = DEAD_DEAD; self.think = SUB_Null; self.nextthink = -1; }; // 
void() army_die1  = { self.frame = $death1;  self.think = army_die2;  self.nextthink = time + 0.1; }; // 
void() army_die2  = { self.frame = $death2;  self.think = army_die3;  self.nextthink = time + 0.1; }; // 
void() army_die3  = { self.frame = $death3;  self.solid = SOLID_NOT; if (self.mc_item_drop_field_name == "ammo_shells" && self.ammo_shells > 0) { DropBackpack(); } else if (self.mc_item_drop_field_name == "ammo_nails" && self.ammo_nails > 0) { DropBackpack(); } else if (self.mc_item_drop_field_name == "ammo_rockets" && self.ammo_rockets > 0) { DropBackpack(); } else if (self.mc_item_drop_field_name == "ammo_cells" && self.ammo_cells > 0) { DropBackpack(); } self.think = army_die4; self.nextthink = time + 0.1; }; // 
void() army_die4  = { self.frame = $death4;  self.think = army_die5;  self.nextthink = time + 0.1; }; // 
void() army_die5  = { self.frame = $death5;  self.think = army_die6;  self.nextthink = time + 0.1; }; // 
void() army_die6  = { self.frame = $death6;  self.think = army_die7;  self.nextthink = time + 0.1; }; // 
void() army_die7  = { self.frame = $death7;  self.think = army_die8;  self.nextthink = time + 0.1; }; // 
void() army_die8  = { self.frame = $death8;  self.think = army_die9;  self.nextthink = time + 0.1; }; // 
void() army_die9  = { self.frame = $death9;  self.think = army_die10; self.nextthink = time + 0.1; }; // 
void() army_die10 = { self.frame = $death10; self.think = army_dead;  self.nextthink = time + 0.1; }; // 

// --- Reload Animation Sequence ---
void() grunt_reload_anim_start = { // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_reload_anim_start (v2.20.2): Begin reload animation.\n"); // 
    self.frame = $load1; // 
    self.nextthink = time + 0.15;  // 
    self.think = grunt_load_2; // 
};
void() grunt_load_2  = { self.frame = $load2;  self.nextthink = time + 0.15; self.think = grunt_load_3; }; // 
void() grunt_load_3  = { self.frame = $load3;  self.nextthink = time + 0.15; self.think = grunt_load_4; }; // 
void() grunt_load_4  = { self.frame = $load4;  self.nextthink = time + 0.15; self.think = grunt_load_5; }; // 
void() grunt_load_5  = { self.frame = $load5;  self.nextthink = time + 0.15; self.think = grunt_load_6; }; // 
void() grunt_load_6  = { self.frame = $load6;  self.nextthink = time + 0.15; self.think = grunt_load_7; }; // 
void() grunt_load_7  = { self.frame = $load7;  self.nextthink = time + 0.15; self.think = grunt_load_8; }; // 
void() grunt_load_8  = { self.frame = $load8;  self.nextthink = time + 0.15; self.think = grunt_load_9; }; // 
void() grunt_load_9  = { self.frame = $load9;  self.nextthink = time + 0.15; self.think = grunt_load_10; }; // 
void() grunt_load_10 = { self.frame = $load10; self.nextthink = time + 0.15; self.think = grunt_load_11; }; // 
void() grunt_load_11 = { self.frame = $load11; self.nextthink = time + 0.1;  self.think = grunt_reload_wait_for_finish; }; // 
void() grunt_reload_wait_for_finish = { // 
    if (time >= self.mc_reload_finish_time) {  // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_reload_wait_for_finish (v2.20.2): Reload duration met. Finishing reload.\n"); // 
        MC_Mon_FinishReload(self);  // 
    } else {
        self.frame = $load11;  // 
        self.nextthink = time + 0.1; // 
        self.think = grunt_reload_wait_for_finish; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_reload_wait_for_finish (v2.20.2): Holding last reload frame, waiting. Time: ", ftos(time), ", Finish: ", ftos(self.mc_reload_finish_time) ,"\n"); // 
    }
};

// --- Pain and Death Handlers ---
void(entity attacker, float damage) grunt_pain = { MC_Pain_Handler(self, attacker, damage, army_pain1, "soldier/pain1.wav", 5, 0.5, 0.6); }; // 
void() grunt_die = { MC_Death_Handler(self, self.dmg_inflictor, army_die1, "soldier/death1.wav", "player/udeath.wav", SUB_Null, SUB_Null); }; // 

// --- Grunt Check Attack ---
float() grunt_check_attack = // 
{
    if (!self.enemy || self.enemy == world || self.enemy.health <= 0) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE && self.enemy) dprint(self.netname, " grunt_check_attack (v2.20.2): No valid enemy (null or health<=0: ", ftos(self.enemy.health) ,").\n"); else if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): No valid enemy (null).\n"); return FALSE; } // 
    if (!visible(self.enemy)) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Enemy '", self.enemy.netname, "' not visible.\n"); return FALSE; } // 
    local float dist_to_enemy; dist_to_enemy = vlen(self.origin - self.enemy.origin); // 
    if (dist_to_enemy > GRUNT_MAX_ENGAGEMENT_RANGE) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Enemy '", self.enemy.netname, "' out of max range (", ftos(dist_to_enemy), " > ", ftos(GRUNT_MAX_ENGAGEMENT_RANGE) ,").\n"); return FALSE; } // 
    if (dist_to_enemy < GRUNT_MIN_ENGAGEMENT_RANGE) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Enemy '", self.enemy.netname, "' too close (", ftos(dist_to_enemy), " < ", ftos(GRUNT_MIN_ENGAGEMENT_RANGE) ,").\n"); return FALSE; } // 
    if (!infight(self)) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Enemy '", self.enemy.netname, "' not in tactical cone (infight() failed).\n"); return FALSE; } // 
    if (self.mc_is_reloading == TRUE) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Currently reloading.\n"); return FALSE;  } // 
    if (time < self.mc_attack_finished_time) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): Attack engagement on cooldown. Until: ", ftos(self.mc_attack_finished_time), ", Now: ", ftos(time) ,".\n"); return FALSE; } // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " grunt_check_attack (v2.20.2): All checks PASSED for enemy '", self.enemy.netname, "'. Returning TRUE.\n"); // 
    return TRUE; // 
};

// --- Precache ---
void() MC_Precache_Grunt = // 
{
    precache_model("progs/soldier.mdl"); // 
    precache_model("progs/h_guard.mdl"); // 
    precache_sound("soldier/death1.wav"); precache_sound("soldier/idle.wav"); // 
    precache_sound("soldier/pain1.wav"); precache_sound("soldier/pain2.wav"); precache_sound("soldier/sattck1.wav"); precache_sound("soldier/sight1.wav"); // 
    precache_sound("player/udeath.wav"); // 
    precache_sound(GRUNT_M93R_SOUND_FIRE); // 
};

// --- Spawn Function ---
void() monster_army = // 
{
    MC_Precache_Grunt(); // 
    MC_Initialize_Monster( self, // 
        30, "progs/soldier.mdl", '-16 -16 -24', '16 16 40', // 
        MOVETYPE_STEP, SOLID_SLIDEBOX, FL_MONSTER, // 
        army_stand1, army_walk1, army_run1, grunt_pain, grunt_die, // 
        army_atk1, army_atk1,  // 
        "soldier/sight1.wav", "soldier/pain1.wav", "soldier/death1.wav", "soldier/idle.wav", // 
        20, '0 0 25', MC_AI_Master_Think, // 
        99999999, TRUE, CS_RANGED, // 
        "$qc_grunt", "$qc_ks_grunt", // 
        -35, "progs/h_guard.mdl", // 
        "ammo_shells", 5 // 
    );
    MC_Mon_InitializeWeaponProfile( self, // 
        GRUNT_M93R_WEAPON_ID,  // 
        GRUNT_M93R_MAG_CAPACITY,  // 
        GRUNT_M93R_ALLOWED_FIREMODES_MASK,  // 
        GRUNT_M93R_RELOAD_DURATION, // 
        grunt_reload_anim_start // 
    );
    self.mc_check_attack_func = grunt_check_attack; // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) // 
    {
        dprint(self.netname, " monster_army (grunt.qc v2.21.0): Assigned self.mc_check_attack_func to grunt_check_attack.\n"); // 
        dprint(self.netname, " monster_army (grunt.qc v2.21.0): Initial think will be MC_AI_Master_Think. self.th_run is local army_run1 chain.\n"); // 
    }
    self.use = monster_use; // 
};
//=============================================================================
// grunt.qc - FQX Mod - Grunt Monster (Monster Core Implementation)
// ##FQX - ##Quedra: Version 2.21.0
//=============================================================================