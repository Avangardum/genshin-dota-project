GenshinElements = {}

GenshinElements.PYRO = 1
GenshinElements.HYDRO = 2
GenshinElements.CRYO = 3
GenshinElements.ELECTRO = 4
GenshinElements.ANEMO = 5
GenshinElements.GEO = 6
GenshinElements.DENDRO = 7

function GenshinElements:ApplyElementalDamage(damageTable)
    if damageTable.element == nil then
        error("damageTable.element is nil")
    end
    print("Applying " .. damageTable.damage .. "damage of element " .. damageTable.element)
    local damageMuliplier = self:ApplyElement(damageTable.element)
    damageTable.damage = damageTable.damage * damageMuliplier
    ApplyDamage(damageTable)
end

-- returns damage multiplier if melt or vaporize reaction was trigerred, otherwise returns 1
function GenshinElements:ApplyElement(unit, element)
    
    return 1
end

print("genshin elements initialized")