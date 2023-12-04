def toposort(nodes, children):
    def dfs(node):
        if node in visited:
            return
        for n in children.get(node, []):
            dfs(n)
        result.append(node)
        visited.add(node)

    result = []
    visited = set()
    for node in nodes:
        if node not in visited:
            dfs(node)

    return result


def main():
    # read graph
    bag_contained_in = {}
    bag_contains = {}
    bag_types = set()
    with open('input.txt') as f:
        for row in f:
            parts = row[:-2].replace(',', '').split()
            if len(parts) == 7:
                assert 'bags contain no other bags.' in row
            else:
                name = ' '.join(parts[:2])
                bag_types.add(name)
                if name not in bag_contains:
                    bag_contains[name] = {}

                for i in range(4, len(parts), 4):
                    n = ' '.join(parts[i+1:i+3])
                    c = int(parts[i])
                    bag_types.add(n)

                    if n not in bag_contained_in:
                        bag_contained_in[n] = {}

                    bag_contained_in[n][name] = c
                    bag_contains[name][n] = c

    # task 1: find all reachable nodes
    frontier = ['shiny gold']
    reachable = set()
    count = -1
    while frontier:
        node = frontier.pop()
        if node not in reachable:
            reachable.add(node)
            frontier.extend(bag_contained_in.get(node, []))
    print(len(reachable) - 1)

    # task 2: edge weight of all ancestors

    # part 1: topological ordering
    order = toposort(bag_types, bag_contains)

    # part 2: bag counting
    bag_content = {t: 0 for t in bag_types}
    for node in order:
        if node in bag_contained_in:
            for n, c in bag_contained_in[node].items():
                bag_content[n] += c * (bag_content[node] + 1)
    print(bag_content['shiny gold'])


if __name__ == '__main__':
    main()
