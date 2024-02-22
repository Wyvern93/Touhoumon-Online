#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to code to allow icons to show up in the Choice Selection Box
#==============================================================================#
class Window_DrawableCommand < SpriteWindow_SelectableEx

  def textWidth(bitmap, text)
    return bitmap.text_size(text).width
  end

  def getAutoDims(commands, dims, width = nil)
    rowMax = ((commands.length + self.columns - 1) / self.columns).to_i
    windowheight = (rowMax * self.rowHeight)
    windowheight += self.borderY
    if !width || width < 0
      width = 0
      tmpbitmap = Bitmap.new(1, 1)
      pbSetSystemFont(tmpbitmap)
      commands.each do |i|
        width = [width, tmpbitmap.text_size(i).width].max
      end
      # one 16 to allow cursor
      width += 16 + 16 + SpriteWindow_Base::TEXT_PADDING
      tmpbitmap.dispose
    end
    # Store suggested width and height of window
    dims[0] = [self.borderX + 1,
               (width * self.columns) + self.borderX + ((self.columns - 1) * self.columnSpacing)].max
    dims[1] = [self.borderY + 1, windowheight].max
    dims[1] = [dims[1], Graphics.height].min
  end
end
#=============================================================================#