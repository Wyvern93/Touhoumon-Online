#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Additions to the Overworld Weather to make it so it plays an audio file
#	  depending on the weather effect.
#==============================================================================#
class Battle::Scene
  def pbFindMoveAnimation(moveID, idxUser, hitNum)
    begin
      move2anim = pbLoadMoveToAnim
      # Find actual animation requested (an opponent using the animation first
      # looks for an OppMove version then a Move version)
      anim = pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
      return anim if anim
      # Actual animation not found, get the default animation for the move's type
      moveData = GameData::Move.get(moveID)
      target_data = GameData::Target.get(moveData.target)
      moveType = moveData.type
      moveKind = moveData.category
      moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
      moveKind += 3 if moveData.status? && target_data.num_targets > 0
      # [one target physical, one target special, user status,
      #  multiple targets physical, multiple targets special, non-user status]
      typeDefaultAnim = {
        :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,  :SWIFT,        :TAILWHIP],
        :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,         nil,           nil],
        :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,    :FEATHERDANCE],
        :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,         :POISONPOWDER],
        :GROUND   => [:SANDTOMB,     :MUDSLAP,      nil,          :EARTHQUAKE, :EARTHPOWER,   :MUDSPORT],
        :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  nil,           :SANDSTORM],
        :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,  :STRINGSHOT],
        :GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,         nil,           :CONFUSERAY],
        :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,           :METALSOUND],
        :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,   :WILLOWISP],
        :WATER    => [:CRABHAMMER,   :WATERGUN,     :AQUARING,    nil,         :SURF,         :WATERSPORT],
        :GRASS    => [:VINEWHIP,     :MEGADRAIN,    :COTTONGUARD, :RAZORLEAF,  nil,           :SPORE],
        :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,    :THUNDERWAVE],
        :PSYCHIC  => [:ZENHEADBUTT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE, :MIRACLEEYE],
        :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,         :POWDERSNOW,   :HAIL],
        :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,      nil],
        :DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,        :EMBARGO],
        :FAIRY    => [:TACKLE,       :FAIRYWIND,    :MOONLIGHT,   nil,         :SWIFT,        :SWEETKISS],
		
        :ILLUSION18   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,  :SWIFT,        :TAILWHIP],
        :DREAM18	  => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,         nil,           nil],
        :FLYING18     => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,    :FEATHERDANCE],
        :MIASMA18     => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,         :POISONPOWDER],
        :EARTH18      => [:SANDTOMB,     :MUDSLAP,      nil,          :EARTHQUAKE, :EARTHPOWER,   :MUDSPORT],
        :BEAST18      => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  nil,           :SANDSTORM],
        :HEART18      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,  :STRINGSHOT],
        :GHOST18      => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,         nil,           :CONFUSERAY],
        :STEEL18      => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,           :METALSOUND],
        :FIRE18       => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,   :WILLOWISP],
        :WATER18      => [:CRABHAMMER,   :WATERGUN,     :AQUARING,    nil,         :SURF,         :WATERSPORT],
        :NATURE18     => [:VINEWHIP,     :MEGADRAIN,    :COTTONGUARD, :RAZORLEAF,  nil,           :SPORE],
        :WIND18		  => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,    :THUNDERWAVE],
        :REASON18	  => [:ZENHEADBUTT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE, :MIRACLEEYE],
        :ICE18	      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,         :POWDERSNOW,   :HAIL],
        :FAITH18      => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,      nil],
        :DARK18	      => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,        :EMBARGO]
      }
      if typeDefaultAnim[moveType]
        anims = typeDefaultAnim[moveType]
        if GameData::Move.exists?(anims[moveKind])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
        end
        if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
        end
        if !anim && GameData::Move.exists?(anims[2])
          anim = pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
        end
      end
      return anim if anim
      # Default animation for the move's type not found, use Tackle's animation
      if GameData::Move.exists?(:TACKLE)
        return pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
      end
    rescue
    end
    return nil
  end
end