import os 
import math 
from random import randint
from sympy import *
import time 
from egcd import egcd

path = "H:\\Nam3\\HK1\\MaHoa-MatMa\\Project\\Project-01\\22127233-Project1\\bai3.exe"
file_input = "test3.inp"
file_output = "test3.out"

MAX = 2**1024
def generate_key():
    p = randint(2**511, MAX)
    q = randint(2**511, MAX)
    p = nextprime(p)
    q = nextprime(q)
    N = p * q
    phi = (p - 1) * (q - 1)
    e = randint(1, phi)
    return N, e

def test_case1():    
    x = randint(5, 5)
    y = randint(20, 20)
    N, e = generate_key()
    m = [randint(2, MAX) for i in range(x)]

    c = []
    for i in range(y):
        if (randint(0, 1) == 1): c.append(randint(2, MAX))
        else:
            c.append(pow(m[randint(0, x - 1)], e, N))

    return x, y, N, e, m, c

for id_test in range(1000):
    x, y, N, e, m, c = test_case1()
    
    with open(file_input, "w") as file:
        file.write(str(x) + " " + str(y) + '\n')
        file.write(hex(N).upper()[2:] + " " + hex(e).upper()[2:] + '\n')
        for i in range(x):
            file.write(hex(m[i]).upper()[2:] + '\n')

        for i in range(y):
            file.write(hex(c[i]).upper()[2:] + '\n')
        
    
    s = time.time()
    os.system(f"g++ ../22127233-project1/bai3.cpp -o ../22127233-project1/bai3.exe")
    os.system(f"{path} {file_input} {file_output}")
    print("Running in: ", time.time() - s)

    with open(file_output, "r") as file:
        my_ans = list(map(int, file.read().split()))

        dic = {}
        for i in range(y):
            dic[c[i]] = i

        accepted_ans = []
        for i in range(x):
            pw = pow(m[i], e, N)
    
            if pw not in dic:
                accepted_ans.append(-1)
            else:
                accepted_ans.append(dic[pw])
        
        print("Your answers: ", my_ans)
        print("Except answers: ", accepted_ans)
        if (my_ans != accepted_ans):
            print(id_test, "FALSE")
            exit(0)    

        print(id_test, "TRUE")


