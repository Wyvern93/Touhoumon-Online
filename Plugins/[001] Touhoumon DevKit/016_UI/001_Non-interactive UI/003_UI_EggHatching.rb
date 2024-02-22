#===============================================================================
# Changes in this section include:
#	* Changing the default egg hatching music.
#===============================================================================
class PokemonEggHatch_Scene
  def pbMain
    pbBGMPlay("U-002. Our Hisou Tensoku (Evolution)")
    # Egg animation
    updateScene(1.5)
    pbPositionHatchMask(0)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(0.2)
    pbPositionHatchMask(1)
    pbSEPlay("Battle ball shake")
    swingEgg(4)
    updateScene(0.4)
    pbPositionHatchMask(2)
    pbSEPlay("Battle ball shake")
    swingEgg(8, 2)
    updateScene(0.4)
    pbPositionHatchMask(3)
    pbSEPlay("Battle ball shake")
    swingEgg(16, 4)
    updateScene(0.2)
    pbPositionHatchMask(4)
    pbSEPlay("Battle recall")
    # Fade and change the sprite
    timer_start = System.uptime
    loop do
      tone_val = lerp(0, 255, 0.4, timer_start, System.uptime)
      @sprites["pokemon"].tone = Tone.new(tone_val, tone_val, tone_val)
      @sprites["overlay"].opacity = tone_val
      updateScene
      break if tone_val >= 255
    end
    updateScene(0.75)
    @sprites["pokemon"].setPokemonBitmap(@pokemon) # Pokémon sprite
    @sprites["pokemon"].x = Graphics.width / 2
    @sprites["pokemon"].y = 264
    @pokemon.species_data.apply_metrics_to_sprite(@sprites["pokemon"], 1)
    @sprites["hatch"].visible = false
    timer_start = System.uptime
    loop do
      tone_val = lerp(255, 0, 0.4, timer_start, System.uptime)
      @sprites["pokemon"].tone = Tone.new(tone_val, tone_val, tone_val)
      @sprites["overlay"].opacity = tone_val
      updateScene
      break if tone_val <= 0
    end
    # Finish scene
    cry_duration = GameData::Species.cry_length(@pokemon)
    @pokemon.play_cry
    updateScene(cry_duration + 0.1)
    pbBGMStop
    pbMEPlay("Evolution success")
    @pokemon.name = nil
    pbMessage("\\se[]" + _INTL("{1} hatched from the Egg!", @pokemon.name) + "\\wt[80]") { update }
    # Record the Pokémon's species as owned in the Pokédex
    was_owned = $player.owned?(@pokemon.species)
    $player.pokedex.register(@pokemon)
    $player.pokedex.set_owned(@pokemon.species)
    $player.pokedex.set_seen_egg(@pokemon.species)
    # Show Pokédex entry for new species if it hasn't been owned before
    if Settings::SHOW_NEW_SPECIES_POKEDEX_ENTRY_MORE_OFTEN && !was_owned &&
       $player.has_pokedex && $player.pokedex.species_in_unlocked_dex?(@pokemon.species)
      pbMessage(_INTL("{1}'s data was added to the Pokédex.", @pokemon.name)) { update }
      $player.pokedex.register_last_seen(@pokemon)
      pbFadeOutIn do
        scene = PokemonPokedexInfo_Scene.new
        screen = PokemonPokedexInfoScreen.new(scene)
        screen.pbDexEntry(@pokemon.species)
      end
    end
    # Nickname the Pokémon
    if $PokemonSystem.givenicknames == 0 &&
       pbConfirmMessage(
         _INTL("Would you like to nickname the newly hatched {1}?", @pokemon.name)
       ) { update }
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", @pokemon.name),
                                    0, Pokemon::MAX_NAME_SIZE, "", @pokemon, true)
      @pokemon.name = nickname
      @nicknamed = true
    end
  end
end