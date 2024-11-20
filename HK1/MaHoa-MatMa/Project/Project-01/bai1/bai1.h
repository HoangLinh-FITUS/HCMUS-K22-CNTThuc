#pragma once
#include <iostream>
#include <algorithm>
#include <vector>
#include <complex>

using namespace std;

namespace FFT {

    using cd = complex<double>;
    const double PI = acos(-1);

    void fft(vector <cd>& a, bool invert) {
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
    
        fft(fa, false); fft(fb, false);
        for (int i = 0; i < n; ++i) fa[i] *= fb[i]; // MOD if need
    
        fft(fa, true);
    
        static vector <int> result;
        result.resize(n);
        for (int i = 0; i < n; ++i) result[i] = round(fa[i].real());
    
        while (result.size() >= a.size() + b.size() && result.back() == 0) result.pop_back();
    
        return result;
    }
};

class BigHex {
private:
    vector <char> number, numMod;

    const int BASE = 16;
    const char BASE_16[16] = { 'F', 'E', 'D', 'C', 'B', 'A', '9', '8', '7', '6', '5', '4', '3', '2', '1', '0' }; // fix string -> char (chua fix)

    void process_back_zero(vector<char>& number) { // xoa chu so 0 o dau 
        while (!number.empty() && number.back() == '0') {
            number.pop_back();
        }
        if (number.empty()) number = { '0' };
    }

public:
    BigHex() : number({'0'}) {}
    BigHex(const string& number) {
        for (const auto& c : number) this->number.emplace_back(c);
    }
    BigHex(const char& number) {
        this->number.emplace_back(number);
    }
    BigHex(const vector<char>& otherNumber) {
        this->number = otherNumber;
    }

    int get_size() const {
        return this->number.size();
    }

    void pop_back() {
        this->number.pop_back();
        if (this->number.empty()) this->number = { '0' };
    }
    char back() {
        return this->number.back();
    }

    const vector<char>& get_value() const {
        return this->number;
    }

    const vector<char>& get_mod() const {
        return this->numMod;
    }

    inline int charOf_hex_to_decimal(const char& digit) const { // chuyen doi thanh ki tu thuoc he 16 sang he 10 
        if ('0' <= digit && digit <= '9') return digit - '0';
        return digit - 'A' + 10;
    }

    inline char digitOf_decimal_to_hex(const int& digit) const { // chuyen doi thanh chu so thuoc he 10 sang he hex
        return BASE_16[BASE - digit - 1];
        /*if (0 <= digit && digit <= 9) return digit + '0';
        return digit - 10 + 'A';*/
    }

    friend ostream& operator << (ostream& os, const BigHex& number) {
        for (auto i : number.get_value()) os << i;
        return os;
    }

    bool operator > (const BigHex& otherNumber) const {
        int sizeNum1 = this->number.size();
        int sizeNum2 = otherNumber.get_size();
        if (sizeNum1 != sizeNum2) return sizeNum1 > sizeNum2;
        for (int i = 0; i < sizeNum1; i++) {
            if (this->number[i] != otherNumber[i]) 
                return this->number[i] > otherNumber[i];
        }
        return false;
    }

    bool operator < (const BigHex& otherNumber) const {
        return otherNumber > *this;
    }

    bool operator == (const BigHex& otherNumber) const {
        return !(*this > otherNumber) && !(otherNumber > *this);
    }

    bool operator <= (const BigHex& otherNumber) const {
        return otherNumber > *this || *this == otherNumber;
    }

    bool operator >= (const BigHex& otherNumber) const {
        return *this > otherNumber || *this == otherNumber;
    }

    void operator = (const BigHex& otherNumber) {
        this->number.clear();
        for (const auto& val : otherNumber.get_value()) 
            this->number.emplace_back(val);
    }

    char operator[] (int index) const {
        if (index < 0 || index >= get_size()) {
            cerr << "Array index out of range\n";
            exit(0);
        }
        return this->number[index];
    }

    BigHex& operator += (const BigHex& otherNumber) {
        
        vector <char> number1 = this->number;
        
        int carry = 0;
        int j = otherNumber.get_size();
        int i = number.size();

        this->number.clear();
        while (i > 0 || j > 0) {
            int digitNumber1 = i == 0 ? 0: charOf_hex_to_decimal(number1[--i]);
            int digitNumber2 = j == 0 ? 0: charOf_hex_to_decimal(otherNumber[--j]);

            int r = (digitNumber1 + digitNumber2 + carry) % BASE;
            carry = (digitNumber1 + digitNumber2 + carry) / BASE; // phan nho 

            this->number.emplace_back(digitOf_decimal_to_hex(r));
        }

        if (carry > 0) this->number.emplace_back(digitOf_decimal_to_hex(carry));
        
        process_back_zero(this->number);
        reverse(this->number.begin(), this->number.end());

        return *this;
    }

    BigHex operator + (const BigHex& otherNumber) const {
        BigHex tmp = *this;
        tmp += otherNumber;
        return tmp;
    }
    
    BigHex& operator ++ () {
        *this += BigHex("1");
        return *this;
    }

    BigHex& operator ++ (int) {
        return ++ * this;
    }

    BigHex& operator -= (const BigHex& otherNumber) {
        vector <char> number1 = this->number;

        int carry = 0;
        int i = this->number.size();
        int j = otherNumber.get_size();
        
        this->number.clear();
        while (i > 0 || j > 0) {
            int digitNumber1 = i == 0 ? 0: charOf_hex_to_decimal(number1[--i]);
            int digitNumber2 = j == 0 ? 0: charOf_hex_to_decimal(otherNumber[--j]);
      
            int r = (digitNumber1 - digitNumber2 + carry + BASE) % BASE;
            carry = (digitNumber1 - digitNumber2 + carry) < 0 ? -1 : 0; // phan nho 
            
            this->number.emplace_back(digitOf_decimal_to_hex(r));
        }

        if (carry < 0) {
            cerr << "khong tru duoc khi number1 < number2";
            exit(0);
        }

        process_back_zero(this->number);
        reverse(this->number.begin(), this->number.end());

        return *this;

    }

    BigHex operator - (const BigHex& otherNumber) const {
        BigHex tmp = *this;
        tmp -= otherNumber;
        return tmp;
    }

    BigHex& operator --() {
        *this -= BigHex("1");
        return *this;
    }

    BigHex& operator --(int) {
        return -- *this;
    }

    BigHex& operator *= (const BigHex& otherNumber) {
        vector <int> a, b;
        for (auto& digit : this->number) a.emplace_back(charOf_hex_to_decimal(digit));
        for (auto& digit : otherNumber.get_value()) b.emplace_back(charOf_hex_to_decimal(digit));

        const std::vector<int>& result = FFT::MULTIPLY(a, b);

        int carry = 0;
        this->number.clear();
        for (int i = (int)result.size() - 1; i >= 0; i--) {
            int r = (result[i] + carry) % BASE;
            carry = (result[i] + carry) / BASE;

            this->number.emplace_back(digitOf_decimal_to_hex(r));
        }

        while (carry > 0) {
            int r = carry % BASE;
            this->number.emplace_back(digitOf_decimal_to_hex(r));
            carry /= BASE;
        }

        process_back_zero(this->number);
        reverse(this->number.begin(), this->number.end());

        return *this;
    }

    BigHex operator * (const BigHex& otherNumber) const {
        BigHex tmp = *this;
        tmp *= otherNumber;
        return tmp;
    }

    void div2() {
        vector<char> num = this->number;
        this->number.clear();
        int carry = 0;
        for (const auto& d : num) {
            int digit = charOf_hex_to_decimal(d);
            char val = digitOf_decimal_to_hex((digit + carry) >> 1);
            carry = ((digit + carry) & 1) ? BASE : 0;

            if (this->number.empty() && val == '0') continue;
            this->number.emplace_back(val);
        }
    }

    BigHex& operator /= (const BigHex& numDiv) {
        BigHex numMod("0");
        vector <char> tmp = this->number;
        this->number.clear();
        for (const auto& digit : tmp) {
            (numMod *= BigHex("10")) += BigHex(digit);
            if (numMod < numDiv) {
                this->number.emplace_back('0');
                continue;
            }
            int c = 0;
            for (int L = 0, R = BASE - 1; L <= R; ) {
                int mid = (L + R) >> 1;

                if (numMod >= numDiv * BigHex(BASE_16[mid])) {
                    c = mid;
                    R = mid - 1;
                }
                else {
                    L = mid + 1;
                }
            }

            numMod -= numDiv * BigHex(BASE_16[c]);
            this->number.emplace_back(BASE_16[c]);
        }

        this->numMod = numMod.get_value();
        process_back_zero(this->number);
        return *this;
    }

    BigHex operator / (const BigHex& otherNumber) const {
        BigHex tmp = *this;
        tmp /= otherNumber;
        return tmp;
    }

    BigHex& operator %= (const BigHex& numDiv) {
        *this /= numDiv;
        this->number = this->numMod;
        return *this;
    }

    BigHex operator % (const BigHex& numMod) const {
        BigHex tmp = *this;
        tmp %= numMod;
        return BigHex(tmp.get_mod());
    }

    bool is_odd() const {
        return charOf_hex_to_decimal(this->number.back()) & 1;
    }

    BigHex& power(BigHex exp) {
        BigHex a = *this;
        this->number = { '1' };
        while (exp > BigHex("0")) {
            if (exp.is_odd()) *this *= a;
            a *= a;
            exp.div2();
        }
        return *this;
    }

    BigHex& power(BigHex exp, BigHex m) {
        BigHex a = *this;
        this->number = { '1' };

        while (exp > BigHex("0")) {
            if (exp.is_odd()) (*this *= a) %= m;
            (a *= a) %= m;
            exp.div2();
        }
        return *this;
    }

};

namespace MONTGOMERY {
    BigHex BitLength(BigHex v, int& x) {
        BigHex k("0");
        x = 0;
        while (v > BigHex("0")) {
            v.div2();
            k++;
            x++;
        }
        return k;
    }

    struct Montgomery {
        BigHex m;
        BigHex n; // n dang duoc bieu dien he so 16 
        BigHex rrm;
        int x; // bieu dien he co so 10 cua n

        Montgomery(const BigHex& m) {
            if (m == BigHex("0") || !m.is_odd()) {
                cerr << m << " :m must be greater than zero and odd";
                exit(0);
            }
            this->m = m;
            this->n = BitLength(m, x);
            //this->rrm = BigHex("2").power(n * BigHex("2"), m);
            this->rrm = power2(n * BigHex("2"), x * 2) % m;
            //cout << "2^" << x * 2 << " " << m << " " << n * BigHex("2") << " ";
            //cout << x * 2 << " " << power2(n * BigHex("2"), x * 2)  << " ";
            //cout << BigHex("2").power(n * BigHex("2")) << '\n';
            // 2^(n * 2) = 16^(n * 2)/4 + 2^((n*2)%4)
            // 2^n = (2^4)^(n/4) = (2^4)^(n//4 + n%4)
        }

        BigHex power2(const BigHex& n, int x) { // 2^n % m
            if (x <= 4) return BigHex("2").power(n);
            int q = x / 4;
            int r = x % 4;
            string res = "";
            if (r == 0) res = "1";
            if (r == 1) res = "2";
            if (r == 2) res = "4";
            if (r == 3) res = "8";
            while (q--) res += "0";
            return BigHex(res);
        }

        BigHex reduce(const BigHex& t) { // t: bigint
            BigHex a = t;
            for (int i = 0; i < x; i++) {
                if (a.is_odd()) a += m;
                a.div2();
            }
            if (a >= m) a -= m;
            return a;
        }
    };

    BigHex powerMod(BigHex x1, const BigHex& x2, const BigHex& m) {
        x1 %= m;

        Montgomery mont(m);
        //BigHex t1 = x1 * mont.rrm;
        //BigHex t2 = x2 * mont.rrm;

        BigHex r1 = mont.reduce(x1 * mont.rrm);
        BigHex r2 = mont.reduce(x2 * mont.rrm);
        BigHex r = mont.power2(mont.n, mont.x); //BigHex("2").power(mont.n);

        BigHex prod = mont.reduce(mont.rrm);
        BigHex base = mont.reduce(x1 * mont.rrm);
        BigHex exp = x2;
        int x = 0;
        while (BitLength(exp, x) > BigHex("0")) {
            if (exp.is_odd()) prod = mont.reduce(prod * base);
            exp.div2();
            base = mont.reduce(base * base);
        }

        return mont.reduce(prod);
    }
}


bool test(const BigHex& a, const int& k, const BigHex& m, const BigHex& n) {
    BigHex tmp = n;
    tmp--;
    BigHex pw = MONTGOMERY::powerMod(a, m % tmp, n);
    if (pw == BigHex("1") || pw == tmp) return true;
    cout << "ok\n";
    for (int l = 1; l < k; l++) {
        (pw *= pw) %= n;
        if (pw == tmp) return true;
    }
    return false;
}

bool miller_rabin(const BigHex& n) {
    if (n < BigHex("2")) return false;
    if (n == BigHex("2")) return true;
    if (!n.is_odd()) return false;
    
    int k = 0;
    BigHex m = n;
    m--;
    while (!m.is_odd()) {
        m.div2();
        k++;
    }
    cout << "ok\n";
    BigHex x;
    for (auto a : { "2", "3", "5", "7", "B", "D", "11", "13", "17", "1D", "1F", "25", "29", "2B", "2F", "35"}) { // "3B", "3D", "43", "47", "49", "4F", "53", "59", "61"}) {
        x = BigHex(a);
        if (n == x) return true;
        if (!test(x, k, m, n)) return false;
        cout << a << '\n';
    }
    return true;
}
