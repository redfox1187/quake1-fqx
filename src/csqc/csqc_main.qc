// csqc_main.qc
// Main Client-Side QuakeC (CSQC) logic file.
// Handles initialization, per-frame updates for UI/HUD, and client-side input.

#include "csqc_defs.qc" // This now correctly includes fteextensions.qc

// --- Global Variables for CSQC State ---
float screen_width;         // Current screen width, updated by CSQC_UpdateView
float screen_height;        // Current screen height, updated by CSQC_UpdateView
float csqc_initialized = FALSE;
float loadout_menu_active = FALSE;
vector mouse_pos;                 // Stores current mouse cursor screen coordinates (x,y,0)

// --- Core CSQC Entry Point Functions ---

/*
====================
CSQC_Init
====================
*/
void CSQC_Init(float apilevel, string enginename, float engineversion) {
    dprint("##Quedra CSQC: CSQC_Init called.\n");
    dprint("    API Level: ", ftos(apilevel), ", Engine Version: ", ftos(engineversion), "\n");
    dprint("    Engine Name: ", enginename, "\n");

    // Example: precache_pic("gfx/ui/my_icon.png");
    csqc_initialized = TRUE; 
}

/*
====================
CSQC_Shutdown
====================
*/
void CSQC_Shutdown(void) {
    dprint("##Quedra CSQC: CSQC_Shutdown called.\n");
    csqc_initialized = FALSE;
}

/*
====================
Draw_LoadoutMenu (Placeholder)
====================
*/
void Draw_LoadoutMenu(void) {
    if (!loadout_menu_active) {
        return;
    }
    vector title_pos;
    title_pos_x = screen_width * 0.5;
    title_pos_y = 50;
    drawstring(title_pos, "Configure Your Loadout", '8 8 0', '1 1 1', 1.0, DRAWFLAG_NORMAL);

    string mouse_debug_text = strcat("Mouse: ", ftos(mouse_pos_x), ", ", ftos(mouse_pos_y));
    drawstring('10 10 0', mouse_debug_text, '8 8 0', '1 1 1', 1.0, DRAWFLAG_NORMAL);
}

/*
====================
Draw_HUD (Placeholder)
====================
*/
void Draw_HUD(void) {
    drawstring('10 10 0', "FQX CSQC HUD Active", '8 8 0', '0.7 1 0.7', 1.0, DRAWFLAG_NORMAL);
}

/*
====================
CSQC_UpdateView
====================
*/
void CSQC_UpdateView(float vwidth, float vheight, float notmenu) {
    if (!csqc_initialized) {
        return;
    }
    screen_width = vwidth;
    screen_height = vheight;
    clearscene(); 

    if (loadout_menu_active) {
        setproperty(VF_DRAWWORLD, FALSE);
        setproperty(VF_DRAWCROSSHAIR, FALSE);
        setproperty(VF_DRAWENGINESBAR, FALSE);
        Draw_LoadoutMenu();
    }
    else if (notmenu) {
        setproperty(VF_DRAWWORLD, TRUE);
        setproperty(VF_DRAWCROSSHAIR, TRUE);
        setproperty(VF_DRAWENGINESBAR, FALSE);
        renderscene();
        Draw_HUD();
    }
}

/*
====================
Handle_LoadoutMenu_Input (Placeholder)
====================
*/
float Handle_LoadoutMenu_Input(float event_type, float scan_code, float unicode_char, float device_id) {
    // (void)device_id; // Mark as unused
    // Example placeholder logic
    // if(event_type == IE_KEYDOWN && scan_code == K_ESCAPE) {
    //     loadout_menu_active = FALSE;
    //     setcursormode(FALSE, "");
    //     return TRUE;
    // }
    return FALSE; 
}

/*
====================
CSQC_InputEvent
====================
*/
float CSQC_InputEvent(float event_type, float scan_code, float unicode_char, float device_id) {
    if (!csqc_initialized) {
        return FALSE;
    }

    // (void)device_id; // Mark as unused

    if (event_type == IE_KEYDOWN) {
        if (scan_code == K_F1) { 
            loadout_menu_active = !loadout_menu_active; 
            if (loadout_menu_active) {
                setcursormode(TRUE, ""); 
                dprint("##Quedra CSQC: Loadout Menu ACTIVATED (Press F1 to close)\n");
            } else {
                setcursormode(FALSE, ""); 
                dprint("##Quedra CSQC: Loadout Menu DEACTIVATED\n");
            }
            return TRUE; 
        }
    }

    if (loadout_menu_active) {
        if (event_type == IE_MOUSEABS) {
            mouse_pos_x = scan_code;    
            mouse_pos_y = unicode_char; 
        }
        if (Handle_LoadoutMenu_Input(event_type, scan_code, unicode_char, device_id)) {
            return TRUE; 
        }
    }
    return FALSE;
}