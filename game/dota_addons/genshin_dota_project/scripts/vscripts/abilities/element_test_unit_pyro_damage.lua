require "abilities/element_test_unit_elemental_damage_base_functions"

element_test_unit_pyro_damage = class({})

LinkLuaModifier("modifier_pyro_effect", "modifiers/modifier_pyro_effect.lua", LUA_MODIFIER_MOTION_NONE)

function element_test_unit_pyro_damage:OnSpellStart()
    ElementTestUnitElementalDamageBaseFunctions.OnSpellStart(self, GenshinElements.PYRO)
end