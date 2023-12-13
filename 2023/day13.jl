
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r");
    input = read(io, String)
    if is_part_2
        solution = solve(input, is_part_2)
    else
        solution = solve(input, is_part_2)
    end
    return solution
end


function solve(input, is_part_2)
    lines = split(input, '\n')

    # pls add empty line at the end of the input file
    result = 0
    pattern_start = 0
    for (i, row) in enumerate(lines)
        if isempty(row)
            mat = Matrix(undef, i - pattern_start - 1, length(lines[i - 1]))
            for j in (pattern_start+1):(i-1)
                for k in 1:lastindex(lines[i - 1])
                    mat[j - pattern_start, k] = lines[j][k]
                end
            end

            if is_part_2
                result += solve_pattern_part2(mat)
            else
                result += solve_pattern_part1(mat)
            end
            pattern_start = i
        end
    end
    
    return result
end


function solve_pattern_part1(pattern)

    cache = Dict()
    function is_reflection(i, j, axis)
        if j <= i
            return true
        end

        key = (i, j, axis)
        if key ∉ keys(cache)
            # first check if rows/columns i and j are the same
            result = true
            for k in 1:lastindex(pattern, axis)
                ci = axis == 1 ? pattern[k, i] : pattern[i, k]
                cj = axis == 1 ? pattern[k, j] : pattern[j, k]

                if ci != cj
                    result = false
                    break
                end
            end

            if result
                # if so, check the inner part for reflection
                result = is_reflection(i + 1, j - 1, axis)
            end

            cache[key] = result
        end

        return cache[key]
    end

    function find_before_perfect_reflection(axis)
        n = lastindex(pattern, axis == 1 ? 2 : 1)
        for i in 0:(n - 2)
            if is_reflection(1, n - i, axis)
                return div(1 + n - i, 2)
            elseif is_reflection(i + 1, n, axis)
                return div(i + 1 + n, 2)
            end
        end
        return 0
    end

    columns_before = find_before_perfect_reflection(1)
    rows_before = find_before_perfect_reflection(2)

    return 100 * rows_before + columns_before
end

@assert 405 == solve_file("2023/inputs/day13-test.txt", false)
@assert 33195 == solve_file("2023/inputs/day13.txt", false)

function solve_pattern_part2(pattern)

    cache = Dict()
    function is_reflection(i, j, axis, can_smudge)
        if j <= i
            # must have found the smudge
            return !can_smudge
        elseif (j - i) % 2 == 0
            # reflection lines can only be between rows/columns
            return false
        end

        key = (i, j, axis, can_smudge)
        if key ∉ keys(cache)
            # first check if rows/columns i and j are the same or with a smudge
            # we may have the option of accepting a single difference to determine
            # reflections

            result = true
            for k in 1:lastindex(pattern, axis)
                ci = axis == 1 ? pattern[k, i] : pattern[i, k]
                cj = axis == 1 ? pattern[k, j] : pattern[j, k]

                if ci != cj
                    if can_smudge
                        can_smudge = false
                    else
                        result = false
                        break
                    end
                end
            end

            if result
                # if so, check the inner part for reflection
                # accounting for possible smudges found
                result = is_reflection(i + 1, j - 1, axis, can_smudge)
            end

            cache[key] = result
        end

        return cache[key]
    end

    function find_smudged_before_perfect_reflection(axis)
        n = lastindex(pattern, axis == 1 ? 2 : 1)
        for i in 0:(n - 2)
            if is_reflection(1, n - i, axis, true)
                return div(1 + n - i, 2)
            elseif is_reflection(i + 1, n, axis, true)
                return div(i + 1 + n, 2)
            end
        end
        return 0
    end

    columns_before = find_smudged_before_perfect_reflection(1)
    rows_before = find_smudged_before_perfect_reflection(2)

    return 100 * rows_before + columns_before
end


@assert 400 == solve_file("2023/inputs/day13-test.txt", true)

@assert 31836 == solve_file("2023/inputs/day13.txt", true)