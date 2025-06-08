//=============================================================================
// defs_fqx_declarations_systems.qc - FQX Mod - System Fwd Declarations
// Location: /src/
// ##FQX - ##Fox: Version 1.0.1
// ##Fox: Removed Loadout UI elements
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Consolidates forward declarations for general game logic and core
// ##Quedra: operational systems (op_* modules, UI, etc.).
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: Standard Game & Utility Functions (from defs_2.qc)
//-----------------------------------------------------------------------------
void(entity passed_body) CopyToBodyQueue;
const void(vector org, vector vel, float damage) SpawnBlood;
void(float damage) spawn_touchblood;
float() W_BestWeapon;
void() W_SetCurrentAmmo;
void() player_run;
string(string title) GetMapName;
void() bubble_bob;
void() ToggleMonsterCoreDebugPrints;
void() FQX_MasterPrecache;

//-----------------------------------------------------------------------------
// ##Quedra: Loadout & Operational Systems (from op_defs.qc & defs_2.qc)
//-----------------------------------------------------------------------------
// --- Data Accessors ---
string FQX_GetWeaponDisplayName(float weapon_id);
float FQX_GetWeaponSlotEligibility(float weapon_id);


// --- Core Loadout Functions ---
void(entity player) Loadout_EncodeParms;
void(entity player) Loadout_DecodeParms;
void(entity player) Loadout_SetDefaults;
float(entity p_player, float p_it_slot_flag) GetWeaponIDForITSlot;
float GetWeaponShellTypeID(float weapon_id);



//=============================================================================
// defs_fqx_declarations_systems.qc - FQX Mod - System Fwd Declarations - END
// ##FQX - ##Fox: Version 1.0.1
//=============================================================================