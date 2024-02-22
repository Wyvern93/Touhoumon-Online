Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TrapTargetInBattleLowerTargetDefSpDef1EachTurn",
  proc { |move, user, target, ai, battle|
    next false if move.damagingMove?
    next true if target.effects[PBEffects::Octolock] >= 0
    next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
	next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST18)
    next false
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetLastMoveUsed",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Inherent preference
    score += 5
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF,
	                            :BLOOMERS, :POWERRIBBON, :POWERGOGGLES, :POWERCAPE]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 10
    end
    # Prefer disabling a damaging move
    score += 8 if GameData::Move.try_get(target.battler.lastRegularMoveUsed)&.damaging?
    next score
  }
)


Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetUsingSameMoveConsecutively",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Inherent preference
    score += 10
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF,
	                            :BLOOMERS, :POWERRIBBON, :POWERGOGGLES, :POWERCAPE]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 10
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetStatusMoves",
  proc { |score, move, user, target, ai, battle|
    next Battle::AI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.statusMove? }
    # Not worth using on a sleeping target that won't imminently wake up
    if target.status == :SLEEP && target.statusCount > ((target.faster_than?(user)) ? 2 : 1)
      if !target.check_for_move { |m| m.statusMove? && m.usableWhenAsleep? }
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Move is likely useless if the target will lock themselves into a move,
    # because they'll likely lock themselves into a damaging move
    if !target.effects[PBEffects::ChoiceBand]
      if target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF,
	                            :BLOOMERS, :POWERRIBBON, :POWERGOGGLES, :POWERCAPE]) ||
         target.has_active_ability?(:GORILLATACTICS)
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Prefer based on how many status moves the target knows
    target.battler.eachMove do |m|
      score += 5 if m.statusMove? && (m.pp > 0 || m.total_pp == 0)
    end
    # Prefer if the target has a protection move
    protection_moves = [
      "ProtectUser",                                       # Detect, Protect
      "ProtectUserSideFromPriorityMoves",                  # Quick Guard
      "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard
      "UserEnduresFaintingThisTurn",                       # Endure
      "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
      "ProtectUserSideFromStatusMoves",                    # Crafty Shield
      "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
      "ProtectUserFromDamagingMovesObstruct",              # Obstruct
      "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
      "ProtectUserBanefulBunker"                           # Baneful Bunker
    ]
    if target.check_for_move { |m| m.statusMove? && protection_moves.include?(m.function_code) }
      score += 10
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("DisableTargetHealingMoves",
  proc { |score, move, user, target, ai, battle|
    # Useless if the foe can't heal themselves with a move or some held items
    if !target.check_for_move { |m| m.healingMove? }
      if !target.has_active_item?(:LEFTOVERS) &&
         !(target.has_active_item?(:BLACKSLUDGE) && (target.has_type?(:POISON) || 
		                                             target.has_type?(:MIASMA18))) 
        next Battle::AI::MOVE_USELESS_SCORE
      end
    end
    # Inherent preference
    score += 10
    next score
  }
)