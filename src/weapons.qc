//=============================================================================
// weapons.qc - FQX Mod - Core Weapon Handling & Standard Implementations
// ##FQXCUSTOM - ##Quedra: Version 3.6.0
// ##Quedra: Based on id Software's original weapons.qc.
// ##Quedra: v3.6.0 - Refactored FQX_WeaponHasSufficientResource for shotguns to use
// ##Quedra:          GetShellResourceCost() based on weapon's SHELL_TYPE_PRIMARY.
// ##Quedra:        - Added GetWeaponShellTypeID() helper function.
// ##Quedra:        - W_HasNoAmmo now leverages refactored FQX_WeaponHasSufficientResource for mag weapons.
// ##Quedra:        - Requires WEAPON_XXX_SHELL_TYPE_PRIMARY constants to be globally accessible
// ##Quedra:          (ideally defined in defs_2.qc as e.g. SAWNOFF_DATA_SHELL_TYPE_PRIMARY)
// ##Quedra:          and GetShellResourceCost() forward declared in defs_2.qc.
// ##Quedra: v3.5 - Corrected W_SetCurrentAmmo for inactive IT_SLOT_UTILITY.
// ##Quedra:        - Corrected W_HasNoAmmo by removing AMMO_ID_NONE check.
// ##Quedra: v3.4 - Overhauled W_HasNoAmmo for FQX magazine and resource system.
// ##Quedra:        - Overhauled W_BestWeapon to Soldier's FQX specifications.
// ##Quedra:        - Added helper functions FQX_IsWeaponExplosive and FQX_WeaponHasSufficientResource (previous version).
// ##Quedra: v3.3 - Removed the empty W_Precache() function definition entirely.
// ##Quedra: v3.2 - W_Precache function content moved to FQX_Precache_AllWeaponAssets() in op_precache.qc.
// ##Quedra: v3.1 - Modified W_SetCurrentAmmo, W_Attack, and ToggleFireMode for IT_SLOT_PRIMARY.
// ##Quedra: v3.0 - Updated W_Precache to include original viewmodels used by AUX slots.
// ##Quedra: v2.9 - Added 'const' to SpawnBlood definition.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text)
    See file, 'COPYING', for details.
*/

//-----------------------------------------------------------------------------
// ##Quedra: Local Function Forward Declarations for weapons.qc
//-----------------------------------------------------------------------------
float() crandom;
void() W_FireAxe;
vector() wall_velocity;
void(vector org, vector vel) SpawnMeatSpray;
const void(vector org, vector vel, float damage) SpawnBlood;
void(float damage) spawn_touchblood;
void(vector org, vector vel) SpawnChunk;
void() ClearMultiDamage;
void() ApplyMultiDamage;
void(entity hit, float damage) AddMultiDamage;
void(float damage, vector dir) TraceAttack;
void(float shotcount, vector dir, vector spread) FireBullets;
void() s_explode1;
void() s_explode2; void() s_explode3; void() s_explode4; void() s_explode5; void() s_explode6;
void() BecomeExplosion;
void() T_MissileTouch;
void() W_FireRocket;
void(vector p1, vector p2, entity from, float damage) LightningDamage;
void() W_FireLightning;
void() GrenadeExplode;
void() GrenadeTouch;
void() W_FireGrenade;
void() W_SetCurrentAmmo;
float() W_BestWeapon;
float(entity playerEnt, float old, float new) W_WantsToChangeWeapon;
float() W_HasNoAmmo;
void() W_Attack;
void() W_ChangeWeapon;
void() CheatCommand;
void() ServerflagsCommand;
void() QuadCheat;
void() ToggleFireMode;
void() Quick_Grenade;
void(string msg) Quick_Melee_DebugPrint;
void() Quick_Melee_End;
void() Quick_Melee_FrameAdvance;
void() Quick_Melee_Start;
void() Quick_Melee_ToggleDebug;
void() Quick_Melee_ForceCancel;
void() ImpulseCommands;
void() W_WeaponFrame;
void() SuperDamageSound;

// ##FQXCUSTOM - ##Quedra: Helper function forward declarations
float FQX_IsWeaponExplosive(float weapon_id);
float FQX_WeaponHasSufficientResource(entity player, float check_weapon_id);
// float GetShellResourceCost(float shell_type_id); // ##Quedra: Defined in am_buckshot.qc, needs forward declaration in defs_2.qc
float GetWeaponShellTypeID(float weapon_id); // ##Quedra: New helper function defined below


//=============================================================================
// ##IDSOFT - ##Quedra: crandom - Standard utility
//=============================================================================
float() crandom =
{
    return 2 * (random() - 0.5);
};
//=============================================================================
// ##IDSOFT - ##Quedra: W_FireAxe - Standard Axe firing logic
//=============================================================================
void() W_FireAxe =
{
    local vector source;
    local vector org;

    makevectors (self.v_angle);
    source = self.origin + '0 0 16';
    traceline (source, source + v_forward * 64, FALSE, self);
    
    if (trace_fraction == 1.0) { return; } 
    
    org = trace_endpos - v_forward * 4;
    if (trace_ent.takedamage) 
    {
        trace_ent.axhitme = 1;
        SpawnBlood(org, '0 0 0', 20);
        T_Damage(trace_ent, self, self, 20);
    }
    else
    {   // hit wall
        sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, org_x);
        WriteCoord(MSG_BROADCAST, org_y);
        WriteCoord(MSG_BROADCAST, org_z); 
    }
};
//============================================================================
// ##IDSOFT - ##Quedra: wall_velocity - Standard utility for gibs
//============================================================================
vector() wall_velocity =
{
    local vector vel;
    vel = normalize(self.velocity); 
    vel = normalize(vel + v_up * (random() - 0.5) + v_right * (random() - 0.5));
    vel = vel + 2 * trace_plane_normal;
    vel = vel * 200; 
    return vel; 
};
//============================================================================
// ##IDSOFT - ##Quedra: SpawnMeatSpray - Standard gibbing effect
//============================================================================
void(vector org, vector vel) SpawnMeatSpray =
{
    local entity missile;
    missile = spawn(); 
    missile.owner = self;
    missile.movetype = MOVETYPE_BOUNCE; 
    missile.solid = SOLID_NOT;
    
    missile.velocity = vel;
    missile.velocity_z = missile.velocity_z + 250 + 50 * random();

    missile.avelocity = '3000 1000 2000';
    
    missile.nextthink = time + 1;
    missile.think = SUB_Remove; 

    setmodel(missile, "progs/zom_gib.mdl");
    setsize(missile, '0 0 0', '0 0 0');      
    setorigin(missile, org);
};
//============================================================================
// ##IDSOFT - ##Quedra: SpawnBlood - Standard blood spawning
//============================================================================
const void(vector org, vector vel, float damage) SpawnBlood =
{
    particle(org, vel * 0.1, 73, damage * 2);
};

//============================================================================
// ##IDSOFT - ##Quedra: spawn_touchblood - Helper for blood on touch
//============================================================================
void(float damage) spawn_touchblood =
{
    local vector vel;
    vel = wall_velocity() * 0.2;
    SpawnBlood(self.origin + vel * 0.01, vel, damage); 
};
//============================================================================
// ##IDSOFT - ##Quedra: SpawnChunk - Placeholder, original was empty
//============================================================================
void(vector org, vector vel) SpawnChunk =
{
    particle(org, vel * 0.02, 0, 10);
};

//==============================================================================
// ##IDSOFT - ##Quedra: MULTI-DAMAGE - System for combining small damage amounts
//==============================================================================
entity  multi_ent;
float   multi_damage;
void() ClearMultiDamage =
{
    multi_ent = world;
    multi_damage = 0; 
};
void() ApplyMultiDamage =
{
    if (multi_ent == world || multi_ent == self || !multi_ent) { return; } 
    T_Damage(multi_ent, self, self, multi_damage); 
};
void(entity hit, float damage) AddMultiDamage =
{
    if (!hit) { return; } 
    if (hit != multi_ent) { ApplyMultiDamage(); multi_damage = damage; multi_ent = hit; } 
    else { multi_damage = multi_damage + damage; } 
};
//==============================================================================
// ##IDSOFT - ##Quedra: BULLETS (TraceAttack based)
//==============================================================================
void(float damage, vector dir) TraceAttack =
{
    local vector org;
    org = trace_endpos - dir * 4;

    if (trace_ent.takedamage) 
    {
        SpawnBlood(org, dir * 50, damage);
        AddMultiDamage(trace_ent, damage);
    }
    else
    {
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_GUNSHOT);
        WriteCoord(MSG_BROADCAST, org_x);
        WriteCoord(MSG_BROADCAST, org_y);
        WriteCoord(MSG_BROADCAST, org_z); 
    }
};
void(float shotcount, vector dir, vector spread) FireBullets =
{
    local vector direction;
    local vector src; 

    makevectors(self.v_angle);
    src = self.origin + v_forward * 10;
    src_z = self.absmin_z + self.size_z * 0.7;  

    ClearMultiDamage();
    while (shotcount > 0) 
    {
        direction = dir + crandom() * spread_x * v_right + crandom() * spread_y * v_up;
        direction = normalize(direction);
        traceline(src, src + direction * 2048, FALSE, self);
        if (trace_fraction != 1.0) { TraceAttack(4, direction); } 
        shotcount = shotcount - 1;
    }
    ApplyMultiDamage(); 
};
//==============================================================================
// ##IDSOFT - ##Quedra: ROCKETS
//==============================================================================
void() s_explode1 = { self.frame = 0; self.nextthink = time + 0.1; self.think = s_explode2; };
void() s_explode2 = { self.frame = 1; self.nextthink = time + 0.1; self.think = s_explode3; };
void() s_explode3 = { self.frame = 2; self.nextthink = time + 0.1; self.think = s_explode4; };
void() s_explode4 = { self.frame = 3; self.nextthink = time + 0.1; self.think = s_explode5; };
void() s_explode5 = { self.frame = 4; self.nextthink = time + 0.1; self.think = s_explode6; };
void() s_explode6 = { self.frame = 5; self.nextthink = time + 0.1; self.think = SUB_Remove; };
void() BecomeExplosion =
{
    self.movetype = MOVETYPE_NONE; self.velocity = '0 0 0'; self.touch = SUB_Null;
    setmodel(self, "progs/s_explod.spr");
    self.solid = SOLID_NOT; s_explode1(); 
};
void() T_MissileTouch =
{
    local float damg; 
    if (other == self.owner) { return; } 
    if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; } 
    damg = 100 + random() * 20;
    if (other.health) { if (other.classname == "monster_shambler") { damg = damg * 0.5; } T_Damage(other, self, self.owner, damg); } 
    T_RadiusDamage(self, self.owner, 120, other);
    self.origin = self.origin - 8 * normalize(self.velocity);  
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z); 
    BecomeExplosion();
};

void() W_FireRocket =
{
    local entity missile;
    self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
    sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);  
    self.punchangle_x = -2;
    missile = spawn(); missile.owner = self; missile.movetype = MOVETYPE_FLYMISSILE; missile.solid = SOLID_BBOX; missile.classname = "missile";
    makevectors(self.v_angle); missile.velocity = aim(self, 1000);
    missile.velocity = missile.velocity * 1000; missile.angles = vectoangles(missile.velocity);
    missile.touch = T_MissileTouch; missile.nextthink = time + 5; missile.think = SUB_Remove;
    setmodel(missile, "progs/missile.mdl"); setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, self.origin + v_forward * 8 + '0 0 16');  
};
//===============================================================================
// ##IDSOFT - ##Quedra: LIGHTNING
//===============================================================================
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
    local entity e1, e2;
    local vector f_spread, beam_dir; 
    beam_dir = normalize(p2 - p1); f_spread_x = -beam_dir_y; f_spread_y = beam_dir_x;
    f_spread_z = 0;
    f_spread = normalize(f_spread) * 16; 
    e1 = e2 = world;
    traceline(p1, p2, FALSE, from);
    if (trace_ent.takedamage) { particle(trace_endpos, '0 0 100', 225, damage * 4); T_Damage(trace_ent, from, from, damage); } 
    e1 = trace_ent;
    traceline(p1 + f_spread, p2 + f_spread, FALSE, from);
    if (trace_ent != e1 && trace_ent.takedamage) { particle(trace_endpos, '0 0 100', 225, damage * 4); T_Damage(trace_ent, from, from, damage); } 
    e2 = trace_ent;
    traceline(p1 - f_spread, p2 - f_spread, FALSE, from);
    if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage) { particle(trace_endpos, '0 0 100', 225, damage * 4); T_Damage(trace_ent, from, from, damage); } 
};

void() W_FireLightning =
{
    local vector org; local float cells_consumed;
    if (self.ammo_cells < 1) { self.weapon = W_BestWeapon(); W_SetCurrentAmmo(); return; } 
    if (self.waterlevel > 1) { cells_consumed = self.ammo_cells; self.ammo_cells = 0; W_SetCurrentAmmo(); T_RadiusDamage(self, self, 35 * cells_consumed, world); return; } 
    if (self.t_width < time) { sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM); self.t_width = time + 0.6; } 
    self.punchangle_x = -2;
    self.currentammo = self.ammo_cells = self.ammo_cells - 1;
    org = self.origin + '0 0 16'; makevectors(self.v_angle);
    traceline(org, org + v_forward * 600, TRUE, self);  
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_LIGHTNING2); WriteEntity(MSG_BROADCAST, self);
    WriteCoord(MSG_BROADCAST, org_x); WriteCoord(MSG_BROADCAST, org_y); WriteCoord(MSG_BROADCAST, org_z); WriteCoord(MSG_BROADCAST, trace_endpos_x); WriteCoord(MSG_BROADCAST, trace_endpos_y); WriteCoord(MSG_BROADCAST, trace_endpos_z);
    LightningDamage(org, trace_endpos + v_forward * 4, self, 30);  
};
//=============================================================================
// ##IDSOFT - ##Quedra: GRENADES
//=============================================================================
void() GrenadeExplode =
{
    T_RadiusDamage(self, self.owner, 120, world);
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY); WriteByte(MSG_BROADCAST, TE_EXPLOSION); WriteCoord(MSG_BROADCAST, self.origin_x); WriteCoord(MSG_BROADCAST, self.origin_y); WriteCoord(MSG_BROADCAST, self.origin_z);
    BecomeExplosion();  
};
void() GrenadeTouch =
{
    if (other == self.owner) { return; } 
    if (other.takedamage == DAMAGE_AIM) { GrenadeExplode(); return; } 
    sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0') { self.avelocity = '0 0 0'; }  
};
void() W_FireGrenade =
{
    local entity missile;
    self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
    sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);  
    self.punchangle_x = -2;
    missile = spawn(); missile.owner = self; missile.movetype = MOVETYPE_BOUNCE; missile.solid = SOLID_BBOX; missile.classname = "grenade";
    makevectors(self.v_angle); 
    if (self.v_angle_x) { missile.velocity = v_forward * 600 + v_up * 200 + crandom() * v_right * 10 + crandom() * v_up * 10; } 
    else { missile.velocity = aim(self, 10000); missile.velocity = missile.velocity * 600; missile.velocity_z = 200; } 
    missile.avelocity = '300 300 300'; missile.angles = vectoangles(missile.velocity);
    missile.touch = GrenadeTouch;
    missile.nextthink = time + 2.5; missile.think = GrenadeExplode;
    setmodel(missile, "progs/grenade.mdl"); setsize(missile, '0 0 0', '0 0 0'); setorigin(missile, self.origin);  
};
//===============================================================================
// ##FQXCUSTOM - ##Quedra: PLAYER WEAPON SELECTION & SETUP
//===============================================================================
void() W_SetCurrentAmmo =
{
    player_run(); self.weaponframe = 0;
    self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
    if (self.weapon == IT_SLOT_MELEE) { self.currentammo = 0; self.weaponmodel = "progs/v_axe.mdl"; } 
    else if (self.weapon == IT_SLOT_HOLDOUT)  
    {
        local float holdout_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT);
        if (holdout_weapon_id == WEAPON_ID_M93R) { w_m93r_SetCurrentAmmo(); } 
        else if (holdout_weapon_id == WEAPON_ID_RAHPM1) { w_rahpm1_SetCurrentAmmo(); } 
        else { w_rahpm1_SetCurrentAmmo(); } 
    }
    else if (self.weapon == IT_SLOT_SECONDARY)  
    {
        local float secondary_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_SECONDARY);
        if (secondary_weapon_id == WEAPON_ID_SAWNOFF) { w_sawnoff_SetCurrentAmmo(); }
        else if (secondary_weapon_id == WEAPON_ID_IZH43) { w_izh43_SetCurrentAmmo(); } 
        else { w_izh43_SetCurrentAmmo(); } 
    }
    else if (self.weapon == IT_SLOT_PRIMARY) 
    {
        local float primary_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_PRIMARY);
        if (primary_weapon_id == WEAPON_ID_IZH43) { w_izh43_SetCurrentAmmo(); }
        else if (primary_weapon_id == WEAPON_ID_UMP45) { w_ump45_SetCurrentAmmo(); }
        else { w_ump45_SetCurrentAmmo(); } 
    } 
    else if (self.weapon == IT_SLOT_HEAVY) 
    { 
        local float heavy_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HEAVY);
        if (heavy_weapon_id == WEAPON_ID_AK47) { w_ak47_SetCurrentAmmo(); }
        else { w_ak47_SetCurrentAmmo(); } 
    } 
    else if (self.weapon == IT_SLOT_UTILITY) 
    { 
        self.currentammo = 0; self.weaponmodel = "progs/v_axe.mdl";
    } 
    else if (self.weapon == IT_SLOT_AUX1) { self.currentammo = self.ammo_rockets; self.weaponmodel = "progs/v_rock2.mdl"; self.items = self.items | IT_ROCKETS; } 
    else if (self.weapon == IT_SLOT_AUX2) { self.currentammo = self.ammo_cells; self.weaponmodel = "progs/v_light.mdl"; self.items = self.items | IT_CELLS; } 
    else { self.currentammo = 0; self.weaponmodel = string_null; } 
};

//-----------------------------------------------------------------------------
// ##FQXCUSTOM - ##Quedra: FQX_IsWeaponExplosive (Helper Function for v3.4)
//-----------------------------------------------------------------------------
float FQX_IsWeaponExplosive(float weapon_id)
{
    if (weapon_id == WEAPON_ID_RL) { return TRUE; }
    // if (weapon_id == WEAPON_ID_GL) { return TRUE; } // Example for future Grenade Launcher ID
    return FALSE;
}

//-----------------------------------------------------------------------------
// ##FQXCUSTOM - ##Quedra: Helper: GetWeaponShellTypeID (v3.6.0)
// Desc: Returns the primary SHELL_TYPE_* ID for a given shotgun weapon ID.
// Note: This function assumes constants like WEAPON_SAWNOFF_SHELL_TYPE_PRIMARY 
//       are made globally accessible (e.g., defined in defs_2.qc as 
//       SAWNOFF_DATA_SHELL_TYPE_PRIMARY). This is a placeholder for that system.
//       Alternatively, these values could be hardcoded here if they are fixed.
//-----------------------------------------------------------------------------
float GetWeaponShellTypeID(float weapon_id)
{
    if (weapon_id == WEAPON_ID_SAWNOFF) 
    { 
        // TODO_FQX: Replace with global constant like SAWNOFF_DATA_SHELL_TYPE_PRIMARY from defs_2.qc
        return SHELL_TYPE_12G_000BUCK; // Assuming Sawn-off uses 000Buck by default for this lookup
    }
    else if (weapon_id == WEAPON_ID_IZH43)
    {
        // TODO_FQX: Replace with global constant like IZH43_DATA_SHELL_TYPE_PRIMARY from defs_2.qc
        return SHELL_TYPE_12G_000BUCK; // Assuming IZh-43 uses 000Buck by default for this lookup
    }
    // Add other FQX shotguns here if they use specific shell types that dictate resource cost
    
    // dprint("GetWeaponShellTypeID: Unhandled weapon_id or not a shell-based shotgun: "); dprint(ftos(weapon_id)); dprint("\n");
    return 0; // Return 0 or a specific "INVALID_SHELL_TYPE" to indicate not applicable
}

//-----------------------------------------------------------------------------
// ##FQXCUSTOM - ##Quedra: FQX_WeaponHasSufficientResource (v3.6.0 - Refactored for shotguns)
//-----------------------------------------------------------------------------
float FQX_WeaponHasSufficientResource(entity player, float check_weapon_id)
{
    if (check_weapon_id == WEAPON_ID_AXE) { return TRUE; }

    local float resource_id_for_weapon;
    local float cost_per_round;

    // Determine primary resource ID for the weapon
    // This section can be expanded or use a helper like GetWeaponDefinedAmmoResourceID(check_weapon_id)
    // For now, direct checks for known FQX weapons:
    if (check_weapon_id == WEAPON_ID_SAWNOFF || check_weapon_id == WEAPON_ID_IZH43 || check_weapon_id == WEAPON_ID_M93R)
    { resource_id_for_weapon = AMMO_ID_SHELLS; }
    else if (check_weapon_id == WEAPON_ID_UMP45 || check_weapon_id == WEAPON_ID_AK47)
    { resource_id_for_weapon = AMMO_ID_NAILS; }
    else if (check_weapon_id == WEAPON_ID_RAHPM1 || check_weapon_id == WEAPON_ID_LG)
    { resource_id_for_weapon = AMMO_ID_CELLS; }
    else if (check_weapon_id == WEAPON_ID_GRAPPLE || check_weapon_id == WEAPON_ID_RL)
    { resource_id_for_weapon = AMMO_ID_ROCKETS; }
    else
    {
        // dprint("FQX_WeaponHasSufficientResource: Unknown weapon ID for resource check: "); dprint(ftos(check_weapon_id)); dprint("\n");
        return FALSE; // Cannot determine resource type
    }

    // Handle shotguns with new shell-type based cost
    if (resource_id_for_weapon == AMMO_ID_SHELLS && (check_weapon_id == WEAPON_ID_SAWNOFF || check_weapon_id == WEAPON_ID_IZH43))
    {
        local float specific_shell_type_id = GetWeaponShellTypeID(check_weapon_id);
        if (specific_shell_type_id == 0) // Safety check if shell type couldn't be determined
        {
            // dprint("FQX_WeaponHasSufficientResource: Could not determine shell type for weapon ID: "); dprint(ftos(check_weapon_id)); dprint("\n");
            return FALSE; 
        }
        cost_per_round = GetShellResourceCost(specific_shell_type_id); // Func from am_buckshot.qc (needs fwd decl)
        if (player.ammo_shells >= cost_per_round) { return TRUE; }
    }
    // Retain simplified logic for other existing FQX weapons (can be refactored later if they adopt complex costs)
    else if (resource_id_for_weapon == AMMO_ID_SHELLS) // e.g. M93R
    {
        if (player.ammo_shells >= 1) { return TRUE; } // Placeholder: Assumes 1 shell resource if not SawnOff/IZh43
    }
    else if (resource_id_for_weapon == AMMO_ID_NAILS)
    {
        if (player.ammo_nails >= 1) { return TRUE; } // Assumes 1 nail per mag round for UMP45/AK47
    }
    else if (resource_id_for_weapon == AMMO_ID_CELLS)
    {
        if (player.ammo_cells >= 1) { return TRUE; } // Assumes 1 cell for RAHPM1 (SDR) / LG
    }
    else if (resource_id_for_weapon == AMMO_ID_ROCKETS)
    {
        if (player.ammo_rockets >= 1) { return TRUE; } // Assumes 1 rocket for Grapple/RL
    }
    
    return FALSE; 
}

//-----------------------------------------------------------------------------
// ##FQXCUSTOM - ##Quedra: W_BestWeapon - Overhauled for FQX (v3.4)
//-----------------------------------------------------------------------------
float() W_BestWeapon =
{
    local float it = self.items;
    local float current_slot_weapon_id;

    if (self.quick_melee_active == TRUE) { Quick_Melee_End(); }

    if (it & IT_SLOT_HOLDOUT) {
        current_slot_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT);
        if (current_slot_weapon_id != WEAPON_ID_NONE && !FQX_IsWeaponExplosive(current_slot_weapon_id)) {
            if (FQX_WeaponHasSufficientResource(self, current_slot_weapon_id)) { return IT_SLOT_HOLDOUT; } } }
    if (it & IT_SLOT_PRIMARY) {
        current_slot_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_PRIMARY);
        if (current_slot_weapon_id != WEAPON_ID_NONE && !FQX_IsWeaponExplosive(current_slot_weapon_id)) {
            if (FQX_WeaponHasSufficientResource(self, current_slot_weapon_id)) { return IT_SLOT_PRIMARY; } } }
    if (it & IT_SLOT_SECONDARY) {
        current_slot_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_SECONDARY);
        if (current_slot_weapon_id != WEAPON_ID_NONE && !FQX_IsWeaponExplosive(current_slot_weapon_id)) {
            if (FQX_WeaponHasSufficientResource(self, current_slot_weapon_id)) { return IT_SLOT_SECONDARY; } } }
    if (it & IT_SLOT_HEAVY) { 
        current_slot_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HEAVY);
        if (current_slot_weapon_id != WEAPON_ID_NONE && !FQX_IsWeaponExplosive(current_slot_weapon_id)) {
            if (FQX_WeaponHasSufficientResource(self, current_slot_weapon_id)) { return IT_SLOT_HEAVY; } } }
    return IT_SLOT_MELEE;
};
//-----------------------------------------------------------------------------
// ##IDSOFT - ##Quedra: W_WantsToChangeWeapon
//-----------------------------------------------------------------------------
float(entity playerEnt, float old, float new) W_WantsToChangeWeapon =
{
    return 1;
};
//============================================================================
// ##FQXCUSTOM - ##Quedra: W_HasNoAmmo - (v3.6.0 - Now leverages refactored FQX_WeaponHasSufficientResource)
//============================================================================
float() W_HasNoAmmo =
{
    local float current_weapon_slot = self.weapon;
    local float current_weapon_id = GetWeaponIDForITSlot(self, current_weapon_slot);

    if (current_weapon_slot == IT_SLOT_MELEE) { return FALSE; }

    // For Utility slot, specifically grapple for now
    if (current_weapon_slot == IT_SLOT_UTILITY) 
    {
        if (current_weapon_id == WEAPON_ID_GRAPPLE) 
        {
             if (!FQX_WeaponHasSufficientResource(self, current_weapon_id))
             {
                sprint(self, PRINT_LOW, "$qc_not_enough_ammo\n");
                self.weapon = W_BestWeapon();
                self.weapon_first_draw_init = TRUE; 
                W_SetCurrentAmmo(); 
                return TRUE;
             }
             return FALSE;
        }
        return FALSE; // Other utility might not use ammo this way or not yet defined
    }
    
    // FQX Magazine Weapons Check
    if (self.current_weapon_max_mag_capacity > 0) 
    {
        if (self.weapon_ammo_in_magazine > 0) // Has rounds in magazine
        {
            return FALSE;
        }
        else // Magazine is empty, check if can reload from global resource
        {
            if (FQX_WeaponHasSufficientResource(self, current_weapon_id))
            {
                 // Can reload (has enough global ammo for at least one mag round)
                return FALSE; 
            }
            else // Cannot reload from global ammo
            {
                sprint(self, PRINT_LOW, "$qc_not_enough_ammo\n");
                self.weapon = W_BestWeapon(); // Switch to best available
                self.weapon_first_draw_init = TRUE; 
                W_SetCurrentAmmo(); 
                return TRUE; // Truly out of ammo
            }
        }
    }
    // Standard (Non-FQX Magazine) Weapon Check (e.g. original Quake RL, LG if any remain with this logic)
    else if (self.currentammo <= 0) 
    {
        sprint(self, PRINT_LOW, "$qc_not_enough_ammo\n");
        self.weapon = W_BestWeapon();
        self.weapon_first_draw_init = TRUE; 
        W_SetCurrentAmmo(); 
        return TRUE;
    }

    return FALSE; 
};
//============================================================================
// ##FQXCUSTOM - ##Quedra: W_Attack
//============================================================================
void() player_axe1; void() player_axeb1; void() player_axec1; void() player_axed1; 
void() player_shot1; void() player_nail1;
void() player_light1;
void() player_rocket1;
void() W_Attack =
{
    local float r; local float equipped_weapon_id;
    if (self.quick_melee_active == TRUE) { Quick_Melee_End(); return; }
    
    if (W_HasNoAmmo()) { return; }
    
    makevectors(self.v_angle);
    self.show_hostile = time + 1;
    if (!(self.weapon == IT_SLOT_MELEE || self.weapon == IT_SLOT_HOLDOUT)) { self.fired_weapon = 1; } 

    if (self.weapon == IT_SLOT_MELEE) { sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM); r = random();
        if (r < 0.25) { player_axe1(); } else if (r<0.5) { player_axeb1(); } else if (r<0.75) { player_axec1(); } else { player_axed1(); } self.attack_finished = time + 0.5; } 
    else if (self.weapon == IT_SLOT_HOLDOUT) { player_shot1(); equipped_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT);
        if (equipped_weapon_id == WEAPON_ID_M93R) { W_FireM93R(); } else if (equipped_weapon_id == WEAPON_ID_RAHPM1) { W_FireRahp(); } } 
    else if (self.weapon == IT_SLOT_SECONDARY) { player_shot1(); equipped_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_SECONDARY);
        if (equipped_weapon_id == WEAPON_ID_SAWNOFF) { W_FireSawnoff(); } else if (equipped_weapon_id == WEAPON_ID_IZH43) { W_FireIZH43(); } } 
    else if (self.weapon == IT_SLOT_PRIMARY) 
    { 
        player_shot1(); local float primary_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_PRIMARY);
        if (primary_weapon_id == WEAPON_ID_IZH43) { W_FireIZH43(); }
        else if (primary_weapon_id == WEAPON_ID_UMP45) { W_FireUMP45(); }
        else { W_FireUMP45(); } 
    } 
    else if (self.weapon == IT_SLOT_HEAVY) 
    { 
        player_shot1(); local float heavy_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HEAVY);
        if (heavy_weapon_id == WEAPON_ID_AK47) { W_FireAk47(); }
        else { W_FireAk47(); } 
    } 
    else if (self.weapon == IT_SLOT_UTILITY) 
    { 
        player_rocket1(); local float utility_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_UTILITY);
        if (utility_weapon_id == WEAPON_ID_GRAPPLE) { /* W_FireGrapple(); */ } 
    } 
    else if (self.weapon == IT_SLOT_AUX1) { player_rocket1(); W_FireRocket(); self.attack_finished = time + 0.8; } 
    else if (self.weapon == IT_SLOT_AUX2) { player_light1(); sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM); W_FireLightning(); } 
};

//============================================================================
// ##FQXCUSTOM - ##Quedra: W_ChangeWeapon
//============================================================================
void() W_ChangeWeapon =
{
    local float target_slot, ammo_check_needed;
    local float target_weapon_id; 
    
    target_slot = 0; ammo_check_needed = FALSE;

    if (self.impulse == 1) { target_slot = IT_SLOT_MELEE; } 
    else if (self.impulse == 2) { target_slot = IT_SLOT_HOLDOUT; ammo_check_needed = TRUE; }  
    else if (self.impulse == 3) { target_slot = IT_SLOT_SECONDARY; ammo_check_needed = TRUE; }     
    else if (self.impulse == 4) { target_slot = IT_SLOT_PRIMARY; ammo_check_needed = TRUE; }  
    else if (self.impulse == 5) { target_slot = IT_SLOT_HEAVY; ammo_check_needed = TRUE; }  
    else if (self.impulse == 6) { target_slot = IT_SLOT_UTILITY; ammo_check_needed = TRUE; } 
    else if (self.impulse == 7) { target_slot = IT_SLOT_AUX1; ammo_check_needed = TRUE; } 
    else if (self.impulse == 8) { target_slot = IT_SLOT_AUX2; ammo_check_needed = TRUE; } 
    
    if (target_slot == 0) { return; } 
    self.impulse = 0;

    if (!(self.items & target_slot)) { sprint(self, PRINT_LOW, "$qc_no_weapon\n"); return; } 
    
    if (ammo_check_needed == TRUE) 
    {
        target_weapon_id = GetWeaponIDForITSlot(self, target_slot); 
        if (target_weapon_id == WEAPON_ID_NONE) 
        {
            sprint(self, PRINT_LOW, "$qc_no_weapon\n"); return;
        }
        // ##Quedra v3.6.0: FQX_WeaponHasSufficientResource now handles the detailed check
        if (!FQX_WeaponHasSufficientResource(self, target_weapon_id))
        {
            sprint(self, PRINT_LOW, "$qc_not_enough_ammo\n"); return;
        }
    } 
    
    self.weapon_first_draw_init = TRUE;
    self.weapon = target_slot;
    W_SetCurrentAmmo();  
};

//============================================================================
// ##IDSOFT - ##Quedra: ServerflagsCommand & QuadCheat (Restored & Styled)
//============================================================================
void() ServerflagsCommand = { serverflags = serverflags * 2 + 1; }; 
void() QuadCheat = { if (cvar("developer") == 0 && (deathmatch || coop)) { return; } self.super_time = 1; self.super_damage_finished = time + 30; self.items = self.items | IT_QUAD; dprint("Quad Damage Cheat Activated!\n"); };
//============================================================================
// ##IDSOFT - ##Quedra: CheatCommand - For "impulse 9"
//============================================================================
void() CheatCommand = { if ((deathmatch || coop) && (cvar("developer") == 0)) { return; } self.ammo_rockets=100; self.ammo_nails=200; self.ammo_shells=100; self.ammo_cells=200; self.items = self.items | IT_SLOT_MELEE | IT_SLOT_HOLDOUT | IT_SLOT_SECONDARY | IT_SLOT_PRIMARY | IT_SLOT_HEAVY | IT_SLOT_UTILITY | IT_SLOT_AUX1 | IT_SLOT_AUX2 | IT_KEY1 | IT_KEY2 | IT_ARMOR3; self.armortype=0.8; self.armorvalue=200; self.weapon_first_draw_init = TRUE; self.weapon=IT_SLOT_AUX1; W_SetCurrentAmmo(); };
//============================================================================
// ##FQXCUSTOM - ##Quedra: ToggleFireMode
//============================================================================
void() ToggleFireMode =
{
    local float equipped_weapon_id;
    if (self.weapon == IT_SLOT_HOLDOUT) { equipped_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HOLDOUT); if (equipped_weapon_id == WEAPON_ID_M93R) { W_SwitchModeM93R(); } else if (equipped_weapon_id == WEAPON_ID_RAHPM1) { W_SwitchModeRahp(); } } 
    else if (self.weapon == IT_SLOT_SECONDARY) { equipped_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_SECONDARY); if (equipped_weapon_id == WEAPON_ID_SAWNOFF) { W_SwitchModeSawnoff(); } else if (equipped_weapon_id == WEAPON_ID_IZH43) { W_SwitchModeIZH43(); } } 
    else if (self.weapon == IT_SLOT_PRIMARY) 
    { 
        local float primary_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_PRIMARY);
        if (primary_weapon_id == WEAPON_ID_IZH43) { W_SwitchModeIZH43(); }
        else if (primary_weapon_id == WEAPON_ID_UMP45) { W_SwitchModeUMP45(); }
        else { sprint(self, PRINT_LOW, "Weapon has no alternate fire modes.\n"); } 
    } 
    else if (self.weapon == IT_SLOT_HEAVY) 
    { 
        local float heavy_weapon_id = GetWeaponIDForITSlot(self, IT_SLOT_HEAVY);
        if (heavy_weapon_id == WEAPON_ID_AK47) { W_SwitchModeAk47(); }
        else { sprint(self, PRINT_LOW, "Weapon has no alternate fire modes.\n");}
    } 
    else { sprint(self, PRINT_LOW, "Weapon has no alternate fire modes.\n"); } 
};
//============================================================================
// ##IDSOFT - ##Quedra: Quick Grenade
//============================================================================
void() Quick_Grenade = { if (self.ammo_rockets >= 1) { W_FireGrenade(); self.attack_finished = time + 0.6; } else { sprint(self, PRINT_LOW, "$qc_not_enough_ammo\n"); return; } };
//============================================================================
// ##FQXCUSTOM - ##Quedra: Quick Melee System
//============================================================================
void(string msg) Quick_Melee_DebugPrint = { if (self.quick_melee_debug == TRUE) { dprint("QuickMelee: "); dprint(msg); dprint("\n"); } }; 
void() Quick_Melee_End = { Quick_Melee_DebugPrint("Melee End start func"); if (self.quick_melee_active == TRUE && self.saved_weapon != 0) { self.think = SUB_Null; self.quick_melee_active = FALSE; self.quick_melee_sequence = 0; local float weapon_to_restore = self.saved_weapon; self.saved_weapon = 0; Quick_Melee_DebugPrint("Switching back to saved weapon"); player_run(); self.weapon_first_draw_init = TRUE; self.weapon = weapon_to_restore; W_SetCurrentAmmo(); } else { Quick_Melee_DebugPrint("End called but not active or no saved weapon"); self.quick_melee_active = FALSE; self.saved_weapon = 0; self.quick_melee_sequence = 0; self.think = SUB_Null; } }; 
void() Quick_Melee_FrameAdvance = { if (self.weaponframe < 3) { self.weaponframe = self.weaponframe + 1; if (self.weaponframe == 2) { W_FireAxe(); Quick_Melee_DebugPrint("Frame 2: Calling W_FireAxe()"); } self.think = Quick_Melee_FrameAdvance; self.nextthink = time + 0.1; } else { self.weaponframe = 0; Quick_Melee_End(); return; } }; 
void() Quick_Melee_Start = { Quick_Melee_DebugPrint("Start called"); if (self.weapon == IT_SLOT_MELEE) { Quick_Melee_DebugPrint("Already using axe, normal attack"); W_Attack(); return; } 
    if (self.quick_melee_active == TRUE) { Quick_Melee_DebugPrint("Already in quick melee, returning"); return; } 
    if (self.weapon != 0 && self.weapon != IT_SLOT_MELEE) { self.saved_weapon = self.weapon; self.quick_melee_active = TRUE; Quick_Melee_DebugPrint("Saved weapon and switching to axe"); self.weapon_first_draw_init = TRUE; self.weapon = IT_SLOT_MELEE; W_SetCurrentAmmo(); self.weaponframe = 0; sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM); self.think = Quick_Melee_FrameAdvance; self.nextthink = time + 0.05; } else { Quick_Melee_DebugPrint("No valid weapon to save for Quick Melee or already axe."); } };
void() Quick_Melee_ToggleDebug = { self.quick_melee_debug = !self.quick_melee_debug; if (self.quick_melee_debug == TRUE) { sprint(self, PRINT_LOW, "Quick Melee Debug: ON\n"); } else { sprint(self, PRINT_LOW, "Quick Melee Debug: OFF\n"); } }; 
void() Quick_Melee_ForceCancel = { self.quick_melee_active = FALSE; self.saved_weapon = 0; self.quick_melee_sequence = 0; self.think = SUB_Null; sprint(self, PRINT_LOW, "Quick Melee state reset.\n"); };
//============================================================================
// ##IDSOFT - ##Quedra: ImpulseCommands - Handles player impulses
//============================================================================
void() ImpulseCommands =
{
    if (self.impulse >= 1 && self.impulse <= 8) { W_ChangeWeapon(); } 
    else if (self.impulse == 9) { CheatCommand(); } 
    else if (self.impulse == 11) { ServerflagsCommand(); } 
    else if (self.impulse == 20) { Quick_Grenade(); }   
    else if (self.impulse == 21) { if(self.quick_melee_active != TRUE) Quick_Melee_Start(); } 
    else if (self.impulse == 22) { ToggleFireMode(); }  
    else if (self.impulse == 200) { Quick_Melee_ToggleDebug(); } 
    else if (self.impulse == 201) { Quick_Melee_ForceCancel(); } 
    else if (self.impulse == 255) { QuadCheat(); } 
    self.impulse = 0;
};

//============================================================================
// ##FQXCUSTOM - ##Quedra: W_WeaponFrame - Per-frame weapon logic
//============================================================================
void() W_WeaponFrame =
{
    if (time < self.attack_finished) 
    {
        if (self.button0) { self.weapon_fire_released = FALSE; } 
        else { AM_WeaponFrame_HandleFireRelease();
        if (self.burst_active == TRUE) { self.burst_active = FALSE; } } 
        return;
    }
    if (self.impulse != 0) { ImpulseCommands();
    if (time < self.attack_finished) { return; } } 
    if (self.button0) { SuperDamageSound(); W_Attack();
    } 
    else { AM_WeaponFrame_HandleFireRelease();
    if (self.burst_active == TRUE) { self.burst_active = FALSE; } } 
};
//============================================================================
// ##IDSOFT - ##Quedra: SuperDamageSound - Quad Damage sound effect
//============================================================================
void() SuperDamageSound =
{
    if (self.super_damage_finished > time) { if (self.super_sound < time) { self.super_sound = time + 1; sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM); } } 
    return; 
};
//=============================================================================
// weapons.qc - End of FQX Mod - Core Weapon Handling
// ##FQXCUSTOM - ##Quedra: Version 3.6.0
//=============================================================================