
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end


mutable struct Beam
    pos_i::Int
    pos_j::Int
    vel_i::Int
    vel_j::Int
    blocked::Bool
end


function new_beam(pos_i, pos_j, vel_i, vel_j)
    return Beam(
        pos_i, pos_j,
        vel_i, vel_j,
        false
    )
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


function beam_step(beam, mat)
    if beam.blocked
        return false
    end

    if (beam.pos_i < 1 || beam.pos_i > lastindex(mat, 1) 
            || beam.pos_j < 1 || beam.pos_j > lastindex(mat, 2))
        beam.blocked = true
        return false
    end

    split_beam = false
    c = mat[beam.pos_i, beam.pos_j]

    if c == '-'
        if beam.vel_i != 0
            split_beam = true
            beam.vel_i, beam.vel_j = 0, 1
        end
    elseif c == '|'
        if beam.vel_j != 0
            split_beam = true
            beam.vel_i, beam.vel_j = 1, 0
        end
    elseif c == '\\' || c == '/'
        r = c == '/' ? 1 : -1
        if beam.vel_i > 0
            beam.vel_i, beam.vel_j = 0, -r
        elseif beam.vel_i < 0
            beam.vel_i, beam.vel_j = 0, r
        elseif beam.vel_j > 0
            beam.vel_i, beam.vel_j = -r, 0
        elseif beam.vel_j < 0
            beam.vel_i, beam.vel_j = r, 0
        end
    end

    beam.pos_i += beam.vel_i
    beam.pos_j += beam.vel_j

    return split_beam
end


function find_energized_tiles(mat, pos_i, pos_j, vel_i, vel_j)
    beams = Set{Beam}([new_beam(pos_i, pos_j, vel_i, vel_j)])
    beam_paths = Set()
    dont_stop = true
    i = 0
    while dont_stop
        dont_stop = false
        for be in beams
            k = (be.pos_i, be.pos_j, be.vel_i, be.vel_j)
            if k ∈ beam_paths
                continue
            end
            push!(beam_paths, k)

            if beam_step(be, mat)
                push!(beams, new_beam(
                    be.pos_i - 2 * be.vel_i,
                    be.pos_j - 2 * be.vel_j,
                    -be.vel_i,
                    -be.vel_j
                ))
            end

            if !be.blocked
                dont_stop = true
            end
        end
    end

    energized_tiles = Set{Tuple{Int, Int}}()
    for k in beam_paths
        if k[1] >= 1 && k[1] <= lastindex(mat, 1) && k[2] >= 1 && k[2] <= lastindex(mat ,2)
            push!(energized_tiles, (k[1], k[2]))
        end
    end

    return length(energized_tiles)
end


function solve_part1(input)
    lines = split(input, '\n')
    mat = Matrix{Char}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = c
        end
    end

    return find_energized_tiles(mat, 1, 1, 0, 1)
end


@assert 46 == solve_file("2023/inputs/day16-test.txt", false)
@assert 7111 == solve_file("2023/inputs/day16.txt", false)


function solve_part2(input)
    lines = split(input, '\n')
    mat = Matrix{Char}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = c
        end
    end

    max_en = 0
    for i in 1:lastindex(mat, 1)
        en = find_energized_tiles(mat, i, 1, 0, 1)
        max_en = max(max_en, en)

        en = find_energized_tiles(mat, i, lastindex(mat, 2), 0, -1)
        max_en = max(max_en, en)
    end
    for j in 1:lastindex(mat, 2)
        en = find_energized_tiles(mat, 1, j, 1, 0)
        max_en = max(max_en, en)

        en = find_energized_tiles(mat, lastindex(mat, 1), j, -1, 0)
        max_en = max(max_en, en)
    end

    return max_en
end


@assert 51 == solve_file("2023/inputs/day16-test.txt", true)

@assert 7831 == solve_file("2023/inputs/day16.txt", true)
