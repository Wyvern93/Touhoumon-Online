#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* The overwhelming majority of changes here are to get the Pokedex search
#	  to account for Touhoumon types. I will mark all changes I make, as I am
#	  just straight copying the entire script section here. A lot of it is
#	  small changes needed to make it work.
#==============================================================================#
class PokedexSearchSelectionSprite < Sprite
  def mode=(value)
    @mode = value
    case @mode
    when 0     # Order
      @xstart = 46
      @ystart = 128
      @xgap = 236
      @ygap = 64
      @cols = 2
    when 1     # Name
      @xstart = 78
      @ystart = 114
      @xgap = 52
      @ygap = 52
      @cols = 7
    when 2     # Type
      @xstart = 8
      @ystart = 104
# ------ Derx: Changes necessary for Pokedex screen fixes
      @xgap = 62			 # Derx: @xgap was initially 124
	  @ygap = 44
      @cols = 8				 # Derx: @cols was initially 4
# ------ End of Pokedex screen fixes
    when 3, 4   # Height, weight
      @xstart = 44
      @ystart = 110
      @xgap = 8
      @ygap = 112
    when 5     # Color
      @xstart = 62
      @ystart = 114
      @xgap = 132
      @ygap = 52
      @cols = 3
    when 6     # Shape
      @xstart = 82
      @ystart = 116
      @xgap = 70
      @ygap = 70
      @cols = 5
    end
  end

  def refresh
    # Size and position cursor
    if @mode == -1   # Main search screen
      case @index
      when 0     # Order
        self.src_rect.y = 0
        self.src_rect.height = 44
      when 1, 5   # Name, color
        self.src_rect.y = 44
        self.src_rect.height = 44
      when 2     # Type
        self.src_rect.y = 88
        self.src_rect.height = 44
      when 3, 4   # Height, weight
        self.src_rect.y = 132
        self.src_rect.height = 44
      when 6     # Shape
        self.src_rect.y = 176
        self.src_rect.height = 68
      else       # Reset/start/cancel
        self.src_rect.y = 244
        self.src_rect.height = 40
      end
      case @index
      when 0         # Order
        self.x = 252
        self.y = 52
      when 1, 2, 3, 4   # Name, type, height, weight
        self.x = 114
        self.y = 110 + ((@index - 1) * 52)
      when 5         # Color
        self.x = 382
        self.y = 110
      when 6         # Shape
        self.x = 420
        self.y = 214
      when 7, 8, 9     # Reset, start, cancel
        self.x = 4 + ((@index - 7) * 176)
        self.y = 334
      end
    else   # Parameter screen
      case @index
      when -2, -3   # OK, Cancel
        self.src_rect.y = 244
        self.src_rect.height = 40
      else
        case @mode
        when 0     # Order
          self.src_rect.y = 0
          self.src_rect.height = 44
        when 1     # Name
          self.src_rect.y = 284
          self.src_rect.height = 44
# ------ Derx: Changes necessary for Pokedex screen fixes
# ------ Derx: These changes were directly ported and may need fixing.
		when 2 # Type
		  self.src_rect.y = 392
		  self.src_rect.height = 44
# ------ End of Pokedex screen fixes
        when 5 # Color
          self.src_rect.y = 44
          self.src_rect.height = 44
#        when 2, 5   # Type, color		# Derx: These were the initial lines for the above section
#          self.src_rect.y = 44			# Derx: These were the initial lines for the above section
#          self.src_rect.height = 44	# Derx: These were the initial lines for the above section
        when 3, 4   # Height, weight
          self.src_rect.y = (@minmax == 1) ? 328 : 424
          self.src_rect.height = 96
        when 6     # Shape
          self.src_rect.y = 176
          self.src_rect.height = 68
        end
      end
      case @index
      when -1   # Blank option
        if @mode == 3 || @mode == 4   # Height/weight range
          self.x = @xstart + ((@cmds + 1) * @xgap * (@minmax % 2))
          self.y = @ystart + (@ygap * ((@minmax + 1) % 2))
        else
          self.x = @xstart + ((@cols - 1) * @xgap)
          self.y = @ystart + ((@cmds / @cols).floor * @ygap)
        end
      when -2   # OK
        self.x = 4
        self.y = 334
      when -3   # Cancel
        self.x = 356
        self.y = 334
      else
        case @mode
        when 0, 1, 2, 5, 6   # Order, name, type, color, shape
          if @index >= @cmds
            self.x = @xstart + ((@cols - 1) * @xgap)
            self.y = @ystart + ((@cmds / @cols).floor * @ygap)
          else
            self.x = @xstart + ((@index % @cols) * @xgap)
            self.y = @ystart + ((@index / @cols).floor * @ygap)
          end
        when 3, 4         # Height, weight
          if @index >= @cmds
            self.x = @xstart + ((@cmds + 1) * @xgap * ((@minmax + 1) % 2))
          else
            self.x = @xstart + ((@index + 1) * @xgap)
          end
          self.y = @ystart + (@ygap * ((@minmax + 1) % 2))
        end
      end
    end
  end
end

#===============================================================================
# Pokédex main screen
#===============================================================================
class PokemonPokedex_Scene
  def pbStartScene
    @sliderbitmap       = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
    @typebitmap         = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types"))
    @typebitmaplarge    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_types_big")) # Derx: Required for Pokedex Screen Fixes
    @shapebitmap        = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
    @hwbitmap           = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
    @selbitmap          = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/icon_searchslider"))
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "background", "Pokedex/bg_list", @viewport)
    # Suggestion for changing the background depending on region. You can
    # comment out the line above and uncomment the following lines:
#    if pbGetPokedexRegion == -1   # Using national Pokédex
#      addBackgroundPlane(@sprites, "background", "Pokedex/bg_national", @viewport)
#    elsif pbGetPokedexRegion == 0   # Using first regional Pokédex
#      addBackgroundPlane(@sprites, "background", "Pokedex/bg_regional", @viewport)
#    end
    addBackgroundPlane(@sprites, "searchbg", "Pokedex/bg_search", @viewport)
    @sprites["searchbg"].visible = false
    @sprites["pokedex"] = Window_Pokedex.new(206, 30, 276, 364, @viewport)
    @sprites["icon"] = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::CENTER)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    @sprites["searchcursor"].visible = false
    @searchResults = false
    @searchParams  = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites)
  end

  def pbRefreshDexSearch(params, _index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(72, 72, 72)
    # Write various bits of text
    textpos = [
      [_INTL("Search Mode"), Graphics.width / 2, 10, :center, base, shadow],
      [_INTL("Order"), 136, 64, :center, base, shadow],
      [_INTL("Name"), 58, 122, :center, base, shadow],
      [_INTL("Type"), 58, 174, :center, base, shadow],
      [_INTL("Height"), 58, 226, :center, base, shadow],
      [_INTL("Weight"), 58, 278, :center, base, shadow],
      [_INTL("Color"), 326, 122, :center, base, shadow],
      [_INTL("Shape"), 454, 174, :center, base, shadow],
      [_INTL("Reset"), 80, 346, :center, base, shadow, 1],
      [_INTL("Start"), Graphics.width / 2, 346, :center, base, shadow, :outline],
      [_INTL("Cancel"), Graphics.width - 80, 346, :center, base, shadow, :outline]
    ]
    # Write order, name and color parameters
    textpos.push([@orderCommands[params[0]], 344, 66, :center, base, shadow, :outline])
    textpos.push([(params[1] < 0) ? "----" : @nameCommands[params[1]], 176, 124, :center, base, shadow, :outline])
    textpos.push([(params[8] < 0) ? "----" : @colorCommands[params[8]].name, 444, 124, :center, base, shadow, :outline])
    # Draw type icons
    if params[2] >= 0
      type_number = @typeCommands[params[2]].icon_position
      typerect = Rect.new(0, type_number * 32, 96, 32)
      overlay.blt(128, 168, @typebitmaplarge.bitmap, typerect) # Derx: Changes necessary for Pokedex screen fixes
    else
      textpos.push(["----", 176, 176, :center, base, shadow, :outline])
    end
    if params[3] >= 0
      type_number = @typeCommands[params[3]].icon_position
      typerect = Rect.new(0, type_number * 32, 96, 32)
      overlay.blt(256, 168, @typebitmaplarge.bitmap, typerect) # Derx: Changes necessary for Pokedex screen fixes
    else
      textpos.push(["----", 304, 176, :center, base, shadow, :outline])
    end
    # Write height and weight limits
    ht1 = (params[4] < 0) ? 0 : (params[4] >= @heightCommands.length) ? 999 : @heightCommands[params[4]]
    ht2 = (params[5] < 0) ? 999 : (params[5] >= @heightCommands.length) ? 0 : @heightCommands[params[5]]
    wt1 = (params[6] < 0) ? 0 : (params[6] >= @weightCommands.length) ? 9999 : @weightCommands[params[6]]
    wt2 = (params[7] < 0) ? 9999 : (params[7] >= @weightCommands.length) ? 0 : @weightCommands[params[7]]
    hwoffset = false
    if System.user_language[3..4] == "US"   # If the user is in the United States
      ht1 = (params[4] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
      ht2 = (params[5] < 0) ? 99 * 12 : (ht2 / 0.254).round
      wt1 = (params[6] >= @weightCommands.length) ? 99_990 : (wt1 / 0.254).round
      wt2 = (params[7] < 0) ? 99_990 : (wt2 / 0.254).round
      textpos.push([sprintf("%d'%02d''", ht1 / 12, ht1 % 12), 166, 228, :center, base, shadow, :outline])
      textpos.push([sprintf("%d'%02d''", ht2 / 12, ht2 % 12), 294, 228, :center, base, shadow, :outline])
      textpos.push([sprintf("%.1f", wt1 / 10.0), 166, 280, :center, base, shadow, :outline])
      textpos.push([sprintf("%.1f", wt2 / 10.0), 294, 280, :center, base, shadow, :outline])
      hwoffset = true
    else
      textpos.push([sprintf("%.1f", ht1 / 10.0), 166, 228, :center, base, shadow, :outline])
      textpos.push([sprintf("%.1f", ht2 / 10.0), 294, 228, :center, base, shadow, :outline])
      textpos.push([sprintf("%.1f", wt1 / 10.0), 166, 280, :center, base, shadow, :outline])
      textpos.push([sprintf("%.1f", wt2 / 10.0), 294, 280, :center, base, shadow, :outline])
    end
    overlay.blt(344, 214, @hwbitmap.bitmap, Rect.new(0, (hwoffset) ? 44 : 0, 32, 44))
    overlay.blt(344, 266, @hwbitmap.bitmap, Rect.new(32, (hwoffset) ? 44 : 0, 32, 44))
    # Draw shape icon
    if params[9] >= 0
      shape_number = @shapeCommands[params[9]].icon_position
      shaperect = Rect.new(0, shape_number * 60, 60, 60)
      overlay.blt(424, 218, @shapebitmap.bitmap, shaperect)
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbRefreshDexSearchParam(mode, cmds, sel, _index)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248, 248, 248)
    shadow = Color.new(72, 72, 72)
    # Write various bits of text
    textpos = [
      [_INTL("Search Mode"), Graphics.width / 2, 10, :center, base, shadow],
      [_INTL("OK"), 80, 346, :center, base, shadow, :outline],
      [_INTL("Cancel"), Graphics.width - 80, 346, :center, base, shadow, :outline]
    ]
    title = [_INTL("Order"), _INTL("Name"), _INTL("Type"), _INTL("Height"),
             _INTL("Weight"), _INTL("Color"), _INTL("Shape")][mode]
    textpos.push([title, 102, (mode == 6) ? 70 : 64, :left, base, shadow])
    case mode
    when 0   # Order
      xstart = 46
      ystart = 128
      xgap = 236
      ygap = 64
      halfwidth = 92
      cols = 2
      selbuttony = 0
      selbuttonheight = 44
    when 1   # Name
      xstart = 78
      ystart = 114
      xgap = 52
      ygap = 52
      halfwidth = 22
      cols = 7
      selbuttony = 156
      selbuttonheight = 44
    when 2   # Type
      xstart = 8
      ystart = 104
      xgap = 62 #Derx: Previously 124
      ygap = 44
      halfwidth = 32 # Derx: Previously 62
      cols = 8 # Derx: Previously 4
      selbuttony = 200 # Derx: Previously 44
      selbuttonheight = 44
# ------ Derx: Revert the above if things go haywire and work again
    when 3, 4   # Height, weight
      xstart = 44
      ystart = 110
      xgap = 304 / (cmds.length + 1)
      ygap = 112
      halfwidth = 60
      cols = cmds.length + 1
    when 5   # Color
      xstart = 62
      ystart = 114
      xgap = 132
      ygap = 52
      halfwidth = 62
      cols = 3
      selbuttony = 44
      selbuttonheight = 44
    when 6   # Shape
      xstart = 82
      ystart = 116
      xgap = 70
      ygap = 70
      halfwidth = 0
      cols = 5
      selbuttony = 88
      selbuttonheight = 68
    end
    # Draw selected option(s) text in top bar
    case mode
    when 2   # Type icons
      2.times do |i|
        if !sel[i] || sel[i] < 0
          textpos.push(["----", 298 + (128 * i), 66, :center, base, shadow, :outline])
        else
          type_number = @typeCommands[sel[i]].icon_position
          typerect = Rect.new(0, type_number * 32, 96, 32)
          overlay.blt(250 + (128 * i), 58, @typebitmaplarge.bitmap, typerect) # Derx: Changes necessary for Pokedex screen fixes
        end
      end
    when 3   # Height range
      ht1 = (sel[0] < 0) ? 0 : (sel[0] >= @heightCommands.length) ? 999 : @heightCommands[sel[0]]
      ht2 = (sel[1] < 0) ? 999 : (sel[1] >= @heightCommands.length) ? 0 : @heightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4] == "US"    # If the user is in the United States
        ht1 = (sel[0] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
        ht2 = (sel[1] < 0) ? 99 * 12 : (ht2 / 0.254).round
        txt1 = sprintf("%d'%02d''", ht1 / 12, ht1 % 12)
        txt2 = sprintf("%d'%02d''", ht2 / 12, ht2 % 12)
        hwoffset = true
      else
        txt1 = sprintf("%.1f", ht1 / 10.0)
        txt2 = sprintf("%.1f", ht2 / 10.0)
      end
      textpos.push([txt1, 286, 66, :center, base, shadow, :outline])
      textpos.push([txt2, 414, 66, :center, base, shadow, :outline])
      overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(0, (hwoffset) ? 44 : 0, 32, 44))
    when 4   # Weight range
      wt1 = (sel[0] < 0) ? 0 : (sel[0] >= @weightCommands.length) ? 9999 : @weightCommands[sel[0]]
      wt2 = (sel[1] < 0) ? 9999 : (sel[1] >= @weightCommands.length) ? 0 : @weightCommands[sel[1]]
      hwoffset = false
      if System.user_language[3..4] == "US"   # If the user is in the United States
        wt1 = (sel[0] >= @weightCommands.length) ? 99_990 : (wt1 / 0.254).round
        wt2 = (sel[1] < 0) ? 99_990 : (wt2 / 0.254).round
        txt1 = sprintf("%.1f", wt1 / 10.0)
        txt2 = sprintf("%.1f", wt2 / 10.0)
        hwoffset = true
      else
        txt1 = sprintf("%.1f", wt1 / 10.0)
        txt2 = sprintf("%.1f", wt2 / 10.0)
      end
      textpos.push([txt1, 286, 66, :center, base, shadow, :outline])
      textpos.push([txt2, 414, 66, :center, base, shadow, :outline])
      overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(32, (hwoffset) ? 44 : 0, 32, 44))
    when 5   # Color
      if sel[0] < 0
        textpos.push(["----", 362, 66, :center, base, shadow, :outline])
      else
        textpos.push([cmds[sel[0]].name, 362, 66, :center, base, shadow, :outline])
      end
    when 6   # Shape icon
      if sel[0] >= 0
        shaperect = Rect.new(0, @shapeCommands[sel[0]].icon_position * 60, 60, 60)
        overlay.blt(332, 50, @shapebitmap.bitmap, shaperect)
      end
    else
      if sel[0] < 0
        text = ["----", "-", "----", "", "", "----", ""][mode]
        textpos.push([text, 362, 66, :center, base, shadow, :outline])
      else
        textpos.push([cmds[sel[0]], 362, 66, :center, base, shadow, :outline])
      end
    end
    # Draw selected option(s) button graphic
    if [3, 4].include?(mode)   # Height, weight
      xpos1 = xstart + ((sel[0] + 1) * xgap)
      xpos1 = xstart if sel[0] < -1
      xpos2 = xstart + ((sel[1] + 1) * xgap)
      xpos2 = xstart + (cols * xgap) if sel[1] < 0
      xpos2 = xstart if sel[1] >= cols - 1
      ypos1 = ystart + 180
      ypos2 = ystart + 36
      overlay.blt(16, 120, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[1] < cols - 1
      overlay.blt(464, 120, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[1] >= 0
      overlay.blt(16, 264, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[0] >= 0
      overlay.blt(464, 264, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[0] < cols - 1
      hwrect = Rect.new(0, 0, 120, 96)
      overlay.blt(xpos2, ystart, @searchsliderbitmap.bitmap, hwrect)
      hwrect.y = 96
      overlay.blt(xpos1, ystart + ygap, @searchsliderbitmap.bitmap, hwrect)
      textpos.push([txt1, xpos1 + halfwidth, ypos1, :center, base])
      textpos.push([txt2, xpos2 + halfwidth, ypos2, :center, base])
    else
      sel.length.times do |i|
        selrect = Rect.new(0, selbuttony, @selbitmap.bitmap.width, selbuttonheight)
        if sel[i] >= 0
          overlay.blt(xstart + ((sel[i] % cols) * xgap),
                      ystart + ((sel[i] / cols).floor * ygap),
                      @selbitmap.bitmap, selrect)
        else
          overlay.blt(xstart + ((cols - 1) * xgap),
                      ystart + ((cmds.length / cols).floor * ygap),
                      @selbitmap.bitmap, selrect)
        end
      end
    end
    # Draw options
    case mode
    when 0, 1   # Order, name
      cmds.length.times do |i|
        x = xstart + halfwidth + ((i % cols) * xgap)
        y = ystart + 14 + ((i / cols).floor * ygap)
        textpos.push([cmds[i], x, y, :center, base, shadow, :outline])
      end
      if mode != 0
        textpos.push([(mode == 1) ? "-" : "----",
                      xstart + halfwidth + ((cols - 1) * xgap),
                      ystart + 14 + ((cmds.length / cols).floor * ygap),
                      :center, base, shadow, :outline])
      end
    when 2   # Type
      typerect = Rect.new(0, 0,34, 28) # Derx: Changes necessary for Pokedex screen fixes
      cmds.length.times do |i|
        typerect.y = @typeCommands[i].icon_position * 28 # Derx: Changes necessary for Pokedex screen fixes
        overlay.blt(xstart + 14 + ((i % cols) * xgap),
                    ystart + 6 + ((i / cols).floor * ygap),
                    @typebitmap.bitmap, typerect)
      end
      textpos.push(["----",
                    xstart + halfwidth + ((cols - 1) * xgap),
                    ystart + 14 + ((cmds.length / cols).floor * ygap),
                    :center, base, shadow, :outline])
    when 5   # Color
      cmds.length.times do |i|
        x = xstart + halfwidth + ((i % cols) * xgap)
        y = ystart + 14 + ((i / cols).floor * ygap)
        textpos.push([cmds[i].name, x, y, :center, base, shadow, :outline])
      end
      textpos.push(["----",
                    xstart + halfwidth + ((cols - 1) * xgap),
                    ystart + 14 + ((cmds.length / cols).floor * ygap),
                    :center, base, shadow, :outline])
    when 6   # Shape
      shaperect = Rect.new(0, 0, 60, 60)
      cmds.length.times do |i|
        shaperect.y = @shapeCommands[i].icon_position * 60
        overlay.blt(xstart + 4 + ((i % cols) * xgap),
                    ystart + 4 + ((i / cols).floor * ygap),
                    @shapebitmap.bitmap, shaperect)
      end
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
  end

  def pbDexSearchCommands(mode, selitems, mainindex)
    cmds = [@orderCommands, @nameCommands, @typeCommands, @heightCommands,
            @weightCommands, @colorCommands, @shapeCommands][mode]
    cols = [2, 7, 8, 4, 1, 1, 3, 5][mode] # Derx: Changes necessary for Pokedex screen fixes
    ret = nil
    # Set background
    case mode
    when 0    then @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_order")
    when 1    then @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_name")
    when 2
      count = 0
      GameData::Type.each { |t| count += 1 if !t.pseudo_type && t.id != :SHADOW }
      if count == 18
        @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_type_18")
      else
        @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_type")
      end
    when 3, 4 then @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_size")
    when 5    then @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_color")
    when 6    then @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search_shape")
    end
    selindex = selitems.clone
    index     = selindex[0]
    oldindex  = index
    minmax    = 1
    oldminmax = minmax
    index = oldindex = selindex[minmax] if [3, 4].include?(mode)
    @sprites["searchcursor"].mode   = mode
    @sprites["searchcursor"].cmds   = cmds.length
    @sprites["searchcursor"].minmax = minmax
    @sprites["searchcursor"].index  = index
    nextparam = cmds.length % 2
    pbRefreshDexSearchParam(mode, cmds, selindex, index)
    loop do
      pbUpdate
      if index != oldindex || minmax != oldminmax
        @sprites["searchcursor"].minmax = minmax
        @sprites["searchcursor"].index  = index
        oldindex  = index
        oldminmax = minmax
      end
      Graphics.update
      Input.update
      if [3, 4].include?(mode)
        if Input.trigger?(Input::UP)
          if index < -1   # From OK/Cancel
            minmax = 0
            index = selindex[minmax]
          elsif minmax == 0
            minmax = 1
            index = selindex[minmax]
          end
          if index != oldindex || minmax != oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.trigger?(Input::DOWN)
          case minmax
          when 1
            minmax = 0
            index = selindex[minmax]
          when 0
            minmax = -1
            index = -2
          end
          if index != oldindex || minmax != oldminmax
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.repeat?(Input::LEFT)
          if index == -3
            index = -2
          elsif index >= -1
            if minmax == 1 && index == -1
              index = cmds.length - 1 if selindex[0] < cmds.length - 1
            elsif minmax == 1 && index == 0
              index = cmds.length if selindex[0] < 0
            elsif index > -1 && !(minmax == 1 && index >= cmds.length)
              index -= 1 if minmax == 0 || selindex[0] <= index - 1
            end
          end
          if index != oldindex
            selindex[minmax] = index if minmax >= 0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        elsif Input.repeat?(Input::RIGHT)
          if index == -2
            index = -3
          elsif index >= -1
            if minmax == 1 && index >= cmds.length
              index = 0
            elsif minmax == 1 && index == cmds.length - 1
              index = -1
            elsif index < cmds.length && !(minmax == 1 && index < 0)
              index += 1 if minmax == 1 || selindex[1] == -1 ||
                            (selindex[1] < cmds.length && selindex[1] >= index + 1)
            end
          end
          if index != oldindex
            selindex[minmax] = index if minmax >= 0
            pbPlayCursorSE
            pbRefreshDexSearchParam(mode, cmds, selindex, index)
          end
        end
      else
        if Input.trigger?(Input::UP)
          if index == -1   # From blank
            index = cmds.length - 1 - ((cmds.length - 1) % cols) - 1
          elsif index == -2   # From OK
            index = ((cmds.length - 1) / cols).floor * cols
          elsif index == -3 && mode == 0   # From Cancel
            index = cmds.length - 1
          elsif index == -3   # From Cancel
            index = -1
          elsif index >= cols
            index -= cols
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::DOWN)
          if index == -1   # From blank
            index = -3
          elsif index >= 0
            if index + cols < cmds.length
              index += cols
            elsif (index / cols).floor < ((cmds.length - 1) / cols).floor
              index = (index % cols < cols / 2.0) ? cmds.length - 1 : -1
            else
              index = (index % cols < cols / 2.0) ? -2 : -3
            end
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::LEFT)
          if index == -3
            index = -2
          elsif index == -1
            index = cmds.length - 1
          elsif index > 0 && index % cols != 0
            index -= 1
          end
          pbPlayCursorSE if index != oldindex
        elsif Input.trigger?(Input::RIGHT)
          if index == -2
            index = -3
          elsif index == cmds.length - 1 && mode != 0
            index = -1
          elsif index >= 0 && index % cols != cols - 1
            index += 1
          end
          pbPlayCursorSE if index != oldindex
        end
      end
      if Input.trigger?(Input::ACTION)
        index = -2
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        ret = nil
        break
      elsif Input.trigger?(Input::USE)
        if index == -2      # OK
          pbPlayDecisionSE
          ret = selindex
          break
        elsif index == -3   # Cancel
          pbPlayCloseMenuSE
          ret = nil
          break
        elsif selindex != index && mode != 3 && mode != 4
          if mode == 2
            if index == -1
              nextparam = (selindex[1] >= 0) ? 1 : 0
            elsif index >= 0
              nextparam = (selindex[0] < 0) ? 0 : (selindex[1] < 0) ? 1 : nextparam
            end
            if index < 0 || selindex[(nextparam + 1) % 2] != index
              pbPlayDecisionSE
              selindex[nextparam] = index
              nextparam = (nextparam + 1) % 2
            end
          else
            pbPlayDecisionSE
            selindex[0] = index
          end
          pbRefreshDexSearchParam(mode, cmds, selindex, index)
        end
      end
    end
    Input.update
    # Set background image
    @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search")
    @sprites["searchcursor"].mode = -1
    @sprites["searchcursor"].index = mainindex
    return ret
  end

  def pbDexSearch
    oldsprites = pbFadeOutAndHide(@sprites)
    params = @searchParams.clone
    @orderCommands = []
    @orderCommands[MODENUMERICAL] = _INTL("Numerical")
    @orderCommands[MODEATOZ]      = _INTL("A to Z")
    @orderCommands[MODEHEAVIEST]  = _INTL("Heaviest")
    @orderCommands[MODELIGHTEST]  = _INTL("Lightest")
    @orderCommands[MODETALLEST]   = _INTL("Tallest")
    @orderCommands[MODESMALLEST]  = _INTL("Smallest")
    @nameCommands = [_INTL("A"), _INTL("B"), _INTL("C"), _INTL("D"), _INTL("E"),
                     _INTL("F"), _INTL("G"), _INTL("H"), _INTL("I"), _INTL("J"),
                     _INTL("K"), _INTL("L"), _INTL("M"), _INTL("N"), _INTL("O"),
                     _INTL("P"), _INTL("Q"), _INTL("R"), _INTL("S"), _INTL("T"),
                     _INTL("U"), _INTL("V"), _INTL("W"), _INTL("X"), _INTL("Y"),
                     _INTL("Z")]
    @typeCommands = []
    GameData::Type.each { |t| @typeCommands.push(t) if !t.pseudo_type }
    @heightCommands = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                       11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                       21, 22, 23, 24, 25, 30, 35, 40, 45, 50,
                       55, 60, 65, 70, 80, 90, 100]
    @weightCommands = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50,
                       55, 60, 70, 80, 90, 100, 110, 120, 140, 160,
                       180, 200, 250, 300, 350, 400, 500, 600, 700, 800,
                       900, 1000, 1250, 1500, 2000, 3000, 5000]
    @colorCommands = []
    GameData::BodyColor.each { |c| @colorCommands.push(c) if c.id != :None }
    @shapeCommands = []
    GameData::BodyShape.each { |s| @shapeCommands.push(s) if s.id != :None }
    @sprites["searchbg"].visible     = true
    @sprites["overlay"].visible      = true
    @sprites["searchcursor"].visible = true
    index = 0
    oldindex = index
    @sprites["searchcursor"].mode    = -1
    @sprites["searchcursor"].index   = index
    pbRefreshDexSearch(params, index)
    pbFadeInAndShow(@sprites)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if index != oldindex
        @sprites["searchcursor"].index = index
        oldindex = index
      end
      if Input.trigger?(Input::UP)
        if index >= 7
          index = 4
        elsif index == 5
          index = 0
        elsif index > 0
          index -= 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::DOWN)
        if [4, 6].include?(index)
          index = 8
        elsif index < 7
          index += 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::LEFT)
        if index == 5
          index = 1
        elsif index == 6
          index = 3
        elsif index > 7
          index -= 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::RIGHT)
        if index == 1
          index = 5
        elsif index >= 2 && index <= 4
          index = 6
        elsif [7, 8].include?(index)
          index += 1
        end
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::ACTION)
        index = 8
        pbPlayCursorSE if index != oldindex
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE if index != 9
        case index
        when 0   # Choose sort order
          newparam = pbDexSearchCommands(0, [params[0]], index)
          params[0] = newparam[0] if newparam
          pbRefreshDexSearch(params, index)
        when 1   # Filter by name
          newparam = pbDexSearchCommands(1, [params[1]], index)
          params[1] = newparam[0] if newparam
          pbRefreshDexSearch(params, index)
        when 2   # Filter by type
          newparam = pbDexSearchCommands(2, [params[2], params[3]], index)
          if newparam
            params[2] = newparam[0]
            params[3] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 3   # Filter by height range
          newparam = pbDexSearchCommands(3, [params[4], params[5]], index)
          if newparam
            params[4] = newparam[0]
            params[5] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 4   # Filter by weight range
          newparam = pbDexSearchCommands(4, [params[6], params[7]], index)
          if newparam
            params[6] = newparam[0]
            params[7] = newparam[1]
          end
          pbRefreshDexSearch(params, index)
        when 5   # Filter by color filter
          newparam = pbDexSearchCommands(5, [params[8]], index)
          params[8] = newparam[0] if newparam
          pbRefreshDexSearch(params, index)
        when 6   # Filter by shape
          newparam = pbDexSearchCommands(6, [params[9]], index)
          params[9] = newparam[0] if newparam
          pbRefreshDexSearch(params, index)
        when 7   # Clear filters
          10.times do |i|
            params[i] = (i == 0) ? MODENUMERICAL : -1
          end
          pbRefreshDexSearch(params, index)
        when 8   # Start search (filter)
          dexlist = pbSearchDexList(params)
          if dexlist.length == 0
            pbMessage(_INTL("No matching Pokémon were found."))
          else
            @dexlist = dexlist
            @sprites["pokedex"].commands = @dexlist
            @sprites["pokedex"].index    = 0
            @sprites["pokedex"].refresh
            @searchResults = true
            @searchParams = params
            break
          end
        when 9   # Cancel
          pbPlayCloseMenuSE
          break
        end
      end
    end
    pbFadeOutAndHide(@sprites)
    if @searchResults
      @sprites["background"].setBitmap("Graphics/UI/Pokedex/bg_listsearch")
    else
      @sprites["background"].setBitmap("Graphics/UI/Pokedex/bg_list")
    end
    pbRefresh
    pbFadeInAndShow(@sprites, oldsprites)
    Input.update
    return 0
  end

  def pbPokedex
    pbActivateWindow(@sprites, "pokedex") do
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        if oldindex != @sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbPlayDecisionSE
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          if @searchResults
            pbPlayCancelSE
            pbCloseSearch
          else
            pbPlayCloseMenuSE
            break
          end
        elsif Input.trigger?(Input::USE)
          if $player.seen?(@sprites["pokedex"].species)
            pbPlayDecisionSE
            pbDexEntry(@sprites["pokedex"].index)
          end
        end
      end
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbPokedex
    @scene.pbEndScene
  end
end
