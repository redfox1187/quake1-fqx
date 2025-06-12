//=============================================================================
// util_combat.qc - FQX Mod - Centralized Combat Utilities
// Location: /src/util/
// ##FQX - ##Quedra: Version 1.0.1
// ##Quedra: Provides centralized, reusable combat-related functions.
// ##Quedra: v1.0.1 - Corrected T_RadiusDamage call to match its definition.
// ##Quedra: v1.0.0 - Initial creation with FQX_Explosion function for Phoenix.
//=============================================================================

/*
================
FQX_Explosion

A centralized function to handle all explosion damage and effects.
Every explosive projectile and event will call this function.
- org: The epicenter of the explosion.
- attacker: The entity responsible for the explosion.
- damage: The base damage value at the epicenter.
- radius: The area of effect for the damage.
- ignore: An entity to be ignored by the radius damage check.
- te_effect: The temporary entity effect to spawn (e.g., TE_EXPLOSION).
================
*/
void(vector org, entity attacker, float damage, float radius, entity ignore, float te_effect) FQX_Explosion =
{
	local entity temp;

    // ##Quedra: Spawn a temporary entity to act as the inflictor
    // ##Quedra: for the damage calculation.
    temp = spawn();
    setorigin(temp, org);

    // ##Quedra: CORRECTED - Removed the fifth parameter ("rocket") to match the
    // ##Quedra: 4-parameter definition of T_RadiusDamage.
	T_RadiusDamage (temp, attacker, damage, ignore);

	remove(temp); // Clean up the temporary entity
};

//=============================================================================
// util_combat.qc - FQX Mod - Centralized Combat Utilities - END
// ##FQX - ##Quedra: Version 1.0.1
//=============================================================================