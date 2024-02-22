#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Added pbConsumeAndInertItem which is what determines whether an item
#	  gets consumed by its holder and comes back after battle
#==============================================================================#
class Battle::Battler
  def pbConsumeAndInertItem
    PBDebug.log("[Item consumed] #{pbThis} consumed and inerted its held #{itemName}")
    pbRemoveItem(false)
  end
end