/*
==============================================================================
RAHP - Republic Army Holdout Pistol

Fires rapid weak shots, or alternate fire to switch to
moderate speed but boosted damage shots that costs Cells.
v_rahpm1.mdl
==============================================================================
*/

void() w_rahpm1_SetCurrentAmmo;// This will likely need to be called from a selection based on IT_SLOT_HOLDOUT weapon choice for weapon framework. WIP for now


void() w_rahpm1_SetCurrentAmmo =
	{
	
		self.weaponmodel = "progs/v_rahpm1.mdl";
		
		//Setting ammo visuals to match firemode
		if (self.weapon_mode_holdout == FIRE_MODE_PRIMARY) 
			{
			self.currentammo = 0;
			}
		else if (self.weapon_mode_holdout == FIRE_MODE_SECONDARY) 
			{
			self.currentammo = self.ammo_cells;
			self.items = self.items | IT_CELLS;
			}
	}


void() W_FireRahp =
{
    if (self.ammo_cells < 1 && self.weapon_mode_holdout == FIRE_MODE_SECONDARY)
    {
        self.weapon_mode_holdout = 0;
        W_SetCurrentAmmo();
    }

    // Primary fire mode (small laser)
    if (self.weapon_mode_holdout == FIRE_MODE_PRIMARY) 
    {
        self.attack_finished = time + 0.2;
        W_am_fire_laser(LASER_SMALL, 0, 1);  // Small laser, no muzzle flash, play sound
    }
    // Secondary fire mode (big laser)
    else if (self.weapon_mode_holdout == FIRE_MODE_SECONDARY)
    {
        self.attack_finished = time + 0.6;
        self.currentammo = self.ammo_cells = self.ammo_cells - 1;
        W_am_fire_laser(LASER_BIG, 0, 1);  // Big laser, no muzzle flash, play sound
    }
}
