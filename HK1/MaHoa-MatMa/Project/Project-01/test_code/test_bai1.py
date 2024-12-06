import os 
from random import randint
from sympy import *
import time 

path = "H:\\Nam3\\HK1\\MaHoa-MatMa\\Project\\Project-01\\22127233-Project1\\bai1.exe"
file_input = "test1.inp"
file_output = "test1.out"

def test_case1():
    m = randint(2, 2**1024)
    return m

def test_case2():
    m = randint(2**1023, 2**1024)
    m = nextprime(m)

    return m

number1 = [2047, 1373653, 25326001, 3215031751, 2152302898747, 3474749660383, 341550071728321, 341550071728321, 3825123056546413051, 3825123056546413051, 3825123056546413051, 318665857834031151167461, 3317044064679887385961981]
number2 = [9,2047,1373653,25326001,3215031751,2152302898747, 3474749660383,341550071728321,341550071728321, 3825123056546413051,3825123056546413051, 3825123056546413051,318665857834031151167461, 3317044064679887385961981]
cnt = 0
for id_test in range(10000):

    m = test_case1() if (randint(0, 1) == 1) else test_case2()
    # m = test_case2()
    # if cnt == len(number2): break 
    # m = number2[cnt]
    # cnt += 1

    if (m >= 2**1024): print("Lon hon nhe!\n")
    with open(file_input, "w") as file:
        file.write(str(hex(m).upper()[2:]))

    s = time.time()
    os.system(f"g++ ../22127233-project1/bai1.cpp -o ../22127233-project1/bai1.exe")
    os.system(f"{path} {file_input} {file_output}")
    print("Running in: ", time.time() - s)
    if (time.time() - s >= 60):
        print(m)

    my_ans = open(file_output, "r").read().strip()
    accept_ans = str(1 if isprime(m) else 0)

    print("Your answers: ", my_ans)
    print("Excepted answers: ", accept_ans)
    if my_ans != accept_ans:
        print(id_test, "FALSE")
        exit(0)
    else:
        print(id_test, "TRUE")


