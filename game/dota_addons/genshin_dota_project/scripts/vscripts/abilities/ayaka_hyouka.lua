ayaka_hyouka = class({})
LinkLuaModifier("modifier_generic_arc_lua", "modifiers/modifier_generic_arc_lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_generic_stunned_lua", "modifiers/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE)

function ayaka_hyouka:OnSpellStart()
    local caster = self:GetCaster()

    local targets = FindUnitsInRadius(
        caster:GetTeamNumber(),                             -- team
        caster:GetOrigin(),                                 -- location
        nil,                                                -- cacheUnit
        self:GetSpecialValueFor("radius"),                  -- radius
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
            attacker    = caster,
            damage      = self:GetSpecialValueFor("damage"),
            damage_type = self:GetAbilityDamageType(),
            ability     = self,
            element     = GenshinElements.CRYO,
        }
        local duration = self:GetSpecialValueFor("duration")
        target:AddNewModifier(caster, self, "modifier_generic_arc_lua", 
        {
            duration = duration,
            height = self:GetSpecialValueFor("height"),
            isStun = true
        })
        target:AddNewModifier(caster, self, "modifier_generic_stunned_lua", { duration = duration })
    end

    self:PlayEffects()
end

function ayaka_hyouka:PlayEffects()
    local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl( particleIndex, 0, self:GetCaster():GetOrigin())
	ParticleManager:SetParticleControl( particleIndex, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)

    EmitSoundOn("Hero_Crystal.CrystalNova", self:GetCaster())
end
