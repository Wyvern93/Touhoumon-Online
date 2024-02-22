#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Necessary changes to allow for an alternate pbShowCommands to work
#==============================================================================#
def pbMessageAlt(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)

  ret = 0
  msgwindow = pbCreateMessageWindow(nil, skin)
  if commands
    ret = pbMessageDisplay(msgwindow, message, true,
                           proc { |msgwndw|
                             next Kernel.pbShowCommandsWithIcon(msgwndw, commands, cmdIfCancel, defaultCmd, &block)
                           }, &block)
  else
    pbMessageDisplay(msgwindow, message, &block)
  end
  pbDisposeMessageWindow(msgwindow)
  Input.update
  return ret
end

def pbShowCommandsWithIcon(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0)
  return 0 if !commands
  cmdwindow = Window_AdvancedCommandPokemonEx.new(commands)
  cmdwindow.z = 99999
  cmdwindow.visible = true
  cmdwindow.resizeToFit(cmdwindow.commands)
  pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
  cmdwindow.index = defaultCmd
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    msgwindow&.update
    yield if block_given?
    if Input.trigger?(Input::BACK)
      if cmdIfCancel > 0
        command = cmdIfCancel - 1
        break
      elsif cmdIfCancel < 0
        command = cmdIfCancel
        break
      end
    end
    if Input.trigger?(Input::USE)
      command = cmdwindow.index
      break
    end
    pbUpdateSceneMap
  end
  ret = command
  cmdwindow.dispose
  Input.update
  return ret
end