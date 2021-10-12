modifier_anemo_effect = class({})

function modifier_anemo_effect:IsDebuff()
	return true;
end

function modifier_anemo_effect:IsHidden()
	return false;
end

function modifier_anemo_effect:IsPurgable()
	return true;
end

function modifier_anemo_effect:GetTexture()
    return "anemo"
end

function modifier_anemo_effect:GetEffectName()
	return "particles/genshin_elements/anemo.vpcf"
end

function modifier_anemo_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_anemo_effect:ShouldUseOverheadOffset()
	return true
end
