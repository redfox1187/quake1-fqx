//=============================================================================
// mc_bh_ai.qc - FQX Mod - Monster Core Behaviors: AI System
// ##FQX - ##Quedra: Version 2.16.0
// ##Quedra: Integrated mc_debug_prints_enabled toggle for all dprint statements.
// ##FQX - ##Quedra: Previous: Version 2.15 - Added detailed enemy state logging. 
//=============================================================================

//============================================================================
// ##FQXnote: AI STATE DEFINITIONS (from mc_defs.qc) 
//============================================================================
// #define MC_AI_STATE_SPAWN       0 // 
// #define MC_AI_STATE_IDLE        1 // 
// #define MC_AI_STATE_PURSUE      2 // 
// #define MC_AI_STATE_COMBAT      3 // 
// #define MC_AI_STATE_PAIN        4 // 
// #define MC_AI_STATE_DEAD        5 // 
// #define MC_AI_STATE_CUSTOM      6 // 

#define AS_STRAIGHT     1 // 
#define AS_SLIDING      2 // 
#define AS_MELEE        3 // 
#define AS_MISSILE      4 // 

//============================================================================
// ##FQXnote: FORWARD DECLARATIONS  
//============================================================================
void() MC_Grunt_RunFrame_Test; // 

//============================================================================
// ##FQXnote: Test Function 
//============================================================================
void() MC_Grunt_RunFrame_Test = // 
{
    if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) // 
    {
        dprint(self.netname, " MC_Grunt_RunFrame_Test (mc_bh_ai.qc v2.16.0): --- Minimal th_run EXECUTED! --- Self is: ", self.netname, ", Class: ", self.classname, "\n"); // 
    }
    self.think = SUB_Null;  // 
    self.nextthink = -1; // 
};

//============================================================================
// ##FQXnote: CORE AI THINKING FUNCTIONS 
//============================================================================

/* ##FQX - ##Quedra: MC_AI_Think_Idle */
void(entity p_mon) MC_AI_Think_Idle = // 
{
    local entity e_potential_target; // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // 
        dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Entry. AI State: ", ftos(p_mon.mc_ai_state), ", Enemy: ", p_mon.enemy.netname, "\n"); // 
        dprint("  Idle GroundEnt: ", p_mon.groundentity.netname, " (valid: ", ftos(p_mon.groundentity != world), "), FL_ONGROUND: ", ftos(p_mon.flags & FL_ONGROUND), "\n"); // 
    }
    e_potential_target = MC_Find_Best_Target(p_mon, FALSE); // 

    if (e_potential_target != world && e_potential_target.health > 0) { // 
        if (p_mon.enemy != e_potential_target || p_mon.mc_has_played_sight_sound == FALSE) { // 
            if (p_mon.noise != string_null) {  // 
                sound(p_mon, CHAN_VOICE, p_mon.noise, 1, ATTN_NORM); // 
                if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Played sight sound '", p_mon.noise, "' for ", e_potential_target.netname, "\n"); // 
            }
            p_mon.mc_has_played_sight_sound = TRUE; // 
        }
        p_mon.enemy = e_potential_target; // 
        p_mon.mc_ai_state = MC_AI_STATE_PURSUE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Target FOUND: ", e_potential_target.netname, ". Setting PURSUE. Scheduling MC_AI_Master_Think.\n"); // 
        p_mon.think = MC_AI_Master_Think; // 
        p_mon.nextthink = time + 0.1; // 
        return; // 
    }

    if (p_mon.enemy != world) {  // 
        p_mon.enemy = world; // 
        p_mon.mc_has_played_sight_sound = FALSE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Lost previous enemy. Reset sight sound flag.\n"); // 
        if (p_mon.movetarget != world && p_mon.movetarget.classname == "path_corner") { p_mon.goalentity = p_mon.movetarget; }  // 
        else { p_mon.goalentity = world; } // 
    }

    if (time > p_mon.pausetime && p_mon.movetarget != world) { // 
        p_mon.goalentity = p_mon.movetarget; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Pathing. Goal: ", p_mon.goalentity.targetname, ". Anim: th_walk.\n"); // 
        if (p_mon.th_walk != SUB_Null) { MC_Set_Animation(p_mon, p_mon.th_walk); }  // 
        else { p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; } // 
    } else {
        p_mon.goalentity = world; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Idle (mc_bh_ai.qc v2.16.0): Standing. Anim: th_stand.\n"); // 
        if (p_mon.th_stand != SUB_Null) { MC_Set_Animation(p_mon, p_mon.th_stand); }  // 
        else { p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; } // 
    }
};

/* ##FQX - ##Quedra: MC_AI_Think_Pursuit */
void(entity p_mon) MC_AI_Think_Pursuit = // 
{
    local float f_can_attack; // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // 
        local string enemy_status_str_pursuit; // 
        if (!p_mon.enemy) { enemy_status_str_pursuit = "NULL"; } // 
        else if (p_mon.enemy == world) { enemy_status_str_pursuit = "world_entity"; } // 
        else { enemy_status_str_pursuit = strcat(p_mon.enemy.netname, " (H:", ftos(p_mon.enemy.health), ")"); } // 
        dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): --- ENTRY --- Enemy is ", enemy_status_str_pursuit, ".\n"); // 
    }

    if (!p_mon.enemy || p_mon.enemy == world || p_mon.enemy.health <= 0) { // 
        p_mon.enemy = world; // 
        if (p_mon.movetarget != world && p_mon.movetarget.classname == "path_corner") { p_mon.goalentity = p_mon.movetarget; }  // 
        else { p_mon.goalentity = world; } // 
        p_mon.mc_has_played_sight_sound = FALSE; // 
        p_mon.mc_ai_state = MC_AI_STATE_IDLE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Enemy lost/dead. Transition to IDLE.\n"); // 
        p_mon.think = MC_AI_Master_Think; // 
        p_mon.nextthink = time + 0.1; // 
        return; // 
    }

    p_mon.goalentity = p_mon.enemy; // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Set goalentity. Calling MC_Face_Target.\n"); // 
    MC_Face_Target(p_mon, p_mon.enemy); // 
    
    f_can_attack = FALSE; // 
    if (p_mon.mc_check_attack_func != SUB_Null) { // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Pre p_mon.mc_check_attack_func().\n"); // 
        f_can_attack = p_mon.mc_check_attack_func(); // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Post p_mon.mc_check_attack_func(). f_can_attack = ", ftos(f_can_attack), "\n"); // 
    } else {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): mc_check_attack_func is SUB_Null.\n"); // 
    }
    
    if (f_can_attack == TRUE && time >= p_mon.mc_attack_finished_time) { // 
        p_mon.mc_ai_state = MC_AI_STATE_COMBAT; // 
        if (p_mon.combat_style == CS_RANGED || p_mon.combat_style == CS_MIXED) { if (p_mon.th_missile != SUB_Null) { p_mon.attack_state = AS_MISSILE; } }  // 
        else if (p_mon.combat_style == CS_MELEE) { if (p_mon.th_melee != SUB_Null) { p_mon.attack_state = AS_MELEE; } } // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Attack CONDITIONS MET. Attack_state set to: ", ftos(p_mon.attack_state), ". Transitioning to COMBAT.\n"); // 
        p_mon.think = MC_AI_Master_Think; // 
        p_mon.nextthink = time + 0.1; // 
        return;  // 
    }

    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): Skipped COMBAT transition. Pre MC_Set_Animation.\n"); // 
    if (p_mon.th_run != SUB_Null) { MC_Set_Animation(p_mon, p_mon.th_run); } // 
    else { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): p_mon.th_run is SUB_Null! Defaulting to Master_Think.\n"); p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; } // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pursuit (mc_bh_ai.qc v2.16.0): --- EXIT --- \n"); // 
};

/* ##FQX - ##Quedra: MC_AI_Think_Combat */
void(entity p_mon) MC_AI_Think_Combat = // 
{
    local float b_attack_executed; b_attack_executed = FALSE; // 
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Entry. AttackState: ", ftos(p_mon.attack_state), ", Enemy: ", p_mon.enemy.netname, "\n"); // 
    if (!p_mon.enemy || p_mon.enemy == world || p_mon.enemy.health <= 0) { // 
        p_mon.enemy = world; // 
        if (p_mon.movetarget != world && p_mon.movetarget.classname == "path_corner") { p_mon.goalentity = p_mon.movetarget; } // 
        else { p_mon.goalentity = world; } // 
        p_mon.mc_has_played_sight_sound = FALSE; // 
        p_mon.mc_ai_state = MC_AI_STATE_IDLE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Enemy lost/dead. Transition to IDLE.\n"); // 
        p_mon.think = MC_AI_Master_Think; // 
        p_mon.nextthink = time + 0.1; // 
        return; // 
    }

    p_mon.goalentity = p_mon.enemy;  MC_Face_Target(p_mon, p_mon.enemy); // 
    if (time < p_mon.mc_attack_finished_time) { p_mon.mc_ai_state = MC_AI_STATE_PURSUE; if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Attack engagement on cooldown (mc_attack_finished_time). Transition to PURSUE.\n"); p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; return; } // 

    if (p_mon.attack_state == 0 || p_mon.attack_state == AS_STRAIGHT) { // 
        if ((p_mon.combat_style == CS_RANGED || p_mon.combat_style == CS_MIXED) && p_mon.th_missile != SUB_Null) { p_mon.attack_state = AS_MISSILE; if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Defaulting attack_state to AS_MISSILE based on CS and th_missile.\n"); } // 
        else if (p_mon.combat_style == CS_MELEE && p_mon.th_melee != SUB_Null) { p_mon.attack_state = AS_MELEE; if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Defaulting attack_state to AS_MELEE based on CS and th_melee.\n"); } // 
    }
    
    if (p_mon.attack_state == AS_MELEE) { if (p_mon.th_melee != SUB_Null) { b_attack_executed = MC_Execute_Melee(p_mon, p_mon.enemy, p_mon.mc_melee_reach, p_mon.th_melee, string_null); } }  // 
    else if (p_mon.attack_state == AS_MISSILE) { if (p_mon.th_missile != SUB_Null) { b_attack_executed = MC_Execute_Missile(p_mon, p_mon.enemy, p_mon.th_missile, string_null); } }  // 
    else if (p_mon.attack_state == AS_SLIDING) { if (p_mon.mc_anim_slide_func != SUB_Null) { MC_Set_Animation(p_mon, p_mon.mc_anim_slide_func); b_attack_executed = TRUE; } } // 

    if (b_attack_executed == TRUE) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Attack initiated or animation set.\n"); } // 
    else { p_mon.mc_ai_state = MC_AI_STATE_PURSUE; if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Combat (mc_bh_ai.qc v2.16.0): Attack failed/not executed (attack_state '", ftos(p_mon.attack_state) ,"' not handled or th_ function null). Transition to PURSUE.\n"); p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; } // 
};

/* ##FQX - ##Quedra: MC_AI_Think_Pain */
void(entity p_mon) MC_AI_Think_Pain =  // 
{
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pain (mc_bh_ai.qc v2.16.0): Entry. PainFinished: ", ftos(p_mon.pain_finished), "\n"); // 
    if (p_mon.pain_finished <= time) { // 
        p_mon.mc_ai_state = MC_AI_STATE_PURSUE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pain (mc_bh_ai.qc v2.16.0): Pain finished. Transition to PURSUE. Setting anim: th_run\n"); // 
        if (p_mon.th_run != SUB_Null) { MC_Set_Animation(p_mon, p_mon.th_run); }  // 
        else { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_AI_Think_Pain (mc_bh_ai.qc v2.16.0): WARNING - p_mon.th_run is SUB_Null! Defaulting to Master_Think.\n"); p_mon.think = MC_AI_Master_Think; p_mon.nextthink = time + 0.1; } // 
    }
};

//============================================================================
// ##FQXnote: MASTER AI THINK FUNCTION  
//============================================================================
void() MC_AI_Master_Think = // 
{
    if(cvar("developer") >= 1 && mc_debug_prints_enabled == TRUE) {  // 
        dprint("MC_AI_Master_Think (mc_bh_ai.qc v2.16.0): ", self.netname, " St: ", ftos(self.mc_ai_state), " H: ", ftos(self.health), "\n"); // 
        dprint("  MasterThink GroundEnt: ", self.groundentity.netname, " (valid: ", ftos(self.groundentity != world), "), FL_ONGROUND: ", ftos(self.flags & FL_ONGROUND), "\n"); // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  DeadFlg: ", ftos(self.deadflag), " Time: ", ftos(time), "\n"); // 
    }

    if (self.health <= 0 || self.deadflag != DEAD_NO) { // 
        self.mc_ai_state = MC_AI_STATE_DEAD; // 
        if (self.deadflag == DEAD_DEAD) { // 
            if(cvar("developer") >= 1 && mc_debug_prints_enabled == TRUE) dprint("MC_AI_Master_Think (mc_bh_ai.qc v2.16.0): Monster ", self.netname, " is DEAD_DEAD. Halting think.\n"); // 
            self.think = SUB_Null;  // 
            self.nextthink = -1; // 
        } else if (self.deadflag == DEAD_DYING) { // 
            if (self.think == MC_AI_Master_Think) { self.nextthink = time + 0.1; } // 
        }
        return; // 
    }

    if (self.mc_ai_state == MC_AI_STATE_PAIN) { MC_AI_Think_Pain(self); if (self.think == MC_AI_Master_Think) { self.nextthink = time + 0.1; } return; } // 

    if (self.mc_ai_state == MC_AI_STATE_IDLE) { MC_AI_Think_Idle(self); }  // 
    else if (self.mc_ai_state == MC_AI_STATE_PURSUE) { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(self.netname, " MC_AI_Master_Think (mc_bh_ai.qc v2.16.0): In PURSUE state. Calling MC_AI_Think_Pursuit.\n"); MC_AI_Think_Pursuit(self); }  // 
    else if (self.mc_ai_state == MC_AI_STATE_COMBAT) { MC_AI_Think_Combat(self); }  // 
    else if (self.mc_ai_state == MC_AI_STATE_SPAWN) { // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_AI_Master_Think (mc_bh_ai.qc v2.16.0): SPAWN state, transitioning to IDLE for ", self.netname, "\n"); // 
        self.mc_ai_state = MC_AI_STATE_IDLE; // 
        self.mc_has_played_sight_sound = FALSE;  // 
        if (self.th_stand != SUB_Null) { MC_Set_Animation(self, self.th_stand); }  // 
        else { self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; }  // 
    } else if (self.mc_ai_state == MC_AI_STATE_CUSTOM) { /* Custom logic */ } // 

    if (self.think == MC_AI_Master_Think) { self.nextthink = time + 0.1; } // 
};

void(void() p_refire_func) MC_SUB_CheckRefire =  // 
{ 
    if (self.enemy == world || self.enemy.health <= 0 || !MC_Can_See(self, self.enemy, TRUE) || random() > 0.6) { // 
        self.attack_finished = time + 0.5 + (random() * 1.5); // 
        self.mc_attack_finished_time = time + 0.5 + (random() * 1.5);  // 
        self.mc_ai_state = MC_AI_STATE_PURSUE; // 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_SUB_CheckRefire (mc_bh_ai.qc v2.16.0): Not refiring for ", self.netname, ". Transition to PURSUE. Anim: th_run\n"); // 
        if (self.th_run != SUB_Null) { MC_Set_Animation(self, self.th_run); }  // 
        else { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_SUB_CheckRefire (mc_bh_ai.qc v2.16.0): WARNING - self.th_run is SUB_Null! Defaulting to Master_Think for ", self.netname, "\n"); self.think = MC_AI_Master_Think; self.nextthink = time + 0.1; } // 
    } else {
        if (p_refire_func != SUB_Null) { // 
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_SUB_CheckRefire (mc_bh_ai.qc v2.16.0): Refiring for ", self.netname, ". Calling p_refire_func.\n"); // 
            p_refire_func();  // 
        } else {
            self.mc_ai_state = MC_AI_STATE_PURSUE; // 
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_SUB_CheckRefire (mc_bh_ai.qc v2.16.0): No refire_func for ", self.netname, ". Transition to PURSUE. Anim: th_run\n"); // 
            if (self.th_run != SUB_Null) { MC_Set_Animation(self, self.th_run); } // 
            else { if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_SUB_CheckRefire (mc_bh_ai.qc v2.16.0): WARNING - self.th_run is SUB_Null (no refire_func)! Defaulting to Master_Think for ", self.netname, "\n"); self.think = MC_AI_Master_Think; self.nextthink = time + 0.1;  } // 
        }
    }
};
//=============================================================================
// mc_bh_ai.qc - FQX Mod - Monster Core Behaviors: AI System
// ##FQX - ##Quedra: Version 2.16.0 - End of File
//=============================================================================