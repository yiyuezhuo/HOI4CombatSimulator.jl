module HOI4CombatSimulator

export get_unit_list, Unit, DivisionTemplate, Division, fire, fire!

include("defs.jl")
include("get_data.jl")
include("data_model.jl")
include("resolve.jl")
include("quick.jl")

end # module
