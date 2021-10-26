modifier_yanfei_done_deal_brilliance = class({})

function modifier_yanfei_done_deal_brilliance:IsDebuff()
	return false;
end

function modifier_yanfei_done_deal_brilliance:IsPurgable()
	return false;
end

function modifier_yanfei_done_deal_brilliance:OnCreated()
	if not IsServer() then return end
	
	local interval = self:GetAbility():GetSpecialValueFor("seal_grant_interval")
	self.sealOfApprovalDamageMultiplier = self:GetAbility():GetSpecialValueFor("seal_of_approval_damage_multiplier")
	
	self:StartIntervalThink(interval)
end

function modifier_yanfei_done_deal_brilliance:OnIntervalThink()
	if not IsServer() then return end

	local scarletSealsModifier = self:GetParent():FindModifierByName("modifier_yanfei_scarlet_seals")
	if scarletSealsModifier ~= nil then
		scarletSealsModifier:AddStack()
	end
end
