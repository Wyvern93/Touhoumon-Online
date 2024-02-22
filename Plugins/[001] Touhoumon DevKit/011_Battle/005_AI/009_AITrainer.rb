
class Battle::AI::AITrainer
#==============================================================================#
# Changes in this section include the following:
#	* Added an additional flag to the set up skill method
#==============================================================================#
  def set_up_skill
    if @trainer
      @skill = @trainer.skill_level
    elsif Settings::SMARTER_WILD_LEGENDARY_POKEMON
      # Give wild legendary/mythical Pokémon a higher skill
      wild_battler = @ai.battle.battlers[@side]
      sp_data = wild_battler.pokemon.species_data
      if sp_data.has_flag?("Legendary") ||
         sp_data.has_flag?("Mythical") ||
         sp_data.has_flag?("UltraBeast") || 
		 sp_data.has_flag?("SmarterWildAI")
        @skill = 32   # Medium skill
      end
    end
  end
end