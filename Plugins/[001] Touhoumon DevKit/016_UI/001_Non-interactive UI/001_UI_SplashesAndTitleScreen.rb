#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Modified the graphics used in the Title and Splash Screen
#==============================================================================#
class IntroEventScene < EventScene
  SPLASH_IMAGES         = ["splash_logo"]
  TITLE_BG_IMAGE        = 'splash'
  TITLE_START_IMAGE     = 'start'
  
  def initialize(viewport = nil)
    super(viewport)
    @pic = addImage(0, 0, "")
    @pic.setOpacity(0, 0)        # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0, 0, "")   # flashing "Press Enter" picture
    @pic2.setOpacity(0, 0)       # set opacity to 0 after waiting 0 frames
    @index = 0
	pbBGMPlay($data_system.title_bgm) # Derx: I want old functionality back!!!
    if SPLASH_IMAGES.empty?
      open_title_screen(self, nil)
    else
      open_splash(self, nil)
    end
  end
  
  def close_splash(scene, args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0, FADE_TICKS, 0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index >= SPLASH_IMAGES.length
      show_intro_text(scene, args)
    else
      open_splash(scene, args)
    end
  end

  def show_intro_text(_scene, *args)
    onCTrigger.clear
	#pbBGMPlay("FRLG 71 Epilogue.ogg")
	scene = Splash_Devs_1.new
    skip = scene.main
	#if !skip
	#  pbWait(10)
	#  Game_Boot_Scene_2.new
	#  pbWait(10)
	#end
    #pbBGMFade(1)
	hide_intro_text(_scene, args)   # called when C key is pressed
  end
  
  def hide_intro_text(scene, args)
    onUpdate.clear
    onCTrigger.clear
    open_title_screen(scene, args)
  end
  
  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
	#pbBGMPlay($data_system.title_bgm)
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
    pictureWait
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end
end