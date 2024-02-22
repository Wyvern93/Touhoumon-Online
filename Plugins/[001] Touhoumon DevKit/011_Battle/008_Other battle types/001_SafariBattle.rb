class SafariBattle
  def pbStartBattle
    begin
      pkmn = @party2[0]
      pbSetSeen(pkmn)
      @scene.pbStartBattle(self)
      pbDisplayPaused(_INTL("Wild {1} appeared!", pkmn.name))
      @scene.pbSafariStart
      weather_data = GameData::BattleWeather.try_get(@weather)
      @scene.pbCommonAnimation(weather_data.animation) if weather_data
      safariBall = GameData::Item.get(:SAFARIBALL).id
      catch_rate = pkmn.species_data.catch_rate
      catchFactor  = (catch_rate * 100) / 1275
      catchFactor  = [[catchFactor, 3].max, 20].min
      escapeFactor = (pbEscapeRate(catch_rate) * 100) / 1275
      escapeFactor = [[escapeFactor, 2].max, 20].min
      loop do
        cmd = @scene.pbSafariCommandMenu(0)
        case cmd
        when 0   # Ball
          if pbBoxesFull?
            pbDisplay(_INTL("The boxes are full! You can't catch anything else!"))
            next
          end
          @ballCount -= 1
          @scene.pbRefresh
          rare = (catchFactor * 1275) / 100
          if safariBall
            pbThrowPokeBall(1, safariBall, rare, true)
            if @caughtPokemon.length > 0
              pbRecordAndStoreCaughtPokemon
              @decision = 4
            end
          end
        when 1   # Bait
          pbDisplayBrief(_INTL("{1} threw some bait at the {2}!", self.pbPlayer.name, pkmn.name))
          @scene.pbThrowBait
          catchFactor  /= 2 if pbRandom(100) < 90   # Harder to catch
          escapeFactor /= 2                       # Less likely to escape
        when 2   # Rock
          pbDisplayBrief(_INTL("{1} threw a rock at the {2}!", self.pbPlayer.name, pkmn.name))
          @scene.pbThrowRock
          catchFactor  *= 2                       # Easier to catch
          escapeFactor *= 2 if pbRandom(100) < 90   # More likely to escape
        when 3   # Run
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("You got away safely!"))
          @decision = 3
        else
          next
        end
        catchFactor  = [[catchFactor, 3].max, 20].min
        escapeFactor = [[escapeFactor, 2].max, 20].min
        # End of round
        if @decision == 0
          if @ballCount <= 0
            pbDisplay(_INTL("PA: You have no Safari Balls left! Game over!"))
            @decision = 2
          elsif pbRandom(100) < 5 * escapeFactor
            pbSEPlay("Battle flee")
            pbDisplay(_INTL("{1} fled!", pkmn.name))
            @decision = 3
          elsif cmd == 1   # Bait
            pbDisplay(_INTL("{1} is eating!", pkmn.name))
          elsif cmd == 2   # Rock
            pbDisplay(_INTL("{1} is angry!", pkmn.name))
          else
            pbDisplay(_INTL("{1} is watching carefully!", pkmn.name))
          end
          # Weather continues
          weather_data = GameData::BattleWeather.try_get(@weather)
          @scene.pbCommonAnimation(weather_data.animation) if weather_data
        end
        break if @decision > 0
      end
      @scene.pbEndBattle(@decision)
    rescue BattleAbortedException
      @decision = 0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end
end
