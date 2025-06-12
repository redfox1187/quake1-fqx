//=============================================================================
// bgs_precache.qc - FQX Mod - Base Game Systems: Precaching
// Location: /src/base/
// ##FQXCUSTOM - ##Quedra: Version 1.0.0
// ##Quedra: Centralizes precaching for gameplay assets like items, weapons,
// ##Quedra: and player resources to improve organization.
// ##Quedra: v1.0.0 - Initial refactoring for FQX Phoenix.
//=============================================================================

//
// WEAPON PRECACHING
//
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");
	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");
	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");
	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
};


//
// MASTER PRECACHE FUNCTION
//
void() FQX_MasterPrecache =
{
    // Call Weapon Precaching
    W_Precache ();

    // Sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");
	// landing splash

	// Setup precaches always needed
	precache_sound ("items/itembk2.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");
	// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");
	// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");
	// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");
	// weapon up
	precache_sound ("items/armor1.wav");		// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");

	precache_sound ("misc/power.wav");
	//lightning for boss

    // Player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");
	// gib sound

    // Player pain sounds
	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");
    
    // Player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

    // Axe sounds	
	precache_sound ("weapons/ax1.wav");
	// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");
	// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");
	// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming

    // Player and weapon models
	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
	precache_model ("progs/s_explod.spr");	// sprite explosion

	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	precache_model ("progs/v_light.mdl");

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");
	// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing
	
	precache_model ("progs/missile.mdl");
	precache_model ("progs/grenade.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");

	precache_model ("progs/backpack.mdl");

	precache_model ("progs/zom_gib.mdl");
};