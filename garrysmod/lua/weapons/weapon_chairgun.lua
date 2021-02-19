SWEP.PrintName = "Chair Thrower"
SWEP.Author = "shumadre"
SWEP.instructions = "vos dispará después fijate"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.ShootSound = Sound( "sounds/chairGun/tomaSilla" )

-- Called when the left mouse button is pressed
function SWEP:PrimaryAttack()
    -- This weapon is 'automatic'. This function call below defines
    -- the rate of fire. Here we set it to shoot every 0.5 seconds.
    self:SetNextPrimaryFire( CurTime() + 0.5 )

    -- Call 'ThrowChair' on self with this model
    self:ThrowChair( "models/props_c17/FurnitureChair001a.mdl" )
end


-- Called when the rightmouse button is pressed
function SWEP:SecondaryAttack()
    -- Though the secondary fire isn't automatic
    -- players shouldn't be able to fire too fast
    self:SetNextSecondaryFire( CurTime() + 0.1 )

    self:ThrowChair( "models/props_c17/FurnitureChair001a.mdl" )
end

-- A custom function we added. When you call this the player will fire a chair!
function SWEP:ThrowChair( model_file )
    local owner = self:GetOwner()

    -- Make sure the weapon is being held before trying to throw a chair
    if ( not owner:IsValid() ) then return end

    -- Play the shoot sound we precached earlier!
    self:EmitSound( self.ShootSound )

    -- If we're the client then this is as much as we want to do.
    -- We play the sound above on the client due to prediction.
    -- ( if we didn't they would feel a ping delay during multiplayer )
    if ( CLIENT ) then return end

    -- Create a prop_physics entity
    local ent = ents.Create( "prop_physics" )

    -- Always make sure that created entities are actually created!
    if ( not ent:IsValid() ) then return end

    -- Set the entity's model to the passed in model
    ent:SetModel( model_file )

    -- This is the same as owner:EyePos() + (self.Owner:GetAimVector() * 16)
    -- but the vector methods prevent duplicitous objects from being created
    -- which is faster and more memory efficient
    -- AimVector is not directly modified as it is used again later in the function
    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16 -- This creates a new vector object
    pos:Add( owner:EyePos() ) -- This translates the local aimvector to world coordinates

    -- Set the position to the player's eye position plus 16 units forward.
    ent:SetPos( pos )

    -- Set the angles to the player'e eye angles. Then spawn it.
    ent:SetAngles( owner:EyeAngles() )
    ent:Spawn()

    -- Now get the physics object. Whenever we get a physics object
    -- we need to test to make sure its valid before using it.
    -- If it isn't then we'll remove the entity.
    local phys = ent:GetPhysicsObject()
    if ( not phys:IsValid() ) then ent:Remove() return end

    -- Now we apply the force - so the chair actually throws instead
    -- of just falling to the ground. You can play with this value here
    -- to adjust how fast we throw it.
    -- Now that this is the last use of the aimvector vector we created,
    -- we can directly modify it instead of creating another copy
    aimvec:Mul( 500 )
    aimvec:Add( VectorRand( -10, 10 ) ) -- Add a random vector with elements [-10, 10)
    phys:ApplyForceCenter( aimvec )

    -- Assuming we're playing in Sandbox mode we want to add this
    -- entity to the cleanup and undo lists. This is done like so.
    cleanup.Add( owner, "props", ent )

    undo.Create( "Thrown_Chair" )
    undo.AddEntity( ent )
    undo.SetPlayer( owner )
    undo.Finish()
end