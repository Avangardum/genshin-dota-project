require("abilities/element_test_unit_pyro_damage")

LinkLuaModifier("modifier_pyro_effect", "modifiers/modifier_pyro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hydro_effect", "modifiers/modifier_hydro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cryo_effect", "modifiers/modifier_cryo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_electro_effect", "modifiers/modifier_electro_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anemo_effect", "modifiers/modifier_anemo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_geo_effect", "modifiers/modifier_geo_effect.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frozen", "modifiers/modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frozen_immunity", "modifiers/modifier_frozen_immunity", LUA_MODIFIER_MOTION_NONE)

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

GenshinElements.VAPORIZE_PYRO_DAMAGE_MULTIPLIER = 1.5
GenshinElements.VAPORIZE_HYDRO_DAMAGE_MULTIPLIER = 2
GenshinElements.MELT_PYRO_DAMAGE_MULTIPLIER = 2
GenshinElements.MELT_CRYO_DAMAGE_MULTIPLIER = 1.5
GenshinElements.FROZEN_IMMUNITY_MULTIPLIER = 2 -- frozen immunity duration = frozen duration * GenshinElements.FROZEN_IMMUNITY_MULTIPLIER
GenshinElements.OVERLOAD_DAMAGE_FUNCTION = function(x) return 0.3 * x * x + 34 end


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
        damageMuliplier = self:TriggerVaporize(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.PYRO, self.CRYO}) then
        damageMuliplier = self:TriggerMelt(args)
    end
    if self:UnitHasElementalModifiers(args.target, {self.CRYO, self.HYDRO}) then
        self:TriggerFrozen(args)
    end

    return damageMuliplier
end

-- Private method. Do not call from the outside of the GenshinElements library! Accepts the same arguments as ApplyElements.
function GenshinElements:TriggerVaporize(args)
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

-- Private method. Do not call from the outside of the GenshinElements library! Accepts the same arguments as ApplyElements.
function GenshinElements:TriggerMelt(args)
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

-- Private method. Do not call from the outside of the GenshinElements library! Accepts the same arguments as ApplyElements.
function GenshinElements:TriggerFrozen(args)
    assert(self:UnitHasElementalModifiers(args.target, { self.HYDRO, self.CRYO }), "frozen target doesn't have hydro and cryo modifiers before the reaction")
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

function GenshinElements:UnitHasElementalModifier(unit, element)
    return unit:FindModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element]) ~= nil
end

function GenshinElements:UnitHasElementalModifiers(unit, elements)
    for k, v in pairs(elements) do
        if not self:UnitHasElementalModifier(unit, v) then
            return false
        end
    end

    return true
end

function GenshinElements:RemoveElementalModifierFromUnit(unit, element)
    unit:RemoveModifierByName(self.ELEMENTAL_MODIFIER_NAMES[element])
end

function GenshinElements:RemoveElementalModifiersFromUnit(unit, elements)
    for k, v in pairs(elements) do
        self:RemoveElementalModifierFromUnit(unit, v)
    end
end

-- The main Genshin elements thinker. All other thinkers are called from here
function GenshinElements:GenshinElementsThinker()
    self:WaterWetThinker()
    self:UnfreezeThinker()

    return 0.1
end

-- Applies a hydro modifier on units in water
function GenshinElements:WaterWetThinker()
    from(FindAllUnits())
    :where(function(x) return x:GetOrigin().z == 0 end)
    :foreach(function(x) self:ApplyElement{ caster = x, target = x, element = self.HYDRO } end)
end

-- Removes a frozen effect from all units without cryo effect
function GenshinElements:UnfreezeThinker()
    from(FindAllUnits())
    :where(function(x) return not self:UnitHasElementalModifier(x, self.CRYO) end)
    :foreach(function(x) x:RemoveModifierByName("modifier_frozen") end)
end
