#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Adjustments to get the Yin/Yang icons to display for Puppets in the Text
#	  Entry Screen.
#	* 
#==============================================================================#
class PokemonEntryScene
  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if USEKEYBOARD
      @sprites["entry"] = Window_TextEntry_Keyboard.new(
        initialText, 0, 0, 400 - 112, 96, helptext, true
      )
      Input.text_input = true
    else
      @sprites["entry"] = Window_TextEntry.new(initialText, 0, 0, 400, 96, helptext, true)
    end
    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2) + 32
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true
    @minlength = minlength
    @maxlength = maxlength
    @symtype = 0
    @sprites["entry"].maxlength = maxlength
    if !USEKEYBOARD
      @sprites["entry2"] = Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport = @viewport
      @sprites["entry2"].visible = true
      @sprites["entry2"].x = (Graphics.width / 2) - (@sprites["entry2"].width / 2)
    end
    if minlength == 0
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    else
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    end
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = USEKEYBOARD
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)
    addBackgroundPlane(@sprites, "background", "Naming/bg_2", @viewport)
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8)
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        pkmn_data = GameData::Species.get_species_form(pokemon.species, pokemon.form)
        textpos = []
		if pkmn_data.has_flag?("Puppet")
          if pokemon.male?
            textpos.push([_INTL("¹"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
       	  elsif pokemon.female?
          	textpos.push([_INTL("²"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
          end
        else
          if pokemon.male?
            textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
       	  elsif pokemon.female?
          	textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
          end
		end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/UI/Naming/icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    pbFadeInAndShow(@sprites)
  end
end



class PokemonEntryScene2
  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    # Create bitmaps
    @bitmaps = []
    @@Characters.length.times do |i|
      @bitmaps[i] = AnimatedBitmap.new(sprintf("Graphics/UI/Naming/overlay_tab_%d", i + 1))
      b = @bitmaps[i].bitmap.clone
      pbSetSystemFont(b)
      textPos = []
      COLUMNS.times do |y|
        ROWS.times do |x|
          pos = (y * ROWS) + x
          textPos.push([@@Characters[i][0][pos], 44 + (x * 32), 24 + (y * 38), :center,
                        Color.new(16, 24, 32), Color.new(160, 160, 160)])
        end
      end
      pbDrawTextPositions(b, textPos)
      @bitmaps[@@Characters.length + i] = b
    end
    underline_bitmap = Bitmap.new(24, 6)
    underline_bitmap.fill_rect(2, 2, 22, 4, Color.new(168, 184, 184))
    underline_bitmap.fill_rect(0, 0, 22, 4, Color.new(16, 24, 32))
    @bitmaps.push(underline_bitmap)
    # Create sprites
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/UI/Naming/bg")
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8)
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        pkmn_data = GameData::Species.get_species_form(pokemon.species, pokemon.form)
		if pkmn_data.has_flag?("Puppet")
          if pokemon.male?
          	textpos.push([_INTL("¹"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
          elsif pokemon.female?
          	textpos.push([_INTL("²"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
          end
        else
          if pokemon.male?
          	textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
          elsif pokemon.female?
          	textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
          end
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/UI/Naming/icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay
    @blanks = []
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @maxlength.times do |i|
      @sprites["blank#{i}"] = Sprite.new(@viewport)
      @sprites["blank#{i}"].x = 160 + (24 * i)
      @sprites["blank#{i}"].bitmap = @bitmaps[@bitmaps.length - 1]
      @blanks[i] = 0
    end
    @sprites["bottomtab"] = Sprite.new(@viewport)   # Current tab
    @sprites["bottomtab"].x = 22
    @sprites["bottomtab"].y = 162
    @sprites["bottomtab"].bitmap = @bitmaps[@@Characters.length]
    @sprites["toptab"] = Sprite.new(@viewport)   # Next tab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    @sprites["toptab"].bitmap = @bitmaps[@@Characters.length + 1]
    @sprites["controls"] = IconSprite.new(0, 0, @viewport)
    @sprites["controls"].x = 16
    @sprites["controls"].y = 96
    @sprites["controls"].setBitmap(_INTL("Graphics/UI/Naming/overlay_controls"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"] = NameEntryCursor.new(@viewport)
    @cursorpos = 0
    @refreshOverlay = true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end