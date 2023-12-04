import click
import time
import os
import sys

from lispy.interpreter import IterativeInterpreter
from lispy.utils import eval_expr, load_stdlib, parse_expr


EXPECTED_OUTPUTS = {
    1: (703131, 272423970),
    2: (460, 251),
    3: (162, 3064612320),
    4: (190, 121),
    5: (822, 705),
    6: (6504, 3351),
    7: (115, 1250),
    8: (1217, 501),
    9: (14144619, 1766397),
    10: (2760, 13816758796288),
    12: (1152, 58637),
    13: (2947, 526090562196173),
    14: (17765746710228, 4401465949086),
}


class CaptureStdOut:
    def __init__(self):
        self.messages = []

    def __enter__(self):
        self._stdout = sys.stdout
        sys.stdout = self
        return self

    def __exit__(self, type, value, traceback):
        sys.stdout = self._stdout

    def write(self, msg):
        self.messages.append(msg)

    def flush(self, *args, **kwargs):
        pass


SUCCESS = 0
ERR_NOT_EXISTING = -1
ERR_RUNTIME = -2
ERR_WRONG = -3

def run_test(day):
    if day not in EXPECTED_OUTPUTS:
        return ERR_NOT_EXISTING, -1

    # check problem was done
    path = f'day{day}'
    code_path = os.path.join(path, 'solve.lpy')
    if not os.path.exists(path) or not os.path.exists(code_path):
        return ERR_NOT_EXISTING, -1

    # read code
    old_dir = os.getcwd()
    os.chdir(path)
    with open('solve.lpy') as f:
        code = f.read() #.replace('input.txt', 'small.txt')

    # execute program
    with CaptureStdOut() as sout:
        inpr = load_stdlib(IterativeInterpreter())
        try:
            tstart = time.time()
            eval_expr(code, inpr)
            duration = time.time() - tstart
        except:
            return ERR_RUNTIME, duration
        finally:
            os.chdir(old_dir)

    # check that output is as expected
    out_lines = ''.join(sout.messages).split('\n')
    if len(out_lines) == 3 and out_lines[-1] == '':
        p1, p2 = int(out_lines[0]), int(out_lines[1])
        if EXPECTED_OUTPUTS[day] == (p1, p2):
            return SUCCESS, duration
    return ERR_WRONG, duration


@click.command()
def main():
    codes = {
        SUCCESS: 'Correct',
        ERR_NOT_EXISTING: 'Not found',
        ERR_RUNTIME: 'Runtime error',
        ERR_WRONG: 'Wrong output',
    }
    for i in range(1, 26):
        result, duration = run_test(i)
        duration_str = f'(Took {duration:.3f} s)' if duration > 0 else ''
        print(f'Day {i} - {codes[result]}', duration_str)
    print()


if __name__ == '__main__':
    main()
