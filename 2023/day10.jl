
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end


function move_next(mat, pos, prev)
    north = p -> (p[1] - 1, p[2])
    south = p -> (p[1] + 1, p[2])
    east = p -> (p[1], p[2] + 1)
    west = p -> (p[1], p[2] - 1)

    if mat[pos[1], pos[2]] == 'S'
        # handle starting position by choosing one random direction
        i, j = pos
        if i > 1 && mat[i - 1, j] != '.'
            return (i - 1, j), pos
        elseif j > 1 && mat[i, j - 1] != '.'
            return (i, j - 1), pos
        elseif i < lastindex(mat, 1) && mat[i + 1, j] != '.'
            return (i + 1, j), pos
        elseif j < lastindex(mat, 2) && mat[i, j + 1] != '.'
            return (i, j + 1), pos
        else
            error("Starting point not connected to pipes")
        end
    end

    # in other cases, choose direction that
    # does not lead to previous position
    if mat[pos[1], pos[2]] == '|'
        (next1, next2) = (north(pos), south(pos))
    elseif mat[pos[1], pos[2]] == '-'
        (next1, next2) = (west(pos), east(pos))
    elseif mat[pos[1], pos[2]] == 'L'
        (next1, next2) = (north(pos), east(pos))
    elseif mat[pos[1], pos[2]] == 'J'
        (next1, next2) = (north(pos), west(pos))
    elseif mat[pos[1], pos[2]] == '7'
        (next1, next2) = (south(pos), west(pos))
    elseif mat[pos[1], pos[2]] == 'F'
        (next1, next2) = (south(pos), east(pos))
    elseif mat[pos[1], pos[2]] == '.'
        error("position outside of pipes")
    end

    if next1 == prev
        return next2, pos
    elseif next2 == prev
        return next1, pos
    else
        error("incorrect previous position")
    end
end


function solve_part1(input)
    lines = split(input, '\n')
    start_pos = (0, 0)
    mat = Matrix{Char}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = c
            if c == 'S'
                start_pos = (i, j)
                println("found start at coordinates $start_pos")
            end
        end
    end

    steps, pos, prev = 0, start_pos, nothing
    while isnothing(prev) || pos != start_pos
        pos, prev = move_next(mat, pos, prev)
        steps += 1
        println("step $steps moved to $pos")
    end
    println("done in $steps")
    return div(steps, 2)
end


function flood_fill(mat, pos, symbol)
    flooded = Set()
    frontier = [pos]
    while !isempty(frontier)
        i, j = pop!(frontier)
        mat[i, j] = symbol
        push!(flooded, (i, j))

        if i > 1 && mat[i - 1, j] == '.'
            push!(frontier, (i - 1, j))
        end

        if j > 1 && mat[i, j - 1] == '.'
            push!(frontier, (i, j - 1))
        end

        if i < lastindex(mat, 1) && mat[i + 1, j] == '.'
            push!(frontier, (i + 1, j))
        end

        if j < lastindex(mat, 2) && mat[i, j + 1] == '.'
            push!(frontier, (i, j + 1))
        end
    end
    return flooded
end


function print_mat(mat, title, hightlight=nothing)
    println(title)
    for i in 1:lastindex(mat, 1)
        for j in 1:lastindex(mat, 2)
            if !isnothing(hightlight) && (i, j) in hightlight
                print('*')
            else
                print(mat[i, j])
            end
        end
        println()
    end
end


function is_inside_loop(mat, pos)
    # idea: all points inside the loop must cross
    # the pipes an odd numer of times
    i, j = pos
    crossings_east = 0
    while j <= lastindex(mat, 2)
        if mat[i, j] in "|LJ"
            crossings_east += 1
        end
        j += 1
    end
    return crossings_east % 2 == 1
end


function solve_part2(input)
    lines = split(input, '\n')
    start_pos = (0, 0)
    mat = Matrix{Char}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = c
            if c == 'S'
                start_pos = (i, j)
                println("found start at coordinates $start_pos")
            end
        end
    end

    # step 1: find all pipes in the loop
    pos, prev = start_pos, nothing
    loop = Set{Tuple{Int, Int}}()
    while isnothing(prev) || pos != start_pos
        push!(loop, pos)
        pos, prev = move_next(mat, pos, prev)
    end

    # step 2: delete all pipes not in the loop
    for i in 1:lastindex(mat, 1)
        for j in 1:lastindex(mat, 2)
            if (i, j) in loop
                continue
            elseif mat[i, j] != 'S'
                mat[i, j] = '.'
            end
        end
    end

    # step 3: flood-fill all ground (add a symbol to differentiate areas)
    symbols = "abcdefghijklmnopqrstuvwxyz"
    flood_areas = []
    cs = 1
    for i in 1:lastindex(mat, 1)
        for j in 1:lastindex(mat, 2)
            if mat[i, j] == '.'
                flooded = flood_fill(mat, (i, j), symbols[cs])
                push!(flood_areas, flooded)

                cs += 1
                if cs > lastindex(symbols)
                    cs = 1
                end
            end
        end
    end

    println("flooded $(length(flood_areas)) different areas")
    print_mat(mat, "after flood-filling")

    # step 4: determine areas inside the loop
    count = 0
    for (k, area) in enumerate(flood_areas)
        for pos in area
            if is_inside_loop(mat, pos)
                count += length(area)
                println("area $k of size $(length(area)) is inside the loop")
            end
            break
        end
    end

    println("total size of areas inside the loop: $count")

    return count
end

#@run solve_file("2023/inputs/day10-test-2.txt", true)

#@run solve_file("2023/inputs/day10-test-3.txt", true)

@assert 317 == solve_file("2023/inputs/day10.txt", true)

#solve_file("2023/inputs/day10-test.txt", true)

#solve_file("2023/inputs/day10-test.txt", false)

@assert 7086 == solve_file("2023/inputs/day10.txt", false)