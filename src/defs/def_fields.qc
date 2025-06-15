// ======================================================================= //
//  ##File: /defs/def_fields.qc
//  ##Project Version: FQX Phoenix v0.5
//  ##File Description: Contains all entity field declarations for the FQX Project.
//  ##File Version: 1.0.0 (20250614.191309CDT)
//
//   v1.0.0 - Initial creation from defs.qc PART 2: ENTITY FIELDS. - ##FIREFQX
//
// =======================================================================

#ifndef DEF_FIELDS_QC_H_
#define DEF_FIELDS_QC_H_

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
.float      fqx_cheat_unlimited_ammo;
.float      fqx_cheat_quad_damage;

#endif // DEF_FIELDS_QC_H_

// ======================================================================= //
// Project: FQX Phoenix v0.5
// File: /defs/def_fields.qc - File Version: 1.0.0
// Last Coder: ##FIREFQX
// =======================================================================