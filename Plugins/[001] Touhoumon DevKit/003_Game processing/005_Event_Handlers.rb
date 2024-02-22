#==============================================================================#
#                             Touhoumon Essentials                             #
#                                  Version 3.x                                 #
#             https://github.com/DerxwnaKapsyla/pokemon-essentials             #
#==============================================================================#
# Changes in this section include the following:
#	* Tweaks to the HandlerHash2 def to allow the reading of addIfs in reverse
#	  order. A necessary change.
#==============================================================================#

#class HandlerHashSymbol
#
#  def [](sym)
#    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
#    return @hash[sym] if sym && @hash[sym]
#    @add_ifs.reverse.each do |add_if|
#      return add_if[1] if add_if[0].call(sym)
#    end
#    return nil
#  end
  
#end