
//-----------------------------------------------------------------------------
// ##Quedra: CheckPowerups, PlayerPostThink, ClientConnect, ClientDisconnect, ClientObituary
//-----------------------------------------------------------------------------
void() CheckPowerups =
{
    if (self.health <= 0)
    {
        return;
    }

    if (self.invisible_finished > time)
    {
        if (self.invisible_sound < time)
        {
            sound(self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
            self.invisible_sound = time + ((random() * 3) + 1);
        }
        if ((self.invisible_finished < time + 3) && (self.invisible_finished > time))
        {
            if (self.invisible_time == 1)
            {
                sprint(self, PRINT_LOW, "$qc_ring_fade\n");
                stuffcmd(self, "bf\n");
                sound(self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
                self.invisible_time = time + 1;
            }
            if (self.invisible_time < time)
            {
                self.invisible_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        self.frame = 0;
        self.modelindex = modelindex_eyes;
    }
    else
    {
        if (self.items & IT_INVISIBILITY)
        {
            self.items = self.items - IT_INVISIBILITY;
        }
        self.invisible_finished = 0;
        self.invisible_time = 0;
        self.modelindex = modelindex_player;
    }

    if (self.invincible_finished > time)
    {
        if ((self.invincible_finished < time + 3) && (self.invincible_finished > time))
        {
            if (self.invincible_time == 1)
            {
                sprint(self, PRINT_LOW, "$qc_protection_fade\n");
                stuffcmd(self, "bf\n");
                sound(self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
                self.invincible_time = time + 1;
            }
            if (self.invincible_time < time)
            {
                self.invincible_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        self.effects = self.effects | EF_PENTALIGHT;
    }
    else
    {
        if (self.items & IT_INVULNERABILITY)
        {
            self.items = self.items - IT_INVULNERABILITY;
        }
        self.invincible_time = 0;
        self.invincible_finished = 0;
        if (self.effects & EF_PENTALIGHT)
        {
            self.effects = self.effects - EF_PENTALIGHT;
        }
    }

    if (self.super_damage_finished > time)
    {
        if ((self.super_damage_finished < time + 3) && (self.super_damage_finished > time))
        {
            if (self.super_time == 1)
            {
                sprint(self, PRINT_LOW, "$qc_quad_fade\n");
                stuffcmd(self, "bf\n");
                sound(self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
                self.super_time = time + 1;
            }
            if (self.super_time < time)
            {
                self.super_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
        self.effects = self.effects | EF_QUADLIGHT;
    }
    else
    {
        if (self.items & IT_QUAD)
        {
            self.items = self.items - IT_QUAD;
        }
        self.super_damage_finished = 0;
        self.super_time = 0;
        if (self.effects & EF_QUADLIGHT)
        {
            self.effects = self.effects - EF_QUADLIGHT;
        }
    }

    if (self.radsuit_finished > time)
    {
        self.air_finished = time + 12;
        if ((self.radsuit_finished < time + 3) && (self.radsuit_finished > time))
        {
            if (self.rad_time == 1)
            {
                sprint(self, PRINT_LOW, "$qc_biosuit_fade\n");
                stuffcmd(self, "bf\n");
                sound(self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
                self.rad_time = time + 1;
            }
            if (self.rad_time < time)
            {
                self.rad_time = time + 1;
                stuffcmd(self, "bf\n");
            }
        }
    }
    else
    {
        if (self.items & IT_SUIT)
        {
            self.items = self.items - IT_SUIT;
        }
        self.rad_time = 0;
        self.radsuit_finished = 0;
    }
}

void() CheckHealthRot =
{
    if (!(self.items & IT_SUPERHEALTH))
    {
        return;
    }
    if (self.healthrot_nextcheck > time)
    {
        return;
    }
    if (self.health > self.max_health)
    {
        self.health = self.health - 1;
        self.healthrot_nextcheck = time + 1;
        return;
    }
    self.items = self.items - (self.items & IT_SUPERHEALTH);
    self.healthrot_nextcheck = 0;
}

void() PlayerPostThink =
{
    if (self.view_ofs == '0 0 0') // Not fully spawned in
    {
        return;
    }
    if (self.deadflag)
    {
        return;
    }

    W_WeaponFrame();

    if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0)) // Landed
    {
        if (self.watertype == CONTENT_WATER)
        {
            sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
        }
        else if (self.jump_flag < -650)
        {
            T_Damage(self, world, world, 5);
            sound(self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
            if (self.health <= 0)
            {
                self.deathtype = "falling";
            }
        }
        else
        {
            sound(self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
        }
        self.jump_flag = 0;
    }

    if (!(self.flags & FL_ONGROUND)) // In air
    {
        self.jump_flag = self.velocity_z;
    }

    CheckPowerups();
    CheckHealthRot();
}

void() ClientConnect =
{
    bprint("$qc_entered ", self.netname, "\n");
    if (intermission_running)
    {
        ExitIntermission(); // Ends intermission immediately
    }
}

void() ClientDisconnect =
{
    if (gameover)
    {
        return;
    }

    bprint("$qc_left_game ", self.netname, " with ", ftos(self.frags), " frags.\n");
    sound(self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE); // Play sound to all
    if (self.effects & EF_QUADLIGHT)
    {
        self.effects = self.effects - EF_QUADLIGHT;
    }
    if (self.effects & EF_PENTALIGHT)
    {
        self.effects = self.effects - EF_PENTALIGHT;
    }
    set_suicide_frame();
}

void(entity targ, entity attacker) ClientObituary =
{
    local float rnum;
    local float attackerteam, targteam;

    attackerteam = attacker.team;
    targteam = targ.team;
    rnum = random();

    if (targ.classname == "player")
    {
        if (attacker.classname == "teledeath")
        {
            bprint("$qc_telefragged ", targ.netname, " by ", attacker.owner.netname, "\n");
            attacker.owner.frags = attacker.owner.frags + 1;
            return;
        }
        if (attacker.classname == "teledeath2")
        {
            bprint("$qc_satans_power ", targ.netname, "\n");
            targ.frags = targ.frags - 1;
            return;
        }
        if (attacker.classname == "player")
        {
            if (targ == attacker) // Player suicided
            {
                attacker.frags = attacker.frags - 1;
                if ((targ.weapon == IT_SLOT_AUX2) && (targ.waterlevel > 1)) // Lightening gun in water
                {
                    if (targ.watertype == CONTENT_SLIME)
                    {
                        bprint("$qc_discharge_slime ", targ.netname, "\n");
                    }
                    else if (targ.watertype == CONTENT_LAVA)
                    {
                        bprint("$qc_discharge_lava ", targ.netname, "\n");
                    }
                    else
                    {
                        bprint("$qc_discharge_water ", targ.netname, "\n");
                    }
                    return;
                }
                if (targ.weapon == IT_SLOT_UTILITY) // Grenade
                {
                    bprint("$qc_suicide_pin ", targ.netname, "\n");
                }
                else if (rnum > 0.5)
                {
                    bprint("$qc_suicide_bored ", targ.netname, "\n");
                }
                else
                {
                    bprint("$qc_suicide_loaded ", targ.netname, "\n");
                }
                return;
            }
            else if ((teamplay == 2) && (targteam == attackerteam) && (attackerteam != 0)) // Teamkill
            {
                if (rnum < 0.25)
                {
                    bprint("$qc_ff_teammate ", attacker.netname, "\n");
                }
                else if (rnum < 0.50)
                {
                    bprint("$qc_ff_glasses ", attacker.netname, "\n");
                }
                else if (rnum < 0.75)
                {
                    bprint("$qc_ff_otherteam ", attacker.netname, "\n");
                }
                else
                {
                    bprint("$qc_ff_friend ", attacker.netname, "\n");
                }
                attacker.frags = attacker.frags - 1;
                return;
            }
            else // Standard kill
            {
                attacker.frags = attacker.frags + 1;
                if (attacker.weapon == IT_SLOT_MELEE)
                {
                    bprint("$qc_death_ax ", targ.netname, " by ", attacker.netname, "\n");
                    return;
                }
                if (attacker.weapon == IT_SLOT_HOLDOUT)
                {
                    bprint("$qc_death_sg ", targ.netname, " by ", attacker.netname, "\n");
                    return;
                }
                if (attacker.weapon == IT_SLOT_SECONDARY)
                {
                    bprint("$qc_death_dbl ", targ.netname, " by ", attacker.netname, "\n");
                    return;
                }
                if (attacker.weapon == IT_SLOT_PRIMARY)
                {
                    bprint("$qc_death_nail ", targ.netname, " by ", attacker.netname, "\n");
                    return;
                }
                if (attacker.weapon == IT_SLOT_HEAVY)
                {
                    bprint("$qc_death_sng ", targ.netname, " by ", attacker.netname, "\n");
                    return;
                }
                if (attacker.weapon == IT_SLOT_UTILITY) // Grenade launcher
                {
                    if (targ.health < -40) // Gibbed
                    {
                        bprint("$qc_death_gl1 ", targ.netname, " by ", attacker.netname, "\n");
                    }
                    else
                    {
                        bprint("$qc_death_gl2 ", targ.netname, " by ", attacker.netname, "\n");
                    }
                    return;
                }
                if (attacker.weapon == IT_SLOT_AUX1) // Rocket launcher
                {
                    if ((attacker.super_damage_finished > time) && (targ.health < -40)) // Quad gib
                    {
                        rnum = random();
                        if (rnum < 0.3)
                        {
                            bprint("$qc_death_rl_quad1 ", targ.netname, " by ", attacker.netname, "\n");
                        }
                        else if (rnum < 0.6)
                        {
                            bprint("$qc_death_rl_quad2 ", targ.netname, " by ", attacker.netname, "\n");
                        }
                        else
                        {
                            bprint("$qc_death_rl1 ", targ.netname, " by ", attacker.netname, "\n");
                        }
                    }
                    else // Normal rocket kill
                    {
                        if (targ.health < -40) // Gibbed
                        {
                            bprint("$qc_death_rl2 ", targ.netname, " by ", attacker.netname, "\n");
                        }
                        else
                        {
                            bprint("$qc_death_rl3 ", targ.netname, " by ", attacker.netname, "\n");
                        }
                    }
                    return;
                }
                if (attacker.weapon == IT_SLOT_AUX2) // Lightning gun
                {
                    if (attacker.waterlevel > 1)
                    {
                        bprint("$qc_death_lg1 ", targ.netname, " by ", attacker.netname, "\n");
                        if (attacker.invincible_finished > time)
                        {
                            msg_entity = attacker;
                            WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
                            WriteString(MSG_ONE, "ACH_SURVIVE_DISCHARGE");
                        }
                    }
                    else
                    {
                        bprint("$qc_death_lg2 ", targ.netname, " by ", attacker.netname, "\n");
                    }
                    return;
                }
                // Default kill message if weapon not specifically handled
                bprint("$qc_killed_by ", targ.netname, " by ", attacker.netname, "\n");
                return;
            }
        }
        else // Attacker is not a player (monster, hazard, etc.)
        {
            targ.frags = targ.frags - 1;
            rnum = targ.watertype; // Using rnum to store watertype for environmental deaths

            if (rnum == CONTENT_WATER)
            {
                if (random() < 0.5)
                {
                    bprint("$qc_death_drown1 ", targ.netname, "\n");
                }
                else
                {
                    bprint("$qc_death_drown2 ", targ.netname, "\n");
                }
                return;
            }
            else if (rnum == CONTENT_SLIME)
            {
                if (random() < 0.5)
                {
                    bprint("$qc_death_slime1 ", targ.netname, "\n");
                }
                else
                {
                    bprint("$qc_death_slime2 ", targ.netname, "\n");
                }
                return;
            }
            else if (rnum == CONTENT_LAVA)
            {
                if (targ.health < -15) // Severely gibbed by lava
                {
                    bprint("$qc_death_lava1 ", targ.netname, "\n");
                    return;
                }
                if (random() < 0.5)
                {
                    bprint("$qc_death_lava2 ", targ.netname, "\n");
                }
                else
                {
                    bprint("$qc_death_lava3 ", targ.netname, "\n");
                }
                return;
            }

            if ((attacker.solid == SOLID_BSP) && (attacker != world)) // Crushed by a door/plat
            {
                bprint("$qc_death_squish ", targ.netname, "\n");
                return;
            }
            if ((attacker.killstring != string_null) && (attacker.killstring != "")) // Specific killstring from entity
            {
                bprint(attacker.killstring, " ", targ.netname, "\n");
                return;
            }
            if (targ.deathtype == "falling") // Fall damage death
            {
                targ.deathtype = string_null; // Clear for next death
                bprint("$qc_death_fall ", targ.netname, "\n");
                return;
            }
            // Generic "died" message
            bprint("$qc_death_died ", targ.netname, "\n");
        }
    }
};

//=============================================================================
// client.qc - FQX Mod - Client Logic, Player Lifecycle, and Input Handling - END
// ##FQXCUSTOM - ##Quedra: Version 2.3.1
//=============================================================================