
//=============================================================================
// ##Quedra: PLAYER GAME EDGE FUNCTIONS 
//=============================================================================
void() respawn =
{
    if (coop)
    {
        CopyToBodyQueue(self);
        setspawnparms(self);
        PutClientInServer();
    }
    else if (deathmatch)
    {
        CopyToBodyQueue(self);
        SetNewParms();
        PutClientInServer();
    }
    else
    {
        serverflags = startingserverflags;
        reset_flag = TRUE;
        localcmd("changelevel ");
        localcmd(mapname);
        localcmd("\n");
    }
};

void() ClientKill =
{
    bprint("$qc_suicides ", self.netname, "\n");
    set_suicide_frame();
    self.modelindex = modelindex_player;
    self.frags = self.frags - 2;
    respawn();
};

float PlayerVisibleToSpawnPoint(entity point)
{
    local vector spot1, spot2;
    local entity player = find(world, classname, "player");

    while (player)
    {
        if (player.health > 0)
        {
            spot1 = point.origin + player.view_ofs;
            spot2 = player.origin + player.view_ofs;
            traceline(spot1, spot2, TRUE, point);
            if (trace_fraction >= 1)
            {
                return TRUE;
            }
        }
        player = find(player, classname, "player");
    }
    return FALSE;
}

entity SelectSpawnPoint(float forceSpawn)
{
    local entity spot, thing, spots_list_head;
    local float numspots, totalspots, pcount, pick_random;

    numspots = 0;
    totalspots = 0;
    spot = find(world, classname, "testplayerstart");
    if (spot)
    {
        return spot;
    }

    if (coop)
    {
        lastspawn = find(lastspawn, classname, "info_player_coop");
        if (lastspawn == world || !lastspawn)
        {
            lastspawn = find(world, classname, "info_player_start");
        }
        if (lastspawn != world && lastspawn)
        {
            return lastspawn;
        }
    }
    else if (deathmatch)
    {
        spots_list_head = world;
        spot = find(world, classname, "info_player_deathmatch");
        while (spot)
        {
            totalspots = totalspots + 1;
            thing = findradius(spot.origin, IDEAL_DIST_FROM_DM_SPAWN_POINT);
            pcount = 0;
            while (thing)
            {
                if (thing.classname == "player" && thing.health > 0)
                {
                    pcount = pcount + 1;
                }
                thing = thing.chain;
            }
            if (pcount == 0)
            {
                if (PlayerVisibleToSpawnPoint(spot))
                {
                    pcount = pcount + 1;
                }
            }
            if (pcount == 0)
            {
                spot.goalentity = spots_list_head;
                spots_list_head = spot;
                numspots = numspots + 1;
            }
            spot = find(spot, classname, "info_player_deathmatch");
        }
        if (numspots == 0)
        {
            spots_list_head = world;
            numspots = 0;
            spot = find(world, classname, "info_player_deathmatch");
            while (spot)
            {
                thing = findradius(spot.origin, MIN_DIST_FROM_DM_SPAWN_POINT);
                pcount = 0;
                while (thing)
                {
                    if (thing.classname == "player" && thing.health > 0)
                    {
                        pcount = pcount + 1;
                    }
                    thing = thing.chain;
                }
                if (pcount == 0)
                {
                    spot.goalentity = spots_list_head;
                    spots_list_head = spot;
                    numspots = numspots + 1;
                }
                spot = find(spot, classname, "info_player_deathmatch");
            }
        }
        if (!numspots)
        {
            if (forceSpawn == FALSE && self.spawn_deferred == 0)
            {
                return world;
            }
            spot = find(world, classname, "info_player_deathmatch");
            if (!spot)
            {
                objerror("No info_player_deathmatch spawn points found!");
                return world; // Should not reach
            }
            if (totalspots > 0)
            {
                pick_random = floor(random() * totalspots);
            }
            else
            {
                pick_random = 0;
            }
            while (pick_random > 0 && spot)
            {
                spot = find(spot, classname, "info_player_deathmatch");
                pick_random = pick_random - 1;
            }
            if (!spot)
            {
                spot = find(world, classname, "info_player_deathmatch");
            }
            return spot;
        }
        pick_random = floor(random() * numspots);
        spot = spots_list_head;
        while (pick_random > 0)
        {
            spot = spot.goalentity;
            pick_random = pick_random - 1;
        }
        return spot;
    }

    if (serverflags)
    {
        spot = find(world, classname, "info_player_start2");
        if (spot)
        {
            return spot;
        }
    }
    spot = find(world, classname, "info_player_start");
    if (!spot)
    {
        error("PutClientInServer: no info_player_start on level");
    }
    return spot;
};

void() PutClientInServer =
{
    local entity spot;
    self.classname = "player";

    if (skill == 3 && !deathmatch)
    {
        self.health = 50;
    }
    else
    {
        self.health = 100;
    }
    self.takedamage = DAMAGE_AIM;
    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_WALK;
    self.show_hostile = 0;
    if (skill == 3 && !deathmatch)
    {
        self.max_health = 50;
    }
    else
    {
        self.max_health = 100;
    }
    self.flags = FL_CLIENT;
    self.air_finished = time + 12;
    self.dmg = 2;
    self.super_damage_finished = 0;
    self.radsuit_finished = 0;
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.effects = 0;
    self.invincible_time = 0;
    self.healthrot_nextcheck = 0;
    self.fired_weapon = 0;
    self.took_damage = 0;
    self.team = 0;
    if (coop)
    {
        self.team = 1;
    }
    DecodeLevelParms();
    Loadout_DecodeParms(self);
    if (self.loadout_id_melee == WEAPON_ID_NONE && self.loadout_id_holdout == WEAPON_ID_NONE)
    {
        Loadout_SetDefaults(self);
    }
    self.weapon_first_draw_init = TRUE;
    W_SetCurrentAmmo();
    AM_InitRecoilSystem();
    self.attack_finished = time;
    self.th_pain = player_pain;
    self.th_die = PlayerDie;
    self.deadflag = DEAD_NO;
    self.pausetime = 0;
    local float shouldTelefrag;
    if (self.spawn_deferred > 0 && time >= self.spawn_deferred)
    {
        if (cvar("developer") > 0)
        {
            dprint("forcing telefrag on this spawn\n");
        }
        shouldTelefrag = TRUE;
    }
    else
    {
        shouldTelefrag = FALSE;
    }
    spot = SelectSpawnPoint(shouldTelefrag);
    if (spot == world)
    {
        self.takedamage = DAMAGE_NO;
        self.solid = SOLID_NOT;
        self.movetype = MOVETYPE_NONE;
        self.deadflag = DEAD_DEAD;
        setmodel(self, "");
        self.view_ofs = '0 0 1';
        self.velocity = '0 0 0';
        if (self.spawn_deferred == 0)
        {
            if (cvar("developer") > 0)
            {
                dprint("no spawns available! deferring\n");
            }
            self.spawn_deferred = time + 1;
        }
        spot = FindIntermission();
        self.angles = self.v_angle = spot.mangle;
        self.fixangle = TRUE;
        setorigin(self, spot.origin);
        self.weaponmodel = "";
        self.weaponframe = 0;
        self.weapon = 0;
        return;
    }
    self.spawn_deferred = 0;
    setorigin(self, spot.origin + '0 0 1');
    self.angles = spot.angles;
    self.fixangle = TRUE;
    setmodel(self, "progs/eyes.mdl");
    modelindex_eyes = self.modelindex;
    setmodel(self, "progs/player.mdl");
    modelindex_player = self.modelindex;
    setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.view_ofs = '0 0 22';
    self.velocity = '0 0 0';
    player_stand1();
    if (deathmatch || coop)
    {
        makevectorsfixed(self.angles);
        spawn_tfog (self.origin + v_forward * 20);
    }
    spawn_tdeath (self.origin, self);
    stuffcmd(self, "-attack\n");
};

/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) */
void() info_player_start = { };
/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24) */
void() info_player_start2 = { };
/*QUAKED testplayerstart (0 0.5 0.5) (-16 -16 -24) (16 16 24) For regioned levels */
void() testplayerstart = { };
/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24) */
void() info_player_deathmatch = { };
/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) */
void() info_player_coop = { };

void() NextLevel =
{
    local entity o;
    if (nextmap != string_null && nextmap != "")
    {
        return;
    }
    if (mapname == "start")
    {
        if (!cvar("registered"))
        {
            mapname = "e1m1";
        }
        else if (!(serverflags & 1))
        {
            mapname = "e1m1";
            serverflags = serverflags | 1;
        }
        else if (!(serverflags & 2))
        {
            mapname = "e2m1";
            serverflags = serverflags | 2;
        }
        else if (!(serverflags & 4))
        {
            mapname = "e3m1";
            serverflags = serverflags | 4;
        }
        else if (!(serverflags & 8))
        {
            mapname = "e4m1";
            serverflags = serverflags - 7;
        }
        o = spawn();
        o.map = mapname;
    }
    else
    {
        o = find(world, classname, "trigger_changelevel");
        if (!o || mapname == "start")
        {
            o = spawn();
            o.map = mapname;
        }
    }
    nextmap = o.map;
    gameover = TRUE;
    if (o.nextthink < time)
    {
        o.think = execute_changelevel;
        o.nextthink = time + 0.1;
    }
};

void() CheckRules =
{
    local float timelimit;
    local float fraglimit;

    if (gameover)
    {
        return;
    }
    timelimit = cvar("timelimit") * 60;
    fraglimit = cvar("fraglimit");

    if (timelimit > 0 && time >= timelimit)
    {
        NextLevel();
        return;
    }
    if (fraglimit > 0 && self.frags >= fraglimit)
    {
        NextLevel();
        return;
    }
};

void() PlayerDeathThink =
{
    local float forward;

    if ((self.flags & FL_ONGROUND))
    {
        forward = vlen(self.velocity);
        forward = forward - 20;
        if (forward <= 0)
        {
            self.velocity = '0 0 0';
        }
        else
        {
            self.velocity = forward * normalize(self.velocity);
        }
    }
    if (self.spawn_deferred != 0)
    {
        local entity spot;
        spot = SelectSpawnPoint(FALSE);
        if (spot != world || time >= self.spawn_deferred)
        {
            respawn();
        }
        return;
    }
    if (self.deadflag == DEAD_DEAD)
    {
        self.deadflag = DEAD_RESPAWNABLE;
        return;
    }
    if (self.deadflag == DEAD_RESPAWNABLE && (self.button0 || self.button1 || self.button2) )
    {
        respawn();
    }
};

void() PlayerJump =
{
    if (self.flags & FL_WATERJUMP)
    {
        return;
    }
    if (self.waterlevel >= 2)
    {
        if (self.watertype == CONTENT_WATER)
        {
            self.velocity_z = 100;
        }
        else if (self.watertype == CONTENT_SLIME)
        {
            self.velocity_z = 80;
        }
        else
        {
            self.velocity_z = 50;
        }
        if (self.swim_flag < time)
        {
            self.swim_flag = time + 1;
            if (random() < 0.5)
            {
                sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
            }
            else
            {
                sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
            }
        }
        return;
    }
    if (!(self.flags & FL_ONGROUND))
    {
        return;
    }
    if ( !(self.flags & FL_JUMPRELEASED) )
    {
        return; // hasn't released jump button since last jump
    }
    self.flags = self.flags - FL_JUMPRELEASED;
    self.flags = self.flags - FL_ONGROUND;    // take off ground
    sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
    self.velocity_z = self.velocity_z + 270;
}; 

void() WaterMove =
{
    if (self.movetype == MOVETYPE_NOCLIP)
    {
        return;
    }
    if (self.health < 0)
    {
        return;
    }
    if (self.waterlevel != 3)
    {
        if (self.air_finished < time)
        {
            sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
        }
        else if (self.air_finished < time + 9)
        {
            sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
        }
        self.air_finished = time + 12;
        self.dmg = 2;
    }
    else if (self.air_finished < time)
    {   // drown
        if (self.pain_finished < time)
        {
            self.dmg = self.dmg + 2;
            if (self.dmg > 15)
            {
                self.dmg = 15;
            }
            T_Damage (self, world, world, self.dmg);
            self.pain_finished = time + 1;
        }
    }
    if (self.waterlevel == 0)
    {
        if (self.flags & FL_INWATER)
        {
            sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
            self.flags = self.flags - FL_INWATER;
        }
        return;
    }
    if (self.watertype == CONTENT_LAVA)     // do damage
    {
        if (self.dmgtime < time)
        {
            if (self.radsuit_finished > time)
            {
                self.dmgtime = time + 1;
            }
            else
            {
                self.dmgtime = time + 0.2;
            }
            T_Damage (self, world, world, 10 * self.waterlevel);
        }
    }
    else if (self.watertype == CONTENT_SLIME)       // do damage
    {
        if (self.dmgtime < time && self.radsuit_finished < time)
        {
            self.dmgtime = time + 1;
            T_Damage (self, world, world, 4 * self.waterlevel);
        }
    }
    if ( !(self.flags & FL_INWATER) )
    {
        if (self.watertype == CONTENT_LAVA)
        {
            sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
        }
        if (self.watertype == CONTENT_WATER)
        {
            sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
        }
        if (self.watertype == CONTENT_SLIME)
        {
            sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
        }
        self.flags = self.flags | FL_INWATER;
        self.dmgtime = 0;
    }
    if (! (self.flags & FL_WATERJUMP) )
    {
        self.velocity = self.velocity * (1 - (0.8 * self.waterlevel * frametime));
    }
}; 

const void() CheckWaterJump = // ##Quedra: Changed to const to match compiler error expectation
{ 
    local vector start, end;

    makevectorsfixed(self.angles); // Use the pitch from self.angles
    start = self.origin;
    start_z = start_z + 8;      // So traceline doesn't hit ground if standing on bottom
    v_forward_z = 0;            // Watch out for loops
    normalize(v_forward);
    end = start + v_forward * 24;
    traceline (start, end, TRUE, self);
    if (trace_fraction < 1)     // Solid at water level
    { 
        start_z = start_z + self.maxs_z - 8;
        end = start + v_forward * 24;
        traceline (start, end, TRUE, self);
        if (trace_fraction == 1)    // Open above
        { 
            self.flags = self.flags | FL_WATERJUMP;
            self.velocity_z = 225;
            self.flags = self.flags - FL_JUMPRELEASED;  // Don't jump again until button is released
            self.teleport_time = time + 2;      // Allow to jumpফ্রout even if not moved for a bit
            return;
        } 
    } 
}; 