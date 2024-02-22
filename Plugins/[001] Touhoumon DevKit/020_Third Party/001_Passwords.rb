if defined?(PluginManager) && !PluginManager.installed?("Passwords in Events")
  PluginManager.register({                                                 
    :name    => "Passwords in Events",                                        
    :version => "1.0",                                                     
    :link    => "https://reliccastle.com/resources/18/",             
    :credits => "Mr. Gela"
  })
end

class Player < Trainer
  attr_accessor :dlwruukoto
  attr_accessor :next_wild_shiny
  attr_accessor	:puppet_orbs_200
  attr_accessor	:reincarnation_items
#  attr_accessor	:derx_rebattle
#  attr_accessor	:sariel_fight
end

#class Game_Temp
#  attr_accessor :next_wild_shiny
#end

def pbPasswordCheck(helptext = "Input Password", minlength = 0, maxlength = 12, casesensitive = false)
  passwords = [
  # --- Pokemon and Puppet Distributions ---
	"retribution",			# Dark Last Word Ruukoto
	
  # --- Item Distributions ---
	"20161118",				# 200 Puppet Orbs
	"rahnwasright",			# Full set of Reincarnation Items
	
  # --- Utility and Quality of Life ---
	"moreshiny",			# Next Wild Encounter is shiny
	"debmodeon",			# Enables Debug Mode
	"debmodeoff",			# Disables Debug Mode
	"debmodestate",			# Toggles the activation state of Debug Mode
	
  # --- Difficulty Altering ---
	
  # --- Shenanigans ---
	"abysswalker",			# Toggles the Derx/Amira rebattle atop the Abandoned Shrine
	"civofmagic"			# Toggles a wild Sariel Puppet atop the Abandoned Shrine

  ]    
  code = pbEnterText(helptext, minlength, maxlength)
  if passwords.include?(code)
  #if code == password || (casesensitive == false && code.downcase == password.downcase)
    case code
	# --- DLwRuukoto ---
	when "retribution"
	  if $player.dlwruukoto
		pbMessage(_INTL("...\\wt[20]No response."))
		return false
	  else
		$game_player.animation_id = 003
		pbMessage(_INTL("\\bWARNING. CORRUPT DATA LOADED. PLEASE CONTACT SILPH CO. FOR EMERGENCY MAINT-\\wtnp[1]"))
		pbWait(20)
		pbSEPlay("PC open")
		pbMessage(_INTL("\\rSystem rebooted. Remote control granted. Please enter trainer ID."))
		pbWait(20)
		pbMessage(_INTL("\\rID confirmed. Distributing gift, \"The Destructor\". Please ensure you have room in your party or box before accepting."))
		if pbConfirmMessage(_INTL("\\rAre you capable of recieving this gift?"))
		  pkmn=Pokemon.new(:RUUKOTO,50)
		  pkmn.name = "DLwRuukoto"
		  pkmn.item = :LEFTOVERS
		  pkmn.form = 1         # DLwRuukoto
		  pkmn.ability = :RETRIBUTION
		  pkmn.nature = :MODEST
		  pkmn.gender = nil
		  pkmn.owner.id = $Trainer.make_foreign_ID
		  pkmn.owner.name = "The Collector"
		  pkmn.iv[:HP]=31
		  pkmn.iv[:ATTACK]=31
		  pkmn.iv[:DEFENSE]=31
		  pkmn.iv[:SPECIAL_ATTACK]=0
		  pkmn.iv[:SPECIAL_DEFENSE]=31
		  pkmn.iv[:SPEED]=31
		  pkmn.calc_stats
		  pkmn.learn_move(:TOXIC18)
		  pkmn.learn_move(:WISH18)
		  pkmn.learn_move(:MAGICCOAT18)
		  pkmn.learn_move(:CHECKMAID)
		  pkmn.record_first_moves
		  pbAddPokemonSilent(pkmn)
		  pbMEPlay("Battle capture success")
		  pbMessage(_INTL("DLwRuukoto joined \\pn's team!\\wtnp[80]"))
		  pbMessage(_INTL("\\rThank you for using Oracle Encryption Software. Goodbye."))
		  pbSEPlay("PC close")
		  $player.dlwruukoto = true
		  return true
		else
		  return false
		end
	  end	
	# --- 200x Puppet Orbs ---
	when "20161118"
	  if $player.puppet_orbs_200
		pbMessage(_INTL("\\bYou have already redeemed the code for 200 Puppet Orbs. This code cannot be used again."))
		return false
	  else
		pbMessage(_INTL("\\bThis code will give you 200 Puppet Orbs."))
		pbMessage(_INTL("\\bOnce claimed, you will not be able to renew this code again."))
		if pbConfirmMessage(_INTL("\\bWould you like to claim this code??"))
		  pbReceiveItem(:PUPPETORB,200)
		  $player.puppet_orbs_200 = true
		  return true
		else
		  return false
		end
	  end
	# --- Reincarnation Items ---
	when "rahnwasright"
	  if $player.reincarnation_items
		pbMessage(_INTL("\\bYou have already redeemed the code for the Reincarnation Items. This code cannot be used again."))
		return false
	  else
		pbMessage(_INTL("\\bThis code will give you a full set of items for the Reincarnation System."))
		pbMessage(_INTL("\\bOnce claimed, you will not be able to renew this code again."))
		if pbConfirmMessage(_INTL("\\bWould you like to claim this code??"))
		  pbReceiveItem(:GOLDSTONE)
		  pbReceiveItem(:REDSTONE)
		  pbReceiveItem(:BLUESTONE)
		  pbReceiveItem(:BLACKSTONE)
		  pbReceiveItem(:WHITESTONE)
		  pbReceiveItem(:GREENSTONE)
		  pbReceiveItem(:RAINBOWSTONE)
		  pbReceiveItem(:REDMARK)
		  pbReceiveItem(:BLUEMARK)
		  pbReceiveItem(:BLACKMARK)
		  pbReceiveItem(:WHITEMARK)
		  pbReceiveItem(:GREENMARK)
		  pbReceiveItem(:GREYMARK)
		  $player.reincarnation_items = true
		  return true
		else
		  return false
		end
	  end
	# --- Next Wild Encounter is Shiny ---
	when "moreshiny"
	  pbMessage(_INTL("\\bThis code will make the next Wild Encounter be shiny."))
	  pbMessage(_INTL("\\bThis code can be reapplied however many times you like."))
	  if pbConfirmMessage(_INTL("\\bWould you like to claim this code??"))
		pbMessage(_INTL("\\bThe next Wild Encounter will be Shiny."))
		$player.next_wild_shiny = true
		$game_switches[Settings::SHINY_WILD_POKEMON_SWITCH] = true
		return true
	  else
		return false
	  end
	# --- Enable/Disable Debug Mode for Testers ---
	when "debmodestate"
	  pbMessage(_INTL("\\rThis code will toggle Debug Mode on or off."))
	  pbMessage(_INTL("\\rThis code is to be used exclusively by testers."))
	  pbMessage(_INTL("\\rPlease use this code responsibly. If something breaks because of Debug Mode Shenanigans, that is (almost always) not my problem."))
	  if $DEBUG == false
		if pbConfirmMessage(_INTL("\\rWould you like to enable Debug Mode?"))
		  pbMessage(_INTL("\\rDebug Mode has been enabled."))
		  $DEBUG == true
		  return true
		else
		  return false
		end
	  else
	    if pbConfirmMessage(_INTL("\\rWould you like to disable Debug Mode?"))
		  pbMessage(_INTL("\\rDebug Mode has been disabled."))
		  $DEBUG == false
		  return true
		else
		  return false
		end
	  end
	# --- Rebattle Derxwna (or Amira, if you were lucky) ---
	when "abysswalker"
	  if $game_switches[85] == false
		pbMessage(_INTL("\\bConditions not met to activate this password. Please try again later."))
		return false
	  elsif $game_switches[84] == true
		pbMessage(_INTL("\\bThe Mulberry Village Gym Leader is awaiting your rebattle atop the Abandoned Shrine."))
		pbMessage(_INTL("\\bThis code cannot be used right now."))
		return false
	  else
		pbMessage(_INTL("\\bThis code will allow you to rebattle the Mulberry Village Gym Leader."))
		pbMessage(_INTL("\\bThis code can be reapplied however many times you like, provided they are not awaiting a rebattle."))
		if pbConfirmMessage(_INTL("\\bWould you like to activate this code?"))
		  pbMessage(_INTL("\\bThe Mulberry Village Gym Leader will be awaiting your rebattle atop the Abandoned Shrine."))
		  $game_switches[84] = true
		  return true
		else
		  return false
		end
	  end
	# --- Battle a wild Sariel ---
	when "civofmagic"
	  if $game_switches[81] == true
		pbMessage(_INTL("\\bA Sariel is already present at the Abandoned Shrine."))
		pbMessage(_INTL("\\bThis code cannot be used right now."))
		return false
	  else
		pbMessage(_INTL("\\bThis code will spawn a Level 65 Sariel Puppet at the Abandoned Shrine."))
		pbMessage(_INTL("\\bThis code can be reapplied however many times you like, provided there is not one there already."))
		if pbConfirmMessage(_INTL("\\bWould you like to activate this code?"))
		  pbMessage(_INTL("\\bA Sariel can now be found at the Abandoned Shrine."))
		  $game_switches[81] = true
		  return true
		else
		  return false
		end
	  end
	# --- End of Passwords ---  
	end
  else
    pbMessage(_INTL("Invalid Password. Please try again."))
    return false
  end
end