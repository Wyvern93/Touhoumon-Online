module GameData
  class Item
    
	def unlosable?(species, ability)
      return false if species == :ARCEUS && ability != :MULTITYPE
      return false if species == :SILVALLY && ability != :RKSSYSTEM
      combos = {
        :ARCEUS    => [:FISTPLATE,   :FIGHTINIUMZ,
                       :SKYPLATE,    :FLYINIUMZ,
                       :TOXICPLATE,  :POISONIUMZ,
                       :EARTHPLATE,  :GROUNDIUMZ,
                       :STONEPLATE,  :ROCKIUMZ,
                       :INSECTPLATE, :BUGINIUMZ,
                       :SPOOKYPLATE, :GHOSTIUMZ,
                       :IRONPLATE,   :STEELIUMZ,
                       :FLAMEPLATE,  :FIRIUMZ,
                       :SPLASHPLATE, :WATERIUMZ,
                       :MEADOWPLATE, :GRASSIUMZ,
                       :ZAPPLATE,    :ELECTRIUMZ,
                       :MINDPLATE,   :PSYCHIUMZ,
                       :ICICLEPLATE, :ICIUMZ,
                       :DRACOPLATE,  :DRAGONIUMZ,
                       :DREADPLATE,  :DARKINIUMZ,
                       :PIXIEPLATE,  :FAIRIUMZ],
        :SILVALLY  => [:FIGHTINGMEMORY,
                       :FLYINGMEMORY,
                       :POISONMEMORY,
                       :GROUNDMEMORY,
                       :ROCKMEMORY,
                       :BUGMEMORY,
                       :GHOSTMEMORY,
                       :STEELMEMORY,
                       :FIREMEMORY,
                       :WATERMEMORY,
                       :GRASSMEMORY,
                       :ELECTRICMEMORY,
                       :PSYCHICMEMORY,
                       :ICEMEMORY,
                       :DRAGONMEMORY,
                       :DARKMEMORY,
                       :FAIRYMEMORY],
        :GIRATINA  => [:GRISEOUSORB],
        :GENESECT  => [:BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE],
        :KYOGRE    => [:BLUEORB],
        :GROUDON   => [:REDORB],
        :ZACIAN    => [:RUSTEDSWORD],
        :ZAMAZENTA => [:RUSTEDSHIELD],
		:SARIELO   => [:DAMASCUSSPHERE,
		               :TERRASPHERE,
					   :FERALSPHERE,
					   :GROWTHSPHERE,
					   :TRUSTSPHERE,
					   :SINSPHERE,
					   :GUSTSPHERE,
					   :CORROSIONSPHERE,
					   :FLIGHTSPHERE,
					   :FROSTSPHERE,
					   :SOULSPHERE,
					   :KNOWLEDGESPHERE,
					   :BLAZESPHERE,
					   :VIRTUESPHERE,
					   :PHANTASMSPHERE]
      }
      return combos[species]&.include?(@id)
    end
  end
end