modifier_reality_rift_talent_2 = modifier_reality_rift_talent_2 or class({})

function modifier_reality_rift_talent_2:IsHidden()
    return true
end

function modifier_reality_rift_talent_2:IsPurgable()
    return false
end

function modifier_reality_rift_talent_2:AllowIllusionDuplicate() 
	return false
end

function modifier_reality_rift_talent_2:RemoveOnDeath()
    return false
end

function modifier_reality_rift_talent_2:OnCreated()
	local parent = self:GetParent()
	local talent = self:GetAbility()
	local talent_value = talent:GetSpecialValueFor("value")
	parent.reality_rift_talent_2_value = talent_value
end

function modifier_reality_rift_talent_2:OnDestroy()
	local parent = self:GetParent()
	if parent.reality_rift_talent_2_value then
		parent.reality_rift_talent_2_value = nil
	end
end
