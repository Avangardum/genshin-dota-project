yanfei_done_deal = class({})
LinkLuaModifier("modifier_yanfei_done_deal_brilliance", "modifiers/modifier_yanfei_done_deal_brilliance", LUA_MODIFIER_MOTION_NONE)

function yanfei_done_deal:OnSpellStart()
    local targets = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),                   -- team
        self:GetCaster():GetOrigin(),                       -- location
        nil,                                                -- cacheUnit
        self:GetSpecialValueFor("aoe"),                     -- radius
        DOTA_UNIT_TARGET_TEAM_ENEMY,                        -- teamFilter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,     -- targetType
        DOTA_UNIT_TARGET_FLAG_NONE,                         -- flagFilter
        FIND_ANY_ORDER,                                     -- order
        false                                               -- canGrowCache
    )
    
    for _, target in pairs(targets) do
        GenshinElements:ApplyElementalDamage
        {
            victim      = target,
            attacker    = self:GetCaster(),
            damage      = self:GetSpecialValueFor("damage"),
            damage_type = self:GetAbilityDamageType(),
            ability     = self,
            element     = GenshinElements.PYRO
        }
    end

    local scarletSealsModifier = self:GetCaster():FindModifierByName("modifier_yanfei_scarlet_seals") 
    if scarletSealsModifier ~= nil then
        scarletSealsModifier:SetMaxStacks()
    end

    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_yanfei_done_deal_brilliance", { duration = self:GetSpecialValueFor("duration") })

    local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_WORLDORIGIN, nil)
    local particleRadiusMultiplier = 1.5
    ParticleManager:SetParticleControl( particleIndex, 0, self:GetCaster():GetOrigin())
	ParticleManager:SetParticleControl( particleIndex, 1, Vector(self:GetSpecialValueFor("aoe") * particleRadiusMultiplier, 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)
end
