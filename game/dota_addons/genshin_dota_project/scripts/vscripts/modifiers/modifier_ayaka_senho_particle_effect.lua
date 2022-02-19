modifier_ayaka_senho_particle_effect = class({})

modifier_ayaka_senho_particle_effect._TICK_INTERVAL = 0.1;
modifier_ayaka_senho_particle_effect._OFFSET = Vector(0, 0, 50)

function modifier_ayaka_senho_particle_effect:OnCreated(kv)
    if not IsServer() then return end

    local particleCast = "particles/units/heroes/hero_ancient_apparition/ancient_ice_vortex.vpcf"
    self._parent = self:GetParent()
    self._caster = self:GetCaster()
    
    local effectCast = ParticleManager:CreateParticle(particleCast, PATTACH_ABSORIGIN_FOLLOW, self._parent )
	ParticleManager:SetParticleControlEnt(
		effectCast,
		0,
		self._parent ,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self._parent:GetOrigin() + self._OFFSET, -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		effectCast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

    self:StartIntervalThink(self._TICK_INTERVAL)

    -- if not self:ApplyHorizontalMotionController() then
	-- 	self:Destroy()
    --     print(9999999)
	-- 	return
	-- end
end

function modifier_ayaka_senho_particle_effect:OnIntervalThink()
    self._parent:SetOrigin(self._caster:GetOrigin() + self._OFFSET)
end
