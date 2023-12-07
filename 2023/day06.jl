
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


function solve_part1(input::AbstractString)
    lines = split(input, '\n')
    times = [parse(Int, x) for x in split(split(lines[1], ": ")[2], " ", keepempty=false)]
    distances = [parse(Int, x) for x in split(split(lines[2], ": ")[2], " ", keepempty=false)]

    result = 1
    for (time, max_dist) in zip(times, distances)
        count = 0
        for t in 1:time
            dist = (time - t) * t
            if dist > max_dist
                count += 1
            end
        end
        result *= count
    end
    result
end


function solve_part2(input::AbstractString)
    lines = split(input, '\n')

    time = parse(Int, replace(split(lines[1], ": ")[2], " " => ""))
    distance = parse(Int, replace(split(lines[2], ": ")[2], " " => ""))

    count = 0
    for t in 1:time
        dist = (time - t) * t
        if dist > distance
            count += 1
        end
    end
    count
end


solve_file("2023/inputs/day06-test.txt", false)

solve_file("2023/inputs/day06.txt", false)

solve_file("2023/inputs/day06.txt", true)
