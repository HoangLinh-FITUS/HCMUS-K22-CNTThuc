#include <iostream>
#include <vector>
#include <complex>
//#include "bai1.h"

using namespace std;
namespace calculator {
    using data_type = int64_t;

    const char* charhex_to_bin(char c) {
        switch (toupper(c)) {
        case '0': return "0000";
        case '1': return "0001";
        case '2': return "0010";
        case '3': return "0011";
        case '4': return "0100";
        case '5': return "0101";
        case '6': return "0110";
        case '7': return "0111";
        case '8': return "1000";
        case '9': return "1001";
        case 'A': return "1010";
        case 'B': return "1011";
        case 'C': return "1100";
        case 'D': return "1101";
        case 'E': return "1110";
        case 'F': return "1111";
        }
        return "0";
    }

    char int_to_charhex(const int& c) {
        static char a[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
        return a[c];
    }

    void convert_hex_into_binary(string& number) {
        string res = "";
        for (const auto& i : number) res += charhex_to_bin(i);
        number = res;
    }

    void convert_binary_into_hex(string& number) {
        string res = "";
        int n = number.size();
        for (int i = n - 1; i >= 0; i -= 4) {
            int val = 0, x = 1;
            for (int j = i; j >= max(0, i - 3); --j) {
                if (number[j] == '1') val += x;
                x <<= 1;
            }
            res += int_to_charhex(val);
        }
        while (res.size() > 0 && res.back() == '0') res.pop_back();
        reverse(res.begin(), res.end());
        number = res;
    }

    struct BigHex {
    private:
        static const int MAXBIT = 31;
        static const data_type BASE = 1UL << MAXBIT;

        vector <data_type> number;

        void del_zero_back(vector <data_type>& a) {
            while (a.size() > 1 && a.back() == 0) a.pop_back();
        }
        void split_binary(string& numberBin) {
            while (numberBin.size() % MAXBIT != 0) numberBin = '0' + numberBin;
            int n = numberBin.size();

            for (int i = n - 1; i >= 0; i -= MAXBIT) {
                int x = 1;
                data_type val = 0;
                for (int j = i; j >= max(0, i - MAXBIT + 1); --j) {
                    if (numberBin[j] == '1') val += x;
                    x <<= 1;
                }
                this->number.push_back(val);
            }
            del_zero_back(this->number);
        }
    public:
        BigHex() : number({ 0 }) {}

        BigHex(const string& numberHex) {
            string numberBin = numberHex;
            convert_hex_into_binary(numberBin);
            split_binary(numberBin);
        }

        BigHex(const data_type& numberInt) {
            string numberBin = "";
            for (data_type x = numberInt; x > 0; x >>= 1) numberBin += (x % 2) + '0';
            if (numberBin.empty()) numberBin = "0";
            reverse(numberBin.begin(), numberBin.end());
            split_binary(numberBin);
        }

        BigHex(const vector<data_type>& otherNumber) {
            int n = otherNumber.size();
            this->number.resize(n);
            data_type carry = 0;
            for (int i = 0; i < n; ++i) {
                this->number[i] = otherNumber[i] + carry;
                carry = this->number[i] / BASE;
                this->number[i] %= BASE;
            }
            if (carry > 0) this->number.emplace_back(carry);
            del_zero_back(this->number);
        }

        const vector <data_type>& get_value() const {
            return this->number;
        }

        const int& get_size() const { return this->number.size(); }

        friend ostream& operator << (ostream& os, const BigHex& number) {
            string ans = "";
            for (int i = number.get_size() - 1; i >= 0; --i) {
                data_type x = number[i];
                string bin = "";
                while (x > 0) {
                    bin += (x % 2) + '0';
                    x >>= 1;
                }
                if (bin.size() == 0) bin = "0";
                while (bin.size() % BigHex::MAXBIT != 0) bin += '0';
                reverse(bin.begin(), bin.end());
                ans += bin;
            }
            convert_binary_into_hex(ans);
            if (ans == "") ans = "0";
            os << ans;
            return os;
        }

        bool operator > (const BigHex& otherNumber) const {
            int sizeNum1 = this->number.size();
            int sizeNum2 = otherNumber.get_size();
            if (sizeNum1 != sizeNum2) return sizeNum1 > sizeNum2;
            for (int i = sizeNum1 - 1; i >= 0; --i) {
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
            int n = otherNumber.get_size();
            this->number.resize(n);
            for (int i = 0; i < n; ++i) this->number[i] = otherNumber[i];
        }

        const data_type& operator[] (const int& index) const {
            if (index < 0 || index >= get_size()) {
                cerr << "Array index out of range\n";
                exit(0);
            }
            return this->number[index];
        }

        BigHex& operator += (const BigHex& otherNumber) {

            data_type carry = 0;

            int i = 0, j = 0;
            int n = this->number.size();
            int m = otherNumber.get_size();

            this->number.resize(max(n, m) + 1);

            int l = 0;
            while (i < n || j < m) {
                data_type digitNumber1 = i == n ? 0 : this->number[i++];
                data_type digitNumber2 = j == m ? 0 : otherNumber[j++];

                data_type r = (digitNumber1 + digitNumber2 + carry) % BASE;
                carry = (digitNumber1 + digitNumber2 + carry) / BASE; // phan nho 

                this->number[l++] = r;
            }

            if (carry > 0) this->number[l++] = carry;
            del_zero_back(this->number);

            return *this;
        }

        BigHex operator + (const BigHex& otherNumber) const {
            BigHex tmp(*this);
            tmp += otherNumber;
            return move(tmp);
        }

        BigHex& operator ++ () {
            *this += BigHex(1);
            return *this;
        }

        BigHex& operator ++ (int) {
            return ++ * this;
        }

        BigHex& operator -= (const BigHex& otherNumber) {

            data_type carry = 0;
            int n = this->number.size();
            int m = otherNumber.get_size();

            this->number.resize(max(n, m) + 1);

            int i = 0, j = 0, l = 0;
            while (i < n || j < m) {
                data_type digitNumber1 = i == n ? 0 : this->number[i++];
                data_type digitNumber2 = j == m ? 0 : otherNumber[j++];

                data_type r = digitNumber1 - digitNumber2 + carry;

                if (r < 0) {
                    carry = -1;
                    r += BASE;
                }
                else carry = 0;

                this->number[l++] = r;
            }

            if (carry < 0) {
                cerr << "khong tru duoc khi number1 < number2";
                exit(0);
            }

            del_zero_back(this->number);

            return *this;

        }

        BigHex operator - (const BigHex& otherNumber) const {
            BigHex tmp(*this);
            tmp -= otherNumber;
            return move(tmp);
        }

        BigHex& operator --() {
            *this -= BigHex(1);
            return *this;
        }

        BigHex& operator --(int) {
            return -- * this;
        }

        BigHex& operator *= (const BigHex& otherNumber) {
            int n = this->number.size(), m = otherNumber.get_size();

            vector <data_type> c(n + m + 1);
            this->number.resize(n + m + 1);
            for (int i = 0; i < n; ++i) {
                for (int j = 0; j < m; ++j) {
                    c[i + j] += (*this)[i] * otherNumber[j];
                    c[i + j + 1] += c[i + j] / BASE;
                    c[i + j] %= BASE;

                }
            }

            for (int i = 0; i < n + m; ++i) {
                c[i + 1] += c[i] / BASE;
                this->number[i] = c[i] % BASE;
            }
            del_zero_back(this->number);
            return *this;
        }


        BigHex operator * (const BigHex& otherNumber) const {
            BigHex tmp(*this);
            tmp *= otherNumber;
            return move(tmp);
        }


        BigHex& operator *= (const data_type& x) {
            data_type carry = 0;
            int n = this->number.size();
            for (int i = 0; i < n; ++i) {
                data_type r = (this->number[i] * x + carry) % BASE;
                carry = (this->number[i] * x + carry) / BASE;
                this->number[i] = r;
            }

            if (carry > 0) this->number.push_back(carry);

            return *this;
        }

        BigHex operator * (const data_type& x) const {
            BigHex tmp(*this);
            tmp *= x;
            return move(tmp);
        }

        BigHex& operator /= (const data_type& x) {
            data_type r = 0;
            for (int i = (int)this->number.size() - 1; i >= 0; --i, r %= x) {
                r = r * BASE + (*this)[i];
                this->number[i] = r / x;
            }
            del_zero_back(this->number);
            return *this;
        }

        BigHex operator / (const data_type& x) const {
            BigHex tmp(*this);
            tmp /= x;
            return move(tmp);
        }

        BigHex& operator %= (const BigHex& otherNumber) {
            static vector <BigHex> power2;
            if (power2.empty()) {
                string res = "";
                for (int i = 0; i <= 2048; i += 4) {
                    power2.emplace_back(BigHex('1' + res));
                    power2.emplace_back(BigHex('2' + res));
                    power2.emplace_back(BigHex('4' + res));
                    power2.emplace_back(BigHex('8' + res));
                    res += '0';
                }
            }

            BigHex mul;
            int Spw2 = (this->number.size() < 35) ? 1029 : power2.size();

            //Spw2 = min(1ll * Spw2, MAXBIT * this->get_size()); // (2^MAXBIT)^i.... 0 
            for (int i = Spw2 - 1; i >= 0; --i) if (*this >= power2[i] && *this >= otherNumber) {
                mul = otherNumber * power2[i];
                while (*this >= mul) *this -= mul;
            }

            return *this;
        }

        BigHex operator % (const BigHex& otherNumber) const {
            BigHex tmp(*this);
            tmp %= otherNumber;
            return move(tmp);
        }

        bool is_odd() const {
            return this->number[0] & 1;
        }

    };

    BigHex power(BigHex a, BigHex b, const BigHex& m) {
        a %= m;

        BigHex res(1), zero(0);
        while (b > zero) {
            if (b.is_odd()) {
                res *= a;
                if (res >= m) res %= m;
            }
            a *= a;
            if (a >= m) a %= m;
            b /= 2;
        }
        return res;
    }

    BigHex power(BigHex a, BigHex b) {
        BigHex res(1);
        while (b > BigHex(0)) {
            if (b.is_odd()) res *= a;
            a *= a;
            b /= 2;
        }
        return move(res);
    }

    namespace MONTGOMERY {
        BigHex BitLength(BigHex v, int& x) {
            x = 0;
            BigHex zero(0);
            while (v > zero) {
                v /= 2;
                ++x;
            }
            return move(BigHex(x));
        }

        struct Montgomery {
            BigHex m;
            BigHex n;
            BigHex rrm;
            int x;

            Montgomery(const BigHex& m) {
                if (m == BigHex(0) || !m.is_odd()) {
                    cerr << m << " :m must be greater than zero and odd";
                    exit(0);
                }
                this->m = m;
                this->n = BitLength(m, x);
                this->rrm = power(2, n * 2, m);
            }

            BigHex reduce(const BigHex& t) {
                BigHex a = t;
                for (int i = 0; i < x; i++) {
                    if (a.is_odd()) a += m;
                    a /= 2;
                }
                if (a >= m) a -= m;
                return move(a);
            }
        };

        BigHex powerMod(BigHex x1, const BigHex& x2, const BigHex& m) {
            x1 %= m;

            Montgomery mont(m);
            //BigHex t1 = x1 * mont.rrm;
            //BigHex t2 = x2 * mont.rrm;

            BigHex r1 = mont.reduce(x1 * mont.rrm);
            BigHex r2 = mont.reduce(x2 * mont.rrm);
            BigHex r = power(2, mont.n);

            BigHex prod = mont.reduce(mont.rrm);
            BigHex base = mont.reduce(x1 * mont.rrm);
            BigHex exp = x2;
            int x = 0;
            BigHex zero(0);
            while (BitLength(exp, x) > zero) {
                if (exp.is_odd()) prod = mont.reduce(prod * base);
                exp /= 2;
                base = mont.reduce(base * base);
            }

            return move(mont.reduce(prod));
        }
    }
}

using namespace calculator;

bool test(BigHex a, const int& k, const BigHex& m, const BigHex& n) {
    BigHex tmp = n;
    --tmp;
    BigHex pw = MONTGOMERY::powerMod(a, m, n);
    if (pw == BigHex(1) || pw == tmp) return true;
    for (int l = 1; l < k; l++) {
        pw *= pw;
        if (pw >= n) pw %= n;
        if (pw == tmp) return true;
    }
    return false;
}

bool miller_rabin(const BigHex& n) {
    if (n < BigHex(2)) return false;
    if (n == BigHex(2)) return true;
    if (!n.is_odd()) return false;
    
    int k = 0;
    BigHex m = n;
    --m;
    while (!m.is_odd()) {
        m /= 2;
        k++;
    }
    
    for (auto a : { "2", "3", "5", "7", "B", "D", "11", "13" }) {//, "17", "1D", "1F", "25", "29", "2B", "2F", "35"}) {//}, "3B", "3D", "43", "47", "49", "4F", "53", "59", "61"}) {
        BigHex tmp(a);
        if (n == tmp) return true;
        if (!test(tmp, k, m, n)) return false;
    }
    return true;
}


int main(int argc, char* argv[]) {
	ios::sync_with_stdio(false); cin.tie(0);
  
    /*long long a = 0x12;
    long long b = 0x12;
    cout << BigHex(a) * BigHex(b) << '\n';
    cout << hex << a * b;*/
    //string a, b, m;
    //long long d = 1;
    //cin >> a >> b >> m >> d;

    //cout << BigHex(a) + BigHex(b) << '\n';

    //if (BigHex(a) < BigHex(b)) cout << "-1\n";
    //else cout << BigHex(a) - BigHex(b) << '\n';
    //
    //cout << BigHex(a) * BigHex(b) << '\n';
    //cout << BigHex(a) % BigHex(b) << '\n';
    //cout << BigHex(a) / d << '\n';
    ////cout << power(a, b, m) << '\n';
    //cout << MONTGOMERY::powerMod(a, b, m) << '\n';
    string m = "37";cin >> m;
    cout << miller_rabin(m) << '\n';

	return 0;
}

