
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
    arr = read_grid(input)

    result = 0
    for i in 1:lastindex(arr, 1)
        j = 1
        while j <= lastindex(arr, 2)
            if isdigit(arr[i, j])
                number, num_end = parse_number(arr, i, j)

                if is_part_number(arr, i, j, num_end)
                    result += number
                end

                j = num_end + 1
            else
                j += 1
            end
        end
    end
    return result
end


function read_grid(input::AbstractString)
    nrow = count(c -> c == '\n', input) + 1
    ncol = findfirst([c == '\n' for c in input]) - 1
    arr = Matrix{Char}(undef, nrow, ncol)

    i = 1
    for row in split(input, "\n")
        j = 1
        for c in row
            arr[i, j] = c
            j += 1
        end
        i += 1
    end

    return arr
end


function parse_number(arr::Matrix{Char}, i::Int, j::Int)
    num_start = num_end = k = j
    while k <= lastindex(arr, 2)
        if isdigit(arr[i, k])
            num_end = k
        else
            break
        end
        k += 1
    end
    number = parse(Int, join(arr[i, num_start:num_end]))

    return number, num_end
end


function is_part_number(arr::Matrix{Char}, row::Int, num_start::Int, num_end::Int)
    is_symbol = c -> c != '.' && !isdigit(c)

    if num_start > 1
        if is_symbol(arr[row, num_start - 1])
            return true
        elseif row > 1 && is_symbol(arr[row - 1, num_start - 1])
            return true
        elseif row < lastindex(arr, 1) && is_symbol(arr[row + 1, num_start - 1])
            return true
        end
    end

    if num_end < lastindex(arr, 2)
        if is_symbol(arr[row, num_end + 1])
            return true
        elseif row > 1 && is_symbol(arr[row - 1, num_end + 1])
            return true
        elseif row < lastindex(arr, 1) && is_symbol(arr[row + 1, num_end + 1])
            return true
        end
    end

    if row > 1
        for j in num_start:num_end
            if is_symbol(arr[row - 1, j])
                return true
            end
        end
    end

    if row < lastindex(arr, 1)
        for j in num_start:num_end
            if is_symbol(arr[row + 1, j])
                return true
            end
        end
    end

    return false
end


solve_file("inputs/day03-test.txt", false) 
solve_file("inputs/day03.txt", false) 


function find_nearby_gears(arr::Matrix{Char}, row::Int, num_start::Int, num_end::Int)
    gears = Vector{Tuple{Int16, Int16}}()

    function check(i::Int,  j::Int)
        if (i >= firstindex(arr, 1) 
                && i <= lastindex(arr, 1) 
                && j >= firstindex(arr, 2) 
                && j <= lastindex(arr, 2) 
                && arr[i, j] == '*')

            push!(gears, (i, j))
        end
    end

    check(row, num_start - 1)
    check(row - 1, num_start - 1)
    check(row + 1, num_start - 1)

    check(row, num_end + 1)
    check(row - 1, num_end + 1)
    check(row + 1, num_end + 1)

    if row > 1
        for j in num_start:num_end
            check(row - 1, j)
        end
    end

    if row < lastindex(arr, 1)
        for j in num_start:num_end
            check(row + 1, j)
        end
    end

    return gears
end


function solve_part2(input::AbstractString)
    arr = read_grid(input)

    gears_to_number = Dict{Tuple{Int16, Int16}, Vector{Int32}}()

    for i in 1:lastindex(arr, 1)
        j = 1
        while j <= lastindex(arr, 2)
            if isdigit(arr[i, j])
                number, num_end = parse_number(arr, i, j)

                nearby_gears = find_nearby_gears(arr, i, j, num_end)
                for coords in nearby_gears
                    if coords ∉ keys(gears_to_number)
                        gears_to_number[coords] = []
                    end
                    push!(gears_to_number[coords], number)
                end

                j = num_end + 1
            else
                j += 1
            end
        end
    end

    result = 0
    for nearby_parts in values(gears_to_number)
        if length(nearby_parts) == 2
            ratio = nearby_parts[1] * nearby_parts[2]
            result += ratio
        end
    end

    return result
end


solve_file("inputs/day03-test.txt", true)

@time solve_file("inputs/day03.txt", false)
@time solve_file("inputs/day03.txt", true)
