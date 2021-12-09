ayaka_soumetsu = class({})
LinkLuaModifier("modifier_ayaka_soumetsu", "modifiers/modifier_ayaka_soumetsu", LUA_MODIFIER_MOTION_NONE)

function ayaka_soumetsu:OnSpellStart()
    local direction = (self:GetCursorPosition() - self:GetCaster():GetOrigin()):Normalized()
    local projectileId = ProjectileManager:CreateLinearProjectile
    {
        EffectName = "particles/frostivus_gameplay/holdout_ancient_apparition_ice_blast_final.vpcf",
        Ability = self,
        Source = self:GetCaster(),
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        vVelocity = direction * self:GetSpecialValueFor("speed"),
        fDistance = math.huge,
        fStartRadius = 1,
        fEndRadius = 1,
        fExpireTime = GameRules:GetGameTime() + self:GetSpecialValueFor("duration"),
    }
    CreateModifierThinker(
        self:GetCaster(),
        self,
        "modifier_ayaka_soumetsu",
        { 
            duration = self:GetSpecialValueFor("duration"), 
            projectileId = projectileId, 
            interval = self:GetSpecialValueFor("interval"),
            intermediateBurstDamage = self:GetSpecialValueFor("intermediate_burst_damage"),
            intermediateBurstRadius = self:GetSpecialValueFor("intermediate_burst_radius")
        },
        self:GetCaster():GetOrigin(),
        self:GetCaster():GetTeamNumber(),
        false
    )
    self:PlayEffectsOnCast()
end

function ayaka_soumetsu:OnProjectileHit(target, location)
    local targets = FindUnitsInRadius(
        self:GetCaster():GetTeamNumber(),                   -- team
        location,                                           -- location
        nil,                                                -- cacheUnit
        self:GetSpecialValueFor("final_burst_radius"),      -- radius
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
            damage      = self:GetSpecialValueFor("final_burst_damage"),
            damage_type = self:GetAbilityDamageType(),
            ability     = self,
            element     = GenshinElements.CRYO,
        }
    end
    self:PlayEffectsOnFinalBurst(location)
end

function ayaka_soumetsu:PlayEffectsOnCast()
    EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Cast", self:GetCaster())
end

function ayaka_soumetsu:PlayEffectsOnFinalBurst(location)
    EmitSoundOnLocationWithCaster(location, "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())
end
