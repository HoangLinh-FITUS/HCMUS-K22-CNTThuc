#include <iostream>
#include <random>
#include <chrono>

#include "bai1.h"

using namespace std;

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());
#define rand(l, r) uniform_int_distribution <int> (l, r)(rng)

vector <char> InHoa = { 'A', 'B', 'C', 'D', 'E', 'F' };
vector <char> ChuSo = { '1','2', '3', '4', '5', '6', '7', '8', '9'};

string take(int lena) {
	string a = "";
	for (int i = 1; i <= lena; i++) {
		if (rand(0, 1) == 1) a += InHoa[rand(0, 5)];
		else a += ChuSo[rand(0, 8)];
	}
	return a;
}
int main() {
	miller_rabin(BigHex("5760B4038F5EB5B4784CC3CA1DAD02896BAD2E77E0F2817B6DF20BCEFF52681F34B3143333BD897ABB537DC76DA945D19DDEA25767D566274A3902AE97A701977A8E6C3A9F064361BD238E09807DE18BC285E6A0D75DB74A941047CEA3B4FE65EC77C1FCA71F3323017776D45FD989F5CA999FCC415DCD862646B5E6E1E8E05FD"));
	return 0;
}

