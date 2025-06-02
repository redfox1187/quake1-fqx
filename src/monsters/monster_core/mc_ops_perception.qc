//=============================================================================
// mc_ops_perception.qc - FQX Mod - Monster Core Operations: Perception
// ##FQX - ##Quedra: Version 2.0.1
// ##Quedra: Gated initial dprint in MC_Find_Best_Target with mc_debug_prints_enabled.
// ##Quedra: Previous: Version 2.0 - Added more basic entry dprints for MC_Find_Best_Target.
//=============================================================================

//============================================================================
// ##FQXnote: GLOBAL DEFINITIONS FOR PERCEPTION (IF ANY)
//============================================================================
// ##FQXnote: RANGE_* constants are defined in FQX defs_3.qc and are used by this module.
//============================================================================
// ##FQXnote: CORE SENSING UTILITIES
//============================================================================

/* ##FQX - ##Quedra: MC_Can_See */
float(entity p_seer, entity p_target, float p_ignore_other_entities) MC_Can_See =
{
    local vector v_spot1;
    local vector v_spot2;

    if (!p_seer || !p_target || p_target == world) { 
        return FALSE;
    }

    v_spot1 = p_seer.origin + p_seer.view_ofs;
    v_spot2 = p_target.origin + p_target.view_ofs;
    
    traceline(v_spot1, v_spot2, p_ignore_other_entities, p_seer);
    if (trace_inopen && trace_inwater) { 
        return FALSE;
    }

    if (trace_fraction == 1 || trace_ent == p_target) {
        return TRUE;
    }

    return FALSE; 
};

/* ##FQX - ##Quedra: MC_Is_Infront */
float(entity p_observer, entity p_target) MC_Is_Infront =
{
    local vector v_vec_to_target;
    local float  f_dot_product;

    if (!p_target || p_target == world) {
        return FALSE;
    }

    makevectorsfixed(p_observer.angles); 

    v_vec_to_target = normalize(p_target.origin - p_observer.origin);
    f_dot_product = v_vec_to_target * v_forward;
    if (f_dot_product > 0.3) { 
        return TRUE;
    }

    return FALSE;
};

/* ##FQX - ##Quedra: MC_Get_Range_Category */
float(entity p_observer, entity p_target) MC_Get_Range_Category =
{
    local vector v_spot1;
    local vector v_spot2;
    local float  f_distance;

    if (!p_target || p_target == world) {
        return RANGE_FAR;
    }

    v_spot1 = p_observer.origin + p_observer.view_ofs;
    v_spot2 = p_target.origin + p_target.view_ofs;

    f_distance = vlen(v_spot1 - v_spot2);
    if (f_distance < 120) { 
        return RANGE_MELEE;
    }
    if (f_distance < 500) { 
        return RANGE_NEAR;
    }
    if (f_distance < 1000) { 
        return RANGE_MID;
    }

    return RANGE_FAR; 
};
//============================================================================
// ##FQXnote: CORE SENSING UTILITIES - END
//============================================================================

//============================================================================
// ##FQXnote: TARGET ACQUISITION
//============================================================================
/* ##FQX - ##Quedra: MC_Find_Best_Target */
entity(entity p_mon, float p_force_new_target_check) MC_Find_Best_Target =
{
    local entity e_potential_target; 
    local entity e_final_target;     
    local float f_range_to_target;
    local float b_target_is_visible; 
    local float b_target_is_infront;
    local string dprint_prefix;

    // ##Quedra: Conditional entry dprint
    if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE)
    {
        dprint_prefix = strcat("QUEDRA_DEBUG_FTARGET (", p_mon.netname, "): "); // Build prefix only if needed
        dprint(dprint_prefix, "Entered MC_Find_Best_Target. ForceNewCheck: ", ftos(p_force_new_target_check), "\n");
        dprint(dprint_prefix, "  Developer cvar IS > 0. Function proceeding with further checks.\n");
    }
    else if (cvar("developer") > 0) // mc_debug_prints_enabled must be FALSE
    {
        // This dprint is for MY information if the above conditional fails when it shouldn't.
        // It indicates a problem with cvar("developer") check itself.
        // dprint("  FTARGET_DEBUG: Developer cvar IS > 0 BUT mc_debug_prints_enabled is FALSE. No further FTARGETTING dprints will show from this function.\n");
        // Even if developer is 0, the function should still work, just without dprints.
        // If no targeting occurs with developer 0, the issue is in the logic below, not the dprints.
    }


    // ## Part 1: Initial Candidate Selection ##
    if (sight_entity_time >= time - 0.1 && !(p_mon.spawnflags & 3) && p_force_new_target_check == FALSE) {
        e_potential_target = sight_entity;
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Attempting target via sight_entity: ", sight_entity.netname, "\n");
        if (e_potential_target.enemy.classname == "player") {
            e_potential_target = e_potential_target.enemy;
        } else if (e_potential_target.classname != "player") { 
            e_potential_target = world;
        }
    } else {
        e_potential_target = checkclient();
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE && e_potential_target != world) dprint(dprint_prefix, "Attempting target via checkclient(): ", e_potential_target.netname, "\n");
        else if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE && e_potential_target == world) dprint(dprint_prefix, "checkclient() returned world.\n");
    }

    // ## Part 2: Basic Validation of the Initial Candidate ##
    if (!e_potential_target || e_potential_target == world) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "No valid initial candidate (world or null from Part 1).\n");
        return world;
    } 
    if (e_potential_target.health <= 0) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Initial candidate ", e_potential_target.netname, " has health <= 0.\n");
        return world;
    }             
    if (e_potential_target.flags & FL_NOTARGET) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Initial candidate ", e_potential_target.netname, " has FL_NOTARGET.\n");
        return world;
    }     
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE && e_potential_target != world) dprint(dprint_prefix, "Initial candidate ", e_potential_target.netname, " passed basic validation.\n");
    e_final_target = e_potential_target; 

    // ## Part 3: Check if Still Targeting the Same Valid Enemy ##
    if (e_final_target == p_mon.enemy && p_force_new_target_check == FALSE) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate is current enemy. Checking visibility.\n");
        if (MC_Can_See(p_mon, e_final_target, TRUE)) { 
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Still see current enemy ", e_final_target.netname, ". Keeping target.\n");
            return e_final_target;
        }
         if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Lost sight of current enemy ", e_final_target.netname, ".\n");
    }
    
    // ## Part 4: Further Filters for e_final_target ##
    if (e_final_target.items & IT_INVISIBILITY) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " has IT_INVISIBILITY.\n");
        return world;
    } 

    // ## Part 5: Range, Visibility, and Facing Checks ##
    f_range_to_target = MC_Get_Range_Category(p_mon, e_final_target);
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, ": Range Category = ", ftos(f_range_to_target), " (0=MELEE,1=NEAR,2=MID,3=FAR).\n");
    if (f_range_to_target == RANGE_FAR) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " is RANGE_FAR. Rejecting.\n");
        return world; 
    } 

    b_target_is_visible = MC_Can_See(p_mon, e_final_target, TRUE);
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, ": MC_Can_See = ", ftos(b_target_is_visible), ".\n");
    if (!b_target_is_visible) { 
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " is not visible (MC_Can_See returned FALSE). Rejecting.\n");
        return world; 
    }  

    b_target_is_infront = MC_Is_Infront(p_mon, e_final_target);
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, ": MC_Is_Infront = ", ftos(b_target_is_infront), ".\n");
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, ": show_hostile = ", ftos(e_final_target.show_hostile), ", time = ", ftos(time), ".\n");
    if (f_range_to_target == RANGE_NEAR) { 
        if (e_final_target.show_hostile < time && !b_target_is_infront) { 
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " (NEAR): show_hostile < time AND not infront. Rejecting.\n");
            return world;
        }
    } else if (f_range_to_target == RANGE_MID) { 
        if (!b_target_is_infront) { 
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " (MID): Not infront. Rejecting.\n");
            return world;
        }
    }
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Candidate ", e_final_target.netname, " passed Range/LOS/Facing checks.\n");
    // ## Part 6: Final Confirmation that Target is a Valid Player ##
    if (e_final_target.classname != "player") {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(dprint_prefix, "Final candidate ", e_final_target.netname, " (class: ", e_final_target.classname, ") is NOT a player. Rejecting.\n");
        return world;
    }
    
    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { 
        dprint(p_mon.netname, " MC_Find_Best_Target FINAL RESULT: Acquired target: ", e_final_target.netname, " (Class: ", e_final_target.classname, ")\n");
    }
    return e_final_target;
};
//============================================================================
// ##FQXnote: TARGET ACQUISITION - END
//============================================================================

//=============================================================================
// mc_ops_perception.qc - FQX Mod - Monster Core Operations: Perception - END
// ##FQX - ##Quedra: Version 2.0.1
//=============================================================================