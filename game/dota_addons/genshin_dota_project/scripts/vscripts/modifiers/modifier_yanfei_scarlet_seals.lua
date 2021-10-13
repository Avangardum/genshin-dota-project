modifier_yanfei_scarlet_seals = class({})

function modifier_yanfei_scarlet_seals:IsHidden()
	return false
end

function modifier_yanfei_scarlet_seals:IsDebuff()
	return false
end

function modifier_yanfei_scarlet_seals:IsPurgable()
	return false
end

function modifier_yanfei_scarlet_seals:RemoveOnDeath()
	return false
end

function modifier_yanfei_scarlet_seals:DeclareFunctions()
	return
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_yanfei_scarlet_seals:GetModifierPreAttack_BonusDamage()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_stack")
end

function modifier_yanfei_scarlet_seals:OnDeath(args)
	if not IsServer() then return end
	if args.unit ~= self:GetParent() then return end
	
	self:RemoveStacks()
end

function modifier_yanfei_scarlet_seals:OnAttackLanded(args)
	if not IsServer() then return end
	if args.attacker ~= self:GetParent() then return end

	self:AddStack()
end

function modifier_yanfei_scarlet_seals:AddStack()
	if self:GetParent():PassivesDisabled() then return end
	if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("max_stacks") then return end

	self:IncrementStackCount()
end

-- Removes all stack and returns how many stacks were removed
function modifier_yanfei_scarlet_seals:RemoveStacks()
	local stacksRemoved = self:GetStackCount()
	self:SetStackCount(0)
	return stacksRemoved
end
