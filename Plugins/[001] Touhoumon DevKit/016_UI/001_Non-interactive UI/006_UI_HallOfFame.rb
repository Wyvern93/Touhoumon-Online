#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Changed the Hall of Fame entry music
#	* Adjusted the script to get the Yin/Yang icons to display for the HoF
#	* Made it so an applause SE plays like in official games
#==============================================================================#
class HallOfFame_Scene
  ENTRYMUSIC = "U-005. Broken Moon (Hall of Fame Mix).ogg" # Derx: Hall of Fame music changed
  
  def writePokemonData(pokemon, hallNumber = -1)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pokename = pokemon.name
    speciesname = pokemon.speciesName
    pkmn_data = GameData::Species.get_species_form(pokemon.species, pokemon.form)
    if pkmn_data.has_flag?("Puppet")
      if pokemon.male?
      	speciesname += "¹"
      elsif pokemon.female?
     	speciesname += "²"
      end
    else
      if pokemon.male?
      	speciesname += "♂"
      elsif pokemon.female?
     	speciesname += "♀"
      end
    end
    pokename += "/" + speciesname
    pokename = _INTL("Egg") + "/" + _INTL("Egg") if pokemon.egg?
    idno = (pokemon.owner.name.empty? || pokemon.egg?) ? "?????" : sprintf("%05d", pokemon.owner.public_id)
    dexnumber = _INTL("No. ???")
    if !pokemon.egg?
      number = @nationalDexList.index(pokemon.species) || 0
      dexnumber = _ISPRINTF("No. {1:03d}", number)
    end
    textPositions = [
      [dexnumber, 32, Graphics.height - 74, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [pokename, Graphics.width - 192, Graphics.height - 74, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [_INTL("Lv. {1}", pokemon.egg? ? "?" : pokemon.level),
       64, Graphics.height - 42, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR],
      [_INTL("ID No. {1}", pokemon.egg? ? "?????" : idno),
       Graphics.width - 192, Graphics.height - 42, :center, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR]
    ]
    if hallNumber > -1
      textPositions.push([_INTL("Hall of Fame No."), (Graphics.width / 2) - 104, 6, :left, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
      textPositions.push([hallNumber.to_s, (Graphics.width / 2) + 104, 6, :right, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
    end
    pbDrawTextPositions(overlay, textPositions)
  end

  def writeWelcome
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    pbDrawTextPositions(overlay, [[_INTL("Welcome to the Hall of Fame!"),
                                   Graphics.width / 2, Graphics.height - 68, 2, BASECOLOR, SHADOWCOLOR]])
	pbSEPlay("Applause") # Derx: Official applause sound effect
  end
end