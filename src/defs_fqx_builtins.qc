//=============================================================================
// defs_fqx_builtins.qc - FQX Mod - Engine Built-in Aliases
// Location: /src/
// ##FQX - ##Quedra: Version 1.0.0
// ##Quedra: Consolidates aliases for engine built-in functions to ensure KEX
// ##Quedra: engine compatibility and provide convenient access.
//=============================================================================

//-----------------------------------------------------------------------------
// ##Quedra: BUILT-IN ALIASES (from defs_2.qc)
//-----------------------------------------------------------------------------
string(string cvar_name) cvar_string    = #0:ex_cvar_string;
string(string s1, string s2, ...) strcat = #0:ex_strcat;
float(string s) strlen                  = #0:ex_strlen;
string(string s, float start_index, float length) substring = #0:ex_substring;
float(string s) stof                    = #0:ex_stof;

//=============================================================================
// defs_fqx_builtins.qc - FQX Mod - Engine Built-in Aliases - END
// ##FQX - ##Quedra: Version 1.0.0
//=============================================================================