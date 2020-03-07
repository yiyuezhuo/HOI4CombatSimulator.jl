round_random(x)::Int = round(x) + (rand() < mod(x, 1))
# d6(n) = floor.(Int, rand(n) .* 6) .+ 1

function fire(;evade, HPPercent, ShooterHardAtk, ShooterSoftAtk, VictimHardness,
               ShooterPierce, ShooterArmor, VictimPierce, VictimArmor)
    hardness = VictimHardness
    firepower = ShooterHardAtk * VictimHardness + ShooterSoftAtk * (1-VictimHardness)
    if ShooterPierce < VictimArmor
        firepower /= 2
    end

    fire_hit = round_random(firepower / 10)
    evade_hit = round_random(evade / 10)

    fire_heavy = max(fire_hit - evade_hit, 0)
    fire_light = min(fire_hit, evade_hit)

    hit = sum(rand(fire_heavy) .< 0.4) + sum(rand(fire_light) .< 0.1)

    HP_dice_size = 2
    if ShooterArmor > VictimPierce
        Org_dice_size = 6
    else
        Org_dice_size = 4
    end

    HP_loss =  sum(floor.(rand(hit) .*  HP_dice_size) .+ 1) * 0.05
    Org_loss = sum(floor.(rand(hit) .* Org_dice_size) .+ 1) * 0.05

    if ShooterPierce < VictimArmor
        HP_loss /= 2
        Org_loss /= 2
    end

    p = floor(HPPercent, digits=1)
    HP_loss *= p
    Org_loss *= p

    return HP_loss, Org_loss
end

"""
    fire(shooter, victin, victim_pos)

shooter == attacker, victim == defender in wiki jargon, but I prefer to not use words atk/def
since they make confusion with "region" attacker and defender, which is indicated by victim_pos.
victim ∈ :attacker, :defender

Note: I misunderstood the last argument as shooter_pos many times! -_-
"""
function fire(shooter::Division, victim::Division, victim_pos::Symbol)
    if victim_pos == :attacker
        evade = victim.T.Breakthr
    elseif victim_pos == :defender
        evade = victim.T.Defense
    else
        error("Unknown victim_pos")
    end

    HPPercent = shooter.HP / shooter.T.HP

    fire(evade=evade, HPPercent=HPPercent, ShooterHardAtk=shooter.T.HardAtk,
         ShooterSoftAtk=shooter.T.SoftAtk, VictimHardness=victim.T.Hardness,
         ShooterPierce=shooter.T.Pierce, ShooterArmor=shooter.T.Armor,
         VictimPierce=victim.T.Pierce, VictimArmor=victim.T.Armor)
end

function fire!(shooter::Division, victim::Division, victim_pos::Symbol)
    HP_loss, Org_loss = fire(shooter, victim, victim_pos)
    victim.HP = max(victim.HP - HP_loss, 0)
    victim.Org = max(victim.Org - Org_loss, 0)
end

"Used to test only, real game resolve damage in meantime."
function duel(div_atk::Division, div_def::Division)
    HP_atk = [div_atk.HP]
    HP_def = [div_def.HP]
    Org_atk = [div_atk.Org]
    Org_def = [div_def.Org]
    while !defeated(div_atk) && !defeated(div_def)
        fire!(div_def, div_atk, :defender)
        fire!(div_atk, div_def, :attacker)
        push!(HP_atk, div_atk.HP)
        push!(HP_def, div_def.HP)
        push!(Org_atk, div_atk.Org)
        push!(Org_def, div_def.Org)
    end
    return (HP_atk=HP_atk, HP_def=HP_def, Org_atk=Org_atk, Org_def=Org_def)
end

