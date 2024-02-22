#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Adds in checks for Lightning Rod and Storm Drain with Touhoumon types
#==============================================================================#
class Battle::Battler
  def pbChangeTargets(move, user, targets)
    target_data = move.pbTarget(user)
    return targets if @battle.switching   # For Pursuit interrupting a switch
    return targets if move.cannotRedirect? || move.targetsPosition?
    return targets if !target_data.can_target_one_foe? || targets.length != 1
    move.pbModifyTargets(targets, user)   # For Dragon Darts
    return targets if user.hasActiveAbility?([:PROPELLERTAIL, :STALWART])
    priority = @battle.pbPriority(true)
    nearOnly = !target_data.can_choose_distant_target?
    # Spotlight (takes priority over Follow Me/Rage Powder/Lightning Rod/Storm Drain)
    newTarget = nil
    strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop] >= 0
      next if b.effects[PBEffects::Spotlight] == 0 ||
              b.effects[PBEffects::Spotlight] >= strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::Spotlight]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
      targets = []
      pbAddTarget(targets, user, newTarget, move, nearOnly)
      return targets
    end
    # Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
    newTarget = nil
    strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop] >= 0
      next if b.effects[PBEffects::RagePowder] && !user.affectedByPowder?
      next if b.effects[PBEffects::FollowMe] == 0 ||
              b.effects[PBEffects::FollowMe] >= strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::FollowMe]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
      targets = []
      pbAddTarget(targets, user, newTarget, move, nearOnly)
      return targets
    end
    # Lightning Rod
    targets = pbChangeTargetByAbility(:LIGHTNINGROD, :ELECTRIC, move, user, targets, priority, nearOnly)
	targets = pbChangeTargetByAbility(:LIGHTNINGROD, :WIND18, move, user, targets, priority, nearOnly) # Derx: Not canon but, shrug!
    # Storm Drain
    targets = pbChangeTargetByAbility(:STORMDRAIN, :WATER, move, user, targets, priority, nearOnly)
	targets = pbChangeTargetByAbility(:STORMDRAIN, :WATER18, move, user, targets, priority, nearOnly) # Derx: Not canon but, shrug!
    return targets
  end
end


