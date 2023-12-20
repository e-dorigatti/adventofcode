using DataStructures


function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end


MAX_LOG_LEVEL = 1
function log_message(level::Int, msg::AbstractString)
    if level <= MAX_LOG_LEVEL
        println(msg)
    end
end


mutable struct FlipFlopModule
    is_on::Bool
end


function handle_pulse(m::FlipFlopModule, is_high::Bool, source::AbstractString)::Vector{Bool}
    if is_high
        return []
    else 
        m.is_on = !m.is_on
        return [m.is_on]
    end
end


mutable struct ConjunctionModule
    input_states::Dict{AbstractString, Bool}
end


function handle_pulse(m::ConjunctionModule, is_high::Bool, source::AbstractString)::Vector{Bool}
    if source ∉ keys(m.input_states)
        error("??")
    end

    m.input_states[source] = is_high
    return [!all(values(m.input_states))]
end


mutable struct OutputModule

end


function handle_pulse(m::OutputModule, is_high::Bool, source::AbstractString)::Vector{Bool}
    return []
end


struct ModuleConfiguration
    modules::Dict{AbstractString, Union{FlipFlopModule, ConjunctionModule, OutputModule}}
    connections::Dict{AbstractString, Vector{AbstractString}}
    broadcaster_out::Vector{AbstractString}
end


function parse_input(input)
    config = ModuleConfiguration(Dict(), Dict(), [])
    conjunction_in = Dict{AbstractString, Vector{AbstractString}}()

    for row in split(input, '\n')
        src, dst = split(row, " -> ")
        dst_list = split(dst, ", ")

        if src == "broadcaster"
            append!(config.broadcaster_out, dst_list)
        else
            src_type = src[1]
            src_name = src[2:lastindex(src)]
            if src_type == '%'
                mod = FlipFlopModule(false)
            else
                mod = ConjunctionModule(Dict())
                conjunction_in[src_name] = []
            end

            config.modules[src_name] = mod
            config.connections[src_name] = dst_list

            log_message(1, "created module $mod with name $src_name")
        end
    end

    # find all incoming connections to each conjunction module
    for (src, dsts) in pairs(config.connections)
        for d in dsts
            if d in keys(conjunction_in)
                push!(conjunction_in[d], src)
            end
        end
    end

    # properly initialize conjunction module memory
    for (m, cin) in pairs(conjunction_in)
        for c in cin
            config.modules[m].input_states[c] = false
        end
        log_message(1, "set inputs to $m as $cin")
    end

    # add last output module
    config.modules["output"] = OutputModule()

    return config
end


function solve_part1(input)
    config = parse_input(input)

    count_high = 0
    count_low = 0
    for i in 1:100000000
        count_low += 1  # count the inital low pulse from the button to the broadcaster
        pulses = Deque{Tuple{String, String, Bool}}()
        for m in config.broadcaster_out
            push!(pulses, ("broadcaster", m, false))
        end

        while !isempty(pulses)
            src, dst, pul = popfirst!(pulses)
            if pul
                count_high += 1
            else
                count_low += 1
            end

            if dst ∉ keys(config.modules)
                log_message(2, "ignoring pulse $pul from $src sent to non-existing module $dst")
                continue
            end

            r = handle_pulse(config.modules[dst], pul, src)
            log_message(2, "module $dst handles pulse $pul from $src")
            for pp in r
                for n in config.connections[dst]
                    push!(pulses, (dst, n, pp))
                    log_message(2, " - sending pulse $pp to $n")
                end
            end
        end

        log_message(1, "iteration $i - processed $count_high high and $count_low low pulses, $(length(pulses)) messages in queue")
        if i % 10000 == 0
            log_message(0, "iteration $i - processed $count_high high and $count_low low pulses, $(length(pulses)) messages in queue")
        end
    end

    result = count_high * count_low
    log_message(0, "result is $result")
    
    return result
end

@assert 32000000 == solve_file("2023/inputs/day20-test-2.txt", false)

@assert 11687500 == solve_file("2023/inputs/day20-test-1.txt", false)

MAX_LOG_LEVEL = 0
@assert 898731036 == solve_file("2023/inputs/day20.txt", false)
