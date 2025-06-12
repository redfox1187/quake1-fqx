// =======================================================================
//
//  ##File: defs_fqx_fdec_weapons.qc
//  ##File Description: FQX Definitions - Weapon System Forward Declarations
//
//  ##FQX - This file is an original FQX module.
//    v0.1.1 - Corrected FQX_Explosion signature to match implementation.
//    v0.1.0 - Initial creation.
//
// =======================================================================
// ##FQX - ##Quedra: Version 0.1.1

//--[ CORE WEAPON HANDLING ]-----------------------------------------------
void() W_Attack;
void() W_ChangeWeapon;
void() W_SetCurrentAmmo;
void() W_WeaponFrame;
float() W_BestWeapon;
void() W_Precache;

//--[ VANILLA WEAPON FIRING LOGIC ]----------------------------------------
void() W_FireAxe;
void() W_FireShotgun;
void() W_FireSuperShotgun;
void(float side) W_FireSpikes;
void() W_FireLightning;
void() W_FireGrenade;
void() W_FireRocket;

//--[ FQX VFAM OPERATIONAL LOGIC ]-----------------------------------------
void(float num, float spread) FireBuckshot;
void(vector dir) FireNail;
void() FireGrenadeProjectile;
void() FireRocketProjectile;
void() FireLightningBeam;
void() MeleeAttack;

//--[ FQX COMBAT UTILITY ]-------------------------------------------------
void(vector org, entity attacker, float damage, float radius, entity ignore, float te_effect) FQX_Explosion;

// =======================================================================
// ##FQX - ##Quedra: Version 0.1.1
// =======================================================================