#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Text changes to remove explicit references to Pokemon
#==============================================================================#
class Battle::Battler
  def pbInitDummyPokemon(pkmn, idxParty)
    raise _INTL("An egg can't be an active battler.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @types        = pkmn.types
    # ability and item intentionally not copied across here
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []
    # moves intentionally not copied across here
    @dummy        = true
  end

  def pbInitialize(pkmn, idxParty, batonPass = false)
    pbInitPokemon(pkmn, idxParty)
    pbInitEffects(batonPass)
    @damageState.reset
  end

  def pbInitPokemon(pkmn, idxParty)
    raise _INTL("An egg can't be an active battler.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @types        = pkmn.types
    @ability_id   = pkmn.ability_id
    @item_id      = pkmn.item_id
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []   # Participants earn Exp. if this battler is defeated
    @moves        = []
    pkmn.moves.each_with_index do |m, i|
      @moves[i] = Battle::Move.from_pokemon_move(@battle, m)
    end
  end
end