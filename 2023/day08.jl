
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


function parse_input_file(input)
    lines = split(input, '\n')

    j = 3
    nodes = Dict{AbstractString, Tuple{AbstractString, AbstractString}}()
    while j <= length(lines)
        from, to = split(lines[j], " = ")
        to_left, to_right = split(to, ", ")
        nodes[from] = (to_left[2:lastindex(to_left)], to_right[1:lastindex(to_right) - 1])
        j += 1
    end
    instructions = lines[1]

    return instructions, nodes
end


function solve_part1(input::AbstractString)
    instructions, nodes = parse_input_file(input)

    cur = "AAA"
    inst = 1
    steps = 0
    while cur != "ZZZ"
        steps += 1

        if instructions[inst] == 'L'
            next = nodes[cur][1]
        else
            next = nodes[cur][2]
        end

        #println("step $steps moving from $cur to $next in instruction $inst")
        cur = next

        inst += 1
        if inst > length(instructions)
            inst = 1
        end
    end
    return steps
end


#@assert 2 == solve_file("2023/inputs/day08-test-1.txt", false)
#@assert 6 == solve_file("2023/inputs/day08-test-2.txt", false)
#@assert 20777 == solve_file("2023/inputs/day08.txt", false)


struct Loop
    start::Int
    length::Int
    exit::Int
end


function detect_loops(nodes, instructions, start)
    cur = start
    steps = 0
    j = 1
    exits = Vector{Int}()
    seen = Dict([(start, j) => steps])
    while true
        #println("$steps @ ($cur, $j)")

        steps += 1
        if instructions[j] == 'L'
            cur = nodes[cur][1]
        else
            cur = nodes[cur][2]
        end
        j += 1
        if j > length(instructions)
            j = 1
        end
        if endswith(cur, 'Z')
            push!(exits, steps)
            println("found exit $cur at step $steps")
        end
        if (cur, j) in keys(seen)
            println("loop detected for cursor $start starting at ($cur, $j) on step $(seen[(cur, j)]) and closing first at step $steps steps - exits at steps $exits")
            break
        end
        seen[(cur, j)] = steps

    end

    @assert length(exits) == 1  # does not work with test case but works with actual example

    loop_start = seen[(cur, j)]
    loop_length = steps - loop_start
    loop_exit = exits[1] - loop_start
    println("loop start @ $loop_start length $loop_length exits at $loop_exit")
    return Loop(loop_start, loop_length, loop_exit)
end


function mod_inverse(a::BigInt, n::BigInt)
    # finds the inverse of a mod n
    # e.g. the inverse of 4 mod 9 is 7, since 7*4 mod 9 = 1

    function aux(r, newr, t, newt) 
        if newr == 0
            return (r, t)
        else
            quot = div(r, newr)
            return aux(
                newr, r - quot * newr,
                newt, t - quot * newt
            )
        end
    end

    r, t = aux(n, a % n, 0, 1)
    if r > 1
        res = -1
    elseif t < 0
        res = t + n
    else
        res = t
    end

    @assert (res * a) % n == 1
    return res
end

@assert 7 == mod_inverse(4, 9)

function chinese_remainder(as::Vector{BigInt}, ns::Vector{BigInt})
    # find the number x so that x = as[i] mod ns[i] for all i)

    big_n::BigInt = reduce(*, ns)
    ys = [div(big_n, n) for n in ns]
    zs = [mod_inverse(y, n) for (y, n) in zip(ys, ns)]

    num = sum(a * y * z for (a, y, z) in zip(as, ys, zs))
    return num % big_n
end

@assert 7 == chinese_remainder([1, 2], [2, 5])
@assert 34 == chinese_remainder([1, 4, 6], [3, 5, 7])

function greatest_common_divisor(a, b)
    while b != 0
        t = b
        b = a % b
        a = t
    end
    return a
end

@assert 4 == greatest_common_divisor(12, 16)

function greatest_common_divisor(xs)
    res = xs[1]
    for i in 2:lastindex(xs)
        res = greatest_common_divisor(res, xs[i])
    end
    return res
end

@assert 4 == greatest_common_divisor([12, 16, 24])

function least_common_multiple(a, b)
    return div(abs(a * b), greatest_common_divisor(a, b))
end

@assert 12 == least_common_multiple(4, 6)

function least_common_multiple(xs)
    res = xs[1]
    for i in 2:lastindex(xs)
        res = least_common_multiple(res, xs[i])
    end
    return res
end

@assert 42 == least_common_multiple([6,7,21])


function solve_part2(input::AbstractString)
    instructions, nodes = parse_input_file(input)

    cursors = []
    for n in keys(nodes)
        if endswith(n, 'A')
            push!(cursors, n)
        end
    end

    loops = []
    for start in cursors
        lo = detect_loops(nodes, instructions, start)
        push!(loops, lo)

        # following solution only works with this condition
        # which is rather peculiar
        @assert lo.start + lo.exit == lo.length
    end

    return least_common_multiple([lo.length for lo in loops])

    # in case the assert fail one can try with the Chinese remainder theorem
end

#solve_file("2023/inputs/day08-test-3.txt", true)
@assert 13289612809129 == solve_file("2023/inputs/day08.txt", true)

