//=============================================================================
// w_q_rl.qc - FQX Mod - Quake Rocket Launcher Datasheet
// ##FQX - ##Quedra: Version 1.0.2
// ##Quedra: Corrected function return type syntax to 'void' to resolve warnings.
//=============================================================================

// --- Forward Declarations from weapons.qc ---
void() player_rocket1;
void() W_FireRocket;

//=============================================================================
// ##Quedra: SetCurrentAmmo function for the Rocket Launcher
//=============================================================================
void w_q_rl_SetCurrentAmmo() =
{
    self.currentammo = self.ammo_rockets;
    self.weaponmodel = "progs/v_rock2.mdl";
    self.items = self.items | IT_ROCKETS;
};

//=============================================================================
// ##Quedra: Fire function for the Rocket Launcher
//=============================================================================
void W_FireRL() =
{
    // Play the weapon animation
    player_rocket1();
    
    // Fire the projectile
    W_FireRocket();
    
    // Set the cooldown
    self.attack_finished = time + 0.8;
};

//=============================================================================
// w_q_rl.qc - FQX Mod - Quake Rocket Launcher Datasheet - END
// ##FQX - ##Quedra: Version 1.0.2
//=============================================================================