/*
================
MK23_FireAnimation
Handles the firing animation sequence
================
*/
void() MK23_FireAnim_Frame4;
void() MK23_FireAnim_Frame3;

void() MK23_FireAnimation =
{
    self.frame = 2;
    self.nextthink = time + 0.05; // Adjust timing as needed
    self.think = MK23_FireAnim_Frame4;
};

void() MK23_FireAnim_Frame4 =
{
    self.frame = 4;
    self.nextthink = time + 0.05;
    self.think = MK23_FireAnim_Frame3;
};

void() MK23_FireAnim_Frame3 =
{
    self.frame = 3;
    self.nextthink = time + 0.05;
    self.think = SUB_Null; // Animation finished
};

/*
================
MK23_ReloadAnimation
Handles the reload animation sequence
================
*/
void() MK23_ReloadAnim_Frame9;
void() MK23_ReloadAnim_Frame11;
void() MK23_ReloadAnim_Frame13;
void() MK23_ReloadAnim_Frame15;
void() MK23_ReloadAnim_Frame21;
void() MK23_ReloadAnim_Frame19;
void() MK23_ReloadAnim_Frame17;
void() MK23_ReloadAnim_Frame11_2;
void() MK23_ReloadAnim_Frame6;

void() MK23_ReloadAnimation =
{
    self.frame = 4;
    self.nextthink = time + 0.1;  // Adjust timing as needed
    self.think = MK23_ReloadAnim_Frame9;
	//sound(self, CHAN_WEAPON, "weapons/usp-reload_magout.wav", 1, ATTN_NORM); // Play sound here
};

void() MK23_ReloadAnim_Frame9 =
{
    self.frame = 9;
    self.nextthink = time + 0.2;
    self.think = MK23_ReloadAnim_Frame11;
};

void() MK23_ReloadAnim_Frame11 =
{
    self.frame = 11;
    self.nextthink = time + 0.2;
    self.think = MK23_ReloadAnim_Frame13;
};

void() MK23_ReloadAnim_Frame13 =
{
    self.frame = 13;
    self.nextthink = time + 0.2;
    self.think = MK23_ReloadAnim_Frame15;
};

void() MK23_ReloadAnim_Frame15 =
{
    self.frame = 15;
    self.nextthink = time + 0.2;
    self.think = MK23_ReloadAnim_Frame21;
};

void() MK23_ReloadAnim_Frame21 =
{
    self.frame = 21;
    self.nextthink = time + 0.1;
    self.think = MK23_ReloadAnim_Frame19;
};

void() MK23_ReloadAnim_Frame19 =
{
    self.frame = 19;
    self.nextthink = time + 0.1;
    self.think = MK23_ReloadAnim_Frame17;
};

void() MK23_ReloadAnim_Frame17 =
{
    self.frame = 17;
    self.nextthink = time + 0.1;
    self.think = MK23_ReloadAnim_Frame11_2;
};

void() MK23_ReloadAnim_Frame11_2 =
{
    self.frame = 11;
    self.nextthink = time + 0.1;
    self.think = MK23_ReloadAnim_Frame6;
};

void() MK23_ReloadAnim_Frame6 =
{
    self.frame = 6;
    self.nextthink = time + 0.1;
    self.think = SUB_Null; // Animation finished
};