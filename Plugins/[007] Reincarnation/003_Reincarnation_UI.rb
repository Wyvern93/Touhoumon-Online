module Reincarnation

  module_function

  def show_reincarnation_scene
    return false if !can_reincarnate?
    pbFadeOutInWithMusic {
      audio_file = "Audio/BGM/#{Reincarnation::CUSTOM_SCENE_BGM}"
      pbBGMPlay(Reincarnation::CUSTOM_SCENE_BGM) if pbStringToAudioFile(audio_file)
      scene = Reincarnation_UI.new
      scene.start_scene
      scene.main
      scene.end_scene
    }
  end
end

class Reincarnation_UI
  
  GRAPHICS_FILE_PATH = "Graphics/Pictures/Reincarnation/"

  CURSOR_SE = "GUI party switch"

  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHDW_COLOR = Color.new(48, 48, 48)

  class Button < Sprite

    TEXT_BASE_COLOR = Reincarnation_UI::TEXT_BASE_COLOR
    TEXT_SHDW_COLOR = Reincarnation_UI::TEXT_SHDW_COLOR

    def initialize(*args)
      super(*args)
      @icon_sprite = nil
      @text_sprite = nil
      @selected    = false
      @x_offset    = 100
      @default_txt = ""
      @text        = ""
    end

    def update(*args)
      super(*args)
      return if !@icon_sprite || @icon_sprite.disposed?
      @icon_sprite.x       = self.x + 8
      @icon_sprite.y       = self.y + (self.bitmap.height / 2)
      @icon_sprite.z       = self.z + 1
      @icon_sprite.color   = self.color
      @icon_sprite.tone    = self.tone
      @icon_sprite.opacity = self.opacity
      @icon_sprite.color   = self.color
      @icon_sprite.visible = self.visible && @selected
      @icon_sprite.update
      @text_sprite.x       = self.x + (@selected ? 80 : 16)
      @text_sprite.y       = self.y
      @text_sprite.z       = self.z + 1
      @text_sprite.color   = self.color
      @text_sprite.tone    = self.tone
      @text_sprite.opacity = self.opacity
      @text_sprite.color   = self.color
      @text_sprite.visible = self.visible
      @text_sprite.update
    end

    def pokemon=(value)
      @icon_sprite&.dispose
      @icon_sprite  = PokemonIconSprite.new(value, self.viewport)
      @icon_sprite.setOffset(PictureOrigin::LEFT)
      @text         = touhou_name(value)
      self.selected = @selected
      self.update
    end

    def item=(value)
      @icon_sprite&.dispose
      @icon_sprite = ItemIconSprite.new(self.x, self.y, value, self.viewport)
      @text        = GameData::Item.try_get(value)&.name || @default_text
      @icon_sprite.blankzero = true
      @icon_sprite.bitmap = RPG::Cache.load_bitmap("Graphics/Items/", "000") if !@icon_sprite.bitmap
      @icon_sprite.setOffset(PictureOrigin::LEFT)
      self.selected = @selected
      self.update
    end

    def color=(value)
      super(value)
      @icon_sprite.color = value
      @text_sprite.color = value
    end

    def tone=(value)
      super(value)
      @icon_sprite.tone = value
      @text_sprite.tone = value
    end

    def selected=(value)
      old_offset = @x_offset
      @selected  = value
      @x_offset  = value ? 0 : 100
      self.x     = self.x - old_offset
      if @text_sprite
        @text_sprite.bitmap.clear
        pbSetSystemFont(@text_sprite.bitmap)
        pbDrawTextPositions(@text_sprite.bitmap, [[@text, 0, 12, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR]])
      end
      self.update
    end

    def default_text=(value)
      @default_text = value
      @text         = value
      return if @text_sprite
      @text_sprite = BitmapSprite.new(self.bitmap.width, self.bitmap.height, self.viewport)
    end

    def x=(value); super(value + @x_offset); end

    def touhou_name(pkmn)
      return @default_text if !pkmn
      return "#{pkmn.name}" if pkmn.genderless?
      if pkmn.species_data.has_flag?("Puppet")
        return "#{pkmn.name} ²" if pkmn.female?
        return "#{pkmn.name} ¹"
      else
        return "#{pkmn.name} ♀" if pkmn.female?
        return "#{pkmn.name} ♂"
      end
    end

    def dispose(*args)
      super(*args)
      @icon_sprite&.dispose
      @text_sprite&.dispose
    end
  end

  def update; pbUpdateSpriteHash(@sprites); end

  def end_scene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @bitmap_f.dispose
    @bitmap_d.dispose
    @bitmap_c.dispose
    @bitmap_b.dispose
    @bitmap_a.dispose
    @bitmap_s.dispose
  end
  
  def start_scene
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @index      = 0
    @recipient  = nil
    @party_idx  = -1
    @donor_1    = nil
    @donor_2    = nil
    @rein_boon  = nil
    @rein_bane  = nil
    @rein_stone = nil
    @sprites    = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(GRAPHICS_FILE_PATH + "bg")

    # :Move all sprites down 5 px:
    @sprites["overlay_sigil"] = IconSprite.new(-30, 30, @viewport)
    @sprites["overlay_sigil"].setBitmap(GRAPHICS_FILE_PATH + "overlay_sigil")
    @sprites["overlay_sigil"].visible = true

    button_arr = ["recipient", "donor_1", "donor_2", "stat_boon", "stat_bane", "stat_mod"]
    text_arr   = [_INTL("Recipient"), _INTL("Donor 1"), _INTL("Donor 2"), _INTL("Stat Boon"), _INTL("Stat Bane"), _INTL("Stat Mod")]

    button_arr.each_with_index do |file, i|
      key = "button_#{i + 1}"
      @sprites[key] = Button.new(@viewport)
      @sprites[key].x = 266
      @sprites[key].y = 35 + (i * 50)
      @sprites[key].bitmap = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "button_#{file}")
      @sprites[key].visible = true
      @sprites[key].default_text = text_arr[i] 
      @sprites[key].update 
      if i < 3
        @sprites[key].pokemon = nil
      else
        @sprites[key].item = nil
      end
    end
    key = "button_#{button_arr.length + 1}"
    @sprites[key] = IconSprite.new(356, 338, @viewport)
    @sprites[key].setBitmap(GRAPHICS_FILE_PATH + "button_begin")
    @sprites[key].src_rect.width = @sprites[key].bitmap.width / 2
    refresh_buttons

    @sprites["icon_recipient"] = PokemonIconSprite.new(nil, @viewport)
    @sprites["icon_recipient"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_recipient"].x = 145
    @sprites["icon_recipient"].y = 120

    @sprites["icon_donor_1"] = PokemonIconSprite.new(nil, @viewport)
    @sprites["icon_donor_1"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_donor_1"].x = 88
    @sprites["icon_donor_1"].y = 240

    @sprites["icon_donor_2"] = PokemonIconSprite.new(nil, @viewport)
    @sprites["icon_donor_2"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_donor_2"].x = 202
    @sprites["icon_donor_2"].y = 238

    @sprites["icon_boon"] = ItemIconSprite.new(106, 108, nil, @viewport)
    @sprites["icon_boon"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_boon"].blankzero = true

    @sprites["icon_bane"] = ItemIconSprite.new(182, 108, nil, @viewport)
    @sprites["icon_bane"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_bane"].blankzero = true

    @sprites["icon_stone"] = ItemIconSprite.new(144, 206, nil, @viewport)
    @sprites["icon_stone"].setOffset(PictureOrigin::CENTER)
    @sprites["icon_stone"].blankzero = true

    @sprites["crystal"] = ItemIconSprite.new(4, 52, Reincarnation::COST_ITEM, @viewport)
    @sprites["crystal"].setOffset(PictureOrigin::LEFT)
	  @sprites["crystal"].visible = Reincarnation.has_cost?

    @sprites["crystal_amt"] = BitmapSprite.new(100, 32, @viewport)
    @sprites["crystal_amt"].x = 53
    @sprites["crystal_amt"].y = 30
    pbSetSystemFont(@sprites["crystal_amt"].bitmap)
    pbDrawTextPositions(@sprites["crystal_amt"].bitmap, [[
      "x#{Reincarnation::COST_AMOUNT}", 4, 12, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR, 1
    ]]) if Reincarnation.has_cost?
    @sprites["crystal_amt"].visible = Reincarnation.has_cost?

    @sprites["results"] = Sprite.new(@viewport)
    @sprites["results"].x = 0
    @sprites["results"].y = 120
    @sprites["results"].visible = false

    reset_all_data

    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = 255
    @sprites["pokemon"].y = 255
    @sprites["pokemon"].visible = false

    @bitmap_f = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_f")
    @bitmap_d = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_d")
    @bitmap_c = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_c")
    @bitmap_b = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_b")
    @bitmap_a = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_a")
    @bitmap_s = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "icon_rating_s")

    pbFadeInAndShow(@sprites)
	end

  def main
    loop do
      Graphics.update
      Input.update
      update
      old_index = @index
      if Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
        @index -= 1
        @index = 0 if @index < 0
      elsif Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
        @index += 1
        limit = @recipient ? 6 : 5
        @index = limit if @index >= limit
      elsif Input.trigger?(Input::USE)
        case @index
        when 0
          @recipient, @party_idx = choose_pokemon
          refresh_buttons
        when 1
          @donor_1 = choose_pokemon.first
        when 2
          @donor_2 = choose_pokemon.first
        when 3
          $game_temp.reincarnation_sel_items.delete(@rein_boon) if @rein_boon
          @rein_boon = select_item_from_bag(proc { |item|
            itm_data = GameData::Item.get(item)
            next false if !itm_data.is_reincarnation_boon?
            next true if !$game_temp.reincarnation_sel_items.include?(item)
            next false if itm_data.is_important? 
            next false if ($bag.quantity(item) - 1) <= 0
            next true
          })
          $game_temp.reincarnation_sel_items.push(@rein_boon) if @rein_boon
        when 4
          $game_temp.reincarnation_sel_items.delete(@rein_bane) if @rein_bane
          @rein_bane = select_item_from_bag(proc { |item|
            itm_data = GameData::Item.get(item)
            next false if !itm_data.is_reincarnation_bane?
            next true if !$game_temp.reincarnation_sel_items.include?(item)
            next false if itm_data.is_important? 
            next false if ($bag.quantity(item) - 1) <= 0
            next true
          })
          $game_temp.reincarnation_sel_items.push(@rein_bane) if @rein_bane
        when 5
          $game_temp.reincarnation_sel_items.delete(@rein_stone) if @rein_stone
          @rein_stone = select_item_from_bag(proc { |item|
            itm_data = GameData::Item.get(item)
            next false if !itm_data.is_reincarnation_stone?
            next true if !$game_temp.reincarnation_sel_items.include?(item)
            next false if itm_data.is_important? 
            next false if ($bag.quantity(item) - 1) <= 0
            next true
          })
          $game_temp.reincarnation_sel_items.push(@rein_stone) if @rein_stone
        when 6
          if !@recipient || @party_idx < 0
            pbMessage(_INTL("Please select a Pokémon to reincarnate!")) { update }
            next
          end
          next if !Reincarnation.can_reincarnate?(@recipient, true)
          $game_temp.reincarnation_sel_items.clear
          old_ivs = @recipient.iv.clone
          old_stats = {
            :HP              => @recipient.totalhp, 
            :ATTACK          => @recipient.attack,
            :DEFENSE         => @recipient.defense,
            :SPECIAL_ATTACK  => @recipient.spatk,
            :SPECIAL_DEFENSE => @recipient.spdef,
            :SPEED           => @recipient.speed,
          }
          show_animation do
            Reincarnation.begin_reincarnation($player.party[@party_idx], @donor_1, @donor_2, @rein_boon, @rein_bane, @rein_stone)
            @recipient = $player.party[@party_idx]
            @sprites["icon_recipient"].pokemon = @recipient
          end
          show_results(old_ivs, old_stats)
          if !Reincarnation.meets_cost_requirement?
            item_data = GameData::Item.get(Reincarnation::COST_ITEM)
            pbMessage(_INTL("You don't have enough {1} to continue Reincarnation...", item_data.portion_name_plural)) { update }
            break
          elsif pbConfirmMessage(_INTL("Do you wish to continue Reincarnation?")) { update }
            reset_all_data
            hide_animation
          else
            break
          end
        end
        refresh_icons if @index < 6
      elsif Input.trigger?(Input::BACK)
        if !pbConfirmMessage(_INTL("Do you wish to continue Reincarnation?")) { update }
          $game_temp.reincarnation_sel_items.clear
          pbPlayCloseMenuSE
          break
        end
      end
      if @index != old_index
        pbSEPlay(CURSOR_SE)
        refresh_buttons
      end
    end
  end

  def show_results(old_ivs, old_stats)
    @sprites["pokemon"].setPokemonBitmap(@recipient)
    @sprites["pokemon"].visible = true
    @sprites["results"].visible = true
    textpos = []
    x   = 130
    y   = 64
    x_2 = 102
    y_2 = 60
    old_ivs.each do |key, stat|
      textpos.push([old_stats[key].to_s, x_2, y_2, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR])
      if stat > 30
        bmp = @bitmap_s
      elsif stat > 24
        bmp = @bitmap_a
      elsif stat > 16
        bmp = @bitmap_b
      elsif stat > 8
        bmp = @bitmap_c
      elsif stat > 0
        bmp = @bitmap_d
      else
        bmp = @bitmap_f
      end
      pbCopyBitmap(@sprites["results"].bitmap, bmp, x, y)
      y += 32
      y_2 += 32
    end

    x   = 468
    y   = 64
    x_2 = 442
    y_2 = 60
    stats = {
      :HP              => @recipient.totalhp, 
      :ATTACK          => @recipient.attack,
      :DEFENSE         => @recipient.defense,
      :SPECIAL_ATTACK  => @recipient.spatk,
      :SPECIAL_DEFENSE => @recipient.spdef,
      :SPEED           => @recipient.speed,
    }
    @recipient.iv.each do |key, stat|
      textpos.push([stats[key].to_s, x_2, y_2, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR])
      if stat > 30
        bmp = @bitmap_s
      elsif stat > 24
        bmp = @bitmap_a
      elsif stat > 16
        bmp = @bitmap_b
      elsif stat > 8
        bmp = @bitmap_c
      elsif stat > 0
        bmp = @bitmap_d
      else
        bmp = @bitmap_f
      end
      pbCopyBitmap(@sprites["results"].bitmap, bmp, x, y)
      y += 32
      y_2 += 32
    end
    @sprites["results"].bitmap.font.name = "Power Green Narrow"
    @sprites["results"].bitmap.font.size = 27
    @sprites["results"].bitmap.text_offset_y = 8
    pbDrawTextPositions(@sprites["results"].bitmap, textpos)
    textpos = []
    textpos.push([@recipient.name, 184, 10, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR])
    textpos.push([@recipient.level.to_s, 208, 40, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR])
    textpos.push([@recipient.nature.name, 184, 226, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR])
    pbSetSystemFont(@sprites["results"].bitmap)
    pbDrawTextPositions(@sprites["results"].bitmap, textpos)
    loop do
      Graphics.update
      Input.update
      update
      break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
    end
  end

  def show_animation
    duration = 0.6
    timer    = 0.0
    target   = (Graphics.width - @sprites["overlay_sigil"].width) / 2 - @sprites["overlay_sigil"].x
    x_keys   = ["overlay_sigil"]
    v_keys   = []
    initial  = {}
    @sprites.each_key do |key|
      v_keys.push(key) if key.include?("button_")
      v_keys.push(key) if key.include?("crystal")
      x_keys.push(key) if key.include?("icon_")
    end

    x_keys.each { |key| initial[key] = @sprites[key].x }
    v_keys.each { |key| @sprites[key].visible = false }
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      timer = duration if timer > duration
      factor = timer / duration
      x_keys.each { |key| @sprites[key].x = initial[key] + (target * factor) }
      break if timer >= duration
    end

    duration = 0.4
    timer    = 0.0
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      break if timer >= duration
    end
    audio_file = "Audio/SE/#{Reincarnation::CUSTOM_COMPLETE_SE}" 
    pbSEPlay(Reincarnation::CUSTOM_COMPLETE_SE) if pbStringToAudioFile(audio_file)
    @sprites.each_value { |sprite| sprite.color = Color.new(248, 248, 248, 0) }
    duration = 0.75
    timer    = 0.0
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      timer = duration if timer > duration
      factor = timer / duration
      @sprites.each_value { |sprite| sprite.color.alpha = 255  * factor }
      break if timer >= duration
    end

    duration = 1.5
    timer    = 0.0
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      break if timer >= duration
    end

    yield if block_given?

    duration = 1.0
    timer    = 0.0
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      timer = duration if timer > duration
      factor = 1 - (timer / duration)
      @sprites.each_value { |sprite| sprite.color.alpha = 255  * factor }
      break if timer >= duration
    end

    duration = 0.75
    timer    = 0.0
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      break if timer >= duration
    end
  end

  def hide_animation
    duration = 0.4
    timer    = 0.0
    target   = -30 - @sprites["overlay_sigil"].x
    x_keys   = ["overlay_sigil"]
    v_keys   = []
    initial  = {}
    @sprites.each_key do |key|
      v_keys.push(key) if key.include?("button_")
      v_keys.push(key) if key.include?("crystal")
      x_keys.push(key) if key.include?("icon_")
    end
    x_keys.each { |key| initial[key] = @sprites[key].x }
    @sprites["results"].visible = false
    @sprites["pokemon"].visible = false
    loop do
      Graphics.update
      update
      timer += Graphics.delta
      timer = duration if timer > duration
      factor = timer / duration
      x_keys.each { |key| @sprites[key].x = initial[key] + (target * factor) }
      break if timer >= duration
    end
    v_keys.each { |key| @sprites[key].visible = true }
    @sprites.each_value { |sprite| sprite.color = Color.new(0, 0, 0, 0) }
    @sprites["crystal"].visible = Reincarnation.has_cost?
    @sprites["crystal_amt"].visible = Reincarnation.has_cost?
  end

  def reset_all_data
    @index      = 0
    @recipient  = nil
    @party_idx  = -1
    @donor_1    = nil
    @donor_2    = nil
    @rein_boon  = nil
    @rein_bane  = nil
    @rein_stone = nil
    refresh_buttons
    refresh_icons
    @sprites["results"].bitmap&.clear
    bmp = RPG::Cache.load_bitmap(GRAPHICS_FILE_PATH, "overlay_results")
    @sprites["results"].bitmap = Bitmap.new(bmp.width, bmp.height) if !@sprites["results"].bitmap
    @sprites["results"].bitmap.blt(0, 0, bmp, Rect.new(0, 0, bmp.width, bmp.height))
    pbSetSystemFont(@sprites["results"].bitmap)
    textpos = [
      [_INTL("HP"), 30, 60, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("ATK"), 30, 92, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("DEF"), 30, 124, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPATK"), 30, 156, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPDEF"), 30, 188, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPD"), 30, 220, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("HP"), 368, 60, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("ATK"), 368, 92, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("DEF"), 368, 124, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPATK"), 368, 156, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPDEF"), 368, 188, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
      [_INTL("SPD"), 368, 220, 0, TEXT_BASE_COLOR, TEXT_SHDW_COLOR],
    ]
    pbDrawTextPositions(@sprites["results"].bitmap, textpos)
    bmp.dispose
  end

  def refresh_buttons
    @sprites.each do |key, sprite|
      next if !key.include?("button_")
      if sprite.is_a?(Button)
        sprite.selected = false
      else
        sprite.src_rect.x = 0
        sprite.y = 348
        sprite.visible = !@recipient.nil?
      end
    end
    key = "button_#{@index + 1}"
    if @sprites[key].is_a?(Button)
      @sprites[key].selected = true
    else
      @sprites[key].y = 338
      @sprites[key].src_rect.x = @sprites[key].bitmap.width / 2
    end
  end

  def refresh_icons
    @sprites["icon_recipient"].pokemon = @recipient
    @sprites["icon_donor_1"].pokemon   = @donor_1
    @sprites["icon_donor_2"].pokemon   = @donor_2
    @sprites["icon_boon"].item         = @rein_boon
    @sprites["icon_bane"].item         = @rein_bane
    @sprites["icon_stone"].item        = @rein_stone
    @sprites["button_1"].pokemon       = @recipient
    @sprites["button_2"].pokemon       = @donor_1
    @sprites["button_3"].pokemon       = @donor_2
    @sprites["button_4"].item          = @rein_boon
    @sprites["button_5"].item          = @rein_bane
    @sprites["button_6"].item          = @rein_stone
  end

  def select_item_from_bag(check_proc)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene, $bag)
      ret = screen.pbChooseItemScreen(check_proc)
    }
    return ret
  end

  def choose_pokemon
    chosen = 0
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Choose a Pokémon."), false)
      chosen = show_choose_pkmn_commands(scene)
      screen.pbEndScene
    }
    if chosen
      return [$player.party[chosen], chosen]
    else
      return [nil, -1] 
    end
  end
  
  def show_choose_pkmn_commands(scene)
    loop do
      pkmn_id = scene.pbChoosePokemon
      return nil if pkmn_id < 0   # Cancelled
      pkmn = $player.party[pkmn_id]
      commands = [_INTL("Select"), _INTL("Summary"), _INTL("Cancel")]
      command = scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands) if pkmn
      case command
      when 1 then scene.pbSummary(pkmn_id) 
      when 0 
        if pkmn.egg?
          scene.pbDisplay(_INTL("Eggs cannot be reincarnated!"))
          next
        elsif @recipient == pkmn
          scene.pbDisplay(_INTL("{1} is the Pokémon being reincarnated!", pkmn.name))
          next
        elsif [@donor_1, @donor_2].include?(pkmn)
          scene.pbDisplay(_INTL("{1} is already a donor!", pkmn.name))
          next
        end
        return pkmn_id 
      end
    end
  end
end

class Game_Temp
  attr_accessor :reincarnation_sel_items

  def reincarnation_sel_items
    @reincarnation_sel_items = [] if !@reincarnation_sel_items
    return @reincarnation_sel_items
  end
end
