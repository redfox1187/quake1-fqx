//=============================================================================
// subs.qc - FQX Mod - Standard Subroutines & FQX Utilities
// Location: /fqx_mod/source/game/
// ##FQXCUSTOM - ##Quedra: Version 1.1.8
// ##IDSOFT: Based significantly on id Software's QRRQC subs.qc structure.
// ##Quedra: Contains common utility functions for the FQX mod, merged with QRRQC base.
// ##Quedra: v1.1.8 - Changed ToggleMonsterCoreDebugPrints to use sprint(self, ...)
// ##Quedra:          as an alternative to print() due to compiler issues with 'print'.
// ##Quedra: Previous: v1.1.7 - Corrected ToggleMonsterCoreDebugPrints to use print() [had error].
// ##Quedra: Previous: v1.1.6 - Re-added definition for ToggleMonsterCoreDebugPrints.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text - Original Source ID: QRRQC subs.qc)
    See file, 'COPYING', for details.
*/

//=============================================================================
// ##Quedra: FORWARD DECLARATIONS (Locally Defined, QRRQC Standards & FQX Utilities)
//=============================================================================
void() SUB_Null;
void() SUB_Remove;
void() SetMovedir;
void() InitTrigger;

void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void() SUB_CalcMoveDone;
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt;

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void() SUB_CalcAngleMoveDone;
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt;

void() DelayThink;
void() SUB_UseTargets; // QRRQC version

void(float normal) SUB_AttackFinished;
void(void() thinkst) SUB_CheckRefire;

string(entity e) etos; // FQX Utility
void() ToggleMonsterCoreDebugPrints; // ##Quedra: Added FQX Utility forward declaration

// ##Quedra: Standard AI functions (defined in ai.qc, used as fallbacks/called by QRRQC subs)
void() ai_stand;
void(float dist) ai_walk;
void(float dist) ai_run;

// ##Quedra: Visibility function - Forward declaration as per QRRQC subs.qc
// ##Quedra: Definition is expected from ai.qc or as an engine built-in.
float(entity targ) visible; 

//=============================================================================
// ##IDSOFT - ##Quedra: Standard Empty Subroutine (from QRRQC)
//=============================================================================
void() SUB_Null = {};

//=============================================================================
// ##IDSOFT - ##Quedra: Standard Entity Removal Subroutine (from QRRQC)
//=============================================================================
void() SUB_Remove = {remove(self);};

//=============================================================================
// ##IDSOFT - ##Quedra: Set Movedir Subroutine (from QRRQC subs.qc)
//=============================================================================
void() SetMovedir =
{
    if (self.angles == '0 -1 0') 
        self.movedir = '0 0 1';
    else if (self.angles == '0 -2 0') 
        self.movedir = '0 0 -1';
    else
    {
        makevectors(self.angles);
        self.movedir = v_forward;
    }
    self.angles = '0 0 0'; 
};

//=============================================================================
// ##IDSOFT - ##Quedra: Initialize Trigger Subroutine (from QRRQC subs.qc)
//=============================================================================
void() InitTrigger =
{
    if (self.angles != '0 0 0')
        SetMovedir ();

    self.solid = SOLID_TRIGGER;
    setmodel (self, self.model); 
    self.movetype = MOVETYPE_NONE;
    self.modelindex = 0; 
    self.model = string_null; 
};

//=============================================================================
// ##IDSOFT - ##Quedra: SUB_CalcMove Variants (from QRRQC subs.qc)
//=============================================================================
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
    local entity stemp;
    stemp = self;
    self = ent;
    SUB_CalcMove (tdest, tspeed, func);
    self = stemp;
}; 

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
    local vector vdestdelta;
    local float len, traveltime;

    if (!tspeed)
        objerror("SUB_CalcMove: No speed is defined!"); 

    self.think1 = func; 
    self.finaldest = tdest; 
    self.think = SUB_CalcMoveDone; 

    if (tdest == self.origin)
    {
        self.velocity = '0 0 0';
        self.nextthink = self.ltime + 0.1; 
        return;
    }
        
    vdestdelta = tdest - self.origin; 
    len = vlen (vdestdelta); 
    
    traveltime = len / tspeed; 
    if (traveltime < 0.1) 
    {
        self.velocity = '0 0 0'; 
        self.nextthink = self.ltime + 0.1; 
        return;
    }
    
    self.nextthink = self.ltime + traveltime; 
    self.velocity = vdestdelta * (1/traveltime); 
};

void() SUB_CalcMoveDone =
{
    setorigin(self, self.finaldest); 
    self.velocity = '0 0 0'; 
    self.nextthink = -1; 

    if (self.think1)
        self.think1(); 
}; 

//=============================================================================
// ##IDSOFT - ##Quedra: SUB_CalcAngleMove Variants (from QRRQC subs.qc)
//=============================================================================
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
    local entity stemp;
    stemp = self;
    self = ent;
    SUB_CalcAngleMove (destangle, tspeed, func);
    self = stemp;
}; 

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
    local vector destdelta;
    local float len, traveltime;

    if (!tspeed)
        objerror("SUB_CalcAngleMove: No speed is defined!"); 

    destdelta = destangle - self.angles; 
    len = vlen (destdelta); 
    
    traveltime = len / tspeed; 
    self.nextthink = self.ltime + traveltime; 
    self.avelocity = destdelta * (1 / traveltime); 
    self.think1 = func; 
    self.finalangle = destangle; 
    self.think = SUB_CalcAngleMoveDone; 
};

void() SUB_CalcAngleMoveDone =
{
    self.angles = self.finalangle; 
    self.avelocity = '0 0 0'; 
    self.nextthink = -1; 
    if (self.think1)
        self.think1(); 
};

//=============================================================================
// ##IDSOFT - ##Quedra: SUB_UseTargets (QRRQC Version)
//=============================================================================
void() DelayThink = 
{
    activator = self.enemy;
    SUB_UseTargets (); 
    remove(self);
};

void() SUB_UseTargets =
{
    local entity t, act, stemp, otemp;

    if (cvar("developer") > 0 && mc_debug_prints_enabled == TRUE)
    {
        dprint("SUB_UseTargets (QRRQC Base): Fired by '");
        if (self.netname != string_null) { dprint(self.netname); } else { dprint(self.classname); }
        dprint("' ("); dprint(etos(self)); dprint("), targeting '");
        dprint(self.target); dprint("'. Current Activator: "); dprint(etos(activator)); dprint("\n");
    }

    if (self.delay) 
    {
        t = spawn(); 
        t.classname = "DelayedUse"; 
        t.nextthink = time + self.delay; 
        t.think = DelayThink; 
        t.enemy = activator; 
        t.message = self.message; 
        t.killtarget = self.killtarget; 
        t.target = self.target; 
        return;
    }
    
    if (activator.classname == "player" && self.message != string_null) 
    {
        centerprint (activator, self.message);
        if (!self.noise) 
            sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
    }

    if (self.killtarget != string_null) 
    {
        t = find (world, targetname, self.killtarget);
        while( t )
        {
            remove (t);
            t = find (t, targetname, self.killtarget);
        }
    }
    
    if (self.target != string_null) 
    {
        act = activator; 
        t = find (world, targetname, self.target);
        while( t )
        {
            stemp = self; 
            otemp = other; 
            
            self = t;    
            other = stemp; 

            if (self.use != SUB_Null) 
            {
                if (self.use) 
                    self.use(); 
            }
            self = stemp;   
            other = otemp;  
            activator = act; 
            t = find (t, targetname, self.target); 
        }
    }
};

//=============================================================================
// ##IDSOFT - ##Quedra: SUB_AttackFinished (QRRQC AI Helper - Modified for FQX)
//=============================================================================
void(float normal) SUB_AttackFinished = 
{
    self.cnt = 0; 

    if (normal > 0)
    {
        self.attack_finished = time + normal;
    }
    else if (self.pausetime > 0) 
    {
        self.attack_finished = time + self.pausetime + (random() * 0.2); 
    }
    else
    {
        self.attack_finished = time + 0.5 + random() * 0.5; 
    }

    if (self.enemy != world && visible(self.enemy) && self.th_run != SUB_Null)
    {
        self.think = self.th_run; 
    }
    else if (self.th_stand != SUB_Null)
    {
        self.think = self.th_stand; 
    }
    else
    {
        self.think = ai_stand; 
    }
    self.nextthink = time + 0.1; 
};

//=============================================================================
// ##IDSOFT - ##Quedra: SUB_CheckRefire (QRRQC AI Helper - Modified for FQX)
//=============================================================================
void(void() thinkst) SUB_CheckRefire = 
{
    if (self.enemy == world || self.enemy.health <= 0 || !visible(self.enemy))
    {
        self.attack_finished = time + 0.5 + random(); 
        if (self.th_stand != SUB_Null)
            self.think = self.th_stand;
        else
            self.think = ai_stand; 
        self.nextthink = time + 0.1;
        return;
    }

    if (skill != 3) 
    {
        if (random() < 0.35) 
        {
            self.attack_finished = time + (0.2 + random() * 0.5) * (3 - skill); 
            if (self.th_stand != SUB_Null)
                self.think = self.th_stand;
            else
                self.think = ai_stand;
            self.nextthink = time + 0.1;
            return;
        }
    }
    
    self.think = thinkst;
    self.nextthink = time + 0.1; 
};

//=============================================================================
// ##FQX - ##Quedra: Entity to String Utility Function (Corrected)
//=============================================================================
string(entity e) etos =
{
    local string s_classname, s_targetname, s_modelindex_str;
    local string out_string;

    if (!e || e == world)
    {
        if (!e) return "null_entity";
        if (e == world) return "world_entity";
    }

    s_classname = e.classname;
    if (s_classname == string_null || s_classname == "") { s_classname = "no_classname"; }

    s_targetname = e.targetname;
    if (s_targetname == string_null || s_targetname == "") { s_targetname = "no_targetname"; }
    
    s_modelindex_str = ftos(e.modelindex);
    if (e.model == string_null || e.model == "") { s_modelindex_str = strcat(s_modelindex_str, "(no_model)"); }

    out_string = strcat("[", s_classname);
    if (e.targetname != string_null && e.targetname != "") 
    {
        out_string = strcat(out_string, ":", s_targetname);
    }
    if (e.netname != string_null && e.netname != "")
    {
        out_string = strcat(out_string, " net:", e.netname);
    }
    out_string = strcat(out_string, " modelidx:", s_modelindex_str, "]");
    
    return out_string;
};

//=============================================================================
// ##FQX - ##Quedra: ToggleMonsterCoreDebugPrints (Alternative Print Method)
// ##Quedra: Toggles the mc_debug_prints_enabled global for Monster Core diagnostics.
//=============================================================================
void() ToggleMonsterCoreDebugPrints =
{
    if (mc_debug_prints_enabled == TRUE)
    {
        mc_debug_prints_enabled = FALSE;
        // ##Quedra: Using sprint(self, ...) for local console message.
        sprint(self, "FQX: Monster Core Diagnostics: OFF\n"); 
    }
    else
    {
        mc_debug_prints_enabled = TRUE;
        // ##Quedra: Using sprint(self, ...) for local console message.
        sprint(self, "FQX: Monster Core Diagnostics: ON\n");  
    }
};

//=============================================================================
// subs.qc - FQX Mod - Standard Subroutines & FQX Utilities - END
// ##FQXCUSTOM - ##Quedra: Version 1.1.8
//=============================================================================