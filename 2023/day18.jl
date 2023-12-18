
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
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


function flood(mat, i, j)
    frontier = [(i, j)]
    while !isempty(frontier)
        i, j = pop!(frontier)
        if i < 1 || j < 1 || i > lastindex(mat, 1) || j > lastindex(mat, 2) || mat[i, j] != '.'
            continue
        end

        mat[i, j] = 'o'

        push!(frontier, (i + 1, j))
        push!(frontier, (i - 1, j))
        push!(frontier, (i, j + 1))
        push!(frontier, (i, j - 1))
    end
end


function solve_part1(input)
    trench = Set{Tuple{Int, Int}}()

    i = j = maxi = maxj = mini = minj = 1
    push!(trench, (i, j))
    for row in split(input, '\n')
        direction, slength, color = split(row)
        di = direction == "D" ? 1 : direction == "U" ? -1 : 0
        dj = direction == "R" ? 1 : direction == "L" ? -1 : 0

        for s in 1:parse(Int, slength)
            i += di
            j += dj
            push!(trench, (i, j))
            maxi = max(maxi, i)
            maxj = max(maxj, j)
            mini = min(mini, i)
            minj = min(minj, j)
        end
    end

    mat = Matrix{Char}(undef, maxi - mini + 1, maxj - minj + 1)
    for i in mini:maxi
        for j in minj:maxj
            mat[i - mini + 1, j - minj + 1] = (i, j) ∈ trench ? '#' : '.'
        end
    end

    for i in 1:lastindex(mat, 1)
        flood(mat, i, 1)
        flood(mat, i, lastindex(mat, 2))
    end
    for j in 1:lastindex(mat, 2)
        flood(mat, 1, j)
        flood(mat, lastindex(mat, 1), j)
    end

    count = 0
    for i in 1:lastindex(mat, 1)
        for j in 1:lastindex(mat, 2)
            if mat[i, j] != 'o'
                count += 1
            end
        end
    end


    return count
end

@assert 62 == solve_file("2023/inputs/day18-test.txt", false)

@assert 70026 == solve_file("2023/inputs/day18.txt", false)


function solve_part2(input)
    trench = Set{Tuple{Int, Int, Int, Int}}()

    i = j = 1
    for row in split(input, '\n')
        _, _, color = split(row)

        length = parse(Int, color[3:7], base = 16)
        direction = color[8]
        li = direction == '1' ? 1 : direction == '3' ? -1 : 0
        lj = direction == '0' ? 1 : direction == '2' ? -1 : 0

        di = i + length * li
        dj = j + length * lj
        push!(trench, (i, j, di, dj))

        i, j = di, dj
    end

    h_splits = Vector{Int}()
    v_splits = Vector{Int}()
    for (i, j, di, dj) in trench
        if i == di
            push!(h_splits, i)
        elseif j == dj
            push!(v_splits, j)
        else
            error("???")
        end
    end

    sort!(h_splits)
    sort!(v_splits)
end

@run solve_file("2023/inputs/day18-test.txt", true)

solve_file("2023/inputs/day18.txt", true)
