yanfei_signed_edict = class({})

function yanfei_signed_edict:GetAOERadius()
    return self:GetSpecialValueFor("aoe")
end

function yanfei_signed_edict:OnSpellStart()
    local targets = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),                   -- team
        self:GetCursorPosition(),                           -- location
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

    if TableLength(targets) > 0 then
        local scarletSealsModifier = self:GetCaster():FindModifierByName("modifier_yanfei_scarlet_seals") 
        if scarletSealsModifier ~= nil then
            scarletSealsModifier:SetMaxStacks()
        end
    end

    local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    local particleOffset = Vector(0, 0, 70)
    ParticleManager:SetParticleControl( particleIndex, 0, self:GetCursorPosition() + particleOffset)
	ParticleManager:SetParticleControl( particleIndex, 1, Vector(self:GetSpecialValueFor("aoe"), 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)

    self:PlayEffects(self:GetCursorPosition(), self:GetSpecialValueFor("aoe"))
end

function yanfei_signed_edict:PlayEffects(position, radius)
    local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    local particleOffset = Vector(0, 0, 70)
    local particleRadiusMultiplier = 1.6
    ParticleManager:SetParticleControl( particleIndex, 0, position + particleOffset)
	ParticleManager:SetParticleControl( particleIndex, 1, Vector(radius * particleRadiusMultiplier, 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)

    EmitSoundOnLocationWithCaster(position, "Hero_Jakiro.LiquidFire", self:GetCaster())
end
