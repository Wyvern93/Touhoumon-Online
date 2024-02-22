#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Feel free to Add, Remove, or Change anything here at your leisure.
# Use the BattleSettings script section to get an example of what is and isn't
# available to modify.
# - DerxwnaKapsyla
#==============================================================================#
module Settings
  MOVE_CATEGORY_PER_MOVE                      = true
  FIXED_DURATION_WEATHER_FROM_ABILITY         = true
  
  X_STAT_ITEMS_RAISE_BY_TWO_STAGES = false
  NEW_POKE_BALL_CATCH_RATES        = true
  SOUL_DEW_POWERS_UP_TYPES            = true
  
  SCALED_EXP_FORMULA        = true
  SPLIT_EXP_BETWEEN_GAINERS = true
  MORE_EXP_FROM_TRAINER_POKEMON        = true
  MORE_EVS_FROM_POWER_ITEMS            = true
  ENABLE_CRITICAL_CAPTURES  = true
  GAIN_EXP_FOR_CAPTURE      = true
  NEW_CAPTURE_CAN_REPLACE_PARTY_MEMBER = true
  CHECK_EVOLUTION_AFTER_ALL_BATTLES   = true
  
  # These may be outdated, as Essentials Deluxe will be doing this but better.
  SPECIAL_BATTLE_SWITCH			= 102	# Used for when you want to trigger a battle with special text for the encounter. (Ie; "N's Zoroark", "The aggressive Igglybuff", etc.)
  SPECIAL_BATTLE_VARIABLE		= 102	# Used in conjunction with the switch above. Determines the stringset to run. You can find existing ones by searching for these lines.
  
  # This setting determines whether or not the player is awarded with Magical Fragments after battle concludes. Magical Fragments are used in the Reincarnation system.
  # This section also determines how many Magical Fragments are rewarded after battle
  GAIN_MAGICAL_FRAGMENTS_AFTER_BATTLE          = true
  MAGICAL_FRAGMENT_REWARD_COUNT                = 1
end