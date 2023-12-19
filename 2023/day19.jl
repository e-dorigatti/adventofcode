
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


const TRange = Dict{AbstractString, Tuple{Int, Int}}

function slice_range(ru::Rule, rng::TRange, matching::Bool)::TRange
    new_rng = TRange()
    for k in keys(rng)
        if k != ru.key
            new_rng[k] = rng[k]
        else
            a, b = rng[k]
            if matching
                if ru.larger_than
                    new_rng[k] = (ru.value + 1, b)
                else
                    new_rng[k] = (a, ru.value - 1)
                end
            else
                if ru.larger_than
                    new_rng[k] = (a, ru.value)
                else
                    new_rng[k] = (ru.value, b)
                end
            end
        end
    end
    return new_rng
end


function count_parts(rng::TRange)::Int
    r = 1
    for (a, b) in values(rng)
        if a <= b
            r *= (b - a + 1)
        else
            r *= 0
        end
    end
    return r
end


function solve_part2(input, sanity_checks = false)
    workflows, _ = parse_input(input)

    frontier = Vector{Tuple{AbstractString, TRange}}([
        ("in", TRange(
            "x" => (1, 4000),
            "m" => (1, 4000),
            "a" => (1, 4000),
            "s" => (1, 4000)),
        )
    ])

    count_accepted = count_rejected = 0
    while !isempty(frontier)
        if sanity_checks
            total = 0 
            for (node, rng) in frontier
                total += count_parts(rng)
            end
            if total + count_accepted + count_rejected != 4000^4
                error("???")
            end
        end

        node, rng = pop!(frontier)
        rng_fail = deepcopy(rng)

        wo = workflows[node]
        for ru in wo.rules
            rng_match = slice_range(ru, rng_fail, true)
            if any(a > b for (a, b) in values(rng_match))
                # range is empty / no parts match this rule
                continue
            end

            rng_fail = slice_range(ru, rng_fail, false)

            if ru.destination == "A"
                n = count_parts(rng_match)
                count_accepted += n
                #println("AAA from $node ($n parts from $new_rng with path $path)")
            elseif ru.destination == "R"
                n = count_parts(rng_match)
                count_rejected += n
                #println("RRR from $node ($n parts from $new_rng with path $path)")
            else
                push!(frontier, (ru.destination, rng_match))
            end
        end
        
        if any(a > b for (a, b) in values(rng_fail))
            # range is empty
            continue
        end

        if wo.default == "A"
            n = count_parts(rng_fail)
            count_accepted += n
            #println("AAA from $node ($n parts from $rng_fail with path $path)")
        elseif wo.default == "R"
            n = count_parts(rng_fail)
            count_rejected += n
            #println("RRR from $node ($n parts from $rng_fail with path $path)")
        else
            push!(frontier, (wo.default, rng_fail))
        end
    end

    println("rules accepted $count_accepted")
    println("rules rejected $count_rejected")
    println("total rules counted $(count_accepted+count_rejected) (expecting $(4000^4))")

    return count_accepted
end


@assert 19114 == solve_file("2023/inputs/day19-test.txt", false)
@assert 418498 == solve_file("2023/inputs/day19.txt", false)

@assert 167409079868000 ==  solve_file("2023/inputs/day19-test.txt", true)
@assert 123331556462603 == solve_file("2023/inputs/day19.txt", true)
