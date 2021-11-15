modifier_frozen = class({})

function modifier_frozen:IsPurgable()
    return false
end

function modifier_frozen:IsStunDefuff()
    return true
end

function modifier_frozen:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_frozen:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_frozen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_frozen:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

function modifier_frozen:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_frozen:GetEffectName()
	return "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf"
end

function modifier_frozen:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_frozen:GetTexture()
    return "frozen"
end
