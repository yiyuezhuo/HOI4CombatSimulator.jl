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

    @testset "conv" begin
        x = HOI4CombatSimulator.Inference.fast_conv(ones(2)/2, 2)
        @test maximum(abs.(x .- [0.25, 0.5, 0.25])) < 1e-6
    end

    @testset "DiceSumDistribution" begin
        d6x2 = HOI4CombatSimulator.Inference.dice_sum_distribution(6, 2)
        @test d6x2.support[1] == 2
        @test d6x2.support[end] == 12
        @test length(d6x2.support) == 11
        @test abs(d6x2.p[1] - 1/36) < 1e-6

        d6x4 = HOI4CombatSimulator.Inference.dice_sum_distribution(6, 4)
        @test d6x4.p[end] == (1/6)^4
        @test abs(sum(d6x4.p)- 1.) < 1e-6
    end

    @testset "prob_fire_loss" begin
        HP_Org_loss_mat = HOI4CombatSimulator.Inference.prob_fire(104.0, 160.0, 6)
        @test size(HP_Org_loss_mat, 1) > 1
        @test size(HP_Org_loss_mat, 2) > 1
        # TODO: detailed test
    end
end