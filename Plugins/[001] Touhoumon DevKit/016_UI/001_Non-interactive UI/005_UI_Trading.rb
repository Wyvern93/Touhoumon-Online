#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Added a BGM to play for the trading UI
#==============================================================================#
class PokemonTrade_Scene
  def pbTrade
    was_owned = $player.owned?(@pokemon2.species)
    $player.pokedex.register(@pokemon2)
    $player.pokedex.set_owned(@pokemon2.species)
    pbBGMStop
	pbBGMPlay("U-004. Shanghai Alice of Meiji 17 (Trading).ogg")
    @pokemon.play_cry
    speciesname1 = GameData::Species.get(@pokemon.species).name
    speciesname2 = GameData::Species.get(@pokemon2.species).name
    pbMessageDisplay(@sprites["msgwindow"],
                     _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}",
                               @pokemon.name, @pokemon.owner.public_id, @pokemon.owner.name) + "\\wtnp[0]") { pbUpdate }
    pbMessageWaitForInput(@sprites["msgwindow"], 50, true) { pbUpdate }
    pbPlayDecisionSE
    pbScene1
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("For {1}'s {2},\n{3} sends {4}.", @trader1, speciesname1, @trader2, speciesname2) + "\1") { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("{1} bids farewell to {2}.", @trader2, speciesname2)) { pbUpdate }
    pbScene2
    pbMessageDisplay(@sprites["msgwindow"],
                     _ISPRINTF("{1:s}\nID: {2:05d}   OT: {3:s}",
                               @pokemon2.name, @pokemon2.owner.public_id, @pokemon2.owner.name) + "\1") { pbUpdate }
    pbMessageDisplay(@sprites["msgwindow"],
                     _INTL("Take good care of {1}.", speciesname2)) { pbUpdate }
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(@pokemon2.species)
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("{1}'s data was added to the Pokédex.", speciesname2)) { pbUpdate }
      $player.pokedex.register_last_seen(@pokemon2)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon2.species)
        pbEndScreen(false)
      end
    end
  end
end