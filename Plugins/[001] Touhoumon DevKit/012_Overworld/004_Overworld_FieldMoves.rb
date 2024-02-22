#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Removing explicit references to Pokemon
# 	* Adds in duplicate handlers for the Touhoumon variants of moves
#	* Made changes that should allow for alternate badges to be checked for HM
#	  moves.
#	* Dive's changes have been commented out as I just... don't plan to use it.
#==============================================================================#

#===============================================================================
# Cut
#===============================================================================
def pbCut
  movelist = [:CUT, :CUT18]
  move = nil
  movefinder = nil
  movelist.each do |m|
  	move = m
  	movefinder = $player.get_pokemon_with_move(m)
  	break if movefinder
  end
  if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, false) ||
  	   pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_CUT, false)) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("This tree looks like it can be cut down."))
    return false
  end
  if pbConfirmMessage(_INTL("This tree looks like it can be cut down!\nWould you like to cut it?"))
    $stats.cut_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, showmsg) ||
  				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_CUT, showmsg))
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/cuttree/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH, showmsg) ||
  				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_FLASH, showmsg))
  if !$game_map.metadata&.dark_map
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  if $PokemonGlobal.flashUsed
    pbMessage(_INTL("Flash is already being used.")) if showmsg
    next false
  end
  next true
})

#===============================================================================
# Fly
#===============================================================================
def pbCanFly?(pkmn = nil, show_messages = false)
  return false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLY, show_messages) ||
  					pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_FLY, show_messages))
  return false if !$DEBUG && !pkmn && !$player.get_pokemon_with_move(:FLY)
  if !$game_player.can_map_transfer_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if show_messages
    return false
  end
  if !$game_map.metadata&.outdoor_map
    pbMessage(_INTL("You can't use that here.")) if show_messages
    return false
  end
  return true
end

#===============================================================================
# Headbutt
#===============================================================================
def pbHeadbutt(event = nil)
  movelist = [:HEADBUTT, :HEADBUTT18]
  move = nil
  movefinder = nil
  movelist.each do |m|
	move = m
	movefinder = $player.get_pokemon_with_move(m)
	break if movefinder
  end
  if !$DEBUG && !movefinder
    pbMessage(_INTL("Something could be in this tree. Maybe it could be shaken."))
    return false
  end
  if pbConfirmMessage(_INTL("Something could be in this tree. Would you like to use Headbutt?"))
    $stats.headbutt_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbHeadbuttEffect(event)
    return true
  end
  return false
end

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmash
  movelist = [:ROCKSMASH, :ROCKSMASH18]
  move=nil
  movefinder=nil
  movelist.each do |m|
	move=m
	movefinder=$player.get_pokemon_with_move(m)
	break if movefinder
  end
  if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, false) ||
  	   pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_ROCKSMASH, false)) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a rugged rock, but it may be able to smash it."))
    return false
  end
  if pbConfirmMessage(_INTL("This rock seems breakable with a hidden move.\nWould you like to use Rock Smash?"))
    $stats.rock_smash_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, showmsg) ||
  				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_ROCKSMASH, showmsg))
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/smashrock/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

#===============================================================================
# Strength
#===============================================================================
def pbStrength
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength made it possible to move boulders around."))
    return false
  end
  movelist = [:STRENGTH, :STRENGTH18]
  move=nil
  movefinder=nil
  movelist.each do |m|
	move=m
	movefinder=$player.get_pokemon_with_move(m)
	break if movefinder
  end
  if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_STRENGTH, false) ||
  	   pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_STRENGTH, false)) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a big boulder, but it may be able to push it aside."))
    return false
  end
  pbMessage(_INTL("It's a big boulder, but you may be able to push it aside with a hidden move.\1"))
  if pbConfirmMessage(_INTL("Would you like to use Strength?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbMessage(_INTL("Strength made it possible to move boulders around!"))
    $PokemonMap.strengthUsed = true
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:STRENGTH, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_STRENGTH, showmsg) ||
				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_STRENGTH, showmsg))
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength is already being used.")) if showmsg
    next false
  end
  next true
})

#===============================================================================
# Surf
#===============================================================================
def pbSurf
  return false if $game_player.pbFacingEvent
  return false if !$game_player.can_ride_vehicle_with_follower?
  movelist = [:SURF, :SURF18]
  move=nil
  movefinder=nil
  movelist.each do |m|
	move=m
	movefinder=$player.get_pokemon_with_move(m)
	break if movefinder
  end
  if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, false) ||
  	   pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_SURF, false)) || (!$DEBUG && !movefinder)
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue color... Would you like to use Surf on it?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbCancelVehicles
    pbHiddenMoveAnimation(movefinder)
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm, 0.5) if surfbgm
    pbStartSurfing
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:SURF, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, showmsg) ||
				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_SURF, showmsg))
  if $PokemonGlobal.surfing
    pbMessage(_INTL("You're already surfing.")) if showmsg
    next false
  end
  if !$game_player.can_ride_vehicle_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    next false
  end
  if $game_map.metadata&.always_bicycle
    pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
    next false
  end
  if !$game_player.pbFacingTerrainTag.can_surf_freely ||
     !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
    pbMessage(_INTL("No surfing here!")) if showmsg
    next false
  end
  next true
})

#===============================================================================
# Waterfall
#===============================================================================
def pbWaterfall
  movelist = [:WATERFALL, :WATERFALL18]
  move=nil
  movefinder=nil
  movelist.each do |m|
	move=m
	movefinder=$Trainer.get_pokemon_with_move(m)
	break if movefinder
  end
  if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_WATERFALL, false) ||
  	   pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_WATERFALL, false)) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbAscendWaterfall
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:WATERFALL, proc { |move, pkmn, showmsg|
  next false if !(pbCheckHiddenMoveBadge(Settings::BADGE_FOR_WATERFALL, showmsg) ||
				  pbCheckHiddenMoveBadge(Settings::ALT_BADGE_FOR_WATERFALL, showmsg))
  if !$game_player.pbFacingTerrainTag.waterfall
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

#-----------------------------------------------------
# Duplicates by Derxwna
#-----------------------------------------------------
# --- Derx: Required for Touhoumon Field Move compatability
# --- Cut handler
HiddenMoveHandlers::CanUseMove.copy(:CUT,:CUT18)
HiddenMoveHandlers::UseMove.copy(:CUT,:CUT18)
# --- Dig handler
HiddenMoveHandlers::CanUseMove.copy(:DIG,:DIG18)
HiddenMoveHandlers::UseMove.copy(:DIG,:DIG18)
# --- Shadow Dive handler
HiddenMoveHandlers::CanUseMove.copy(:DIVE,:SHADOWDIVE18)
HiddenMoveHandlers::UseMove.copy(:DIVE,:SHADOWDIVE18)
# --- Flash handler
HiddenMoveHandlers::CanUseMove.copy(:FLASH,:FLASH18)
HiddenMoveHandlers::UseMove.copy(:FLASH,:FLASH18)
# --- Fly handler
HiddenMoveHandlers::CanUseMove.copy(:FLY,:FLY18)
HiddenMoveHandlers::UseMove.copy(:FLY,:FLY18)
# --- Headbutt handler
HiddenMoveHandlers::CanUseMove.copy(:HEADBUTT,:HEADBUTT18)
HiddenMoveHandlers::UseMove.copy(:HEADBUTT,:HEADBUTT18)
# --- Rock Smash handler
HiddenMoveHandlers::CanUseMove.copy(:ROCKSMASH,:ROCKSMASH18)
HiddenMoveHandlers::UseMove.copy(:ROCKSMASH,:ROCKSMASH18)
# --- Strength handler
HiddenMoveHandlers::CanUseMove.copy(:STRENGTH,:STRENGTH18)
HiddenMoveHandlers::UseMove.copy(:STRENGTH,:STRENGTH18)
# --- Surf handler
HiddenMoveHandlers::CanUseMove.copy(:SURF,:SURF18)
HiddenMoveHandlers::UseMove.copy(:SURF,:SURF18)
# --- Nature Power handler
HiddenMoveHandlers::CanUseMove.copy(:SWEETSCENT,:NATUREPOWER18)
HiddenMoveHandlers::UseMove.copy(:SWEETSCENT,:NATUREPOWER18)
# --- Teleport handler
HiddenMoveHandlers::CanUseMove.copy(:TELEPORT,:TELEPORT18)
HiddenMoveHandlers::UseMove.copy(:TELEPORT,:TELEPORT18)
# --- Waterfall handler
HiddenMoveHandlers::CanUseMove.copy(:WATERFALL,:WATERFALL18)
HiddenMoveHandlers::UseMove.copy(:WATERFALL,:WATERFALL18)
# --- Derx: End of Touhoumon Field Move compatability