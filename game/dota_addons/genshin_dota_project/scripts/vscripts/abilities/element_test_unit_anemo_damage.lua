require "abilities/element_test_unit_elemental_damage_base_functions"

element_test_unit_anemo_damage = class({})

function element_test_unit_anemo_damage:OnSpellStart()
    ElementTestUnitElementalDamageBaseFunctions.OnSpellStart(self, GenshinElements.ANEMO)
end