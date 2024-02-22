#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Adjustments to battle strings for Special Battles
#==============================================================================#
class Battle::Battler
  def pbThis(lowerCase = false)
    if opposes?
      if @battle.trainerBattle?
        return lowerCase ? _INTL("the opposing {1}", name) : _INTL("The opposing {1}", name)
      else
		if $game_switches[Settings::SPECIAL_BATTLE_SWITCH] # Special Battle Switch
		  case $game_variables[Settings::SPECIAL_BATTLE_VARIABLE]
			when 1	then sbName = "the territorial"	 ; sbName2 = "The territorial" 
			when 2	then sbName = "the aggressive" 	 ; sbName2 = "The aggressive"
			when 3	then sbName = "Celadon Gym's"	 ; sbName2 = "Celadon Gym's"
			when 4	then sbName = "a trainer's"		 ; sbName2 = "A trainer's"
		    else		 sbName = "the wild"		 ; sbName2 = "The wild"
		  end
		  return lowerCase ? _INTL("{2} {1}", name, sbName) : _INTL("{2} {1}", name, sbName2)
		else
		  return lowerCase ? _INTL("the wild {1}", name) : _INTL("The wild {1}", name)
		end
      end
    elsif !pbOwnedByPlayer?
      return lowerCase ? _INTL("the ally {1}", name) : _INTL("The ally {1}", name)
    end
    return name
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added checks for Touhoumon Flying to count as Airborne
#==============================================================================#  
  def airborne?
    return false if hasActiveItem?(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pbHasType?(:FLYING)
	return true if pbHasType?(:FLYING18)
    return true if hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
    return true if hasActiveItem?(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise] > 0
    return true if @effects[PBEffects::Telekinesis] > 0
    return false
  end

#==============================================================================#
# Changes in this section include the following:
#	* Added checks for Touhoumon types in regards to Sandstorm immunity
#==============================================================================#
  def takesSandstormDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL) ||
					pbHasType?(:EARTH18) || pbHasType?(:BEAST18) || pbHasType?(:STEEL18)
    return false if inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
    return false if hasActiveAbility?([:OVERCOAT, :SANDFORCE, :SANDRUSH, :SANDVEIL])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added checks for Touhoumon types in regards to Hail immunity
#==============================================================================#  
  def takesHailDamage?
    return false if !takesIndirectDamage?
    return false if pbHasType?(:ICE) || pbHasType?(:ICE18)
    return false if inTwoTurnAttack?("TwoTurnAttackInvulnerableUnderground",
                                     "TwoTurnAttackInvulnerableUnderwater")
    return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK])
    return false if hasActiveItem?(:SAFETYGOGGLES)
    return true
  end
end