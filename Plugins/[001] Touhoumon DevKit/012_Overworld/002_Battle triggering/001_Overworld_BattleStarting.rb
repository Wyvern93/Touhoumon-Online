# TO-DO: Get a message to display for both Pickup and Graverobber
EventHandlers.add(:on_end_battle, :evolve_and_black_out_alt,
  proc { |decision, canLose|
    # Check for blacking out or gaining Graverobber/Potato Harvest items
    case decision
    when 1, 4   # Win, capture
	  $player.pokemon_party.each do |pkmn|
		pbGraverobber(pkmn)
		pbPotatoHarvest(pkmn)
      end
    end
  }
)

# Derx: Still fleshing out items.
GRAVEROBBER_COMMON_ITEMS = [
  :ORANBERRY,     # Levels 1-10
  :PECHABERRY,    # Levels 1-10, 11-20
  :SITRUSBERRY,   # Levels 1-10, 11-20, 21-30
  :NETBALL,       # Levels 1-10, 11-20, 21-30, 31-40
  :REPEL,         # Levels 1-10, 11-20, 21-30, 31-40, 41-50
  :ESCAPEROPE,    # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60
  :OLDGATEAU,     # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70
  :ENERGYROOT,    # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80
  :DUSKBALL,      # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90
  :REVIVALHERB,   # Levels       11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :RARECANDY,     # Levels              21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :SUNSTONE,      # Levels                     31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :MOONSTONE,     # Levels                            41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :REDUFO,        # Levels                                   51-60, 61-70, 71-80, 81-90, 91-100
  :FULLRESTORE,   # Levels                                          61-70, 71-80, 81-90, 91-100
  :MAXREVIVE,     # Levels                                                 71-80, 81-90, 91-100
  :PPUP,          # Levels                                                        81-90, 91-100
  :MAXELIXIR      # Levels                                                               91-100
]

GRAVEROBBER_COMMON_ITEM_CHANCES = [30, 10, 10, 10, 10, 10, 10, 4, 4]

# Derx: Still fleshing out items.
GRAVEROBBER_RARE_ITEMS = [
  :ENERGYROOT,    # Levels 1-10
  :RAREBONE,      # Levels 1-10, 11-20
  :KINGSROCK,     # Levels       11-20, 21-30
  :FULLRESTORE,   # Levels              21-30, 31-40
  :LEPPABERRY,    # Levels                     31-40, 41-50
  :POMEGBERRY,    # Levels                            41-50, 51-60
  :REAPERCLOTH,   # Levels                                   51-60, 61-70
  :GOTHIC,        # Levels                                          61-70, 71-80
  :REAPERCLOTH,   # Levels                                                 71-80, 81-90
  :STEALTHCHARM,  # Levels                                                        81-90, 91-100
  :SACREDASH,     # Levels                                                               91-100
]

GRAVEROBBER_RARE_ITEM_CHANCES = [1, 1]


def pbGraverobber(pkmn)
  return if pkmn.egg? || !pkmn.hasAbility?(:GRAVEROBBER)
  return if pkmn.hasItem?
  return unless rand(100) < 10   # 10% chance for Graverobber to trigger
  num_rarity_levels = 10
  # Ensure common and rare item lists contain defined items
  common_items = pbDynamicItemList(*GRAVEROBBER_COMMON_ITEMS)
  rare_items = pbDynamicItemList(*GRAVEROBBER_RARE_ITEMS)
  return if common_items.length < num_rarity_levels - 1 + GRAVEROBBER_COMMON_ITEM_CHANCES.length
  return if rare_items.length < num_rarity_levels - 1 + GRAVEROBBER_RARE_ITEM_CHANCES.length
  # Determine the starting point for adding items from the above arrays into the
  # pool
  start_index = [([100, pkmn.level].min - 1) * num_rarity_levels / 100, 0].max
  # Generate a pool of items depending on the Pokémon's level
  items = []
  GRAVEROBBER_COMMON_ITEM_CHANCES.length.times { |i| items.push(common_items[start_index + i]) }
  GRAVEROBBER_RARE_ITEM_CHANCES.length.times { |i| items.push(rare_items[start_index + i]) }
  # Randomly choose an item from the pool to give to the Pokémon
  all_chances = GRAVEROBBER_COMMON_ITEM_CHANCES + GRAVEROBBER_RARE_ITEM_CHANCES
  rnd = rand(all_chances.sum)
  cumul = 0
  all_chances.each_with_index do |c, i|
    cumul += c
    next if rnd >= cumul
    pkmn.item = items[i]
    break
  end
end

# Try to gain a Potato item after a battle if a Pokemon has the ability Potato Harvest.
def pbPotatoHarvest(pkmn)
  return if !GameData::Item.exists?(:POTATO)
  return if pkmn.egg? || !pkmn.hasAbility?(:POTATOHARVEST) || pkmn.hasItem?
  chance = 5 + (((pkmn.level - 1) / 10) * 5)
  return unless rand(100) < chance
  pkmn.item = :POTATO
end