class Splash_Devs_1 < EventScene
  BASECOLOR = Color.new(248, 248, 248)
  SHADOWCOLOR = Color.new(72, 72, 72)
  TEXT = [
    [
      "Touhoumon Essentials",
      "2011-2023 DerxwnaKapsyla",
	  "2011-2022 ChaoticInfinity",
	  "2020-2023 Overseer Household"
    ],
    :wait, 140,
    :clear,
    :wait, 8,
    [
      "Pokémon Essentials",
	  "2011-2023 Maruno",
	  "2007-2010 Peter O.",
	  "Based on work by Flameguru"
    ],
    :wait, 140,
    :clear,
    :wait, 8,
    [
      "mkxp-z",
	  "",
	  "Roza",
	  "Based on mkxp by Ancurio et al."
    ],
    :wait, 140,
    :clear
  ]

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 999999999
    @text = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@text.bitmap)
    @idx = 0
	@skipped = false
  end

  def main
    while @idx < self.class::TEXT.size
      if self.class::TEXT[@idx] == :wait
        wait_time = (self.class::TEXT[@idx + 1] * (Graphics.frame_rate/40.0)).to_i
        wait_time.times do
          return @skipped if update_or_skip
        end
        @idx += 2
      elsif self.class::TEXT[@idx] == :clear
        (Graphics.frame_rate/10 * 4).times do
          return @skipped if update_or_skip
          @text.opacity -= 255/(Graphics.frame_rate/10 * 4)
        end
        @text.opacity = 0
        @idx += 1
      elsif self.class::TEXT[@idx].is_a?(Array)
        @text.opacity = 0
        lines = self.class::TEXT[@idx]
        @text.bitmap.clear
        for i in 0...lines.size
          y = [
            nil,
            [-16],
            [-26, 6],
            [-48, -16, 16],
            [-64, -32, 0, 32]
          ][lines.size][i]
          pbDrawTextPositions(@text.bitmap, [[
            lines[i],
            Graphics.width / 2,
            Graphics.height / 2 + y,
            2,
            self.class::BASECOLOR,
            self.class::SHADOWCOLOR
          ]])
        end
        (Graphics.frame_rate/10 * 8).times do
          return @skipped if update_or_skip
          @text.opacity += 255/(Graphics.frame_rate/10 * 8)
        end
        @text.opacity = 255
        @idx += 1
      end
    end
    (Graphics.frame_rate/10 * 8).times do
      return @skipped if update_or_skip
      @text.opacity -= 255/(Graphics.frame_rate/10 * 8)
    end
    @text.opacity = 0
    dispose
	  return @skipped
  end

  def update_or_skip
    if Input.press?(Input::USE)
      @text.opacity = 0
      dispose
	    @skipped = true
      return true
    else
      Input.update
      Graphics.update
      return false
    end
  end

  def dispose
    @text.dispose
    @viewport.dispose
  end
end

# ---------------------------