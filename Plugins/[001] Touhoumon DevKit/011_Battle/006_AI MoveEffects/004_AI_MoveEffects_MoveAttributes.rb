Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("OHKOIce",
  proc { |move, user, target, ai, battle|
    next true if target.has_type?(:ICE)
	next true if target.has_type?(:ICE18)
    next Battle::AI::Handlers.move_will_fail_against_target?("OHKO", move, user, target, ai, battle)
  }
)


Battle::AI::Handlers::MoveEffectScore.add("StartWeakenElectricMoves",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have Electric moves
    any_foe_electric_moves = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:ELECTRIC)
	  next if !b.has_damaging_move_of_type?(:WIND18)
      score += 15
      score += 7 if !b.check_for_move { |m| m.damagingMove? && (m.pbCalcType(b.battler) != :ELECTRIC || 
	                                                            m.pbCalcType(b.battler) != :WIND18) }
      any_foe_electric_moves = true
    end
    next Battle::AI::MOVE_USELESS_SCORE if !any_foe_electric_moves
    # Don't prefer if any allies have Electric moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:ELECTRIC)
	  next if !b.has_damaging_move_of_type?(:WIND18)
      score -= 10
      score -= 5 if !b.check_for_move { |m| m.damagingMove? && (m.pbCalcType(b.battler) != :ELECTRIC ||
                                                                m.pbCalcType(b.battler) != :WIND18) }
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartWeakenFireMoves",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have Fire moves
    any_foe_fire_moves = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:FIRE)
	  next if !b.has_damaging_move_of_type?(:FIRE18)
      score += 15
      score += 7 if !b.check_for_move { |m| m.damagingMove? && (m.pbCalcType(b.battler) != :FIRE ||
                                                                m.pbCalcType(b.battler) != :FIRE18)	}
      any_foe_fire_moves = true
    end
    next Battle::AI::MOVE_USELESS_SCORE if !any_foe_fire_moves
    # Don't prefer if any allies have Fire moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:FIRE)
	  next if !b.has_damaging_move_of_type?(:FIRE18)
      score -= 10
      score -= 5 if !b.check_for_move { |m| m.damagingMove? && (m.pbCalcType(b.battler) != :FIRE ||
                                                                m.pbCalcType(b.battler) != :FIRE18)	}
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartNegateTargetEvasionStatStageAndGhostImmunity",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::Foresight] || user.has_active_ability?(:SCRAPPY)
    # Check if the user knows any moves that would benefit from negating the
    # target's Ghost type immunity
    if target.has_type?(:GHOST)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :GHOST)
      end
	elsif target.has_type?(:GHOST18)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :GHOST18)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartNegateTargetEvasionStatStageAndDarkImmunity",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.effects[PBEffects::MiracleEye]
    # Check if the user knows any moves that would benefit from negating the
    # target's Dark type immunity
    if target.has_type?(:DARK)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :DARK)
      end
	elsif target.has_type?(:DARK18)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :DARK18)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

Battle::AI::Handlers::MoveBasePower.copy("TypeAndPowerDependOnWeather",
                                         "TypeAndPowerDependOnWeatherThmn")