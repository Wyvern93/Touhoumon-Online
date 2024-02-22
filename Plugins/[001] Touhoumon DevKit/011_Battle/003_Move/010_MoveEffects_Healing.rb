#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to existing move effects to account for Touhoumon mechanics
#==============================================================================#

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#
# Change: Removed explicit references to Pokemon as an individual species
#===============================================================================
class Battle::Move::StartPerishCountsForAllBattlers < Battle::Move
  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    super
    @battle.pbDisplay(_INTL("Everyone on the field that heard the song will faint in three turns!"))
  end
end