
def play(numbers, turns):
    last_turns = {n: [i] for i, n in enumerate(numbers)}
    last_spoken = numbers[-1]
    for t in range(len(numbers), turns):
        if len(last_turns[last_spoken]) == 1:
            spoken = 0
        else:
            spoken = last_turns[last_spoken][-1] - last_turns[last_spoken][-2]
        last_spoken = spoken

        if spoken in last_turns:
            last_turns[spoken] = [last_turns[spoken][-1], t]
        else:
            last_turns[spoken] = [t]
    return last_spoken


def main():
    with open('input.txt') as f:
        numbers = [int(x) for x in f.read().split(',')]

    print(play(numbers, 2020))
    print(play(numbers, 30000000))


if __name__ == '__main__':
    main()
