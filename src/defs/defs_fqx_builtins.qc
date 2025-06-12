// =======================================================================
//
//  ##File: defs_fqx_builtins.qc
//  ##File Description: FQX Definitions - Engine Built-in Functions
//  ##FQX - ##FQXnote.: Version 1.1.0 (20250611.044810CDT)
//
//  ##FQXnote.
//    v1.1.0 - Corrected strcat declaration to use the FTEQCC intrinsic
//             (#0:ex_strcat) per the 'Edict on String Concatenation'.
//    v1.0.1 - Corrected function signatures to match defs_quake_core.qc.
//    v1.0.0 - Initial creation.
//
// =======================================================================

//--[ Engine Built-in Function Declarations ]------------------------------
void(string e) error;
void(string var, string val) cvar_set;
float(string name) cvar;
void() main;
entity() spawn;
void(entity e) remove;
void(vector ang) makevectors;
void(vector ang) makevectorsfixed;
void(entity e, string m) setmodel;
void(entity e, vector min, vector max) setsize;
void(entity e, vector org) setorigin;
void(vector start, vector end, float nomonsters, entity passedict) traceline;
float(vector p) pointcontents;
float(entity e) checkbottom;
float(entity e1, entity e2) visible;
void(entity e, float chan, string samp, float vol, float atten) sound;
string(string s) precache_sound;
string(string s) precache_model;
string(string s) precache_file;
string(string s) precache_file2;
string(string s) precache_model2;
void(string s, ...) bprint;
void(entity client, string s, ...) sprint;
void(entity client, string s, ...) centerprint;
void(entity client, string s) stuffcmd;
string(float f) ftos;
string(vector v) vtos;
vector(vector v) normalize;
float(vector v) vlen;
float(vector v) vectoyaw;

// ##FQXnote.: CORRECTED - This now points to the FTEQCC intrinsic for string
// ##FQXnote.: concatenation, resolving the compiler error.
string(string s1, string s2, ...) strcat = #0:ex_strcat;

// =======================================================================
// ##FQX - ##FQXnote.: Version 1.1.0
// ##File: defs_fqx_builtins.qc
// =======================================================================