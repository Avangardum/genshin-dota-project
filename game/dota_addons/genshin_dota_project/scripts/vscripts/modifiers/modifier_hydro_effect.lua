modifier_hydro_effect = class({})

function modifier_hydro_effect:IsDebuff()
	return true;
end

function modifier_hydro_effect:IsHidden()
	return false;
end

function modifier_hydro_effect:IsPurgable()
	return true;
end

function modifier_hydro_effect:GetTexture()
    return "hydro"
end

function modifier_hydro_effect:GetEffectName()
	return "particles/genshin_elements/hydro.vpcf"
end

function modifier_hydro_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_hydro_effect:ShouldUseOverheadOffset()
	return true
end

