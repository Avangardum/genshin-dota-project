require "abilities/element_test_unit_elemental_damage"

element_test_unit_pyro_damage = class({}, nil, element_test_unit_elemental_damage)

function element_test_unit_pyro_damage:OnSpellStart()
    element_test_unit_elemental_damage.OnSpellStart(self, GenshinElements.PYRO)
end