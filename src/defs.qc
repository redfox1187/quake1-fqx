/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

/*
==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================
*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;

float		force_retouch;		// force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float		deathmatch;
float		coop;
float		teamplay;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes

float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector		v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;			// destination of single entity writes

//
// required prog functions
//
void() 		main;						// only for testing

void()		StartFrame;

void() 		PlayerPreThink;
void() 		PlayerPostThink;

void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;

void()		SetNewParms;			// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()		SetChangeParms;			// call to set parms for self so they can
									// be saved for a level transition

//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		ltime;			// local time for entity
.float		movetype;
.float		solid;

.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.vector		punchangle;		// temp angle adjust from damage or recoil

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SLOT_HOLDOUT, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;

.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;

.vector		view_ofs;			// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump

.float		impulse;		// weapon changes

.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes


.string		netname;

.entity 	enemy;

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// players maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = waist, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;

.entity 	goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump

.string		message;		// trigger messages

.float		sounds;		// either a cd track number or sound number

.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================


//================================================
// AMMO OPERATIONS FORWARD DECLARATIONS (am_operations.qc)
//================================================
// Ensure 'const' is REMOVED from these user-defined function declarations
void(string model_path, float ammo_id_to_read, float items_flag) AM_InitializeWeaponView;
void(float ammo_id, float amount_to_consume) AM_ConsumeAmmo;
void(float num_standard_modes, float supports_debug_mode) AM_InitWeaponFireModes;
void() AM_CycleFireMode;
void() AM_WeaponFrame_HandleFireRelease;
float() AM_CanFireSemiAuto;
void() AM_ResetSustainedRecoil; 
//================================================
// WEAPON-SPECIFIC MODE SWITCH FUNCTION FORWARD DECLARATIONS
//================================================
void() W_SwitchModeUMP45;  // From w_ump45.qc
void() W_SwitchModeRahp;   // From w_rahpm1.qc
void() W_SwitchModeDBShot; // From w_dbshot.qc (NEW)
// Add other weapon-specific mode switchers here as they are created

// Quake Super Nailgun
void w_q_snailgun_SetCurrentAmmo (void);
void W_Fire_Q_Snailgun (void);


//============================================================================
// Weapon: Ak47 Assault Rifle (w_ak47.qc)
//============================================================================
void w_ak47_SetCurrentAmmo (void);    // Called when the Ak47 is selected/equipped.
void W_FireAk47 (void);               // Main firing function called by W_Attack.
void W_SwitchModeAk47 (void);         // Called by ToggleFireMode impulse.

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//##FOX: Additions
.float saved_weapon;        
.float quick_melee_active;  
.float quick_melee_debug;
.float quick_melee_sequence;

.float loot_bonus;
.float loot_fragcheck;

.float w_melee; 
.float w_holdout; 
.float w_secondary; 
.float w_primary; 
.float w_heavy; 

// Grapple states
float GRAPPLE_NONE = 0;    
float GRAPPLE_FLYING = 1;  
float GRAPPLE_ATTACHED = 2; 

// Global variables for Grapple
.entity anchor;             
.float grapple_state;       
.float last_jump_time;      
.float anchor_length;       
.float grapple_action;      
.float grapple_time;        

float GRAPPLE_CYCLE_SPEED = 15;     
float GRAPPLE_CONTINUOUS_SPEED = 5; 
float GRAPPLE_ACTION_NONE = 0;
float GRAPPLE_ACTION_EXTEND = 1;
float GRAPPLE_ACTION_RETRACT = 2;

//Advanced Recoil System
.vector recoil_current;     
.vector recoil_visual;      
.float recoil_last_time;    
.float recoil_recovery_rate;
.vector recoil_pattern;     
.float recoil_shots_fired;  

// UMP45 Specific fields (still needed for its internal burst logic)
.float ump_burst_count;       
.float ump_last_fire_time;    
.float ump_burst_active;      
.float ump_next_burst_time;   

// Generic Weapon Operation Fields (These are the new system)
.float current_weapon_fire_mode;    
.float weapon_fire_released;        
.float weapon_num_standard_modes;   
.float weapon_supports_debug_mode;  

// In defs.qc, add these to your player entity fields:
.float  firemode_slot_melee;
.float  firemode_slot_holdout;
.float  firemode_slot_secondary;
.float  firemode_slot_primary;
.float  firemode_slot_heavy;
.float  firemode_slot_utility;
.float  firemode_slot_aux1;
.float  firemode_slot_aux2;
.float  firemode_slot_aux3;

// Define generic fire mode constants (can be used by any weapon)
#define FIRE_MODE_PRIMARY   0  // Generic index for a weapon's primary mode
#define FIRE_MODE_SECONDARY 1  // Generic index for a weapon's secondary mode
#define FIRE_MODE_TERTIARY  2  // Generic index for a weapon's tertiary mode

// UMP45 Specific Fire Mode Index Constants (maps generic indices to UMP's specific modes)
float UMP_FIREMODE_IDX_SINGLE = 0;    // UMP's single shot mode uses generic index 0
float UMP_FIREMODE_IDX_BURST = 1;     // UMP's burst mode uses generic index 1
float UMP_FIREMODE_IDX_AUTO = 2;      // UMP's auto mode uses generic index 2
float UMP_FIREMODE_IDX_DEBUG = 3;     // UMP's debug mode uses index 3


// RAHP Specific Fire Mode Index Constants (if needed globally, e.g. by W_HasNoAmmo in weapons.qc)
float RAHP_FIREMODE_IDX_SMALL_LASER = 0; 

// --- BEGIN FIRE MODE PERSISTENCE CONSTANTS (BITFLAG EMULATION) ---
// Mask to extract a single fire mode value (0-3)
float FIREMODE_PERSIST_MASK = 3; // (binary 11)

// Place values (2^shift_amount) for each weapon slot's fire mode
// Slot order: MELEE, HOLDOUT, SECONDARY, PRIMARY, HEAVY, UTILITY, AUX1, AUX2, AUX3
// These correspond to 2^(slot_index * 2_bits_per_slot)
float FIREMODE_PLACE_VALUE_SLOT_MELEE     = 1;    // 2^0
float FIREMODE_PLACE_VALUE_SLOT_HOLDOUT   = 4;    // 2^2
float FIREMODE_PLACE_VALUE_SLOT_SECONDARY = 16;   // 2^4
float FIREMODE_PLACE_VALUE_SLOT_PRIMARY   = 64;   // 2^6
float FIREMODE_PLACE_VALUE_SLOT_HEAVY     = 256;  // 2^8
float FIREMODE_PLACE_VALUE_SLOT_UTILITY   = 1024; // 2^10
float FIREMODE_PLACE_VALUE_SLOT_AUX1      = 4096; // 2^12
float FIREMODE_PLACE_VALUE_SLOT_AUX2      = 16384;// 2^14
float FIREMODE_PLACE_VALUE_SLOT_AUX3      = 65536;// 2^16
// --- END FIRE MODE PERSISTENCE CONSTANTS ---


//
// constants
//

float	FALSE					= 0;
float 	TRUE					= 1;

// edict.flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;		// set for all client edicts
float	FL_INWATER				= 16;		// for enter / leave water splash
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;		// player cheat
float	FL_NOTARGET				= 128;		// player cheat
float	FL_ITEM					= 256;		// extra wide size for bonus items
float	FL_ONGROUND				= 512;		// standing on something
float	FL_PARTIALGROUND		= 1024;		// not all corners are valid
float	FL_WATERJUMP			= 2048;		// player jumping out of water
float	FL_JUMPRELEASED			= 4096;		// for jump debouncing
float 	FL_ISBOT     			= 8192; 	// mal: this will be set on bot players
float 	FL_NO_PLAYERS			= 16384;	// mal: used by the spawn point editor
float 	FL_NO_MONSTERS			= 32768;	// mal: used by the spawn point editor
float   FL_NO_BOTS				= 65536;	// mal: any item marked with this will be ignored by bots.
float 	FL_OBJECTIVE			= 131072; 	// mal: any item marked with this is an objective of some kind.

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
//float	MOVETYPE_ANGLENOCLIP	= 1;
//float	MOVETYPE_ANGLECLIP		= 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_GIB			= 11;	// like MOVETYPE_BOUNCE, but with adjustable gravity

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block
float	SOLID_CORPSE			= 5;	// reports touch and can shoot it, but not blocking otherwise.

// range values
float	RANGE_MELEE				= 0;
float	RANGE_NEAR				= 1;
float	RANGE_MID				= 2;
float	RANGE_FAR				= 3;

// deadflag values

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

// takedamage values

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

// items
float	IT_SLOT_MELEE					= 4096;
float	IT_SLOT_HOLDOUT				= 1;
float	IT_SLOT_SECONDARY		= 2;
float	IT_SLOT_PRIMARY				= 4;
float	IT_SLOT_HEAVY		= 8;
float	IT_SLOT_UTILITY		= 16;
float	IT_SLOT_AUX1		= 32;
float	IT_SLOT_AUX2			= 64;
float	IT_SLOT_AUX3			= 128;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

float	IT_ARMOR1				= 8192;
float	IT_ARMOR2				= 16384;
float	IT_ARMOR3				= 32768;
float	IT_SUPERHEALTH			= 65536;

float	IT_KEY1					= 131072;
float	IT_KEY2					= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT					= 2097152;
float	IT_QUAD					= 4194304;

// point content values

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY				= -6;

float	STATE_TOP		= 0;
float	STATE_BOTTOM	= 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;

vector	VEC_ORIGIN = '0 0 0';
vector	VEC_HULL_MIN = '-16 -16 -24';
vector	VEC_HULL_MAX = '16 16 32';

vector	VEC_HULL2_MIN = '-32 -32 -24';
vector	VEC_HULL2_MAX = '32 32 64';

// protocol bytes
float	SVC_BAD					= 0;
float	SVC_NOP					= 1;
float	SVC_DISCONNECT			= 2;
float	SVC_UPDATESTAT			= 3;
float	SVC_VERSION				= 4;
float	SVC_SETVIEW				= 5;
float	SVC_SOUND				= 6;
float	SVC_TIME				= 7;
float	SVC_PRINT				= 8;
float	SVC_STUFFTEXT			= 9;
float	SVC_SETANGLE			= 10;
float	SVC_SERVERINFO			= 11;
float	SVC_LIGHTSTYLE			= 12;
float 	SVC_UPDATENAME			= 13;
float 	SVC_UPDATEFRAGS			= 14;
float 	SVC_CLIENTDATA			= 15;
float	SVC_STOPSOUND			= 16;
float	SVC_UPDATECOLORS		= 17;
float	SVC_PARTICLE			= 18;
float 	SVC_DAMAGE				= 19;
float	SVC_SPAWNSTATIC			= 20;
float	SVC_SPAWNBASELINE		= 22;
float	SVC_TEMPENTITY			= 23;
float	SVC_SETPAUSE			= 24;
float	SVC_SIGNONNUM			= 25;
float	SVC_CENTERPRINT			= 26;
float	SVC_KILLEDMONSTER		= 27;
float	SVC_FOUNDSECRET			= 28;
float	SVC_SPAWNSTATICSOUND	= 29;
float	SVC_INTERMISSION		= 30;
float	SVC_FINALE				= 31;
float	SVC_CDTRACK				= 32;
float	SVC_SELLSCREEN			= 33;
float	SVC_CUTSCENE			= 34;
float   SVC_SKYBOX              = 37;
float   SVC_BOTCHAT             = 38;
float   SVC_SPAWNEDMONSTER      = 39;
float   SVC_BONUSFLASH          = 40;
float   SVC_FOG                 = 41;
float   SVC_SPAWNBASELINE2      = 42;
float   SVC_SPAWNSTATIC2        = 43;
float   SVC_SPAWNSTATICSOUND2   = 44;
float   SVC_SETVIEWS            = 45;
float   SVC_UPDATEPING          = 46;
float   SVC_UPDATESOCIAL        = 47;
float   SVC_UPDATEPLINFO        = 48;
float   SVC_RAWPRINT            = 49;
float   SVC_SERVERVARS          = 50;
float   SVC_SEQ                 = 51;
float	SVC_ACHIEVEMENT		    = 52;
float   SVC_CHAT                = 53;
float   SVC_LEVELCOMPLETED      = 54;
float   SVC_BACKTOLOBBY         = 55;
float   SVC_LOCALSOUND          = 56;
float   SVC_PROMPT 				= 57;


float	TE_SPIKE		= 0;
float	TE_SUPERSPIKE	= 1;
float	TE_GUNSHOT		= 2;
float	TE_EXPLOSION	= 3;
float	TE_TAREXPLOSION	= 4;
float	TE_LIGHTNING1	= 5;
float	TE_LIGHTNING2	= 6;
float	TE_WIZSPIKE		= 7;
float	TE_KNIGHTSPIKE	= 8;
float	TE_LIGHTNING3	= 9;
float	TE_LAVASPLASH	= 10;
float	TE_TELEPORT		= 11;
float	TE_EXPLOSION2   = 12;
float	TE_BEAM			= 13;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

// update types

float	UPDATE_GENERAL	= 0;
float	UPDATE_STATIC	= 1;
float	UPDATE_BINARY	= 2;
float	UPDATE_TEMP		= 3;

// entity effects

float	EF_BRIGHTFIELD	= 1;
float	EF_MUZZLEFLASH 	= 2;
float	EF_BRIGHTLIGHT 	= 4;
float	EF_DIMLIGHT 	= 8;
float 	EF_QUADLIGHT    = 16;
float 	EF_PENTALIGHT   = 32;
float	EF_CANDLELIGHT	= 64;

// messages
float	MSG_BROADCAST	= 0;		// unreliable to all
float	MSG_ONE			= 1;		// reliable to one (msg_entity)
float	MSG_ALL			= 2;		// reliable to all
float	MSG_INIT		= 3;		// write to the init string

// team numbers
float TEAM_NONE			= -1;
float TEAM_MONSTERS		= 0;
float TEAM_HUMANS		= 1;

// mal: basic colors - based on the Quake color palette.
float COLOR_RED			= 251;
float COLOR_GREEN		= 184;
float COLOR_BLUE		= 208;
float COLOR_YELLOW		= 192;
float COLOR_WHITE		= 254;
float COLOR_BLACK		= 0;
float COLOR_CYAN		= 244;
float COLOR_ORANGE		= 95;

float DRAW_AI_SINGLE_FRAME		= .1; // mal: use for AI that think every 10th of a second
float DRAW_GAME_SINGLE_FRAME	= -1; // mal: use in game code that updates every frame.

// player expanded settings flags
float PEF_CHANGEONLYNEW	= 1;
float PEF_CHANGENEVER   = 2;

// mal: codes that the QuakeC built-ins "bot_movetopoint" and "bot_followentity" will return each time they're called
float BOT_GOAL_ERROR 		= 0;	// can't do this goal for some reason.
float BOT_GOAL_SUCCESS 		= 1;	// goal as requested is complete.
float BOT_GOAL_IN_PROGRESS 	= 2;	// goal is in progress

// mal: codes that the QuakeC built-in "walkpathtogoal" will return each time it's called
float PATH_ERROR 			= 0;	// something bad happened ( no nav nodes, no nearby nodes, no path, etc. ).
float PATH_REACHED_GOAL 	= 1;	// reached whatever we were trying to get to.
float PATH_REACHED_PATH_END = 2;	// reached the end of the path - can now move directly to target.
float PATH_MOVE_BLOCKED 	= 3;	// something ( or someone ) is in our way.
float PATH_IN_PROGRESS 		= 4;	// path was found, and we're following it.

//================================================

//
// globals
//
float	movedist;
float	gameover;		// set when a rule exits

string	string_null;	// null string, nothing should be held here

entity	newmis;			// launch_spike sets this after spawning it

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
float	framecount;

float	skill;
float	campaign_valid;
float	campaign;

float	cheats_allowed;		// mal: let's us run cheat commands in DM/Coop games.

//================================================

//
// world fields (FIXME: make globals)
//
.string		wad;
.string 	map;

float WORLDTYPE_MEDIEVAL = 0;
float WORLDTYPE_METAL = 1;
float WORLDTYPE_BASE = 2;
.float		worldtype;

//================================================

.float		alpha;

.string		killtarget;

//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;


//
// monster ai
//
.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;
.void(optional entity attacker,optional float damage)		th_pain;
.void()		th_die;

.entity		oldenemy;		// mad at this player before taking damage

.float		speed;

.float	lefty;

.float	search_time;

// Attack state ( not really used in Vanilla )
.float	attack_state;
float	AS_STRAIGHT		= 1;
float	AS_SLIDING		= 2;
float	AS_MELEE		= 3;
float	AS_MISSILE		= 4;

.float  allowPathFind; // not used in Vanilla, but added for demonstration purposes...

// Combat style
.float 	combat_style;
float   CS_NONE 		= 0; // default - used for bosses or other monsters that don't move
float 	CS_RANGED		= 1;
float 	CS_MELEE		= 2;
float 	CS_MIXED		= 3; // can do ranged or melee equally.

//
// player only fields
//
.float		walkframe;

.float 		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		rad_time;
.float		fly_sound;

.float 		healthrot_nextcheck; // if grabbed Mega-Health, the next time we'll rot the players health

.float		axhitme;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died
.float		fired_weapon;	// [NDS] haleyjd: if player has fired a weapon, for achievement
.float		took_damage;	// [NDS] haleyjd: if player has taken damage, for achievement

//
// object stuff
//
.string		mdl;
.vector		mangle;			// angle at start

.vector		oldorigin;		// only used by secret door

.float		t_length, t_width;


//
// doors, etc
//
.vector		dest, dest1, dest2;
.float		wait;			// time from firing to restarting
.float		delay;			// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;

//
// monsters
//
.float 		pausetime;
.entity 	movetarget;


//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit
	
//
// misc
//
.float		cnt; 			// misc flag
	
//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;

//
// triggers
//
.float		count;			// for counting triggers


//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector		pos1, pos2;		// top and bottom positions
.float		height;

//
// sounds
//
.float		waitmin, waitmax;
.float		distance;
.float		volume;


.string		killstring;	// monster kill message

.float    spawn_deferred;

void makevectorsfixed(vector ang);		

//===========================================================================
	

//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() break						= #6;
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s, ...) bprint				= #0:ex_bprint;
void(entity client, string s, ...) sprint = #0:ex_sprint;
void(string s, ...) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump						= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff						= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
float() droptofloor= #34;	// TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;		// returns the shooting vector
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw = #49;						// turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

//
// broadcast client message generation
//

// void(float f) bWriteByte		= #59;
// void(float f) bWriteChar		= #60;
// void(float f) bWriteShort		= #61;
// void(float f) bWriteLong		= #62;
// void(float f) bWriteCoord		= #63;
// void(float f) bWriteAngle		= #64;
// void(string s) bWriteString	= #65;
// void(entity e) bWriteEntity = #66;

void(float step) movetogoal				= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value

void(entity client, string s, ...) centerprint = #0:ex_centerprint;	// sprint, but in middle

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only

void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn

float() finaleFinished = #0:ex_finaleFinished;

// Plays a sound that only "client" can hear. Useful for announcers...
void localsound( entity client, string sample ) = #0:ex_localsound;

// Debug rendering functions.
void draw_point( vector point, float colormap, float lifetime, float depthtest ) = #0:ex_draw_point;
void draw_line( vector start, vector end, float colormap, float lifetime, float depthtest ) = #0:ex_draw_line;
void draw_arrow( vector start, vector end, float colormap, float size, float lifetime, float depthtest ) = #0:ex_draw_arrow;
void draw_ray( vector start, vector direction, float length, float colormap, float size, float lifetime, float depthtest ) = #0:ex_draw_ray;
void draw_circle( vector origin, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_circle;
void draw_bounds( vector min, vector max, float colormap, float lifetime, float depthtest ) = #0:ex_draw_bounds;
void draw_worldtext( string s, vector origin, float size, float lifetime, float depthtest ) = #0:ex_draw_worldtext;
void draw_sphere( vector origin, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_sphere;
void draw_cylinder( vector origin, float halfHeight, float radius, float colormap, float lifetime, float depthtest ) = #0:ex_draw_cylinder;

// Bot functions that return a value based on "BOT_GOAL_<X>", depending on the status of the goal.
float bot_movetopoint( entity bot, vector point ) = #0:ex_bot_movetopoint;
float bot_followentity( entity bot, entity goal ) = #0:ex_bot_followentity;

// Function for checking new player configured flags, such as weapon swap behaviour
float CheckPlayerEXFlags( entity playerEnt ) = #0:ex_CheckPlayerEXFlags;

// Path monsters to the goal using any available nav nodes on the map
float walkpathtogoal( float movedist, vector goal ) = #0:ex_walkpathtogoal;

float checkextension( string s ) = #99;

void setcolor( entity client, float color ) = #401;

void prompt( entity client, string text, float numChoices ) = #0:ex_prompt;
void promptchoice( entity client, string text, float impulse ) = #0:ex_promptchoice;
void clearprompt( entity client ) = #0:ex_clearprompt;


//============================================================================

//
// subs.qc
//
void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;

//
//	combat.qc
//
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;


float (entity e, float healamount, float ignore) T_Heal; // health function

float(entity targ, entity inflictor) CanDamage;


