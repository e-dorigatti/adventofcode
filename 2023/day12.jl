
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
        parts = split(row)
        conditions = parts[1] #split(parts[1], '.', keepempty=false)
        groups = [parse(Int, x) for x in split(parts[2], ',')]
        result += solve_row(conditions, groups)
    end
    return result
end


function solve_part2(input)
    lines = split(input, '\n')
    result = 0
    for row in lines
        parts = split(row)
        conditions = join([parts[1] for x in 1:5], "?")
        groups = repeat([parse(Int, x) for x in split(parts[2], ',')], 5)
        result += solve_row(conditions, groups)
    end
    return result
end


function solve_row(conds, groups)
    conditions = [c for c in conds]

    cache = Dict()
    function aux(i, j)
        if i > lastindex(conditions)
            # success iff we used up all groups
            res = j > lastindex(groups) ? 1 : 0
            if res > 0
                #println("solution found - ", join(solution))
            else
                #println("INVALID - ", join(solution))
            end
            return res
        end

        key = (i, j)
        if key ∈ keys(cache)
            return cache[key]
        end
        
        res = 0

        if conditions[i] == '?' || conditions[i] == '.'
            # try to put a good spring here
            res += aux(i + 1, j)
        end

        if (conditions[i] == '?' || conditions[i] == '#') && j <= lastindex(groups)
            # try to put a broken spring here
            # in particular, try to put the entire groups[j] amount of broken gears

            k = i  # find end of broken/uncertain gears
            while k <= lastindex(conds) && conds[k] != '.'
                k += 1
            end

            if k - i >= groups[j]  # we have enough ? or # to entirely place this group
                if i + groups[j] > lastindex(conditions) || conditions[i + groups[j]] != '#'
                    # there is (or we can place) a good gear after this group, do it and jumpt after that
                    res += aux(i + groups[j] + 1, j + 1)
                else
                    # still a broken gear after this group, arrangement not possible
                end
            end
        end

        cache[key] = res
        return res
    end

    return aux(1, 1)
end

@assert 12 == solve_row("??#???#?????.?", [5, 1, 1])
@assert 0 == solve_row("?#?.?", [1, 1, 1])
@assert 10 == solve_row("?###????????", [3, 2, 1])
@assert 4 == solve_row("??.??.?##", [1, 1, 3])
@assert 1 == solve_row("???.###", [1,1,3])
@assert 2 == solve_row("?.?", [1])
@assert 1 == solve_row("???", [1, 1])
@assert 1 == solve_row("???.###", [1, 1, 3])
@assert 4 == solve_row("??.??", [1, 1])
@assert 1 == solve_row("????.#...#...", [4, 1, 1])
@assert 4 == solve_row("????.######..#####.", [1, 6, 5])
@assert 1 == solve_row("##??", [2, 1])


@assert 21 == solve_file("2023/inputs/day12-test.txt", false)
@assert 7286 == solve_file("2023/inputs/day12.txt", false)

@assert 525152 == solve_file("2023/inputs/day12-test.txt", true)
@assert 25470469710341 == solve_file("2023/inputs/day12.txt", true)


#########################################################
###  A GRAVEYARD OF IDEAS FOLLOWS FOR YOUR ENJOYMENT  ###
#########################################################


@run solve_row("?#?.?", [1, 1, 1])

@run solve_row("?#?", [1, 1])

@assert 0 == solve_row("?#?.?", [1, 1, 1])
@assert 10 == solve_row("?###????????", [3, 2, 1])
@assert 4 == solve_row("??.??.?##", [1, 1, 3])
@assert 1 == solve_row("???.###", [1,1,3])
@assert 2 == solve_row("?.?", [1])
@assert 1 == solve_row("???", [1, 1])
@assert 1 == solve_row("???.###", [1, 1, 3])
@assert 4 == solve_row("??.??", [1, 1])
@assert 1 == solve_row("????.#...#...", [4, 1, 1])
@assert 4 == solve_row("????.######..#####.", [1, 6, 5])

@assert 1 == solve_row("##??", [2, 1])

solve_row("##??", [3, 1])


function solve_row(conds, groups)
    conditions = [c for c in conds]

    function is_valid()
        gg = split(join(conditions), '.', keepempty=false)
        return groups == [length(x) for x in gg]
    end

    cache = Dict()
    function aux(i)
        #if i ∈ keys(cache)
        #    return cache[i]
        #end

        if i > lastindex(conditions)
            res = is_valid() ? 1 : 0
        elseif conditions[i] == '?'
            conditions[i] = '.'
            res = aux(i + 1)
            conditions[i] = '#'
            res += aux(i + 1)
            conditions[i] = '?'
        else
            res = aux(i + 1)
        end

        cache[i] = res
        return res
    end

    return aux(1)
end


@assert 0 == solve_row("?#?.?", [1, 1, 1])

solve_row("?###????????", [3, 2, 1])

@assert 4 == solve_row("??.??.?##", [1, 1, 3])
@assert 1 == solve_row("???.###", [1,1,3])
@assert 2 == solve_row("?.?", [1])
@assert 1 == solve_row("???", [1, 1])
@assert 1 == solve_row("???.###", [1, 1, 3])
@assert 4 == solve_row("??.??", [1, 1])
@assert 1 == solve_row("????.#...#...", [4, 1, 1])
@assert 4 == solve_row("????.######..#####.", [1, 6, 5])




function solve_row(conds, broken_counts)
    # split conditions into groups of # or ?
    groups = []
    cur = []
    for c in conds
        if isempty(cur) || cur[1] == c
            push!(cur, c)
        else
            push!(groups, cur)
            cur = [c]
        end
    end
    if !isempty(cur)
        push!(groups, cur)
    end
    println(groups)

    function solve(grp, cnt)
        if isempty(grp)
            return isempty(cnt) ? 1 : 0
        end

        if grp[1][1] == '.'
            return solve(grp[2:lastindex(grp)], cnt)
        elseif grp[1][1] == '#'
            if isempty(cnt) || cnt[1] < length(grp[1])
                # impossible = this group is larger than the remaining size
                return 0
            end
            # to have a group of size cnt[1], the next group must start with
            # a certain number of broken gears
            if length(grp[1]) == cnt[1]
                new_cnt = cnt[2:lastindex(cnt)]
            else
                new_cnt = cnt[:]
                new_cnt[1] -= length(grp[1])  # broken gears at the start of next group
            end
            if length(grp) == 1 || grp[2][1] != '?'
                # no next group or next group is fixed gears,
                # recur to check that we did all counts
                return solve(grp[2:length(grp)], new_cnt)
            else
                new_grp = grp[2:length(grp)]
                if length(new_grp[1]) >= length(grp[1])
                    new_grp[1] = new_grp[1][length(grp[1]):lastindex(new_grp[1])]
                end
                return solve(new_grp, new_cnt)
            end
        elseif grp[1][1] == '?'
            if isempty(cnt)
                # no more groups to be formed, this group must be good
                # must check that later groups are not broken
                return solve(grp[2:lastindex(grp)], cnt)
            end
            # first choice: all gears are fine
            result = solve(grp[2:lastindex(grp)], cnt)

            next_broken = (length(grp) > 1 && grp[2][1] == '#') ? length(grp[2]) : 0
            for g in 1:length(cnt)
                # try forming g groups with given sizes
                nar = count_arrangements(length(grp[1]), cnt[1:g], next_broken)
                if nar > 0
                    # if possible, for each of these arrangements count the remaining possibilities
                    if next_broken > 0
                        # all these groups already include the broken gears in the next group
                        # therefore we should skip it directly
                        result += nar * solve(grp[3:lastindex(grp)], cnt[(g+1):lastindex(cnt)])
                    else
                        result += nar * solve(grp[2:lastindex(grp)], cnt[(g+1):lastindex(cnt)])
                    end
                end
            end
            return result
        end
        error("error")
    end

    return solve(groups, broken_counts)
end


function count_arrangements(size, group_sizes, broken_following)
    # count how many possible arrangements of . and # can be done
    # in a string of length `size`, while creating groups of # that
    # are separated by at least one . and have exactly the given sizes
    # also considering that after this group there will be a given
    # number of broken gears immediately following
    # (the number of broken gears counts for the last group)
    println("count $size $group_sizes")

    if size == 0
        return length(group_sizes) == 0 ? 1 : 0
    elseif length(group_sizes) == 0
        return 1
    end 

    n = group_sizes[1]
    result = 0
    last_index = broken_following == 0 ? (size - n + 1) : (size - n)
    for i in 1:last_index
        # put a group of size n starting at i
        # recursion to check remaining groups on remaining space
        result += count_arrangements(
            size - n - i,
            group_sizes[2:lastindex(group_sizes)],
            broken_following
        )
    end

    # now we have checked all possible starting positions for the first group
    # except the last one where the group would merge with the following broken
    if broken_following > 0
        if length(group_sizes) == 1 && size + broken_following == group_sizes[1]
            # by merging the next group and this one we can exactly get the
            # desired size
            result += 1
        else
            # since the remaining position is adjacent to the following group
            # of broken gears, only one group can be formed
        end
    end

    return result
end


@assert 0 == count_arrangements(3, [3], 1)
@assert 1 == count_arrangements(2, [3], 1)
@assert 4 == count_arrangements(4, [2, 1], 0)
@assert 4 == count_arrangements(4, [1, 1], 0)
@assert 3 == count_arrangements(3, [1], 0)
@assert 1 == count_arrangements(3, [1, 1], 0)

function solve_row(conds, groups)
    conditions = [c for c in conds]

    cache = Dict()

    function aux(i, g, in_group, cur_groups)
        if i > lastindex(conditions) + 1
            r = all(g == 0 for g in cur_groups)
            #println("end", conditions, cur_groups, r)
            return r
        end

        restore = -1
        if i > 1
            if conditions[i - 1] == '#'
                if !in_group
                    in_group = true
                    g += 1
                    if g > lastindex(cur_groups)
                        #println("invalid detected $conditions until $i")
                        return 0
                    end
                end

                if cur_groups[g] == 0
                    #println("invalid detected $conditions until $i")
                    return 0
                end
                cur_groups[g] -= 1
                restore = g
            elseif conditions[i - 1] == '.'
                if in_group && cur_groups[g] > 0
                    #println("invalid detected $conditions until $i")
                    return 0
                else
                    in_group = false
                end
            else
                error("should not be here")
            end
        end

        if i <= lastindex(conditions)
            if conditions[i] == '?'
                conditions[i] = '.'
                res = aux(i + 1, g, in_group, cur_groups)
                conditions[i] = '#'
                res += aux(i + 1, g, in_group, cur_groups)
                conditions[i] = '?'
            else
                res = aux(i + 1, g, in_group, cur_groups)
            end
        else
            res = aux(i + 1, g, in_group, cur_groups)
        end
        if restore > 0
            cur_groups[restore] += 1
        end
        return res
    end

    return aux(1, 0, false, [x for x in groups])
end

 solve_row("?###????????", [3, 2, 1])

@assert 4 == solve_row("??.??.?##", [1, 1, 3])
@assert 1 == solve_row("???.###", [1,1,3])
@assert 2 == solve_row("?.?", [1])
@assert 1 == solve_row("???", [1, 1])
@assert 1 == solve_row("???.###", [1, 1, 3])
@assert 4 == solve_row("??.??", [1, 1])
@assert 1 == solve_row("????.#...#...", [4, 1, 1])
@assert 4 == solve_row("????.######..#####.", [1, 6, 5])

@assert 1 == solve_row("##??", [2, 1])



function solve_row(conds, groups)
    conditions = [c for c in conds]

    function aux(i, g, in_group, cur_groups)
        if i > lastindex(conditions)
            s = all(g == 0 for g in cur_groups)
            gr = split(join(conditions), '.', keepempty=false)
            t = [length(x) for x in gr] == groups
            @assert s == t
            return t ? 1 : 0
        end

        if conditions[i] == '#'
            if !in_group
                in_group = true
                g += 1
                if g > lastindex(cur_groups) && i < lastindex(conds)
                    # ran out of groups
                    #println("invalid detected $conditions until $i")
                    return 0
                end
            end

            if cur_groups[g] == 0
                # more broken gears than in group
                #println("invalid detected $conditions until $i")
                return 0
            end
            cur_groups[g] -= 1
            res = aux(i + 1, g, in_group, cur_groups)
            cur_groups[g] += 1
        elseif conditions[i] == '.'
            if in_group && cur_groups[g] > 0
                # group of broken gears too small
                #println("invalid detected $conditions until $i")
                return 0
            else
                in_group = false
            end
            res = aux(i + 1, g, in_group, cur_groups)
        elseif conditions[i] == '?'
            # try with a good gear
            conditions[i] = '.'
            newgroup = in_group
            if in_group && cur_groups[g] > 0
                # group of broken gears too small
                #println("invalid detected $conditions until $i")
                return 0
            else
                newgroup = false
            end
            res = aux(i + 1, g, newgroup, cur_groups)

            # try with a broken gear
            conditions[i] = '#'
            possible = true

            # must update group counts
            if !in_group
                in_group = true
                g += 1
                if g > lastindex(cur_groups) && i < lastindex(conds)
                    # ran out of groups
                    #println("invalid detected $conditions until $i")
                    possible = false
                end
            end

            if cur_groups[g] == 0
                # more broken gears than in group
                #println("invalid detected $conditions until $i")
                possible = false
            end
            if possible
                cur_groups[g] -= 1
                res = aux(i + 1, g, in_group, cur_groups)
                cur_groups[g] += 1
            end
            conditions[i] = '?'
        end
        return res
    end

    res = aux(1, 0, false, [x for x in groups])
    println("$conds - $res")
    return res
end


function solve_row(conds, groups)
    conditions = [c for c in conds]

    function aux(i)
        cur_groups = [x for x in groups]
        g = 0
        in_group = false
        for j in 1:(i - 1)
            if conditions[j] == '#'
                if !in_group
                    in_group = true
                    g += 1
                    if g > lastindex(cur_groups)
                        #println("invalid detected $conditions until $i")
                        return 0
                    end
                end

                cur_groups[g] -= 1
                if cur_groups[g] < 0
                    #println("invalid detected $conditions until $i")
                    return 0
                end
            elseif conditions[j] == '.'
                if in_group && cur_groups[g] > 0
                    #println("invalid detected $conditions until $i")
                    return 0
                else
                    in_group = false
                end
            else
                error("should not be here")
            end
        end

        if i > lastindex(conditions)
            return all(g == 0 for g in cur_groups)
        end

        if conditions[i] == '?'
            conditions[i] = '.'
            res = aux(i + 1)
            conditions[i] = '#'
            res += aux(i + 1)
            conditions[i] = '?'
            return res
        else
            return aux(i + 1)
        end
    end

    return aux(1)
end

@assert 1 == solve_row("???.###", [1,1,3])
@assert 10 == solve_row("?###????????", [3, 2, 1])
@assert 0 == solve_row("?#?.?", [1, 1, 1])
@assert 2 == solve_row("?.?", [1])
@assert 1 == solve_row("???", [1, 1])
@assert 1 == solve_row("???.###", [1, 1, 3])
@assert 4 == solve_row("??.??", [1, 1])
@assert 4 == solve_row("??.??.?##", [1, 1, 3])
@assert 1 == solve_row("????.#...#...", [4, 1, 1])
@assert 4 == solve_row("????.######..#####.", [1, 6, 5])


function solve_row_slow(conds, groups)
    conditions = [c for c in conds]

    function is_valid()
        gg = split(join(conditions), '.', keepempty=false)
        return groups == [length(x) for x in gg]
    end

    function aux(i)
        if i > lastindex(conditions)
            return is_valid() ? 1 : 0
        elseif conditions[i] == '?'
            conditions[i] = '.'
            res = aux(i + 1)
            conditions[i] = '#'
            res += aux(i + 1)
            conditions[i] = '?'
            return res
        else
            return aux(i + 1)
        end
    end

    return aux(1)
end



function solve_row_oldest(conditions, groups)

    function aux(i, j, indent_level, status)
        indent = repeat("  ", indent_level)
        println("$indent aux $i $j $groups")

        if i > lastindex(conditions)
            if all(x == 0 for x in groups)
                println("$indent success $(join(status))")
                return 1
            else
                println("$indent fail $(join(status))")
                return 0
            end
        elseif conditions[i] == '.'
            return aux(i + 1, j, indent_level + 1, [status, '.'])
        elseif conditions[i] == '#'
            # broken spring, reduce amount in current group and move on
            if j > lastindex(groups)
                # out of groups, used too many springs earlier
                res = 0
            else
                groups[j] -= 1
                if groups[j] == 0
                    # counting this broken spring, this group is empty
                    if i < lastindex(conditions)
                        if conditions[i + 1] == '?'
                            # next spring must be working and we skip it
                            res = aux(i + 2, j + 1, indent_level + 1, [status; '#'; '.'])
                        elseif conditions[i + 1] == '#'
                            # next spring is broken, impossible to have empty group
                            res = 0
                        elseif conditions[i + 1] == '.'
                            # next spring is fine, skip
                            res = aux(i + 2, j + 1, indent_level + 1, [status; '#'; '.'])
                        end
                    else
                        # this was the very last spring, recur and check base case
                        res = aux(i + 1, j + 1, indent_level + 1, [status; '#'])
                    end
                else
                    res = aux(i + 1, j, indent_level + 1, [status; '#'])
                end
                groups[j] += 1
            end
        elseif conditions[i] == '?'
            res = 0

            if j <= lastindex(groups)
                # try putting a broken spring here
                println("$indent try broken at $i")
                groups[j] -= 1
                if groups[j] == 0
                    if i < lastindex(conditions)
                        if conditions[i + 1] == '#'
                            # impossible: this group is empty but immediately following
                            # there is a broken spring
                        elseif conditions[i + 1] == '?'
                            # next position is unknown but this group is finished
                            # meaning that there must be a working spring here
                            res += aux(i + 2, j + 1, indent_level + 1, [status; '#'; '.'])
                        elseif conditions[i + 1] == '.'
                            # next up is a working spring, this is okay and we can skip that
                            res += aux(i + 2, j + 1, indent_level + 1, [status; '#'; '.'])
                        end
                    else
                        # very last position, recurse and check if all groups are assigned
                        res += aux(i + 1, j, indent_level + 1, [status; '#'])
                    end
                else
                    res += aux(i + 1, j, indent_level + 1, [status; '#'])
                end
                groups[j] += 1
            end

            # try putting an operational spring here
            println("$indent try operational at $i")
            res += aux(i + 1, j, indent_level + 1, [status; '.'])
        end

        return res
    end

    return aux(1, 1, 0, [])
end

solve_row("?###????????", [3, 2, 1])


@assert 0 == solve_row("?#?.?", [1, 1, 1])

@assert 2 == solve_row("?.?", [1])

@assert 1 == solve_row("???", [1, 1])

@assert 1 == solve_row("???.###", [1, 1, 3])

@assert 4 == solve_row("??.??", [1, 1])

@assert 4 == solve_row("??.??.?##", [1, 1, 3])

@assert 1 == solve_row("????.#...#...", [4, 1, 1])

@assert 4 == solve_row("????.######..#####.", [1, 6, 5])
