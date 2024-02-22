#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removed explicit references to Pokemon
#==============================================================================#
class BugContestBattle < Battle

  def pbCommandMenu(idxBattler, _firstAction)
    return @scene.pbCommandMenuEx(idxBattler,
                                  [_INTL("Sport Balls: {1}", @ballCount),
                                   _INTL("Fight"),
                                   _INTL("Ball"),
                                   _INTL("Party"),
                                   _INTL("Run")], 4)
  end
  
 def pbStorePokemon(pkmn)
    if pbBugContestState.lastPokemon
      lastPokemon = pbBugContestState.lastPokemon
      pbDisplayPaused(_INTL("You already caught a {1}.", lastPokemon.name))
      helptext = _INTL("Stock Capture:\n{1} Lv.{2} Max HP: {3}\nThis Capture:\n{4} Lv.{5} Max HP: {6}",
                       lastPokemon.name, lastPokemon.level, lastPokemon.totalhp,
                       pkmn.name, pkmn.level, pkmn.totalhp)
      @scene.pbShowHelp(helptext)
      if pbDisplayConfirm(_INTL("Switch captures?"))
        pbBugContestState.lastPokemon = pkmn
        @scene.pbHideHelp
      else
        @scene.pbHideHelp
        return
      end
    else
      pbBugContestState.lastPokemon = pkmn
    end
    pbDisplay(_INTL("Caught {1}!", pkmn.name))
  end
end