//=============================================================================
// mc_ops_states.qc - FQX Mod - Monster Core Operations: States
// ##FQX - ##Quedra: Version 1.8.1
// ##Quedra: Gated initial dprint in MC_Initialize_Monster with mc_debug_prints_enabled.
// ##Quedra: Previous: Version 1.8 - Segmented dprints in MC_Initialize_Monster to fix warnings.
//=============================================================================

//============================================================================
// ##Quedra: MONSTER INITIALIZATION
//============================================================================
void(entity p_mon, float p_health, string p_model_path, vector p_mins, vector p_maxs, float p_movetype, float p_solid_type, float p_flags_to_add,
    void() p_th_stand_func, void() p_th_walk_func, void() p_th_run_func, void(entity attacker, float damage) p_th_pain_func, void() p_th_die_func,
    void() p_th_melee_func, void() p_th_missile_func,
    string p_sound_sight, string p_sound_pain_primary, string p_sound_death_primary, string p_sound_idle_primary,
    float p_yaw_speed, vector p_view_ofs, void() p_initial_think_func, float p_pausetime_if_no_target,
    float p_allow_path_find, float p_combat_style, string p_netname, string p_killstring,
    float p_gib_health_thresh, string p_head_gib_model_path, string p_item_drop_field_name, float p_item_drop_amount) MC_Initialize_Monster =
{
    // ##Quedra: CONDITIONAL ENTRY DIAGNOSTIC
    if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE)
    {
        dprint("MC_Initialize_Monster: ENTRY for ", p_netname, ". Cvar 'developer': ", ftos(cvar("developer")), ", mc_debug_prints_enabled: ", ftos(mc_debug_prints_enabled), "\n");
    }

    // ##FQXCUSTOM - ##Quedra: Basic Entity Setup
    p_mon.solid = p_solid_type;
    p_mon.movetype = p_movetype;
    setmodel(p_mon, p_model_path);
    setsize(p_mon, p_mins, p_maxs);

    p_mon.health = p_health;
    p_mon.max_health = p_health;
    p_mon.takedamage = DAMAGE_AIM;
    p_mon.flags = (p_mon.flags - (p_mon.flags & FL_ONGROUND)) | FL_MONSTER | p_flags_to_add; 

    // ##FQXCUSTOM - ##Quedra: Identification and Core Sounds
    if (p_netname != string_null) { p_mon.netname = p_netname; }
    if (p_killstring != string_null) { p_mon.killstring = p_killstring; }
    if (p_sound_sight != string_null) { p_mon.noise = p_sound_sight; }
    if (p_sound_pain_primary != string_null) { p_mon.mc_sound_pain_primary = p_sound_pain_primary; }
    if (p_sound_death_primary != string_null) { p_mon.mc_sound_death_primary = p_sound_death_primary; }
    if (p_sound_idle_primary != string_null) { p_mon.mc_sound_idle_primary = p_sound_idle_primary; }

    p_mon.th_stand = p_th_stand_func;
    p_mon.th_walk = p_th_walk_func;
    p_mon.th_run = p_th_run_func;
    p_mon.th_pain = p_th_pain_func;
    p_mon.th_die = p_th_die_func;
    if (p_th_melee_func != SUB_Null) { p_mon.th_melee = p_th_melee_func; }
    if (p_th_missile_func != SUB_Null) { p_mon.th_missile = p_th_missile_func; }

    p_mon.yaw_speed = p_yaw_speed;
    if (p_yaw_speed == 0) { 
        if (p_mon.flags & FL_FLY || p_mon.flags & FL_SWIM) { p_mon.yaw_speed = 10; } 
        else { p_mon.yaw_speed = 20; }
    }
    p_mon.view_ofs = p_view_ofs;
    if (p_view_ofs == '0 0 0') { 
        if (p_mon.flags & FL_SWIM) { p_mon.view_ofs = '0 0 10'; } 
        else { p_mon.view_ofs = '0 0 25'; }
    }

    p_mon.use = monster_use; 
    p_mon.team = TEAM_MONSTERS; 
    p_mon.allowPathFind = p_allow_path_find;
    p_mon.combat_style = p_combat_style;
    p_mon.mc_gib_health_threshold = p_gib_health_thresh;
    if (p_head_gib_model_path != string_null) { p_mon.mc_head_gib_model_path = p_head_gib_model_path; }
    p_mon.mc_item_drop_field_name = p_item_drop_field_name;
    p_mon.mc_item_drop_amount = p_item_drop_amount;

    if (p_mon.target != string_null) {
        p_mon.goalentity = p_mon.movetarget = find(world, targetname, p_mon.target);
        if (!p_mon.movetarget) {
            if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint("MC_Initialize_Monster: Monster at ", vtos(p_mon.origin), " can't find target: ", p_mon.target, "\n");
            p_mon.pausetime = time + p_pausetime_if_no_target;
            if (p_pausetime_if_no_target == 0) { p_mon.pausetime = time + 99999999; }
            p_mon.think = p_initial_think_func;
        } else {
            p_mon.ideal_yaw = vectoyaw(p_mon.goalentity.origin - p_mon.origin);
            if (p_mon.movetarget.classname == "path_corner") { p_mon.think = p_th_walk_func; } 
            else { 
                p_mon.pausetime = time + p_pausetime_if_no_target;
                if (p_pausetime_if_no_target == 0) { p_mon.pausetime = time + 99999999; }
                p_mon.think = p_initial_think_func;
            }
        }
    } else {
        p_mon.pausetime = time + p_pausetime_if_no_target;
        if (p_pausetime_if_no_target == 0) { p_mon.pausetime = time + 99999999; }
        p_mon.think = p_initial_think_func;
    }

    if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) {
        dprint(p_mon.netname, " MC_Init: PRE-GROUNDING CHECK. MOVETYPE_STEP=", ftos(MOVETYPE_STEP), ", p_mon.movetype=", ftos(p_mon.movetype), "\n");
        dprint(p_mon.netname, " MC_Init: PRE-GROUNDING CHECK. FL_SWIM=", ftos(FL_SWIM), ", p_mon.flags & FL_SWIM=", ftos(p_mon.flags & FL_SWIM), "\n");
    }

    if (p_mon.movetype == MOVETYPE_STEP && !(p_mon.flags & FL_SWIM) ) {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Init: ENTERING grounding logic block.\n");
        p_mon.origin_z = p_mon.origin_z + 1; 
        droptofloor();
        
        if (p_mon.groundentity != world) {
            p_mon.flags = p_mon.flags | FL_ONGROUND;
             if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Init: After droptofloor(), GroundEnt was valid. Forced FL_ONGROUND.\n");
        } else {
            p_mon.flags = p_mon.flags - (p_mon.flags & FL_ONGROUND);
            if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Init: After droptofloor(), GroundEnt is world. Cleared FL_ONGROUND.\n");
        }

        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // ##Quedra: Segmented dprint
            dprint(p_mon.netname, " MC_Init: State Bf_walkmove(0,0) GE: ", p_mon.groundentity.netname, " (valid: ", ftos(p_mon.groundentity != world), ")\n");
            dprint(p_mon.netname, " MC_Init: State Bf_walkmove(0,0) FL_ONGROUND: ", ftos(p_mon.flags & FL_ONGROUND), "\n");
        }
        
        if (!walkmove(0, 0)) { 
            if (cvar("developer") > 0) dprint("MC_Initialize_Monster: Monster ", p_mon.netname," stuck in wall at: ", vtos(p_mon.origin), " (after initial walkmove(0,0) check)\n");
        }

        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) { // ##Quedra: Segmented dprint
            dprint(p_mon.netname, " MC_Init: FINAL Ground State GE: ", p_mon.groundentity.netname, " (valid: ", ftos(p_mon.groundentity != world), ")\n");
            dprint(p_mon.netname, " MC_Init: FINAL Ground State FL_ONGROUND: ", ftos(p_mon.flags & FL_ONGROUND), "\n");
        }
    } else if (p_mon.flags & FL_FLY) { 
         if (!walkmove(0,0)) { 
            if (cvar("developer") > 0) dprint ("MC_Initialize_Monster: Flymonster ", p_mon.netname," stuck in wall at: ", vtos(p_mon.origin), "\n");
         }
    } else {
        if(cvar("developer") > 0 && mc_debug_prints_enabled == TRUE) dprint(p_mon.netname, " MC_Init: SKIPPED grounding logic block. Movetype was not STEP or was SWIM.\n");
    }

    p_mon.ideal_yaw = p_mon.angles_y;
    p_mon.nextthink = time + 0.1 + (random() * 0.2);
    total_monsters = total_monsters + 1; 
};

//============================================================================
// ##Quedra: GENERIC PAIN HANDLING
//============================================================================
void(entity p_mon, entity p_attacker, float p_damage, void() p_pain_anim_func_ptr, string p_pain_sound_override, float p_pain_threshold, float p_pain_chance, float p_pain_duration) MC_Pain_Handler =
{
    local string s_sound_to_play;
    if (p_mon.pain_finished > time) { return; }
    if (p_mon.health <= 0) { return; }
    if (p_damage < p_pain_threshold) { return; }
    if (p_pain_chance < 1.0 && random() >= p_pain_chance) { return; }

    p_mon.mc_ai_state = MC_AI_STATE_PAIN;
    s_sound_to_play = string_null;
    if (p_pain_sound_override != string_null) { s_sound_to_play = p_pain_sound_override; } 
    else if (p_mon.mc_sound_pain_primary != string_null) { s_sound_to_play = p_mon.mc_sound_pain_primary; }

    if (s_sound_to_play != string_null) { sound(p_mon, CHAN_VOICE, s_sound_to_play, 1, ATTN_NORM); }
    p_mon.pain_finished = time + p_pain_duration;

    if (p_pain_anim_func_ptr != SUB_Null) {
        p_pain_anim_func_ptr();
    } else {
        p_mon.think = MC_AI_Master_Think;
        p_mon.nextthink = time + 0.1;
    }
};
//============================================================================
// ##Quedra: GENERIC DEATH HANDLING
//============================================================================
void(entity p_mon, entity p_attacker, void() p_death_anim_func_ptr, string p_death_sound_override, string p_gib_sound_override, void() p_gib_func_override, void() p_drop_item_func_override) MC_Death_Handler =
{
    local string s_sound_to_play;
    local float b_is_gibbed; 

    b_is_gibbed = FALSE;
    if (p_mon.health < p_mon.mc_gib_health_threshold) {
        b_is_gibbed = TRUE;
        if (p_gib_func_override != SUB_Null) {
            p_gib_func_override();
        } else {
            s_sound_to_play = p_gib_sound_override;
            if (s_sound_to_play == string_null) { s_sound_to_play = "player/udeath.wav"; }
            sound(p_mon, CHAN_VOICE, s_sound_to_play, 1, ATTN_NORM);
            if (p_mon.mc_head_gib_model_path != string_null) { ThrowHead(p_mon.mc_head_gib_model_path, p_mon.health); }
            ThrowGib("progs/gib1.mdl", p_mon.health);
            ThrowGib("progs/gib2.mdl", p_mon.health);
            ThrowGib("progs/gib3.mdl", p_mon.health);
        }
    }

    if (b_is_gibbed == TRUE) {
        p_mon.deadflag = DEAD_DEAD;
        p_mon.takedamage = DAMAGE_NO;
        p_mon.solid = SOLID_NOT;
        p_mon.movetype = MOVETYPE_NONE;
        p_mon.flags = p_mon.flags - (p_mon.flags & FL_ONGROUND);
        if (p_mon.target != string_null) {
            if (p_mon.enemy != world) { activator = p_mon.enemy; } 
            else if (p_attacker != world && p_attacker != p_mon) { activator = p_attacker; } 
            else { activator = world; }
            if (activator != world) { SUB_UseTargets(); }
        }
        return;
    }

    s_sound_to_play = p_death_sound_override;
    if (s_sound_to_play == string_null && p_mon.mc_sound_death_primary != string_null) {
        s_sound_to_play = p_mon.mc_sound_death_primary;
    }
    if (s_sound_to_play != string_null) { sound(p_mon, CHAN_VOICE, s_sound_to_play, 1, ATTN_NORM); }

    if (p_drop_item_func_override == SUB_Null && p_mon.mc_item_drop_field_name != string_null && p_mon.mc_item_drop_amount > 0) {
        if (p_mon.mc_item_drop_field_name == "ammo_shells") { p_mon.ammo_shells = p_mon.mc_item_drop_amount; } 
        else if (p_mon.mc_item_drop_field_name == "ammo_nails") { p_mon.ammo_nails = p_mon.mc_item_drop_amount; } 
        else if (p_mon.mc_item_drop_field_name == "ammo_rockets") { p_mon.ammo_rockets = p_mon.mc_item_drop_amount; } 
        else if (p_mon.mc_item_drop_field_name == "ammo_cells") { p_mon.ammo_cells = p_mon.mc_item_drop_amount; }
    } else if (p_drop_item_func_override != SUB_Null) {
        p_drop_item_func_override();
    }

    p_mon.deadflag = DEAD_DYING;
    p_mon.takedamage = DAMAGE_NO;
    if (p_death_anim_func_ptr != SUB_Null) {
        p_death_anim_func_ptr();
    } else {
        p_mon.solid = SOLID_NOT;
        if (p_drop_item_func_override == SUB_Null && p_mon.mc_item_drop_field_name != string_null && p_mon.mc_item_drop_amount > 0) {
             if (p_mon.ammo_shells > 0 || p_mon.ammo_rockets > 0 || p_mon.ammo_cells > 0 || p_mon.ammo_nails > 0) { DropBackpack(); }
        }
        if (p_mon.target != string_null) {
            if (p_mon.enemy != world) { activator = p_mon.enemy; } 
            else if (p_attacker != world && p_attacker != p_mon) { activator = p_attacker; } 
            else { activator = world; }
            if (activator != world) { SUB_UseTargets(); }
        }
        p_mon.deadflag = DEAD_DEAD;
        p_mon.think = MC_AI_Master_Think;
        p_mon.nextthink = time + 0.1;
    }
};
//=============================================================================
// mc_ops_states.qc - FQX Mod - Monster Core Operations: States - END
// ##FQX - ##Quedra: Version 1.8.1
//=============================================================================