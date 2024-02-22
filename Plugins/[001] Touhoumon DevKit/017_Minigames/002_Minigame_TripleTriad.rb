#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Modifies the price of Triple Triad cards, as they use coins instead of
#	  cash.
#==============================================================================#
class TriadCard
  def price
    maxValue = [@north, @east, @south, @west].max
    ret = (@north * @north) + (@east * @east) + (@south * @south) + (@west * @west)
    ret += maxValue * maxValue * 2
    ret *= maxValue
    ret *= (@north + @east + @south + @west)
    ret /= 10   # Ranges from 2 to 24,000
    # Quantize prices to the next highest "unit"
    if ret > 10_000
      ret = (1 + (ret / 1000)) * 500
    elsif ret > 5000
      ret = (1 + (ret / 500)) * 250
    elsif ret > 1000
      ret = (1 + (ret / 100)) * 50
    elsif ret > 500
      ret = (1 + (ret / 50)) * 25
    else
      ret = (1 + (ret / 10)) * 10
    end
    return ret
  end
end

#==============================================================================#
# Changes in this section include the following:
#	* Changes a few stirngs to say coins instead of money.
#	* Changes the Triad price to coins, mechanically.
#==============================================================================#
def pbBuyTriads
  commands = []
  realcommands = []
  GameData::Species.each_species do |s|
    next if !$player.owned?(s.species)
    price = TriadCard.new(s.id).price
    commands.push([price, s.name, _INTL("{1} - {2} Coins", s.name, price.to_s_formatted), s.id])
  end
  if commands.length == 0
    pbMessage(_INTL("There are no cards that you can buy."))
    return
  end
  commands.sort! { |a, b| a[1] <=> b[1] }   # Sort alphabetically
  commands.each do |command|
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4, 3, 5)
  cmdwindow = Window_CommandPokemonEx.newWithSize(realcommands, 0, 0, Graphics.width / 2, Graphics.height)
  cmdwindow.z = 99999
  goldwindow = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Coins:\n{1}", $player.coins.to_s_formatted), 0, 0, 32, 32
  )
  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.x = Graphics.width - goldwindow.width
  goldwindow.y = 0
  goldwindow.z = 99999
  preview = Sprite.new
  preview.x = (Graphics.width * 3 / 4) - 40
  preview.y = (Graphics.height / 2) - 48
  preview.z = 4
  preview.bitmap = TriadCard.new(commands[cmdwindow.index][3]).createBitmap(1)
  olditem = commands[cmdwindow.index][3]
  Graphics.frame_reset
  loop do
    Graphics.update
    Input.update
    cmdwindow.active = true
    cmdwindow.update
    goldwindow.update
    if commands[cmdwindow.index][3] != olditem
      preview.bitmap&.dispose
      preview.bitmap = TriadCard.new(commands[cmdwindow.index][3]).createBitmap(1)
      olditem = commands[cmdwindow.index][3]
    end
    if Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::USE)
      price    = commands[cmdwindow.index][0]
      item     = commands[cmdwindow.index][3]
      itemname = commands[cmdwindow.index][1]
      cmdwindow.active = false
      cmdwindow.update
      if $player.coins < price
        pbMessage(_INTL("You don't have enough coins."))
        next
      end
      maxafford = (price <= 0) ? 99 : $player.coins.to_s_formatted / price
      maxafford = 99 if maxafford > 99
      params = ChooseNumberParams.new
      params.setRange(1, maxafford)
      params.setInitialValue(1)
      params.setCancelValue(0)
      quantity = pbMessageChooseNumber(
        _INTL("The {1} card? Certainly. How many would you like?", itemname), params
      )
      next if quantity <= 0
      price *= quantity
      next if !pbConfirmMessage(_INTL("{1}, and you want {2}. That will be {3} Coins. OK?", itemname, quantity, price.to_s_formatted))
      if $player.coins < price
        pbMessage(_INTL("You don't have enough coins."))
        next
      end
      if !$PokemonGlobal.triads.can_add?(item, quantity)
        pbMessage(_INTL("You have no room for more cards."))
        next
      end
      $PokemonGlobal.triads.add(item, quantity)
      $player.coins -= price
      goldwindow.text = _INTL("Coins:\r\n{1}", $player.coins.to_s_formatted)
      pbMessage(_INTL("Here you are! Thank you!") + "\\se[Mart buy item]")
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  preview.bitmap&.dispose
  preview.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6, 3, 5)
end

def pbSellTriads
  total_cards = 0
  commands = []
  $PokemonGlobal.triads.length.times do |i|
    item = $PokemonGlobal.triads[i]
    speciesname = GameData::Species.get(item[0]).name
    commands.push(_INTL("{1} x{2}", speciesname, item[1]))
    total_cards += item[1]
  end
  commands.push(_INTL("CANCEL"))
  if total_cards == 0
    pbMessage(_INTL("You have no cards."))
    return
  end
  # Scroll right before showing screen
  pbScrollMap(4, 3, 5)
  cmdwindow = Window_CommandPokemonEx.newWithSize(commands, 0, 0, Graphics.width / 2, Graphics.height)
  cmdwindow.z = 99999
  goldwindow = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Coins:\r\n{1}", $player.coins.to_s_formatted), 0, 0, 32, 32
  )
  goldwindow.resizeToFit(goldwindow.text, Graphics.width)
  goldwindow.x = Graphics.width - goldwindow.width
  goldwindow.y = 0
  goldwindow.z = 99999
  preview = Sprite.new
  preview.x = (Graphics.width * 3 / 4) - 40
  preview.y = (Graphics.height / 2) - 48
  preview.z = 4
  item = $PokemonGlobal.triads.get_item(cmdwindow.index)
  preview.bitmap = TriadCard.new(item).createBitmap(1)
  olditem = $PokemonGlobal.triads.get_item(cmdwindow.index)
  done = false
  Graphics.frame_reset
  until done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active = true
      cmdwindow.update
      goldwindow.update
      item = $PokemonGlobal.triads.get_item(cmdwindow.index)
      if olditem != item
        preview.bitmap&.dispose
        preview.bitmap = TriadCard.new(item).createBitmap(1) if item
        olditem = item
      end
      if Input.trigger?(Input::BACK)
        done = true
        break
      end
      if Input.trigger?(Input::USE)
        if cmdwindow.index >= $PokemonGlobal.triads.length
          done = true
          break
        end
        item = $PokemonGlobal.triads.get_item(cmdwindow.index)
        itemname = GameData::Species.get(item).name
        quantity = $PokemonGlobal.triads.quantity(item)
        price = TriadCard.new(item).price
        if price == 0
          pbDisplayPaused(_INTL("The {1} card? Oh, no. I can't buy that.", itemname))
          break
        end
        cmdwindow.active = false
        cmdwindow.update
        if quantity > 1
          params = ChooseNumberParams.new
          params.setRange(1, quantity)
          params.setInitialValue(1)
          params.setCancelValue(0)
          quantity = pbMessageChooseNumber(
            _INTL("The {1} card? How many would you like to sell?", itemname), params
          )
        end
        if quantity > 0
          price /= 4
          price *= quantity
          if pbConfirmMessage(_INTL("I can pay {1} Coins. Would that be OK?", price.to_s_formatted))
            $player.coins += price
            goldwindow.text = _INTL("Coins:\r\n{1}", $player.coins.to_s_formatted)
            $PokemonGlobal.triads.remove(item, quantity)
            pbMessage(_INTL("Turned over the {1} card and received {2} Coins.\\se[Mart buy item]", itemname, $player.coins.to_s_formatted))
            commands = []
            $PokemonGlobal.triads.length.times do |i|
              item = $PokemonGlobal.triads[i]
              speciesname = GameData::Species.get(item[0]).name
              commands.push(_INTL("{1} x{2}", speciesname, item[1]))
            end
            commands.push(_INTL("CANCEL"))
            cmdwindow.commands = commands
            break
          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  preview.bitmap&.dispose
  preview.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6, 3, 5)
end