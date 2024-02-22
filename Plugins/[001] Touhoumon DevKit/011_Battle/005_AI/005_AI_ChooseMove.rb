
class Battle::AI
#==============================================================================#
# Changes in this section include the following:
#	* Added Wind and Hydro to Lightning Rod and Storm Drain checks
#==============================================================================#
  def get_redirected_target(target_data)
    return nil if @move.move.cannotRedirect?
    return nil if !target_data.can_target_one_foe? || target_data.num_targets != 1
    return nil if @user.has_active_ability?([:PROPELLERTAIL, :STALWART])
    priority = @battle.pbPriority(true)
    near_only = !target_data.can_choose_distant_target?
    # Spotlight, Follow Me/Rage Powder
    new_target = -1
    strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop] >= 0
      next if !b.opposes?(@user.battler)
      next if near_only && !b.near?(@user.battler)
      if b.effects[PBEffects::Spotlight] > 0 && b.effects[PBEffects::Spotlight] - 50 < strength
        new_target = b.index
        strength = b.effects[PBEffects::Spotlight] - 50   # Spotlight takes priority
      elsif (b.effects[PBEffects::RagePowder] && @user.battler.affectedByPowder?) ||
            (b.effects[PBEffects::FollowMe] > 0 && b.effects[PBEffects::FollowMe] < strength)
        new_target = b.index
        strength = b.effects[PBEffects::FollowMe]
      end
    end
    return new_target if new_target >= 0
    calc_type = @move.rough_type
    priority.each do |b|
      next if b.index == @user.index
      next if near_only && !b.near?(@user.battler)
      case calc_type
      when :ELECTRIC, :WIND18
        new_target = b.index if b.hasActiveAbility?(:LIGHTNINGROD)
      when :WATER, :WATER18
        new_target = b.index if b.hasActiveAbility?(:STORMDRAIN)
      end
      break if new_target >= 0
    end
    return (new_target >= 0) ? new_target : nil
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Lucid Dreaming to Sleep-related checks
#==============================================================================#  
  def pbPredictMoveFailure
    # User is asleep and will not wake up
    return true if @user.battler.asleep? && @user.statusCount > 1 && !@move.move.usableWhenAsleep? && !user.has_active_ability?(:LUCIDDREAMING)
    # User is awake and can't use moves that are only usable when asleep
    return true if !@user.battler.asleep? && @move.move.usableWhenAsleep?
    # NOTE: Truanting is not considered, because if it is, a Pokémon with Truant
    #       will want to switch due to terrible moves every other round (because
    #       all of its moves will fail), and this is disruptive and shouldn't be
    #       how such Pokémon behave.
    # Primal weather
    return true if @battle.pbWeather == :HeavyRain && @move.rough_type == :FIRE
    return true if @battle.pbWeather == :HarshSun && @move.rough_type == :WATER
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail?(@move.function_code, @move, @user, self, @battle)
    return false
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added Airborne-immunity to Earth moves
#	* Added Umbral to Prankster Immunity checks
#==============================================================================#
  def pbPredictMoveFailureAgainstTarget
    # Move effect-specific checks
    return true if Battle::AI::Handlers.move_will_fail_against_target?(@move.function_code, @move, @user, @target, self, @battle)
    # Immunity to priority moves because of Psychic Terrain
    return true if @battle.field.terrain == :Psychic && @target.battler.affectedByTerrain? &&
                   @target.opposes?(@user) && @move.rough_priority(@user) > 0
    # Immunity because of ability
    return true if @move.move.pbImmunityByAbility(@user.battler, @target.battler, false)
    # Immunity because of Dazzling/Queenly Majesty
    if @move.rough_priority(@user) > 0 && @target.opposes?(@user)
      each_same_side_battler(@target.side) do |b, i|
        return true if b.has_active_ability?([:DAZZLING, :QUEENLYMAJESTY])
      end
    end
    # Type immunity
    calc_type = @move.rough_type
    typeMod = @move.move.pbCalcTypeMod(calc_type, @user.battler, @target.battler)
    return true if @move.move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
    # Dark-type immunity to moves made faster by Prankster
    return true if Settings::MECHANICS_GENERATION >= 7 && @move.statusMove? &&
                   @user.has_active_ability?(:PRANKSTER) && @target.has_type?(:DARK) && @target.opposes?(@user)
    # Umbral-type immunity to moves made faster by Prankster
    return true if Settings::MECHANICS_GENERATION >= 7 && @move.statusMove? &&
                   @user.has_active_ability?(:PRANKSTER) && @target.has_type?(:DARK18) && @target.opposes?(@user)
    # Airborne-based immunity to Ground moves
    return true if @move.damagingMove? && calc_type == :GROUND &&
                   @target.battler.airborne? && !@move.move.hitsFlyingTargets?
    # Airborne-based immunity to Earth moves
    return true if @move.damagingMove? && calc_type == :EARTH &&
                   @target.battler.airborne? && !@move.move.hitsFlyingTargets?
    # Immunity to powder-based moves
    return true if @move.move.powderMove? && !@target.battler.affectedByPowder?
    # Substitute
    return true if @target.effects[PBEffects::Substitute] > 0 && @move.statusMove? &&
                   !@move.move.ignoresSubstitute?(@user.battler) && @user.index != @target.index
    return false
  end
end