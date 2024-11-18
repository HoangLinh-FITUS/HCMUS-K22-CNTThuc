#pragma once
#include <iostream>
#include <algorithm>
#include <vector>
#include <complex>

using namespace std;


using cd = complex<double>;
const double PI = acos(-1);
const string BASE_16[] = { "F", "E", "D", "C", "B", "A", "9", "8", "7", "6", "5", "4", "3", "2", "1", "0" };

void FFT(vector<cd>& a, bool invert) {
    int n = a.size();

    for (int i = 1, j = 0; i < n; ++i) {
        int bit = n >> 1;
        for (; j & bit; bit >>= 1) j ^= bit;
        j ^= bit;

        if (i < j) swap(a[i], a[j]);
    }

    for (int len = 2; len <= n; len <<= 1) {
        double ang = 2 * PI / len * (invert ? -1 : 1);
        cd wlen(cos(ang), sin(ang));
        for (int i = 0; i < n; i += len) {
            cd w(1);
            for (int j = 0; j < len / 2; ++j) {
                cd u = a[i + j], v = a[i + j + len / 2] * w;
                a[i + j] = u + v;
                a[i + j + len / 2] = u - v;
                w *= wlen;
            }
        }
    }

    if (invert) for (auto& x : a) x /= n;
}
vector <int>& MULTIPLY(vector <int> const& a, vector <int> const& b) {
    vector <cd> fa(a.begin(), a.end()), fb(b.begin(), b.end());
    int n = 1;
    while (n < (int)a.size() + (int)b.size()) n <<= 1;
    fa.resize(n); fb.resize(n);

    FFT(fa, false); FFT(fb, false);
    for (int i = 0; i < n; ++i) fa[i] *= fb[i]; // MOD if need

    FFT(fa, true);

    static vector <int> result;
    result.resize(n);
    for (int i = 0; i < n; ++i) result[i] = round(fa[i].real());

    while (result.size() >= a.size() + b.size() && result.back() == 0) result.pop_back();

    return result;
}


bool compare_gt(const string& number1, const string& number2) { // number1 >= number2
    if (number1.size() > number2.size()) return true;
    if (number1.size() < number2.size()) return false;
    return number1 >= number2;
}

inline int charOf_hex_to_decimal(const char& digit) { // chuyen doi thanh ki tu thuoc he 16 sang he 10 
    if ('0' <= digit && digit <= '9') return digit - '0';
    return digit - 'A' + 10;
}

inline char digitOf_decimal_to_hex(const int& digit) { // chuyen doi thanh chu so thuoc he 10 sang he hex
    if (0 <= digit && digit <= 9) return digit + '0';
    return digit - 10 + 'A';
}

void balance_lenNumber(string& number1, const string& number2) { // can bang do dai cua 2 so 
    while (number1.size() < number2.size()) number1 = '0' + number1;
}

void process_head_zero(string& number) { // xoa chu so 0 o dau 
    reverse(number.begin(), number.end());

    while (!number.empty() && number.back() == '0') {
        number.pop_back();
    }
    if (number.empty()) number = "0";

    reverse(number.begin(), number.end());
}

string add(string& number1, string& number2, int base = 16) { // cong 2 so

    balance_lenNumber(number1, number2);
    balance_lenNumber(number2, number1);

    static string sum;
    sum = "";
    int carry = 0;
    for (int i = (int)number1.size() - 1; i >= 0; i--) {
        int digitNumber1 = charOf_hex_to_decimal(number1[i]);
        int digitNumber2 = charOf_hex_to_decimal(number2[i]);

        int r = (digitNumber1 + digitNumber2 + carry) % base;
        carry = (digitNumber1 + digitNumber2 + carry) / base; // phan nho 

        sum += digitOf_decimal_to_hex(r);
    }

    if (carry > 0) sum += digitOf_decimal_to_hex(carry);
    reverse(sum.begin(), sum.end());

    process_head_zero(sum);
    return sum;
}

string add(const string& number1, const string& number2, int base = 16) {
    string x = number1;
    string y = number2;
    return add(x, y);
}

string subtract(string& number1, string& number2, int base = 16) { // tru 2 so (number1 >= number2)

    balance_lenNumber(number1, number2);
    balance_lenNumber(number2, number1);
    static string sum;
    sum = "";
    int carry = 0;
    for (int i = (int)number1.size() - 1; i >= 0; i--) {
        int digitNumber1 = charOf_hex_to_decimal(number1[i]);
        int digitNumber2 = charOf_hex_to_decimal(number2[i]);
        int r = (digitNumber1 - digitNumber2 + carry + base) % base; 
        carry = (digitNumber1 - digitNumber2 + carry) < 0 ? -1 : 0; // phan nho 
        sum += digitOf_decimal_to_hex(r);
    }
    if (carry < 0) {
        cout << "khong tru duoc khi number1 < number2";
        exit(0);
    }
    reverse(sum.begin(), sum.end());
    process_head_zero(sum);
    return sum;
 }

string subtract(const string& number1, const string& number2, int base = 16) {
    string x = number1;
    string y = number2;
    return subtract(x, y);
}

string multiple(const string& number1,const string& number2, int base = 16) {

    vector <int> a, b;
    for (auto &digit: number1) a.push_back(charOf_hex_to_decimal(digit));
    for (auto &digit: number2) b.push_back(charOf_hex_to_decimal(digit));

    const std::vector<int>& result = MULTIPLY(a, b);

    int carry = 0;
    static string res;
    res = "";
    for (int i = (int)result.size() - 1; i >= 0; i--) {
        int r = (result[i] + carry) % base;
        carry = (result[i] + carry) / base;

        res += digitOf_decimal_to_hex(r);
    }

    while (carry > 0) {
        int r = carry % base;
        res += digitOf_decimal_to_hex(r);
        carry /= base;
    }

    reverse(res.begin(), res.end());

    process_head_zero(res);
    return res;
}

string div2(const string& number, int base = 16) { // chia number cho 2 
    static string divNumber;
    divNumber = "";
    int carry = 0;
    for (const auto& d : number) {
        int digit = charOf_hex_to_decimal(d);
        divNumber += digitOf_decimal_to_hex((digit + carry) >> 1);

        carry = ((digit + carry) & 1) ? base : 0;
    }
    process_head_zero(divNumber);
    return divNumber;
}

string mod(const string& number, const string& numberMod) { // number chia du chu numberMod
    
    static string numDiv;
    numDiv = "";
    string numMul;
    for (const auto& digit: number) {
        numDiv += digit;
        if (!compare_gt(numDiv, numberMod)) continue;
        
        int c = -1;
        for (int L = 0, R = 15; L <= R; ) {
            int mid = (L + R) >> 1;

            if (compare_gt(numDiv, multiple(numberMod, BASE_16[mid]))) {
                c = mid;
                R = mid - 1;
            }
            else {
                L = mid + 1;
            }
        }

        if (c == -1) continue;
        numDiv = subtract(numDiv, multiple(numberMod, BASE_16[c]));
        if (numDiv == "0") numDiv = "";
        
    }

    process_head_zero(numDiv);
    return numDiv;
} 

bool is_odd(const string& number) {
    return charOf_hex_to_decimal(number.back()) & 1;
}

string powerMod(string a, string b, const string &n) {
    static string ans;
    ans = "1";
    while (b != "0") {
        if (is_odd(b)) ans = mod(multiple(ans, a), n);
        a = mod(multiple(a, a), n);
        b = div2(b);
    }
    return ans;
}

 bool test(const string& a, const int& k, const string& m, const string &n) {
     static string pw;
     pw = powerMod(a, m, n);
     if (pw == "1" || pw == subtract(n, "1")) return true;

     for (int l = 1; l < k; l++) {
         pw = mod(multiple(pw, pw), n);
         if (pw == subtract(n, "1")) return true;
     }
     return false;
 }

 bool miller_rabin(const string& n) {
     int k = 0;
     static string m;
     m = subtract(n, "1");
     while (!is_odd(m)) {
         m = div2(m);
         k++;
     }

     for (auto a : { "2", "3", "5", "7", "B", "D", "11", "13", "17", }) {//"1D", "1F", "25", "29", "2B", "2F", "35"}) { // "3B", "3D", "43", "47", "49", "4F", "53", "59", "61"}) {
         if (n == a) return true;
         if (!test(a, k, m, n)) return false;
         cout << a << '\n';
     }
     return true;
 }