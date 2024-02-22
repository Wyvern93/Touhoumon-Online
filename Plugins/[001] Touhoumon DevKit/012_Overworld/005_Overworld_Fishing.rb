#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Added Collector to the check for Fishing abilities, even though it's
#	  unofficial
#	* Removed explicit references to Pokemon
#==============================================================================#
def pbFishing(hasEncounter, rodType = 1)
  $stats.fishing_count += 1
  speedup = ($player.first_pokemon && [:STICKYHOLD, :SUCTIONCUPS, :COLLECTOR].include?($player.first_pokemon.ability_id))
  biteChance = 20 + (25 * rodType)   # 45, 70, 95
  biteChance *= 1.5 if speedup   # 67.5, 100, 100
  hookChance = 100
  pbFishingBegin
  msgWindow = pbCreateMessageWindow
  ret = false
  loop do
    time = rand(5..10)
    time = [time, rand(5..10)].min if speedup
    message = ""
    time.times { message += ".   " }
    if pbWaitMessage(msgWindow, time)
      pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("Not even a nibble...")) }
      break
    end
    if hasEncounter && rand(100) < biteChance
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
      duration = rand(5..10) / 10.0   # 0.5-1 seconds
      if !pbWaitForInput(msgWindow, message + "\n" + _INTL("Oh! A bite!"), duration)
        pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("They got away...")) }
        break
      end
      if Settings::FISHING_AUTO_HOOK || rand(100) < hookChance
        pbFishingEnd do
          pbMessageDisplay(msgWindow, _INTL("Landed something!")) if !Settings::FISHING_AUTO_HOOK
        end
        ret = true
        break
      end
#      biteChance += 15
#      hookChance += 15
    else
      pbFishingEnd { pbMessageDisplay(msgWindow, _INTL("Not even a nibble...")) }
      break
    end
  end
  pbDisposeMessageWindow(msgWindow)
  return ret
end