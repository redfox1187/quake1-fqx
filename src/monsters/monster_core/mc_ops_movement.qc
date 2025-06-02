//=============================================================================
// mc_ops_movement.qc - FQX Mod - Monster Core Operations: Movement
// ##FQX - ##Quedra: Version 2.3.6
// ##Quedra: Gated all dprint statements with mc_debug_prints_enabled in addition
// ##Quedra: to cvar("developer") > 0 within MC_Set_Animation and MC_Attempt_PathToGoal.
// ##Quedra: Previous: Version 2.3.5 - Re-enabled walkmove in fallback of MC_Attempt_PathToGoal.
//=============================================================================

// ##Quedra: For dprint comparisons in MC_Set_Animation to work by name,
// ##Quedra: specific animation functions like army_walk1, army_atk1, etc.,
// ##Quedra: would need to be forward-declared in a place visible to this file (e.g., mc_defs.qc or defs_2.qc).
//============================================================================
// ##FQXnote: GENERIC ANIMATION UTILITIES
//============================================================================
void(entity p_mon, void() p_anim_start_func) MC_Set_Animation =
{
    // ##Quedra: Corrected dprint gating
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // DPRINT BLOCK SA1
        dprint(p_mon.netname, " MC_Set_Animation (v2.3.6 Entry): Current self is: ", p_mon.netname, " (classname: ", p_mon.classname, ")\n");
        dprint("  SA_D1: Received p_anim_start_func = ");
        if (p_anim_start_func == army_walk1) { dprint("army_walk1.\n");
        } else if (p_anim_start_func == army_stand1) { dprint("army_stand1.\n");
        } else if (p_anim_start_func == army_run1) { dprint("army_run1.\n");
        } else if (p_anim_start_func == army_atk1) { dprint("!!! army_atk1 !!!\n");
        } else if (p_anim_start_func == SUB_Null) { dprint("SUB_Null.\n");
        } else { dprint("ANOTHER ANIMATION FUNCTION (name unavailable here).\n");
        }
        dprint("  SA_D2: Current p_mon.think is: ");
        if (p_mon.think == army_walk1) { dprint("army_walk1.\n");
        } else if (p_mon.think == army_stand1) { dprint("army_stand1.\n");
        } else if (p_mon.think == army_run1) { dprint("army_run1.\n");
        } else if (p_mon.think == MC_AI_Master_Think) { dprint("MC_AI_Master_Think.\n");
        } else if (p_mon.think == SUB_Null) { dprint("SUB_Null.\n");
        } else { dprint("ANOTHER FUNCTION (name unavailable here).\n");
        }
    }

    if (p_anim_start_func != SUB_Null) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D3: Setting ", p_mon.netname, ".think to a NON-NULL function.\n");
        p_mon.think = p_anim_start_func;
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D4: ", p_mon.netname, ".think ASSIGNED.\n");
        p_mon.nextthink = time + 0.1;
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D5: ", p_mon.netname, ".nextthink ASSIGNED (", ftos(p_mon.nextthink),").\n");
    } else {
        if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {
             dprint("  SA_D6_WARN: p_anim_start_func was SUB_Null for monster ", p_mon.netname, ". Attempting fallback.\n");
        }
        if (p_mon.th_stand != SUB_Null) {
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D7: Fallback - Setting .think to th_stand for ", p_mon.netname, "\n");
            p_mon.think = p_mon.th_stand;
            p_mon.nextthink = time + 0.1;
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D8: Fallback .think and .nextthink assigned.\n");
        } else {
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D9_WARN: Fallback - WARNING - th_stand is also SUB_Null! Setting .think to MC_AI_Master_Think for ", p_mon.netname, "\n");
            p_mon.think = MC_AI_Master_Think;
            p_mon.nextthink = time + 0.1;
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("  SA_D10: Critical Fallback .think and .nextthink assigned.\n");
        }
    }
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Set_Animation (v2.3.6 Exit): Current self is: ", p_mon.netname, "\n");
};

void(entity p_mon, void() p_anim_think_func, float p_start_frame, float p_end_frame, float p_loop_to_frame, void() p_end_cycle_think_func) MC_Advance_FrameCycle =
{
    p_mon.frame = p_mon.frame + 1;
    if (p_mon.frame > p_end_frame) {
        if (p_loop_to_frame >= p_start_frame && p_loop_to_frame <= p_end_frame) {
            p_mon.frame = p_loop_to_frame;
        } else if (p_end_cycle_think_func != SUB_Null) {
            p_end_cycle_think_func();
            return;
        } else {
            p_mon.frame = p_start_frame;
            if (p_mon.th_stand != SUB_Null) {
                 p_mon.th_stand();
            }
            return;
        }
    }
    p_mon.think = p_anim_think_func;
    p_mon.nextthink = time + 0.1;
};
//============================================================================
// ##FQXnote: GENERIC MOVEMENT OPERATIONS
//============================================================================
void(entity p_mon, vector p_dest_pos, float p_move_speed_scalar, float p_ideal_yaw_override, void() p_end_reach_think_func, float p_reach_threshold) MC_MoveToPoint_Direct =
{
    local vector v_dir_to_dest;
    local float  f_dist_to_dest;
    local float  f_threshold;

    if (p_ideal_yaw_override != 0) {
        p_mon.ideal_yaw = p_ideal_yaw_override;
    } else {
        if (p_dest_pos != p_mon.origin) {
            v_dir_to_dest = normalize(p_dest_pos - p_mon.origin);
            p_mon.ideal_yaw = vectoyaw(v_dir_to_dest);
        }
    }
    ChangeYaw();

    f_threshold = p_reach_threshold;
    if (f_threshold <= 0) { f_threshold = 16; }
    f_dist_to_dest = vlen(p_dest_pos - p_mon.origin);
    if (f_dist_to_dest < f_threshold) {
        if (p_end_reach_think_func != SUB_Null) { p_end_reach_think_func();
        }
        return;
    }

    if (p_mon.movetype == MOVETYPE_STEP && !(p_mon.flags & FL_SWIM)) {
        walkmove(p_mon.ideal_yaw, p_move_speed_scalar);
    } else if ((p_mon.flags & FL_FLY) || (p_mon.flags & FL_SWIM)) {
        movetogoal(p_move_speed_scalar);
    }
};

float(entity p_mon, entity p_goal_entity, float p_move_dist_per_think) MC_Attempt_PathToGoal =
{
    local string goal_name_str;
    local float move_result;
    if (p_goal_entity && p_goal_entity != world) { goal_name_str = etos(p_goal_entity); } else { goal_name_str = "world_or_null_goal"; } // ##Quedra: Used etos for more detail

    // ##Quedra: Corrected dprint gating
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6): --- ENTRY --- Goal: ", goal_name_str, ", Dist: ", ftos(p_move_dist_per_think), "\n");
    if (!p_goal_entity || p_goal_entity == world) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6): Invalid goal. No movement attempted.\n");
        return FALSE;
    }
    
    if (p_mon.allowPathFind == TRUE) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6): allowPathFind is TRUE.\n");
        if (visible(p_goal_entity)) { // ##Quedra: Assuming 'visible' is available (defined in ai.qc or built-in)
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6): Goal visible. CombatStyle: ", ftos(p_mon.combat_style), "\n");
            if (p_mon.combat_style == CS_RANGED) {
                if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {
                    dprint(p_mon.netname, " MC_AttPath_PRE_WALKMOVE (RANGED v2.3.6) Part1: origin: ", vtos(p_mon.origin), " angles: ", vtos(p_mon.angles), " ideal_yaw: ", ftos(p_mon.ideal_yaw), "\n");
                    dprint(p_mon.netname, " MC_AttPath_PRE_WALKMOVE (RANGED v2.3.6) Part2: goal: ", etos(p_mon.goalentity), " at ", vtos(p_mon.goalentity.origin), "\n");
                    dprint(p_mon.netname, " MC_AttPath_PRE_WALKMOVE (RANGED v2.3.6) Part7: Using self.angles_y: ", ftos(p_mon.angles_y), ", dist: ", ftos(p_move_dist_per_think), "\n");
                }
                
                if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): Calling ChangeYaw(). Current angles_y: ", ftos(p_mon.angles_y), ", ideal_yaw: ", ftos(p_mon.ideal_yaw), "\n");
                ChangeYaw();
                if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): Post ChangeYaw(). Current angles_y: ", ftos(p_mon.angles_y), ". Attempting direct walkmove.\n");
                move_result = walkmove(p_mon.angles_y, p_move_dist_per_think);

                if (move_result == TRUE) { 
                    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): Direct walkmove successful.\n");
                    return TRUE;
                } else { 
                    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): Direct walkmove FAILED. Attempting walkpathtogoal as fallback.\n");
                    if (walkpathtogoal(p_move_dist_per_think, p_goal_entity.origin) == PATH_IN_PROGRESS) {
                        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): walkpathtogoal fallback IN_PROGRESS.\n");
                        return TRUE; 
                    } else {
                        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 RANGED): walkpathtogoal fallback also FAILED.\n");
                    }
                }
            } else if (p_mon.combat_style == CS_MELEE) { 
                if (range(p_goal_entity) > RANGE_NEAR) { // ##Quedra: Assuming 'range' is available
                    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 MELEE): Not near. Calling walkpathtogoal to ", vtos(p_goal_entity.origin), "\n");
                    if (walkpathtogoal(p_move_dist_per_think, p_goal_entity.origin) == PATH_IN_PROGRESS) {
                        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 MELEE): walkpathtogoal IN_PROGRESS.\n");
                        return TRUE;
                    }
                }
            } else if (p_mon.combat_style == CS_MIXED) {
                if (range(p_goal_entity) > RANGE_MID) { // ##Quedra: Assuming 'range' is available
                    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 MIXED): Not mid-range. Calling walkpathtogoal to ", vtos(p_goal_entity.origin), "\n");
                    if (walkpathtogoal(p_move_dist_per_think, p_goal_entity.origin) == PATH_IN_PROGRESS) {
                         if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 MIXED): walkpathtogoal IN_PROGRESS.\n");
                         return TRUE;
                    }
                }
            }
        } else { // Goal NOT visible
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 NOT VISIBLE): Goal NOT visible. Calling walkpathtogoal to ", vtos(p_goal_entity.origin), "\n");
            if (walkpathtogoal(p_move_dist_per_think, p_goal_entity.origin) == PATH_IN_PROGRESS) {
                 if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Attempt_PathToGoal (v2.3.6 NOT VISIBLE): walkpathtogoal IN_PROGRESS.\n");
                 return TRUE;
            }
        }
    }

    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {
        dprint(p_mon.netname, " MC_Attempt_PathToGoal (FALLBACK v2.3.6) Part1: origin: ", vtos(p_mon.origin), " angles: ", vtos(p_mon.angles), "\n");
        dprint(p_mon.netname, " MC_Attempt_PathToGoal (FALLBACK v2.3.6) Part2: ideal_yaw: ", ftos(p_mon.ideal_yaw), "\n");
        dprint(p_mon.netname, " MC_Attempt_PathToGoal (FALLBACK v2.3.6): Attempting final ChangeYaw and walkmove.\n");
    }
    
    ChangeYaw(); 
    move_result = walkmove(p_mon.angles_y, p_move_dist_per_think);
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {
        if(move_result == TRUE) {
            dprint(p_mon.netname, " MC_Attempt_PathToGoal (FALLBACK v2.3.6): walkmove successful.\n");
        } else {
            dprint(p_mon.netname, " MC_Attempt_PathToGoal (FALLBACK v2.3.6): walkmove FAILED.\n");
        }
    }
    return move_result; 
};

void(entity p_mon, entity p_target_entity) MC_Face_Target =
{
    if (!p_target_entity || p_target_entity == world) {
        return;
    }
    p_mon.ideal_yaw = vectoyaw(p_target_entity.origin - p_mon.origin);
    ChangeYaw();
};
//============================================================================
// ##FQXnote: GENERIC MOVEMENT OPERATIONS - END
//============================================================================

//=============================================================================
// mc_ops_movement.qc - FQX Mod - Monster Core Operations: Movement
// ##FQX - ##Quedra: Version 2.3.6
//=============================================================================