modifier_ayaka_soumetsu = class({})

function modifier_ayaka_soumetsu:OnCreated(kv)
    if not IsServer() then return end

    AssertType(kv.projectileId, "projectileId", "number")
    AssertType(kv.interval, "interval", "number")
    AssertType(kv.intermediateBurstDamage, "intermediateBurstDamage", "number")
    AssertType(kv.intermediateBurstRadius, "intermediateBurstRadius", "number")

    self._projectileId = kv.projectileId
    self._intermediateBurstDamage = kv.intermediateBurstDamage
    self._intermediateBurstRadius = kv.intermediateBurstRadius
    self:StartIntervalThink(kv.interval)
end

function modifier_ayaka_soumetsu:OnIntervalThink()
    AssertType(self._projectileId, "_projectileId", "number")
    AssertType(self._intermediateBurstDamage, "_intermediateBurstDamage", "number")
    AssertType(self._intermediateBurstRadius, "_intermediateBurstRadius", "number")

    local projectileLocation = ProjectileManager:GetLinearProjectileLocation(self._projectileId)
    local targets = FindUnitsInRadius(
        self:GetAbility():GetCaster():GetTeamNumber(),      -- team
        projectileLocation,                                 -- location
        nil,                                                -- cacheUnit
        self._intermediateBurstRadius,                      -- radius
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
            attacker    = self:GetAbility():GetCaster(),
            damage      = self._intermediateBurstDamage,
            damage_type = self:GetAbility():GetAbilityDamageType(),
            ability     = self:GetAbility(),
            element     = GenshinElements.CRYO,
        }
    end
    
    self:PlayEffectsIntermediate(projectileLocation, self._intermediateBurstRadius)
end

function modifier_ayaka_soumetsu:PlayEffectsIntermediate(location, radius)
    AssertNumberInRange(radius, "radius", 0, math.huge)
    local particleId = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_ice.vpcf", 
        PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleId, 0, location)
    local point1Offset = Vector(1, 1, 0)
    ParticleManager:SetParticleControl(particleId, 1, location + point1Offset)
    ParticleManager:SetParticleControl(particleId, 2, Vector(radius, 1, 1))

    EmitSoundOnLocationWithCaster(location, "Hero_Crystal.CrystalNova", self:GetCaster())
end
