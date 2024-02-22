#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Adjustments to battle strings for Special Battles
#	* Adds handling for the "Make the next wild battle be shiny" passcode
#	  (Switch 31). Will disable itself when it notices its on.
#==============================================================================#
class Battle
  def pbStartBattleSendOut(sendOuts)	
        if $game_switches[Settings::SPECIAL_BATTLE_SWITCH]
          case $game_variables[Settings::SPECIAL_BATTLE_VARIABLE]
                when 1        then sbName = "The territorial"
                when 2        then sbName = "The aggressive"
                when 3        then sbName = "Celadon Gym's"
                when 4        then sbName = "A trainer's"
                else               sbName = "Oh! A wild"
          end
        else
          sbName = "Oh! A wild"
        end 
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("{2} {1} appeared!", foeParty[0].name, sbName))
      when 2
        pbDisplayPaused(_INTL("{3} {1} and {2} appeared!", foeParty[0].name,
                              foeParty[1].name, sbName))
      when 3
        pbDisplayPaused(_INTL("{4} {1}, {2} and {3} appeared!", foeParty[0].name,
                              foeParty[1].name, foeParty[2].name, sbName))
      end
	  #if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH] # Used for the "Make Any Pokemon Shiny" passcode
	  #  $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH] = false
	  #end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!", @opponent[0].full_name))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!", @opponent[0].full_name,
                              @opponent[1].full_name))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
                              @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
      end
    end
    # Send out Pokémon (opposing trainers first)
    [1, 0].each do |side|
      next if side == 1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side == 0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t, i|
        next if side == 0 && i == 0   # The player's message is shown last
        msg += "\n" if msg.length > 0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!", t.full_name, @battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!", t.full_name,
                       @battlers[sent[0]].name, @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side == 0
        msg += "\n" if msg.length > 0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!", @battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!", @battlers[sent[0]].name, @battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!", @battlers[sent[0]].name,
                       @battlers[sent[1]].name, @battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length > 0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler, @battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts, true)
    end
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Implements a method to gain Magical Fragments
#==============================================================================#
  def pbGainMagFrags
	return if !Settings::GAIN_MAGICAL_FRAGMENTS_AFTER_BATTLE
	$bag.add(:MAGFRAG, Settings::MAGICAL_FRAGMENT_REWARD_COUNT)
	if Settings::MAGICAL_FRAGMENT_REWARD_COUNT > 1
	  pbDisplayPaused(_INTL("You picked up {1} Magical Fragments!", Settings::MAGICAL_FRAGMENT_REWARD_COUNT))
	else
	  pbDisplayPaused(_INTL("You picked up {1} Magical Fragment!", Settings::MAGICAL_FRAGMENT_REWARD_COUNT))
	end
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Removes explicit references to Pokemon as a individual species
#	* Adds in the method to acquire Magical Fragments after winning a battle
#	  or a successful capture
#==============================================================================#
  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision == 1 && wildBattle? && @caughtPokemon.length > 0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log_header("===== Player won =====")
      PBDebug.log("")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!", @opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!", @opponent[0].full_name,
                                @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!", @opponent[0].full_name,
                                @opponent[1].full_name, @opponent[2].full_name))
        end
        @opponent.each_with_index do |trainer, i|
          @scene.pbShowOpponent(i)
          msg = trainer.lose_text
          msg = "..." if !msg || msg.empty?
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
        end
        PBDebug.log("")
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision != 4
	  # Gain Magical Fragments from winning a battle, if the prerequsite battle setting is on
	  pbGainMagFrags
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length > 0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log_header("===== Player lost =====") if @decision == 2
      PBDebug.log_header("===== Player drew with opponent =====") if @decision == 5
      PBDebug.log("")
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more party members that can fight!"))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!", @opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
                                  @opponent[0].full_name, @opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
                                  @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision == 2   # Lost in a Battle Frontier battle
        if @opponent
          @opponent.each_with_index do |trainer, i|
            @scene.pbShowOpponent(i)
            msg = trainer.win_text
            msg = "..." if !msg || msg.empty?
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
          end
          PBDebug.log("")
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      PBDebug.log("")
      PBDebug.log_header("===== Pokémon caught =====")
      PBDebug.log("")
      @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
	  # Gain Magical Fragments for capturing a Pokemon, if the prerequsite battle setting is on
	  pbGainMagFrags
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision == 4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $player.party.each_with_index do |pkmn, i|
        infected.push(i) if pkmn.pokerusStage == 1
      end
      infected.each do |idxParty|
        strain = $player.party[idxParty].pokerusStrain
        if idxParty > 0 && $player.party[idxParty - 1].pokerusStage == 0 && rand(3) == 0   # 33%
          $player.party[idxParty - 1].givePokerus(strain)
        end
        if idxParty < $player.party.length - 1 && $player.party[idxParty + 1].pokerusStage == 0 && rand(3) == 0   # 33%
          $player.party[idxParty + 1].givePokerus(strain)
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      Battle::AbilityEffects.triggerOnSwitchOut(b.ability, b, true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn, i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self, pkmn, @usedInBattle[0][i], true)   # Reset form
      pkmn.item = @initialItems[0][i]
    end
	if $player.next_wild_shiny
	  $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH] = false
	  $player.next_wild_shiny = false
	end
    return @decision
  end
end