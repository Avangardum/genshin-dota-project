require('my_util')
require('genshin_elements')

modifier_superconduct = class({})

function modifier_superconduct:DeclareFunctions()
    return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_superconduct:GetModifierPhysicalArmorBonus()
    return -GenshinElements.SUPERCONDUCT_ARMOR_REDUCTION;
end

function modifier_superconduct:GetTexture()
    return "superconduct"
end
