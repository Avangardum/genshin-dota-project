require "abilities/element_test_unit_elemental_damage_base_functions"

element_test_unit_electro_damage = class({})

function element_test_unit_electro_damage:OnSpellStart()
    ElementTestUnitElementalDamageBaseFunctions.OnSpellStart(self, GenshinElements.ELECTRO)
end