#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Changes the Day/Night tones to the one Deo's Custom Day Night tones uses
#==============================================================================#
module PBDayNight
  HOURLY_TONES = [
#Deo's custom Day & Night tones for Pokemon Essentials.
#These are created with preserving most of the tile colors in mind.
#Credit is appreciated.
     Tone.new(-70,	-70,	11,	68),     # Midnight
     Tone.new(-70,	-70,	11,	68),
     Tone.new(-70,	-70,	11,	68),
     Tone.new(-70,	-70,	11,	68),
     Tone.new(-70,	-70,	11,	68),
     Tone.new(-17,  -51,   -85,	17),
     Tone.new(-17,  -51,   -85,	17),      # 6AM
     Tone.new(-17,  -51,   -85, 17),
     Tone.new(  0,    0,     0,  0),
     Tone.new(  0,    0,     0,  0), 
     Tone.new(  0,    0,     0,  0), 
     Tone.new(  0,    0,     0,  0), 
     Tone.new(  0,    0,     0,  0),      # Noon
     Tone.new(  0,    0,     0,  0),
     Tone.new(  0,    0,     0,  0),
     Tone.new(  0,    0,     0,  0),
     Tone.new(  0,    0,     0,  0),
     Tone.new(  0,    0,     0,  0),
     Tone.new(-30,  -30,     5, 68),      # 6PM
     Tone.new(-30,  -30,     5, 68),
     Tone.new(-35,  -35,     7, 68),
     Tone.new(-35,  -35,     7, 68),
     Tone.new(-70,	-70,    11,	68),
     Tone.new(-70,	-70,    11,	68)
  ]
  @cachedTone = nil
  @dayNightToneLastUpdate = nil
  @oneOverSixty = 1 / 60.0

  # Returns true if it's day.
  def self.isDay?(time = nil)
    time = pbGetTimeNow if !time
    return (time.hour >= 5 && time.hour < 20)
  end

  # Returns true if it's night.
  def self.isNight?(time = nil)
    time = pbGetTimeNow if !time
    return (time.hour >= 20 || time.hour < 5)
  end

  # Returns true if it's morning.
  def self.isMorning?(time = nil)
    time = pbGetTimeNow if !time
    return (time.hour >= 5 && time.hour < 10)
  end

  # Returns true if it's the afternoon.
  def self.isAfternoon?(time = nil)
    time = pbGetTimeNow if !time
    return (time.hour >= 14 && time.hour < 17)
  end

  # Returns true if it's the evening.
  def self.isEvening?(time = nil)
    time = pbGetTimeNow if !time
    return (time.hour >= 17 && time.hour < 20)
  end

  # Gets a number representing the amount of daylight (0=full night, 255=full day).
  def self.getShade
    time = pbGetDayNightMinutes
    time = (24 * 60) - time if time > (12 * 60)
    return 255 * time / (12 * 60)
  end

  # Gets a Tone object representing a suggested shading
  # tone for the current time of day.
  def self.getTone
    @cachedTone = Tone.new(0, 0, 0) if !@cachedTone
    return @cachedTone if !Settings::TIME_SHADING
    if !@dayNightToneLastUpdate || (System.uptime - @dayNightToneLastUpdate >= CACHED_TONE_LIFETIME)
      getToneInternal
      @dayNightToneLastUpdate = System.uptime
    end
    return @cachedTone
  end

  def self.pbGetDayNightMinutes
    now = pbGetTimeNow   # Get the current in-game time
    return (now.hour * 60) + now.min
  end

  def self.getToneInternal
    # Calculates the tone for the current frame, used for day/night effects
    realMinutes = pbGetDayNightMinutes
    hour   = realMinutes / 60
    minute = realMinutes % 60
    tone         = PBDayNight::HOURLY_TONES[hour]
    nexthourtone = PBDayNight::HOURLY_TONES[(hour + 1) % 24]
    # Calculate current tint according to current and next hour's tint and
    # depending on current minute
    @cachedTone.red   = ((nexthourtone.red - tone.red) * minute * @oneOverSixty) + tone.red
    @cachedTone.green = ((nexthourtone.green - tone.green) * minute * @oneOverSixty) + tone.green
    @cachedTone.blue  = ((nexthourtone.blue - tone.blue) * minute * @oneOverSixty) + tone.blue
    @cachedTone.gray  = ((nexthourtone.gray - tone.gray) * minute * @oneOverSixty) + tone.gray
  end
end