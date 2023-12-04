
function solve_file(path::AbstractString, is_part_2::Bool)
    io = open(path, "r")
    input = read(io, String)
    if is_part_2
        return solve_part2(input)
    else
        return solve_part1(input)
    end
end

function solve_part1(input::AbstractString)
    result = 0
    for row in split(input, "\n")
        if length(row) == 0
            continue
        end

        numbers = split(row, ": ")[2]
        winning_list, have_list = split(numbers, " | ")
        winning = Set([parse(Int, x) for x in split(winning_list)])
        have = Set([parse(Int, x) for x in split(have_list)])

        have_winning = length(intersect(have, winning))
        if have_winning > 0
            card_score = 2 ^ (have_winning - 1)
            result += card_score
        end
    end
    return result
end


function solve_part2(input::AbstractString)
    num_cards = count(c -> c == '\n', input) + 1
    won_cards = ones(Int, num_cards)

    i = 1
    for row in split(input, "\n")
        numbers = split(row, ": ")[2]
        winning_list, have_list = split(numbers, " | ")
        winning = Set([parse(Int, x) for x in split(winning_list)])
        have = Set([parse(Int, x) for x in split(have_list)])

        have_winning = length(intersect(have, winning))
        if have_winning > 0
            for j in 1:have_winning
                won_cards[i + j] += won_cards[i]
            end
        end
        println("card $i wins $have_winning - now have $won_cards")

        i += 1
    end
    return sum(won_cards)
end

solve_file("inputs/day04-text.txt", true)

solve_file("inputs/day04-text.txt", false)

solve_file("inputs/day04.txt", false)

solve_file("inputs/day04.txt", true)
