/*
==============================================================================
MK23 SOCOM - .45 ACP Pistol Animation Sequences

Animation sequences for the SOCOM Mk23 Pistol v_model
- Firing sequence (standard and suppressed)
- Reload sequence

To be used with v_mk23.mdl
==============================================================================
*/

// Frame definitions for easier reference
$frame idle            // Frame 1 (assumed to be idle pose)
$frame fire1           // Frame 2 (first fire frame)
$frame fire2           // Frame 3 (recovery frame)
$frame slide_back      // Frame 4 (slide back position - used in both fire and reload)
$frame draw1           // Frame 5 (assumed to be first draw frame)
$frame holster         // Frame 6 (assumed to be holster frame)
$frame reload1         // Frame 9 (start reload)
$frame reload2         // Frame 11 (magazine out)
$frame reload3         // Frame 13 (new magazine approaching)
$frame reload4         // Frame 15 (new magazine inserted)
$frame reload5         // Frame 17 (hand leaving magazine)
$frame reload6         // Frame 19 (hand to slide)
$frame reload7         // Frame 21 (slide release)

/*
================
$modelname mk23
================
*/

/*
================
Fire Animation Sequence
Fire sequence: frame 2 -> 4 -> 3
================
*/
$sequence fire {
    fire1 slide_back fire2
    frames 3
    fps 20
}

/*
================
Reload Animation Sequence
Reload sequence: 4 -> 9 -> 11 -> 13 -> 15 -> 21 -> 19 -> 17 -> 11 -> 6

Note: The fps value here is a reference value only. The actual animation speed
will be controlled dynamically by the MK23_ReloadNextFrame function based on
the current MK23_RELOAD_TIME value.
================
*/
$sequence reload {
    slide_back reload1 reload2 reload3 reload4 reload7 reload6 reload5 reload2 holster
    frames 10
    fps 10      // Reference value only - actual timing controlled by code
}

/*
================
Draw Animation Sequence (inferred based on common practices)
================
*/
$sequence draw {
    draw1 idle
    frames 2
    fps 8
}

/*
================
Idle Animation Sequence
================
*/
$sequence idle {
    idle
    frames 1
    fps 10
}

/*
================
Holster Animation Sequence
================
*/
$sequence holster {
    holster
    frames 1
    fps 10
}
