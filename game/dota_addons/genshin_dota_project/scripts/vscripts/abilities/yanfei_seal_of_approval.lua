yanfei_seal_of_approval = class({})

function yanfei_seal_of_approval:GetSealsAmount()
    return self:GetCaster():GetModifierStackCount("modifier_yanfei_scarlet_seals", self:GetCaster())
end

function yanfei_seal_of_approval:GetAOERadius()
    local base = self:GetSpecialValueFor("base_aoe")
    local perSeal = self:GetSpecialValueFor("aoe_per_seal")
    return base + self:GetSealsAmount() * perSeal
end

function yanfei_seal_of_approval:GetCooldown(level)
    local baseCd = self.BaseClass.GetCooldown(self, level)
    local cdReduction = self:GetSpecialValueFor("cd_reduction_per_seal") * self:GetSealsAmount()
    return baseCd * (1 - cdReduction)
end

function yanfei_seal_of_approval:GetManaCost(level)
    local baseMc = self.BaseClass.GetManaCost(self, level)
    local mcReduction = self:GetSpecialValueFor("mana_cost_reduction_per_seal") * self:GetSealsAmount()
    return baseMc * (1 - mcReduction)
end

function yanfei_seal_of_approval:OnSpellStart()
    local radius = self:GetAOERadius()
    local baseDamage = self:GetSpecialValueFor("base_damage")
    local damagePerSeal = self:GetSpecialValueFor("damage_per_seal")
    local scarletSealsModifier = self:GetCaster():FindModifierByName("modifier_yanfei_scarlet_seals")
    local sealsConsumed = 0
    if scarletSealsModifier ~= nil then
        sealsConsumed = scarletSealsModifier:RemoveStacks()
    end
    local damage = baseDamage + damagePerSeal * sealsConsumed

    local targets = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),                   -- team
        self:GetCursorPosition(),                           -- location
        nil,                                                -- cacheUnit
        radius,                                             -- radius
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
            damage      = damage,
            damage_type = self:GetAbilityDamageType(),
            ability     = self,
            element     = GenshinElements.PYRO
        }
    end

    local particleIndex = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7.vpcf", PATTACH_WORLDORIGIN, nil)
    local particleOffset = Vector(0, 0, 0)
    ParticleManager:SetParticleControl( particleIndex, 0, self:GetCursorPosition() + particleOffset)
	ParticleManager:SetParticleControl( particleIndex, 1, Vector(radius, 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)
end
