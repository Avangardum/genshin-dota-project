modifier_cryo_effect = class({})

function modifier_cryo_effect:GetTexture()
    return "cryo"
end

function modifier_cryo_effect:GetEffectName()
	return "particles/genshin_elements/cryo.vpcf"
end

function modifier_cryo_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_cryo_effect:ShouldUseOverheadOffset()
	return true
end

