#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Addition of Fretful to Truant checks
#==============================================================================#
class Battle
  def pbPursuit(idxSwitcher)
    @switching = true
    pbPriority.each do |b|
      next if b.fainted? || !b.opposes?(idxSwitcher)   # Shouldn't hit an ally
      next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index, "PursueSwitchingFoe")
      # Check whether Pursuit can be used
      next unless pbMoveCanTarget?(b.index, idxSwitcher, @choices[b.index][2].pbTarget(b))
      next unless pbCanChooseMove?(b.index, @choices[b.index][1], false)
      next if b.status == :SLEEP || b.status == :FROZEN
      next if b.effects[PBEffects::SkyDrop] >= 0
      next if (b.hasActiveAbility?(:TRUANT) ||
      		   b.hasActiveAbility?(:FRETFUL)) && b.effects[PBEffects::Truant]
      # Mega Evolve
      if !b.wild?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner] == b.index
      end
      # Use Pursuit
      @choices[b.index][3] = idxSwitcher   # Change Pursuit's target
      b.pbProcessTurn(@choices[b.index], false)
      break if @decision > 0 || @battlers[idxSwitcher].fainted?
    end
    @switching = false
  end
end