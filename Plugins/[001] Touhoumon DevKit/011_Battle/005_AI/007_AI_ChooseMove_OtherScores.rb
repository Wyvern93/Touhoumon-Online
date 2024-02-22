#==============================================================================#
# Changes in this section include the following:
#	* Added the Touhoumon Choice Items to the relevant areas
#==============================================================================#
Battle::AI::Handlers::GeneralMoveScore.add(:good_move_for_choice_item,
  proc { |score, move, user, ai, battle|
    next score if !ai.trainer.medium_skill?
    next score if !user.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, 
	                                      :BLOOMERS, :POWERRIBBON, :POWERGOGGLES, :POWERCAPE]) &&
                  !user.has_active_ability?(:GORILLATACTICS)
    old_score = score
    # Really don't prefer status moves (except Trick)
    if move.statusMove? && move.function_code != "UserTargetSwapItems"
      score -= 25
      PBDebug.log_score_change(score - old_score, "don't want to be Choiced into a status move")
      next score
    end
    # Don't prefer moves which are 0x against at least one type
    move_type = move.rough_type
    GameData::Type.each do |type_data|
      score -= 8 if type_data.immunities.include?(move_type)
    end
    # Don't prefer moves with lower accuracy
    if move.accuracy > 0
      score -= (0.4 * (100 - move.accuracy)).to_i   # -0 (100%) to -39 (1%)
    end
    # Don't prefer moves with low PP
    score -= 10 if move.move.pp <= 5
    PBDebug.log_score_change(score - old_score, "move is less suitable to be Choiced into")
    next score
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Added Pyro type avoidance to Powder checks
#==============================================================================#
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_can_powder_fire_moves,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.high_skill? && (move.rough_type == :FIRE || move.rough_type == :FIRE18) &&
       target.has_move_with_function?("TargetNextFireMoveDamagesTarget") &&
       target.faster_than?(user)
      old_score = score
      score -= 5   # Only 5 because we're not sure target will use Powder
      PBDebug.log_score_change(score - old_score, "target knows Powder and could negate Fire moves")
    end
    next score
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Added Advent to ability checks for preventing flinching
#==============================================================================#
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:external_flinching_effects,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && move.damagingMove? && !move.move.flinchingMove? &&
       user.faster_than?(target) && target.effects[PBEffects::Substitute] == 0
      if user.has_active_item?([:KINGSROCK, :RAZORFANG]) ||
         user.has_active_ability?(:STENCH)
        if battle.moldBreaker || !target.has_active_ability?([:INNERFOCUS, :SHIELDDUST, :ADVENT])
          old_score = score
          score += 8
          score += 5 if move.move.multiHitMove?
          PBDebug.log_score_change(score - old_score, "added chance to cause flinching")
        end
      end
    end
    next score
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Added a check to prevent using Pyro moves against Frozen targets
#==============================================================================#
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:thawing_move_against_frozen_target,
  proc { |score, move, user, target, ai, battle|
    if ai.trainer.medium_skill? && target.status == :FROZEN
      if (move.rough_type == :FIRE || move.rough_type == :FIRE18) || (Settings::MECHANICS_GENERATION >= 6 && move.move.thawsUser?)
        old_score = score
        score -= 20
        PBDebug.log_score_change(score - old_score, "thaws the target")
      end
    end
    next score
  }
)