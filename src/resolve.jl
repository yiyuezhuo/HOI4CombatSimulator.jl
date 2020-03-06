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

    #=
    # Does HP and Org loss roll dices independently? I don't know...
    HP_dice = hit * 2
    if ShooterArmor > VictimPierce
        Org_dice = hit * 6
    else
        Org_dice = hit * 4
    end
    =#
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

function fire(shooter::Division, victim::Division, victim_pos::Symbol)
    # shooter == attacker, victim == defender in wiki jargon, but I prefer to not use words atk/def
    # since they make confusion with "region" attacker and defender, which is indicated by victim_pos.
    # victim ∈ :attacker, :defender
    if victim_pos == :attacker
        evade = victim.T.Breakthr
    else
        evade = victim.T.Defense
    end

    HPPercent = shooter.HP / shooter.T.HP

    fire(evade=evade, HPPercent=HPPercent, ShooterHardAtk=shooter.T.HardAtk,
         ShooterSoftAtk=shooter.T.SoftAtk, VictimHardness=victim.T.Hardness,
         ShooterPierce=shooter.T.Pierce, ShooterArmor=shooter.T.Armor,
         VictimPierce=victim.T.Pierce, VictimArmor=victim.T.Armor)
end

function fire!(shooter::Division, victim::Division, victim_pos::Symbol)
    HP_loss, Org_loss = fire(shooter, victim. victim_pos)
    victim.HP = max(victim.HP - HP_loss, 0)
    victim.Org = max(victim.Org - Org_loss, 0)
end