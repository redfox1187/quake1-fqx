//============================================================================
// am_ebolt.qc - Energy Bolt Projectile System
// ##FQX - ##Quedra: Version 1.5 - Varmint crit visual, corrected TE_EXPLOSION2 for SDR.
//============================================================================

// --- Ebolt Entity Function Declarations ---
// ##Quedra: These are forward declared in defs_2.qc
// void() ebolt_touch;
// void() ebolt_think;
// void(float ebolt_type, float &damage, float &speed, string &mdl, string &impact_snd, string &crit_impact_snd, float &impact_efx_id, float &crit_impact_efx_id) get_ebolt_properties;

// --- Ebolt Type Definitions ---
// ##Quedra: These constants define the different types of energy bolts.
// ##Quedra: Values are used internally by this module via get_ebolt_properties.
float EBOLT_VARMINT   = 1; // RAHP-M1 Primary: Low damage, fast, chance of double damage.
float EBOLT_SDR       = 2; // Self Defense Round: RAHP-M1 Secondary proxy. More potent.
float EBOLT_COMBAT    = 3; // SMG/Carbine: Lethal, good for auto/burst. Medium range.
float EBOLT_WARRIFLE  = 4; // DMR: High damage, accurate, moderate RoF.
float EBOLT_BALLISTA  = 5; // Anti-Materiel: Very high damage, long range.

// --- Ebolt Property Constants ---
// ##Quedra: Models - Using a generic one for now.
string MODEL_EBOLT_GENERIC = "progs/laser.mdl";

// ##Quedra: Impact Sounds
string SOUND_IMPACT_VARMINT       = "weapons/ric1.wav";
string SOUND_IMPACT_VARMINT_CRIT  = "weapons/tink1.wav";    // Distinct sound for Varmint critical
string SOUND_IMPACT_SDR           = "enforcer/enfexpl.wav";
string SOUND_IMPACT_COMBAT        = "weapons/lghit1.wav";
string SOUND_IMPACT_WARRIFLE      = "hknight/hksht1.wav";
string SOUND_IMPACT_BALLISTA      = "weapons/r_exp3.wav";

// ##Quedra: Impact Effect Type Identifiers (for logic in ebolt_touch)
float IMPACT_EFX_VARMINT        = 1;
float IMPACT_EFX_SDR            = 2;
float IMPACT_EFX_COMBAT         = 3;
float IMPACT_EFX_WARRIFLE       = 4;
float IMPACT_EFX_BALLISTA       = 5;
float IMPACT_EFX_VARMINT_CRIT   = 6; // Visual for Varmint critical hit

// --- General Ebolt Constants ---
float EBOLT_LIFETIME = 4; // Seconds for projectile lifetime

//============================================================================
// ##Quedra: Ebolt Property Retrieval Function
//============================================================================
void(float ebolt_type, float &damage, float &speed, string &mdl, string &impact_snd, string &crit_impact_snd, float &impact_efx_id, float &crit_impact_efx_id) get_ebolt_properties =
{
    mdl = MODEL_EBOLT_GENERIC; // Universal model for now
    crit_impact_snd = "";      // Default to no specific critical impact sound
    crit_impact_efx_id = 0;    // Default to no specific critical impact visual (0 can mean "use normal")

    if (ebolt_type == EBOLT_VARMINT)
    {
        damage = 9;
        speed = 1500;
        impact_snd = SOUND_IMPACT_VARMINT;
        crit_impact_snd = SOUND_IMPACT_VARMINT_CRIT;
        impact_efx_id = IMPACT_EFX_VARMINT;
        crit_impact_efx_id = IMPACT_EFX_VARMINT_CRIT; // Specific visual for Varmint crits
    }
    else if (ebolt_type == EBOLT_SDR)
    {
        damage = 28;
        speed = 1200;
        impact_snd = SOUND_IMPACT_SDR;
        impact_efx_id = IMPACT_EFX_SDR;
        crit_impact_efx_id = impact_efx_id; // No special crit visual, use normal
    }
    else if (ebolt_type == EBOLT_COMBAT)
    {
        damage = 20;
        speed = 2000;
        impact_snd = SOUND_IMPACT_COMBAT;
        impact_efx_id = IMPACT_EFX_COMBAT;
        crit_impact_efx_id = impact_efx_id;
    }
    else if (ebolt_type == EBOLT_WARRIFLE)
    {
        damage = 45;
        speed = 3200;
        impact_snd = SOUND_IMPACT_WARRIFLE;
        impact_efx_id = IMPACT_EFX_WARRIFLE;
        crit_impact_efx_id = impact_efx_id;
    }
    else if (ebolt_type == EBOLT_BALLISTA)
    {
        damage = 125;
        speed = 5500;
        impact_snd = SOUND_IMPACT_BALLISTA;
        impact_efx_id = IMPACT_EFX_BALLISTA;
        crit_impact_efx_id = impact_efx_id;
    }
    else // Default to Varmint if unknown type
    {
        dprint("get_ebolt_properties: Unknown ebolt_type ");
        dprint(ftos(ebolt_type));
        dprint(", defaulting to VARMINT.\n");
        damage = 9;
        speed = 1500;
        impact_snd = SOUND_IMPACT_VARMINT;
        crit_impact_snd = SOUND_IMPACT_VARMINT_CRIT;
        impact_efx_id = IMPACT_EFX_VARMINT;
        crit_impact_efx_id = IMPACT_EFX_VARMINT_CRIT;
    }
};

//============================================================================
// ##Quedra: Ebolt Entity Logic
//============================================================================
/*
================
ebolt_touch
Handles collision of an energy bolt.
================
*/
void() ebolt_touch =
{
    local float damage_to_deal;
    local string current_impact_sound;
    local float current_impact_efx_id;

    if (other == self.owner) { remove(self); return; }
    if (other.solid == SOLID_TRIGGER) { return; }
    if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }

    damage_to_deal = self.dmg;
    current_impact_sound = self.noise_impact;        // Base impact sound set at launch
    current_impact_efx_id = self.impact_effect_field; // Base impact visual set at launch

    // ##Quedra: EBOLT_VARMINT 5% double damage chance & unique crit feedback
    if (self.ebolt_type_field == EBOLT_VARMINT)
    {
        if (random() < 0.05)
        {
            damage_to_deal = damage_to_deal * 2;
            if (self.noise_crit_impact != "") // Check if a specific crit sound is defined
            {
                current_impact_sound = self.noise_crit_impact;
            }
            if (self.crit_impact_effect_field != 0) // Check for specific crit visual
            {
                current_impact_efx_id = self.crit_impact_effect_field;
            }
        }
    }

    // ##Quedra: Play determined impact sound
    if (current_impact_sound != "")
    {
        sound(self, CHAN_AUTO, current_impact_sound, 1, ATTN_NORM);
    }

    // ##Quedra: Spawn determined visual impact effect
    if (current_impact_efx_id == IMPACT_EFX_VARMINT)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
    }
    else if (current_impact_efx_id == IMPACT_EFX_VARMINT_CRIT)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_EXPLOSION2);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
        WriteByte(MSG_BROADCAST, 215); // colorStart (bright yellow/orange)
        WriteByte(MSG_BROADCAST, 4);   // count (small, sharp burst)
    }
    else if (current_impact_efx_id == IMPACT_EFX_SDR)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_EXPLOSION2);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
        WriteByte(MSG_BROADCAST, 150); // colorStart (blueish)
        WriteByte(MSG_BROADCAST, 8);   // count
    }
    else if (current_impact_efx_id == IMPACT_EFX_COMBAT)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_TAREXPLOSION);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
    }
    else if (current_impact_efx_id == IMPACT_EFX_WARRIFLE)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_LIGHTNING1);
        WriteEntity(MSG_BROADCAST, self);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z - 16);
    }
    else if (current_impact_efx_id == IMPACT_EFX_BALLISTA)
    {
         WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_EXPLOSION);
         WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
    }
    else // Default effect if id is somehow unknown (should not happen if get_ebolt_properties is comprehensive)
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
    }

    // ##Quedra: Apply damage
    if (other.takedamage)
    {
        T_Damage(other, self, self.owner, damage_to_deal);
    }

    remove(self);
};

/*
================
ebolt_think
Handles ebolt lifetime.
================
*/
void() ebolt_think =
{
    remove(self); // ##Quedra: Simple removal after lifetime.
};

//============================================================================
// ##Quedra: Ebolt Spawning Logic
//============================================================================
/*
================
launch_ebolt
Creates a single ebolt entity with properties based on its type.
================
*/
entity(vector org, vector dir, float ebolt_type, entity source_ent) launch_ebolt =
{
    local entity bolt;
    local float l_dmg, l_speed, l_impact_efx_id, l_crit_impact_efx_id;
    local string l_mdl, l_impact_snd, l_crit_impact_snd;

    bolt = spawn();
    bolt.owner = source_ent;
    bolt.movetype = MOVETYPE_FLYMISSILE;
    bolt.solid = SOLID_BBOX;

    // ##Quedra: Fetch properties for this ebolt type
    get_ebolt_properties(ebolt_type, l_dmg, l_speed, l_mdl, l_impact_snd, l_crit_impact_snd, l_impact_efx_id, l_crit_impact_efx_id);

    bolt.dmg = l_dmg;
    bolt.velocity = dir * l_speed;
    setmodel(bolt, l_mdl);

    // ##Quedra: Store necessary fields on the projectile entity itself for use in ebolt_touch
    bolt.noise_impact = l_impact_snd;
    bolt.noise_crit_impact = l_crit_impact_snd;
    bolt.impact_effect_field = l_impact_efx_id;
    bolt.crit_impact_effect_field = l_crit_impact_efx_id;
    bolt.ebolt_type_field = ebolt_type;

    setsize(bolt, '0 0 0', '0 0 0');
    setorigin(bolt, org);

    bolt.angles = vectoangles(bolt.velocity);
    bolt.touch = ebolt_touch;
    bolt.think = ebolt_think;
    bolt.nextthink = time + EBOLT_LIFETIME;

    return bolt;
};

//============================================================================
// ##Quedra: Weapon Interface Function
//============================================================================
/*
================
W_am_fire_ebolt
Main function for weapons to fire an energy bolt.
Weapon provides the fire sound, accuracy, and recoil parameters.
================
*/
void(float ebolt_type, string p_fire_sound, float p_accuracy, float p_use_advanced_recoil, optional float p_recoil_str, optional float p_recoil_spr, optional float p_recoil_vert_bias, optional float p_recoil_sust_mult, optional float p_recoil_max_sust) W_am_fire_ebolt =
{
    local vector dir, fire_origin;
    local vector view_offset_forward, view_offset_right, view_offset_up;
    local float current_spread_factor, base_spread_value, spread_x, spread_y;

    // ##Quedra: Standard muzzle position calculation
    view_offset_forward = v_forward * 10;
    view_offset_right   = v_right * 3;
    view_offset_up      = v_up * -5;
    fire_origin = self.origin + self.view_ofs + view_offset_forward + view_offset_right + view_offset_up;

    // ##Quedra: Aiming & Spread calculation (from am_ballistics.qc)
    // ##Quedra: p_accuracy: 1.0 = perfect, lower (towards 0) = more spread.
    makevectors(self.v_angle);
    dir = v_forward; // Start with exact aim

    if (p_accuracy < 1.0 && p_accuracy >= 0) // Only apply spread if accuracy is not perfect
    {
        base_spread_value = 0.03; // Base cone factor
        if (p_accuracy > 0.001)
        {
            current_spread_factor = base_spread_value / p_accuracy;
        }
        else // Max spread for accuracy 0 or very near 0
        {
            current_spread_factor = base_spread_value / 0.01; // Effectively a very high spread
        }
        // Optional: Cap max spread: if (current_spread_factor > 0.2) current_spread_factor = 0.2;

        spread_x = (random() - 0.5) * current_spread_factor;
        spread_y = (random() - 0.5) * current_spread_factor;
        dir = dir + (v_right * spread_x) + (v_up * spread_y);
        dir = normalize(dir); // Ensure unit vector
    }

    // ##Quedra: Play weapon-specified firing sound
    if (p_fire_sound != "")
    {
        sound(self, CHAN_WEAPON, p_fire_sound, 1, ATTN_NORM);
    }

    // ##Quedra: Muzzle flash effect (generic)
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_GUNSHOT);
    WriteCoord(MSG_BROADCAST, fire_origin_x);
    WriteCoord(MSG_BROADCAST, fire_origin_y);
    WriteCoord(MSG_BROADCAST, fire_origin_z);
    // self.effects = self.effects | EF_MUZZLEFLASH; // If player viewmodel flash desired

    // ##Quedra: Launch the projectile
    launch_ebolt(fire_origin, dir, ebolt_type, self);

    // ##Quedra: Apply recoil
    if (p_use_advanced_recoil)
    {
        AM_ApplyRecoil(p_recoil_str, p_recoil_spr, p_recoil_vert_bias, p_recoil_sust_mult, p_recoil_max_sust);
    }
    else // Fallback to simple punchangle if advanced recoil not requested
    {
        if (ebolt_type == EBOLT_VARMINT) { self.punchangle_x = -0.2; }
        else if (ebolt_type == EBOLT_SDR) { self.punchangle_x = -0.8; }
        else if (ebolt_type == EBOLT_COMBAT) { self.punchangle_x = -0.5; }
        else if (ebolt_type == EBOLT_WARRIFLE) { self.punchangle_x = -1.2; }
        else if (ebolt_type == EBOLT_BALLISTA) { self.punchangle_x = -2.5; }
        else { self.punchangle_x = -0.2; } // Default for unknown types
    }
};
//============================================================================
// am_ebolt.qc - End of File
//============================================================================