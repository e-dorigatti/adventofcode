
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
    function parse_row(row)
        direction, slen, color = split(row)
        len = parse(Int, slen)
        li = direction == "D" ? 1 : direction == "U" ? -1 : 0
        lj = direction == "R" ? 1 : direction == "L" ? -1 : 0
        return len, li, lj
    end

    return solve(input, parse_row)
end


function solve_part2(input)
    function parse_row(row)
        _, _, color = split(row)

        len = parse(Int, color[3:7], base = 16)
        direction = color[8]
        li = direction == '1' ? 1 : direction == '3' ? -1 : 0
        lj = direction == '0' ? 1 : direction == '2' ? -1 : 0
        
        return len, li, lj
    end

    return solve(input, parse_row)
end


function solve(input, row_parser)
    # a split is defined by its position in one coordinate
    # and start/end in the other coordinate
    h_splits = Vector{Tuple{Int, Int, Int}}()
    v_splits = Vector{Tuple{Int, Int, Int}}()

    i = j = 1
    for row in split(input, '\n')
        len, li, lj = row_parser(row)

        di = i + len * li
        dj = j + len * lj

        if i == di
            push!(h_splits, (i, min(j, dj), max(j, dj)))
        elseif j == dj
            push!(v_splits, (j, min(i, di), max(i, di)))
        end

        i, j = di, dj
    end

    ah = compute_area(h_splits)
    #if ah != compute_area(v_splits)
    #    error("??")
    #end

    # the area computed is off by half of the perimeter
    # intuitively, because the splits cut each block exactly in half
    # still not sure why we need to add one...
    perimeter = sum(
        dj - j for (i, j, dj) in h_splits
    ) + sum(
        di - i for (j, i, di) in v_splits
    )

    return ah + div(perimeter, 2) + 1
end


function compute_area(splits::Vector{Tuple{Int, Int, Int}})::Int
    sort!(splits)

    open_intervals = Vector{Tuple{Int, Int}}()
    area = 0
    prev_height = -10000000
    for (height, first, last) in splits
        for (a, b) in open_intervals
            area += (height - prev_height) * (b - a)
        end

        prev_height = height
        new_intervals = Vector{Tuple{Int, Int}}()
        intersects = false
        for (a, b) in open_intervals
            if intersects || (last < a || first > b)
                push!(new_intervals, (a, b))
                if intersects && ((a < first && b > last) || (a < last && b > first))
                    error("??")
                end
            else
                intersects = true
                if a == first && b == last
                    # this interval is now closed
                elseif a < first && b > last
                    # interval is split in two
                    push!(new_intervals, (a, first))
                    push!(new_intervals, (last, b))
                elseif a == first && b > last
                    # interval is shrunk on the left
                    push!(new_intervals, (last, b))
                elseif a < first && b == last
                    # interval is shrunk on the right
                    push!(new_intervals, (a, first))
                elseif a == last
                    # interval is extended on the left
                    push!(new_intervals, (first, b))
                elseif b == first
                    # interval is extended on the right
                    push!(new_intervals, (a, last))
                else
                    error("????")
                end
            end
        end

        if !intersects
            push!(new_intervals, (first, last))
        end

        # merge adjacent intervals
        # TODO could make it faster with an interval tree ?
        if !isempty(new_intervals)
            sort!(new_intervals)
            merged_intervals = Vector{Tuple{Int, Int}}()

            i = 1
            while i <= lastindex(new_intervals)
                a, b = new_intervals[i]
                j = i + 1
                while j <= lastindex(new_intervals) && b == new_intervals[j][1]
                    b = new_intervals[j][2]
                    j += 1
                end

                push!(merged_intervals, (a, b))
                i = j
            end
            open_intervals = merged_intervals
        else
            open_intervals = new_intervals
        end
    end

    if !isempty(open_intervals)
        error("??")
    end

    return area
end


@assert 62 == solve_file("2023/inputs/day18-test.txt", false)
@assert 70026 == solve_file("2023/inputs/day18.txt", false)
@assert 952408144115 == solve_file("2023/inputs/day18-test.txt", true)
@assert 68548301037382 == solve_file("2023/inputs/day18.txt", true)
