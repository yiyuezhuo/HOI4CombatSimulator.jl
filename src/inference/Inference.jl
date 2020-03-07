"""
Inference module
"""
module Inference

using Distributions

function conv(arr1, arr2)
    arr_conv = zeros(length(arr1)+length(arr2)-1)
    for i in 1:length(arr1)
        for j in 1:length(arr2)
            arr_conv[i+j-1] += arr1[i] * arr2[j]
        end
    end
    arr_conv
end

function fast_conv(arr, n::Int)
    #=  1  2  3
      1 2  3  4
      2 3  4  5
      3 4  5  6
    =#
    if n < 0
        error("Invalid n: $n")
    end
    if n == 0
        return [1.]
    end 
    if n == 1
        return arr
    end
    arr2 = conv(arr, arr)
    arr3 = fast_conv(arr2, n ÷ 2)
    if n % 2 == 1
        arr3 = conv(arr3, arr)
    end
    arr3
end

function dice_sum_distribution(base::Int, n::Int)
    # D6 * 2 -> (6, 2) -> 2,3,...,12  1/36,2/36,...
    support = n:(base*n)
    prob = fast_conv(ones(base)/base, n)
    DiscreteNonParametric(support, prob)
end

function prob_fire(firepower::Real, evade::Real, Org_cons::Int)
    f = firepower / 10
    e = evade / 10
    
    firepower_x = [floor(Int, f), ceil(Int, f)]
    firepower_p = [1+floor(f)-f, f - floor(f)]
    
    evade_x = [floor(Int, e), ceil(Int, e)]
    evade_p = [1+floor(e)-e, e - floor(e)]
    
    # (fire_floor, evade_floor), (fire_floor, evade_ceil), (fire_ceil, evade_floor), (fire_ceil, evade_ceil)
    fire_heavy_x = [max(fire_hit - evade_hit, 0) for fire_hit = firepower_x for evade_hit = evade_x]
    fire_light_x = [min(fire_hit, evade_hit) for fire_hit = firepower_x for evade_hit = evade_x]
    
    fire_hl_p = [fire_p * evade_p for fire_p = firepower_p for evade_p = evade_p]
    
    max_hit = maximum(fire_heavy_x .+ fire_light_x)
    hit_p = zeros(max_hit+1) # denote prob for 0,1,...,max_hit

    for (hx, lx, p) in zip(fire_heavy_x, fire_light_x, fire_hl_p)
        ha = fast_conv([0.6, 0.4], hx)
        la = fast_conv([0.9, 0.1], lx)
        pp = conv(ha, la)
        hit_p[1:length(pp)] += pp * p
    end

    #Org_cons = 6 # 4

    HP_base_p = ones(2) / 2
    Org_base_p = ones(Org_cons) / Org_cons
    
    #HP_loss_p = zeros(max_hit*2+1) # denote HP loss for 0, 1, ..., max_hit*2
    #Org_loss_p = zeros(max_hit*Org_cons+1) # denote Org loss for 0, 1, ..., max_hit*Org_cons
    
    #HP_loss_p[1] = hit_p[1]
    #Org_loss_p[1] = hit_p[1]

    HP_Org_loss_mat = zeros(max_hit*2+1, max_hit*Org_cons+1)
    HP_Org_loss_mat[1, 1] = hit_p[1]
    
    HP_p = [1.]
    Org_p = [1.]
    
    for (hit, p) in enumerate(hit_p[2:end])
        HP_p = conv(HP_p, HP_base_p)
        Org_p = conv(Org_p, Org_base_p)

        # marginal
        #HP_loss_p[hit+1:length(HP_p)+hit] += HP_p * p
        #Org_loss_p[hit+1:length(Org_p)+hit] += Org_p * p

        HP_Org_loss_mat[hit+1:length(HP_p)+hit, hit+1:length(Org_p)+hit] += HP_p .* Org_p' * p

    end

    #return HP_loss_p, Org_loss_p
    return HP_Org_loss_mat
end


end