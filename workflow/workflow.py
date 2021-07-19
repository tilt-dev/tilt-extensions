import subprocess

cmds = [
        ['echo', 'hi'],
        ['echo', 'second step']
        ['echo', 'third step']
        ['echo', 'fourth step']
        ['echo', 'bye']
    ]

clear_cmd = ['echo', 'resetting...']

index = 0

def next_index():
    next_i = index + 1
    return next_i % len(cmds)

def prev_index():
    prev_i = index - 1
    return prev_i % len(cmds)

def reset_index():
    index = 0

def is_last_step(i):
    return i == len(cmds)-1

def run_current():
    subprocess.run(cmds[i])

def run_next():
    if is_last_step(index):
        start_over()
        print('workflow finished, starting over')
    else:
        index = next_index()
        run_current()

def rerun():
    run_current()

def start_over():
    subprocess.run(clear_cmd)
    reset_index()
    pass

