# Derx: Sariel Omega isn't actually programmed in, but this code exists here nonetheless.
# Do with it as you will, I guess.
=begin
MultipleForms.register(:SARIELO, {
  "getForm" => proc { |pkmn|
    next nil if !pkmn.hasAbility?(:SERAPHSWINGS)
    typeArray = {
      1  => [:DAMASCUSSPHERE],
      2  => [:TERRASPHERE],
      3  => [:FERALSPHERE],
      4  => [:GROWTHSPHERE],
      5  => [:TRUSTSPHERE],
      6  => [:SINSPHERE],
      7  => [:GUSTSPHERE],
      8  => [:CORROSIONSPHERE],
      9  => [:FLIGHTSPHERE],
      10 => [:FROSTSPHERE],
      11 => [:SOULSPHERE],
      12 => [:KNOWLEDGESPHERE],
      13 => [:BLAZESPHERE],
      14 => [:VIRTUESPHERE],
      15 => [:PHANTASMSPHERE],
    }
    ret = 0
    typeArray.each do |f, items|
      items.each do |item|
        next if !pkmn.hasItem?(item)
        ret = f
        break
      end
      break if ret > 0
    end
    next ret
  }
})
=end