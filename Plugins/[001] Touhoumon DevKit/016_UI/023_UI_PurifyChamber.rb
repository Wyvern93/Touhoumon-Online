#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Modified the messages for putting a Pokemon or Puppet into the Purify
#	  chamber. Otherwise, the dialogue removed Pokemon if possible.
#==============================================================================#
class PurifyChamberScreen
  def pbPlace(pkmn, position)
    return false if !pkmn
    if pkmn.egg?
      @scene.pbDisplay(_INTL("Can't place an egg there."))
      return false
    end
    if position == 0
      if pkmn.shadowPokemon?
        # Remove from storage and place in set
        oldpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, position)
        if oldpkmn
          @scene.pbShift(position, pkmn)
        else
          @scene.pbPlace(position, pkmn)
        end
        PurifyChamberHelper.pbSetPokemon(@chamber, position, pkmn)
        @scene.pbRefresh
      else
        @scene.pbDisplay(_INTL("Only a Shadow Pokémon or Puppet can go there."))
        return false
      end
    elsif position >= 1
      if pkmn.shadowPokemon?
        @scene.pbDisplay(_INTL("Can't place a Shadow Pokémon or Puppet there."))
        return false
      else
        oldpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, position)
        if oldpkmn
          @scene.pbShift(position, pkmn)
        else
          @scene.pbPlace(position, pkmn)
        end
        PurifyChamberHelper.pbSetPokemon(@chamber, position, pkmn)
        @scene.pbRefresh
      end
    end
    return true
  end

  def pbPlacePokemon(pos, position)
    return false if !pos
    pkmn = $PokemonStorage[pos[0], pos[1]]
    if pbPlace(pkmn, position)
      $PokemonStorage.pbDelete(pos[0], pos[1])
      return true
    end
    return false
  end

  def pbOnPlace(pkmn)
    set = @chamber.currentSet
    if @chamber.setCount(set) == 0 && @chamber.isPurifiableIgnoreRegular?(set)
      pkmn = @chamber.getShadow(set)
      @scene.pbDisplay(
        _INTL("This {1} is ready to open its heart. However, there must be at least one regular party member in the set to perform a purification ceremony.",
              pkmn.name)
      )
    end
  end

  def pbOpenSetDetail
    chamber = @chamber
    @scene.pbOpenSetDetail(chamber.currentSet)
    heldpkmn = nil
    loop do
      # Commands
      # array[0]==0 - a position was chosen
      # array[0]==1 - a new set was chosen
      # array[0]==2 - choose Pokemon command
      cmd = @scene.pbSetScreen
      case cmd[0]
      when 0   # Place Pokemon in the set
        curpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, cmd[1])
        if curpkmn || heldpkmn
          commands = [_INTL("MOVE"), _INTL("SUMMARY"), _INTL("WITHDRAW")]
          if curpkmn && heldpkmn
            commands[0] = _INTL("EXCHANGE")
          elsif heldpkmn
            commands[0] = _INTL("PLACE")
          end
          cmdReplace = -1
          cmdRotate = -1
          if !heldpkmn && curpkmn && cmd[1] == 0 &&
             @chamber[@chamber.currentSet].length > 0
            commands[cmdRotate = commands.length] = _INTL("ROTATE")
          end
          if !heldpkmn && curpkmn
            commands[cmdReplace = commands.length] = _INTL("REPLACE")
          end
          commands.push(_INTL("CANCEL"))
          choice = @scene.pbShowCommands(
            _INTL("What shall I do with this {1}?", heldpkmn ? heldpkmn.name : curpkmn.name),
            commands
          )
          if choice == 0
            if heldpkmn
              if pbPlace(heldpkmn, cmd[1]) # calls place or shift as appropriate
                if curpkmn
                  heldpkmn = curpkmn # Pokemon was shifted
                else
                  pbOnPlace(heldpkmn)
                  @scene.pbPositionHint(PurifyChamberHelper.adjustOnInsert(cmd[1]))
                  heldpkmn = nil # Pokemon was placed
                end
              end
            else
              @scene.pbMove(cmd[1])
              PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], nil)
              @scene.pbRefresh
              heldpkmn = curpkmn
            end
          elsif choice == 1
            @scene.pbSummary(cmd[1], heldpkmn)
          elsif choice == 2
            if pbBoxesFull?
              @scene.pbDisplay(_INTL("All boxes are full."))
            elsif heldpkmn
              @scene.pbWithdraw(cmd[1], heldpkmn)
              $PokemonStorage.pbStoreCaught(heldpkmn)
              heldpkmn = nil
              @scene.pbRefresh
            else
              # Store and delete Pokemon.
              @scene.pbWithdraw(cmd[1], heldpkmn)
              $PokemonStorage.pbStoreCaught(curpkmn)
              PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], nil)
              @scene.pbRefresh
            end
          elsif cmdRotate >= 0 && choice == cmdRotate
            count = @chamber[@chamber.currentSet].length
            nextPos = @chamber[@chamber.currentSet].facing
            if count > 0
              @scene.pbRotate((nextPos + 1) % count)
              @chamber[@chamber.currentSet].facing = (nextPos + 1) % count
              @scene.pbRefresh
            end
          elsif cmdReplace >= 0 && choice == cmdReplace
            pos = @scene.pbChoosePokemon
            if pos
              newpkmn = $PokemonStorage[pos[0], pos[1]]
              if newpkmn
                if (newpkmn.shadowPokemon?) == (curpkmn.shadowPokemon?)
                  @scene.pbReplace(cmd, pos)
                  PurifyChamberHelper.pbSetPokemon(@chamber, cmd[1], newpkmn)
                  $PokemonStorage[pos[0], pos[1]] = curpkmn
                  @scene.pbRefresh
                  pbOnPlace(curpkmn)
                else
                  @scene.pbDisplay(_INTL("They can't be placed there."))
                end
              end
            end
          end
        else   # No current Pokemon
          pos = @scene.pbChoosePokemon
          if pbPlacePokemon(pos, cmd[1])
            curpkmn = PurifyChamberHelper.pbGetPokemon(@chamber, cmd[1])
            pbOnPlace(curpkmn)
            @scene.pbPositionHint(PurifyChamberHelper.adjustOnInsert(cmd[1]))
          end
        end
      when 1   # Change the active set
        @scene.pbChangeSet(cmd[1])
        chamber.currentSet = cmd[1]
      when 2   # Choose a Pokemon
        pos = @scene.pbChoosePokemon
        pkmn = pos ? $PokemonStorage[pos[0], pos[1]] : nil
        heldpkmn = pkmn if pkmn
      else   # cancel
        if heldpkmn
          @scene.pbDisplay(_INTL("You're holding something!"))
        else
          break if !@scene.pbConfirm(_INTL("Continue editing sets?"))
        end
      end
    end
    if pbCheckPurify
      @scene.pbDisplay(_INTL("{1} is ready to open its heart!\1",pkmn.name))
      @scene.pbCloseSetDetail
      pbDoPurify
      return false
    else
      @scene.pbCloseSetDetail
      return true
    end
  end
  
  def pbDoPurify
    purifiables = []
    PurifyChamber::NUMSETS.times do |set|
      if @chamber.isPurifiable?(set) # if ready for purification
        purifiables.push(set)
      end
    end
    purifiables.length.times do |i|
      set = purifiables[i]
      @chamber.currentSet = set
      @scene.pbOpenSet(set)
      @scene.pbPurify
      pbPurify(@chamber[set].shadow, self)
      pbStorePokemon(@chamber[set].shadow)
      @chamber.setShadow(set, nil) # Remove shadow Pokemon from set
      if (i + 1) != purifiables.length
        @scene.pbDisplay(_INTL("There is another that is ready to open its heart!"))
        if !@scene.pbConfirm(_INTL("Would you like to switch sets?"))
          @scene.pbCloseSet
          break
        end
      end
      @scene.pbCloseSet
    end
  end
end