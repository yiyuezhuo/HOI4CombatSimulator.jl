using Test
using HOI4CombatSimulator

@testset "get_unit_list" begin
    unit_list = HOI4CombatSimulator.get_unit_list()
    @test length(unit_list) > 0
end