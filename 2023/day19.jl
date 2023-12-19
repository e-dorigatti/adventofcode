
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end


struct Rule
    key::AbstractString
    larger_than::Bool
    value::Int
    destination::AbstractString
end


struct Workflow
    rules::Vector{Rule}
    default::AbstractString
end


function parse_input(input)
    workflows = Dict{AbstractString, Workflow}()
    parts = Vector{Dict{AbstractString, Int}}()

    lines = split(input, '\n')
    
    # parse workflows
    i = 1
    while !isempty(lines[i])
        name, srules = split(lines[i], '{')
        i += 1
        rules = split(srules[1:lastindex(srules)-1], ',')

        wo = Workflow(Vector{Rule}(), rules[lastindex(rules)])
        workflows[name] = wo

        for r in rules
            if ':' ∉ r
                continue
            end

            ru, dest = split(r, ':')
            if '>' in r
                key, val = split(ru, '>')
                push!(wo.rules, Rule(key, true, parse(Int, val), dest))
            else
                key, val = split(ru, '<')
                push!(wo.rules, Rule(key, false, parse(Int, val), dest))
            end
        end

    end

    # parts
    i += 1
    while i <= lastindex(lines)
        sratings = split(lines[i][2:lastindex(lines[i])-1], ',')
        i += 1

        pa = Dict{AbstractString, Int}()
        for ra in sratings
            r, v = split(ra, '=')
            pa[r] = parse(Int, v)
        end

        push!(parts, pa)
    end

    return workflows, parts
end


function solve_part1(input)
    workflows, parts = parse_input(input)

    result = 0
    for pa in parts
        #println("processing part $pa")
        wo = workflows["in"]
        while true
            transfer = processed = false
            for ru in wo.rules
                is_larger = pa[ru.key] > ru.value
                if (ru.larger_than && is_larger) || (!ru.larger_than && !is_larger)
                    if ru.destination == "A"
                        result += sum(values(pa))
                        processed = true
                        #println("ACCEPTED")
                    elseif ru.destination == "R"
                        processed = true
                        #println("REJECTED")
                    else
                        #println("transferring to $(ru.destination)")
                        wo = workflows[ru.destination]
                        transfer = true
                    end
                    break
                end
            end

            if processed
                break
            elseif !transfer
                if wo.default == "A"
                    result += sum(values(pa))
                    #println("ACCEPTED")
                    break
                elseif wo.default == "R"
                    #println("REJECTED")
                    break
                else
                    #println("transferring to $(wo.default)")
                    wo = workflows[wo.default]
                end
            end
        end
    end

    return result
end


@assert 19114 == solve_file("2023/inputs/day19-test.txt", false)
@assert 418498 == solve_file("2023/inputs/day19.txt", false)

