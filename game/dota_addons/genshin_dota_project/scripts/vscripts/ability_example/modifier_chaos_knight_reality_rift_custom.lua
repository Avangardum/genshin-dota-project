modifier_chaos_knight_reality_rift_custom = modifier_chaos_knight_reality_rift_custom or class({})

function modifier_chaos_knight_reality_rift_custom:IsHidden()
	return false
end

function modifier_chaos_knight_reality_rift_custom:IsPurgable()
	return true
end

function modifier_chaos_knight_reality_rift_custom:IsDebuff()
	return true
end

-- Modifiers exist both on server and client, so take care what methods you use
function modifier_chaos_knight_reality_rift_custom:OnCreated()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local armor_reduction = ability:GetSpecialValueFor("armor_reduction")
	
	-- Talent that increases armor reduction
	if caster:HasModifier("modifier_reality_rift_talent_2") then
		armor_reduction = armor_reduction - math.abs(caster.reality_rift_talent_2_value)
	end
	
	self.armor_reduction = armor_reduction
end

modifier_chaos_knight_reality_rift_custom.OnRefresh = modifier_chaos_knight_reality_rift_custom.OnCreated

function modifier_chaos_knight_reality_rift_custom:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}

	return funcs
end

function modifier_chaos_knight_reality_rift_custom:GetModifierPhysicalArmorBonus()
	return self.armor_reduction
end

function modifier_chaos_knight_reality_rift_custom:GetEffectName()
	-- Chaos Knight Reality Rift uses Medallion of Courage particle
	return "particles/units/heroes/hero_chaos_knight/chaos_knight_reality_rift_buff.vpcf"
end

function modifier_chaos_knight_reality_rift_custom:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_chaos_knight_reality_rift_custom:ShouldUseOverheadOffset()
	return true
end
