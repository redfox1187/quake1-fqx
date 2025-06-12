// =======================================================================
//
//  ##File: defs.qc
//  ##File Description: FQX Phoenix - MONOLITHIC DEFINITIONS (Corrected)
//  ##FIREFQX: Version 4.0.7 (20250612.064515CDT)
//
//  ##FIREFQX
//   v4.0.7 - Authoritative and complete rebuild based on a full,
//            line-by-line analysis of the QRRQC source files. This
//            version corrects all previously identified omissions and
//            formatting errors.
//
// =======================================================================

#pragma TARGET ID "KEX 4.0"

//-------------------------------------------------------------------------
// PART 1: GLOBAL VARIABLES
//-------------------------------------------------------------------------

// --- IMMUTABLE SYSTEM GLOBALS ---
entity      self;
entity      other;
entity      world;
float       time;
float       frametime;
float       force_retouch;
string      mapname;
float       deathmatch;
float       coop;
float       teamplay;
float       serverflags;
float       total_secrets;
float       total_monsters;
float       found_secrets;
float       killed_monsters;
float       parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
vector      v_forward, v_up, v_right;
float       trace_allsolid;
float       trace_startsolid;
float       trace_fraction;
vector      trace_endpos;
vector      trace_plane_normal;
float       trace_plane_dist;
entity      trace_ent;
float       trace_inopen;
float       trace_inwater;
entity      msg_entity;
void()      main;
void()      StartFrame;
void()      PlayerPreThink;
void()      PlayerPostThink;
void()      ClientKill;
void()      ClientConnect;
void()      PutClientInServer;
void()      ClientDisconnect;
void()      SetNewParms;
void()      SetChangeParms;

void        end_sys_globals;

// --- FQX CUSTOM GLOBAL VARIABLES ---
float       startingserverflags;
float       reset_flag;
entity      lastspawn;
float       movedist;
float       gameover;
string      string_null;
entity      newmis;
entity      activator;
entity      damage_attacker;
float       framecount;
float       skill;
float       campaign_valid;
float       campaign;
float       cheats_allowed;


//-------------------------------------------------------------------------
// PART 2: ENTITY FIELDS
//-------------------------------------------------------------------------

// --- IMMUTABLE SYSTEM FIELDS ---
.float      modelindex;
.vector     absmin, absmax;
.float      ltime;
.float      movetype;
.float      solid;
.vector     origin;
.vector     oldorigin;
.vector     velocity;
.vector     angles;
.vector     avelocity;
.vector     punchangle;
.string     classname;
.string     model;
.float      frame;
.float      skin;
.float      effects;
.vector     mins, maxs;
.vector     size;
.void()     touch;
.void()     use;
.void()     think;
.void()     blocked;
.float      nextthink;
.entity     groundentity;
.float      health;
.float      frags;
.float      weapon;
.string     weaponmodel;
.float      weaponframe;
.float      currentammo;
.float      ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float      items;
.float      takedamage;
.entity     chain;
.float      deadflag;
.vector     view_ofs;
.float      button0;
.float      button1;
.float      button2;
.float      impulse;
.float      fixangle;
.vector     v_angle;
.float      idealpitch;
.string     netname;
.entity     enemy;
.float      flags;
.float      colormap;
.float      team;
.float      max_health;
.float      teleport_time;
.float      armortype;
.float      armorvalue;
.float      waterlevel;
.float      watertype;
.float      ideal_yaw;
.float      yaw_speed;
.entity     aiment;
.entity     goalentity;
.float      spawnflags;
.string     target;
.string     targetname;
.float      dmg_take;
.float      dmg_save;
.entity     dmg_inflictor;
.entity     owner;
.vector     movedir;
.string     message;
.float      sounds;
.string     noise, noise1, noise2, noise3;

void        end_sys_fields;


// --- FQX CUSTOM ENTITY FIELDS ---
.string     killtarget;
.float      light_lev;
.float      style;
.string     wad;
.string     map;
.float      worldtype;
.void()     th_stand;
.void()     th_walk;
.void()     th_run;
.void()     th_missile;
.void()     th_melee;
.void(entity attacker, float damage) th_pain;
.void()     th_die;
.entity     oldenemy;
.float      speed;
.float      lefty;
.float      search_time;
.float      attack_state;
.float      allowPathFind;
.float      combat_style;
.float      pausetime;
.entity     movetarget;
.float      walkframe;
.float      attack_finished;
.float      pain_finished;
.float      invincible_finished;
.float      invisible_finished;
.float      super_damage_finished;
.float      radsuit_finished;
.float      invincible_time, invincible_sound;
.float      invisible_time, invisible_sound;
.float      super_time, super_sound;
.float      rad_time;
.float      fly_sound;
.float      axhitme;
.float      show_hostile;
.float      jump_flag;
.float      swim_flag;
.float      air_finished;
.float      bubble_count;
.string     deathtype;
.float      fired_weapon;
.float      took_damage;
.string     mdl;
.vector     mangle;
.float      t_length, t_width;
.vector     dest, dest1, dest2;
.float      wait;
.float      delay;
.entity     trigger_field;
.string     noise4;
.float      aflag;
.float      dmg;
.float      cnt;
.void()     think1;
.vector     finaldest, finalangle;
.float      count;
.float      lip;
.float      state;
.vector     pos1, pos2;
.float      height;
.float      waitmin, waitmax;
.float      distance;
.float      volume;
.string     killstring;
.float      fqx_version;
.float      fqx_spawn_flags;
.float      spawn_deferred;
.float      healthrot_nextcheck;
.float      dmgtime;
.float      loadout_weapon_s1, loadout_weapon_s2, loadout_weapon_s3, loadout_weapon_s4, loadout_weapon_s5, loadout_weapon_s6, loadout_weapon_s7, loadout_weapon_s8, loadout_weapon_s9;
.float      loadout_firemode_s1, loadout_firemode_s2, loadout_firemode_s3, loadout_firemode_s4, loadout_firemode_s5, loadout_firemode_s6, loadout_firemode_s7, loadout_firemode_s8, loadout_firemode_s9;
.float      fqx_weapon_id;
.float      fqx_firemode;
.float      fqx_ammo_id;
.float      fqx_ammo_per_shot;
.float      fqx_mag_capacity;
.float      fqx_mag_current;
.float      fqx_refire_rate;
.float      fqx_recoil_strength;
.float      fqx_recoil_time;
.vector     fqx_recoil_pattern;
.string     pain_sound;
.string     death_sound;
.float      inpain;
.float      mc_state;
.float      mc_state_time;
.void()     mc_think_state;
.void()     mc_pain_state;
.void()     mc_die_state;
.float      mc_memory;
.entity     mc_target_memory;

//-------------------------------------------------------------------------
// PART 3: CONSTANTS
//-------------------------------------------------------------------------

#define FALSE                   0
#define TRUE                    1
#define FL_FLY                  1
#define FL_SWIM                 2
#define FL_CLIENT               8
#define FL_INWATER              16
#define FL_MONSTER              32
#define FL_GODMODE              64
#define FL_NOTARGET             128
#define FL_ITEM                 256
#define FL_ONGROUND             512
#define FL_PARTIALGROUND        1024
#define FL_WATERJUMP            2048
#define FL_JUMPRELEASED         4096
#define FL_ISBOT                8192
#define FL_NO_PLAYERS           16384
#define FL_NO_MONSTERS          32768
#define FL_NO_BOTS              65536
#define FL_OBJECTIVE            131072
#define MOVETYPE_NONE           0
#define MOVETYPE_WALK           3
#define MOVETYPE_STEP           4
#define MOVETYPE_FLY            5
#define MOVETYPE_TOSS           6
#define MOVETYPE_PUSH           7
#define MOVETYPE_NOCLIP         8
#define MOVETYPE_FLYMISSILE     9
#define MOVETYPE_BOUNCE         10
#define MOVETYPE_GIB            11
#define SOLID_NOT               0
#define SOLID_TRIGGER           1
#define SOLID_BBOX              2
#define SOLID_SLIDEBOX          3
#define SOLID_BSP               4
#define SOLID_CORPSE            5
#define RANGE_MELEE             0
#define RANGE_NEAR              1
#define RANGE_MID               2
#define RANGE_FAR               3
#define DEAD_NO                 0
#define DEAD_DYING              1
#define DEAD_DEAD               2
#define DEAD_RESPAWNABLE        3
#define DAMAGE_NO               0
#define DAMAGE_YES              1
#define DAMAGE_AIM              2
#define IT_AXE                  4096
#define IT_SHOTGUN              1
#define IT_SUPER_SHOTGUN        2
#define IT_NAILGUN              4
#define IT_SUPER_NAILGUN        8
#define IT_GRENADE_LAUNCHER     16
#define IT_ROCKET_LAUNCHER      32
#define IT_LIGHTNING            64
#define IT_EXTRA_WEAPON         128
#define IT_SHELLS               256
#define IT_NAILS                512
#define IT_ROCKETS              1024
#define IT_CELLS                2048
#define IT_ARMOR1               8192
#define IT_ARMOR2               16384
#define IT_ARMOR3               32768
#define IT_SUPERHEALTH          65536
#define IT_KEY1                 131072
#define IT_KEY2                 262144
#define IT_INVISIBILITY         524288
#define IT_INVULNERABILITY      1048576
#define IT_SUIT                 2097152
#define IT_QUAD                 4194304
#define CONTENT_EMPTY           -1
#define CONTENT_SOLID           -2
#define CONTENT_WATER           -3
#define CONTENT_SLIME           -4
#define CONTENT_LAVA            -5
#define CONTENT_SKY             -6
#define STATE_TOP               0
#define STATE_BOTTOM            1
#define STATE_UP                2
#define STATE_DOWN              3
#define VEC_ORIGIN              '0 0 0'
#define VEC_HULL_MIN            '-16 -16 -24'
#define VEC_HULL_MAX            '16 16 32'
#define VEC_HULL2_MIN           '-32 -32 -24'
#define VEC_HULL2_MAX           '32 32 64'
#define SVC_TEMPENTITY          23
#define SVC_KILLEDMONSTER       27
#define SVC_FOUNDSECRET         28
#define SVC_INTERMISSION        30
#define SVC_FINALE              31
#define SVC_CDTRACK             32
#define SVC_SELLSCREEN          33
#define SVC_SPAWNEDMONSTER      39
#define SVC_ACHIEVEMENT         52
#define SVC_CHAT                53
#define SVC_LEVELCOMPLETED      54
#define SVC_BACKTOLOBBY         55
#define SVC_LOCALSOUND          56
#define SVC_PROMPT              57
#define TE_SPIKE                0
#define TE_SUPERSPIKE           1
#define TE_GUNSHOT              2
#define TE_EXPLOSION            3
#define TE_TAREXPLOSION         4
#define TE_LIGHTNING1           5
#define TE_LIGHTNING2           6
#define TE_WIZSPIKE             7
#define TE_KNIGHTSPIKE          8
#define TE_LIGHTNING3           9
#define TE_LAVASPLASH           10
#define TE_TELEPORT             11
#define TE_EXPLOSION2           12
#define TE_BEAM                 13
#define CHAN_AUTO               0
#define CHAN_WEAPON             1
#define CHAN_VOICE              2
#define CHAN_ITEM               3
#define CHAN_BODY               4
#define ATTN_NONE               0
#define ATTN_NORM               1
#define ATTN_IDLE               2
#define ATTN_STATIC             3
#define EF_BRIGHTFIELD          1
#define EF_MUZZLEFLASH          2
#define EF_BRIGHTLIGHT          4
#define EF_DIMLIGHT             8
#define EF_QUADLIGHT            16
#define EF_PENTALIGHT           32
#define EF_CANDLELIGHT          64
#define MSG_BROADCAST           0
#define MSG_ONE                 1
#define MSG_ALL                 2
#define MSG_INIT                3
#define TEAM_NONE               -1
#define TEAM_MONSTERS           0
#define TEAM_HUMANS             1
#define PEF_CHANGEONLYNEW       1
#define PEF_CHANGENEVER         2
#define AS_STRAIGHT             1
#define AS_SLIDING              2
#define AS_MELEE                3
#define AS_MISSILE              4
#define CS_NONE                 0
#define CS_RANGED               1
#define CS_MELEE                2
#define CS_MIXED                3
#define WORLDTYPE_MEDIEVAL      0
#define WORLDTYPE_METAL         1
#define WORLDTYPE_BASE          2

//-------------------------------------------------------------------------
// PART 4: BUILT-IN FUNCTION DECLARATIONS
//-------------------------------------------------------------------------

void(vector ang)    makevectors         = #1;
void(entity e, vector o) setorigin     = #2;
void(entity e, string m) setmodel      = #3;
void(entity e, vector min, vector max) setsize = #4;
void()              break               = #6;
float()             random              = #7;
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v)    normalize           = #9;
void(string e)      error               = #10;
void(string e)      objerror            = #11;
float(vector v)     vlen                = #12;
float(vector v)     vectoyaw            = #13;
entity()            spawn               = #14;
void(entity e)      remove              = #15;
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;
entity()            checkclient         = #17;
entity(entity start, .string fld, string match) find = #18;
string(string s)    precache_sound      = #19;
string(string s)    precache_model      = #20;
void(entity client, string s, ...) stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s, ...) dprint              = #25;
string(float f)     ftos                = #26;
string(vector v)    vtos                = #27;
void()              coredump            = #28;
void()              traceon             = #29;
void()              traceoff            = #30;
void(entity e)      eprint              = #31;
float(float yaw, float dist) walkmove  = #32;
float()             droptofloor         = #34;
void(float style, string value) lightstyle = #35;
float(float v)      rint                = #36;
float(float v)      floor               = #37;
float(float v)      ceil                = #38;
float(entity e)     checkbottom         = #40;
float(vector v)     pointcontents       = #41;
float(float f)      fabs                = #43;
vector(entity e, float speed) aim   = #44;
float(string s)     cvar                = #45;
void(string s)      localcmd            = #46;
entity(entity e)    nextent             = #47;
void(vector o, vector d, float color, float count) particle = #48;
void()              ChangeYaw           = #49;
vector(vector v)    vectoangles         = #51;
void(float to, float f) WriteByte       = #52;
void(float to, float f) WriteChar       = #53;
void(float to, float f) WriteShort      = #54;
void(float to, float f) WriteLong       = #55;
void(float to, float f) WriteCoord      = #56;
void(float to, float f) WriteAngle      = #57;
void(float to, string s) WriteString   = #58;
void(float to, entity s) WriteEntity   = #59;
void(float step)    movetogoal          = #67;
string(string s)    precache_file       = #68;
void(entity e)      makestatic          = #69;
void(string s)      changelevel         = #70;
void(string var, string val) cvar_set   = #72;
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
string(string s)    precache_model2     = #75;
string(string s)    precache_sound2     = #76;
string(string s)    precache_file2      = #77;
void(entity e)      setspawnparms       = #78;
float(string s)     checkextension      = #99;

// QRRQC Extensions
void(string s, ...) bprint              = #0:ex_bprint;
void(entity client, string s, ...) sprint = #0:ex_sprint;
void(entity client, string s, ...) centerprint = #0:ex_centerprint;
string(...)         strcat              = #0:ex_strcat;
float()             finaleFinished      = #0:ex_finaleFinished;
void(entity client, string sample) localsound = #0:ex_localsound;
float(entity playerEnt) CheckPlayerEXFlags = #0:ex_CheckPlayerEXFlags;
float(float movedist, vector goal) walkpathtogoal = #0:ex_walkpathtogoal;

//-------------------------------------------------------------------------
// PART 5: FORWARD DECLARATIONS
//-------------------------------------------------------------------------

// --- QRRQC Forward Declarations ---
void(vector ang) makevectorsfixed;
void() SUB_Null;
void() SUB_UseTargets;
void(vector dest, float speed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void() SUB_CalcMoveDone;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt;
void() SUB_CalcAngleMoveDone;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity e, float healamount, float ignore) T_Heal;
float(entity targ, entity inflictor) CanDamage;

// --- FQX Project Forward Declarations ---
void() walkmonster_start;
void() flymonster_start;
void() swimmonster_start;
void() monster_use;
void() monster_death_use;
void() BecomeExplosion;
void() ai_stand;
void(float dist) ai_walk;
void(float dist) ai_run;
void() ai_run_melee;
void() ai_run_missile;
void() ai_run_slide;
void() ai_melee_side;
void(float dist) ai_pain;
void(entity monster, float dist) ai_charge;
void() ai_charge_side;
float() ai_checkattack;
float() CheckAnyAttack;
void() ai_face;
void(float dist) ai_painforward;
void(float dist) ai_forward;
void(float dist) ai_back;
void() ai_turn;
float() SoldierCheckAttack;
float() OgreCheckAttack;
float() ShamCheckAttack;
float() DemonCheckAttack;
float() CheckAttack;
void() knight_attack;
float() DogCheckAttack;
float() WizardCheckAttack;
void() monster_army;
void() monster_ogre;
void() monster_knight;
void() monster_hell_knight;
void() monster_demon1;
void() monster_shambler;
void() monster_wizard;
void() monster_dog;
void() monster_zombie;
void() monster_fish;
void() monster_shalrath;
void() monster_enforcer;
void() monster_tarbaby;
void() monster_boss;
void() monster_chton;
void() monster_shubniggurath;
void() InitTrigger;
string(float item_flag) GetNetName;
void(entity attacker, float damage) player_pain;
void() PlayerDie;
void() set_suicide_frame;
void() PlayerJump;
void() WaterMove;
void() CheckWaterJump;
void() PlayerDeathThink;
void() CheckPowerups;
void() CheckHealthRot;
void(float num_bubbles) DeathBubbles;
void() DropBackpack;
void() respawn;
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;
void() IntermissionThink;
void() CheckRules;
entity() FindIntermission;
void() InitBodyQueue;
void(entity ent) CopyToBodyQueue;
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
void(vector org) spawn_shot_spark;
void() DecodeLevelParms;
entity(float forceSpawn) SelectSpawnPoint;
void() W_Attack;
void() W_ChangeWeapon;
void() W_SetCurrentAmmo;
void() W_WeaponFrame;
float() W_BestWeapon;
void() W_Precache;
void() W_FireAxe;
void() W_FireShotgun;
void() W_FireSuperShotgun;
void(float side) W_FireSpikes;
void() W_FireLightning;
void() W_FireGrenade;
void() W_FireRocket;
void(float num, float spread) FireBuckshot;
void(vector dir) FireNail;
void() FireGrenadeProjectile;
void() FireRocketProjectile;
void() FireLightningBeam;
void() MeleeAttack;
void(vector org, entity attacker, float damage, float radius, entity ignore, float te_effect) FQX_Explosion;

// =======================================================================
// Project: FQX Phoenix
// File: ./defs.qc - File Version: 4.0.7
// Last Coder: ##FIREFQX
// =======================================================================