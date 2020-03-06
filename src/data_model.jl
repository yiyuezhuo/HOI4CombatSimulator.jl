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

function Base.show(io::IO, ::MIME"text/plain", div::DivisionTemplate)
    print("uniList: ")
    print(join([unit.Unit for unit in div.unitList], ","))
    for fn in fieldnames(typeof(div))
        if fn == :unitList
            continue
        end
        print(" $fn: $(getproperty(div, fn)),")
    end
end

