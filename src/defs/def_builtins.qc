// ======================================================================= //
//  ##File: /defs/def_builtins.qc
//  ##Project Version: FQX Phoenix v0.5
//  ##File Description: Contains built-in function and QRRQC extension declarations.
//  ##File Version: 1.0.1 (20250614.193230CDT)
//
//   v1.0.1 - Corrected declaration of 'sprint' built-in to include 'entity client' parameter. - ##FIREFQX
//   v1.0.0 - Initial creation from defs.qc PART 4: BUILT-IN FUNCTION DECLARATIONS. - ##FIREFQX
//
// =======================================================================

#ifndef DEF_BUILTINS_QC_H_
#define DEF_BUILTINS_QC_H_

//-------------------------------------------------------------------------
// PART 4: BUILT-IN FUNCTION DECLARATIONS
//-------------------------------------------------------------------------

void(vector ang)    makevectors             = #1;
void(entity e, vector o) setorigin      = #2;
void(entity e, string m) setmodel       = #3;
void(entity e, vector min, vector max) setsize = #4;
void()              break                   = #6;
float()             random                  = #7;
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v)    normalize               = #9;
void(string e)      error                   = #10;
void(string e)      objerror                = #11;
float(vector v)     vlen                    = #12;
float(vector v)     vectoyaw                = #13;
entity()            spawn                   = #14;
void(entity e)      remove                  = #15;
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;
entity()            checkclient             = #17;
entity(entity start, .string fld, string match) find = #18;
string(string s)    precache_sound          = #19;
string(string s)    precache_model          = #20;
void(entity client, string s, ...) stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s, ...) dprint                  = #25;
string(float f)     ftos                    = #26;
string(vector v)    vtos                    = #27;
void()              coredump                = #28;
void()              traceon                 = #29;
void()              traceoff                = #30;
void(entity e)      eprint                  = #31;
float(float yaw, float dist) walkmove = #32;
float()             droptofloor             = #34;
void(float style, string value) lightstyle = #35;
float(float v)      rint                    = #36;
float(float v)      floor                   = #37;
float(float v)      ceil                    = #38;
float(entity e)     checkbottom             = #40;
float(vector v)     pointcontents           = #41;
float(float f)      fabs                    = #43;
vector(entity e, float speed) aim        = #44;
float(string s)     cvar                    = #45;
void(string s)      localcmd                = #46;
entity(entity e)    nextent                 = #47;
void(vector o, vector d, float color, float count) particle = #48;
void()              ChangeYaw               = #49;
vector(vector v)    vectoangles             = #51;
void(float to, float f) WriteByte           = #52;
void(float to, float f) WriteChar           = #53;
void(float to, float f) WriteShort          = #54;
void(float to, float f) WriteLong           = #55;
void(float to, float f) WriteCoord          = #56;
void(float to, float f) WriteAngle          = #57;
void(float to, string s) WriteString        = #58;
void(float to, entity s) WriteEntity        = #59;
void(float step)    movetogoal              = #67;
string(string s)    precache_file           = #68;
void(entity e)      makestatic              = #69;
void(string s)      changelevel             = #70;
void(string var, string val) cvar_set = #72;
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
string(string s)    precache_model2         = #75;
string(string s)    precache_sound2         = #76;
string(string s)    precache_file2          = #77;
void(entity e)      setspawnparms           = #78;
float(string s)     checkextension          = #99;

// QRRQC Extensions
void(string s, ...) bprint                  = #0:ex_bprint;
void(entity client, string s, ...) sprint = #0:ex_sprint; // ##FIREFQX: Corrected declaration.
void(entity client, string s, ...) centerprint = #0:ex_centerprint;
string(...)         strcat                  = #0:ex_strcat;
float()             finaleFinished          = #0:ex_finaleFinished;
void(entity client, string sample) localsound = #0:ex_localsound;
float(entity playerEnt) CheckPlayerEXFlags = #0:ex_CheckPlayerEXFlags;
float(float movedist, vector goal) walkpathtogoal = #0:ex_walkpathtogoal;

#endif // DEF_BUILTINS_QC_H_

// ======================================================================= //
// Project: FQX Phoenix v0.5
// File: /defs/def_builtins.qc - File Version: 1.0.1
// Last Coder: ##FIREFQX
// =======================================================================