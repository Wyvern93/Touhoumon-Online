Battle::AI::Handlers::MoveEffectScore.add("RaiseUserSpDef1PowerUpElectricMove",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if user.has_damaging_move_of_type?(:ELECTRIC) || user.has_damaging_move_of_type?(:WIND18)
      score += 10
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("RaiseUserCriticalHitRate2",
  proc { |score, move, user, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !user.check_for_move { |m| m.damagingMove? }
    score += 15
    if ai.trainer.medium_skill?
      # Other effects that raise the critical hit rate
      if user.item_active?
        if [:RAZORCLAW, :SCOPELENS].include?(user.item_id) ||
           (user.item_id == :LUCKYPUNCH && user.battler.isSpecies?(:CHANSEY)) ||
           ([:LEEK, :STICK].include?(user.item_id) &&
           (user.battler.isSpecies?(:FARFETCHD) || user.battler.isSpecies?(:SIRFETCHD)))
		   (user.item_id == :NYUUDOUFIST && 
		   (user.battler.isSpecies?(:CICHIRIN) || user.battler.isSpecies?(:ICHIRIN)))
          score += 10
        end
      end
      # Critical hits do more damage
      score += 10 if user.has_active_ability?(:SNIPER)
    end
    next score
  }
)


