class GameData::Item
  def is_reincarnation_stone?
    flags.each do |flag|
      next if !flag.include?("ReincarnationStone")
      return true
    end
    return false
  end

  def is_reincarnation_boon?
    flags.each do |flag|
      next if !flag.include?("ReincarnationBoon")
      return true
    end
    return false
  end

  def is_reincarnation_bane?
    flags.each do |flag|
      next if !flag.include?("ReincarnationBane")
      return true
    end
    return false
  end

  def stat_for_reincarnation(check_flag)
    flags.each do |flag|
      next if !flag.include?(check_flag)
      split = flag.split("_")
      stat = split[1...flag.length].join("_").to_sym
      next if !GameData::Stat.exists?(stat)
      return stat 
    end
    return nil
  end
end

module Reincarnation

  module_function

  def can_reincarnate?(pkmn = nil, show_message = true)
    if !meets_cost_requirement?
      qty = COST_AMOUNT
      item_data = GameData::Item.get(COST_ITEM)
      item_name = qty == 1 ? item_data.portion_name : item_data.portion_name_plural
      pbMessage(_INTL("You need at least {2} {1} for reincarnation...", item_name, qty)) if show_message
      return false
    elsif pkmn && pkmn.able? && NUZLOCKE_REINCARNATION && defined?(Nuzlocke.definedrules?)
      pbMessage(_INTL("{1} is not fainted, reincarnation cannot occur...", pkmn.name)) if show_message
      return false
    elsif pkmn && pkmn.species_data.has_flag?("CannotReincarnate")
      pbMessage(_INTL("{1} cannot be reincarnated...", pkmn.name)) if show_message
      return false
    elsif !pkmn && $player.party.length < 1
      pbMessage(_INTL("You don't have enough Pokemon to reincarnate...")) if show_message
      return false
    end
	  return true
  end

  def has_cost?
    return false if !GameData::Item.exists?(COST_ITEM)
    return false if !COST_AMOUNT || COST_AMOUNT < 1
    return true
  end

  def meets_cost_requirement?
    return true if !has_cost?
    # return true if $DEBUG
    return true if $bag.quantity(COST_ITEM) >= COST_AMOUNT
    return false
  end

  def begin_reincarnation(pkmn, donator_1 = nil, donator_2 = nil, boon_item, bane_item, iv_item)
	  # Randomize Stats
    new_ivs = {}
    GameData::Stat.each_main { |s| new_ivs[s.id] = rand(Pokemon::IV_STAT_LIMIT + 1) }
    parents = []
    parents.push(donator_1) if donator_1
    parents.push(donator_2) if donator_2
    availible_ivs = new_ivs.keys.clone
    iv_item_stat  = GameData::Item.try_get(iv_item)&.stat_for_reincarnation("ReincarnationStone")
    if iv_item_stat
      new_ivs[iv_item_stat] = pkmn.iv[iv_item_stat] 
      availible_ivs.delete(iv_item_stat)
    end
    if parents.length < 2
      rand_stat = availible_ivs.sample
      new_ivs[rand_stat] = (parents.first ? parents.first.iv[rand_stat] : new_ivs[rand_stat])
    else
      limit = ((!iv_item || GameData::Item.get(iv_item).stat_for_reincarnation("ReincarnationStone")) ? 3 : 5)
      pass_stats = availible_ivs.sample(limit)
      pass_stats.each do |stat|
        parent = parents.sample
        new_ivs[stat] = parent.iv[stat]
      end
    end
    nature_maps = { :NEUTRAL => [] }
    GameData::Stat.each_main { |stat| nature_maps[stat.id] = {} }
    GameData::Nature.each do |nature|
      if !nature.stat_changes || nature.stat_changes.empty?
        nature_maps[:NEUTRAL].push(nature.id)
        next
      end
      stat_inc = nil
      stat_dec = nil
      nature.stat_changes.each do |stat, amt| 
        stat_inc = stat if amt > 0
        stat_dec = stat if amt < 0
      end
      next if !stat_inc
      if boon_item
        nature_maps[stat_inc][stat_dec] = nature.id
      elsif bane_item
        nature_maps[stat_dec][stat_inc] = nature.id
      end
    end
    reincarnate_nature = nil
    boon_stat = GameData::Item.try_get(boon_item)&.stat_for_reincarnation("ReincarnationBoon")
    bane_stat = GameData::Item.try_get(bane_item)&.stat_for_reincarnation("ReincarnationBane")
    if (!boon_stat && !bane_stat) || (boon_stat == bane_stat)
      reincarnate_nature = nature_maps[:NEUTRAL].sample
    elsif boon_item && boon_stat
      nature_hash = nature_maps[boon_stat]
      reincarnate_nature = nature_hash[bane_stat]
      reincarnate_nature = nature_hash.values.sample if !reincarnate_nature
    elsif bane_item && bane_stat
      nature_hash = nature_maps[bane_stat]
      reincarnate_nature = nature_hash[boon_stat]
      reincarnate_nature = nature_hash.values.sample if !reincarnate_nature
    end
    pkmn.permaFaint = false if NUZLOCKE_REINCARNATION && defined?(Nuzlocke.definedrules?)
    $bag.remove(iv_item) if iv_item && !GameData::Item.try_get(iv_item).is_important?
    $bag.remove(boon_item) if boon_item && !GameData::Item.try_get(boon_item).is_important?
    $bag.remove(bane_item) if boon_item && !GameData::Item.try_get(boon_item).is_important?
    $bag.remove(COST_ITEM, COST_AMOUNT) if has_cost?
    pkmn.level = Reincarnation::SET_TO_LEVEL if SET_TO_LEVEL.is_a?(Numeric)
    pkmn.species = pkmn.species_data.get_baby_species if REVERT_EVOLUTION
    pkmn.reset_moves if REVERT_MOVES
    pkmn.iv = new_ivs
    pkmn.nature = reincarnate_nature if reincarnate_nature
    pkmn.calc_stats
	end
end