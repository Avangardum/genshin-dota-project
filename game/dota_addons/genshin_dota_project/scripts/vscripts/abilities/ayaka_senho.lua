ayaka_senho = class({})
LinkLuaModifier("modifier_ayaka_senho", "modifiers/modifier_ayaka_senho", LUA_MODIFIER_MOTION_HORIZONTAL)

function ayaka_senho:Precache(context)
	  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context)
  	PrecacheResource("particle", "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", context)
end

function ayaka_senho:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    print("cast")
    if caster:HasModifier("modifier_ayaka_senho") then
        self:RefundManaCost()
        return
    end

    caster:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_ayaka_senho", -- modifier name
		{
			x = point.x,
			y = point.y,
		} -- kv
    )
end

function ayaka_senho:GetCastRange(location, target)
    -- If this function is called by a server, return a very big number to allow casting on any point
    -- If this function is called by a client, return the max distance to draw a circle
    if IsServer() then
        return 1000000 -- unlimited range
    else
        return self:GetSpecialValueFor("max_distance")
    end
end
