
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


function solve_part1(input)
    lines = split(input, '\n')
    
    galaxies = []
    expand_rows = Set(1:length(lines))
    expand_cols = Set(1:length(lines[1]))
    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            if c == '#'
                push!(galaxies, (i, j))
                delete!(expand_rows, i)
                delete!(expand_cols, j)
            end
        end
    end

    result = 0
    for i in 1:(lastindex(galaxies)-1)
        for j in (i+1):lastindex(galaxies)
            g = galaxies[i]
            h = galaxies[j]

            (r1, r2) = min(g[1], h[1]), max(g[1], h[1])
            (c1, c2) = min(g[2], h[2]), max(g[2], h[2])

            dist = (r2 - r1) + (c2 - c1)
            dist += sum(1 for i in r1:r2 if i in expand_rows; init = 0)
            dist += sum(1 for j in c1:c2 if j in expand_cols; init = 0)

            result += dist
        end
    end

    return result
end


function solve_part2(input)
    lines = split(input, '\n')
    
    galaxies = []
    expand_rows = Set(1:length(lines))
    expand_cols = Set(1:length(lines[1]))
    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            if c == '#'
                push!(galaxies, (i, j))
                delete!(expand_rows, i)
                delete!(expand_cols, j)
            end
        end
    end

    result = 0
    for i in 1:(lastindex(galaxies)-1)
        for j in (i+1):lastindex(galaxies)
            g = galaxies[i]
            h = galaxies[j]

            (r1, r2) = min(g[1], h[1]), max(g[1], h[1])
            (c1, c2) = min(g[2], h[2]), max(g[2], h[2])

            dist = (r2 - r1) + (c2 - c1)
            dist += sum(999999 for i in r1:r2 if i in expand_rows; init = 0)
            dist += sum(999999 for j in c1:c2 if j in expand_cols; init = 0)

            result += dist
        end
    end

    return result
end


@assert 374 == solve_file("2023/inputs/day11-test.txt", false)

@assert 9965032 == solve_file("2023/inputs/day11.txt", false)

@assert 550358864332 == solve_file("2023/inputs/day11.txt", true)