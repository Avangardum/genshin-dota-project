require('libraries/lualinq')

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
