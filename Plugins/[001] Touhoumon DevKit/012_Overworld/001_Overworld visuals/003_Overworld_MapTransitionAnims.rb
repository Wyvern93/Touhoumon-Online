#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removed explicit references to Pokemon as a species
#	* Changed the colors for the blackout message from 8 to 12
#		* This might be unnecessary here, idk.
#==============================================================================#
def pbStartOver(gameover = false)
  if pbInBugContest?
    pbBugContestStartOver
    return
  end
  $stats.blacked_out_count += 1
  $player.heal_party
  if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId >= 0
    if gameover
      pbMessage("\\w[]\\wm\\c[12]\\l[3]" +
                _INTL("After the unfortunate defeat, you scurry back to a Pokémon Center."))
    else
      pbMessage("\\w[]\\wm\\c[12]\\l[3]" +
                _INTL("You scurry back to a Pokémon Center, protecting your exhausted partners from any further harm..."))
    end
    pbCancelVehicles
    Followers.clear
	$game_switches[Settings::SPECIAL_BATTLE_SWITCH] = false
    $game_switches[Settings::STARTING_OVER_SWITCH] = true
    $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
    $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
    $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
    $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
    pbDismountBike
    $scene.transfer_player if $scene.is_a?(Scene_Map)
    $game_map.refresh
  else
    homedata = GameData::PlayerMetadata.get($player.character_ID)&.home
    homedata = GameData::Metadata.get.home if !homedata
    if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata", homedata[0]))
      if $DEBUG
        pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.", homedata[0]))
      end
      $player.heal_party
      return
    end
    if gameover
      pbMessage("\\w[]\\wm\\c[12]\\l[3]" +
                _INTL("After the unfortunate defeat, you scurry back home."))
    else
      pbMessage("\\w[]\\wm\\c[12]\\l[3]" +
                _INTL("You scurry back home, protecting your exhausted partners from any further harm..."))
    end
    if homedata
      pbCancelVehicles
      Followers.clear
	  $game_switches[Settings::SPECIAL_BATTLE_SWITCH] = false
      $game_switches[Settings::STARTING_OVER_SWITCH] = true
      $game_temp.player_new_map_id    = homedata[0]
      $game_temp.player_new_x         = homedata[1]
      $game_temp.player_new_y         = homedata[2]
      $game_temp.player_new_direction = homedata[3]
      pbDismountBike
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      $player.heal_party
    end
  end
  pbEraseEscapePoint
end