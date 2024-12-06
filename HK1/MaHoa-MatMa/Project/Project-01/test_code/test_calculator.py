import os 
from random import randint
from sympy import *
import time 

path = "H:\\Nam3\\HK1\\MaHoa-MatMa\\Project\\Project-01\\x64\\Debug\\calculator.exe"
file_input = "test4.inp"
file_output = "test4.out"

for id_test in range(10000):

    x = randint(0, 2**1024)
    y = randint(0, 2**1024)

    with open(file_input, "w") as file:
        file.write(str(hex(x).upper()[2:]) + " " + str(hex(y).upper()[2:]))

    s = time.time()
    os.system(f"{path} < {file_input} > {file_output}")
    print("Running in: ", time.time() - s)

    my_ans = open(file_output, "r").read().split()
    add = int(my_ans[0], 16)
    sub = int(my_ans[1], 16)
    mod = int(my_ans[2], 16)
    print("Your answers: ", [add, sub, mod])
    print("Excepted answers: ", [x + y, x - y, x % y])
    if [add, sub, mod] != [x + y, x - y, x % y]:
        print(id_test, "FALSE")
        exit(0)
    else:
        print(id_test, "TRUE")


