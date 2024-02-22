#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Added the Puppet Orbs variants
#	* Made it so the Net Ball works on Touhoumon Water and Beast Types
#	* Added the Glitter Ball, which will turn a species shiny on capture, or 
#	  have an enhanced rate against Shiny Encounter. (NOT YET IMPLEMENTED)
#==============================================================================#

Battle::PokeBallEffects::ModifyCatchRate.add(:NETBALL, proc { |ball, catchRate, battle, battler|
  multiplier = (Settings::NEW_POKE_BALL_CATCH_RATES) ? 3.5 : 3
  catchRate *= multiplier if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER) ||
							 battler.pbHasType?(:BEAST18) || battler.pbHasType?(:WATER18)
  next catchRate
})


Battle::PokeBallEffects::ModifyCatchRate.add(:GREATORB, proc { |ball, catchRate, battle, battler|
  next catchRate * 1.5
})

Battle::PokeBallEffects::ModifyCatchRate.add(:ULTRAORB, proc { |ball, catchRate, battle, battler|
  next catchRate * 2
})

Battle::PokeBallEffects::ModifyCatchRate.add(:SAFARIORB, proc { |ball, catchRate, battle, battler|
  next catchRate * 1.5
})

Battle::PokeBallEffects::IsUnconditional.add(:MASTERORB, proc { |ball, battle, battler|
  next true
})