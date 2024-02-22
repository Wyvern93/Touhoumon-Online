#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removed explicit references to Pokemon.
#==============================================================================#

def pbRelicStone
  if $player.party.none? { |pkmn| pkmn.purifiable? }
    pbMessage(_INTL("You have nothing that can be purified."))
    return
  end
  pbMessage(_INTL("There's someone that may open the door to its heart!"))
  # Choose a purifiable Pokemon
  pbChoosePokemon(1, 2, proc { |pkmn|
    pkmn.able? && pkmn.shadowPokemon? && pkmn.heart_gauge == 0
  })
  if $game_variables[1] >= 0
    pbRelicStoneScreen($player.party[$game_variables[1]])
  end
end