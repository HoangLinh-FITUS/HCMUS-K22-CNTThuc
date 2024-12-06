import os 
import math 
from random import randint
from sympy import *
import time 
from egcd import egcd

path = "H:\\Nam3\\HK1\\MaHoa-MatMa\\Project\\Project-01\\22127233-Project1\\bai2.exe"
file_input = "test2.inp"
file_output = "test2.out"

MAX = 2**1024

def test_case1():    
    p = randint(2, MAX)
    q = randint(2**1023, MAX)
    e = randint(2, MAX)
    p = nextprime(p)
    q = nextprime(q)
    # e = nextprime(e)

    return p, q, e

for id_test in range(10000):
    p, q, e = test_case1()

    with open(file_input, "w") as file:
        file.write(str(hex(p).upper()[2:]) + '\n')
        file.write(str(hex(q).upper()[2:]) + '\n')
        file.write(str(hex(e).upper()[2:]))

    
    s = time.time()
    os.system(f"g++ ../22127233-project1/bai2.cpp -o ../22127233-project1/bai2.exe")
    os.system(f"{path} {file_input} {file_output}")
    print("Running in: ", time.time() - s)

    with open(file_output, "r") as file:
        my_ans = int(file.read(), 16)
        # my_ans = file.read().split()
        # s = int(my_ans[0], 16)
        # t = int(my_ans[1], 16)
        # g = int(my_ans[2], 16)
        # print(s, t, g)
        # if (s * p + t * q == g and g == math.gcd(p, q)):
        #     print(id_test, "TRUE")
        # else:
        #     print(id_test, "FALSE")
        #     exit(0)
        phi = (p - 1) * (q - 1)
        g, d, x = egcd(e, phi)

        accepted_ans = -1
        if (g == 1): 
            accepted_ans = d % phi    
        
        #print("Your answers: ", my_ans)
        #print("Except answers: ", accepted_ans)
        if (my_ans != accepted_ans):
            print(id_test, "FALSE")
            exit(0)    

        print(id_test, "TRUE")


