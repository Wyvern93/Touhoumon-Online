
class Battle::AI

#==============================================================================#
# Changes in this section include the following:
#	* Added various type interactions with ability absorption (NOT IMPLEMENTED)
#==============================================================================#
  def pokemon_can_absorb_move?(pkmn, move, move_type)
    return false if pkmn.is_a?(Battle::AI::AIBattler) && !pkmn.ability_active?
    # Check pkmn's ability
    # Anything with a Battle::AbilityEffects::MoveImmunity handler
    case pkmn.ability_id
    when :BULLETPROOF
      move_data = GameData::Move.get(move.id)
      return move_data.has_flag?("Bomb")
    when :FLASHFIRE
      return move_type == :FIRE
    when :LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB
      return move_type == :ELECTRIC
    when :SAPSIPPER
      return move_type == :GRASS
    when :SOUNDPROOF
      move_data = GameData::Move.get(move.id)
      return move_data.has_flag?("Sound")
    when :STORMDRAIN, :WATERABSORB, :DRYSKIN
      return move_type == :WATER
    when :TELEPATHY
      # NOTE: The move is being used by a foe of pkmn.
      return false
    when :WONDERGUARD
      types = pkmn.types
      types = pkmn.pbTypes(true) if pkmn.is_a?(Battle::AI::AIBattler)
      return !Effectiveness.super_effective_type?(move_type, *types)
    end
    return false
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added various interactions with Toxic Spikes
#==============================================================================#
  def pokemon_can_be_poisoned?(pkmn)
    # Check pkmn's immunity to being poisoned
    return false if @battle.field.terrain == :Misty
    return false if pkmn.hasType?(:POISON)
    return false if pkmn.hasType?(:STEEL)
    return false if pkmn.hasType?(:MIASMA18)
    return false if pkmn.hasType?(:STEEL18)
    return false if pkmn.hasAbility?(:IMMUNITY)
    return false if pkmn.hasAbility?(:PASTELVEIL)
    return false if pkmn.hasAbility?(:FLOWERVEIL) && pkmn.hasType?(:GRASS)
    return false if pkmn.hasAbility?(:LEAFGUARD) && [:Sun, :HarshSun].include?(@battle.pbWeather)
    return false if pkmn.hasAbility?(:COMATOSE) && pkmn.isSpecies?(:KOMALA)
    return false if pkmn.hasAbility?(:SHIELDSDOWN) && pkmn.isSpecies?(:MINIOR) && pkmn.form < 7
    return true
  end

#==============================================================================#
# Changes in this section include the following:
#	* Added Aero to Airborne checks
#==============================================================================#  
  def pokemon_airborne?(pkmn)
    return false if pkmn.hasItem?(:IRONBALL)
    return false if @battle.field.effects[PBEffects::Gravity] > 0
    return true if pkmn.hasType?(:FLYING)
	return true if pkmn.hasType?(:FLYING18)
    return true if pkmn.hasAbility?(:LEVITATE)
    return true if pkmn.hasItem?(:AIRBALLOON)
    return false
  end
  
#==============================================================================#
# Changes in this section include the following:
#	* Added various abilities to these arrays
#==============================================================================#  
  BASE_ABILITY_RATINGS = {
    10 => [:DELTASTREAM, :DESOLATELAND, :HUGEPOWER, :MOODY, :PARENTALBOND,
           :POWERCONSTRUCT, :PRIMORDIALSEA, :PUREPOWER, :SHADOWTAG,
           :STANCECHANGE, :WONDERGUARD,
		   :DEATHLYFROST, :ARIDWASTES, :PLAYGHOST, :RETRIBUTION,
		   :FANTASYNATURE, :FANTASYNATURE_ALT, :UNZAN],
		   
    9  => [:ARENATRAP, :DRIZZLE, :DROUGHT, :IMPOSTER, :MAGICBOUNCE, :MAGICGUARD,
           :MAGNETPULL, :SANDSTREAM, :SPEEDBOOST,
		   :PIERCINGSTARE],
		   
    8  => [:ADAPTABILITY, :AERILATE, :CONTRARY, :DISGUISE, :DRAGONSMAW,
           :ELECTRICSURGE, :GALVANIZE, :GRASSYSURGE, :ILLUSION, :LIBERO,
           :MISTYSURGE, :MULTISCALE, :MULTITYPE, :NOGUARD, :POISONHEAL,
           :PIXILATE, :PRANKSTER, :PROTEAN, :PSYCHICSURGE, :REFRIGERATE,
           :REGENERATOR, :RKSSYSTEM, :SERENEGRACE, :SHADOWSHIELD, :SHEERFORCE,
           :SIMPLE, :SNOWWARNING, :TECHNICIAN, :TRANSISTOR, :WATERBUBBLE,
		   :SERAPHSWINGS],
		   
    7  => [:BEASTBOOST, :BULLETPROOF, :COMPOUNDEYES, :DOWNLOAD, :FURCOAT,
           :HUSTLE, :ICESCALES, :INTIMIDATE, :LEVITATE, :LIGHTNINGROD,
           :MEGALAUNCHER, :MOLDBREAKER, :MOXIE, :NATURALCURE, :SAPSIPPER,
           :SHEDSKIN, :SKILLLINK, :SOULHEART, :STORMDRAIN, :TERAVOLT, :THICKFAT,
           :TINTEDLENS, :TOUGHCLAWS, :TRIAGE, :TURBOBLAZE, :UNBURDEN,
           :VOLTABSORB, :WATERABSORB,
		   :GEHABURN, :FOCUS, :MAINTENANCE, :ICEWALL],
		   
    6  => [:BATTLEBOND, :CHLOROPHYLL, :COMATOSE, :DARKAURA, :DRYSKIN,
           :FAIRYAURA, :FILTER, :FLASHFIRE, :FORECAST, :GALEWINGS, :GUTS,
           :INFILTRATOR, :IRONBARBS, :IRONFIST, :MIRRORARMOR, :MOTORDRIVE,
           :NEUROFORCE, :PRISMARMOR, :QUEENLYMAJESTY, :RECKLESS, :ROUGHSKIN,
           :SANDRUSH, :SCHOOLING, :SCRAPPY, :SHIELDSDOWN, :SOLIDROCK, :STAKEOUT,
           :STAMINA, :STEELWORKER, :STRONGJAW, :STURDY, :SWIFTSWIM, :TOXICBOOST,
           :TRACE, :UNAWARE, :VICTORYSTAR,
		   :DOLLWALL, :LUCIDDREAMING, :FLOWOFTIME],
		   
    5  => [:AFTERMATH, :AIRLOCK, :ANALYTIC, :BERSERK, :BLAZE, :CLOUDNINE,
           :COMPETITIVE, :CORROSION, :DANCER, :DAZZLING, :DEFIANT, :FLAREBOOST,
           :FLUFFY, :GOOEY, :HARVEST, :HEATPROOF, :INNARDSOUT, :LIQUIDVOICE,
           :MARVELSCALE, :MUMMY, :NEUTRALIZINGGAS, :OVERCOAT, :OVERGROW,
           :PRESSURE, :QUICKFEET, :ROCKHEAD, :SANDSPIT, :SHIELDDUST, :SLUSHRUSH,
           :SWARM, :TANGLINGHAIR, :TORRENT,
		   :UNCONSCIOUS, :HISOUTEN, :INNERPOWER, :SPRINGCHARM],
		   
    4  => [:ANGERPOINT, :BADDREAMS, :CHEEKPOUCH, :CLEARBODY, :CURSEDBODY,
           :EARLYBIRD, :EFFECTSPORE, :FLAMEBODY, :FLOWERGIFT, :FULLMETALBODY,
           :GORILLATACTICS, :HYDRATION, :ICEFACE, :IMMUNITY, :INSOMNIA,
           :JUSTIFIED, :MERCILESS, :PASTELVEIL, :POISONPOINT, :POISONTOUCH,
           :RIPEN, :SANDFORCE, :SOUNDPROOF, :STATIC, :SURGESURFER, :SWEETVEIL,
           :SYNCHRONIZE, :VITALSPIRIT, :WATERCOMPACTION, :WATERVEIL,
           :WHITESMOKE, :WONDERSKIN,
		   :ABYSSALDRAIN, :BARRIER, :HAKUREIMIKO, :INFECTIOUS, :POISONBODY],
		   
    3  => [:AROMAVEIL, :AURABREAK, :COTTONDOWN, :DAUNTLESSSHIELD,
           :EMERGENCYEXIT, :GLUTTONY, :GULPMISSLE, :HYPERCUTTER, :ICEBODY,
           :INTREPIDSWORD, :LIMBER, :LIQUIDOOZE, :LONGREACH, :MAGICIAN,
           :OWNTEMPO, :PICKPOCKET, :RAINDISH, :RATTLED, :SANDVEIL,
           :SCREENCLEANER, :SNIPER, :SNOWCLOAK, :SOLARPOWER, :STEAMENGINE,
           :STICKYHOLD, :SUPERLUCK, :UNNERVE, :WIMPOUT,
		   :HISTRENGTH, :COLLECTOR, :STRANGEMIST],
		   
    2  => [:BATTLEARMOR, :COLORCHANGE, :CUTECHARM, :DAMP, :GRASSPELT,
           :HUNGERSWITCH, :INNERFOCUS, :LEAFGUARD, :LIGHTMETAL, :MIMICRY,
           :OBLIVIOUS, :POWERSPOT, :PROPELLORTAIL, :PUNKROCK, :SHELLARMOR,
           :STALWART, :STEADFAST, :STEELYSPIRIT, :SUCTIONCUPS, :TANGLEDFEET,
           :WANDERINGSPIRIT, :WEAKARMOR,
		   :MYSTERIOUS, :GATEKEEPER, :DIVA, :GUARDARMOR],
		   
    1  => [:BIGPECKS, :KEENEYE, :MAGMAARMOR, :PICKUP, :RIVALRY, :STENCH,
		   :GRAVEROBBER],
	
    0  => [:ANTICIPATION, :ASONECHILLINGNEIGH, :ASONEGRIMNEIGH, :BALLFETCH,
           :BATTERY, :CHILLINGNEIGH, :CURIOUSMEDICINE, :FLOWERVEIL, :FOREWARN,
           :FRIENDGUARD, :FRISK, :GRIMNEIGH, :HEALER, :HONEYGATHER, :ILLUMINATE,
           :MINUS, :PLUS, :POWEROFALCHEMY, :QUICKDRAW, :RECEIVER, :RUNAWAY,
           :SYMBIOSIS, :TELEPATHY, :UNSEENFIST,
		   :JEALOUSY, :POTATOHARVEST],
		   
    -1 => [:DEFEATIST, :HEAVYMETAL, :KLUTZ, :NORMALIZE, :PERISHBODY, :STALL,
           :ZENMODE],
		   
    -2 => [:SLOWSTART, :TRUANT,
	       :FRETFUL]
  }
  
#==============================================================================#
# Changes in this section include the following:
#	* Added various items to these arrays
#==============================================================================#  
  BASE_ITEM_RATINGS = {
    10 => [:EVIOLITE, :FOCUSSASH, :LIFEORB, :THICKCLUB,
	       :CURSEDRIBBON],
    9  => [:ASSAULTVEST, :BLACKSLUDGE, :CHOICEBAND, :CHOICESCARF, :CHOICESPECS,
           :DEEPSEATOOTH, :LEFTOVERS,
		   :POWERRIBBON, :POWERCAPE, :POWERGOGGLES, :KUSANAGI],
    8  => [:LEEK, :STICK, :THROATSPRAY, :WEAKNESSPOLICY],
    7  => [:EXPERTBELT, :LIGHTBALL, :LUMBERRY, :POWERHERB, :ROCKYHELMET,
           :SITRUSBERRY,
		   :ICEBALL, :BAKEDPOTATO],
    6  => [:KINGSROCK, :LIECHIBERRY, :LIGHTCLAY, :PETAYABERRY, :RAZORFANG,
           :REDCARD, :SALACBERRY, :SHELLBELL, :WHITEHERB,
           # Type-resisting berries
           :BABIRIBERRY, :CHARTIBERRY, :CHILANBERRY, :CHOPLEBERRY, :COBABERRY,
           :COLBURBERRY, :HABANBERRY, :KASIBBERRY, :KEBIABERRY, :OCCABERRY,
           :PASSHOBERRY, :PAYAPABERRY, :RINDOBERRY, :ROSELIBERRY, :SHUCABERRY,
           :TANGABERRY, :WACANBERRY, :YACHEBERRY,
		   :BABIRIPENDANT, :CHARTIPENDANT, :CHILANPENDANT, :CHOPLEPENDANT, :COBAPENDANT,
           :COLBURPENDANT, :HABANPENDANT, :KASIBPENDANT, :KEBIAPENDANT, :OCCAPENDANT,
           :PASSHOPENDANT, :PAYAPAPENDANT, :RINDOPENDANT, :ROSELIPENDANT, :SHUCAPENDANT,
           :TANGAPENDANT, :WACANPENDANT, :YACHEPENDANT,
           :ANTIBEAST, :ANTINATURE, :ANTIHEART, :ANTIUMBRAL, :ANTIWIND, :ANTIMIASMA,
           :ANTIHYDRO, :ANTIAERO, :ANTICRYO, :ANTINETHER, :ANTIREASON, :ANTIPYRO,
           :ANTIILLUSION, :ANTIFAITH, :ANTIDREAM,
           # Gems
           :BUGGEM, :DARKGEM, :DRAGONGEM, :ELECTRICGEM, :FAIRYGEM, :FIGHTINGGEM,
           :FIREGEM, :FLYINGGEM, :GHOSTGEM, :GRASSGEM, :GROUNDGEM, :ICEGEM,
           :NORMALGEM, :POISONGEM, :PSYCHICGEM, :ROCKGEM, :STEELGEM, :WATERGEM,
		   :BUGRIBBON, :DARKRIBBON, :DRAGONRIBBON, :ELECTRICRIBBON, :FIGHTINGRIBBON,
           :FIRERIBBON, :FLYINGRIBBON, :GHOSTRIBBON, :GRASSRIBBON, :GROUNDRIBBON, :ICERIBBON,
           :NORMALRIBBON, :POISONRIBBON, :PSYCHICRIBBON, :ROCKRIBBON, :STEELRIBBON, :WATERRIBBON,
		   :HEMATITE, :QUARTZ, :ONYX, :MALACHITE, :GOLD, :OBSIDIAN, :JADE, :AMETHYST, :AQUAMARINE,
		   :DIAMOND, :LAPISLAZULI, :SUGILITE, :OPAL, :GARNET, :MORGANITE, :TOPAZ, :MOONSTONEGEM,
		   :HEMATITEHAIRPIN, :QUARTZHAIRPIN, :ONYXHAIRPIN, :MALACHITEHAIRPIN, :GOLDHAIRPIN,
		   :OBSIDIANHAIRPIN, :JADEHAIRPIN, :AMETHYSTHAIRPIN, :AQUAMARINEHAIRPIN,
		   :DIAMONDHAIRPIN, :LAPISHAIRPIN, :SUGILITEHAIRPIN, :OPALHAIRPIN, :GARNETHAIRPIN,
		   :MORGANITEHAIRPIN, :TOPAZHAIRPIN, :MOONSTONEHAIRPIN,
           # Legendary Orbs
           :ADAMANTORB, :GRISEOUSORB, :LUSTROUSORB, :SOULDEW,
           # Berries that heal HP and may confuse
           :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY],
    5  => [:CUSTAPBERRY, :DEEPSEASCALE, :EJECTBUTTON, :FOCUSBAND, :JABOCABERRY,
           :KEEBERRY, :LANSATBERRY, :MARANGABERRY, :MENTALHERB, :METRONOME,
           :MUSCLEBAND, :QUICKCLAW, :RAZORCLAW, :ROWAPBERRY, :SCOPELENS,
           :WISEGLASSES,
		   :FOCUSRIBBON,:YATAMIRROR,
           # Type power boosters
           :BLACKBELT, :BLACKGLASSES, :CHARCOAL, :DRAGONFANG, :HARDSTONE,
           :MAGNET, :METALCOAT, :MIRACLESEED, :MYSTICWATER, :NEVERMELTICE,
           :POISONBARB, :SHARPBEAK, :SILKSCARF,:SILVERPOWDER, :SOFTSAND,
           :SPELLTAG, :TWISTEDSPOON,
           :ODDINCENSE, :ROCKINCENSE, :ROSEINCENSE, :SEAINCENSE, :WAVEINCENSE,
		   :MAIDCOSTUME, :SWEATER, :BUNNYSUIT, :CAMOUFLAGE, :BLAZER, :MISTRESS,
		   :NINJA, :NURSE, :SWIMSUIT, :STEWARDESS, :THICKFUR, :KIMONO, :WITCH,
		   :GOTHIC, :BRIDALGOWN, :PRIESTESS, :CHINADRESS,
           # Plates
           :DRACOPLATE, :DREADPLATE, :EARTHPLATE, :FISTPLATE, :FLAMEPLATE,
           :ICICLEPLATE, :INSECTPLATE, :IRONPLATE, :MEADOWPLATE, :MINDPLATE,
           :PIXIEPLATE, :SKYPLATE, :SPLASHPLATE, :SPOOKYPLATE, :STONEPLATE,
           :TOXICPLATE, :ZAPPLATE,
		   :DAMASCUSSPHERE, :TERRASPHERE, :FERALSPHERE, :GROWTHSPHERE, :TRUSTSPHERE,
		   :SINSPHERE, :GUTSSPHERE, :CORROSIONSPHERE, :FLOODSPHERE, :FLIGHTSPHERE,
		   :FROSTSPHERE, :SOULSPHERE, :KNOWLEDGESPHERE, :BLAZESPHERE, :VIRTUESPHERE,
		   :PHANTASMSPHERE,
           # Weather/terrain extenders
           :DAMPROCK, :HEATROCK, :ICYROCK, :SMOOTHROCK, :TERRAINEXTENDER],
    4  => [:ADRENALINEORB, :APICOTBERRY, :BLUNDERPOLICY, :CHESTOBERRY,
           :EJECTPACK, :ENIGMABERRY, :GANLONBERRY, :HEAVYDUTYBOOTS,
           :ROOMSERVICE, :SAFETYGOGGLES, :SHEDSHELL, :STARFBERRY],
    3  => [:BIGROOT, :BRIGHTPOWDER, :LAXINCENSE, :LEPPABERRY, :PERSIMBERRY,
           :PROTECTIVEPADS, :UTILITYUMBRELLA,
           # Status problem-curing berries (except Chesto which is in 4)
           :ASPEARBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY],
    2  => [:ABSORBBULB, :BERRYJUICE, :CELLBATTERY, :GRIPCLAW, :LUMINOUSMOSS,
           :MICLEBERRY, :ORANBERRY, :SNOWBALL, :WIDELENS, :ZOOMLENS,
		   :POTATO,
           # Terrain seeds
           :ELECTRICSEED, :GRASSYSEED, :MISTYSEED, :PSYCHICSEED],
    1  => [:AIRBALLOON, :BINDINGBAND, :DESTINYKNOT, :FLOATSTONE, :LUCKYPUNCH,
           :METALPOWDER, :QUICKPOWDER,
		   :NYUUDOUFIST,
           # Drives
           :BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE,
           # Memories
           :BUGMEMORY, :DARKMEMORY, :DRAGONMEMORY, :ELECTRICMEMORY,
           :FAIRYMEMORY, :FIGHTINGMEMORY, :FIREMEMORY, :FLYINGMEMORY,
           :GHOSTMEMORY, :GRASSMEMORY, :GROUNDMEMORY, :ICEMEMORY, :POISONMEMORY,
           :PSYCHICMEMORY, :ROCKMEMORY, :STEELMEMORY, :WATERMEMORY
           ],
    0  => [:SMOKEBALL],
    -5 => [:FULLINCENSE, :LAGGINGTAIL, :RINGTARGET],
    -6 => [:MACHOBRACE, :POWERANKLET, :POWERBAND, :POWERBELT, :POWERBRACER,
           :POWERLENS, :POWERWEIGHT],
    -7 => [:FLAMEORB, :IRONBALL, :TOXICORB],
    -9 => [:STICKYBARB]
  }
end

#==============================================================================#
# Changes in this section include the following:
#	* Various adjustments to abilities to account for Touhoumon variants
#==============================================================================#  
Battle::AI::Handlers::AbilityRanking.add(:BLAZE,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:FIRE)
	next score if battler.has_damaging_move_of_type?(:FIRE18)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:GALEWINGS,
  proc { |ability, score, battler, ai|
    next score if battler.check_for_move { |m| m.type == :FLYING }
	next score if battler.check_for_move { |m| m.type == :FLYING18 }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:OVERGROW,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:GRASS)
	next score if battler.has_damaging_move_of_type?(:NATURE18)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SANDFORCE,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:GROUND, :ROCK, :STEEL)
	next score if battler.has_damaging_move_of_type?(:EARTH18, :BEAST18, :STEEL18)
    next 2
  }
)

Battle::AI::Handlers::AbilityRanking.add(:STEELWORKER,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:STEEL)
	# next score if battler.has_damaging_move_of_type?(:STEEL18) # Should it buff Metal?
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:INNERPOWER,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:DREAM18)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:TORRENT,
  proc { |ability, score, battler, ai|
    next score if battler.has_damaging_move_of_type?(:WATER)
	next score if battler.has_damaging_move_of_type?(:WATER18)
    next 0
  }
)

#==============================================================================#
# Changes in this section include the following:
#	* Various adjustments and additions to items to account for Touhoumon variants
#==============================================================================#  
Battle::AI::Handlers::ItemRanking.add(:BLACKSLUDGE,
  proc { |item, score, battler, ai|
    next score if battler.has_type?(:POISON)
	next score if battler.has_type?(:MIASMA18)
    next -9
  }
)

Battle::AI::Handlers::ItemRanking.copy(:CHOICEBAND, :BLOOMERS)
Battle::AI::Handlers::ItemRanking.copy(:CHOICEBAND, :POWERRIBBON)
Battle::AI::Handlers::ItemRanking.copy(:CHOICESPECS, :POWERGOGGLES)
Battle::AI::Handlers::ItemRanking.copy(:CHOICESCARF, :POWERCAPE)

Battle::AI::Handlers::ItemRanking.add(:YATAMIRROR,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:RINNOSUKE)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:KUSANAGI,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:RINNOSUKE) &&
                  battler.check_for_move { |m| m.physicalMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:ICEBALL,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:CCIRNO) &&
                  battler.check_for_move { |m| m.damagingMove? }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:NYUUDOUFIST,
  proc { |item, score, battler, ai|
    next score if battler.battler.isSpecies?(:CICHIRIN)
	next score if battler.battler.isSpecies?(:ICHIRIN)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:POTATO,
  proc { |item, score, battler, ai|
    next [20 - (battler.totalhp / 8), 1].max
  }
)

Battle::AI::Handlers::ItemRanking.add(:CURSEDRIBBON,
  proc { |item, score, battler, ai|
    next score if (battler.battler.isSpecies?(:CHINA) ||
				   battler.battler.isSpecies?(:HINA)) &&
                  battler.check_for_move { |m| m.physicalMove?(m.type) }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:type_boosting_items_thmn,
  proc { |item|
    next [:MAIDCOSTUME, :SWEATER, :BUNNYSUIT, :CAMOUFLAGE, :BLAZER,
          :MISTRESS, :NINJA, :NURSE, :SWIMSUIT, :STEWARDESS, :THICKFUR,
		  :KIMONO, :WITCH, :GOTHIC, :BRIDALGOWN, :PRIESTESS, :CHINADRESS,
		  :DAMASCUSSPHERE, :TERRASPHERE, :FERALSPHERE, :GROWTHSPHERE,
		  :TRUSTSPHERE, :SINSPHERE, :GUSTSPHERE, :CORROSIONSPHERE,
		  :FLOODSPHERE, :FLIGHTSPHERE, :FROSTSPHERE, :SOULSPHERE,
		  :KNOWLEDGESPHERE, :BLAZESPHERE, :VIRTUESPHERE, :PHANTASMSPHERE,
          :ODDINCENSE, :ROCKINCENSE, :ROSEINCENSE, :SEAINCENSE, :WAVEINCENSE].include?(item)
  },
  proc { |item, score, battler, ai|
    boosters = {
      :STEEL18      	=> [:MAIDCOSTUME, :DAMASCUSSPHERE],
      :EARTH18     		=> [:SWEATER, :TERRASPHERE, :ROCKINCENSE],
      :BEAST18   		=> [:BUNNYSUIT, :FERALSPHERE],
      :NATURE18 		=> [:CAMOUFLAGE, :GROWTHSPHERE, :ROSEINCENSE],
      :HEART18    		=> [:BLAZER, :TRUSTSPHERE],
      :DARK18 			=> [:MISTRESS, :SINSPHERE],
      :WIND18     		=> [:NINJA, :GUSTSPHERE],
      :MIASMA18   		=> [:NURSE, :CORROSIONSPHERE],
      :WATER18    		=> [:SWIMSUIT, :FLOODSPHERE, :SEAINCENSE, :WAVEINCENSE],
      :FLYING18    		=> [:STEWARDESS, :FLIGHTSPHERE],
      :ICE18   			=> [:THICKFUR, :FROSTSPHERE],
      :GHOST18      	=> [:KIMONO, :SOULSPHERE],
      :REASON18   		=> [:WITCH, :KNOWLEDGESPHERE, :ODDINCENSE],
      :FIRE18   		=> [:GOTHIC, :BLAZESPHERE],
      :ILLUSION18  		=> [:BRIDALGOWN],
      :FAITH18     		=> [:PRIESTESS, :VIRTUESPHERE],
      :DREAM18    		=> [:CHINADRESS, :PHANTASMSPHERE],
    }
    boosted_type = nil
    boosters.each_pair do |type, items|
      next if !items.include?(item)
      boosted_type = type
      break
    end
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:gems_pkmn_tiertwo,
  proc { |item|
    next [:FIRERIBBON, :WATERRIBBON, :ELECTRICRIBBON, :GRASSRIBBON, :ICERIBBON, :FIGHTINGRIBBON,
          :POISONRIBBON, :GROUNDRIBBON, :FLYINGRIBBON, :PSYCHICRIBBON, :BUGRIBBON, :ROCKRIBBON,
          :GHOSTRIBBON, :DRAGONRIBBON, :DARKRIBBON, :STEELRIBBON, :FAIRYRIBBON, :NORMALRIBBON].include?(item)
  },
  proc { |item, score, battler, ai|
    score += 2 if Settings::MECHANICS_GENERATION <= 5   # 1.5x boost rather than 1.3x
    boosted_type = {
      :BUGRIBBON      => :BUG,
      :DARKRIBBON     => :DARK,
      :DRAGONRIBBON   => :DRAGON,
      :ELECTRICRIBBON => :ELECTRIC,
      :FAIRYRIBBON    => :FAIRY,
      :FIGHTINGRIBBON => :FIGHTING,
      :FIRERIBBON     => :FIRE,
      :FLYINGRIBBON   => :FLYING,
      :GHOSTRIBBON    => :GHOST,
      :GRASSRIBBON    => :GRASS,
      :GROUNDRIBBON   => :GROUND,
      :ICERIBBON      => :ICE,
      :NORMALRIBBON   => :NORMAL,
      :POISONRIBBON   => :POISON,
      :PSYCHICRIBBON  => :PSYCHIC,
      :ROCKRIBBON     => :ROCK,
      :STEELRIBBON    => :STEEL,
      :WATERRIBBON    => :WATER,
    }[item]
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:gems_thmn,
  proc { |item|
    next [:HEMATITE, :QUARTZ, :ONYX, :MALACHITE, :GOLD, :OBSIDIAN, 
	      :JADE, :AMETHYST, :AQUAMARINE, :DIAMOND, :LAPISLAZULI, 
		  :SUGILITE, :OPAL, :GARNET, :MORGANITE, :TOPAZ, :MOONSTONEGEM].include?(item)
  },
  proc { |item, score, battler, ai|
    score += 2 if Settings::MECHANICS_GENERATION <= 5   # 1.5x boost rather than 1.3x
    boosted_type = {
      :HEMATITE       => :STEEL18,
      :QUARTZ         => :EARTH18,
      :ONYX           => :BEAST18,
      :MALACHITE      => :NATURE18,
      :GOLD           => :HEART18,
      :OBSIDIAN       => :DARK18,
      :JADE           => :WIND18,
      :AMETHYST       => :MIASMA18,
      :AQUAMARINE     => :WATER18,
      :DIAMOND        => :FLYING18,
      :LAPISLAZULI    => :ICE18,
      :SUGILITE       => :GHOST18,
      :OPAL           => :REASON18,
      :GARNET         => :FIRE18,
      :MORGANITE      => :REASON18,
      :TOPAZ          => :FAITH18,
      :MOONSTONEGEM   => :DREAM18,
    }[item]
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.addIf(:gems_thmn_tiertwo,
  proc { |item|
    next [:HEMATITEHAIRPIN, :QUARTZHAIRPIN, :ONYXHAIRPIN, :MALACHITEHAIRPIN, 
	      :GOLDHAIRPIN, :OBSIDIANHAIRPIN, :JADEHAIRPIN, :AMETHYSTHAIRPIN, 
		  :AQUAMARINEHAIRPIN, :DIAMONDHAIRPIN, :LAPISHAIRPIN, :SUGILITEHAIRPIN, 
		  :OPALHAIRPIN, :GARNETHAIRPIN, :MORGANITEHAIRPIN, :TOPAZHAIRPIN, 
		  :MOONSTONEHAIRPIN,].include?(item)
  },
  proc { |item, score, battler, ai|
    score += 2 if Settings::MECHANICS_GENERATION <= 5   # 1.5x boost rather than 1.3x
    boosted_type = {
      :HEMATITEHAIRPIN       => :STEEL18,
      :QUARTZHAIRPIN         => :EARTH18,
      :ONYXHAIRPIN           => :BEAST18,
      :MALACHITEHAIRPIN      => :NATURE18,
      :GOLDHAIRPIN           => :HEART18,
      :OBSIDIANHAIRPIN       => :DARK18,
      :JADEHAIRPIN           => :WIND18,
      :AMETHYSTHAIRPIN       => :MIASMA18,
      :AQUAMARINEHAIRPIN     => :WATER18,
      :DIAMONDHAIRPIN        => :FLYING18,
      :LAPISHAIRPIN          => :ICE18,
      :SUGILITEHAIRPIN       => :GHOST18,
      :OPALHAIRPIN           => :REASON18,
      :GARNETHAIRPIN         => :FIRE18,
      :MORGANITEHAIRPIN      => :REASON18,
      :TOPAZHAIRPIN          => :FAITH18,
      :MOONSTONEHAIRPIN      => :DREAM18,
    }[item]
    next score if boosted_type && battler.has_damaging_move_of_type?(boosted_type)
    next 0
  }
)