//=============================================================================
// defs_3.qc - FQX Mod - Part 3 of Global Definitions
// ##FQXCUSTOM - ##FQXDEV: Contains standard QuakeC constants (flags, items,
// ##FQXCUSTOM - ##FQXDEV: movetypes, etc.), FQX-specific constants, global
// ##FQXCUSTOM - ##FQXDEV: variables, entity fields, and built-in functions.
// ##FQXCUSTOM - ##FQXDEV: This file is based on standard Quake/KEX defs.qc
// ##FQXCUSTOM - ##FQXDEV: with FQX-specific additions and styling.
// ##Quedra: Version 1.7 - Complete. FL_*, EF_*, and Built-in numbers aligned with QRRQC-defs.qc.txt.
// ##Quedra: makevectorsfixed forward declaration activated.
//=============================================================================

//-----------------------------------------------------------------------------
// ##FQXDEV: CORE CONSTANTS (From FQX defs_3.qc)
//-----------------------------------------------------------------------------
float   FALSE                   = 0;
float   TRUE                    = 1;

//-----------------------------------------------------------------------------
// ##FQXDEV: EDICT FLAGS (edict.flags) - ALIGNED WITH KEX STANDARD (QRRQC-defs.qc.txt)
//-----------------------------------------------------------------------------
float   FL_FLY                  = 1;    // KEX Standard (Bit 0)
float   FL_SWIM                 = 2;    // KEX Standard (Bit 1)
//      FL_UNUSED_BIT_2         = 4;    // Bit 2 was traditionally FL_CONVEYOR
float   FL_CLIENT               = 8;    // set for all client edicts (Bit 3)
float   FL_INWATER              = 16;   // for enter / leave water splash (Bit 4)
float   FL_MONSTER              = 32;   // KEX Standard (Bit 5)
float   FL_GODMODE              = 64;   // player cheat (Bit 6)
float   FL_NOTARGET             = 128;  // player cheat (Bit 7)
float   FL_ITEM                 = 256;  // extra wide size for bonus items (Bit 8)
float   FL_ONGROUND             = 512;  // KEX Standard (Bit 9)
float   FL_PARTIALGROUND        = 1024; // not all corners are valid (Bit 10)
float   FL_WATERJUMP            = 2048; // player jumping out of water (Bit 11)
float   FL_JUMPRELEASED         = 4096; // for jump debouncing (Bit 12)
float   FL_ISBOT                = 8192; // KEX Standard (Bit 13)
float   FL_NO_PLAYERS           = 16384;// KEX Standard (Bit 14)
float   FL_NO_MONSTERS          = 32768;// KEX Standard (Bit 15)
float   FL_NO_BOTS              = 65536;// KEX Standard (Bit 16)
float   FL_OBJECTIVE            = 131072; // KEX Standard (Bit 17)

//-----------------------------------------------------------------------------
// ##FQXDEV: MOVETYPE VALUES (edict.movetype) - KEX Standard
//-----------------------------------------------------------------------------
float   MOVETYPE_NONE           = 0;    
float   MOVETYPE_WALK           = 3;    
float   MOVETYPE_STEP           = 4;    
float   MOVETYPE_FLY            = 5;   
float   MOVETYPE_TOSS           = 6;    
float   MOVETYPE_PUSH           = 7;    
float   MOVETYPE_NOCLIP         = 8;   
float   MOVETYPE_FLYMISSILE     = 9;    
float   MOVETYPE_BOUNCE         = 10;  
float   MOVETYPE_GIB            = 11;   

//-----------------------------------------------------------------------------
// ##FQXDEV: SOLID VALUES (edict.solid) - KEX Standard
//-----------------------------------------------------------------------------
float   SOLID_NOT               = 0;    
float   SOLID_TRIGGER           = 1;    
float   SOLID_BBOX              = 2;    
float   SOLID_SLIDEBOX          = 3;    
float   SOLID_BSP               = 4;    
float   SOLID_CORPSE            = 5;    

//-----------------------------------------------------------------------------
// ##FQXDEV: RANGE VALUES (From FQX defs_3.qc)
//-----------------------------------------------------------------------------
float   RANGE_MELEE             = 0;
float   RANGE_NEAR              = 1;
float   RANGE_MID               = 2;
float   RANGE_FAR               = 3;

//-----------------------------------------------------------------------------
// ##FQXDEV: DEADFLAG VALUES (KEX Standard)
//-----------------------------------------------------------------------------
float   DEAD_NO                 = 0;
float   DEAD_DYING              = 1;
float   DEAD_DEAD               = 2;
float   DEAD_RESPAWNABLE        = 3;

//-----------------------------------------------------------------------------
// ##FQXDEV: TAKEDAMAGE VALUES (KEX Standard)
//-----------------------------------------------------------------------------
float   DAMAGE_NO               = 0;
float   DAMAGE_YES              = 1;
float   DAMAGE_AIM              = 2;

//=============================================================================
// ##FQXDEV: FQX CUSTOM ITEM SLOT DEFINITIONS (From FQX defs_3.qc)
//=============================================================================
float   IT_SLOT_MELEE           = 4096; 
float   IT_SLOT_HOLDOUT         = 1;   
float   IT_SLOT_SECONDARY       = 2;   
float   IT_SLOT_PRIMARY         = 4;   
float   IT_SLOT_HEAVY           = 8;   
float   IT_SLOT_UTILITY         = 16;  
float   IT_SLOT_AUX1            = 32;  
float   IT_SLOT_AUX2            = 64;  
float   IT_SLOT_AUX3            = 128; 
//=============================================================================

//-----------------------------------------------------------------------------
// ##FQXDEV: STANDARD AMMO, ARMOR, POWERUPS, KEYS (IT_ Flags) - KEX Standard Values
// ##Quedra: Note: Original QRRQC uses IT_AXE, IT_SHOTGUN etc. for weapon bits.
// ##Quedra: FQX uses IT_SLOT_* for these. The ammo/armor/powerup/key bits are standard.
//-----------------------------------------------------------------------------
float   IT_SHELLS               = 256; 
float   IT_NAILS                = 512; 
float   IT_ROCKETS              = 1024;
float   IT_CELLS                = 2048;
float   IT_ARMOR1               = 8192;  // KEX: Green Armor
float   IT_ARMOR2               = 16384; // KEX: Yellow Armor
float   IT_ARMOR3               = 32768; // KEX: Red Armor
float   IT_SUPERHEALTH          = 65536;
float   IT_KEY1                 = 131072;      
float   IT_KEY2                 = 262144;      
float   IT_INVISIBILITY         = 524288;      
float   IT_INVULNERABILITY      = 1048576;     
float   IT_SUIT                 = 2097152;     
float   IT_QUAD                 = 4194304;     

//-----------------------------------------------------------------------------
// ##FQXDEV: POINT CONTENT VALUES (KEX Standard)
//-----------------------------------------------------------------------------
float   CONTENT_EMPTY           = -1;
float   CONTENT_SOLID           = -2;
float   CONTENT_WATER           = -3;
float   CONTENT_SLIME           = -4;
float   CONTENT_LAVA            = -5;
float   CONTENT_SKY             = -6;

//-----------------------------------------------------------------------------
// ##FQXDEV: STATE VALUES (e.g., for plats, doors) - KEX Standard
//-----------------------------------------------------------------------------
float   STATE_TOP               = 0;
float   STATE_BOTTOM            = 1;
float   STATE_UP                = 2;
float   STATE_DOWN              = 3;

//-----------------------------------------------------------------------------
// ##FQXDEV: COMMON VECTORS (KEX Standard)
//-----------------------------------------------------------------------------
vector  VEC_ORIGIN              = '0 0 0';     
vector  VEC_HULL_MIN            = '-16 -16 -24';
vector  VEC_HULL_MAX            = '16 16 32';  
vector  VEC_HULL2_MIN           = '-32 -32 -24';
vector  VEC_HULL2_MAX           = '32 32 64';  

//-----------------------------------------------------------------------------
// ##FQXDEV: PROTOCOL BYTES (SVC_ Network Messages) - From QRRQC-defs.qc
//-----------------------------------------------------------------------------
float   SVC_TEMPENTITY          = 23;  
float   SVC_KILLEDMONSTER       = 27;  
float   SVC_FOUNDSECRET         = 28;  
float   SVC_INTERMISSION        = 30;  
float   SVC_FINALE              = 31;  
float   SVC_CDTRACK             = 32;  
float   SVC_SELLSCREEN          = 33;  
//float   SVC_SMALLKICK           = 34; // User's FQX had these, QRRQC doesn't list them under standard SVC_
//float   SVC_BIGKICK             = 35;   
//float   SVC_UPDATESTAT          = 36;   
//float   SVC_VERSION             = 37;   
//float   SVC_PARTICLEBEAM        = 38;   
float   SVC_SPAWNEDMONSTER      = 39;   // This one IS in QRRQC
//float   SVC_FOUNDITEM           = 40;   
//float   SVC_REPLACETEXTURE      = 41;   
//float   SVC_PLAYERINFO          = 42;   
//float   SVC_PLAYERNAMES         = 43;   
//float   SVC_PLAYERCOLORS        = 44;   
//float   SVC_FORCEMODEL          = 45;   
//float   SVC_KILLTAUNT           = 46;   
//float   SVC_DEATHTAUNT          = 47;   
//float   SVC_HUMILITAUNT         = 48;   
//float   SVC_MODELFAIL           = 49;   
//float   SVC_TEXTMESSAGE         = 50;   
//float   SVC_FMOD_SOUND          = 51;   
float   SVC_ACHIEVEMENT         = 52;  
float   SVC_CHAT                = 53;  
float   SVC_LEVELCOMPLETED      = 54;  
float   SVC_BACKTOLOBBY         = 55;  
float   SVC_LOCALSOUND          = 56;  
float   SVC_PROMPT              = 57;  

//-----------------------------------------------------------------------------
// ##FQXDEV: TEMPORARY ENTITY TYPES (TE_ Effects) - KEX Standard
//-----------------------------------------------------------------------------
float   TE_SPIKE                = 0;   
float   TE_SUPERSPIKE           = 1;   
float   TE_GUNSHOT              = 2;   
float   TE_EXPLOSION            = 3;   
float   TE_TAREXPLOSION         = 4;   
float   TE_LIGHTNING1           = 5;   
float   TE_LIGHTNING2           = 6;   
float   TE_WIZSPIKE             = 7;   
float   TE_KNIGHTSPIKE          = 8;   
float   TE_LIGHTNING3           = 9;   
float   TE_LAVASPLASH           = 10;  
float   TE_TELEPORT             = 11;  
float   TE_EXPLOSION2           = 12;  
float   TE_BEAM                 = 13;  

//-----------------------------------------------------------------------------
// ##FQXDEV: SOUND CHANNELS (KEX Standard)
//-----------------------------------------------------------------------------
float   CHAN_AUTO               = 0;   
float   CHAN_WEAPON             = 1;   
float   CHAN_VOICE              = 2;   
float   CHAN_ITEM               = 3;   
float   CHAN_BODY               = 4;   

//-----------------------------------------------------------------------------
// ##FQXDEV: SOUND ATTENUATION VALUES (KEX Standard)
//-----------------------------------------------------------------------------
float   ATTN_NONE               = 0;   
float   ATTN_NORM               = 1;   
float   ATTN_IDLE               = 2;   
float   ATTN_STATIC             = 3;   

//-----------------------------------------------------------------------------
// ##FQXDEV: UPDATE TYPES (for network updates) - KEX Standard
//-----------------------------------------------------------------------------
float   UPDATE_GENERAL          = 0;   
float   UPDATE_STATIC           = 1;   
float   UPDATE_BINARY           = 2;   
float   UPDATE_TEMP             = 3;   

//-----------------------------------------------------------------------------
// ##FQXDEV: ENTITY EFFECTS (EF_ Visual Effects) - ALIGNED WITH KEX STANDARD (QRRQC-defs.qc.txt)
//-----------------------------------------------------------------------------
float   EF_BRIGHTFIELD          = 1;   
float   EF_MUZZLEFLASH          = 2;   
float   EF_BRIGHTLIGHT          = 4;   
float   EF_DIMLIGHT             = 8;   
float   EF_QUADLIGHT            = 16;   // ##Quedra: KEX Standard (Bit 4)
float   EF_PENTALIGHT           = 32;   // ##Quedra: KEX Standard (Bit 5) - Invulnerability visual
float   EF_CANDLELIGHT          = 64;   // ##Quedra: KEX Standard (Bit 6) - Used by Ogre/Hellknight
// ##Quedra: The original FQX defs_3.qc also had:
// ##Quedra: float EF_FLAG1 = 16; // ##IDSOFT: KEX Rerelease - was EF_DARKLIGHT, now general purpose
// ##Quedra: float EF_FLAG2 = 32; // ##IDSOFT: KEX Rerelease - was EF_INVULNERABILITY, now general purpose
// ##Quedra: float EF_NODRAW = 64; // ##IDSOFT: KEX Rerelease - replaces EF_TRACKER_EFFECT
// ##Quedra: EF_FLAG1 is now EF_QUADLIGHT. EF_FLAG2 is now EF_PENTALIGHT.
// ##Quedra: EF_NODRAW = 64 from previous FQX defs conflicted with KEX EF_CANDLELIGHT = 64.
// ##Quedra: EF_NODRAW is not defined in QRRQC-defs.qc.txt. If FQX needs EF_NODRAW, assign it an unused bit (e.g., 128).

//-----------------------------------------------------------------------------
// ##FQXDEV: MESSAGE TYPES (for client/server communication) - KEX Standard
//-----------------------------------------------------------------------------
float   MSG_BROADCAST           = 0;    
float   MSG_ONE                 = 1;    
float   MSG_ALL                 = 2;    
float   MSG_INIT                = 3;    

//-----------------------------------------------------------------------------
// ##FQXDEV: TEAM NUMBERS (KEX Standard)
//-----------------------------------------------------------------------------
float   TEAM_NONE               = -1;  
float   TEAM_MONSTERS           = 0;   
float   TEAM_HUMANS             = 1;   

//-----------------------------------------------------------------------------
// ##IDSOFT - ##mal: BASIC COLORS (KEX Standard)
//-----------------------------------------------------------------------------
float   COLOR_RED               = 251; 
float   COLOR_GREEN             = 184; 
float   COLOR_BLUE              = 208; 
float   COLOR_YELLOW            = 192; 
float   COLOR_WHITE             = 254; 
float   COLOR_BLACK             = 0;   
float   COLOR_CYAN              = 244; 
float   COLOR_ORANGE            = 95;  

//-----------------------------------------------------------------------------
// ##IDSOFT - ##mal: AI AND GAME TIMING CONSTANTS (KEX Standard)
//-----------------------------------------------------------------------------
float   DRAW_AI_SINGLE_FRAME    = 0.1;  
float   DRAW_GAME_SINGLE_FRAME  = -1;   

//-----------------------------------------------------------------------------
// ##FQXDEV: PLAYER EXPANDED SETTINGS FLAGS (PEF_*) (From FQX defs_3.qc)
//-----------------------------------------------------------------------------
float   PEF_CHANGEONLYNEW       = 1;   
float   PEF_CHANGENEVER         = 2;   

//-----------------------------------------------------------------------------
// ##IDSOFT - ##mal: BOT GOAL STATUS CODES (KEX Standard)
//-----------------------------------------------------------------------------
float   BOT_GOAL_ERROR          = 0;    
float   BOT_GOAL_SUCCESS        = 1;    
float   BOT_GOAL_IN_PROGRESS    = 2;    

//-----------------------------------------------------------------------------
// ##IDSOFT - ##mal: PATHING STATUS CODES (KEX Standard)
//-----------------------------------------------------------------------------
float   PATH_ERROR              = 0;    
float   PATH_REACHED_GOAL       = 1;    
float   PATH_REACHED_PATH_END   = 2;    
float   PATH_MOVE_BLOCKED       = 3;    
float   PATH_IN_PROGRESS        = 4;    

//============================================================================
// ##FQXDEV: GLOBAL VARIABLES (From FQX defs_3.qc, aligned with QRRQC-defs.qc for standards)
//============================================================================
float   movedist;                      
float   gameover;                       
string  string_null;                    
entity  newmis;                         
entity  activator;                      
entity  damage_attacker;                
float   framecount;                    
float   skill;                         
float   campaign_valid;                
float   campaign;                      
float   cheats_allowed;                 

//============================================================================
// ##FQXDEV: WORLD ENTITY FIELDS (From FQX defs_3.qc, aligned with QRRQC-defs.qc)
//============================================================================
.string wad;                           
.string map;                            
float   WORLDTYPE_MEDIEVAL      = 0;   
float   WORLDTYPE_METAL         = 1;   
float   WORLDTYPE_BASE          = 2;   
.float  worldtype;                     

//============================================================================
// ##FQXDEV: GENERAL ENTITY FIELDS (From FQX defs_3.qc, aligned with QRRQC-defs.qc)
//============================================================================
.string killtarget;                    
.float  light_lev;                      
.float  style;                         
.void() th_stand;                      
.void() th_walk;                       
.void() th_run;                        
.void() th_missile;                    
.void() th_melee;                      
.void(entity attacker, float damage) th_pain;
.void() th_die;                        
.entity oldenemy;                       
.float  speed;                         
.float  lefty;                         
.float  search_time;                   
.float  attack_state;                   
float   AS_STRAIGHT             = 1;   
float   AS_SLIDING              = 2;   
float   AS_MELEE                = 3;   
float   AS_MISSILE              = 4;   
.float  allowPathFind;                  
.float  combat_style;                   
float   CS_NONE                 = 0;    
float   CS_RANGED               = 1;   
float   CS_MELEE                = 2;   
float   CS_MIXED                = 3;    
.float  walkframe;                     
.float  attack_finished;               
.float  pain_finished;                 
.float  invincible_finished;           
.float  invisible_finished;            
.float  super_damage_finished;         
.float  radsuit_finished;              
.float  invincible_time, invincible_sound;
.float  invisible_time, invisible_sound;
.float  super_time, super_sound;       
.float  rad_time;                      
.float  fly_sound;                     
.float  healthrot_nextcheck;            
.float  axhitme;                       
.float  show_hostile;                   
.float  jump_flag;                      
.float  swim_flag;                      
.float  air_finished;                   
.float  bubble_count;                   
.string deathtype;                      
.float  fired_weapon;                   
.float  took_damage;                    
.string mdl;                           
.vector mangle;                         
// .vector oldorigin; // This is a system field from defs_1.qc
.float  t_length, t_width;             
.vector dest, dest1, dest2;            
.float  wait;                           
.float  delay;                          
.entity trigger_field;                  
.string noise4;                         
.float  pausetime;                     
.entity movetarget;                    
.float  aflag;                         
.float  dmg;                            
.float  cnt;                            
.void() think1;                        
.vector finaldest, finalangle;         
.float  count;                          
.float  lip;                           
.float  state;                         
.vector pos1, pos2;                     
.float  height;                        
.float  waitmin, waitmax;              
.float  distance;                      
.float  volume;                        
.string killstring;                     
.float  spawn_deferred;                 

//============================================================================
// ##FQXDEV: FORWARD DECLARATIONS (From FQX defs_3.qc)
//============================================================================
void makevectorsfixed(vector ang);      

void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;
void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void()  SUB_CalcAngleMoveDone;
void()  SUB_Null;
void()  SUB_UseTargets;
void()  SUB_Remove;

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity e, float healamount, float ignore) T_Heal; 
float(entity targ, entity inflictor) CanDamage;

//============================================================================
// ##FQXDEV: BUILT-IN ENGINE FUNCTIONS (PROGS BUILTINS) - ALIGNED WITH QRRQC-defs.qc.txt
//============================================================================
void(vector ang)    makevectors         = #1;  
void(entity e, vector o) setorigin      = #2;  
void(entity e, string m) setmodel       = #3;  
void(entity e, vector minv, vector maxv) setsize = #4;
// #5 removed
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
void(entity client, string s) stuffcmd  = #21; 
entity(vector org, float rad) findradius = #22;
// SVC_TEMPENTITY = 23 (in constants)
// ##Quedra: QRRQC uses #0:ex_bprint, #0:ex_sprint. FTEQCC also supports #24/#25 for them.
// ##Quedra: Using QRRQC direct # numbers for core functions if they differ from user's for max KEX compatibility.
void(string s, ...) bprint              = #0:ex_bprint; // Was #24 in FQX
void(entity client, string s, ...) sprint = #0:ex_sprint; // Was #25 in FQX
void(string s, ...) dprint              = #25; // Was #26 in FQX, is #25 in QRRQC
string(float f)     ftos                = #26; // Was #27 in FQX, is #26 in QRRQC
string(vector v)    vtos                = #27; // Was #28 in FQX, is #27 in QRRQC
void()              coredump            = #28; // Was #29 in FQX, is #28 in QRRQC
void()              traceon             = #29; // Was #30 in FQX, is #29 in QRRQC
void()              traceoff            = #30; // Was #31 in FQX, is #30 in QRRQC
void(entity e)      eprint              = #31; // Was #32 in FQX, is #31 in QRRQC
float(float yaw, float dist) walkmove   = #32; // Was #33 in FQX, is #32 in QRRQC
// #33 removed
float()             droptofloor         = #34; 
void(float style, string value) lightstyle = #35; // QRRQC uses style, value
float(float v)      rint                = #36; 
float(float v)      floor               = #37; 
float(float v)      ceil                = #38; 
// #39 removed
float(entity e)     checkbottom         = #40; 
float(vector v)     pointcontents       = #41; 
// #42 removed
float(float f)      fabs                = #43; 
vector(entity e, float speed) aim       = #44; // QRRQC uses speed
float(string s)     cvar                = #45; 
void(string s)      localcmd            = #46; 
entity(entity e)    nextent             = #47; 
void(vector o, vector d, float color, float count) particle = #48; // QRRQC uses color, count
void()              ChangeYaw           = #49; 
// #50 removed
vector(vector v)    vectoangles         = #51; 
void(float to, float f) WriteByte       = #52; 
void(float to, float f) WriteChar       = #53; 
void(float to, float f) WriteShort      = #54; 
void(float to, float f) WriteLong       = #55; 
void(float to, float f) WriteCoord      = #56; 
void(float to, float f) WriteAngle      = #57; 
void(float to, string s) WriteString    = #58; 
void(float to, entity s) WriteEntity    = #59; // QRRQC uses entity s (not e)
// #60-#66 for bWrite* are not in QRRQC standard defs.qc, they are comments
void(float step) movetogoal             = #67; // QRRQC uses step
string(string s)    precache_file       = #68; 
void(entity e)      makestatic          = #69; 
void(string s)      changelevel         = #70; 
// #71 removed
void(string var, string val) cvar_set   = #72; // QRRQC uses var, val
void(entity client, string s, ...) centerprint = #0:ex_centerprint; // Was #73 in FQX
void(vector pos, string samp, float vol, float atten) ambientsound = #74; // QRRQC uses pos
string(string s)    precache_model2     = #75; 
string(string s)    precache_sound2     = #76; 
string(string s)    precache_file2      = #77; 
void(entity e)      setspawnparms       = #78; 

// KEX Extended Builtins (from QRRQC-defs.qc.txt)
float() finaleFinished = #0:ex_finaleFinished;   
void(entity client, string sample) localsound = #0:ex_localsound;
void(vector point, float colormap, float lifetime, float depthtest) draw_point = #0:ex_draw_point;
void(vector start, vector end, float colormap, float lifetime, float depthtest) draw_line = #0:ex_draw_line; 
void(vector start, vector end, float colormap, float size, float lifetime, float depthtest) draw_arrow = #0:ex_draw_arrow;
void(vector start, vector direction, float length, float colormap, float size, float lifetime, float depthtest) draw_ray = #0:ex_draw_ray;
void(vector origin, float radius, float colormap, float lifetime, float depthtest) draw_circle = #0:ex_draw_circle;
void(vector minv, vector maxv, float colormap, float lifetime, float depthtest) draw_bounds = #0:ex_draw_bounds;
void(string s, vector origin, float size, float lifetime, float depthtest) draw_worldtext = #0:ex_draw_worldtext;
void(vector origin, float radius, float colormap, float lifetime, float depthtest) draw_sphere = #0:ex_draw_sphere;
void(vector origin, float halfHeight, float radius, float colormap, float lifetime, float depthtest) draw_cylinder = #0:ex_draw_cylinder;
float(entity bot, vector point) bot_movetopoint = #0:ex_bot_movetopoint;
float(entity bot, entity goal) bot_followentity = #0:ex_bot_followentity;
float(entity playerEnt) CheckPlayerEXFlags = #0:ex_CheckPlayerEXFlags;
float(float movedist, vector goal) walkpathtogoal = #0:ex_walkpathtogoal;
float checkextension( string s ) = #99;

//=============================================================================
// defs_3.qc - Version 1.7 - End of FQX Mod - Part 3 of Global Definitions
//=============================================================================