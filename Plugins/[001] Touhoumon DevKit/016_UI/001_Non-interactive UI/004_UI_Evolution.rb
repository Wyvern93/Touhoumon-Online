#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Made the scene more accurate by adding audio before evolution
#	* Changed the theme used for the evolution scene
#==============================================================================#
class PokemonEvolutionScene
  def pbEvolution(cancancel = true)
    pbBGMStop
    pbMEPlay("Evolution start")
    pbMessageDisplay(@sprites["msgwindow"], "\\se[]" + _INTL("What?") + "\\1") { pbUpdate }
    pbPlayDecisionSE
    @pokemon.play_cry
    @sprites["msgwindow"].text = _INTL("{1} is evolving!", @pokemon.name)
    timer_start = System.uptime
    loop do
      Graphics.update
      Input.update
      pbUpdate
      break if System.uptime - timer_start >= 1
    end
    pbBGMPlay("U-002. Our Hisou Tensoku (Evolution)")
    canceled = false
    loop do
      pbUpdateNarrowScreen(timer_start)
      @picture1.update
      setPictureSprite(@sprites["rsprite1"], @picture1)
      if @sprites["rsprite1"].zoom_x > 1.0
        @sprites["rsprite1"].zoom_x = 1.0
        @sprites["rsprite1"].zoom_y = 1.0
      end
      @picture2.update
      setPictureSprite(@sprites["rsprite2"], @picture2)
      if @sprites["rsprite2"].zoom_x > 1.0
        @sprites["rsprite2"].zoom_x = 1.0
        @sprites["rsprite2"].zoom_y = 1.0
      end
      Graphics.update
      Input.update
      pbUpdate(true)
      if Input.trigger?(Input::BACK) && cancancel
        pbBGMStop
        pbPlayCancelSE
        canceled = true
        break
      end
      break if !@picture1.running? && !@picture2.running?
    end
    pbFlashInOut(canceled)
    if canceled
      $stats.evolutions_cancelled += 1
      pbMessageDisplay(@sprites["msgwindow"],
                       _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
    else
      pbEvolutionSuccess
    end
  end
end