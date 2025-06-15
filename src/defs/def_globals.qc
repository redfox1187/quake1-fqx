// ======================================================================= //
//  ##File: /defs/def_globals.qc
//  ##Project Version: FQX Phoenix v0.5
//  ##File Description: Contains all global variable declarations for the FQX Project.
//  ##File Version: 1.0.0 (20250614.190900CDT)
//
//   v1.0.0 - Initial creation from defs.qc PART 1: GLOBAL VARIABLES. - ##FIREFQX
//
// =======================================================================

#ifndef DEF_GLOBALS_QC_H_
#define DEF_GLOBALS_QC_H_

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


#endif // DEF_GLOBALS_QC_H_

// ======================================================================= //
// Project: FQX Phoenix v0.5
// File: /defs/def_globals.qc - File Version: 1.0.0
// Last Coder: ##FIREFQX
// =======================================================================