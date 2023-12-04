import numpy as np

def task1(seats):
    occupancy = np.zeros_like(seats)
    visited = set()

    while tuple(occupancy.ravel()) not in visited:
        visited.add(tuple(occupancy.ravel()))
        adjacent = np.zeros_like(occupancy)

        adjacent[:-1, :] += occupancy[1:, :]
        adjacent[1:, :] += occupancy[:-1, :]
        adjacent[:, :-1] += occupancy[:, 1:]
        adjacent[:, 1:] += occupancy[:, :-1]

        adjacent[:-1, :-1] += occupancy[1:, 1:]
        adjacent[:-1, 1:] += occupancy[1:, :-1]
        adjacent[1:, :-1] += occupancy[:-1, 1:]
        adjacent[1:, 1:] += occupancy[:-1, :-1]

        adjacent *= seats

        new_occupancy = occupancy.copy()
        new_occupancy[(occupancy == 0) & (adjacent == 0)] = 1
        new_occupancy[(occupancy > 0) & (adjacent >= 4)] = 0
        new_occupancy *= seats
        occupancy = new_occupancy

    print(np.sum(occupancy))


def task2(seats):
    neighbors = {}

    for i in range(seats.shape[0]):
        for j in range(seats.shape[1]):
            if not seats[i, j]:
                continue

            neighbors[i, j] = []
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == dj == 0:
                        continue

                    pi, pj = i, j
                    while (
                            (0 <= pi < seats.shape[0]) and
                            (0 <= pj < seats.shape[1]) and
                            (((pi, pj) == (i, j)) or seats[pi, pj] == 0)):
                        pi += di
                        pj += dj

                    if  (0 <= pi < seats.shape[0]) and (0 <= pj < seats.shape[1]):
                        assert seats[pi, pj] == 1
                        neighbors[i, j].append((pi, pj))

    visited = set()
    occupancy = np.zeros_like(seats)
    while tuple(occupancy.ravel()) not in visited:
        visited.add(tuple(occupancy.ravel()))

        new_occupancy = np.zeros_like(seats)
        for (i, j), ns in neighbors.items():
            num_occupied = sum(occupancy[k, l] for k, l in ns)
            if not occupancy[i, j] and num_occupied == 0:
                new_occupancy[i, j] = 1
            elif occupancy[i, j] and num_occupied >= 5:
                new_occupancy[i, j] = 0
            else:
                new_occupancy[i, j] = occupancy[i, j]

        occupancy = new_occupancy

    print(occupancy.sum())


def main():
    with open('input.txt') as f:
        seats = np.array([
            [c == 'L' for c in row]
            for row in f
        ], dtype=np.int32)

    task1(seats)
    task2(seats)


if __name__ == '__main__':
    main()
