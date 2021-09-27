-- This is not an ability. This is a container for base functions for elemental damage abilities
ElementTestUnitElementalDamageBaseFunctions = {}

function ElementTestUnitElementalDamageBaseFunctions:OnSpellStart(element)
    local target = self:GetCursorTarget()
    local caster = self:GetCaster()

    if target ~= nil then
        local damageTable = 
        {
            victim = target,
            attacker = caster,
            damage = self:GetAbilityDamage(),
            damage_type = self:GetAbilityDamageType(),
            ability = self,
            element = element
        }
        GenshinElements:ApplyElementalDamage(damageTable)
    end
end