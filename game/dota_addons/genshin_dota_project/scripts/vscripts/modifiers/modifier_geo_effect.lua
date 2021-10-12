modifier_geo_effect = class({})

function modifier_geo_effect:IsDebuff()
	return true;
end

function modifier_geo_effect:IsHidden()
	return false;
end

function modifier_geo_effect:IsPurgable()
	return true;
end

function modifier_geo_effect:GetTexture()
    return "geo"
end

function modifier_geo_effect:GetEffectName()
	return "particles/genshin_elements/geo.vpcf"
end

function modifier_geo_effect:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_geo_effect:ShouldUseOverheadOffset()
	return true
end
