#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Made it so that a Thunder sound effect plays on occasion between
#	  lightning flashes. From the Overworld Weather Sound Effect plugin.
#==============================================================================#
module RPG
  class Weather
    def update
      update_fading
      update_screen_tone
      # Storm flashes
      if @type == :Storm && !@fading
        if @time_until_flash > 0
          @time_until_flash -= Graphics.delta_s
          if @time_until_flash <= 0
            @viewport.flash(Color.new(255, 255, 255, 230), rand(2..4) * 20)
# ------ Derx: When raining, play some thunder!
			if rand(50)<25
              pbSEPlay("OWThunder1")
			elsif rand(50)>30
              pbSEPlay("OWThunder2")
			else
              return
			end
# ------ Derx: End of Thunder during Rain changes
          end
        end
        if @time_until_flash <= 0
          @time_until_flash = rand(1..12) * 0.5   # 0.5-6 seconds
        end
      end
      @viewport.update
      # Update weather particles (raindrops, snowflakes, etc.)
      if @weatherTypes[@type] && @weatherTypes[@type][1].length > 0
        ensureSprites
        MAX_SPRITES.times do |i|
          update_sprite_position(@sprites[i], i, false)
        end
      elsif @sprites.length > 0
        @sprites.each { |sprite| sprite&.dispose }
        @sprites.clear
      end
      # Update new weather particles (while fading in only)
      if @fading && @weatherTypes[@target_type] && @weatherTypes[@target_type][1].length > 0
        ensureSprites
        MAX_SPRITES.times do |i|
          update_sprite_position(@new_sprites[i], i, true)
        end
      elsif @new_sprites.length > 0
        @new_sprites.each { |sprite| sprite&.dispose }
        @new_sprites.clear
      end
      # Update weather tiles (sandstorm/blizzard tiled overlay)
      if @tiles_wide > 0 && @tiles_tall > 0
        ensureTiles
        recalculate_tile_positions
        @tiles.each_with_index { |sprite, i| update_tile_position(sprite, i) }
      elsif @tiles.length > 0
        @tiles.each { |sprite| sprite&.dispose }
        @tiles.clear
      end
    end
  end
end