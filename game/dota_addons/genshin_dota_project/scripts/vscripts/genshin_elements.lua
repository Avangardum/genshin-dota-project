require("abilities/element_test_unit_pyro_damage")

LinkLuaModifier("modifier_pyro_effect", "modifiers/modifier_pyro_effect.lua", LUA_MODIFIER_MOTION_NONE)

GenshinElements = {}

GenshinElements.PYRO = 1
GenshinElements.HYDRO = 2
GenshinElements.CRYO = 3
GenshinElements.ELECTRO = 4
GenshinElements.ANEMO = 5
GenshinElements.GEO = 6
GenshinElements.DENDRO = 7

GenshinElements.DEFAULT_ELEMENT_DURATION = 5

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
        ability = damageTable.ability
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
    print("Applying element " .. args.element)
    print(args.duration)
    args.target:AddNewModifier( args.caster, args.ability, "modifier_pyro_effect", { duration = args.duration } )
    return 1
end