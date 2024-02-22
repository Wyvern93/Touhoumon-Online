#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removes explicit references to Pokemon
#	* Changes the way text is displayed in the choice box to display Yin/Yang
#	  glyphs for gender.
#==============================================================================#
class DayCare
    def choice_text
      return nil if !filled?
	  pkmn_data = GameData::Species.get_species_form(pokemon.species, pokemon.form)
	  if pkmn_data.has_flag?("Puppet")
		if @pokemon.male?
		  return _INTL("{1} (¹, Lv.{2})", @pokemon.name, @pokemon.level)
		elsif @pokemon.female?
          return _INTL("{1} (², Lv.{2})", @pokemon.name, @pokemon.level)
		end
	  else
		if @pokemon.male?
		  return _INTL("{1} (♂, Lv.{2})", @pokemon.name, @pokemon.level)
		elsif @pokemon.female?
          return _INTL("{1} (♀, Lv.{2})", @pokemon.name, @pokemon.level)
		end
	  end
      return _INTL("{1} (Lv.{2})", @pokemon.name, @pokemon.level)
    end
	

  
#==============================================================================#
# Changes in this section include the following:
#	* Removes explicit references to Pokemon
#==============================================================================#
  def self.deposit(party_index)
    $stats.day_care_deposits += 1
    day_care = $PokemonGlobal.day_care
    pkmn = $player.party[party_index]
    raise _INTL("Nothing at index {1} in party.", party_index) if pkmn.nil?
    day_care.slots.each do |slot|
      next if slot.filled?
      slot.deposit(pkmn)
      $player.party.delete_at(party_index)
      day_care.reset_egg_counters
      return
    end
    raise _INTL("No room to deposit a party member.")
  end

  def self.withdraw(index)
    day_care = $PokemonGlobal.day_care
    slot = day_care[index]
    if !slot.filled?
      raise _INTL("Nothing found in slot {1}.", index)
    elsif $player.party_full?
      raise _INTL("No room in party to withdraw.")
    end
    $stats.day_care_levels_gained += slot.level_gain
    $player.party.push(slot.pokemon)
    slot.reset
    day_care.reset_egg_counters
  end

  def self.choose(message, choice_var)
    day_care = $PokemonGlobal.day_care
    case day_care.count
    when 0
      raise _INTL("Nothing found in Day Care to choose from.")
    when 1
      day_care.slots.each_with_index { |slot, i| $game_variables[choice_var] = i if slot.filled? }
    else
      commands = []
      indices = []
      day_care.slots.each_with_index do |slot, i|
        choice_text = slot.choice_text
        next if !choice_text
        commands.push(choice_text)
        indices.push(i)
      end
      commands.push(_INTL("CANCEL"))
      command = pbMessage(message, commands, commands.length)
      $game_variables[choice_var] = (command == commands.length - 1) ? -1 : indices[command]
    end
  end
end
	
  
#==============================================================================#
# Changes in this section include the following:
#	* The addition of the pbHatchAll command, which is used in the Debug Menu
#==============================================================================#
def pbHatchAll
  for egg in $player.party
    if egg.egg?
      egg.steps_to_hatch=0
      pbHatch(egg)
    end
  end
end