function DebugPrint(...)
	if USE_DEBUG then
		print(...)
	end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Requires an element and a table, returns true if element is in the table.
function TableContains(t, element)
    if t == nil then return false end
    for k,v in pairs(t) do
        if k == element then
            return true
        end
    end
    return false
end

-- Return length of the table even if the table is nil or empty
function TableLength(t)
    if t == nil or t == {} then
        return 0
    end
    local length = 0
    for k,v in pairs(t) do
        length = length + 1
    end
    return length
end

function GetRandomTableElement(t)
    -- iterate over whole table to get all keys
    local keyset = {}
    for k in pairs(t) do
        table.insert(keyset, k)
    end
    -- now you can reliably return a random key
    return t[keyset[RandomInt(1, #keyset)]]
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

-- Author: Noya
-- This function hides all dota item cosmetics (hats/wearables) from the hero/unit and store them into a handle variable
-- Works only for wearables added with code
function HideWearables(unit)
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
  local model = unit:FirstMoveChild()
  while model ~= nil do
    if model:GetClassname() == "dota_item_wearable" then
      model:AddEffects(EF_NODRAW) -- Set model hidden
      table.insert(unit.hiddenWearables, model)
    end
    model = model:NextMovePeer()
  end
end

-- Author: Noya
-- This function un-hides (shows) wearables that were hidden with HideWearables() function.
function ShowWearables(unit)
	for i,v in pairs(unit.hiddenWearables) do
		v:RemoveEffects(EF_NODRAW)
	end
end

-- Author: Noya
-- This function changes (swaps) dota item cosmetic models (hats/wearables)
-- Works only for wearables added with code
function SwapWearable(unit, target_model, new_model)
    local wearable = unit:FirstMoveChild()
    while wearable ~= nil do
        if wearable:GetClassname() == "dota_item_wearable" then
            if wearable:GetModelName() == target_model then
                wearable:SetModel(new_model)
                return
            end
        end
        wearable = wearable:NextMovePeer()
    end
end

-- This function checks if a given unit is Roshan, returns boolean value;
function CDOTA_BaseNPC:IsRoshan()
	if self:IsAncient() and self:GetUnitName() == "npc_dota_roshan" then
		return true
	end
	
	return false
end

-- This function checks if this entity is a fountain or not; returns boolean value;
function CBaseEntity:IsFountain()
	if self:GetName() == "ent_dota_fountain_bad" or self:GetName() == "ent_dota_fountain_good" then
		return true
	end
	
	return false
end

-- Author: Noya
-- This function is showing custom Error Messages using notifications library
function SendErrorMessage(pID, string)
  if Notifications then
    Notifications:ClearBottom(pID)
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
  end
  EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

-- My functions

function FindAllUnits()
    return FindUnitsInRadius(
		DOTA_TEAM_GOODGUYS, 
		Vector(0, 0, 0), 
		nil, 
		FIND_UNITS_EVERYWHERE, 
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
    )
end

function AssertType(object, objectName, requiredType)
    assert(type(requiredType) == "string", "requiredType is not a string")
    assert(type(objectName) == "string", "objectName is not a string")
    local objectType = type(object)
    AssertWithErrorLevel(objectType == requiredType, objectName.." is "..objectType..". Expected "..requiredType, 2)
end

function AssertTypeOneOf(object, objectName, requiredTypes)
    assert(type(requiredTypes) == "table", "requiredTypes is not a table")
    assert(#requiredTypes > 0, "requiredTypes is empty")
    from(requiredTypes):foreach(function(x) assert(type(x) == "string", "requiredTypes contains a member of type "..type(x)..". Expected strings only") end)
    assert(type(objectName) == "string", "objectName is not a string")
    local objectType = type(object)
    local message = objectName.." is "..objectType..". Expected one of types: ";
    from(requiredTypes):foreach(function(x) message = message..x.." " end)
    AssertWithErrorLevel(from(requiredTypes):contains(objectType), message, 2)
end

function AssertWithErrorLevel(condition, message, level)
    assert(type(message) == "string", "message is not string")
    assert(type(level) == "number", "level is not a number")
    if not condition then
        error(message, level)
    end
end

function AssertNumberInRange(number, numberName, min, max, message)
    AssertType("number", numberName, "number")
    local isNumberInRange = min <= number and number <= max
    AssertWithErrorLevel(isNumberInRange, numberName.." is out of range. Expected "..min.." - "..max..", received "..number, 2)
end

function AssertSingleTypeArray(array, arrayName, requiredType)
    AssertType(array, arrayName, "table")
    for k, v in pairs(array) do
        AssertWithErrorLevel(type(v) == requiredType, arrayName.." is not an array of "..requiredType, 2)
    end
end
