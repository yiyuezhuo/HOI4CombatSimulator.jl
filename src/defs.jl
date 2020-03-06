struct Unit
    CategoryHead::String
    Unit::String
    Icon::String # url
    NATOSymbol::String # url
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    SpecialEffects::String
    Manpower::Int64
    Training::Int64
    Equip::String # TODO: detailed parse
    Equipment_Modifier::String
    Category::String
    Speed::Float64 # 8.0/10.0/12.0 -> 8.0
    SoftAtk::Float64
    HardAtk::Float64
    AirAtk::Float64
    Defense::Float64
    Breakthr::Float64
    Armor::Float64 # 10/15/20 -> 10
    Pierce::Float64
    Hardness::Float64 # 64% -> 0.64
    FuelCapacity::Float64
    FuelUsage::Float64
    ProdCost::Float64
    UnitTail::String
end

Base.@kwdef struct DivisionTemplate # kwdef make it possible to use keyword specify parameter
    unitList::Array{Unit,1}
    HP::Float64
    Org::Float64
    Recov::Float64
    Suppr::Float64
    Weight::Float64
    Supply::Float64
    Width::Float64
    Manpower::Int64
    Training::Int64
    Speed::Float64
    SoftAtk::Float64
    HardAtk::Float64
    AirAtk::Float64
    Defense::Float64
    Breakthr::Float64
    Armor::Float64
    Pierce::Float64
    Hardness::Float64
    FuelCapacity::Float64
    FuelUsage::Float64
    ProdCost::Float64
end

mutable struct Division
    template::DivisionTemplate # max HP, max Org, etc...
    HP::Float64
    Org::Float64
end