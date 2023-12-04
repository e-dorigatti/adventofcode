

function solve_part1(input::AbstractString)
    i = 1
    res = 0
    for row in split(input, "\n")
        if length(row) == 0
            continue
        end

        game = split(row, ": ")[2]
        draws = split(game, "; ")
        game_possible = true
        for dr in draws
            color_counts = split(dr, ", ")
            for cc in color_counts 
                (count_str, color) = split(cc)
                count = parse(Int, count_str)
                #println("game $(i) color $(color) count $(count)")
                if color == "red" && count > 12
                    game_possible = false
                elseif color == "green" && count > 13
                    game_possible = false
                elseif color == "blue" && count > 14
                    game_possible = false
                end
            end
        end

        if game_possible
            res += i
        end

        #println("game $(i) : $(game_possible)")

        i += 1
    end

    return res
end
solve_file("inputs/day02-test.txt", false)

function solve_part2(input::AbstractString)
    i = 1
    res = 0
    for row in split(input, "\n")
        if length(row) == 0
            continue
        end

        min_red = min_green = min_blue = typemin(Int)
        game = split(row, ": ")[2]
        draws = split(game, "; ")
        for dr in draws
            color_counts = split(dr, ", ")
            for cc in color_counts 
                (count_str, color) = split(cc)
                count = parse(Int, count_str)
                if color == "red"
                    min_red = max(min_red, count)
                elseif color == "green"
                    min_green = max(min_green, count)
                elseif color == "blue"
                    min_blue = max(min_blue, count)
                end
                #println("game $(i) : $(min_red) $(min_green) $(min_blue) $(color) $(count)")
            end
        end
        
        power = min_red * min_green * min_blue
        res += power

        #println("game $(i) : $(min_red) $(min_green) $(min_blue) $(power)")

        i += 1
    end

    return res
end


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



solve_file("inputs/day02-test.txt", true)
solve_file("inputs/day02.txt", false)
solve_file("inputs/day02.txt", true)
