#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Ensures that Amira Naxeroth will always be fought on the Starlight
#	  battle background. Because my shitposting is cosmic and interstellar.
#	  Out of this goddamn world.
#==============================================================================#
EventHandlers.add(:on_trainer_load, :shameless_self_insert,
  proc { |trainer|
    if trainer
      if trainer.name==("Amira Naxeroth")
        $PokemonGlobal.nextBattleBack = "starlight"
      end
    end
    }
)

EventHandlers.add(:on_wild_pokemon_created, :pokemon_encounter,
    proc { |pkmn|
      next unless pkmn.species_data.has_flag?("Pokemon")
      $PokemonGlobal.nextBattleBGM = pbStringToAudioFile("B-010. Battle vs. Hidden Encounter")
    }
)

#EventHandlers.add(:on_trainer_load, :make_trainer_shiny,
#  proc { |trainer|
#    if trainer
#	  for pkmn in trainer.party
#		pkmn.shiny = true if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
#	  end
#	end
#  }
#)