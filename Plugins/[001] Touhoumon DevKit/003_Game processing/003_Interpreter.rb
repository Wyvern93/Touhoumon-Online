#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Implementation of Cross-Map Self-Switch Setting
#==============================================================================#
class Interpreter

  def pbSetSelfSwitch2(map, eventid, switch_name, value)
		$game_self_switches[[map, eventid, switch_name]] = value
		$game_map.need_refresh = true
  end

#==============================================================================#
# Changes in this section include the following:
#	* Commented out a few lines of code to allow Custom Vs. Transitions to work
#
#	  NOTE: This does cause a few quirks:
#
#	  [6:26 PM] Maruno: $game_temp.in_battle is set when it is for a couple of 
#	  reasons. It prevents phone calls happening at the exact moment a battle tries 
#	  to start, it stands the player up if they were in their running pose, and 
#	  it prevents low laptop battery messages from showing at that moment.
#==============================================================================#
  # Runs a common event.
  def pbCommonEvent(id)
    common_event = $data_common_events[id]
    return if !common_event
#    if $game_temp.in_battle
#      $game_system.battle_interpreter.setup(common_event.list, 0)
#    else
      interp = Interpreter.new
      interp.setup(common_event.list, 0)
      loop do
        Graphics.update
        Input.update
        interp.update
        pbUpdateSceneMap
        break if !interp.running?
      end
#    end
  end
end