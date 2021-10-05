modifier_pyro_effect = class({})

function modifier_pyro_effect:GetTexture()
    return "pyro"
end

function modifier_pyro_effect:GetEffectName()
	return "particles/genshin_elements/pyro.vpcf"
end

function modifier_pyro_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_pyro_effect:ShouldUseOverheadOffset()
	return true
end
