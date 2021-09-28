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
GenshinElements.MIN_ELEMENT = 1
GenshinElements.MAX_ELEMENT = 7

GenshinElements.DEFAULT_ELEMENT_DURATIONS =
{
    [GenshinElements.PYRO] = 5,
    [GenshinElements.HYDRO] = 5,
    [GenshinElements.CRYO] = 5,
    [GenshinElements.ELECTRO] = 5,
    [GenshinElements.ANEMO] = 5,
    [GenshinElements.GEO] = 5
}

GenshinElements.ELEMENTAL_MODIFIER_NAMES =
{
    [GenshinElements.PYRO] = "modifier_pyro_effect",
    [GenshinElements.HYDRO] = "modifier_hydro_effect",
    [GenshinElements.CRYO] = "modifier_cryo_effect",
    [GenshinElements.ELECTRO] = "modifier_electro_effect",
    [GenshinElements.ANEMO] = "modifier_anemo_effect",
    [GenshinElements.GEO] = "modifier_geo_effect"
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
    args.target:AddNewModifier( args.caster, nil, self.ELEMENTAL_MODIFIER_NAMES[args.element], { duration = self.DEFAULT_ELEMENT_DURATIONS[args.element] } )

    local damageMuliplier = 1
    if(self:UnitHasElementalModifiers(target, self.PYRO, self.HYDRO)) then
        print("Vaporize triggered by element " .. args.element)
        self:RemoveElementalModifiersFromUnit(target, self.PYRO, self.HYDRO)
    end

    return damageMuliplier
end

function GenshinElements:UnitHasElementalModifier(unit, element)
    return unit:FindModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element]) ~= nil
end

function GenshinElements:UnitHasElementalModifiers(unit, ...)
    for k, v in pairs{...} do
        if not self:UnitHasElementalModifier(unit, v) then
            return false
        end
    end

    return true
end

function GenshinElements:RemoveElementalModifierFromUnit(unit, element)
    unit:RemoveModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element])
end

function GenshinElements:RemoveElementalModifiersFromUnit(unit, ...)
    for k, v in pairs{...} do
        self:RemoveElementalModifierFromUnit(v)
    end
end