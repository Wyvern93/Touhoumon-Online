Battle::AI::Handlers::MoveFailureAgainstTargetCheck.add("TwoTurnAttackInvulnerableInSkyTargetCannotAct",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user)
    next true if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
    next true if target.has_type?(:FLYING)
	next true if target.has_type?(:FLYING18)
    next true if Settings::MECHANICS_GENERATION >= 6 && target.battler.pbWeight >= 2000   # 200.0kg
    next true if target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    next false
  }
)