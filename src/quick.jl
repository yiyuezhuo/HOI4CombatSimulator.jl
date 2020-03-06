module quick
#=
Usage:

using HOI4CombatSimulator
HOI4CombatSimulator.quick.init()
using HOI4CombatSimulator.quick: Infantry, Artillery, Tank, Motor, SPA, 
    inf7art2, inf10, tank5mot2spa2, div72, div10, div522
=#

using ..HOI4CombatSimulator: get_unit_list, DivisionTemplate, Division

function init()
    global unit_list = get_unit_list()
    # there're ("Support", "Artillery") and ("Infantry", "Artillery")
    global unit_dict = Dict((unit.CategoryHead, unit.Unit) => unit for unit in unit_list)

    # unit type (base: Light)
    global Infantry = unit_dict[("Infantry", "Infantry")]
    global Artillery = unit_dict[("Infantry", "Artillery")]
    global Tank = unit_dict[("Tanks", "Light TD")]
    global Motor = unit_dict[("Mobile Battalions", "Motorized Infantry")]
    global SPA = unit_dict[("Tanks", "Light SP Artillery")]

    # common 20 width template
    global inf7art2 = DivisionTemplate((Infantry, 7), (Artillery, 2))
    global inf10 = DivisionTemplate((Infantry, 2))
    global tank5mot2spa2 = DivisionTemplate((Tank, 5), (Motor, 2), (SPA, 2))

    # quick Division example
    global div72 = Division(inf7art2)
    global div10 = Division(inf10)
    global div522 = Division(tank5mot2spa2)
    
end

end
