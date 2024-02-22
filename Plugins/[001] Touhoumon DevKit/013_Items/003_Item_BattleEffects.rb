#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removed explicit references to Pokemon
#	* Added in new items for Touhoumon mechanics
#	* Added in custom items not in Touhoumon
#	* Made tweaks to existing items
#	* Added in a check to the Battle Rule for no capture to display an alt line
#==============================================================================#

ItemHandlers::CanUseInBattle.copy(:POTION, :POTATO)
ItemHandlers::CanUseInBattle.copy(:FULLHEAL, :GRILLEDLAMPREY)

# ------ Liquid Revive: Max Elixir + Max Revive
ItemHandlers::CanUseInBattle.add(:LIQUIDREVIVE, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if pokemon.able? || pokemon.egg?
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
  canRestore = false
  pokemon.moves.each do |m|
    next if m.id == 0
    next if m.total_pp <= 0 || m.pp == m.total_pp
    canRestore = true
    break
  end
  next true
})
# ------ Derx: End of Liquid Revive code

ItemHandlers::CanUseInBattle.add(:BAKEDPOTATO, proc { |item, pokemon, battler, move, firstAction, battle, scene, showMessages|
  if !pokemon.able? || (pokemon.hp == pokemon.totalhp ||
                       (pokemon.status == :NONE &&
                       (!battler || battler.effects[PBEffects::Confusion] == 0)))
    scene.pbDisplay(_INTL("It won't have any effect.")) if showMessages
    next false
  end
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  pbSEPlay("Battle Flee")
  battle.pbDisplayPaused(_INTL("You got away safely!"))
})

ItemHandlers::UseInBattle.add(:POKEFLUTE, proc { |item, battler, battle|
  battle.allBattlers.each do |b|
    b.pbCureStatus(false) if b.status == :SLEEP && !b.hasActiveAbility?(:SOUNDPROOF)
  end
  battle.pbDisplay(_INTL("All active battlers were roused by the tune!"))
})

ItemHandlers::BattleUseOnPokemon.copy(:FULLHEAL, :GRILLEDLAMPREY)

# ------ Liquid Revive: Max Elixir + Max Revive
ItemHandlers::BattleUseOnPokemon.add(:LIQUIDREVIVE, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_HP
  pokemon.heal_status
  pokemon.moves.length.times do |i|
    pbBattleRestorePP(pokemon, battler, i, pokemon.moves[i].total_pp)
  end
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was fully revitalized!", pokemon.name))
})
# ------ Derx: End of Liquid Revive code


ItemHandlers::BattleUseOnPokemon.add(:POTATO, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 20, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:BAKEDPOTATO, proc { |item, pokemon, battler, choices, scene|
  pokemon.heal_status
  battler&.pbCureStatus(false)
  battler&.pbCureConfusion
  name = (battler) ? battler.pbThis : pokemon.name
  if pokemon.hp < pokemon.totalhp
	pbBattleHPItem(pokemon, battler, pokemon.totalhp / 4, scene)
  else
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} became healthy.", name))
  end
})