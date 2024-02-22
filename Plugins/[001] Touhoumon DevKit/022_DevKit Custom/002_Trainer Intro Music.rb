#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Trainer Intro Themes as BGMs
# Script made by: FL, requested by DerxwnaKapsyla
# ------------------------------------------------------------------------------
# To use, simply follow the format listed below. If you want a Trainer Class
# to have an Intro theme, their class has to be defined in here with the
# associated track. 
#
# If the track has an apostraphe in it, it must have a "\" before the 
# apostraphe. For the last entry in the list, remember to not place a comma,
# as that is the end of the array.
#
# To use it in an event, the script for it is "TrainerIntro2(:[Trainer Class])"
# (because I was a silly head and didn't preface it with pb for consistency's
# sake :wacko:.
#
# All the commented out entries are for the Trainer Classes in Essentials
# normally, barring a few exceptions. Uncomment as necessary, or feel free to
# purge the entire list!
#==============================================================================#
# This code is outdated! I no longer use this!
#==============================================================================#

class Interpreter
  TRAINER_BGMS = {
    :DEVELOPER => 'P-001. Demystify Feast',
#    :AROMALADY => 'P-001. Demystify Feast',
#    :BEAUTY => 'P-001. Demystify Feast',
#    :BIKER => 'P-001. Demystify Feast',
#    :BIRDKEEPER => 'P-001. Demystify Feast',
#    :BUGCATCHER => 'P-001. Demystify Feast',
#    :BURGLAR => 'P-001. Demystify Feast',
#    :CHANELLER => 'P-001. Demystify Feast',
#    :CUEBALL => 'P-001. Demystify Feast',
    :ENGINEER => 'P-002. Trainers\' Eyes Meet (Hiker)',
#    :FISHERMAN => 'P-001. Demystify Feast',
#    :GAMBLER => 'P-001. Demystify Feast',
#    :GENTLEMAN => 'P-001. Demystify Feast',
#    :HIKER => 'P-001. Demystify Feast',
#    :JUGGLER => 'P-001. Demystify Feast',
#    :LADY => 'P-001. Demystify Feast',
#    :PAINTER => 'P-001. Demystify Feast',
#    :POKEMANIAC => 'P-001. Demystify Feast',
#    :POKEMONBREEDER => 'P-001. Demystify Feast',
#    :PROFESSOR => 'P-001. Demystify Feast',
#    :ROCKER => 'P-001. Demystify Feast',
#    :RUINMANIAC => 'P-001. Demystify Feast',
#    :SAILOR => 'P-001. Demystify Feast',
#    :SCIENTIST => 'P-001. Demystify Feast',
#    :SUPERNERD => 'P-001. Demystify Feast',
#    :TAMER => 'P-001. Demystify Feast',
#    :BLACKBELT => 'P-001. Demystify Feast',
#    :CRUSHGIRL => 'P-001. Demystify Feast',
#    :CAMPER => 'P-001. Demystify Feast',
#    :PICNICKER => 'P-001. Demystify Feast',
#    :COOLTRAINER_M => 'P-001. Demystify Feast',
#    :COOLTRAINER_F => 'P-001. Demystify Feast',
#    :YOUNGSTER => 'P-001. Demystify Feast',
#    :LASS => 'P-001. Demystify Feast',
#    :POKEMONRANGER_M => 'P-001. Demystify Feast',
#    :POKEMONRANGER_F => 'P-001. Demystify Feast',
#    :PSYCHIC_M => 'P-001. Demystify Feast',
#    :PSYCHIC_F => 'P-001. Demystify Feast',
#    :SWIMMER_M => 'P-001. Demystify Feast',
#    :SWIMMER_F => 'P-001. Demystify Feast',
#    :SWIMMER2_M => 'P-001. Demystify Feast',
#    :SWIMMER2_F => 'P-001. Demystify Feast',
#    :TUBER_M => 'P-001. Demystify Feast',
#    :TUBER_F => 'P-001. Demystify Feast',
#    :TUBER2_M => 'P-001. Demystify Feast',
#    :TUBER2_F => 'P-001. Demystify Feast',
#    :COOLCOUPLE => 'P-001. Demystify Feast',
#    :CRUSHKIN => 'P-001. Demystify Feast',
#    :SISANDBRO => 'P-001. Demystify Feast',
#    :TWINS => 'P-001. Demystify Feast',
#    :YOUNGCOUPLE => 'P-001. Demystify Feast'
  }
  # Play the trainer eye bgm according to the type defined in Interpreter::TRAINER_BGMS
  # @param type [Symbol] type of trainer (key in TRAINER_BGMS)
#  def trainer_eye_bgm(type, volume = 100, pitch = 100)
  def TrainerIntro2(type, volume = 100, pitch = 100)
    audio_file = TRAINER_BGMS[type]
    Audio.bgm_play("Audio/BGM/Intros/#{audio_file}", volume, pitch) if audio_file
  end
end