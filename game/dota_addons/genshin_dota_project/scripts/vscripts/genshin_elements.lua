require("abilities/element_test_unit_pyro_damage")

LinkLuaModifier("modifier_pyro_effect", "modifiers/modifier_pyro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hydro_effect", "modifiers/modifier_hydro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cryo_effect", "modifiers/modifier_cryo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_electro_effect", "modifiers/modifier_electro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anemo_effect", "modifiers/modifier_anemo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_geo_effect", "modifiers/modifier_geo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frozen", "modifiers/modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frozen_immunity", "modifiers/modifier_frozen_immunity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_superconduct", "modifiers/modifier_superconduct", LUA_MODIFIER_MOTION_NONE)

GenshinElements = {}

GenshinElements.PYRO = 1
GenshinElements.HYDRO = 2
GenshinElements.CRYO = 3
GenshinElements.ELECTRO = 4
GenshinElements.ANEMO = 5
GenshinElements.GEO = 6
GenshinElements.MIN_ELEMENT = 1
GenshinElements.MAX_ELEMENT = 6

GenshinElements.DEFAULT_ELEMENT_DURATIONS =
{
    [GenshinElements.PYRO] = 5,
    [GenshinElements.HYDRO] = 5,
    [GenshinElements.CRYO] = 5,
    [GenshinElements.ELECTRO] = 5,
    [GenshinElements.ANEMO] = 0,
    [GenshinElements.GEO] = 0
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

GenshinElements.ELEMENT_NAMES =
{
    [GenshinElements.PYRO] = "pyro",
    [GenshinElements.HYDRO] = "hydro",
    [GenshinElements.CRYO] = "cryo",
    [GenshinElements.ELECTRO] = "electro",
    [GenshinElements.ANEMO] = "anemo",
    [GenshinElements.GEO] = "geo"
}

GenshinElements.NIL_CASTER_LEVEL = 1
GenshinElements.VAPORIZE_PYRO_DAMAGE_MULTIPLIER = 1.5
GenshinElements.VAPORIZE_HYDRO_DAMAGE_MULTIPLIER = 2
GenshinElements.MELT_PYRO_DAMAGE_MULTIPLIER = 2
GenshinElements.MELT_CRYO_DAMAGE_MULTIPLIER = 1.5
GenshinElements.FROZEN_IMMUNITY_MULTIPLIER = 2 -- frozen immunity duration = frozen duration * GenshinElements.FROZEN_IMMUNITY_MULTIPLIER

GenshinElements.OVERLOADED_RADIUS = 500
GenshinElements.SUPERCONDUCT_ARMOR_REDUCTION = 10
GenshinElements.SUPERCONDUCT_RADIUS = 500
GenshinElements.SUPERCONDUCT_DURATION = 12

-- Accepts a damage table with all arguments required for ApplyDamage, plus it shoud contain an element
function GenshinElements:ApplyElementalDamage(damageTable)
    AssertType(damageTable, "damageTable", "table")
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

-- Accepts a table with following arguments: 
-- target  : CDOTA_BaseNPC
-- element : number
-- caster  : CDOTA_BaseNPC | nil
-- Returns damage multiplier if melt or vaporize reaction was trigerred, otherwise returns 1
function GenshinElements:ApplyElement(args)
    AssertType(args, "args", "table")
    AssertType(args.target, "target", "table")
    AssertType(args.element, "element", "number")
    assert(self.MIN_ELEMENT <= args.element and args.element <= self.MAX_ELEMENT, "element is out of range")
    AssertTypeOneOf(args.caster, "caster", { "table", "nil" })

    args.duration = args.duration or self.DEFAULT_ELEMENT_DURATIONS[args.element]
    args.target:AddNewModifier( args.caster, nil, self.ELEMENTAL_MODIFIER_NAMES[args.element], { duration = args.duration } )

    -- elemental reactions
    local damageMuliplier = 1
    if self:UnitHasElementalModifiers(args.target, {self.PYRO, self.HYDRO}) then
        damageMuliplier = self:_TriggerVaporize(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.PYRO, self.CRYO}) then
        damageMuliplier = self:_TriggerMelt(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.CRYO, self.HYDRO}) then
        self:_TriggerFrozen(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.PYRO, self.ELECTRO}) then
        self:_TriggerOverloaded(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.CRYO, self.ELECTRO}) then
        self:_TriggerSuperconduct(args)
    end

    return damageMuliplier
end

-- Accepts the same arguments as ApplyElements.
function GenshinElements:_TriggerVaporize(args)
    assert(self:UnitHasElementalModifier(args.target, self.HYDRO), "vaporize target doesn't have a hydro modifier before the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.PYRO), "vaporize target doesn't have a pyro modifier before the reaction")
    assert(IsServer(), "vaporize was triggered on a client")
    local damageMuliplier
    if args.element == self.PYRO then damageMuliplier = self.VAPORIZE_PYRO_DAMAGE_MULTIPLIER
    elseif args.element == self.HYDRO then damageMuliplier = self.VAPORIZE_HYDRO_DAMAGE_MULTIPLIER
    else error("vaporize trigerred by the " .. self.ELEMENT_NAMES[args.element] .. " element") end
    self:RemoveElementalModifiersFromUnit(args.target, {self.PYRO, self.HYDRO})
    local particleID = ParticleManager:CreateParticle("particles/genshin_elemental_reactions/vaporize.vpcf", PATTACH_OVERHEAD_FOLLOW, args.target)
    ParticleManager:ReleaseParticleIndex(particleID)
    assert(not self:UnitHasElementalModifier(args.target, self.HYDRO), "vaporize target has a hydro modifier after the reaction")
    assert(not self:UnitHasElementalModifier(args.target, self.PYRO), "vaporize target has a pyro modifier after the reaction")
    return damageMuliplier
end

-- Accepts the same arguments as ApplyElements.
function GenshinElements:_TriggerMelt(args)
    assert(self:UnitHasElementalModifier(args.target, self.CRYO), "melt target doesn't have a cryo modifier before the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.PYRO), "melt target doesn't have a pyro modifier before the reaction")
    assert(IsServer(), "melt was triggered on a client")
    if args.element == self.PYRO then damageMuliplier = self.MELT_PYRO_DAMAGE_MULTIPLIER
    elseif args.element == self.CRYO then damageMuliplier = self.MELT_CRYO_DAMAGE_MULTIPLIER
    else error("melt trigerred by the " .. self.ELEMENT_NAMES[args.element] .. " element") end
    self:RemoveElementalModifiersFromUnit(args.target, {self.PYRO, self.CRYO})
    local particleID = ParticleManager:CreateParticle("particles/genshin_elemental_reactions/melt.vpcf", PATTACH_OVERHEAD_FOLLOW, args.target)
    ParticleManager:ReleaseParticleIndex(particleID)
    assert(not self:UnitHasElementalModifier(args.target, self.CRYO), "melt target has a cryo modifier after the reaction")
    assert(not self:UnitHasElementalModifier(args.target, self.PYRO), "melt target has a pyro modifier after the reaction")
    return damageMuliplier
end

-- Accepts the same arguments as ApplyElements.
function GenshinElements:_TriggerFrozen(args)
    assert(self:UnitHasElementalModifier(args.target, self.HYDRO), "frozen target doesn't have a hydro modifier before the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.CRYO), "frozen target doesn't have a cryo modifier before the reaction")
    assert(IsServer(), "frozen was triggered on a client")
    local hydroModifier = args.target:FindModifierByName("modifier_hydro_effect")
    local cryoModifier = args.target:FindModifierByName("modifier_cryo_effect")
    self:RemoveElementalModifierFromUnit(args.target, self.HYDRO)
    local hasFrozenImmunity = args.target:FindModifierByName("modifier_frozen_immunity") ~= nil;
    if (hasFrozenImmunity) then return end
    local duration = math.min(hydroModifier:GetRemainingTime(), cryoModifier:GetRemainingTime());
    args.target:AddNewModifier( args.caster, nil, "modifier_frozen", { duration = duration } )
    args.target:AddNewModifier( args.caster, nil, "modifier_frozen_immunity", { duration = duration * self.FROZEN_IMMUNITY_MULTIPLIER } )
    local particleID = ParticleManager:CreateParticle("particles/genshin_elemental_reactions/frozen.vpcf", PATTACH_OVERHEAD_FOLLOW, args.target)
    ParticleManager:ReleaseParticleIndex(particleID)
    assert(not self:UnitHasElementalModifier(args.target, self.HYDRO), "frozen target still has the hydro effect after the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.CRYO), "frozen target doesn't have the cryo effect after the reaction")
    assert(args.target:FindModifierByName("modifier_frozen"), "frozen target doesn't have the frozen modifier after the reaction")
    assert(args.target:FindModifierByName("modifier_frozen_immunity"), "frozen target doesn't have the frozen immunity modifier after the reaction")
end

-- Accepts the same arguments as ApplyElements.
function GenshinElements:_TriggerOverloaded(args)
    assert(self:UnitHasElementalModifier(args.target, self.PYRO), "overloaded target doesn't have a pyro modifier before the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.ELECTRO), "overloaded target doesn't have an electro modifier before the reaction")
    assert(IsServer(), "elemental reaction was triggered on client")
    self:RemoveElementalModifiersFromUnit(args.target, { self.PYRO, self.ELECTRO })
    local affectedUnits = from(
        FindUnitsInRadius(
        args.target:GetTeamNumber(),                        -- team
        args.target:GetOrigin(),                            -- location
        nil,                                                -- cacheUnit
        self.OVERLOADED_RADIUS,                             -- radius
        DOTA_UNIT_TARGET_TEAM_BOTH,                         -- teamFilter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,     -- targetType
        DOTA_UNIT_TARGET_FLAG_NONE,                         -- flagFilter
        FIND_ANY_ORDER,                                     -- order
        false                                               -- canGrowCache
        )
    )
    :where(function(x) return args.caster == nil or x:GetTeamNumber() ~= args.caster:GetTeamNumber() end) -- exclude caster's allies
    :toArray()
    for _, unit in pairs(affectedUnits) do
        ApplyDamage
        {
            victim      = unit,
            attacker    = args.caster,
            damage      = self:_GetOverloadedDamage(self:_GetCasterLevel(args.caster)),
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
    end
    local particleID = ParticleManager:CreateParticle("particles/genshin_elemental_reactions/overloaded.vpcf", PATTACH_OVERHEAD_FOLLOW, args.target)
    ParticleManager:ReleaseParticleIndex(particleID)
    local explosionParticleId = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", 
    PATTACH_WORLDORIGIN, args.target)
    ParticleManager:SetParticleControl(explosionParticleId, 0, args.target:GetOrigin())
    ParticleManager:SetParticleControl(explosionParticleId, 1, Vector(self.OVERLOADED_RADIUS, 1, 1))
    ParticleManager:ReleaseParticleIndex(explosionParticleId)
    assert(not self:UnitHasElementalModifier(args.target, self.PYRO), "overloaded target still has a pyro effect after the reaction")
    assert(not self:UnitHasElementalModifier(args.target, self.ELECTRO), "overloaded target still has an electro effect after the reaction")
end

function GenshinElements:_TriggerSuperconduct(args)
    assert(self:UnitHasElementalModifier(args.target, self.ELECTRO), "superconduct target doesn't have an electro modifier before the reaction")
    assert(self:UnitHasElementalModifier(args.target, self.CRYO), "superconduct target doesn't have a cryo modifier before the reaction")
    self:RemoveElementalModifiersFromUnit(args.target, { self.ELECTRO, self.CRYO })
    local affectedUnits = from(
        FindUnitsInRadius(
        args.target:GetTeamNumber(),                        -- team
        args.target:GetOrigin(),                            -- location
        nil,                                                -- cacheUnit
        self.SUPERCONDUCT_RADIUS,                           -- radius
        DOTA_UNIT_TARGET_TEAM_BOTH,                         -- teamFilter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,     -- targetType
        DOTA_UNIT_TARGET_FLAG_NONE,                         -- flagFilter
        FIND_ANY_ORDER,                                     -- order
        false                                               -- canGrowCache
        )
    )
    :where(function(x) return args.caster == nil or x:GetTeamNumber() ~= args.caster:GetTeamNumber() end) -- exclude caster's allies
    :toArray()
    for _, unit in pairs(affectedUnits) do
        ApplyDamage
        {
            victim      = unit,
            attacker    = args.caster,
            damage      = self:_GetSuperconductDamage(self:_GetCasterLevel(args.caster)),
            damage_type = DAMAGE_TYPE_MAGICAL,
        }
        local superconductModifier = unit:AddNewModifier(args.caster, nil, "modifier_superconduct", 
            { duration = self.SUPERCONDUCT_DURATION, armorReduction = self.SUPERCONDUCT_ARMOR_REDUCTION })
    end
    local particleID = ParticleManager:CreateParticle("particles/genshin_elemental_reactions/superconduct.vpcf", PATTACH_OVERHEAD_FOLLOW, args.target)
    ParticleManager:ReleaseParticleIndex(particleID)
    local explosionParticleId = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", 
    PATTACH_WORLDORIGIN, args.target)
    ParticleManager:SetParticleControl(explosionParticleId, 0, args.target:GetOrigin())
    ParticleManager:SetParticleControl(explosionParticleId, 1, Vector(self.SUPERCONDUCT_RADIUS, 1, 1))
    ParticleManager:ReleaseParticleIndex(explosionParticleId)
    assert(args.target:FindModifierByName("modifier_superconduct") ~= nil, "superconduct target doesn't have a superconduct modifier after the reaction")
    assert(not self:UnitHasElementalModifier(args.target, self.ELECTRO), "superconduct target still has an electro effect after the reaction")
    assert(not self:UnitHasElementalModifier(args.target, self.CRYO), "superconduct target still has a cryo effect after the reaction")
end

-- Returns if the given unit has the modifier of the given element
function GenshinElements:UnitHasElementalModifier(unit, element)
    AssertType(unit, "unit", "table")
    AssertType(element, "element", "number")
    return unit:FindModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element]) ~= nil
end

-- Returns if the given unit has all the modifiers of the given elements
function GenshinElements:UnitHasElementalModifiers(unit, elements)
    AssertType(unit, "unit", "table")
    for _, element in pairs(elements) do assert(self:IsValidElement(element), element.." is not a valid element") end
    for k, v in pairs(elements) do
        if not self:UnitHasElementalModifier(unit, v) then
            return false
        end
    end

    return true
end

-- Removes the modifier of the given element from the given unit
function GenshinElements:RemoveElementalModifierFromUnit(unit, element)
    AssertType(unit, "unit", "table")
    AssertType(element, "element", "number")
    unit:RemoveModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element])
end

-- Removes all the modifiers of the given elements from the given unit
function GenshinElements:RemoveElementalModifiersFromUnit(unit, elements)
    AssertType(unit, "unit", "table")
    for _, element in pairs(elements) do assert(self:IsValidElement(element), element.." is not a valid element") end
    for k, v in pairs(elements) do
        self:RemoveElementalModifierFromUnit(unit, v)
    end
end

-- Removes all elemental modifiers from the given unit
function GenshinElements:RemoveAllElementalModifiersFromUnit(unit)
    AssertType(unit, "unit", "table")
    for i = self.MIN_ELEMENT, self.MAX_ELEMENT do
        self:RemoveElementalModifierFromUnit(unit, i)
    end
end

function GenshinElements:IsValidElement(element)
    return type(element) == "number" and self.MIN_ELEMENT <= element and element <= self.MAX_ELEMENT
end

-- The main Genshin elements thinker. All other thinkers are called from here
function GenshinElements:GenshinElementsThinker()
    self:_WaterWetThinker()
    self:_UnfreezeThinker()

    return 0.1
end

-- Applies a hydro modifier on units in water
function GenshinElements:_WaterWetThinker()
    from(FindAllUnits())
    :where(function(x) return x:GetOrigin().z == 0 end)
    :foreach(function(x) self:ApplyElement{ caster = x, target = x, element = self.HYDRO } end)
end

-- Removes a frozen effect from all units without cryo effect
function GenshinElements:_UnfreezeThinker()
    from(FindAllUnits())
    :where(function(x) return not self:UnitHasElementalModifier(x, self.CRYO) end)
    :foreach(function(x) x:RemoveModifierByName("modifier_frozen") end)
end

function GenshinElements:_GetCasterLevel(caster)
    AssertTypeOneOf(caster, "caster", { "table", "nil" })
    if (caster ~= nil) then
        return caster:GetLevel()
    else
        return self.NIL_CASTER_LEVEL
    end
end

function GenshinElements:_GetOverloadedDamage(casterLevel) return 0.3 * casterLevel * casterLevel + 34 end

function GenshinElements:_GetSuperconductDamage(casterLevel) return 0.2 * casterLevel * casterLevel + 20 end
