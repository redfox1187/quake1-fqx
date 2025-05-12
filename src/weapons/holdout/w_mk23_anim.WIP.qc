

void() MK23_ReloadNextFrame;
void() MK23_ReloadAnimation;
void() MK23_ReturnToIdle;

/*
================
MK23_FireAnimation
Plays the firing animation and schedules return to idle
================
*/
void() MK23_FireAnimation =
{
    // Set view model to firing animation
    self.weaponframe = 0;  // Start at first frame of fire sequence
    
    // Schedule return to idle after animation completes
    // At 20fps, 3 frames = 0.15 seconds
    self.think = MK23_ReturnToIdle;
    self.nextthink = time + 0.15;
};

/*
================
MK23_ReturnToIdle
Returns weapon to idle state after firing
================
*/
void() MK23_ReturnToIdle =
{
    // Return to idle frame
    self.weaponframe = 0;  // Assuming 0 is used for idle animation sequence
};

/*
================
MK23_ReloadAnimation
Plays the reload animation sequence with dynamic timing based on MK23_RELOAD_TIME
================
*/
void() MK23_ReloadAnimation =
{
    // Play the reload animation
    self.weaponframe = 3;  // Start at first frame of reload sequence
    
    // Store the frame time calculation for consistent timing
    // Total frames in reload animation = 10
    self.reload_frame_time = MK23_RELOAD_TIME / 10;
    
    // Schedule the first frame change and sound
    self.reload_next_frame = 1;  // Next frame index to show
    self.think = MK23_ReloadNextFrame;
    self.nextthink = time + self.reload_frame_time;
};

/*
================
MK23_ReloadNextFrame
Advances the reload animation to the next frame with proper timing
and plays appropriate sounds at key frames
================
*/
void() MK23_ReloadNextFrame =
{
    // Frame sequence mapping for reload: 4→9→11→13→15→21→19→17→11→6
    // These represent the actual model frame numbers to display
    local float frames[10] = {4, 9, 11, 13, 15, 21, 19, 17, 11, 6};
    
    // Advance to next frame in sequence
    self.weaponframe = frames[self.reload_next_frame];
    
    // Play sounds at specific frames
    if (self.reload_next_frame == 2)  // Frame 11 (magazine out)
    {
        sound(self, CHAN_AUTO, "weapons/usp-reload_magout.wav", 1, ATTN_NORM);
    }
    else if (self.reload_next_frame == 4)  // Frame 15 (magazine in)
    {
        sound(self, CHAN_AUTO, "weapons/usp-reload_magin.wav", 1, ATTN_NORM);
    }
    else if (self.reload_next_frame == 5)  // Frame 21 (slide release)
    {
        // Optional slide release sound if you have one
        // sound(self, CHAN_AUTO, "weapons/usp-slidecatch.wav", 1, ATTN_NORM);
    }
    
    // Increment the frame counter
    self.reload_next_frame = self.reload_next_frame + 1;
    
    // Check if we've finished the animation
    if (self.reload_next_frame >= 10)
    {
        // Animation complete, return to idle
        self.think = MK23_ReturnToIdle;
    }
    else
    {
        // Continue to next frame
        self.think = MK23_ReloadNextFrame;
    }
    
    // Schedule the next frame change
    self.nextthink = time + self.reload_frame_time;
};
