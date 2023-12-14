
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


function read_input(input)
    lines = split(input, '\n')
    mat = Matrix(undef, length(lines), length(lines[1]))
    for (i, row) in enumerate(lines)
        for (j, c) in enumerate(row)
            mat[i, j] = c
        end
    end
    
    return mat 
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


function solve_part1(input)
    mat = read_input(input)
    m = lastindex(mat, 1)
    n = lastindex(mat, 2)

    load = 0
    
    #print_mat(mat, "start")
    
    for j in 1:n
        ground = 0
        for i in 1:m
            if mat[i, j] == '#'
                ground = i
            elseif mat[i, j] == 'O'
                if ground + 1 < i
                    mat[ground + 1, j] = mat[i, j]
                    mat[i, j] = '.'
                end
                load += m - ground
                ground += 1
            end
        end
    end

    #print_mat(mat, "end")
    return load
end


@assert 136 == solve_file("2023/inputs/day14-test.txt", false)
@assert 106186 == solve_file("2023/inputs/day14.txt", false)


function move_stone(mat, stone, direction)
    if direction == 1  # north
        inc_i, inc_j = -1, 0
    elseif direction == 2  # west
        inc_i, inc_j = 0, -1
    elseif direction == 3  # south
        inc_i, inc_j = 1, 0
    elseif direction == 4  # east
        inc_i, inc_j = 0, 1
    end

    i, j = stone
    if mat[i, j] == '#'
        error("????")
    end

    last_gap = i, j
    while i >= 1 && j >= 1 && i <= lastindex(mat, 1) && j <= lastindex(mat, 2) && mat[i, j] != '#'
        if mat[i, j] == '.'
            last_gap = i, j
        end
        i += inc_i
        j += inc_j
    end

    return last_gap
end


function solve_part2(input)
    mat = read_input(input)
    m = lastindex(mat, 1)
    n = lastindex(mat, 2)

    stones = Set()
    for i in 1:m
        for j in 1:n
            if mat[i, j] == 'O'
                push!(stones, (i, j))
            end
        end
    end

    num_cycles = 1000000000
    loop_start = loop_length = 0
    seen = Dict(stones => 0)
    for it in 1:num_cycles
        for k in 1:4
            new_stones = Set()
            for (i, j) in stones
                ni, nj = move_stone(mat, (i, j), k)
                mat[i, j] = '.'
                mat[ni, nj] = 'O'
                push!(new_stones, (ni, nj))
            end
            stones = new_stones
            #print_mat(mat, "after $it cycles at direction $k")
        end

        if stones in keys(seen)
            println("loop detected at $it starting at $(seen[stones])")
            loop_start = seen[stones]
            loop_length = it - seen[stones]
            break
        end
        seen[stones] = it
    end

    end_it = loop_start + (num_cycles - loop_start) % loop_length
    end_stones = [s for (s, i) in pairs(seen) if i == end_it][1]
    load = sum(m - i + 1 for (i, j) in end_stones)

    return load
end


@assert 64 == solve_file("2023/inputs/day14-test.txt", true)
@assert 106390 == solve_file("2023/inputs/day14.txt", true)
