class PokemonSummary_Scene
  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
	statshadow = Color.new(176, 176, 176)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
	statdatashadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
	GameData::Stat.each_main { |s| statdatashadows[s.id] = statshadow }

    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(136, 96, 72) if change[1] > 0
        statshadows[change[0]] = Color.new(64, 120, 152) if change[1] < 0
		
		statdatashadows[change[0]] = Color.new(176, 136, 112) if change[1] > 0
        statdatashadows[change[0]] = Color.new(104, 160, 192) if change[1] < 0
      end
    end
	
	ev_total = 0
    # Write various bits of text
    textpos = [
	  [_INTL("Base"), 402, 64, :center, base, shadow],
      [_INTL("EV"), 494, 64, :center, base, shadow],
	  [_INTL("IV"), 448, 64, :center, base, shadow],
	  
      [_INTL("HP"), 247, 94, :left, base, shadow],
	  [@pokemon.totalhp.to_s, 368, 94, :right, Color.new(64, 64, 64), statdatashadows[:HP]],
	  [sprintf("%d", @pokemon.baseStats[:HP]), 424, 94, :right, Color.new(64, 64, 64), statdatashadows[:HP]],
      [sprintf("%d", @pokemon.iv[:HP]), 460, 94, :right, Color.new(64, 64, 64), statdatashadows[:HP]],
      [sprintf("%d", @pokemon.ev[:HP]), 512, 94, :right, Color.new(64, 64, 64), statdatashadows[:HP]],
	  
      [_INTL("Atk"), 248, 126, :left, base, statshadows[:ATTACK]],
      #[@pokemon.attack.to_s, 456, 126, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
	  [@pokemon.attack.to_s, 368, 126, :right, Color.new(64, 64, 64), statdatashadows[:ATTACK]],
	  [sprintf("%d", @pokemon.baseStats[:ATTACK]), 424, 126, :right, Color.new(64, 64, 64), statdatashadows[:ATTACK]],
      [sprintf("%d", @pokemon.iv[:ATTACK]), 460, 126, :right, Color.new(64, 64, 64), statdatashadows[:ATTACK]],
      [sprintf("%d", @pokemon.ev[:ATTACK]), 512, 126, :right, Color.new(64, 64, 64), statdatashadows[:ATTACK]],
	  
      [_INTL("Def"), 248, 158, :left, base, statshadows[:DEFENSE]],
      #[@pokemon.defense.to_s, 456, 158, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
	  [@pokemon.defense.to_s, 368, 158, :right, Color.new(64, 64, 64), statdatashadows[:DEFENSE]],
	  [sprintf("%d", @pokemon.baseStats[:DEFENSE]), 424, 158, :right, Color.new(64, 64, 64), statdatashadows[:DEFENSE]],
      [sprintf("%d", @pokemon.iv[:DEFENSE]), 460, 158, :right, Color.new(64, 64, 64), statdatashadows[:DEFENSE]],
      [sprintf("%d", @pokemon.ev[:DEFENSE]), 512, 158, :right, Color.new(64, 64, 64), statdatashadows[:DEFENSE]],
	  
      [_INTL("Sp. Atk"), 248, 190, :left, base, statshadows[:SPECIAL_ATTACK]],
      #[@pokemon.spatk.to_s, 456, 190, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
	  [@pokemon.spatk.to_s, 368, 190, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_ATTACK]],
	  [sprintf("%d", @pokemon.baseStats[:SPECIAL_ATTACK]), 424, 190, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_ATTACK]],
      [sprintf("%d", @pokemon.iv[:SPECIAL_ATTACK]), 460, 190, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_ATTACK]],
      [sprintf("%d", @pokemon.ev[:SPECIAL_ATTACK]), 512, 190, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_ATTACK]],
	  
      [_INTL("Sp. Def"), 248, 222, :left, base, statshadows[:SPECIAL_DEFENSE]],
      #[@pokemon.spdef.to_s, 456, 222, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
	  [@pokemon.spdef.to_s, 368, 222, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_DEFENSE]],
	  [sprintf("%d", @pokemon.baseStats[:SPECIAL_DEFENSE]), 424, 222, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_DEFENSE]],
      [sprintf("%d", @pokemon.iv[:SPECIAL_DEFENSE]), 460, 222, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_DEFENSE]],
      [sprintf("%d", @pokemon.ev[:SPECIAL_DEFENSE]), 512, 222, :right, Color.new(64, 64, 64), statdatashadows[:SPECIAL_DEFENSE]],
	  
      [_INTL("Speed"), 248, 254, :left, base, statshadows[:SPEED]],
      #[@pokemon.speed.to_s, 456, 254, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)],
	  [@pokemon.speed.to_s, 368, 254, :right, Color.new(64, 64, 64), statdatashadows[:SPEED]],
	  [sprintf("%d", @pokemon.baseStats[:SPEED]), 424, 254, :right, Color.new(64, 64, 64), statdatashadows[:SPEED]],
      [sprintf("%d", @pokemon.iv[:SPEED]), 460, 254, :right, Color.new(64, 64, 64), statdatashadows[:SPEED]],
      [sprintf("%d", @pokemon.ev[:SPEED]), 512, 254, :right, Color.new(64, 64, 64), statdatashadows[:SPEED]],
	  
      [_INTL("Ability"), 224, 290, :left, base, shadow],
	  
	  [_INTL("Total EV"), 580, 252, :left, base, shadow],
      [sprintf("%d/%d", ev_total, Pokemon::EV_LIMIT), 622, 284, :center, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Hidden Power"), 664, 316, :right, base, shadow]
    ]
    # Draw ability name and description
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name, 362, 290, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      drawTextEx(overlay, 224, 322, 282, 2, ability.description, Color.new(64, 64, 64), Color.new(176, 176, 176))
    end
	
	# Draw Hidden Power
	hiddenpower = pbHiddenPower(@pokemon)
    type_number = GameData::Type.get(hiddenpower[0]).icon_position
    type_rect = Rect.new(0, type_number * 28, 64, 28)
    overlay.blt(568, 342, @typebitmap.bitmap, type_rect)
	
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw HP bar
    if @pokemon.hp > 0
      w = @pokemon.hp * 96 / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      imagepos = [
        ["Graphics/UI/Summary/overlay_hp", 264, 70, 0, hpzone * 6, w, 6]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
  end
 end