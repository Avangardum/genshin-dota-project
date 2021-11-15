modifier_frozen_immunity = class({})

function modifier_frozen_immunity:IsPurgable()
    return false
end

function modifier_frozen_immunity:IsDebuff()
    return false
end

function modifier_frozen_immunity:GetTexture()
    return "frozen_immunity"
end
