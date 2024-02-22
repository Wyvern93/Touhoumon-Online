Battle::AI::Handlers::MoveFailureCheck.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |move, user, ai, battle|
    next false if (user.has_type?(:GHOST) ||
                  (move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))) ||
				  (user.has_type?(:GHOST18) ||
                  (move.rough_type == :GHOST18 && user.has_active_ability?([:LIBERO, :PROTEAN])))
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    (move.move.statDown.length / 2).times do |i|
      next if !user.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |move, user, target, ai, battle|
    next false if (!user.has_type?(:GHOST) &&
                  !(move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))) ||
				  (!user.has_type?(:GHOST18) &&
                  !(move.rough_type == :GHOST18 && user.has_active_ability?([:LIBERO, :PROTEAN])))
    next true if target.effects[PBEffects::Curse] || !target.battler.takesIndirectDamage?
    next false
  }
)
Battle::AI::Handlers::MoveEffectScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, ai, battle|
    next score if (user.has_type?(:GHOST) ||
                  (move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))) ||
				  (user.has_type?(:GHOST18) ||
                  (move.rough_type == :GHOST18 && user.has_active_ability?([:LIBERO, :PROTEAN])))
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == Battle::AI::MOVE_USELESS_SCORE
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("CurseTargetOrLowerUserSpd1RaiseUserAtkDef1",
  proc { |score, move, user, target, ai, battle|
    next score if (!user.has_type?(:GHOST) &&
                  !(move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))) ||
				  (!user.has_type?(:GHOST) &&
                  !(move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN])))
    # Don't prefer if user will faint because of using this move
    if ai.trainer.has_skill_flag?("HPAware")
      next Battle::AI::MOVE_USELESS_SCORE if user.hp <= user.totalhp / 2
    end
    # Prefer early on
    score += 10 if user.turnCount < 2
    if ai.trainer.medium_skill?
      # Prefer if the user has no damaging moves
      score += 15 if !user.check_for_move { |m| m.damagingMove? }
      # Prefer if the target can't switch out to remove its curse
      score += 10 if !battle.pbCanChooseNonActive?(target.index)
    end
    if ai.trainer.high_skill?
      # Prefer if user can stall while damage is dealt
      if user.check_for_move { |m| m.is_a?(Battle::Move::ProtectMove) }
        score += 5
      end
    end
    next score
  }
)