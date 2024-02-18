AddCSLuaFile()
if SERVER then util.AddNetworkString("kb_apc_grenade_spawn") end

SWEP.Category = "Kitbash"
SWEP.PrintName = "APC Grenade"

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

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = "false"

local projectiles = {}

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetHoldType( self.HoldType )

    if SERVER then return end

    local rnd = math.random(0, 1)
    self:SetBodygroup(0, rnd)
    LocalPlayer():GetViewModel():SetBodygroup(0, rnd)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 5)

    if SERVER then return end

    net.Start("kb_apc_grenade_spawn")
        net.WriteEntity(LocalPlayer())
        net.WriteBool(LocalPlayer():GetViewModel():GetBodygroup(0) == 0)
    net.SendToServer()
end

function SWEP:SecondaryAttack()
end

if SERVER then
    net.Receive("kb_apc_grenade_spawn", function()
        local ply = net.ReadEntity()
        local bg = net.ReadBool()
        local pos = ply:EyePos()
        local ang = ply:EyeAngles()
        local dir = ply:GetAimVector()
        local weapon = ply:GetActiveWeapon()
        weapon.Owner:SetAnimation(PLAYER_ATTACK1)
	    weapon:SendWeaponAnim(ACT_VM_THROW)

        timer.Simple(11 / 24, function()
            weapon:SendWeaponAnim(ACT_VM_DRAW)
            local rnd = math.random(0, 1)
            weapon:SetBodygroup(0, rnd)
            ply:GetViewModel():SetBodygroup(0, rnd)
            bg = rnd
        end)

        local spawnDist = 128
        local spawnRay = util.TraceHull({
            start = pos,
            endpos = pos + dir * spawnDist,
            mins = Vector(-125, -73, -48.5) + Vector(0, 0, 66),
            maxs = Vector(118, 73, 50.5) + Vector(0, 0, 66),
            filter = ply,
            output = true
        })
        local shootPos = spawnRay.HitPos
        local apc = ents.Create("prop_physics")
        
        if bg == 0 or bg then
            apc:SetModel("models/combine_apc.mdl")
        else
            apc:SetModel("models/kitbash/props/apc001.mdl")
        end
        
        apc:SetPos(shootPos - Vector())
        apc:SetAngles(ang)
        apc:Spawn()
        apc:SetOwner(ply)
        local phys = apc:GetPhysicsObject()
        phys:SetVelocityInstantaneous(ply:GetVelocity() + dir * 1000)
        phys:SetMaterial("metalvehicle")

        apc.FireTime = CurTime()
        apc.NotMoving = math.huge
        table.insert(projectiles, apc)
    end)

    hook.Add("Tick", "kb_apc_grenade_despawn_handler", function()
        for i = #projectiles, 1, -1 do
            local apc = projectiles[i]
            if not IsValid(apc) then
                table.remove(projectiles, i)
                continue
            end
            local apcPhys = apc:GetPhysicsObject()

            if CurTime() - apc.FireTime > 10 or CurTime() - apc.NotMoving >= 5 then
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