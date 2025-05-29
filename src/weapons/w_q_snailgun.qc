//============================================================================
// w_q_snailgun.qc - FQX Mod - Quake Super Nailgun
// ##FQXCUSTOM - ##Quedra: Adapted original Super Nailgun behavior for FQX.
// ##Quedra: Version 1.1 - Updated AM_InitWeaponFireModes call.
//============================================================================

//============================================================================
// QUAKE SUPER NAILGUN - SETUP
//============================================================================
void w_q_snailgun_SetCurrentAmmo() {
    // Initialize weapon view, ammo, and fire modes
    // Using standard Quake Super Nailgun view model
    // AMMO_ID_NAILS should be defined in defs_2.qc or similar for AM_ConsumeAmmo and AM_InitializeWeaponView
    // IT_SLOT_HEAVY is the slot type this weapon occupies.
    AM_InitializeWeaponView("progs/v_nail2.mdl", AMMO_ID_NAILS, IT_SLOT_HEAVY);

    // The Super Nailgun has one primary mode of operation.
    AM_InitWeaponFireModes(1); // ##Quedra: Corrected call, 1 standard mode. Debug mode is universal.

    // Original Super Nailgun applied a direct punchangle.
    // We will apply this directly in W_Fire_Q_Snailgun to maintain original feel.
    // FQX recoil system is not strictly needed for this weapon's original behavior.
    AM_SetRecoilPattern('0 0 0', 1); // Neutral pattern as punchangle is handled manually.
}

//============================================================================
// QUAKE SUPER NAILGUN - FIRE
//============================================================================
void W_Fire_Q_Snailgun() {
    vector src; // Launch origin for projectiles

    // Determine launch origin - typically eye level + small forward offset
    makevectors(self.v_angle);
    src = self.origin + self.view_ofs + v_forward * 8; // Eye position + 8 units forward

    if (self.ammo_nails >= 2) {
        // Fire Super Spike Volley
        sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM); // Standard Super Nailgun fire sound
        AM_ConsumeAmmo(AMMO_ID_NAILS, 2);
        
        launch_spike(src, v_forward); // v_forward is already normalized from makevectors()

        // Customize the just-launched spike (newmis) to be a super spike
        if (newmis) { // newmis is a global entity set by launch_spike
            newmis.classname = "super_spike";
            newmis.touch = superspike_touch; // Assumes superspike_touch is defined in am_nails.qc or globally
            setmodel (newmis, "progs/s_spike.mdl"); // Standard Super Spike projectile model
        }

        self.punchangle_x = -5; // Original Super Nailgun volley punchangle

    } else if (self.ammo_nails >= 1) {
        // Not enough for volley, but has ammo - fire a single, centered standard nail
        sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM); // Standard Nailgun fire sound
        AM_ConsumeAmmo(AMMO_ID_NAILS, 1);
        launch_spike(src, v_forward);

        self.punchangle_x = -2; // Original Nailgun single shot punchangle

    } else {
        // No ammo
        sound (self, CHAN_AUTO, "weapons/boltback.wav", 1, ATTN_NORM); // FQX standard empty sound
        
        W_BestWeapon(); 
        return;
    }

    // Player model animation handling:
    // For FQX, if player animations are driven differently, this might need adjustment later.
    // For now, this function focuses on projectile and sound.
}

//============================================================================
// Supporting functions from am_nails.qc (ensure these are available and forward-declared):
//
// void launch_spike(vector org, vector dir)
// - Spawns a standard spike projectile ('progs/spike.mdl').
// - Sets its touch to spike_touch().
// - Sets global 'newmis' to this new spike.
//
// void spike_touch()
// - Applies standard nail damage.
//
// void superspike_touch()
// - Applies super spike damage.
//
// Global entity newmis;
//============================================================================
// w_q_snailgun.qc - FQX Mod - Quake Super Nailgun - END
// ##Quedra: Version 1.1
//=============================================================================