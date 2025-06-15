// ======================================================================= //
//  ##File: /defs/def_constants.qc
//  ##Project Version: FQX Phoenix v0.5
//  ##File Description: Contains all #define constants for the FQX Project.
//  ##File Version: 1.0.0 (20250614.190731CDT)
//
//   v1.0.0 - Initial creation from defs.qc PART 3: CONSTANTS. - ##FIREFQX
//
// =======================================================================

#ifndef DEF_CONSTANTS_QC_H_
#define DEF_CONSTANTS_QC_H_

#define FALSE                   0
#define TRUE                    1
#define FL_FLY                  1
#define FL_SWIM                 2
#define FL_CLIENT               8
#define FL_INWATER              16
#define FL_MONSTER              32
#define FL_GODMODE              64
#define FL_NOTARGET             128
#define FL_ITEM                 256
#define FL_ONGROUND             512
#define FL_PARTIALGROUND        1024
#define FL_WATERJUMP            2048
#define FL_JUMPRELEASED         4096
#define FL_ISBOT                8192
#define FL_NO_PLAYERS           16384
#define FL_NO_MONSTERS          32768
#define FL_NO_BOTS              65536
#define FL_OBJECTIVE            131072
#define MOVETYPE_NONE           0
#define MOVETYPE_WALK           3
#define MOVETYPE_STEP           4
#define MOVETYPE_FLY            5
#define MOVETYPE_TOSS           6
#define MOVETYPE_PUSH           7
#define MOVETYPE_NOCLIP         8
#define MOVETYPE_FLYMISSILE     9
#define MOVETYPE_BOUNCE         10
#define MOVETYPE_GIB            11
#define SOLID_NOT               0
#define SOLID_TRIGGER           1
#define SOLID_BBOX              2
#define SOLID_SLIDEBOX          3
#define SOLID_BSP               4
#define SOLID_CORPSE            5
#define RANGE_MELEE             0
#define RANGE_NEAR              1
#define RANGE_MID               2
#define RANGE_FAR               3
#define DEAD_NO                 0
#define DEAD_DYING              1
#define DEAD_DEAD               2
#define DEAD_RESPAWNABLE        3
#define DAMAGE_NO               0
#define DAMAGE_YES              1
#define DAMAGE_AIM              2
#define IT_AXE                  4096
#define IT_SHOTGUN              1
#define IT_SUPER_SHOTGUN        2
#define IT_NAILGUN              4
#define IT_SUPER_NAILGUN        8
#define IT_GRENADE_LAUNCHER     16
#define IT_ROCKET_LAUNCHER      32
#define IT_LIGHTNING            64
#define IT_EXTRA_WEAPON         128
#define IT_SHELLS               256
#define IT_NAILS                512
#define IT_ROCKETS              1024
#define IT_CELLS                2048
#define IT_ARMOR1               8192
#define IT_ARMOR2               16384
#define IT_ARMOR3               32768
#define IT_SUPERHEALTH          65536
#define IT_KEY1                 131072
#define IT_KEY2                 262144
#define IT_INVISIBILITY         524288
#define IT_INVULNERABILITY      1048576
#define IT_SUIT                 2097152
#define IT_QUAD                 4194304
#define CONTENT_EMPTY           -1
#define CONTENT_SOLID           -2
#define CONTENT_WATER           -3
#define CONTENT_SLIME           -4
#define CONTENT_LAVA            -5
#define CONTENT_SKY             -6
#define STATE_TOP               0
#define STATE_BOTTOM            1
#define STATE_UP                2
#define STATE_DOWN              3
#define VEC_ORIGIN              '0 0 0'
#define VEC_HULL_MIN            '-16 -16 -24'
#define VEC_HULL_MAX            '16 16 32'
#define VEC_HULL2_MIN           '-32 -32 -24'
#define VEC_HULL2_MAX           '32 32 64'
#define SVC_TEMPENTITY          23
#define SVC_KILLEDMONSTER       27
#define SVC_FOUNDSECRET         28
#define SVC_INTERMISSION        30
#define SVC_FINALE              31
#define SVC_CDTRACK             32
#define SVC_SELLSCREEN          33
#define SVC_SPAWNEDMONSTER      39
#define SVC_ACHIEVEMENT         52
#define SVC_CHAT                53
#define SVC_LEVELCOMPLETED      54
#define SVC_BACKTOLOBBY         55
#define SVC_LOCALSOUND          56
#define SVC_PROMPT              57
#define TE_SPIKE                0
#define TE_SUPERSPIKE           1
#define TE_GUNSHOT              2
#define TE_EXPLOSION            3
#define TE_TAREXPLOSION         4
#define TE_LIGHTNING1           5
#define TE_LIGHTNING2           6
#define TE_WIZSPIKE             7
#define TE_KNIGHTSPIKE          8
#define TE_LIGHTNING3           9
#define TE_LAVASPLASH           10
#define TE_TELEPORT             11
#define TE_EXPLOSION2           12
#define TE_BEAM                 13
#define CHAN_AUTO               0
#define CHAN_WEAPON             1
#define CHAN_VOICE              2
#define CHAN_ITEM               3
#define CHAN_BODY               4
#define ATTN_NONE               0
#define ATTN_NORM               1
#define ATTN_IDLE               2
#define ATTN_STATIC             3
#define EF_BRIGHTFIELD          1
#define EF_MUZZLEFLASH          2
#define EF_BRIGHTLIGHT          4
#define EF_DIMLIGHT             8
#define EF_QUADLIGHT            16
#define EF_PENTALIGHT           32
#define EF_CANDLELIGHT          64
#define MSG_BROADCAST           0
#define MSG_ONE                 1
#define MSG_ALL                 2
#define MSG_INIT                3
#define TEAM_NONE               -1
#define TEAM_MONSTERS           0
#define TEAM_HUMANS             1
#define PEF_CHANGEONLYNEW       1
#define PEF_CHANGENEVER         2
#define AS_STRAIGHT             1
#define AS_SLIDING              2
#define AS_MELEE                3
#define AS_MISSILE              4
#define CS_NONE                 0
#define CS_RANGED               1
#define CS_MELEE                2
#define CS_MIXED                3
#define WORLDTYPE_MEDIEVAL      0
#define WORLDTYPE_METAL         1
#define WORLDTYPE_BASE          2

#endif // DEF_CONSTANTS_QC_H_

// ======================================================================= //
// Project: FQX Phoenix v0.5
// File: /defs/def_constants.qc - File Version: 1.0.0
// Last Coder: ##FIREFQX
// =======================================================================