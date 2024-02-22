class Scene_Credits
  BGM                    = "W-012. Hourai Illusion ~ Far East.ogg"
  
  def get_text
    ret = Settings.game_credits || []
    # Add plugin credits
    if PluginManager.plugins.length > 0
      ret.push("")
      PluginManager.plugins.each do |plugin|
        pcred = PluginManager.credits(plugin)
        ret.push(_INTL("--- \"{1}\" v.{2} ---", plugin, PluginManager.version(plugin)))
        add_names_to_credits(ret, pcred)
      end
    end
    # Add Essentials credits
	ret.push("", "", "")
    ret.push(_INTL("\"Pokémon Essentials\" was created by:"))
    add_names_to_credits(ret, [
      "Poccil (Peter O.)",
      "Maruno",
      _INTL("Inspired by work by Flameguru")
    ])
    ret.push(_INTL("With contributions from:"))
    add_names_to_credits(ret, [
      "AvatarMonkeyKirby", "Boushy", "Brother1440", "FL.", "Genzai Kawakami",
      "Golisopod User", "help-14", "IceGod64", "Jacob O. Wobbrock", "KitsuneKouta",
      "Lisa Anthony", "Luka S.J.", "Marin", "MiDas Mike", "Near Fantastica",
      "PinkMan", "Popper", "Rataime", "Savordez", "SoundSpawn",
      "the__end", "Venom12", "Wachunga"
    ], false)
    ret.push(_INTL("and everyone else who helped out"))
    ret.push("")
    ret.push(_INTL("\"mkxp-z\" by:"))
    add_names_to_credits(ret, [
      "Roza",
      _INTL("Based on \"mkxp\" by Ancurio et al.")
    ])
    ret.push(_INTL("\"RPG Maker XP\" by:"))
    add_names_to_credits(ret, ["Enterbrain"])
    ret.push(_INTL("Pokémon is owned by:"))
    add_names_to_credits(ret, [
      "The Pokémon Company",
      "Nintendo",
      _INTL("Affiliated with Game Freak")
    ])
    ret.push("", "")
    ret.push(_INTL("This is a non-profit fan-made game."),
             _INTL("No copyright infringements intended."),
             _INTL("Please support the official games!"))
	ret.push("", "")
	ret.push(_INTL("Touhoumon Development Kit"))
	add_names_to_credits(ret, [
	  "2011-2023<s>DerxwnaKapsyla",
	  "2012-2022<s>ChaoticInfinity Development",
	  "2020-2023<s>Overseer Household",
	  _INTL("Based on Pokémon Essentials")
	  ])
	ret.push("", "")
	ret.push(_INTL("Pokémon Essentials"))
	add_names_to_credits(ret, [
	  "2007-2010<s>Peter O.",
	  "2011-2023<s>Maruno",
	  _INTL("Based on work by Flameguru")
	  ])
    return ret
  end
end