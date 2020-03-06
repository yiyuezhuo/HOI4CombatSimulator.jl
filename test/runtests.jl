using Test
using HOI4CombatSimulator
using Statistics

macro rep(n::Int, exp::Expr)
    quote
        resp_array = Array{Any, 1}(undef, $n)
        for i in 1:$n
            resp_array[i] = $exp
        end
        m = length(resp_array)
        n = length(resp_array[1])
        mat = zeros(m, n)
        for i in 1:m
            for j in 1:n
                mat[i, j] = resp_array[i][j]
            end
        end
        mat
    end
end

@testset "HOI4CombatSimulator" begin
    @testset "get_unit_list" begin
        unit_list = HOI4CombatSimulator.get_unit_list()
        @test length(unit_list) > 0
    end

    @testset "wiki_example" begin
        HP_loss_Org_loss_mat = @rep 1000 HOI4CombatSimulator.fire(
            evade=500, HPPercent=0.99, ShooterHardAtk=0,
            ShooterSoftAtk=1000, VictimHardness=0,
            ShooterPierce=20, ShooterArmor=10,
            VictimPierce=1, VictimArmor=0
        ) # (n, 2)
        HP_loss_arr = HP_loss_Org_loss_mat[:, 1]
        Org_loss_arr = HP_loss_Org_loss_mat[:, 2]
        diff = abs(mean(Org_loss_arr) - 3.9)
        tol = (std(Org_loss_arr) / sqrt(1000))*5 # 5 sigma
        @test  diff < tol 
    end
end