ayaka_kabuki = class{}

ayaka_kabuki._DUMMY_UNIT_OFFSET = 10

function ayaka_kabuki:OnSpellStart()
    local direction = (self:GetCursorPosition() - self:GetCaster():GetOrigin()):Normalized()
    local dummyUnitLocation = self:GetCaster():GetOrigin() + direction * self._DUMMY_UNIT_OFFSET
    local dummyUnit = CreateUnitByName(
        "npc_dota_custom_dummy_unit",
        dummyUnitLocation,
        false,
        nil,
        nil,
        DOTA_TEAM_NEUTRALS
    )
    local damage = self:GetCaster():GetAttackDamage() * self:GetSpecialValueFor("cleave_damage_multiplier")
    DoCleaveAttack(
        self:GetCaster(),
        dummyUnit,
        self,
        damage,
        self:GetSpecialValueFor("cleave_start_radius"),
        self:GetSpecialValueFor("cleave_end_radius"),
        self:GetSpecialValueFor("cleave_distance"),
        "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf"
    )
    dummyUnit:ForceKill(false)
    self:PlayEffects()
end

function ayaka_kabuki:PlayEffects()
    self:GetCaster():EmitSound("Hero_Juggernaut.Attack")
end
