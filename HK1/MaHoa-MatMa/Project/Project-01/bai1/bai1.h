//#pragma once
//#include <iostream>
//#include <algorithm>
//#include <vector>
//#include <complex>
//
//using namespace std;
//using uint32 = unsigned int;
//using uint64 = unsigned long long;
//
//namespace FFT {
//
//    using cd = complex<long double>;
//    const long double PI = acos(-1);
//
//    void fft(vector <cd>& a, bool invert) {
//        int n = a.size();
//    
//        for (int i = 1, j = 0; i < n; ++i) {
//            int bit = n >> 1;
//            for (; j & bit; bit >>= 1) j ^= bit;
//            j ^= bit;
//    
//            if (i < j) swap(a[i], a[j]);
//        }
//    
//        for (int len = 2; len <= n; len <<= 1) {
//            long double ang = 2 * PI / len * (invert ? -1 : 1);
//            cd wlen(cos(ang), sin(ang));
//            for (int i = 0; i < n; i += len) {
//                cd w(1);
//                for (int j = 0; j < len / 2; ++j) {
//                    cd u = a[i + j], v = a[i + j + len / 2] * w;
//                    a[i + j] = u + v;
//                    a[i + j + len / 2] = u - v;
//                    w *= wlen;
//                }
//            }
//        }
//    
//        if (invert) for (auto& x : a) x /= n;
//    }
//
//    vector <uint64>& MULTIPLY(vector <uint64> const& a, vector <uint64> const& b) {
//        vector <cd> fa(a.begin(), a.end()), fb(b.begin(), b.end());
//        int n = 1;
//        while (n < (int)a.size() + (int)b.size()) n <<= 1;
//        fa.resize(n); fb.resize(n);
//    
//        fft(fa, false); fft(fb, false);
//        for (int i = 0; i < n; ++i) fa[i] *= fb[i]; // MOD if need
//        fft(fa, true);
//    
//        static vector <uint64> result;
//        result.resize(n);
//        uint64_t carry = 0;
//        for (int i = 0; i < n; ++i) result[i] = round(fa[i].real());
//        while (result.size() >= a.size() + b.size() && result.back() == 0) result.pop_back();
//    
//        return result;
//    }
//};
//
//struct BigInt {
//private:
//    const uint32 MAXBIT = 20;
//    const uint64 BASE = (1ULL << MAXBIT);
//
//    vector <uint32> number, numMod;
//
//
//    const char* char_to_bin(char c) {
//        switch (toupper(c)) {
//        case '0': return "0000";
//        case '1': return "0001";
//        case '2': return "0010";
//        case '3': return "0011";
//        case '4': return "0100";
//        case '5': return "0101";
//        case '6': return "0110";
//        case '7': return "0111";
//        case '8': return "1000";
//        case '9': return "1001";
//        case 'A': return "1010";
//        case 'B': return "1011";
//        case 'C': return "1100";
//        case 'D': return "1101";
//        case 'E': return "1110";
//        case 'F': return "1111";
//        }
//        return "0";
//    }
//
//    string convert_hex_into_binary(const string& number) {
//        string bin = "";
//        for (const auto& c : number) {
//            cout << "c = " << c << '\n';
//            bin += char_to_bin(c);
//        }
//        return bin;
//    }
//
//    void process_back_zero(vector<uint32>& number) { // xoa chu so 0 o dau 
//        while (!number.empty() && number.back() == 0) {
//            number.pop_back();
//        }
//        if (number.empty()) number = {0};
//    }
//
//public:
//    BigInt() : number({0}) {}
//    BigInt(const string& number) {
//        string binNumber = convert_hex_into_binary(number);
//        while (binNumber.size() % MAXBIT != 0) binNumber = '0' + binNumber;
//        for (int i = binNumber.size(); i >= 1; i -= MAXBIT) {
//            uint32 x = 1, val = 0;
//            //for (int j = i - MAXBIT + 1; j <= i; j++) cout << binNumber[j - 1]; cout << '\n';
//            for (int j = i; j > i - MAXBIT; j--) {
//                if (binNumber[j - 1] == '1') val += x;
//                x <<= 1;
//            }
//            this->number.emplace_back(val);
//        }
//        process_back_zero(this->number);
//        reverse(this->number.begin(), this->number.end());
//    }
//
//    BigInt(uint32 x) {
//        string binNumber = "";
//        while (x > 0) {
//            binNumber += x % 2 + '0';
//            x >>= 1;
//        }
//        reverse(binNumber.begin(), binNumber.end());
//        while (binNumber.size() % MAXBIT != 0) binNumber = '0' + binNumber;
//        //cout << binNumber << '\n';
//        for (int i = binNumber.size(); i >= 1; i -= MAXBIT) {
//            uint32 x = 1, val = 0;
//            //for (int j = i - MAXBIT + 1; j <= i; j++) cout << binNumber[j - 1]; cout << '\n';
//            for (int j = i; j > i - MAXBIT; j--) {
//                if (binNumber[j - 1] == '1') val += x;
//                x <<= 1;
//            }
//            this->number.emplace_back(val);
//        }
//        process_back_zero(this->number);
//        reverse(this->number.begin(), this->number.end());
//    }
//
//    BigInt(const vector<uint32>& otherNumber) {
//        this->number = otherNumber;
//    }
//
//    int get_size() const {
//        return this->number.size();
//    }
//
//    void pop_back() {
//        if (!this->number.empty()) this->number.pop_back();
//        if (this->number.empty()) this->number = {0};
//    }
//
//    uint32 back() {
//        return this->number.back();
//    }
//
//    const vector<uint32>& get_value() const {
//        return this->number;
//    }
//
//    const vector<uint32>& get_mod() const {
//        return this->numMod;
//    }
//
//    uint32 count_binary() const {
//        uint32 res = 0;
//        for (auto x : this->number) {
//            while (x > 0) {
//                res++;
//                x >>= 1;
//            }
//        }
//        return res;
//    }
//
//    friend ostream& operator << (ostream& os, const BigInt& number) {
//        vector <int> ans;
//        for (auto x : number.get_value()) {
//            //cout << "i = " << i << '\n';
//            while (x > 0) {
//                ans.push_back(x % 2);
//                x >>= 1;
//            }
//        }
//        for (auto i : ans) cout << i; cout << '\n';
//        reverse(ans.begin(), ans.end());
//        for (auto i : ans) cout << i; cout << '\n';
//        for (auto i : ans) os << i;
//        return os;
//    }
//
//    bool operator > (const BigInt& otherNumber) const {
//        int sizeNum1 = this->number.size();
//        int sizeNum2 = otherNumber.get_size();
//        if (sizeNum1 != sizeNum2) return sizeNum1 > sizeNum2;
//        for (int i = 0; i < sizeNum1; i++) {
//            if (this->number[i] != otherNumber[i]) 
//                return this->number[i] > otherNumber[i];
//        }
//        return false;
//    }
//
//    bool operator < (const BigInt& otherNumber) const {
//        return otherNumber > *this;
//    }
//
//    bool operator == (const BigInt& otherNumber) const {
//        return !(*this > otherNumber) && !(otherNumber > *this);
//    }
//
//    bool operator <= (const BigInt& otherNumber) const {
//        return otherNumber > *this || *this == otherNumber;
//    }
//
//    bool operator >= (const BigInt& otherNumber) const {
//        return *this > otherNumber || *this == otherNumber;
//    }
//
//    void operator = (const BigInt& otherNumber) {
//        this->number.clear();
//        for (const auto& val : otherNumber.get_value()) 
//            this->number.emplace_back(val);
//    }
//
//    uint32 operator[] (int index) const {
//        if (index < 0 || index >= get_size()) {
//            cerr << "Array index out of range\n";
//            exit(0);
//        }
//        return this->number[index];
//    }
//
//    BigInt& operator += (const BigInt& otherNumber) {
//        
//        vector <uint32> number1 = this->number;
//        
//        uint64 carry = 0;
//        uint64 j = otherNumber.get_size();
//        int i = number.size();
//        this->number.clear();
//        while (i > 0 || j > 0) {
//            uint64 digitNumber1 = i == 0 ? 0: number1[--i];
//            uint64 digitNumber2 = j == 0 ? 0: otherNumber[--j];
//
//            uint32 r = (digitNumber1 + digitNumber2 + carry) % BASE;
//            carry = (digitNumber1 + digitNumber2 + carry) / BASE; // phan nho 
//
//            this->number.emplace_back(r);
//        }
//
//        if (carry > 0) this->number.emplace_back(carry);
//        
//        process_back_zero(this->number);
//        reverse(this->number.begin(), this->number.end());
//
//        return *this;
//    }
//
//    BigInt operator + (const BigInt& otherNumber) const {
//        BigInt tmp = *this;
//        tmp += otherNumber;
//        return tmp;
//    }
//    
//    BigInt& operator ++ () {
//        *this += BigInt("1");
//        return *this;
//    }
//
//    BigInt& operator ++ (int) {
//        return ++ * this;
//    }
//
//    BigInt& operator -= (const BigInt& otherNumber) {
//        //for (auto i : this->number) cout << i << " "; cout << '\n';
//        //for (auto i : otherNumber.get_value()) cout << i << " "; cout << '\n';
//        vector <uint32> number1 = this->number;
//
//        uint64 carry = 0;
//        uint64 i = this->number.size();
//        uint64 j = otherNumber.get_size();
//        this->number.clear();
//        while (i > 0 || j > 0) {
//            long long digitNumber1 = i == 0 ? 0: number1[--i];
//            long long digitNumber2 = j == 0 ? 0: otherNumber[--j];
//      
//            long long r = (digitNumber1 - digitNumber2 + carry);
//            if (r < 0) {
//                carry = -1;
//                r += BASE;
//            }
//            else carry = 0;
//            
//            this->number.emplace_back(r);
//        }
//
//        if (carry < 0) {
//            cerr << "khong tru duoc khi number1 < number2";
//            exit(0);
//        }
//
//        process_back_zero(this->number);
//        reverse(this->number.begin(), this->number.end());
//        //for (auto i : this->number) cout << i << " "; cout << '\n';
//
//        return *this;
//
//    }
//
//    BigInt operator - (const BigInt& otherNumber) const {
//        BigInt tmp = *this;
//        tmp -= otherNumber;
//        return tmp;
//    }
//
//    BigInt& operator --() {
//        *this -= BigInt("1");
//        return *this;
//    }
//
//    BigInt& operator --(int) {
//        return -- *this;
//    }
//
//    BigInt& operator *= (const BigInt& otherNumber) {
//        vector <uint64> a, b;
//        for (auto& digit : this->number) a.emplace_back(digit);
//        for (auto& digit : otherNumber.get_value()) b.emplace_back(digit);
//        /*cout << "a = "; for (int i = 0; i < a.size(); i++) cout << a[i] << " "; cout << '\n';
//        cout << "b = "; for (int i = 0; i < b.size(); i++) cout << b[i] << " "; cout << '\n';*/
//        const std::vector<uint64>& result = FFT::MULTIPLY(a, b);
//        //for (int i = 0; i < result.size(); i++) cout << result[i] << " "; cout << '\n';
//        uint64 carry = 0;
//        this->number.clear();
//        for (int i = (int)result.size() - 1; i >= 0; i--) {
//            int r = (result[i] + carry) % BASE;
//            carry = (result[i] + carry) / BASE;
//
//            this->number.emplace_back(r);
//        }
//
//        while (carry > 0) {
//            int r = carry % BASE;
//            this->number.emplace_back(r);
//            carry /= BASE;
//        }
//
//        process_back_zero(this->number);
//        reverse(this->number.begin(), this->number.end());
//
//        return *this;
//    }
//
//    BigInt operator * (const BigInt& otherNumber) const {
//        BigInt tmp = *this;
//        tmp *= otherNumber;
//        return tmp;
//    }
//
//    //BigInt& shiftRight(int x) {
//    //    while (x--) {
//    //        if (!this->number.empty()) this->number.pop_back();
//    //    }
//    //    if (this->number.empty()) this->number = { '0' };
//    //    return *this;
//
//    //}
//
//    //BigInt& shiftLeft(int x) {
//    //    while (x--) this->number.emplace_back('0');
//    //    return *this;
//    //}
//
//    BigInt& operator /= (const BigInt& numDiv) {
//        vector <uint32> tmp = this->number;
//                
//        this->number.clear();
//        vector <uint32> numMod;
//        for (const auto& digit : tmp) {
//            if (numMod.empty() && digit == 0) continue;
//        
//            numMod.push_back(digit);
//            if (BigInt(numMod) < numDiv) {
//                this->number.emplace_back(0);
//                continue;
//            }
//            int c = 0;
//            BigInt tmp_numMod(numMod);
//            for (int L = 0, R = BASE - 1; L <= R; ) {
//                int mid = (L + R) >> 1;
//
//                if (tmp_numMod >= numDiv * BigInt(mid)) {
//                    c = mid;
//                    L = mid + 1;
//                }
//                else {
//                    R = mid - 1;
//                }
//            }
//            tmp_numMod -= numDiv * BigInt(c);
//            numMod = tmp_numMod.get_value();
//            this->number.emplace_back(c);
//        }
//        this->numMod = numMod;
//        process_back_zero(this->number);
//        return *this;
//    }
//
//    BigInt operator / (const BigInt& otherNumber) const {
//        BigInt tmp = *this;
//        tmp /= otherNumber;
//        return tmp;
//    }
//
//    BigInt& operator %= (const BigInt& numDiv) {
//        *this /= numDiv;
//        this->number = this->numMod;
//        return *this;
//    }
//
//    BigInt operator % (const BigInt& numMod) const {
//        BigInt tmp = *this;
//        tmp %= numMod;
//        return BigInt(tmp.get_mod());
//    }
//
//    bool is_odd() const {
//        return (this->number.back()) & 1;
//    }
//
//    BigInt& power(BigInt exp, const BigInt& m) {
//        BigInt a = *this;
//        this->number = { '1' };
//        cout << exp << '\n';
//        cout << exp / BigInt(2) << '\n';
//        while (exp > BigInt(0)) {
//            //cout << exp << '\n';
//            if (exp.is_odd()) (*this *= a) %= m;
//            (a *= a) %= m;
//            
//            exp /= BigInt(2);
//        }
//        return *this;
//    }
//
//};
////
////bool test(BigInt a, const int& k, const BigInt& m, const BigInt& n) {
////    BigInt tmp = n;
////    --tmp;
////    BigInt pw = a.power(m % tmp, n);
////    if (pw == BigInt("1") || pw == tmp) return true;
////    for (int l = 1; l < k; l++) {
////        (pw *= pw) %= n;
////        if (pw == tmp) return true;
////    }
////    return false;
////}
//
////bool miller_rabin(const BigInt& n) {
////    if (n < BigInt("2")) return false;
////    if (n == BigInt("2")) return true;
////    if (!n.is_odd()) return false;
////    
////    int k = 0;
////    BigInt m = n;
////    --m;
////    while (m.is_odd()) {
////        m.shiftRight(1);
////        k++;
////    }
////
////    for (auto a : { "2", "3", "5", "7", "B", "D", "11", "13", "17", "1D", "1F", "25", "29", "2B", "2F", "35" }) {//}, "3B", "3D", "43", "47", "49", "4F", "53", "59", "61"}) {
////        if (n == BigInt(a)) return true;
////        if (!test(BigInt(a), k, m, n)) return false;
////    }
////    return true;
////}
