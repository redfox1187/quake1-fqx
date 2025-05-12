/*
==============================================================================
LOADOUT SYSTEM

This file manages the player's weapon loadout configuration, allowing for
dynamic weapon selection across multiple weapon slots.

Features:
- 2-digit IDs for each weapon (supporting up to 99 weapons)
- 9 weapon slots total
- Functions to configure and retrieve loadout information
- Integration with existing weapon system

==============================================================================
*/

// =========== LOADOUT CONSTANTS ============

// Define slot constants (these match the IT_SLOT_* constants in defs.qc)
float SLOT_MELEE       = 1;
float SLOT_HOLDOUT     = 2;
float SLOT_PRIMARY     = 3;
float SLOT_SECONDARY   = 4;
float SLOT_SPECIAL     = 5;
float SLOT_EXPLOSIVE   = 6;
float SLOT_MAGIC       = 7;
float SLOT_HEAVY       = 8;
float SLOT_EQUIPMENT   = 9;

// Total number of slots
float NUM_SLOTS = 9;

// =========== WEAPON CONSTANTS ============
// Weapon IDs - 2 digits per weapon

// SLOT_MELEE weapons (01-09)
float WPNID_AXE        = 1;
float WPNID_KNIFE      = 2;
float WPNID_MACHETE    = 3;
// Add more melee weapons as needed

// SLOT_HOLDOUT weapons (10-19)
float WPNID_RAHP       = 10;  // Republic Army Holdout Pistol
float WPNID_DEAGLE     = 11;  // Desert Eagle
float WPNID_PPISTOL    = 12;  // Plasma Pistol
// Add more holdout weapons as needed

// SLOT_PRIMARY weapons (20-29)
float WPNID_UMP45      = 20;  // UMP-45 SMG
float WPNID_M4         = 21;  // M4 Rifle
float WPNID_AK47       = 22;  // AK-47 Rifle
// Add more primary weapons as needed

// SLOT_SECONDARY weapons (30-39)
float WPNID_DBSHOT     = 30;  // Double Barrel Shotgun
float WPNID_AUTOSHOTTY = 31;  // Auto Shotgun
// Add more secondary weapons as needed

// Add constants for other slots (40-89)...

// =========== LOADOUT SYSTEM VARIABLES ============

// Fields to store the player's loadout
// These will be added to the entity struct automatically
// .float loadout_melee;    // Stores weapon ID for melee slot
// .float loadout_holdout;  // Stores weapon ID for holdout slot
// ...etc for all slots

// =========== LOADOUT SYSTEM FUNCTIONS ============

/*
================
LoadoutInit
Initialize a player's loadout with default weapons
Called during player spawn/initialization
================
*/
void() LoadoutInit =
{
    // Set default weapons for each slot
    self.loadout_melee = WPNID_AXE;          // Default melee: Axe
    self.loadout_holdout = WPNID_RAHP;       // Default holdout: RAHP
    self.loadout_primary = WPNID_UMP45;      // Default primary: UMP-45
    self.loadout_secondary = WPNID_DBSHOT;   // Default secondary: Double Barrel Shotgun
    self.loadout_special = 0;                // Default special: None
    self.loadout_explosive = 0;              // Default explosive: None
    self.loadout_magic = 0;                  // Default magic: None
    self.loadout_heavy = 0;                  // Default heavy: None
    self.loadout_equipment = 0;              // Default equipment: None
};

/*
================
LoadoutSetWeapon
Set a specific weapon to a specific slot
Parameters:
- slot: The slot to set (use SLOT_* constants)
- weapon_id: The ID of the weapon to place in that slot
================
*/
void(float slot, float weapon_id) LoadoutSetWeapon =
{
    if (slot == SLOT_MELEE)
        self.loadout_melee = weapon_id;
    else if (slot == SLOT_HOLDOUT)
        self.loadout_holdout = weapon_id;
    else if (slot == SLOT_PRIMARY)
        self.loadout_primary = weapon_id;
    else if (slot == SLOT_SECONDARY)
        self.loadout_secondary = weapon_id;
    else if (slot == SLOT_SPECIAL)
        self.loadout_special = weapon_id;
    else if (slot == SLOT_EXPLOSIVE)
        self.loadout_explosive = weapon_id;
    else if (slot == SLOT_MAGIC)
        self.loadout_magic = weapon_id;
    else if (slot == SLOT_HEAVY)
        self.loadout_heavy = weapon_id;
    else if (slot == SLOT_EQUIPMENT)
        self.loadout_equipment = weapon_id;
};

/*
================
LoadoutGetWeapon
Get the weapon ID for a specific slot
Parameters:
- slot: The slot to query (use SLOT_* constants)
Returns: The weapon ID in that slot
================
*/
float(float slot) LoadoutGetWeapon =
{
    if (slot == SLOT_MELEE)
        return self.loadout_melee;
    else if (slot == SLOT_HOLDOUT)
        return self.loadout_holdout;
    else if (slot == SLOT_PRIMARY)
        return self.loadout_primary;
    else if (slot == SLOT_SECONDARY)
        return self.loadout_secondary;
    else if (slot == SLOT_SPECIAL)
        return self.loadout_special;
    else if (slot == SLOT_EXPLOSIVE)
        return self.loadout_explosive;
    else if (slot == SLOT_MAGIC)
        return self.loadout_magic;
    else if (slot == SLOT_HEAVY)
        return self.loadout_heavy;
    else if (slot == SLOT_EQUIPMENT)
        return self.loadout_equipment;
    
    return 0; // Invalid slot or no weapon
};

/*
================
LoadoutGetCurrentWeapon
Get the weapon ID for the player's currently selected weapon/slot
Returns: The weapon ID of the current weapon
================
*/
float() LoadoutGetCurrentWeapon =
{
    if (self.weapon == IT_SLOT_MELEE)
        return self.loadout_melee;
    else if (self.weapon == IT_SLOT_HOLDOUT)
        return self.loadout_holdout;
    else if (self.weapon == IT_SLOT_PRIMARY)
        return self.loadout_primary;
    else if (self.weapon == IT_SLOT_SECONDARY)
        return self.loadout_secondary;
    else if (self.weapon == IT_SLOT_SPECIAL)
        return self.loadout_special;
    else if (self.weapon == IT_SLOT_EXPLOSIVE)
        return self.loadout_explosive;
    else if (self.weapon == IT_SLOT_MAGIC)
        return self.loadout_magic;
    else if (self.weapon == IT_SLOT_HEAVY)
        return self.loadout_heavy;
    else if (self.weapon == IT_SLOT_EQUIPMENT)
        return self.loadout_equipment;
    
    return 0; // Invalid weapon or no weapon
};

/*
================
LoadoutHasWeapon
Check if the player has a specific weapon in their loadout
Parameters:
- weapon_id: The ID of the weapon to check for
Returns: TRUE if the player has the weapon, FALSE otherwise
================
*/
float(float weapon_id) LoadoutHasWeapon =
{
    if (self.loadout_melee == weapon_id || 
        self.loadout_holdout == weapon_id || 
        self.loadout_primary == weapon_id || 
        self.loadout_secondary == weapon_id || 
        self.loadout_special == weapon_id || 
        self.loadout_explosive == weapon_id || 
        self.loadout_magic == weapon_id || 
        self.loadout_heavy == weapon_id || 
        self.loadout_equipment == weapon_id)
        return TRUE;
    
    return FALSE;
};

// ============= WEAPON FUNCTION DISPATCHERS =============

/*
================
LoadoutDispatchSetCurrentAmmo
Dispatches the W_SetCurrentAmmo call to the appropriate weapon function
based on the player's loadout configuration for the current slot
================
*/
void() LoadoutDispatchSetCurrentAmmo =
{
    float current_weapon = LoadoutGetCurrentWeapon();
    
    // Based on the current weapon ID, call the appropriate SetCurrentAmmo function
    if (current_weapon == WPNID_AXE)
        w_axe_SetCurrentAmmo();
    else if (current_weapon == WPNID_KNIFE)
        w_knife_SetCurrentAmmo();
    else if (current_weapon == WPNID_MACHETE)
        w_machete_SetCurrentAmmo();
    
    // SLOT_HOLDOUT weapons
    else if (current_weapon == WPNID_RAHP)
        w_rahpm1_SetCurrentAmmo();
    else if (current_weapon == WPNID_DEAGLE)
        w_deagle_SetCurrentAmmo();
    else if (current_weapon == WPNID_PPISTOL)
        w_ppistol_SetCurrentAmmo();
    
    // SLOT_PRIMARY weapons
    else if (current_weapon == WPNID_UMP45)
        w_ump45_SetCurrentAmmo();
    else if (current_weapon == WPNID_M4)
        w_m4_SetCurrentAmmo();
    else if (current_weapon == WPNID_AK47)
        w_ak47_SetCurrentAmmo();
    
    // SLOT_SECONDARY weapons
    else if (current_weapon == WPNID_DBSHOT)
        w_dbshot_SetCurrentAmmo();
    else if (current_weapon == WPNID_AUTOSHOTTY)
        w_autoshotty_SetCurrentAmmo();
    
    // Add more weapon cases as needed
    
    // Default/fallback for unknown weapons
    else
        W_SetCurrentAmmo(); // Original function as fallback
};

/*
================
LoadoutDispatchFire
Dispatches the weapon firing call to the appropriate weapon function
based on the player's loadout configuration for the current slot
================
*/
void() LoadoutDispatchFire =
{
    float current_weapon = LoadoutGetCurrentWeapon();
    
    // Based on the current weapon ID, call the appropriate Fire function
    if (current_weapon == WPNID_AXE)
        W_FireAxe();
    else if (current_weapon == WPNID_KNIFE)
        W_FireKnife();
    else if (current_weapon == WPNID_MACHETE)
        W_FireMachete();
    
    // SLOT_HOLDOUT weapons
    else if (current_weapon == WPNID_RAHP)
        W_FireRahp();
    else if (current_weapon == WPNID_DEAGLE)
        W_FireDeagle();
    else if (current_weapon == WPNID_PPISTOL)
        W_FirePPistol();
    
    // SLOT_PRIMARY weapons
    else if (current_weapon == WPNID_UMP45)
        W_FireUMP45();
    else if (current_weapon == WPNID_M4)
        W_FireM4();
    else if (current_weapon == WPNID_AK47)
        W_FireAK47();
    
    // SLOT_SECONDARY weapons
    else if (current_weapon == WPNID_DBSHOT)
        W_FireDBShot();
    else if (current_weapon == WPNID_AUTOSHOTTY)
        W_FireAutoShotty();
    
    // Add more weapon cases as needed
};

/*
================
LoadoutDispatchCycleFireMode
Dispatches the fire mode cycling call to the appropriate weapon function
based on the player's loadout configuration for the current slot
================
*/
void() LoadoutDispatchCycleFireMode =
{
    float current_weapon = LoadoutGetCurrentWeapon();
    
    // Based on the current weapon ID, call the appropriate CycleFireMode function
    if (current_weapon == WPNID_AXE)
        w_axe_CycleFireMode();
    else if (current_weapon == WPNID_KNIFE)
        w_knife_CycleFireMode();
    else if (current_weapon == WPNID_MACHETE)
        w_machete_CycleFireMode();
    
    // SLOT_HOLDOUT weapons
    else if (current_weapon == WPNID_RAHP)
        w_rahpm1_CycleFireMode();
    else if (current_weapon == WPNID_DEAGLE)
        w_deagle_CycleFireMode();
    else if (current_weapon == WPNID_PPISTOL)
        w_ppistol_CycleFireMode();
    
    // SLOT_PRIMARY weapons
    else if (current_weapon == WPNID_UMP45)
        w_ump45_CycleFireMode();
    else if (current_weapon == WPNID_M4)
        w_m4_CycleFireMode();
    else if (current_weapon == WPNID_AK47)
        w_ak47_CycleFireMode();
    
    // SLOT_SECONDARY weapons
    else if (current_weapon == WPNID_DBSHOT)
        w_dbshot_CycleFireMode();
    else if (current_weapon == WPNID_AUTOSHOTTY)
        w_autoshotty_CycleFireMode();
    
    // Add more weapon cases as needed
};

/*
================
LoadoutDispatchHasNoAmmo
Dispatches the ammo check call to the appropriate weapon function
based on the player's loadout configuration for the current slot
Returns: TRUE if no ammo, FALSE if has ammo
================
*/
float() LoadoutDispatchHasNoAmmo =
{
    float current_weapon = LoadoutGetCurrentWeapon();
    
    // Based on the current weapon ID, call the appropriate HasNoAmmo function
    if (current_weapon == WPNID_AXE)
        return w_axe_HasNoAmmo();
    else if (current_weapon == WPNID_KNIFE)
        return w_knife_HasNoAmmo();
    else if (current_weapon == WPNID_MACHETE)
        return w_machete_HasNoAmmo();
    
    // SLOT_HOLDOUT weapons
    else if (current_weapon == WPNID_RAHP)
        return w_rahpm1_HasNoAmmo();
    else if (current_weapon == WPNID_DEAGLE)
        return w_deagle_HasNoAmmo();
    else if (current_weapon == WPNID_PPISTOL)
        return w_ppistol_HasNoAmmo();
    
    // SLOT_PRIMARY weapons
    else if (current_weapon == WPNID_UMP45)
        return w_ump45_HasNoAmmo();
    else if (current_weapon == WPNID_M4)
        return w_m4_HasNoAmmo();
    else if (current_weapon == WPNID_AK47)
        return w_ak47_HasNoAmmo();
    
    // SLOT_SECONDARY weapons
    else if (current_weapon == WPNID_DBSHOT)
        return w_dbshot_HasNoAmmo();
    else if (current_weapon == WPNID_AUTOSHOTTY)
        return w_autoshotty_HasNoAmmo();
    
    // Add more weapon cases as needed
    
    // Default/fallback for unknown weapons
    return TRUE; // Assume no ammo for safety
};

/*
================
LoadoutDispatchBestMode
Dispatches the best mode determination call to the appropriate weapon function
based on the player's loadout configuration for the current slot
Returns: The best firing mode for the current weapon
================
*/
float() LoadoutDispatchBestMode =
{
    float current_weapon = LoadoutGetCurrentWeapon();
    
    // Based on the current weapon ID, call the appropriate BestMode function
    if (current_weapon == WPNID_AXE)
        return w_axe_BestMode();
    else if (current_weapon == WPNID_KNIFE)
        return w_knife_BestMode();
    else if (current_weapon == WPNID_MACHETE)
        return w_machete_BestMode();
    
    // SLOT_HOLDOUT weapons
    else if (current_weapon == WPNID_RAHP)
        return w_rahpm1_BestMode();
    else if (current_weapon == WPNID_DEAGLE)
        return w_deagle_BestMode();
    else if (current_weapon == WPNID_PPISTOL)
        return w_ppistol_BestMode();
    
    // SLOT_PRIMARY weapons
    else if (current_weapon == WPNID_UMP45)
        return w_ump45_BestMode();
    else if (current_weapon == WPNID_M4)
        return w_m4_BestMode();
    else if (current_weapon == WPNID_AK47)
        return w_ak47_BestMode();
    
    // SLOT_SECONDARY weapons
    else if (current_weapon == WPNID_DBSHOT)
        return w_dbshot_BestMode();
    else if (current_weapon == WPNID_AUTOSHOTTY)
        return w_autoshotty_BestMode();
    
    // Add more weapon cases as needed
    
    // Default/fallback for unknown weapons
    return FIRE_MODE_PRIMARY; // Assume primary mode for safety
};

// ============= MAP CONFIGURATION FUNCTIONS =============

/*
================
LoadoutSetFromString
Set a player's complete loadout from a string of weapon IDs
Format: "01,10,20,30,00,00,00,00,00" (comma-separated 2-digit IDs)
This can be useful for map entities to set default loadouts
Parameters:
- loadout_string: String containing comma-separated weapon IDs
================
*/
void(string loadout_string) LoadoutSetFromString =
{
    // We'll need a tokenizer to parse the string
    // For simplicity, assuming fixed format with known positions
    
    // Format: "01,10,20,30,00,00,00,00,00"
    
    // Extract each 2-digit ID (plus comma) and convert to float
    self.loadout_melee = stof(substring(loadout_string, 0, 2));
    self.loadout_holdout = stof(substring(loadout_string, 3, 2));
    self.loadout_primary = stof(substring(loadout_string, 6, 2));
    self.loadout_secondary = stof(substring(loadout_string, 9, 2));
    self.loadout_special = stof(substring(loadout_string, 12, 2));
    self.loadout_explosive = stof(substring(loadout_string, 15, 2));
    self.loadout_magic = stof(substring(loadout_string, 18, 2));
    self.loadout_heavy = stof(substring(loadout_string, 21, 2));
    self.loadout_equipment = stof(substring(loadout_string, 24, 2));
};

/*
================
LoadoutGetAsString
Get a player's complete loadout as a string of weapon IDs
Format: "01,10,20,30,00,00,00,00,00" (comma-separated 2-digit IDs)
Returns: String representation of the loadout
================
*/
string() LoadoutGetAsString =
{
    string result;
    string temp;
    
    // Format the melee weapon ID
    if (self.loadout_melee < 10)
        temp = strcat("0", ftos(self.loadout_melee));
    else
        temp = ftos(self.loadout_melee);
    result = temp;
    
    // Format the holdout weapon ID
    if (self.loadout_holdout < 10)
        temp = strcat(",0", ftos(self.loadout_holdout));
    else
        temp = strcat(",", ftos(self.loadout_holdout));
    result = strcat(result, temp);
    
    // Format the primary weapon ID
    if (self.loadout_primary < 10)
        temp = strcat(",0", ftos(self.loadout_primary));
    else
        temp = strcat(",", ftos(self.loadout_primary));
    result = strcat(result, temp);
    
    // Format the secondary weapon ID
    if (self.loadout_secondary < 10)
        temp = strcat(",0", ftos(self.loadout_secondary));
    else
        temp = strcat(",", ftos(self.loadout_secondary));
    result = strcat(result, temp);
    
    // Format the special weapon ID
    if (self.loadout_special < 10)
        temp = strcat(",0", ftos(self.loadout_special));
    else
        temp = strcat(",", ftos(self.loadout_special));
    result = strcat(result, temp);
    
    // Format the explosive weapon ID
    if (self.loadout_explosive < 10)
        temp = strcat(",0", ftos(self.loadout_explosive));
    else
        temp = strcat(",", ftos(self.loadout_explosive));
    result = strcat(result, temp);
    
    // Format the magic weapon ID
    if (self.loadout_magic < 10)
        temp = strcat(",0", ftos(self.loadout_magic));
    else
        temp = strcat(",", ftos(self.loadout_magic));
    result = strcat(result, temp);
    
    // Format the heavy weapon ID
    if (self.loadout_heavy < 10)
        temp = strcat(",0", ftos(self.loadout_heavy));
    else
        temp = strcat(",", ftos(self.loadout_heavy));
    result = strcat(result, temp);
    
    // Format the equipment weapon ID
    if (self.loadout_equipment < 10)
        temp = strcat(",0", ftos(self.loadout_equipment));
    else
        temp = strcat(",", ftos(self.loadout_equipment));
    result = strcat(result, temp);
    
    return result;
};

// ============= INTEGRATION HELPERS =============

/*
================
LoadoutAddWeaponFields
Add the loadout fields to the entity struct (called early in game init)
================
*/
void() LoadoutAddWeaponFields =
{
    // This function would need to be implemented in C code or using a builtin
    // as QuakeC doesn't allow dynamic field definition at runtime
    
    // For documentation purposes only - these fields must be defined elsewhere:
    // .float loadout_melee;
    // .float loadout_holdout;
    // .float loadout_primary;
    // .float loadout_secondary;
    // .float loadout_special;
    // .float loadout_explosive;
    // .float loadout_magic;
    // .float loadout_heavy;
    // .float loadout_equipment;
};

/*
================
LoadoutInitializeClient
Initialize a new client with default loadout (called during player spawn)
================
*/
void() LoadoutInitializeClient =
{
    // Initialize with default loadout
    LoadoutInit();
    
    // May want to apply any saved loadout preferences here
    // (if implementing a persistent loadout system)
};