require("abilities/element_test_unit_pyro_damage")

LinkLuaModifier("modifier_pyro_effect", "modifiers/modifier_pyro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hydro_effect", "modifiers/modifier_hydro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cryo_effect", "modifiers/modifier_cryo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_electro_effect", "modifiers/modifier_electro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anemo_effect", "modifiers/modifier_anemo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_geo_effect", "modifiers/modifier_geo_effect.lua", LUA_MODIFIER_MOTION_NONE)

GenshinElements = {}

GenshinElements.PYRO = 1
GenshinElements.HYDRO = 2
GenshinElements.CRYO = 3
GenshinElements.ELECTRO = 4
GenshinElements.ANEMO = 5
GenshinElements.GEO = 6
GenshinElements.DENDRO = 7

GenshinElements.DEFAULT_ELEMENT_DURATIONS =
{
    [GenshinElements.PYRO] = 5,
    [GenshinElements.HYDRO] = 5,
    [GenshinElements.CRYO] = 5,
    [GenshinElements.ELECTRO] = 5,
    [GenshinElements.ANEMO] = 5,
    [GenshinElements.GEO] = 5
}

function GenshinElements:ApplyElementalDamage(damageTable)
    if damageTable.element == nil then
        error("damageTable.element is nil")
    end
    print("Applying " .. damageTable.damage .. " damage of element " .. damageTable.element)
    local applyElementTable = 
    {
        caster = damageTable.attacker,
        target = damageTable.victim,
        element = damageTable.element,
    }
    local damageMuliplier = self:ApplyElement(applyElementTable)
    damageTable.damage = damageTable.damage * damageMuliplier
    ApplyDamage(damageTable)
end

-- returns damage multiplier if melt or vaporize reaction was trigerred, otherwise returns 1
function GenshinElements:ApplyElement(args)
    if args.caster == nil then error("caster is nil") end
    if args.target == nil then error("target is nil") end
    if args.element == nil then error("element is nil") end
    args.duration = args.duration or self.DEFAULT_ELEMENT_DURATION
    args.target:AddNewModifier( args.caster, nil, self:ElementToModifierName(args.element), { duration = self.DEFAULT_ELEMENT_DURATIONS[args.element] } )
    return 1
end

function GenshinElements:ElementToModifierName(element)
    if element == self.PYRO then return "modifier_pyro_effect"
    elseif element == self.HYDRO then return "modifier_hydro_effect"
    elseif element == self.CRYO then return "modifier_cryo_effect"
    elseif element == self.ELECTRO then return "modifier_electro_effect"
    elseif element == self.ANEMO then return "modifier_anemo_effect"
    elseif element == self.GEO then return "modifier_geo_effect" end
end
