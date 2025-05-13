/*
==============================================================================
870b - Remington 870 Shotgun

A shotgun, maybe THE shotgun.

v_870b.mdl
==============================================================================
*/

void() w_870b_SetCurrentAmmo;// This will likely need to be called from a selection based on IT_SLOT_HOLDOUT weapon choice for weapon framework. WIP for now
void() ralaser_small_touch;
void() ralaser_big_touch;

void() w_870b_SetCurrentAmmo =
	{
	
		self.weaponmodel = "progs/v_870b.mdl";
		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;

	}


void() W_Fire870b =
{
	local vector dir, muzzle_offset, muzzle_origin;
	local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up; // control projectile origin.

	if (self.ammo_cells < 2 && self.weapon_mode_secondary == FIRE_MODE_SECONDARY)
		{
		self.weapon_mode_secondary = 0;
		W_SetCurrentAmmo ();
		}

    if (self.weapon_mode_secondary == FIRE_MODE_PRIMARY) //Single Shot fire
    {
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.attack_finished = time + 0.7; //A little slower than the standard Quake shotgun, but the damage per shot will be higher
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 1000);
	
	// Define the approximate offset of your weapon's muzzle
	// These values are *estimates* and you'll need to adjust them based
	// on your specific weapon model's position.
	muzzle_offset_forward = 16;  // Adjust this value
	muzzle_offset_right = 0;    // Adjust this value
	muzzle_offset_up = 20;      // Adjust this value 

	makevectors(self.v_angle); // Get the player's view vectors (forward, right, up)

	// Calculate the muzzle's world origin
	muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
	muzzle_origin = self.origin + muzzle_offset;
	
	launch_am_buckshot (muzzle_origin, dir); //This setup likely needs heavy modification, this is more just an example of the naming conventions I'd like to use
	newmis.classname = "am_buckshot"; //more examples
	newmis.touch = am_buckshot_touch; //more examples

	self.punchangle_x = -2;
    }

    // Secondary mode - 2x shot, slower rate of fire
    else if (self.weapon_mode_secondary == FIRE_MODE_SECONDARY)
    {
	sound (self, CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.attack_finished = time + 1.4; //rate of fire should be twice as slow as the single shot mode
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 1000);
	
	// Define the approximate offset of your weapon's muzzle
	// These values are *estimates* and you'll need to adjust them based
	// on your specific weapon model's position.
	muzzle_offset_forward = 16;  // Adjust this value
	muzzle_offset_right = 0;    // Adjust this value
	muzzle_offset_up = 20;      // Adjust this value 

	makevectors(self.v_angle); // Get the player's view vectors (forward, right, up)

	// Calculate the muzzle's world origin
	muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
	muzzle_origin = self.origin + muzzle_offset;
	
	launch_am_buckshot (muzzle_origin, dir); //This setup likely needs heavy modification, this is more just an example of the naming conventions I'd like to use
	newmis.classname = "am_buckshot"; //more examples
	newmis.touch = am_buckshot_touch; //more examples


	self.punchangle_x = -4;
    }


};

