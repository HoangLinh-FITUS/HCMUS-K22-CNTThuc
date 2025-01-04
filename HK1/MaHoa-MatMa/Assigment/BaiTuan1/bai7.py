def euclid_extended(a, b):
    if b == 0:
        return (a, 1, 0)
    
    d, x0, y0 = euclid_extended(b, a % b)
    x = y0 
    y = x0 - y0 * (a // b)

    if x <= 0:
        x += b // d 
        y -= a // d 

    return d, x, y 

import random 

if __name__ == "__main__":
    # cau a
    a = 252
    b = 198
    
    # cau b 
    # a = 16261 
    # b = 85652

    # # cau c
    a =139024789
    b = 93278890
    
    d, x, y = euclid_extended(a, b)

    print(f'd = {d}, x = {x}, y = {y}')
