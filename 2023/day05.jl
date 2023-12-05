
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r");
    input = read(io, String)
    if is_part_2
        solution = solve_part2(input)
    else
        solution = solve_part1(input)
    end
    return solution
end


mutable struct RangeMap
    key_start::Vector{Int}
    value_start::Vector{Int}
    length::Vector{Int}
end


function sort_by_key!(rm::RangeMap)
    p = sortperm(rm.key_start)
    rm.key_start = rm.key_start[p]
    rm.value_start = rm.value_start[p]
    rm.length = rm.length[p]
end


function get_value(rm::RangeMap, k::Int)::Int
    i = searchsortedlast(rm.key_start, k)
    if i > 0 && i <= length(rm.key_start) && k < rm.key_start[i] + rm.length[i]
        # inside the interval
        val = rm.value_start[i] + k - rm.key_start[i]
        println("mapped $k to interval $(rm.key_start[i]) length $(rm.length[i]) and value $val")
    else
        # outside the interval, but before the next interval starts
        val = k
        println("mapped $k outside interval at $(i) to value $val")
    end
    return val
end


function solve_part1(input::AbstractString)
    rows = split(input, '\n')
    j = 1

    # parse stuff
    seed_to_soil = RangeMap([], [], [])
    soil_to_fertilizer = RangeMap([], [], [])
    fertilizer_to_water = RangeMap([], [], [])
    water_to_light = RangeMap([], [], [])
    light_to_temperature = RangeMap([], [], [])
    temperature_to_humidity = RangeMap([], [], [])
    humidity_to_location = RangeMap([], [], [])

    seeds = [parse(Int, x) for x in split(split(rows[1], ": ")[2])]

    j = 3
    while j < length(rows)
        @assert endswith(rows[j], " map:")
        map_name = split(rows[j])[1]
        if map_name == "seed-to-soil"
            current_map = seed_to_soil
        elseif map_name == "soil-to-fertilizer"
            current_map = soil_to_fertilizer
        elseif map_name == "fertilizer-to-water"
            current_map = fertilizer_to_water
        elseif map_name == "water-to-light"
            current_map = water_to_light
        elseif map_name == "light-to-temperature"
            current_map = light_to_temperature
        elseif map_name == "temperature-to-humidity"
            current_map = temperature_to_humidity
        elseif map_name == "humidity-to-location"
            current_map = humidity_to_location
        end

        j += 1
        while j < length(rows) && length(rows[j]) > 0
            to_start, from_start, size = [parse(Int, x) for x in split(rows[j])]
            push!(current_map.key_start, from_start)
            push!(current_map.value_start, to_start)
            push!(current_map.length, size)
            j += 1
        end
        j += 1
    end

    sort_by_key!(seed_to_soil)
    sort_by_key!(soil_to_fertilizer)
    sort_by_key!(fertilizer_to_water)
    sort_by_key!(water_to_light)
    sort_by_key!(light_to_temperature)
    sort_by_key!(temperature_to_humidity)
    sort_by_key!(humidity_to_location)

    # solve problem
    lowest = typemax(Int)
    for s in seeds
        p = s
        p = get_value(seed_to_soil, p)
        p = get_value(soil_to_fertilizer, p)
        p = get_value(fertilizer_to_water, p)
        p = get_value(water_to_light, p)
        p = get_value(light_to_temperature, p)
        p = get_value(temperature_to_humidity, p)
        p = get_value(humidity_to_location, p)
        lowest = min(lowest, p)
        println("mapped seed $s to position $p")
    end

    return lowest
end


solve_file("2023/inputs/day05-test.txt", false)
@time solve_file("2023/inputs/day05.txt", false)


struct Interval
    # NB - endpoint start+length NOT included
    start::Int
    length::Int
end


function map_interval(rm::RangeMap, start::Int, length::Int, result::Vector{Interval})
    if length <= 0
        return
    end
    
    k = searchsortedlast(rm.key_start, start)
    if k == 0
        # interval starts before the first, check end
        if start + length <= rm.key_start[1]
            # no intersection, interval stays the same
            push!(result, Interval(start, length))
        else
            # intersection with first interval
            # preserve first chunk and recur on intersecting interval

            part1 = Interval(start, rm.key_start[1] - start)
            part2 = Interval(rm.key_start[1], length - part1.length)

            @assert part2.start == part1.start + part1.length
            @assert part1.length + part2.length == length
            @assert part2.start + part2.length == start + length

            push!(result, Interval(part1.start, part1.length))
            map_interval(rm, part2.start, part2.length, result)
        end
    elseif start < rm.key_start[k] + rm.length[k]
        # start is inside interval k, check end
        if start + length <= rm.key_start[k] + rm.length[k]
            # end is also inside interval k, map whole interval
            push!(result, Interval(rm.value_start[k] + start - rm.key_start[k], length))
        else
            # end is in another interval, map intersection and recur on rest
            part1 = Interval(start, rm.key_start[k] + rm.length[k] - start)
            part2 = Interval(rm.key_start[k] + rm.length[k], length - part1.length)

            @assert part2.start == part1.start + part1.length
            @assert part1.length + part2.length == length
            @assert part2.start + part2.length == start + length

            offset = rm.value_start[k] - rm.key_start[k]
            part1_dest = Interval(part1.start + offset, part1.length)

            push!(result, Interval(part1_dest.start, part1_dest.length))
            map_interval(rm, part2.start, part2.length, result)
        end
    else
        # interval starts after the last thus stays the same
        push!(result, Interval(start, length))
    end
end


function map_all_intervals(rm::RangeMap, its::Vector{Interval})::Vector{Interval}
    result = Vector{Interval}()
    for it in its
        #pr = Vector{Interval}()
        #map_interval(rm, it.start, it.length, pr)
        #println("mapped $it to $pr")
        #append!(result, pr)
        map_interval(rm, it.start, it.length, result)
    end
    return result
end


function solve_part2(input::AbstractString)
    rows = split(input, '\n')
    j = 1

    seed_to_soil = RangeMap([], [], [])
    soil_to_fertilizer = RangeMap([], [], [])
    fertilizer_to_water = RangeMap([], [], [])
    water_to_light = RangeMap([], [], [])
    light_to_temperature = RangeMap([], [], [])
    temperature_to_humidity = RangeMap([], [], [])
    humidity_to_location = RangeMap([], [], [])

    seed_bounds = [parse(Int, x) for x in split(split(rows[1], ": ")[2])]
    seed_intervals = Vector{Interval}()
    j = 1
    while j < length(seed_bounds)
        push!(seed_intervals, Interval(seed_bounds[j], seed_bounds[j + 1]))
        j += 2
    end

    j = 3
    while j < length(rows)
        @assert endswith(rows[j], " map:")
        map_name = split(rows[j])[1]
        if map_name == "seed-to-soil"
            current_map = seed_to_soil
        elseif map_name == "soil-to-fertilizer"
            current_map = soil_to_fertilizer
        elseif map_name == "fertilizer-to-water"
            current_map = fertilizer_to_water
        elseif map_name == "water-to-light"
            current_map = water_to_light
        elseif map_name == "light-to-temperature"
            current_map = light_to_temperature
        elseif map_name == "temperature-to-humidity"
            current_map = temperature_to_humidity
        elseif map_name == "humidity-to-location"
            current_map = humidity_to_location
        end

        j += 1
        while j < length(rows) && length(rows[j]) > 0
            to_start, from_start, size = [parse(Int, x) for x in split(rows[j])]
            push!(current_map.key_start, from_start)
            push!(current_map.value_start, to_start)
            push!(current_map.length, size)
            j += 1
        end
        j += 1
    end

    sort_by_key!(seed_to_soil)
    sort_by_key!(soil_to_fertilizer)
    sort_by_key!(fertilizer_to_water)
    sort_by_key!(water_to_light)
    sort_by_key!(light_to_temperature)
    sort_by_key!(temperature_to_humidity)
    sort_by_key!(humidity_to_location)

    # solve
    lowest = typemax(Int)
    for sit in seed_intervals
        dest = [sit]
        dest = map_all_intervals(seed_to_soil, dest)
        dest = map_all_intervals(soil_to_fertilizer, dest)
        dest = map_all_intervals(fertilizer_to_water, dest)
        dest = map_all_intervals(water_to_light, dest)
        dest = map_all_intervals(light_to_temperature, dest)
        dest = map_all_intervals(temperature_to_humidity, dest)
        dest = map_all_intervals(humidity_to_location, dest)
        lowest = min(lowest, minimum([it.start for it in dest]))
        println("seed $sit mapped to $dest")
    end

    println("solution is $lowest")
    return lowest
end


@run solve_file("2023/inputs/day05-test.txt", true)

#@assert 46 == solve_file("2023/inputs/day05-test.txt", true)

#@time solve_file("2023/inputs/day05.txt", true)

# 52510809 - correct
