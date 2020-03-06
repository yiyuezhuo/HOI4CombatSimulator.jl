
using HTTP
using Gumbo
using Cascadia

cache_path = "$(@__DIR__)/../assets/data.html.asset" # ".asset" is used to supress vscode and github wrong hint

function get_from_wiki(;cache=true)
    url = "https://hoi4.paradoxwikis.com/Land_units"
    res = HTTP.request("GET", url)
    data = String(res.body)

    if cache
        f = open(cache_path, "r")
        write(f, data)
        close(f)
    end

    return data
end

function get_from_cache()
    f = open(cache_path, "r")
    data = String(read(f))
    close(f)
    
    return data
end

function _unit_parse(::Type{Float64}, x::AbstractString)
    if length(x)==0 # empty string "" => 0
        return 0.0
    end
    
    # weired wiki "107.2.0" => "107.2"
    split_x = split(x, ".")
    if length(split_x) == 1
        x = split_x[1]
    else
        x = join(split_x[1:2], ".")
    end
    
    if x[1]=='+'
        x=x[2:end]
    end
    if x[end]=='%'
        return Base.parse(Float64, x[1:end-1]) / 100
    end
    return Base.parse(Float64, x)
end

function _unit_parse(::Type{Int64}, x::AbstractString)
    if length(x)==0
        return 0
    end
    if x[1]=='+'
        x=x[2:end]
    end
    return Base.parse(Int64, x)
end

function unit_parse(::Type{String}, x::AbstractString)
    return x
end

function unit_parse(typ, x::AbstractString)
    #global y
    y = split(x, "/")[1]
    _unit_parse(typ, y)
end

function extract_td(td)
    #global td_ = td
    match_img = eachmatch(sel"img", td);
    if length(match_img) > 0
        raw = attrs(match_img[1])["src"]
    else
        raw_list = []
        for child in td.children
            if child isa HTMLElement{:br}
                push!(raw_list, "/")
            else
                push!(raw_list, strip(nodeText(child)))
            end
        end
        raw = join(raw_list, "")
    end
    return raw
end

function colspan_sum(tr::HTMLElement{:tr})
    # determine cols by resolve first colspan. 
    s = 0
    for el in tr.children # el ∈ {tr, th}
        if "colspan" in keys(attrs(el))
            colspan = Base.parse(Int, attrs(el)["colspan"])
        else
            colspan = 1
        end
        s += colspan
    end
    s
end

function table_index(table::HTMLElement{:table})
    tr_list = eachmatch(sel"tr", table)
    cols = colspan_sum(tr_list[1])
    rows = length(tr_list)
    idx = 1
    index_mat = zeros(Int, rows, cols) # Use 0 to denote "unassigned"
    content_list = []
    for (i, tr) in enumerate(tr_list)
        j = 1
        for el in tr.children # el ∈ tr, td
            while index_mat[i, j] != 0
                j += 1
            end
            colspan = Base.parse(Int, get(attrs(el), "colspan", "1"))
            rowspan = Base.parse(Int, get(attrs(el), "rowspan", "1"))
            for ii in i:(i+rowspan-1)
                for jj in j:(j+colspan-1)
                    index_mat[ii, jj] = idx
                end
            end
            idx += 1
            push!(content_list, el)
        end
    end
    return content_list, index_mat
end

struct HTMLTableMatrix <: AbstractArray{HTMLElement, 2}
    content_list::Vector{HTMLElement}
    index_mat::Array{Int, 2}
end

Base.size(A::HTMLTableMatrix) = size(A.index_mat)
Base.getindex(A::HTMLTableMatrix, i::Int, j::Int) = A.content_list[A.index_mat[i,j]]

function get_unit_list(;cache=true)
    if cache
        data = get_from_cache()
    else
        data = get_from_wiki()
    end

    data_parsed = parsehtml(data)
    table_selected = eachmatch(sel"table.wikitable", data_parsed.root)[1]
    content_list, index_mat = table_index(table_selected)
    html_table_matrix = HTMLTableMatrix(content_list, index_mat);
    mat_extracted = extract_td.(html_table_matrix)[3:end, :] # remove 2 row head
    mat_parsed = Matrix{Any}(undef, size(mat_extracted)...)

    for i in 1:size(mat_extracted, 1)
        for (f_name, f_type, j) in zip(fieldnames(Unit), fieldtypes(Unit), 1:size(mat_extracted, 2))
            #global i_ = i
            #global j_ = j
            raw = mat_extracted[i, j]
            #global raw_ = raw
            parsed = unit_parse(f_type, raw)
            mat_parsed[i,j] = parsed
        end
    end

    unit_list = [Unit(mat_parsed[i,:]...) for i in 1:size(mat_parsed, 1)]
end

