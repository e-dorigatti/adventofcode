
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


function compute_hash(s)
    value = 0
    for c in s
        n = convert(Int8, c)
        value += n
        value *= 17
        value %= 256
    end
    return value
end

function solve_part1(input)
    steps = split(input, ',')
    return sum(compute_hash(s) for s in steps)
end


@assert 1320 == solve_file("2023/inputs/day15-test.txt", false)
@assert 506269 == solve_file("2023/inputs/day15.txt", false)


mutable struct LinkedListNode
    next::Union{Nothing, LinkedListNode}
    label::AbstractString
    focal::Int
end


function linked_list_append(head, label, focal)
    if isnothing(head)
        return LinkedListNode(nothing, label, focal)
    elseif head.label == label
        head.focal = focal
        return head
    else
        head.next = linked_list_append(head.next, label, focal)
        return head
    end
end


function linked_list_remove(head, label)
    if isnothing(head)
        # empty list
        return nothing
    elseif head.label == label
        return head.next
    else
        head.next = linked_list_remove(head.next, label)
        return head
    end
end


function linked_list_print(head)
    while !isnothing(head)
        print("[$(head.label) $(head.focal)] ")
        head = head.next
    end
    println("")
end


function solve_part2(input)
    boxes = Vector{Union{Nothing, LinkedListNode}}(nothing, 256)

    steps = split(input, ',')
    for st in steps
        hash = 0

        i = 1
        while i <= lastindex(st) && st[i] != '-' && st[i] != '='
            n = convert(Int8, st[i])
            if n != 10
                hash += n
                hash *= 17
                hash %= 256
            end
            i += 1
        end
        box_id = hash + 1  # stupid 1-based indexing

        label = st[1:i-1]
        if st[i] == '-'
            boxes[box_id] = linked_list_remove(boxes[box_id], label)
        elseif st[i] == '='
            focal = parse(Int, st[i+1:lastindex(st)])
            boxes[box_id] = linked_list_append(boxes[box_id], label, focal)
        else
            error("??")
        end

        #println("boxes after input $st")
        #for i in 1:lastindex(boxes)
        #    if !isnothing(boxes[i])
        #        print("Box $(i-1) ")
        #        linked_list_print(boxes[i])
        #    end
        #end
    end

    power = 0
    for i in 1:lastindex(boxes)
        j = 1
        cur = boxes[i]
        while !isnothing(cur)
            power += i * j * cur.focal
            cur = cur.next
            j += 1
        end
    end

    return power
end


@assert 145 == solve_file("2023/inputs/day15-test.txt", true)
@assert 264021 == solve_file("2023/inputs/day15.txt", true)
