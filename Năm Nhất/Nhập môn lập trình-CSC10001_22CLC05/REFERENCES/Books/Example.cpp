#include <fstream>
#include <iostream>
using namespace std;
#define MAX 40
#define MAXLEN 80
#define INPUT_FILE_NAME "d:/Test/List02.txt"
#define OUTPUT_FILE_NAME "d:/Test/List.txt"
typedef struct STUDENT {
	char Id[9];
	char Name[40];
	float Score;
} ;
typedef struct STUDENT_LIST {
	int Num;
	STUDENT s[MAX];
} ;
void ReadList( STUDENT_LIST &sl, char * filename) {
	ifstream fin( filename );
	int k = 0;
	while (! fin.eof()) {
		fin >> sl.s[k].Id >> sl.s[k].Name >> sl.s[k].Score; 
		k++;
	}
	sl.Num = k;
	fin.close();
}
void ReadList2 ( STUDENT_LIST &sl, char * filename) {
	ifstream fin( filename );
	int k = 0;
	char str[MAXLEN];
	while (! fin.eof()) {
		fin.getline(str, MAXLEN-1);
		char * s = strtok(str,"<>");
		strcpy (sl.s[k].Id, s);
		s =  strtok(NULL,"<>");
		strcpy (sl.s[k].Name, s);
		s =  strtok(NULL,"<>");
		sl.s[k].Score = atoi(s); 
		k++;
	}
	sl.Num = k;
	fin.close();
}
void PrintList( STUDENT_LIST sl) {
	
	for (int i = 0; i < sl.Num; i++)
		cout << sl.s[i].Id << " " << sl.s[i].Name << " " << sl.s[i].Score << endl; 
}
int main () {
	STUDENT_LIST a;
	ReadList2(a, INPUT_FILE_NAME);
	PrintList(a);
}


//#include <iostream>
////#include <fstream>
//using namespace std;
//#define MAX 40
//typedef struct PHANSO {
//	int tu;
//	int mau;
//} ;
//void XuatPhanSo( PHANSO p) {
//	cout <<p.tu<<"/"<<p.mau;
//}
//void XuatDayPhanSo( PHANSO a[], int n) {
//	for (int i=0; i<n; i++) {
//		XuatPhanSo(a[i]);
//		cout <<" , ";
//	}
//}
//int main () {
//	PHANSO a [] = { {1,2}, {3,7}, {5,4}, {11,2019} };
//	int n = sizeof(a) / sizeof(PHANSO);
//	 XuatDayPhanSo( a, n);
//}





//int main() {
//   int a = 2019, b = 11;
//float f = 2019.11;
//char s[80] = "Testing Text File # ";
//ofstream fout;
//fout.open ("D:\\test\\Example.txt"); if (!fout) return 1;
//fout. << s << endl << "2019  11.2019  11 \n" 
//	<<  ++a << "  " << --f << "   "<<  --b ;
//fout.close();
//ifstream fin ("D:/test/Example.txt");  if (!fin) return 1;
//fin.getline(s, 80);
//fin >> a >> f  >> b;
//cout << s << a << '*'<< b << " * " << f << endl;
//fin >> a >> b  >> s[2] >> f;
//cout << s << a << " * " << b <<  " * " << f << endl;
//fin.close();
//fin.
//    return 0;
//}

//#include <iostream.h>
//using namespace std;
//
//bool checkPrimeNumber (int N) {
//   for (int i = 2; i <= N/2; i++)
//       if (N % i == 0) {
//		   cout << N << "ko phai so nguyen to";
//		   return false;
//	   }
//    cout << N << "la so nguyen to";
//	return true;
//}   //Note: No use input /output functions (cin /cout /...)
//
//int main() { 
//	cout << "All of Prime number in [2..2019] : " ;
//	for (int i = 2; i <= 123456789; ++i)
//        if (checkPrimeNumber ( i ) == true)
//	cout << i << "  ";
//    return 0; 
//}






//using namespace std;
//int mul_10(int N) {
//	__asm { // start ASM code 	
//		mov eax, N
//		shl eax, 1		; EAX = N*2
//		mov ebx, eax
//		shl eax, 2		; EAX = N*8
//		add eax, ebx	; EAX = N*10
//	}  // end of ASM code
//}  // return with result in EAX
//int div_10(int N) { return N/10; } 
//int mul_10_N_times_byASM(int num, int n) {
//	__asm { // start ASM code 	
//		mov ecx, n
//		mov eax, num
//Repeat_N:
//		shl eax, 1		
//		mov ebx, eax
//		shl eax, 2		
//		add eax, ebx
//		loop Repeat_N		
//	}  // end of ASM code	
//}
//short int count_bits(int n) {
//__asm {
//	mov ax, 0 ; AX chua ket qua
//	mov ebx, n	
//	mov ecx, 32
//Repeat:
//	shr ebx, 1
//	jnc Cont1
//	inc ax
//Cont1:
//	loop Repeat
//	/*dec ecx
//	cmp ecx, 0
//	jne Repeat*/
//}	
//}
//char convert (char c) {
//__asm {
//	mov al, c
//KiemTraChuThuong:
//	cmp al, 'a'
//	jb  KiemTraChuHoa
//	cmp al, 'z'
//	ja  KiemTraChuHoa
//	add al, 'A'-'a' ; doi chu cai thuong trong AL thanh chu hoa
//	jmp KetThuc
//KiemTraChuHoa:
//	cmp al, 'A'
//	jb  KiemTraChuSo
//	cmp al, 'Z'
//	ja  KiemTraChuSo
//	add al, 'a'-'A' ; doi chu cai hoa trong AL thanh chu thuong
//	jmp KetThuc
//KiemTraChuSo:
//	cmp al, '0'
//	jb  KetThuc
//	cmp al, '9'
//	ja  KetThuc
//	sub al, 10 + 2*'0'
//	neg al
//KetThuc:
//}
//}
//int main() {
//	cout << convert('y') << endl ;
//	cout << convert('B') << endl ;
//	cout << convert('3') << endl ;
//
////	int Num = 2019, n ;
////	cout << Num << "*10 = " << mul_10(Num) << endl
////		 << "Number of bit_1 in " << Num << " = " << count_bits(Num) << endl;
////__asm { // start ASM code 	
////	push Num // push Num to the Stack
////    call div_10 // EAX = Num/10
////	pop ebx
////	mov n, eax
////} // end of ASM code
////	cout << Num << "/10 = " << n << endl ;	
//}



















//#define PI 3.14
//float absolute(float x); 
//float getNumber(){ 
//	float num;
//	std::cout << "Enter a number (0 to stop): "; std::cin >> num;
//	return num;
//} 
//void main(){ 
//	float a = getNumber(), min = a;     
//	while (a!=0){         
//		a = getNumber(); 
//      	if (absolute(a-PI) < absolute(min-PI)) 
//		   min = a; 
//	}
//	std::cout << "The nearest value to PI is " << min;
//} 
//float absolute(float x) {
//    /*if (x >= 0)	
//		cout << "Gia tri tuyet doi la "<< x << endl; 
//    else 	cout<< "Gia tri tuyet doi la "<< -x << endl;*/ 
//	return x>=0?x:-x;
//} 