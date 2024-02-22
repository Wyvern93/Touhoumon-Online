module Reincarnation
  # If you want your reincarnation to cost an item, defined in COST_ITEM,
  # and the amount of that item, COST_AMOUNT. Set to nil if no cost
  COST_ITEM           = :MAGFRAG
  COST_AMOUNT         = 1

  # Custom Music for the Menu, has to be in BGM/SE folders respectively.
  CUSTOM_SCENE_BGM    = "Unexpected Visitor"
  CUSTOM_COMPLETE_SE  = "Evo Complete"

  # After reincarnation set Pokemon to this level, if nil, will not change level.
  SET_TO_LEVEL        = Settings::EGG_LEVEL # Default: 1
  REVERT_EVOLUTION    = true
  REVERT_MOVES        = false

  # Nuzlocke X Support 
  # Reincarnation can only be used if a Pokémon is fainted.
  NUZLOCKE_REINCARNATION = true
end