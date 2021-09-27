modifier_pyro_effect = class({})

function modifier_pyro_effect:IsHidden()
    return false
  end
  
  function modifier_pyro_effect:IsDebuff() 
    return true
  end
  
  function modifier_pyro_effect:IsPurgable() 
    return true
  end
  