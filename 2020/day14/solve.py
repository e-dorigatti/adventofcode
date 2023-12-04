
def mask_address(mask, address):
    addr_bin = tuple(format(address, '036b'))
    return tuple([
        a if m == '0' else '1' if m == '1' else  'X'
        for m, a in zip(mask, addr_bin)
    ])


def count_overlaps(addr1, addr2):
    acc = 1
    for a, b in zip(addr1, addr2):
        if a == b == 'X':
            acc *= 2
        elif a != 'X' and b != 'X' and a != b:
            return 0
    return acc


def main_fast(fname):
    with open(fname) as f:
        mask = ('0',) * 36
        writes = []
        for row in f:
            if row.startswith('mask'):
                mask = tuple(row.split()[-1])
            else:
                parts = row.split()
                address = int(parts[0][4:-1])
                value = int(parts[-1])
                writes.append((mask_address(mask, address), value))

    total = 0
    for i, (a, v) in enumerate(writes):
        count = 2**sum(1 for b in a if b == 'X')
        for j in range(i + 1, len(writes)):
            count -= count_overlaps(a, writes[j][0])

        if count > 0:
            total += v * count

    print(total)


def main_slow(fname):
    memory = {}
    def write_to_memory(masked_address, value, i=0):
        if i < len(masked_address):
            if masked_address[i] == 0:
                pass

    with open(fname) as f:
        mask = ('0',) * 36
        writes = []
        for row in f:
            if row.startswith('mask'):
                mask = tuple(row.split()[-1])
            else:
                parts = row.split()
                address = int(parts[0][4:-1])
                value = int(parts[-1])
                write_to_memory(mask_address(mask, address), value)


if __name__ == '__main__':
    main_fast()
