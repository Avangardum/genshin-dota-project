element_test_unit_elemental_damage = class({})

function element_test_unit_elemental_damage:OnSpellStart(element)
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