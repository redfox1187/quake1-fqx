//=============================================================================
// mc_ops_combat.qc - FQX Mod - Monster Core Operations: Combat
// ##FQX - ##FQXnote: Generic monster combat operations.
// ##FQX - ##FQXnote: - Melee execution
// ##FQX - ##FQXnote: - Missile attack execution
// ##FQX - ##FQXnote: - Attack range checking
// ##FQX - ##FQXnote: Version 1.2 (Consistency update with other MC modules)
//=============================================================================

//============================================================================
// ##FQXnote: FORWARD DECLARATIONS (from other MC_* modules, assumed available)
//============================================================================
// ##FQXnote: From mc_ops_movement.qc
void(entity p_mon, entity p_target_entity) MC_Face_Target;
// ##FQXnote: From RERELEASE: weapons.qc (CanDamage)
float(entity targ, entity inflictor) CanDamage;


//============================================================================
// ##FQXnote: GENERIC COMBAT EXECUTION FUNCTIONS
//============================================================================

/* ##FQX - ##FQXnote:
MC_Execute_Melee
Initiates a melee attack sequence if the target is valid and in range.
It calls the monster-specific animation and damage functions.

Parameters:
    p_mon                   - The monster entity (self).
    p_target_enemy          - The enemy entity to attack.
    p_melee_reach           - The maximum distance for this melee attack to connect.
                              (This should be stored on the monster, e.g., self.mc_melee_reach)
    p_melee_anim_start_func - Function pointer to the monster's specific melee attack
                              animation sequence (e.g., knight_atk1). This sequence is
                              expected to call the actual damage dealing logic at the
                              appropriate frame(s).
    p_melee_sound_override  - (Optional) Path to a specific sound to play when initiating
                              the melee attack. Many monsters play sounds within their
                              animation frames, so this can be string_null.
Return:
    float                   - TRUE (1.0) if the melee attack was initiated, FALSE (0.0) otherwise.
*/
float(entity p_mon, entity p_target_enemy, float p_melee_reach, void() p_melee_anim_start_func, string p_melee_sound_override) MC_Execute_Melee =
{
    local float f_dist_to_enemy;

    if (!p_target_enemy || p_target_enemy == world || p_target_enemy.health <= 0) {
        return FALSE; // ##FQXnote: Invalid or dead target
    }

    if (p_melee_anim_start_func == SUB_Null) {
        if (cvar("developer") > 0) {
            dprint("MC_Execute_Melee: p_melee_anim_start_func is SUB_Null for ");
            dprint(p_mon.netname);
            dprint("\n");
        }
        return FALSE; // ##FQXnote: No animation function provided
    }

    // ##FQXnote: Check if target is damageable by this monster
    if (!CanDamage(p_target_enemy, p_mon)) { // ##FQXnote: CanDamage is standard QuakeC
        return FALSE;
    }

    // ##FQXnote: Check melee range
    f_dist_to_enemy = vlen(p_target_enemy.origin - p_mon.origin);
    if (f_dist_to_enemy > p_melee_reach) {
        return FALSE; // ##FQXnote: Target is out of melee reach
    }

    // ##FQXnote: Play sound if provided
    if (p_melee_sound_override != string_null) {
        sound(p_mon, CHAN_WEAPON, p_melee_sound_override, 1, ATTN_NORM);
    }

    // ##FQXnote: Face the target before attacking
    MC_Face_Target(p_mon, p_target_enemy);

    // ##FQXnote: Call the monster-specific melee animation/attack function
    p_melee_anim_start_func();

    return TRUE; // ##FQXnote: Melee attack initiated
};

/* ##FQX - ##FQXnote:
MC_Execute_Missile
Initiates a missile attack sequence. This involves calling monster-specific
animation functions, which in turn are expected to call monster-specific
projectile spawning functions at the correct animation frame.

Parameters:
    p_mon                     - The monster entity (self).
    p_target_enemy            - The enemy entity to attack.
    p_missile_anim_start_func - Function pointer to the monster's specific missile
                                attack animation sequence (e.g., enf_atk1). This sequence
                                is expected to call the actual projectile spawning logic.
    p_missile_attack_sound_override - (Optional) Path to a specific sound for initiating the
                                      missile attack. Many monsters play sounds within their
                                      animation frames.
Return:
    float                     - TRUE (1.0) if the missile attack was initiated, FALSE (0.0) otherwise.
*/
float(entity p_mon, entity p_target_enemy, void() p_missile_anim_start_func, string p_missile_attack_sound_override) MC_Execute_Missile =
{
    if (!p_target_enemy || p_target_enemy == world || p_target_enemy.health <= 0) {
        return FALSE; // ##FQXnote: Invalid or dead target
    }

    if (p_missile_anim_start_func == SUB_Null) {
        if (cvar("developer") > 0) {
            dprint("MC_Execute_Missile: p_missile_anim_start_func is SUB_Null for ");
            dprint(p_mon.netname);
            dprint("\n");
        }
        return FALSE; // ##FQXnote: No animation function provided
    }

    if (p_missile_attack_sound_override != string_null) {
        sound(p_mon, CHAN_WEAPON, p_missile_attack_sound_override, 1, ATTN_NORM);
    }

    MC_Face_Target(p_mon, p_target_enemy);
    p_missile_anim_start_func();

    return TRUE; // ##FQXnote: Missile attack initiated
};
//============================================================================
// ##FQXnote: GENERIC COMBAT EXECUTION FUNCTIONS - END
//============================================================================

//============================================================================
// ##FQXnote: GENERIC COMBAT UTILITY FUNCTIONS
//============================================================================

/* ##FQX - ##FQXnote:
MC_Check_Attack_Range
Generic function to check if a target is within a specified attack range.
This is more granular than MC_Get_Range_Category.

Parameters:
    p_mon           - The monster entity (self).
    p_target_enemy  - The enemy entity to check range against.
    p_min_range     - The minimum distance for this attack to be valid.
                      (Use 0 if there's no minimum range).
    p_max_range     - The maximum distance for this attack to be valid.
Return:
    float           - TRUE (1.0) if target is within [p_min_range, p_max_range], FALSE (0.0) otherwise.
*/
float(entity p_mon, entity p_target_enemy, float p_min_range, float p_max_range) MC_Check_Attack_Range =
{
    local float f_dist_to_enemy;

    if (!p_target_enemy || p_target_enemy == world || p_target_enemy.health <= 0) {
        return FALSE;
    }

    f_dist_to_enemy = vlen(p_target_enemy.origin - p_mon.origin);

    if (f_dist_to_enemy >= p_min_range && f_dist_to_enemy <= p_max_range) {
        return TRUE;
    }

    return FALSE;
};

/* ##FQX - ##FQXnote:
MC_Can_Damage_Target
Checks if the monster can damage the target entity.
Currently a wrapper for the standard CanDamage.

Parameters:
    p_mon           - The monster entity (self).
    p_target_enemy  - The potential target entity.
Return:
    float           - TRUE (1.0) if target can be damaged, FALSE (0.0) otherwise.
References:
    RERELEASE: weapons.qc (CanDamage function)
*/
float(entity p_mon, entity p_target_enemy) MC_Can_Damage_Target =
{
    // ##FQXnote: CanDamage(target, inflictor)
    // ##FQXnote: Ensure CanDamage is available (typically from combat.qc or similar)
    return CanDamage(p_target_enemy, p_mon);
};

//============================================================================
// ##FQXnote: GENERIC COMBAT UTILITY FUNCTIONS - END
//============================================================================

//=============================================================================
// mc_ops_combat.qc - FQX Mod - Monster Core Operations: Combat - END
//=============================================================================
