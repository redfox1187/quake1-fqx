//=============================================================================
// world.qc - FQX Mod - World Spawn Logic & Global Initializations
// ##FQXCUSTOM - ##Rook: Version 1.1.1
// ##Rook: v1.1.1 - Corrected execution order. Moved FQX_MasterPrecache() to be the
// ##Rook:          first call in worldspawn() to prevent memory overflow during
// ##Rook:          entity initialization. This is the fix.
//=============================================================================

/* Copyright (C) 1996-2022 id Software LLC
    (Standard GPL License text)
    See file, 'COPYING', for details.
*/

//=============================================================================
// ##Quedra: Forward Declarations
//=============================================================================
void() InitBodyQueue; // Defined below
void() main;          // Defined below
void() worldspawn;    // Defined below
void() StartFrame; // Defined below
void() bodyqueue;     // Defined below
void(entity ent) CopyToBodyQueue; // Defined below

// --- From other FQX modules (assumed declared in defs_*.qc) ---
// void() FQX_MasterPrecache; // From op_precache.qc
// string(string msg) GetMapName; // From client.qc (or other utility)
// void() W_Precache; // From weapons.qc (called by FQX_MasterPrecache)

//=============================================================================
// ##IDSOFT - ##Quedra: main - Initial File Precaching (Compiler Directives)
//=============================================================================
void() main =
{
    dprint("main function\n"); 
    
    precache_file("progs.dat"); 
    precache_file("gfx.wad"); 
    precache_file("quake.rc"); 
    precache_file("default.cfg"); 

    precache_file("end1.bin"); 
    precache_file2("end2.bin"); 

    precache_file("demo1.dem"); 
    precache_file("demo2.dem"); 
    precache_file("demo3.dem"); 

    precache_file("gfx/palette.lmp"); 
    precache_file("gfx/colormap.lmp"); 
    precache_file2("gfx/pop.lmp"); 
    precache_file("gfx/complete.lmp"); 
    precache_file("gfx/inter.lmp"); 
    precache_file("gfx/ranking.lmp"); 
    precache_file("gfx/vidmodes.lmp"); 
    precache_file("gfx/finale.lmp"); 
    precache_file("gfx/conback.lmp"); 
    precache_file("gfx/qplaque.lmp"); 
    precache_file("gfx/menudot1.lmp"); 
    precache_file("gfx/menudot2.lmp"); 
    precache_file("gfx/menudot3.lmp"); 
    precache_file("gfx/menudot4.lmp"); 
    precache_file("gfx/menudot5.lmp"); 
    precache_file("gfx/menudot6.lmp"); 
    precache_file("gfx/menuplyr.lmp"); 
    precache_file("gfx/bigbox.lmp"); 
    precache_file("gfx/dim_modm.lmp"); 
    precache_file("gfx/dim_drct.lmp"); 
    precache_file("gfx/dim_ipx.lmp"); 
    precache_file("gfx/dim_tcp.lmp"); 
    precache_file("gfx/dim_mult.lmp"); 
    precache_file("gfx/mainmenu.lmp"); 
    precache_file("gfx/box_tl.lmp"); 
    precache_file("gfx/box_tm.lmp"); 
    precache_file("gfx/box_tr.lmp"); 
    precache_file("gfx/box_ml.lmp"); 
    precache_file("gfx/box_mm.lmp"); 
    precache_file("gfx/box_mm2.lmp"); 
    precache_file("gfx/box_mr.lmp"); 
    precache_file("gfx/box_bl.lmp"); 
    precache_file("gfx/box_bm.lmp"); 
    precache_file("gfx/box_br.lmp"); 
    precache_file("gfx/sp_menu.lmp"); 
    precache_file("gfx/ttl_sgl.lmp"); 
    precache_file("gfx/ttl_main.lmp"); 
    precache_file("gfx/ttl_cstm.lmp"); 
    precache_file("gfx/mp_menu.lmp"); 
    precache_file("gfx/netmen1.lmp"); 
    precache_file("gfx/netmen2.lmp"); 
    precache_file("gfx/netmen3.lmp"); 
    precache_file("gfx/netmen4.lmp"); 
    precache_file("gfx/netmen5.lmp"); 
    precache_file("gfx/sell.lmp"); 
    precache_file("gfx/help0.lmp"); 
    precache_file("gfx/help1.lmp"); 
    precache_file("gfx/help2.lmp"); 
    precache_file("gfx/help3.lmp"); 
    precache_file("gfx/help4.lmp"); 
    precache_file("gfx/help5.lmp"); 
    precache_file("gfx/pause.lmp"); 
    precache_file("gfx/loading.lmp"); 
    precache_file("gfx/p_option.lmp"); 
    precache_file("gfx/p_load.lmp"); 
    precache_file("gfx/p_save.lmp"); 
    precache_file("gfx/p_multi.lmp"); 
    precache_sound("misc/menu1.wav"); 
    precache_sound("misc/menu2.wav"); 
    precache_sound("misc/menu3.wav"); 
    precache_sound("ambience/water1.wav"); 
    precache_sound("ambience/wind2.wav"); 

    precache_file("maps/start.bsp"); 
    precache_file("maps/e1m1.bsp"); 
    precache_file("maps/e1m2.bsp"); 
    precache_file("maps/e1m3.bsp"); 
    precache_file("maps/e1m4.bsp"); 
    precache_file("maps/e1m5.bsp"); 
    precache_file("maps/e1m6.bsp"); 
    precache_file("maps/e1m7.bsp"); 
    precache_file("maps/e1m8.bsp"); 

    precache_file2("maps/e2m1.bsp"); 
    precache_file2("maps/e2m2.bsp"); 
    precache_file2("maps/e2m3.bsp"); 
    precache_file2("maps/e2m4.bsp"); 
    precache_file2("maps/e2m5.bsp"); 
    precache_file2("maps/e2m6.bsp"); 
    precache_file2("maps/e2m7.bsp"); 
    precache_file2("maps/e3m1.bsp"); 
    precache_file2("maps/e3m2.bsp"); 
    precache_file2("maps/e3m3.bsp"); 
    precache_file2("maps/e3m4.bsp"); 
    precache_file2("maps/e3m5.bsp"); 
    precache_file2("maps/e3m6.bsp"); 
    precache_file2("maps/e3m7.bsp"); 
    precache_file2("maps/e4m1.bsp"); 
    precache_file2("maps/e4m2.bsp"); 
    precache_file2("maps/e4m3.bsp"); 
    precache_file2("maps/e4m4.bsp"); 
    precache_file2("maps/e4m5.bsp"); 
    precache_file2("maps/e4m6.bsp"); 
    precache_file2("maps/e4m7.bsp"); 
    precache_file2("maps/e4m8.bsp"); 
    precache_file2("maps/end.bsp"); 
    precache_file2("maps/dm1.bsp"); 
    precache_file2("maps/dm2.bsp"); 
    precache_file2("maps/dm3.bsp"); 
    precache_file2("maps/dm4.bsp"); 
    precache_file2("maps/dm5.bsp"); 
    precache_file2("maps/dm6.bsp"); 
};

//=============================================================================
// ##IDSOFT - ##Quedra: worldspawn - Called when a map is loaded
//=============================================================================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity. 
Set message to the level name. 
Set sounds to the cd track to play.
World Types: 
0: medieval
1: metal
2: base
*/

void() worldspawn =
{
    // ##ROOK'S FIX: Master precache MUST be the first operation to prevent
    // ##ROOK'S FIX: a memory overflow where monster data is corrupted by
    // ##ROOK'S FIX: precache string data during simultaneous entity spawn.
    FQX_MasterPrecache();

    startingserverflags = serverflags; 
    lastspawn = world; 
    InitBodyQueue(); 

    // ##FQX - ##Quedra: Initialize Monster Core debug print toggle
    mc_debug_prints_enabled = 0; // Off by default

    // ##IDSOFT: Custom map attributes
    if (self.model == "maps/e1m8.bsp") 
    {
        cvar_set("sv_gravity", "100"); 
    }
    else
    {
        cvar_set("sv_gravity", "800"); // Default gravity 
    }

    // ##IDSOFT: Custom map title (from world entity's message field)
    self.message = GetMapName(self.message); // Assumes GetMapName is defined in client.qc or defs 
    
    // ##IDSOFT: Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
    lightstyle(0, "m"); 
    lightstyle(1, "mmnmmommommnonmmonqnmmo"); 
    lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"); 
    lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"); 
    lightstyle(4, "mamamamamama"); 
    lightstyle(5, "jklmnopqrstuvwxyzyxwvutsrqponmlkj"); 
    lightstyle(6, "nmonqnmomnmomomno"); 
    lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm"); 
    lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"); 
    lightstyle(9, "aaaaaaaazzzzzzzz"); 
    lightstyle(10, "mmamammmmammamamaaamammma"); 
    lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba"); 
    lightstyle(63, "a"); 
};

//=============================================================================
// ##IDSOFT - ##Quedra: StartFrame - Called at the start of each frame
//=============================================================================
void() StartFrame =
{
    teamplay = cvar("teamplay"); 
    skill = cvar("skill"); 
    cheats_allowed = cvar("sv_cheats"); 

    // ##Quedra: Campaign cvar handling from QRRQC 
    if (!campaign_valid) 
    {
        campaign_valid = TRUE; 
        campaign = cvar("campaign"); 
    } 
    else 
    {
        cvar_set("campaign", ftos(campaign)); 
    }

    framecount = framecount + 1; 
};

//==============================================================================
// ##IDSOFT - ##Quedra: BODY QUE - For managing player corpses in DM/Coop
//==============================================================================
entity bodyqueue_head; 

void() bodyqueue = {}; // Placeholder for entity type 

void() InitBodyQueue = 
{   
    bodyqueue_head = spawn(); 
    bodyqueue_head.classname = "bodyqueue"; 
    
    bodyqueue_head.owner = spawn(); 
    bodyqueue_head.owner.classname = "bodyqueue"; 
    bodyqueue_head.owner.owner = spawn(); 
    bodyqueue_head.owner.owner.classname = "bodyqueue"; 
    bodyqueue_head.owner.owner.owner = spawn(); 
    bodyqueue_head.owner.owner.owner.classname = "bodyqueue"; 
    bodyqueue_head.owner.owner.owner.owner = bodyqueue_head; // Link last to first 
};

// make a body que entry for the given ent so the ent can be respawned elsewhere 
void(entity ent) CopyToBodyQueue =
{
    bodyqueue_head.angles = ent.angles; 
    bodyqueue_head.model = ent.model; 
    bodyqueue_head.modelindex = ent.modelindex; 
    bodyqueue_head.frame = ent.frame; 
    bodyqueue_head.colormap = ent.colormap; 
    bodyqueue_head.movetype = ent.movetype; 
    bodyqueue_head.velocity = ent.velocity; 
    bodyqueue_head.flags = 0; 
    
    setorigin(bodyqueue_head, ent.origin); 
    setsize(bodyqueue_head, ent.mins, ent.maxs); 
    
    bodyqueue_head = bodyqueue_head.owner; 
};

//=============================================================================
// world.qc - End of FQX Mod - World Spawn Logic & Global Initializations
// ##FQXCUSTOM - ##Rook: Version 1.1.1
//=============================================================================