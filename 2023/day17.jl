import DataStructures

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

function find_best_path(mat::Matrix{Int8}, min_dist::Int, max_dist::Int)::Int
    m, n = lastindex(mat, 1), lastindex(mat, 2)

    # content: position and direction we came from (and we cannot go further)
    frontier = DataStructures.PriorityQueue{Tuple{Int, Int, Int, Int}, Int}()
    DataStructures.enqueue!(frontier, (1, 1, 0, 0) => 0)

    visited = Set{Tuple{Int, Int, Int, Int}}()

    count_visited = skipped = 0
    while !isempty(frontier)
        k, cost = DataStructures.dequeue_pair!(frontier)

        if k ∈ visited
            continue
        end
        push!(visited, k)

        (i, j, px, py) = k

        count_visited += 1
        if i < 1 || i > m || j < 1 || j > n
            skipped += 1
            continue
        elseif i == m && j == n
            println("found path with cost $cost")
            println("visited $count_visited nodes ($skipped out of bounds)")
            return cost
        end

        #println("visiting position $i $j with cost $cost")
        for (c, d) in [(1, 0), (0, 1), (-1, 0), (0, -1)]
            if (c == px && d == py) || (c == -px && d == -py)
                continue
            end

            new_cost = cost
            di, dj = i, j
            for dist in 1:max_dist
                di += c
                dj += d
                if di < 1 || di > m || dj < 1 || dj > n
                    break
                end

                new_cost += mat[di, dj]
                if dist >= min_dist
                    k = (di, dj, c, d)
                    if k ∈ keys(frontier)
                        if frontier[k] > new_cost
                            frontier[k] = new_cost
                        end
                    else
                        DataStructures.enqueue!(frontier, k, new_cost)
                    end
                end
            end
        end
    end

    return best
end


function solve_part1(input)
    lines = split(input, '\n')
    mat = Matrix{Int8}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = parse(Int8, c)
        end
    end

    return find_best_path(mat, 1, 3)
end


function solve_part2(input)
    lines = split(input, '\n')
    mat = Matrix{Int8}(undef, length(lines), length(lines[1]))

    for (i, r) in enumerate(lines)
        for (j, c) in enumerate(r)
            mat[i, j] = parse(Int8, c)
        end
    end

    return find_best_path(mat, 4, 10)
end


@assert 102 == solve_file("2023/inputs/day17-test.txt", false)

@assert 94 == solve_file("2023/inputs/day17-test.txt", true)

@assert 886 == solve_file("2023/inputs/day17.txt", false)

@assert 1055 == solve_file("2023/inputs/day17.txt", true)

@time solve_file("2023/inputs/day17.txt", true)

@time solve_file("2023/inputs/day17.txt", false)


### DISCARDED IDEAS BELOW ###

@enum Direction North=1 South=2 East=3 West=4


function find_best_path_2(mat::Matrix{Int8}, start_i::Int, start_j::Int)

    cache = Dict{Tuple{Int, Int, Direction, Int}, Int}()

    m = lastindex(mat, 1)
    n = lastindex(mat, 2)

    cost = 0
    path = Dict()

    function aux(i::Int, j::Int, d::Direction, k::Int)::Int
        if i < 1 || i > m || j < 1 || j > n || k < 1
            return 1000000
        elseif i == m && j == n
            println("\nPATH OF COST $cost")
            for a in 1:lastindex(mat, 1)
                for b in 1:lastindex(mat, 2)
                    if (a,b) ∈ keys(path)
                        print(path[a,b])
                    else
                        print(mat[a,b])
                    end
                end
                println()
            end

            return mat[i, j]
        elseif (i, j, d, k) ∈ keys(cache)
            return cache[i, j, d, k]
        end

        cost += mat[i, j]
        c = d == North ? '^' : d == South ? 'v' : d == East ? '>' : d == West ? '<' : '*'
        path[i,j] = c

        cache[i, j, d, k] = 100000  # avoid loops
        if d == North
            res = mat[i, j] + min(
                aux(i, j + 1, East, 2),
                aux(i, j - 1, West, 2),
                aux(i - 1, j, North, k - 1)
            )
        elseif d == South
            res = mat[i, j] + min(
                aux(i, j + 1, East, 2),
                aux(i, j - 1, West, 2),
                aux(i + 1, j, South, k - 1)
            )
        elseif d == East
            res = mat[i, j] + min(
                aux(i + 1, j, South, 2),
                aux(i - 1, j, North, 2),
                aux(i, j + 1, East, k - 1)
            )
        elseif d == West
            res = mat[i, j] + min(
                aux(i + 1, j, South, 2),
                aux(i - 1, j, North, 2),
                aux(i, j - 1, West, k - 1)
            )
        end

        cache[i, j, d, k] = res
        #println(repeat(" ", t), "best at ($i, $j) direction $d remaining steps $k is $res")
        cost -= mat[i, j]
        pop!(keys(path), (i,j))
        return res
    end

    res = min(
        aux(1, 1, East, 3),
        aux(1, 1, South, 3),
    ) - mat[1, 1]
    return res
end


function find_best_path_old(mat::Matrix{Int8}, start_i::Int, start_j::Int)

    cache = Dict{Tuple{Int, Int}, Int}()

    m = lastindex(mat, 1)
    n = lastindex(mat, 2)

    function aux(i::Int, j::Int, t::Int)
        #println(repeat(" ", t), "at $i $j")
        if t > 500
            error("??")
        end

        if i < 1 || i > m || j < 1 || j > n
            return 1000000
        elseif i == m && j == n
            return 0
        elseif (i, j) ∈ keys(cache)
            return cache[i, j]
        end

        cache[i, j] = 1000000  # avoid loops

        res = 1000000
        for d in 1:3
            if i + d <= m
                if j > 1
                    res = min(res, sum(mat[i+1:i+d,j]) + mat[i+d,j-1] + aux(i+d,j-1,t+1))
                end
                if j < n
                    res = min(res, sum(mat[i+1:i+d,j]) + mat[i+d,j+1] + aux(i+d,j+1,t+1))
                end
            end
            if i - d >= 1
                if j > 1
                    res = min(res, sum(mat[i-d:i-1,j]) + mat[i-d,j-1] + aux(i-d,j-1,t+1))
                end
                if j < n
                    res = min(res, sum(mat[i-d:i-1,j]) + mat[i-d,j+1] + aux(i-d,j+1,t+1))
                end
            end
            if j + d <= n
                if i > 1
                    res = min(res, sum(mat[i,j+1:j+d]) + mat[i-1,j+d] + aux(i-1,j+d,t+1))
                end
                if i < m
                    res = min(res, sum(mat[i,j+1:j+d]) + mat[i+1,j+d] + aux(i+1,j+d,t+1))
                end
            end
            if j - d >= 1
                if i > 1
                    res = min(res, sum(mat[i,j-d:j-1]) + mat[i-1,j-d] + aux(i-1,j-d,t+1))
                end
                if i < m
                    res = min(res, sum(mat[i,j-d:j-1]) + mat[i+1,j-d] + aux(i+1,j-d,t+1))
                end
            end
        end

        cache[i, j] = res
        return res
    end

    #re = aux(m - 5, n - 1, 0)
    re = aux(1, 1, 0)
    return re
end

