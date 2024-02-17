AddCSLuaFile()

SWEP.Category = "Kitbash"
SWEP.PrintedName = "APC Grenade"

SWEP.Author = "Octo"
SWEP.Purpose = "KILL"
SWEP.Instructions = "Primary fire: Throw APC"

SWEP.ViewModel = "models/kitbash/weapons/c_apc_grenade.mdl"
SWEP.Spawnable = true
SWEP.Slot = 4
SWEP.UseHands = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true
SWEP.HoldType = "grenade"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = "false"

local projectiles = {}

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 5)

    if SERVER then return end

    local spawnDist = 128
    local spawnRay = util.TraceHull({
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * spawnDist,
        mins = Vector(-125, -73, -48.5),
        maxs = Vector(118, 73, 50.5),
        filter = LocalPlayer(),
        output = true
    })
    local shootPos = spawnRay.HitPos
    local apc = ents.Create("prop_physics")
    apc:SetModel("models/combine_apc.mdl")
    apc:SetPos(shootPos)
    apc:setAngles(LocalPlayer():EyeAngles())
    apc:Spawn()
    local phys = apc:GetPhysicsObject()
    phys:SetVelocityInstantaneous(LocalPlayer():GetAimVector() * 1000)
    phys:SetMaterial("metalvehicle")

    apc.FireTime = CurTime()
    apc.NotMoving = math.huge
    table.insert(projectiles, apc)
end

function SWEP:SecondaryAttack()
end

if SERVER then
    hook.Add("Tick", "kb_apc_grenade_despawn_handler", function()
        for i = #projectiles, 1, -1 do
            local apc = projectiles[i]
            if not IsValid(apc) then
                table.remove(projectiles, i)
                continue
            end
            local apcPhys = apc:GetPhysicsObject()

            if CurTime() - apc.FireTime > 15 or CurTime() - apc.NotMoving >= 5 then
                apc:Remove()
                table.remove(projectiles, i)
                continue
            end

            if apcPhys:IsAsleep() then
                apc.NotMoving = CurTime()
            else
                apc.NotMoving = math.huge
            end
        end
    end)
end