modifier_ayaka_senho = class({})
LinkLuaModifier("modifier_generic_slowed_lua", "modifiers/modifier_generic_slowed_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ayaka_senho_particle_effect", "modifiers/modifier_ayaka_senho_particle_effect", LUA_MODIFIER_MOTION_HORIZONTAL)

modifier_ayaka_senho._DISTANCE_TO_STOP = 100
modifier_ayaka_senho._DESTROY_TREES_RADIUS = 100

function modifier_ayaka_senho:IsHidden()
	return false
end

function modifier_ayaka_senho:IsDebuff()
	return false
end

function modifier_ayaka_senho:IsStunDebuff()
	return false
end

function modifier_ayaka_senho:IsPurgable()
	return false
end

function modifier_ayaka_senho:OnCreated(kv)
    self._parent = self:GetParent()
	self._ability = self:GetAbility()
	self._team = self._parent:GetTeamNumber()

    self._maxDistance = self:GetAbility():GetSpecialValueFor("max_distance")
    self._speed = self:GetAbility():GetSpecialValueFor("speed")
    self._damage = self:GetAbility():GetSpecialValueFor("damage")
    self._movementSpeedReduction = self:GetAbility():GetSpecialValueFor("movement_speed_reduction")
    self._attackSpeedReduction = self:GetAbility():GetSpecialValueFor("attack_speed_reduction")
	self._slowDuration = self:GetAbility():GetSpecialValueFor("slow_duration")
	self._radius = self:GetAbility():GetSpecialValueFor("radius")
	
    if not IsServer() then return end

	self._abilityDamageType = self:GetAbility():GetAbilityDamageType()

	local origin = self._parent:GetOrigin()
    self._targetPoint = Vector(kv.x, kv.y, origin.z)
	
	-- if the target point is too far away, move it closer
	local vectorToTargetPoint = self._targetPoint - origin
	-- vectorToTargetPoint is horizontal (z = 0)
	assert(vectorToTargetPoint.z == 0)
	if vectorToTargetPoint:Length() > self._maxDistance then
		vectorToTargetPoint = vectorToTargetPoint:Normalized() * self._maxDistance
		self._targetPoint = origin + vectorToTargetPoint
	end

    self._damageTable = {
		attacker = self._parent,
		damage = self._damage,
		damage_type = self._abilityDamageType,
		ability = self._ability,
		element = GenshinElements.CRYO,
	}

	self._parent:AddNoDraw()

    if not self:ApplyHorizontalMotionController() then
		self:Destroy()
		return
	end

    self:PlayEffectsStart()
end

function modifier_ayaka_senho:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_ayaka_senho:OnDestroy()
    if not IsServer() then return end

	self._parent:RemoveNoDraw()
	self._parent:RemoveHorizontalMotionController(self)
    StopSoundOn("Hero_StormSpirit.BallLightning.Loop", self._parent)
	self._particleEffect:ForceKill(false)

	-- deal damage and apply slow
	local enemies = FindUnitsInRadius(
		self._team,	-- int, your team number
		self._parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self._radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,enemy in pairs(enemies) do
		-- damage
		self._damageTable.victim = enemy
		GenshinElements:ApplyElementalDamage(self._damageTable)
		print("ms slow = " .. self._movementSpeedReduction)
		print("as slow = " .. self._attackSpeedReduction)

		-- slow
		enemy:AddNewModifier(self._parent, self._ability, "modifier_generic_slowed_lua", 
			{
				as_slow    = self._attackSpeedReduction,
				ms_slow    = self._movementSpeedReduction,
				duration   = self._slowDuration,
				isPurgable = true,
			})
	end

	self:PlayEffectsEnd()
end

function modifier_ayaka_senho:UpdateHorizontalMotion(me, dt)
    local origin = me:GetOrigin()
	local direction = self._targetPoint - origin
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

    local target = origin + direction * self._speed * dt
	me:SetOrigin(target)

	GridNav:DestroyTreesAroundPoint( me:GetOrigin(), self._DESTROY_TREES_RADIUS, false )
	
    if distance < self._DISTANCE_TO_STOP then
		self:Destroy()
		return
	end
end

function modifier_ayaka_senho:OnHorizontalMotionInterrupted()
	self:Destroy()
end

function modifier_ayaka_senho:PlayEffectsStart()
	local soundCast = "Hero_StormSpirit.BallLightning"
	local soundLoop = "Hero_StormSpirit.BallLightning.Loop"

	-- create particle
	self._particleEffect = CreateModifierThinker(
		self._parent,
		self,
		"modifier_ayaka_senho_particle_effect",
		{ caster = self._parent },
		self._parent:GetOrigin(),
		self._parent:GetTeamNumber(),
		false
	)

	-- Create Sound
	EmitSoundOn(soundCast, self._parent)
	EmitSoundOn(soundLoop, self._parent)
end

function modifier_ayaka_senho:PlayEffectsEnd()
	local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particleIndex, 0, self._parent:GetOrigin())
	ParticleManager:SetParticleControl(particleIndex, 1, Vector(self._radius, 1, 1 ) )
    ParticleManager:ReleaseParticleIndex(particleIndex)

    EmitSoundOn("Hero_Crystal.CrystalNova", self:GetCaster())
end
