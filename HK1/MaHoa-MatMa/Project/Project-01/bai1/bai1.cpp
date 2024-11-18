#include <iostream>
#include <random>
#include <chrono>

#include "bai1.h"
#define int long long 

using namespace std;

int BitLength(int v) { // v: bigint
	int k = 0;
	while (v > 0) {
		v >>= 1;
		k++;
	}
	return k;
}

struct Montgomery {
	int m; // bigint
	int n;
	int rrm; // bigint 

	Montgomery(int m) {
		if (m == 0 || !(m & 1)) {
			cout << "m must be greater than zero and odd";
			exit(0);
		}
		this->m = m;
		this->n = BitLength(m);
		this->rrm = (1LL << (n * 2)) % m;
	}

	int reduce(int t) { // t: bigint
		int a = t;
		for (int i = 0; i < n; i++) {
			if (a & 1) a += m;
			a >>= 1;
		}
		if (a >= m) a -= m;
		return a;
	}
};

int powerMod(int x1, int x2, int m) {
	x1 %= m;

	Montgomery mont(m);
	int t1 = x1 * mont.rrm;
	int t2 = x2 * mont.rrm;

	int r1 = mont.reduce(t1);
	int r2 = mont.reduce(t2);
	int r = 1LL << mont.n;

	int prod = mont.reduce(mont.rrm);
	int base = mont.reduce(x1 * mont.rrm);
	int exp = x2;
	while (BitLength(exp) > 0) {
		if (exp & 1) prod = mont.reduce(prod * base);
		exp >>= 1;
		base = mont.reduce(base * base);
	}

	//cout << mont.reduce(prod) << '\n';
	return mont.reduce(prod);
}


int power(int x, int y, int n) {
	int res = 1;
	while (y > 0) {
		if (y & 1) res = res * x % n;
		x = x * x % n;
		y /= 2;
	}
	return res;
}

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
#define rand(l, r) uniform_int_distribution <int> (l, r) (rng)


__int32 main() {
  
	for (int i = 0; i < 1000; i++) {
		int x1 = rand(1, 1000);
		int x2 = rand(1, 1000);
		int m = rand(1, 1000);
		if (!(m & 1)) m++;
		if (power(x1, x2, m) == powerMod(x1, x2, m)) {
			cout << "YES\n";
		}
		else {
			cout << "NO";
			exit(0);
		}	
	}
	return 0;
}

