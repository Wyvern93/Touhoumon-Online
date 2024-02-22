Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserTakesTargetItem",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild? || user.item
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
	next score if target.has_active_ability?(:COLLECTOR) && !battle.moldBreaker
    # User can steal the target's item; score it
    user_item_preference = user.wants_item?(target.item_id)
    user_no_item_preference = user.wants_item?(:NONE)
    user_diff = user_item_preference - user_no_item_preference
    user_diff = 0 if !user.item_active?
    target_item_preference = target.wants_item?(target.item_id)
    target_no_item_preference = target.wants_item?(:NONE)
    target_diff = target_no_item_preference - target_item_preference
    target_diff = 0 if !target.item_active?
    score += user_diff * 4
    score -= target_diff * 4
    next score
  }
)

Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("UserTargetSwapItems",
  proc { |move, user, target, ai, battle|
    next true if user.wild?
    next true if !user.item && !target.item
    next true if user.battler.unlosableItem?(user.item) || user.battler.unlosableItem?(target.item)
    next true if target.battler.unlosableItem?(target.item) || target.battler.unlosableItem?(user.item)
    next true if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
	next true if target.has_active_ability?(:COLLECTOR) && !battle.moldBreaker
    next false
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("RemoveTargetItem",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild?
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
	next score if target.has_active_ability?(:COLLECTOR) && !battle.moldBreaker
    next score if !target.item_active?
    # User can knock off the target's item; score it
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    score -= (no_item_preference - item_preference) * 4
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DestroyTargetBerryOrGem",
  proc { |score, move, user, target, ai, battle|
    next score if !target.item || (!target.item.is_berry? &&
                  !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
	next score if target.has_active_ability?(:COLLECTOR) && !battle.moldBreaker
    next score if !target.item_active?
    # User can incinerate the target's item; score it
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    score -= (no_item_preference - item_preference) * 4
    next score
  }
)

Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("CorrodeTargetItem",
  proc { |move, user, target, ai, battle|
    next true if !target.item || target.battler.unlosableItem?(target.item) ||
                 target.effects[PBEffects::Substitute] > 0
    next true if target.has_active_ability?(:STICKYHOLD)
	next true if target.has_active_ability?(:COLLECTOR)
    next true if battle.corrosiveGas[target.index % 2][target.party_index]
    next false
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("ThrowUserItemAtTarget",
  proc { |score, move, user, target, ai, battle|
    case user.item_id
    when :POISONBARB, :TOXICORB
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("PoisonTarget",
         score, move, user, target, ai, battle)
    when :FLAMEORB, :BAKEDPOTATO
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("BurnTarget",
         score, move, user, target, ai, battle)
    when :LIGHTBALL
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("ParalyzeTarget",
         score, move, user, target, ai, battle)
	when :ICEBALL
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("FreezeTarget",
         score, move, user, target, ai, battle)
    when :KINGSROCK, :RAZORFANG
      score = Battle::AI::Handlers.apply_move_effect_against_target_score("FlinchTarget",
         score, move, user, target, ai, battle)
    else
      score -= target.get_score_change_for_consuming_item(user.item_id)
    end
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Don't prefer if target will become able to use Belch
      score -= 5 if user.item.is_berry? && !target.battler.belched? &&
                    target.has_move_with_function?("FailsIfUserNotConsumedBerry")
      # Prefer if user will benefit from not having an item
      score += 5 if user.has_active_ability?(:UNBURDEN)
    end
    # Prefer if the user doesn't want its held item/don't prefer if it wants to
    # keep its held item
    item_preference = user.wants_item?(user.item_id)
    no_item_preference = user.wants_item?(:NONE)
    score += (no_item_preference - item_preference) * 2
    next score
  }
)