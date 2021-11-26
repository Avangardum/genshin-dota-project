modifier_overloaded_immunity = class({})

function modifier_overloaded_immunity:IsDebuff()
    return false
end

function modifier_overloaded_immunity:IsPurgable()
    return false
end

function modifier_overloaded_immunity:IsVisible()
    return false
end
