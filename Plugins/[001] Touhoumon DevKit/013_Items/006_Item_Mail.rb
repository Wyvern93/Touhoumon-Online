#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removed explicit references to Pokemon
#==============================================================================#
def pbStoreMail(pkmn, item, message, poke1 = nil, poke2 = nil, poke3 = nil)
  raise _INTL("They already have mail") if pkmn.mail
  pkmn.mail = Mail.new(item, message, $player.name, poke1, poke2, poke3)
end

def pbWriteMail(item, pkmn, pkmnid, scene)
  message = ""
  loop do
    message = pbMessageFreeText(_INTL("Please enter a message (max. 250 characters)."),
                                "", false, 250, Graphics.width) { scene.pbUpdate }
    if message != ""
      # Store mail if a message was written
      poke1 = poke2 = nil
      if $player.party[pkmnid + 2]
        p = $player.party[pkmnid + 2]
        poke1 = [p.species, p.gender, p.shiny?, p.form, p.shadowPokemon?]
        poke1.push(true) if p.egg?
      end
      if $player.party[pkmnid + 1]
        p = $player.party[pkmnid + 1]
        poke2 = [p.species, p.gender, p.shiny?, p.form, p.shadowPokemon?]
        poke2.push(true) if p.egg?
      end
      poke3 = [pkmn.species, pkmn.gender, pkmn.shiny?, pkmn.form, pkmn.shadowPokemon?]
      poke3.push(true) if pkmn.egg?
      pbStoreMail(pkmn, item, message, poke1, poke2, poke3)
      return true
    end
    return false if scene.pbConfirm(_INTL("Stop giving them Mail?"))
  end
end
