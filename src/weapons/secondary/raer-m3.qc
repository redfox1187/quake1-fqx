/*
==============================================================================
RAER-M3 Republic Army Energy Rifle - Model 3

Fires rapid medium damage shots that cost Cells.
This is the compact configuration that has less consistent accuracy than the
carbine configuration.

==============================================================================
*/

raerm3

	else if (self.weapon == IT_SLOT_SECONDARY && self.w_secondary == 1) //Needs a string definition system.
	{
		player_nail1 (); //Use this player model anim
		W_FireRaerM3 (); //fire behavior
		self.attack_finished = time + 0.15; //Slightly faster than the nailguns
	}
	
/*
===============
launch_ralaser


===============
*/
void(vector org, vector dir) launch_ralaser =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = ralaser_touch;
	newmis.classname = "ralaser";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireRaerM3 =
{
	local vector	dir;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM); //replace sound
	//stuffcmd (self, "vibrate tactile/weapons/spike2.bnvib");
	self.attack_finished = time + 0.15;
	self.currentammo = self.ammo_cells = self.ammo_cells - 2;
	dir = aim (self, 1000);
	launch_ralaser (self.origin + '0 0 16', dir);
	newmis.classname = "ralaserbig";
	newmis.touch = ralaserbig_touch;
	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN); //maybe adjust scale for sexier laser		
	self.punchangle_x = -2;
};

void(float ox) W_FireRahp =
{
	local vector	dir;
	
	makevectors (self.v_angle);
	
	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM); //Switch to laser pew pew sound
	self.attack_finished = time + 0.2; //pistol needs semi check
	self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	dir = aim (self, 1000);
	launch_ralaser (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};

void() ralaser_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9); //match puny nails
		T_Damage (other, self, self.owner, 9);
	}

	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() ralaserbig_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (30);
		T_Damage (other, self, self.owner, 30); /More damage than nails 
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};
