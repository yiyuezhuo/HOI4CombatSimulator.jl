using Statistics

collect_property(unitList::Array, key::Symbol) = [getproperty(unit, key) for unit in unitList]

function DivisionTemplate(unitList::Array{Unit,1})
    # sum property
    kw_dict = Dict{Symbol, Real}()
    for key in [:HP, :Recov, :Suppr, :Weight, :Supply, :Width, :Manpower, :SoftAtk, :HardAtk, :AirAtk,
                :Defense, :Breakthr, :FuelCapacity, :FuelUsage, :ProdCost]
        kw_dict[key] = sum(collect_property(unitList, key))
    end
    
    # mean property
    for key in [:Org, :Hardness]
        kw_dict[key] = mean(collect_property(unitList, key))
    end
    
    # max property
    for key in [:Training]
        kw_dict[key] = maximum(collect_property(unitList, key))
    end
    
    # min property
    for key in [:Speed]
        kw_dict[key] = minimum(collect_property(unitList, key))
    end
    
    # speciel
    armor = collect_property(unitList, :Armor)
    pierce = collect_property(unitList, :Pierce)
    
    kw_dict[:Armor] = 0.3*maximum(armor) + 0.7*mean(armor)
    kw_dict[:Pierce] = 0.4*maximum(pierce) + 0.6*mean(pierce)
    
    return DivisionTemplate(;unitList=unitList, kw_dict...)
end

function DivisionTemplate(config_list::Tuple{Unit,Int64}...)
    unit_list = Array{Unit,1}()
    for (unit, count) in config_list
        for i in 1:count
            push!(unit_list, unit)
        end
    end
    DivisionTemplate(unit_list)
end

function Base.show(io::IO, ::MIME"text/plain", div::DivisionTemplate)
    print(io, "uniList: ")
    print(io, join([unit.Unit for unit in div.unitList], ","))
    for fn in fieldnames(typeof(div))
        if fn == :unitList
            continue
        end
        print(io, " $fn: $(getproperty(div, fn)),")
    end
end

function Division(template::DivisionTemplate)
    Division(template, template.HP, template.Org)
end

function reset!(div::Division)
    div.HP = div.T.HP
    div.Org = div.T.Org
end

function broken(div::Division)
    return div.Org <= 0
end

function eliminated(div::Division)
    return div.HP <= 0
end

function defeated(div::Division)
    return broken(div) || eliminated(div)
end

function Base.show(io::IO, media::MIME"text/plain", div::Division)
    f(x) = round(x, digits=1)
    
    println(io, "HP: $(f(div.HP))/$(f(div.T.HP))")
    println(io, "Org: $(f(div.Org))/$(f(div.T.Org))")
    println(io, "SoftAtk, HardAtk: $(f(div.T.SoftAtk)), $(f(div.T.HardAtk))")
    println(io, "Breakthr, Defense: $(f(div.T.Breakthr)), $(f(div.T.Defense))")
    println(io, "Pierce, Armor: $(f(div.T.Pierce)), $(f(div.T.Armor))")
    println(io, "Hardness, Width: $(round(div.T.Hardness, digits=3)), $(f(div.T.Width))")
    print(io, "T:")
    show(io, media, div.T)
end