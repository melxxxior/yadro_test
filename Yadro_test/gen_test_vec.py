import random

random.seed(17)

def yadro_equation (a , b, c, d):
    return ((a-b) * (1 + 3 * c) - 4 * d) // 2


def log_calculation(a, b, c, d, Q, filename="test_vectors.txt"):
    with open(filename, "a", encoding="utf-8") as file:
        file.write(f"{a:12d} {b:12d} {c:12d} {d:12d} {Q:12d}\n")

def rand_tests(num_tests=10, width=32):
    min_val = -(1 << (width - 1))
    max_val = (1 << (width - 1)) - 1

    for i in range(num_tests):
        a = random.randint(min_val, max_val)
        b = random.randint(min_val, max_val)
        c = random.randint(min_val, max_val)
        d = random.randint(min_val, max_val)
        
        Q = yadro_equation(a, b, c, d)
        log_calculation(a, b, c, d, Q)  # Запись в файл

def hand_tests():
    a = 0
    b = 0
    c = 0
    d = 0
    Q = yadro_equation(a, b, c, d)
    log_calculation(a, b, c, d, Q)

    a = 1
    b = 2
    c = 3
    d = 4
    Q = yadro_equation(a, b, c, d)
    log_calculation(a, b, c, d, Q)

    a = 6
    b = 6
    c = -(1 << 31)
    d = 6
    Q = yadro_equation(a, b, c, d)
    log_calculation(a, b, c, d, Q)

    a = 1
    b = 0
    c = -(1 << 31)
    d = 6
    Q = yadro_equation(a, b, c, d)
    log_calculation(a, b, c, d, Q)


open("test_vectors.txt", "w").close() 

def run_all_tests():
    hand_tests()
    rand_tests(num_tests = 50, width = 8)
    rand_tests(num_tests = 50,width = 16)
    rand_tests(num_tests = 50,width = 32)
    

run_all_tests()