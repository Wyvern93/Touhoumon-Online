#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* The custom Vs. Transitions used by the Touhoumon DevKit.
#==============================================================================#
SpecialBattleIntroAnimations.register("derx_animations", 100,   # Priority 100
  proc { |battle_type, foe, location|   # Condition
    next $game_map && $game_switches[104] && $game_variables[103] <= 10
  },
  proc { |viewport, battle_type, foe, location|   # Animation
    case $game_variables[103]    # check this variable, and depending on the number returned...
     when  0 then pbCommonEvent(6)    # Vs. Yukari
     when  1 then  pbCommonEvent(7)    # Vs. Eirin
     when  2 then  pbCommonEvent(8)    # Vs. Byakuren
     when  3 then  pbCommonEvent(9)    # Vs. Eiki
     when  4 then  pbCommonEvent(10)   # Vs. Shinki
     when  5 then  pbCommonEvent(12)   # Vs. Derxwna
     when  6 then  pbCommonEvent(13)   # Vs. Nue
     when  7 then  pbCommonEvent(14)   # Vs. The Collector
     when  8 then  pbCommonEvent(15)   # Vs. Renko
     when  9 then  pbCommonEvent(16)   # Vs. Maribel
     when 10 then  pbCommonEvent(18)   # Vs. Sariel (Puppet)
    else
      raise "Custom animation #{$game_variables[103]} expected but not found somehow!"
    end
  }
)