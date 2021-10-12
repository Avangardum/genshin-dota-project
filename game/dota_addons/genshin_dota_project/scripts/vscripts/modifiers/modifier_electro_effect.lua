modifier_electro_effect = class({})

function modifier_electro_effect:IsDebuff()
	return true;
end

function modifier_electro_effect:IsHidden()
	return false;
end

function modifier_electro_effect:IsPurgable()
	return true;
end

function modifier_electro_effect:GetTexture()
    return "electro"
end

function modifier_electro_effect:GetEffectName()
	return "particles/genshin_elements/electro.vpcf"
end

function modifier_electro_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_electro_effect:ShouldUseOverheadOffset()
	return true
end
