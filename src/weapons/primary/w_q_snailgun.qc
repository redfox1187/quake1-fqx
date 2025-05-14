//============================================================================
// Weapon: Quake Super Nailgun (w_q_snailgun.qc)
// For FQX Mod - Preserving Original Behavior
//============================================================================

//============================================================================
// QUAKE SUPER NAILGUN - SETUP
//============================================================================
void w_q_snailgun_SetCurrentAmmo() {
    // Initialize weapon view, ammo, and fire modes
    // Using standard Quake Super Nailgun view model
    // AMMO_ID_NAILS should be defined in defs.qc for AM_ConsumeAmmo and AM_InitializeWeaponView
    // IT_SLOT_HEAVY is a placeholder for the slot type this weapon would occupy if active.
    AM_InitializeWeaponView("progs/v_nail2.mdl", AMMO_ID_NAILS, IT_SLOT_HEAVY);

    // The Super Nailgun has one primary mode of operation.
    AM_InitWeaponFireModes(1, FALSE); // 1 standard mode, no debug mode support

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

        // launch_spike(origin, direction)
        // Fire a single, centered super spike projectile that is then modified.
        // The original Super Nailgun was accurate.
        launch_spike(src, v_forward); // v_forward is already normalized from makevectors()

        // Customize the just-launched spike (newmis) to be a super spike
        if (newmis) {
            newmis.classname = "super_spike";
            newmis.touch = superspike_touch; // Assumes superspike_touch is defined in am_nails.qc or globally
            setmodel (newmis, "progs/s_spike.mdl"); // Standard Super Spike projectile model
            // newmis.owner = self; // launch_spike should handle setting the owner
        }

        self.punchangle_x = -5; // Original Super Nailgun volley punchangle

    } else if (self.ammo_nails >= 1) {
        // Not enough for volley, but has ammo - fire a single, centered standard nail
        sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM); // Standard Nailgun fire sound
        AM_ConsumeAmmo(AMMO_ID_NAILS, 1);

        // Fire a single, centered standard nail.
        launch_spike(src, v_forward);

        self.punchangle_x = -2; // Original Nailgun single shot punchangle

    } else {
        // No ammo - use an FQX standard empty sound if available
        sound (self, CHAN_AUTO, "weapons/boltback.wav", 1, ATTN_NORM); // "weapons/boltback.wav" is the FQX standard
                                                                    // Or use another sound if FQX has a different default.
                                                                    // If no specific FQX empty sound, original Quake often played nothing here.
        
        // Attempt to switch to best weapon (consistent with original W_FireSpikes behavior)
        // The Code Guide (sources [94], [97]) implies W_FireSpikes attempts to switch to best weapon.
        W_BestWeapon(); 
        return;
    }

    // Player model animation handling:
    // Original Quake would typically set self.state to a firing animation state from player.qc,
    // triggered by W_Attack calling the weapon's fire function.
    // For FQX, if player animations are driven differently, this might need adjustment later.
    // For now, this function focuses on projectile and sound.
    // Example: if player animations are still somewhat standard:
    // P_SetGunFrame(); // or similar function to cycle viewmodel animation if needed.
}

//============================================================================
// Supporting functions from am_nails.qc (ensure these are available):
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
// Global entity newmis; // Used by launch_spike and then modified here.
//============================================================================