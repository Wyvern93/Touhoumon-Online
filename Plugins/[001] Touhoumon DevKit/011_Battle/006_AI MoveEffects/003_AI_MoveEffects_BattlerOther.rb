Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("SleepTarget",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? Battle::AI::MOVE_USELESS_SCORE : score
    next useless_score if target.effects[PBEffects::Yawn] > 0   # Target is going to fall asleep anyway
    # No score modifier if the sleep will be removed immediately
    next useless_score if target.has_active_item?([:CHESTOBERRY, :LUMBERRY, :BAKEDPOTATO])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanSleep?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the user or an ally has a move/ability that is better if the target is asleep
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetAsleepCureTarget",
                                                "DoublePowerIfTargetStatusProblem",
                                                "HealUserByHalfOfDamageDoneIfTargetAsleep",
                                                "StartDamageTargetEachTurnIfTargetAsleep")
        score += 10 if b.has_active_ability?(:BADDREAMS)
      end
      # Don't prefer if target benefits from having the sleep status problem
      # NOTE: The target's Guts/Quick Feet will benefit from the target being
      #       asleep, but the target won't (usually) be able to make use of
      #       them, so they're not worth considering.
      score -= 10 if target.has_active_ability?(:EARLYBIRD)
      score -= 8 if target.has_active_ability?([:MARVELSCALE, :SPRINGCHARM])
      # Don't prefer if target has a move it can use while asleep
      score -= 8 if target.check_for_move { |m| m.usableWhenAsleep? }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)


Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("PoisonTarget",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? Battle::AI::MOVE_USELESS_SCORE : score
    next useless_score if target.has_active_ability?(:POISONHEAL)
    # No score modifier if the poisoning will be removed immediately
    next useless_score if target.has_active_item?([:PECHABERRY, :LUMBERRY, :BAKEDPOTATO])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanPoison?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the target is at high HP
      if ai.trainer.has_skill_flag?("HPAware")
        score += 15 * target.hp / target.totalhp
      end
      # Prefer if the user or an ally has a move/ability that is better if the target is poisoned
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetPoisoned",
                                                "DoublePowerIfTargetStatusProblem")
        score += 10 if b.has_active_ability?(:MERCILESS)
      end
      # Don't prefer if target benefits from having the poison status problem
      score -= 8 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :TOXICBOOST, :SPRINGCHARM])
      score -= 25 if target.has_active_ability?(:POISONHEAL)
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanPoisonSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed",
                                                   "CureUserBurnPoisonParalysis")
      score -= 15 if target.check_for_move { |m|
        m.function_code == "GiveUserStatusToTarget" && user.battler.pbCanPoison?(target.battler, false, m)
      }
      # Don't prefer if the target won't take damage from the poison
      score -= 20 if !target.battler.takesIndirectDamage?
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)


Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("ParalyzeTarget",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? Battle::AI::MOVE_USELESS_SCORE : score
    # No score modifier if the paralysis will be removed immediately
    next useless_score if target.has_active_item?([:CHERIBERRY, :LUMBERRY, :BAKEDPOTATO])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanParalyze?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference (because of the chance of full paralysis)
      score += 10
      # Prefer if the target is faster than the user but will become slower if
      # paralysed
      if target.faster_than?(user)
        user_speed = user.rough_stat(:SPEED)
        target_speed = target.rough_stat(:SPEED)
        score += 15 if target_speed < user_speed * ((Settings::MECHANICS_GENERATION >= 7) ? 2 : 4)
      end
      # Prefer if the target is confused or infatuated, to compound the turn skipping
      score += 7 if target.effects[PBEffects::Confusion] > 1
      score += 7 if target.effects[PBEffects::Attract] >= 0
      # Prefer if the user or an ally has a move/ability that is better if the target is paralysed
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetParalyzedCureTarget",
                                                "DoublePowerIfTargetStatusProblem")
      end
      # Don't prefer if target benefits from having the paralysis status problem
      score -= 8 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :SPRINGCHARM])
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanParalyzeSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed",
                                                   "CureUserBurnPoisonParalysis")
      score -= 15 if target.check_for_move { |m|
        m.function_code == "GiveUserStatusToTarget" && user.battler.pbCanParalyze?(target.battler, false, m)
      }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("BurnTarget",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? Battle::AI::MOVE_USELESS_SCORE : score
    # No score modifier if the burn will be removed immediately
    next useless_score if target.has_active_item?([:RAWSTBERRY, :LUMBERRY, :BAKEDPOTATO])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanBurn?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the target knows any physical moves that will be weaked by a burn
      if !target.has_active_ability?(:GUTS) && target.check_for_move { |m| m.physicalMove? }
        score += 8
        score += 8 if !target.check_for_move { |m| m.specialMove? }
      end
      # Prefer if the user or an ally has a move/ability that is better if the target is burned
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetStatusProblem")
      end
      # Don't prefer if target benefits from having the burn status problem
      score -= 8 if target.has_active_ability?([:FLAREBOOST, :GUTS, :MARVELSCALE, :QUICKFEET, :SPRINGCHARM])
      score -= 5 if target.has_active_ability?(:HEATPROOF)
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanBurnSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("DoublePowerIfUserPoisonedBurnedParalyzed",
                                                   "CureUserBurnPoisonParalysis")
      score -= 15 if target.check_for_move { |m|
        m.function_code == "GiveUserStatusToTarget" && user.battler.pbCanBurn?(target.battler, false, m)
      }
      # Don't prefer if the target won't take damage from the burn
      score -= 20 if !target.battler.takesIndirectDamage?
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("FreezeTarget",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? Battle::AI::MOVE_USELESS_SCORE : score
    # No score modifier if the freeze will be removed immediately
    next useless_score if target.has_active_item?([:ASPEARBERRY, :LUMBERRY, :BAKEDPOTATO])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanFreeze?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the user or an ally has a move/ability that is better if the target is frozen
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetStatusProblem")
      end
      # Don't prefer if target benefits from having the frozen status problem
      # NOTE: The target's Guts/Quick Feet will benefit from the target being
      #       frozen, but the target won't be able to make use of them, so
      #       they're not worth considering.
      score -= 8 if target.has_active_ability?([:MARVELSCALE, :SPRINGCHARM])
      # Don't prefer if the target knows a move that can thaw it
      score -= 15 if target.check_for_move { |m| m.thawsUser? }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("ParalyzeBurnOrFreezeTarget",
  proc { |score, move, user, target, ai, battle|
    # No score modifier if the status problem will be removed immediately
    next score if target.has_active_item?([:LUMBERRY, :BAKEDPOTATO])
    next score if target.faster_than?(user) &&
                  target.has_active_ability?(:HYDRATION) &&
                  [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    # Scores for the possible effects
    ["ParalyzeTarget", "BurnTarget", "FreezeTarget"].each do |function_code|
      effect_score = Battle::AI::Handlers.apply_move_effect_against_target_score(function_code,
         0, move, user, target, ai, battle)
      score += effect_score / 3 if effect_score != Battle::AI::MOVE_USELESS_SCORE
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("AttractTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanAttract?(user.battler, false)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
	  # Prefer if the user has the ability Diva, which will cause attraction regardless
      score += 15 if user.has_active_ability?(:DIVA)
      # Prefer if the target is paralysed or confused, to compound the turn skipping
      score += 8 if target.status == :PARALYSIS || target.effects[PBEffects::Confusion] > 1
      # Don't prefer if the target can infatuate the user because of this move
      score -= 15 if target.has_active_item?(:DESTINYKNOT) &&
                     user.battler.pbCanAttract?(target.battler, false)
      # Don't prefer if the user has another way to infatuate the target
      score -= 15 if move.statusMove? && user.has_active_ability?(:CUTECHARM)
    end
    next score
  }
)


Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("UserTargetSwapAbilities",
  proc { |move, user, target, ai, battle|
    next true if !user.ability || user.battler.unstoppableAbility? ||
                 user.battler.ungainableAbility? || (user.ability_id == :WONDERGUARD || 
				                                     user.ability_id == :PLAYGHOST)
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartUserAirborne",
  proc { |score, move, user, ai, battle|
    # Move is useless if user is already airborne
    if user.has_type?(:FLYING) ||
	   user.has_type?(:FLYING18) ||
       user.has_active_ability?(:LEVITATE) ||
       user.has_active_item?(:AIRBALLOON) ||
       user.effects[PBEffects::Telekinesis] > 0
      next Battle::AI::MOVE_USELESS_SCORE
    end
    # Prefer if any foes have damaging Ground-type moves that do 1x or more
    # damage to the user
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:GROUND)
	  next if !b.has_damaging_move_of_type?(:EARTH18)
      next if Effectiveness.resistant?(user.effectiveness_of_type_against_battler(:GROUND, b))
	  next if Effectiveness.resistant?(user.effectiveness_of_type_against_battler(:EARTH18, b))
      score += 10
    end
    # Don't prefer if terrain exists (which the user will no longer be affected by)
    if ai.trainer.medium_skill?
      score -= 8 if battle.field.terrain != :None
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("StartTargetAirborneAndAlwaysHitByMoves",
  proc { |score, move, user, target, ai, battle|
    # Move is useless if the target is already airborne
    if target.has_type?(:FLYING) ||
       target.has_type?(:FLYING18) ||
	   target.has_active_ability?(:LEVITATE) ||
       target.has_active_item?(:AIRBALLOON)
      next Battle::AI::MOVE_USELESS_SCORE
    end
    # Prefer if any allies have moves with accuracy < 90%
    # Don't prefer if any allies have damaging Ground-type moves that do 1x or
    # more damage to the target
    ai.each_foe_battler(target.side) do |b, i|
      b.battler.eachMove do |m|
        acc = m.accuracy
        acc = m.pbBaseAccuracy(b.battler, target.battler) if ai.trainer.medium_skill?
        score += 5 if acc < 90 && acc != 0
        score += 5 if acc <= 50 && acc != 0
      end
      next if !b.has_damaging_move_of_type?(:GROUND)
	  next if !b.has_damaging_move_of_type?(:EARTH18)
      next if Effectiveness.resistant?(target.effectiveness_of_type_against_battler(:GROUND, b))
	  next if Effectiveness.resistant?(target.effectiveness_of_type_against_battler(:EARTH18, b))
      score -= 7
    end
    # Prefer if terrain exists (which the target will no longer be affected by)
    if ai.trainer.medium_skill?
      score += 8 if battle.field.terrain != :None
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("HitsTargetInSkyGroundsTarget",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::Substitute] > 0
    if !target.battler.airborne?
      next score if target.faster_than?(user) ||
                    !target.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                                     "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
    end
    # Prefer if the target is airborne
    score += 10
    # Prefer if any allies have damaging Ground-type moves
    ai.each_foe_battler(target.side) do |b, i|
      score += 8 if (b.has_damaging_move_of_type?(:GROUND)
	                 b.has_damaging_move_of_type?(:EARTH18))
    end
    # Don't prefer if terrain exists (which the target will become affected by)
    if ai.trainer.medium_skill?
      score -= 8 if battle.field.terrain != :None
    end
    next score
  }
)

Battle::AI::Handlers::MoveEffectScore.add("StartGravity",
  proc { |score, move, user, ai, battle|
    ai.each_battler do |b, i|
      # Prefer grounding airborne foes, don't prefer grounding airborne allies
      # Prefer making allies affected by terrain, don't prefer making foes
      # affected by terrain
      if b.battler.airborne?
        score_change = 10
        if ai.trainer.medium_skill?
          score_change -= 8 if battle.field.terrain != :None
        end
        score += (user.opposes?(b)) ? score_change : -score_change
        # Prefer if allies have any damaging Ground moves they'll be able to use
        # on a grounded foe, and vice versa
        ai.each_foe_battler(b.side) do |b2, j|
          next if (!b2.has_damaging_move_of_type?(:GROUND) ||
		           !b2.has_damaging_move_of_type?(:EARTH18))
          score += (user.opposes?(b2)) ? -8 : 8
        end
      end
      # Prefer ending Sky Drop being used on allies, don't prefer ending Sky
      # Drop being used on foes
      if b.effects[PBEffects::SkyDrop] >= 0
        score += (user.opposes?(b)) ? -8 : 8
      end
      # Gravity raises accuracy of all moves; prefer if the user/ally has low
      # accuracy moves, don't prefer if foes have any
      if b.check_for_move { |m| m.accuracy < 85 }
        score += (user.opposes?(b)) ? -8 : 8
      end
      # Prefer stopping foes' sky-based attacks, don't prefer stopping allies'
      # sky-based attacks
      if user.faster_than?(b) &&
         b.battler.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                    "TwoTurnAttackInvulnerableInSkyParalyzeTarget",
                                    "TwoTurnAttackInvulnerableInSkyTargetCannotAct")
        score += (user.opposes?(b)) ? 10 : -10
      end
    end
    next score
  }
)


Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("UserCopiesMovesWithoutTransforming",
  proc { |move, user, target, ai, battle|
    next true if user.effects[PBEffects::Transform]
    next true if target.effects[PBEffects::Transform] ||
                 target.effects[PBEffects::Illusion]
    next false
  }
)
Battle::AI::Handlers::MoveEffectAgainstTargetScore.add("UserCopiesMovesWithoutTransforming",
  proc { |score, move, user, target, ai, battle|
    next score - 5
  }
)