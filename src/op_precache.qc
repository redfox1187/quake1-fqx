//=============================================================================
// op_precache.qc - FQX Mod - Centralized Precache Management
// ##FQX - ##Quedra: Version 1.4.0
// ##Quedra: Consolidates precaching of game assets (models, sounds).
// ##Quedra: Called by worldspawn() in world.qc.
// ##Quedra: v1.1 - Added IDSOFT tags to relevant assets in FQX_Precache_Generic_Assets.
// ##Quedra:        Removed redundant zom_gib.mdl precache.
// ##Quedra: v1.2 - Added missing precache for weapons/lock4.wav.
// ##Quedra: v1.3 - Moved weapon-specific precaching from weapons.qc (W_Precache)
// ##Quedra:          into FQX_Precache_AllWeaponAssets() within this file.
// ##Quedra:          FQX_MasterPrecache now calls the local function.
// ##Quedra: v1.4.0 - ##Quedra: Added critical precaches for "progs/spike.mdl", "progs/s_spike.mdl"
// ##Quedra:          (fixes BFL-20250527-001 CTD). Also added other missing assets
// ##Quedra:          from compiler warnings (pkup.wav, scock.wav, change.wav, etc.).
//=============================================================================

//=============================================================================
// ##Quedra: Forward Declarations (for functions called by FQX_MasterPrecache)
//=============================================================================
// void MC_Precache_AllMonsters(void); // Example, to be defined if monster precaches are centralized [cite: 7]
// void FQX_Precache_AllItems(void); // Example, to be defined if item precaches are centralized [cite: 8]

void FQX_Precache_Generic_Assets(void);         // Defined below [cite: 9]
void FQX_Precache_AllWeaponAssets(void);      // Defined below [cite: 9]
void FQX_MasterPrecache(void);                // Defined below [cite: 9]

//=============================================================================
// ##Quedra: Specific Asset Group Precaching Functions
//=============================================================================

//-----------------------------------------------------------------------------
// FQX_Precache_Generic_Assets
// ##Quedra: Precaches common player models, sounds, gibs, and misc effects
// ##Quedra: previously located in world.qc -> worldspawn(). [cite: 10]
//-----------------------------------------------------------------------------
void FQX_Precache_Generic_Assets()
{
    // --- Player Models & Sounds ---
    precache_model("progs/player.mdl");       // ##IDSOFT - ##Quedra: Standard player model. [cite: 11]
    precache_model("progs/eyes.mdl");         // ##IDSOFT - ##Quedra: Player eyes model for invisibility. [cite: 11]
    precache_model("progs/h_player.mdl");     // ##IDSOFT - ##Quedra: Player head gib model. [cite: 12]
    precache_model("progs/gib1.mdl");         // ##IDSOFT - ##Quedra: Generic gib model 1. [cite: 12]
    precache_model("progs/gib2.mdl");         // ##IDSOFT - ##Quedra: Generic gib model 2. [cite: 13]
    precache_model("progs/gib3.mdl");         // ##IDSOFT - ##Quedra: Generic gib model 3. [cite: 14]

    precache_sound("player/plyrjmp8.wav");    // ##IDSOFT - ##Quedra: Player jump sound. [cite: 15]
    precache_sound("player/land.wav");        // ##IDSOFT - ##Quedra: Player normal landing sound. [cite: 15]
    precache_sound("player/land2.wav");       // ##IDSOFT - ##Quedra: Player hard landing/hurt sound. [cite: 15]
    precache_sound("player/drown1.wav");      // ##IDSOFT - ##Quedra: Player drowning pain sound 1. [cite: 16]
    precache_sound("player/drown2.wav");      // ##IDSOFT - ##Quedra: Player drowning pain sound 2. [cite: 17]
    precache_sound("player/gasp1.wav");       // ##IDSOFT - ##Quedra: Player gasping for air sound 1. [cite: 18]
    precache_sound("player/gasp2.wav");       // ##IDSOFT - ##Quedra: Player taking breath sound. [cite: 19]
    precache_sound("player/h2odeath.wav");    // ##IDSOFT - ##Quedra: Player drowning death sound. [cite: 19]
    precache_sound("player/teledth1.wav");    // ##IDSOFT - ##Quedra: Player telefrag death sound. [cite: 20]
    precache_sound("player/gib.wav");         // ##IDSOFT - ##Quedra: Player gib sound. [cite: 20]
    precache_sound("player/udeath.wav");      // ##IDSOFT - ##Quedra: Player ultraviolent death/gib sound. [cite: 21]
    precache_sound("player/tornoff2.wav");    // ##IDSOFT - ##Quedra: Player limb torn off sound. [cite: 21]
    precache_sound("player/pain1.wav");       // ##IDSOFT - ##Quedra: Player pain sound 1. [cite: 22]
    precache_sound("player/pain2.wav");       // ##IDSOFT - ##Quedra: Player pain sound 2. [cite: 23]
    precache_sound("player/pain3.wav");       // ##IDSOFT - ##Quedra: Player pain sound 3. [cite: 24]
    precache_sound("player/pain4.wav");       // ##IDSOFT - ##Quedra: Player pain sound 4. [cite: 25]
    precache_sound("player/pain5.wav");       // ##IDSOFT - ##Quedra: Player pain sound 5. [cite: 26]
    precache_sound("player/pain6.wav");       // ##IDSOFT - ##Quedra: Player pain sound 6. [cite: 27]
    precache_sound("player/death1.wav");      // ##IDSOFT - ##Quedra: Player death sound 1. [cite: 28]
    precache_sound("player/death2.wav");      // ##IDSOFT - ##Quedra: Player death sound 2. [cite: 29]
    precache_sound("player/death3.wav");      // ##IDSOFT - ##Quedra: Player death sound 3. [cite: 30]
    precache_sound("player/death4.wav");      // ##IDSOFT - ##Quedra: Player death sound 4. [cite: 31]
    precache_sound("player/death5.wav");      // ##IDSOFT - ##Quedra: Player death sound 5. [cite: 32]
    precache_sound("player/axhit1.wav");      // ##IDSOFT - ##Quedra: Axe hitting flesh sound. [cite: 33]
    precache_sound("player/h2ojump.wav");     // ##IDSOFT - ##Quedra: Player jumping into water sound. [cite: 33]
    precache_sound("player/slimbrn2.wav");    // ##IDSOFT - ##Quedra: Player entering slime sound. [cite: 34]
    precache_sound("player/inh2o.wav");       // ##IDSOFT - ##Quedra: Player entering water sound. [cite: 34]
    precache_sound("player/inlava.wav");      // ##IDSOFT - ##Quedra: Player entering lava sound. [cite: 35]
    precache_sound("player/lburn1.wav");      // ##IDSOFT - ##Quedra: Player lava burn sound 1. [cite: 35]
    precache_sound("player/lburn2.wav");      // ##IDSOFT - ##Quedra: Player lava burn sound 2. [cite: 36]

    // --- Generic Environment & Item Sounds (those not tied to specific weapon/monster/item files) ---
    precache_sound("demon/dland2.wav");       // ##IDSOFT - ##Quedra: Demon landing, often used as generic thud. [cite: 37]
    precache_sound("misc/h2ohit1.wav");       // ##IDSOFT - ##Quedra: Generic water splash sound. [cite: 38]
    precache_sound("items/itembk2.wav");      // ##IDSOFT - ##Quedra: Item respawn sound. [cite: 38]
    precache_sound("weapons/pkup.wav");       // ##IDSOFT - ##Quedra: Generic item/ammo pickup sound (compiler warning fix).
    precache_sound("misc/talk.wav");          // ##IDSOFT - ##Quedra: Trigger message talk sound. [cite: 38]
    precache_sound("misc/r_tele1.wav");       // ##IDSOFT - ##Quedra: Teleport sound variant 1. [cite: 39]
    precache_sound("misc/r_tele2.wav");       // ##IDSOFT - ##Quedra: Teleport sound variant 2. [cite: 40]
    precache_sound("misc/r_tele3.wav");       // ##IDSOFT - ##Quedra: Teleport sound variant 3. [cite: 41]
    precache_sound("misc/r_tele4.wav");       // ##IDSOFT - ##Quedra: Teleport sound variant 4. [cite: 42]
    precache_sound("misc/r_tele5.wav");       // ##IDSOFT - ##Quedra: Teleport sound variant 5. [cite: 43]
    precache_sound("weapons/lock4.wav");      // ##IDSOFT - ##Quedra: Ammo pickup sound. [cite: 44]
    precache_sound("misc/outwater.wav");      // ##IDSOFT - ##Quedra: Player leaving water sound. [cite: 44]
    precache_sound("misc/water1.wav");        // ##IDSOFT - ##Quedra: Swimming sound 1. [cite: 45]
    precache_sound("misc/water2.wav");        // ##IDSOFT - ##Quedra: Swimming sound 2. [cite: 46]
    
    // --- Generic Effect Models & Sounds ---
    precache_model("progs/s_bubble.spr");     // ##IDSOFT - ##Quedra: Drowning/underwater bubbles sprite. [cite: 47]
    precache_model("progs/lavaball.mdl");     // ##IDSOFT - ##Quedra: Model for misc_fireball. [cite: 47]
    // --- Sounds/Models for items that are not weapons ---
    precache_sound("items/armor1.wav");       // ##IDSOFT - ##Quedra: Armor pickup sound. [cite: 49]
    precache_model("progs/backpack.mdl");     // ##IDSOFT - ##Quedra: Backpack model for ammo. [cite: 50]
}

//-----------------------------------------------------------------------------
// FQX_Precache_AllWeaponAssets
// ##FQX - ##Quedra: Precaches all weapon-specific sounds and models.
// ##Quedra: Contents moved from W_Precache() in weapons.qc. [cite: 51]
//-----------------------------------------------------------------------------
void FQX_Precache_AllWeaponAssets()
{
    // ##IDSOFT: Original Quake Sounds (many are used by FQX weapons as placeholders or by original weapons)
    precache_sound ("weapons/r_exp3.wav");      // ##IDSOFT: new rocket explosion [cite: 52]
    precache_sound ("weapons/rocket1i.wav");    // ##IDSOFT: spike gun (Nailgun sound) [cite: 53]
    precache_sound ("weapons/sgun1.wav");       // ##IDSOFT: Shotgun fire (also used by original Rocket Launcher) [cite: 54]
    precache_sound ("weapons/guncock.wav");     // ##IDSOFT: Player shotgun cock/fire (used by Sawn-off/IZh-43 single) [cite: 55]
    precache_sound ("weapons/ric1.wav");        // ##IDSOFT: ricochet (used in c code) [cite: 56]
    precache_sound ("weapons/ric2.wav");        // ##IDSOFT: ricochet (used in c code) [cite: 57]
    precache_sound ("weapons/ric3.wav");        // ##IDSOFT: ricochet (used in c code) [cite: 58]
    precache_sound ("weapons/spike2.wav");      // ##IDSOFT: super spikes (Super Nailgun sound) [cite: 59]
    precache_sound ("weapons/tink1.wav");       // ##IDSOFT: spikes tink (used in c code) [cite: 60]
    precache_sound ("weapons/grenade.wav");     // ##IDSOFT: grenade launcher fire [cite: 61]
    precache_sound ("weapons/bounce.wav");      // ##IDSOFT: grenade bounce [cite: 61]
    precache_sound ("weapons/shotgn2.wav");     // ##IDSOFT: super shotgun fire (used by Sawn-off/IZh-43 double) [cite: 62]
    precache_sound ("player/axhit2.wav");      // ##IDSOFT: Axe wall hit sound [cite: 63]
    precache_sound ("weapons/ax1.wav");        // ##IDSOFT: Axe swing sound [cite: 64]
    precache_sound ("items/damage3.wav");       // ##IDSOFT: Quad damage loop [cite: 64]
    precache_sound ("weapons/lstart.wav");     // ##IDSOFT: Lightning gun start [cite: 65]
    precache_sound ("weapons/lhit.wav");        // ##IDSOFT: Lightning gun hit loop [cite: 66]
    
    // ##IDSOFT: Original Quake Models (some may be FQX replacements or fallbacks)
    precache_model ("progs/v_axe.mdl");         // ##IDSOFT [cite: 67]
    precache_model ("progs/missile.mdl");       // ##IDSOFT: Rocket projectile [cite: 67]
    precache_model ("progs/grenade.mdl");       // ##IDSOFT: Grenade projectile [cite: 67]
    precache_model ("progs/s_explod.spr");      // ##IDSOFT [cite: 68]
    precache_model ("progs/zom_gib.mdl");       // ##IDSOFT [cite: 68] // Already in FQX_Precache_Generic_Assets if truly generic, or monster specific

    // ##Quedra: Original Quake view models still used by AUX slots or potentially as fallbacks
    precache_model ("progs/v_shot.mdl");        // ##IDSOFT: Original Shotgun viewmodel [cite: 69]
    precache_model ("progs/v_shot2.mdl");       // ##IDSOFT: Original Super Shotgun viewmodel [cite: 70]
    precache_model ("progs/v_nail.mdl");        // ##IDSOFT: Original Nailgun viewmodel [cite: 71]
    precache_model ("progs/v_nail2.mdl");       // ##IDSOFT: Original Super Nailgun viewmodel [cite: 72]
    precache_model ("progs/v_rock.mdl");        // ##IDSOFT: Original Grenade Launcher viewmodel (often shares with RL) [cite: 73]
    precache_model ("progs/v_rock2.mdl");       // ##IDSOFT: Original Rocket Launcher viewmodel (for IT_SLOT_AUX1) [cite: 74]
    precache_model ("progs/v_light.mdl");       // ##IDSOFT: Original Lightning Gun viewmodel (for IT_SLOT_AUX2) [cite: 75]

    // ##FQX: Enforcer Laser (if used by any entity)
    precache_sound ("enforcer/enfire.wav");     // ##IDSOFT [cite: 76]
    precache_model ("progs/laser.mdl");         // ##IDSOFT [cite: 76]

    // ##FQX: Custom Weapon View Models
    precache_model ("progs/v_rahpm1.mdl");      // ##FQX [cite: 77]
    precache_model ("progs/v_doublebarrel.mdl"); // ##FQX [cite: 77]
    precache_model ("progs/v_sawnoff.mdl");     // ##FQX: Precaching new Sawn-off model [cite: 77]
    precache_model ("progs/v_ump45.mdl");       // ##FQX [cite: 78]
    precache_model ("progs/v_ak47.mdl");        // ##FQX [cite: 78]
    
    // ##FQX: Projectile Models
    precache_model ("progs/bit.mdl");           // ##FQX: For buckshot pellet [cite: 78]
    precache_model ("progs/bullet.mdl");        // ##FQX: For ballistic bullet [cite: 79]
    // ##FQX - ##Quedra: Spike Trap Projectile Models (CRITICAL FIX for CTD BFL-20250527-001)
    precache_model("progs/spike.mdl");          // ##FQX: Standard spike projectile model
    precache_model("progs/s_spike.mdl");        // ##FQX: Super spike projectile model

    // ##FQX: Weapon Sounds (many already covered by IDSOFT originals)
    precache_sound ("weapons/ump45-1.wav");     // ##FQX [cite: 80]
    precache_sound ("weapons/boltback.wav");    // ##FQX [cite: 80]
    precache_sound ("weapons/weaponclick.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/ak47-fire-1.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/ak47-fire-2.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/ak47_switch.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/9mm_Pistol-1.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/9mm_Pistol-2.wav"); // ##FQX [cite: 80]
    precache_sound ("weapons/9mm_Pistol_Switch-01.wav"); // ##FQX [cite: 81]
    
    // ##FQX - ##Quedra: Additional weapon sounds from compiler warnings
    precache_sound("weapons/scock.wav");        // ##FQX: Weapon cocking/handling sound (compiler warning fix)
    precache_sound("weapons/change.wav");       // ##FQX: Weapon change sound (compiler warning fix)
    precache_sound("weapons/weapon.wav");       // ##FQX: Generic weapon interaction sound (compiler warning fix)
    precache_sound("weapons/spike.wav");        // ##FQX: Standard nailgun/spike impact sound (compiler warning fix)

    // ##FQX: Grappling Hook Assets
    precache_model ("progs/grapple_anchor.mdl"); // ##FQX [cite: 82]
}

//-----------------------------------------------------------------------------
// FQX_MasterPrecache
// ##Quedra: Main precaching function to be called from worldspawn(). [cite: 83]
//-----------------------------------------------------------------------------
void FQX_MasterPrecache()
{
    if (cvar("developer") > 0) { dprint("FQX_MasterPrecache: Beginning asset precaching.\n"); }

    FQX_Precache_Generic_Assets();
    FQX_Precache_AllWeaponAssets();             // ##Quedra: Calls the local function for all weapon assets [cite: 84]

    // ##Quedra: Placeholder for centralized monster precaching
    // MC_Precache_AllMonsters(); // For now, individual monster precaches (like MC_Precache_Grunt in grunt.qc ) are called by their spawn functions. [cite: 85]
    // ##Quedra: Placeholder for centralized item precaching
    // FQX_Precache_AllItems(); // For now, item models/sounds are often precached with generic assets or where items are defined. [cite: 87]
    if (cvar("developer") > 0) { dprint("FQX_MasterPrecache: Asset precaching complete.\n"); } // [cite: 88]
}

//=============================================================================
// op_precache.qc - End of FQX Mod - Centralized Precache Management
// ##FQX - ##Quedra: Version 1.4.0
//=============================================================================