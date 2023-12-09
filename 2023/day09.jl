
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end


function solve_part1(input)
    lines = split(input, '\n')

    result = 0
    for row in lines
        nums = [parse(Int, x) for x in split(row)]
        result += nums[lastindex(nums)]

        while length(nums) > 0 && !all(x == 0 for x in nums)
            diffs = [nums[i] - nums[i - 1] for i in 2:lastindex(nums)]
            result += diffs[lastindex(diffs)]
            nums = diffs
        end
    end

    return result
end


function solve_part2(input)
    lines = split(input, '\n')

    result = 0
    for row in lines
        nums = [parse(Int, x) for x in split(row)]

        heads = [nums[1]]
        while length(nums) > 0 && !all(x == 0 for x in nums)
            diffs = [nums[i] - nums[i - 1] for i in 2:lastindex(nums)]
            push!(heads, diffs[1])
            nums = diffs
        end

        println(heads)
        last = 0
        for i in (lastindex(heads)-1):-1:1
            x = heads[i] - last
            println("$x")
            last = x
        end
        result += last
    end

    return result
end

@assert 1053 == solve_file("2023/inputs/day09.txt", true)

solve_file("2023/inputs/day09-test.txt", true)

solve_file("2023/inputs/day09-test.txt", false)

@assert 1743490457 == solve_file("2023/inputs/day09.txt", false)
