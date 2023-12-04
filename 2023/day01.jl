
function find_first_num(s::AbstractString)
    for c in s
        if isdigit(c)
            return parse(Int, c)
        end
    end
    return 0
end


function solve(input::AbstractString, is_part_2::Bool)
    tot = 0
    for line in split(input, "\n")
        if is_part_2
            l1 = replace(line, "one"=>"1", "two"=>"2", "three"=>"3", "four"=>"4", "five"=>"5", "six"=>"6", "seven"=>"7", "eight"=>"8", "nine"=>"9")
            n1 = find_first_num(l1)

            l2 = replace(reverse(line), "eno"=>"1", "owt"=>"2", "eerht"=>"3", "ruof"=>"4", "evif"=>"5", "xis"=>"6", "neves"=>"7", "thgie"=>"8", "enin"=>"9")
            n2 = find_first_num(l2)
        else
            n1 = find_first_num(line)
            n2 = find_first_num(reverse(line))
        end

        s = 10 * n1 + n2
        tot += s
    end
    return tot
end


function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r");
    input = read(io, String)
    solution = solve(input, is_part_2)
    return solution
end


solve_file("inputs/day01-test-first.txt", false)
solve_file("inputs/day01.txt", false)
solve_file("inputs/day01-test-second.txt", true)
solve_file("inputs/day01.txt", true)
