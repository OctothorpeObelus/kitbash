hook.Add("EntityTakeDamage", "kb_EntityTakeDamage", function(ent, dmg)
    local owner = dmg:GetInflictor():GetOwner()
    
    if not IsValid(owner) then return end

    local weapon = dmg:GetInflictor().WeaponUsed or owner:GetActiveWeapon()

    if IsValid(weapon) then dmg:SetInflictor(weapon) end

    dmg:SetAttacker(owner)
end)