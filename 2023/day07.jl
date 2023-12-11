
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


@enum HandValue HighCard=1 OnePair=2 TwoPairs=3 ThreeKind=4 FullHouse=5 FourKind=6 FiveKind=7

struct Hand
    cards::Vector{Int8}
    hand_type::HandValue
    bet::Int
end


function card_less_than(h1::Hand, h2::Hand)
    if h2.hand_type > h1.hand_type
        return true
    elseif h1.hand_type > h2.hand_type
        return false
    else
        for (c, d) in zip(h1.cards, h2.cards)
            if d < c
                return true
            elseif c < d
                return false
            end
        end
        return false
    end
end


function get_hand_value(card_counts::Vector{Int8})::HandValue
    mx = maximum(card_counts)
    hand_type = 0
    if mx == 1
        # high card
        hand_type = HighCard
    elseif mx == 2
        num_pairs = sum(x == 2 for x in card_counts)
        if num_pairs == 1
            # one pair
            hand_type = OnePair
        else
            # two pairs
            hand_type = TwoPairs
        end
    elseif mx == 3
        if any(x == 2 for x in card_counts)
            # full house
            hand_type = FullHouse
        else
            # three of a kind
            hand_type = ThreeKind
        end
    elseif mx == 4
        # four of a kind
        hand_type = FourKind
    else
        # five of a kind
        hand_type = FiveKind
    end
    return hand_type
end


function solve_part1(input::AbstractString)
    lines = split(input, '\n')
    
    card_values = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
    hands = Vector{Hand}(undef, length(lines))

    for (i, row) in enumerate(lines)
        cards, bet = split(row)

        vals = indexin(cards, card_values)
        card_counts = zeros(Int8, length(card_values))
        for i in vals
            card_counts[i] = card_counts[i] + 1
        end

        hand_type = get_hand_value(card_counts)

        hands[i] = Hand(vals, hand_type, parse(Int, bet))
        println("hand $i has type $hand_type")
    end

    sort!(hands, lt=card_less_than)
    result = 0
    for (i, c) in enumerate(hands)
        println("rank $i bet $(c.bet)")
        result += i * c.bet
    end
    return result
end


@assert 6440 == solve_file("2023/inputs/day07-test.txt", false)
@assert 253866470 == solve_file("2023/inputs/day07.txt", false)


function get_hand_value_part2(card_counts::Vector{Int8}, j_count::Int)::HandValue
    mx = maximum(card_counts)  # this does not cont Js
    hand_type = 0

    if mx == 0
        # all jokers
        hand_type = FiveKind
    elseif mx == 1
        if j_count == 0
            hand_type = HighCard
        elseif j_count == 1
            # have one joker, convert hand to one pair
            hand_type = OnePair
        elseif j_count == 2
            # convert two jokers to get a trio
            hand_type = ThreeKind
        elseif j_count == 3
            # convert three jokers to get four
            hand_type = FourKind
        elseif j_count == 4
            hand_type = FiveKind
        else
            error("unexpected number of jokers")
        end
    elseif mx == 2
        num_pairs = sum(x == 2 for x in card_counts)
        if num_pairs == 1
            if j_count == 0
                # one pair
                hand_type = OnePair
            elseif j_count == 1
                # join joker with pair
                hand_type = ThreeKind
            elseif j_count == 2
                # convert two jokers to the other two cards
                hand_type = FourKind
            elseif j_count == 3
                hand_type = FiveKind
            else
                error("unexpected number of jokers")
            end
        else
            if j_count == 0
                # two pairs
                hand_type = TwoPairs
            elseif j_count == 1
                # convert joker to one of the pairs and get full house
                hand_type = FullHouse
            else
                error("unexpected number of jokers")
            end
        end
    elseif mx == 3
        if any(x == 2 for x in card_counts)
            # full house
            hand_type = FullHouse
            # MethodError: Cannot `convert` an object of type Nothing to an object of type HandValue
            # in this assert ?!
            #  @assert j_count == 0
        else
            if j_count == 0
                hand_type = ThreeKind
            elseif j_count == 1
                # convert joker to join the trio
                hand_type = FourKind
            elseif j_count == 2
                # convert both jokers to the trio
                hand_type = FiveKind
            else
                error("unexpected number of jokers")
            end
        end
    elseif mx == 4
        if j_count == 0
            # four of a kind
            hand_type = FourKind
        elseif j_count == 1
            # convert joker to the four 
            hand_type = FiveKind
        else
            error("unexpected number of jokers")
        end
    elseif mx == 5
        # five of a kind
        hand_type = FiveKind
    end
end


function solve_part2(input::AbstractString)
    lines = split(input, '\n')
    
    card_values = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']
    hands = Vector{Hand}(undef, length(lines))

    for (i, row) in enumerate(lines)
        cards, bet = split(row)

        vals = indexin(cards, card_values)
        card_counts = zeros(Int8, length(card_values))
        j_count = 0
        for i in vals
            if i != lastindex(card_counts)
                card_counts[i] = card_counts[i] + 1
            else
                j_count += 1
            end
        end

        hand_type = get_hand_value_part2(card_counts, j_count)

        @assert hand_type != 0
        card_counts[lastindex(card_counts)] = j_count
        hands[i] = Hand(vals, hand_type, parse(Int, bet))
        println("hand $i $cards has type $hand_type")
    end

    sort!(hands, lt=card_less_than)
    
    result = 0
    for (i, c) in enumerate(hands)
        println("rank $i bet $(c.bet)")
        result += i * c.bet
    end
    return result
end

@assert 5905 == solve_file("2023/inputs/day07-test.txt", true)
@assert 254494947 == solve_file("2023/inputs/day07.txt", true)
