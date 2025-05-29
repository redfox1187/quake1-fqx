/*
==============================================================================
GRAPPLING HOOK

Improved implementation with impulse-only controls
==============================================================================
*/



void() w_grapple_SetCurrentAmmo;
void() anchor_touch;
void() anchor_think;
void() grapple_check_player;
void() grapple_release;



// Set up the grapple weapon
void() w_grapple_SetCurrentAmmo =
{
    self.weaponmodel = "progs/v_rock.mdl";  // Use existing grenade launcher model
    self.currentammo = self.ammo_rockets;
    self.items = self.items | IT_ROCKETS;
};

// Fire the grapple hook
void() W_FireGrapple =
{
    local vector dir, muzzle_offset, muzzle_origin;
    local float muzzle_offset_forward, muzzle_offset_right, muzzle_offset_up;
    
    // Don't fire if we already have a hook out
    if (self.grapple_state != GRAPPLE_NONE)
    {
        // If they fire again with a hook out, release it
        grapple_release();
        return;
    }
    
    // Check ammo
    if (self.ammo_rockets < 1)
    {
        self.weapon = W_BestWeapon();
        W_SetCurrentAmmo();
        return;
    }
    
    // Use ammo
    self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
    
    sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);  // Use standard grenade launcher sound
    
    // Set attack cooldown
    self.attack_finished = time + 0.8;
    
    // Aim handling
    dir = aim(self, 1000);
    
    // Define muzzle offset
    muzzle_offset_forward = 16;
    muzzle_offset_right = 0;
    muzzle_offset_up = 16;
    
    // Calculate muzzle origin
    makevectors(self.v_angle);
    muzzle_offset = v_forward * muzzle_offset_forward + v_right * muzzle_offset_right + v_up * muzzle_offset_up;
    muzzle_origin = self.origin + muzzle_offset;
    
    // Create the hook entity
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_BOUNCE;  // Like a grenade, it should bounce
    newmis.solid = SOLID_BBOX;
    newmis.classname = "grapple_anchor";
    
    // Set model and size
    setmodel(newmis, "progs/grapple_anchor.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, muzzle_origin);
    
    // Set velocity for lobbed trajectory like a grenade
    // We'll use a bit more velocity for better range
    newmis.velocity = dir * 800 + v_up * 200;
    newmis.avelocity = '300 300 300';  // Make it spin
    newmis.angles = vectoangles(newmis.velocity);
    
    // Set touch and think functions
    newmis.touch = anchor_touch;
    newmis.think = anchor_think;
    newmis.nextthink = time + 0.1;
    
    // Store the anchor reference
    self.anchor = newmis;
    self.grapple_state = GRAPPLE_FLYING;
    self.anchor_length = 9999;  // Will be set properly when attached
    self.grapple_action = GRAPPLE_ACTION_NONE;
    
    // Apply a small recoil
    self.punchangle_x = -2;
};

// Called when the anchor hits something
void() anchor_touch =
{
    // Don't interact with your owner
    if (other == self.owner)
        return;
    
    // Ignore trigger brushes
    if (other.solid == SOLID_TRIGGER)
        return;
    
    // If anchor hits sky, remove it
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        if (self.owner.anchor == self)
        {
            self.owner.anchor = world;
            self.owner.grapple_state = GRAPPLE_NONE;
        }
        remove(self);
        return;
    }
    
    // If anchor is already attached or has moved less than 20 units since last touch
    if (self.owner.grapple_state == GRAPPLE_ATTACHED)
        return;
    
    // If this is the second touch (after first bounce)
    if (self.attack_finished)
    {
        // Stop the anchor's movement
        self.velocity = '0 0 0';
        self.avelocity = '0 0 0';
        self.movetype = MOVETYPE_NONE;
        
        // Make the anchor attached
        self.owner.grapple_state = GRAPPLE_ATTACHED;
        
        // Calculate and store the initial anchor length
        self.owner.anchor_length = vlen(self.origin - self.owner.origin);
        
        // Play attach sound
        sound(self, CHAN_WEAPON, "weapons/tink1.wav", 1, ATTN_NORM);
        
        // If we hit something that takes damage, attach to it
        if (other.takedamage)
        {
            // Attach to the entity
            self.enemy = other;
            
            // If it's a monster or player, cause a bit of damage
            if (other.flags & (FL_MONSTER | FL_CLIENT))
            {
                T_Damage(other, self, self.owner, 10);
                spawn_touchblood(10);
            }
        }
    }
    else
    {
        // First bounce, set flag for next touch
        self.attack_finished = time + 0.2;
        // Play bounce sound
        sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    }
};

// Anchor's regular thinking
void() anchor_think =
{
    // If the owner is gone or dead, remove the anchor
    if (!self.owner || self.owner.health <= 0)
    {
        remove(self);
        return;
    }
    
    // If attached to an entity, follow it
    if (self.enemy && self.enemy.solid != SOLID_BSP)
    {
        setorigin(self, self.enemy.origin);
    }
    
    // Check if player is pressing jump
    grapple_check_player();
    
    // Handle continuous rope adjustment based on grapple_action
	//##WIP This needs to be modified so it can be easily used to retract/extract using commands bound to the mousewheel
    if (self.owner.grapple_state == GRAPPLE_ATTACHED)
    {
        if (self.owner.grapple_action == GRAPPLE_ACTION_EXTEND)
        {
            self.owner.anchor_length = self.owner.anchor_length + GRAPPLE_CONTINUOUS_SPEED;
        }
        else if (self.owner.grapple_action == GRAPPLE_ACTION_RETRACT)
        {
            self.owner.anchor_length = self.owner.anchor_length - GRAPPLE_CONTINUOUS_SPEED;
            if (self.owner.anchor_length < 0)
                self.owner.anchor_length = 0;
        }
    }
    
    // Draw a beam between player and anchor
	//##WIP I want to see if it's possible to have the rope wrap around world geometry, to give more of a realistic rope feel when using the grapple
    if (self.owner.grapple_state != GRAPPLE_NONE)
    {
        // Draw beam effect
        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_BEAM);
        WriteEntity(MSG_BROADCAST, self);
        WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
        WriteCoord(MSG_BROADCAST, self.owner.origin_x);
        WriteCoord(MSG_BROADCAST, self.owner.origin_y);
        WriteCoord(MSG_BROADCAST, self.owner.origin_z + 16);
    }
    
    self.nextthink = time + 0.1;
};

// New impulse handler for grapple commands
void() GrappleImpulseCommands =
{
    // Check if player used impulse 23 to start extending the rope
    if (self.impulse == 23)
    {
        if (self.grapple_state == GRAPPLE_ATTACHED)
        {
            if (self.grapple_action == GRAPPLE_ACTION_EXTEND)
            {
                // Player is already in extend mode, cancel it
                self.grapple_action = GRAPPLE_ACTION_NONE;
            }
            else
            {
                // Start extending mode
                self.grapple_action = GRAPPLE_ACTION_EXTEND;
                // Make initial adjustment
                self.anchor_length = self.anchor_length + GRAPPLE_CYCLE_SPEED;
            }
        }
        self.impulse = 0;
    }
    
    // Check if player used impulse 24 to start retracting the rope
    else if (self.impulse == 24)
    {
        if (self.grapple_state == GRAPPLE_ATTACHED)
        {
            if (self.grapple_action == GRAPPLE_ACTION_RETRACT)
            {
                // Player is already in retract mode, cancel it
                self.grapple_action = GRAPPLE_ACTION_NONE;
            }
            else
            {
                // Start retracting mode
                self.grapple_action = GRAPPLE_ACTION_RETRACT;
                // Make initial adjustment
                self.anchor_length = self.anchor_length - GRAPPLE_CYCLE_SPEED;
                if (self.anchor_length < 0)
                    self.anchor_length = 0;
            }
        }
        self.impulse = 0;
    }
    
    // Check if player used impulse 25 to toggle off any grapple action
    else if (self.impulse == 25)
    {
        self.grapple_action = GRAPPLE_ACTION_NONE;
        self.impulse = 0;
    }
};

// Repurposed Cycle Weapon for extending grapple (one-time adjustment)
void() CycleWeaponCommand =
{
    if (self.grapple_state == GRAPPLE_ATTACHED)
    {
        // Maintain backward compatibility with one-time adjustment
        self.anchor_length = self.anchor_length + GRAPPLE_CYCLE_SPEED;
        
        // Also toggle continuous extend mode
        if (self.grapple_action == GRAPPLE_ACTION_EXTEND)
        {
            // Already extending, so cancel it
            self.grapple_action = GRAPPLE_ACTION_NONE;
        }
        else
        {
            // Start extending
            self.grapple_action = GRAPPLE_ACTION_EXTEND;
        }
    }
};

// Repurposed Cycle Weapon Reverse for retracting grapple (one-time adjustment)
void() CycleWeaponReverseCommand =
{
    if (self.grapple_state == GRAPPLE_ATTACHED)
    {
        // Maintain backward compatibility with one-time adjustment
        self.anchor_length = self.anchor_length - GRAPPLE_CYCLE_SPEED;
        if (self.anchor_length < 0)
            self.anchor_length = 0;
        
        // Also toggle continuous retract mode
        if (self.grapple_action == GRAPPLE_ACTION_RETRACT)
        {
            // Already retracting, so cancel it
            self.grapple_action = GRAPPLE_ACTION_NONE;
        }
        else
        {
            // Start retracting
            self.grapple_action = GRAPPLE_ACTION_RETRACT;
        }
    }
};

// Check player actions for grapple control
void() grapple_check_player =
{
    local vector dir;
    local float current_length;

    // Only process if attached
    if (self.owner.grapple_state != GRAPPLE_ATTACHED)
        return;

    // Calculate current distance
    current_length = vlen(self.origin - self.owner.origin);

    // Improved double-jump detection
    if (self.owner.button2)  // If jump button is pressed
    {
        if (self.owner.flags & FL_JUMPRELEASED)  // Check if this is a new jump press
        {
            // Record the time of this jump press
            float current_time = time;
            
            // If this is the second jump within 0.4 seconds
            if ((current_time - self.owner.last_jump_time) < 0.4 && 
                self.owner.last_jump_time > 0)
            {
                // Double jump detected - release the grapple
                grapple_release();
                // Reset jump detection variables
                self.owner.last_jump_time = 0;
                return;
            }
            
            // Store the time of this jump press
            self.owner.last_jump_time = current_time;
            // Mark that the jump button has been pressed
            self.owner.flags = self.owner.flags - FL_JUMPRELEASED;
        }
    }
    else
    {
        // When jump button is released, set the flag to allow next jump detection
        self.owner.flags = self.owner.flags | FL_JUMPRELEASED;
    }

    // Enforce rope length constraint
    if (current_length > self.owner.anchor_length && self.owner.grapple_state == GRAPPLE_ATTACHED)
    {
        // Calculate pull direction
        dir = normalize(self.origin - self.owner.origin);

        // Pull player toward anchor to maintain rope length
        self.owner.velocity = self.owner.velocity + dir * (current_length - self.owner.anchor_length) * 5;
    }
};

// Release the grappling hook
void() grapple_release =
{
    // Only process if we have an anchor
    if (self.anchor)
    {
        sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
        
        // Reset grapple state
        self.grapple_state = GRAPPLE_NONE;
        self.grapple_action = GRAPPLE_ACTION_NONE;
        
        // Remove the anchor entity
        remove(self.anchor);
        self.anchor = world;
    }
};

// Check when player dies to remove anchor
void() GrappleCheckDeath =
{
    // This function should be called from the player's death function
    if (self.anchor)
    {
        remove(self.anchor);
        self.anchor = world;
        self.grapple_state = GRAPPLE_NONE;
        self.grapple_action = GRAPPLE_ACTION_NONE;
    }
};