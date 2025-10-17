import pyodbc
import constants

conn = pyodbc.connect(f'''
    DRIVER={constants.CONFIG_DATABASE['DRIVER']};
    SERVER={constants.CONFIG_DATABASE['SERVER']};
    DATABASE={constants.CONFIG_DATABASE['DATABASE']}; 
    Trusted_Connection=yes;
    TrustServerCertificate=yes;             
''')

cursor = conn.cursor()


def login_account(TENDN: str, MK: str):

    cursor.execute(f"EXEC SP_SEL_PUBLIC_NHANVIEN '{TENDN}', '{MK}'")

    table = cursor.fetchall()

    if table == []:
        return False # login that bai

    constants.username = TENDN
    constants.password = MK 
    constants.manv = table[0].MANV
    return True 


def infor_account():

    cursor.execute(f"EXEC SP_SEL_PUBLIC_NHANVIEN '{constants.username}', '{constants.password}'")
    res = cursor.fetchall()
    LUONGCB = res[0].LUONGCB

    cursor.execute(f"SELECT * FROM NHANVIEN WHERE TENDN = '{constants.username}'")

    res = cursor.fetchall()
    
    return LUONGCB, res[0]

def table_lophoc():

    cursor.execute('SELECT * FROM LOP')
    return cursor.fetchall()    

def table_lophoc_nhanvien():

    cursor.execute(f"SELECT * FROM LOP WHERE MANV = '{constants.manv}'")
    return cursor.fetchall()

def table_sinhvien(malop):
    
    cursor.execute(f"select * from sinhvien where malop = '{malop}'")
    return cursor.fetchall()

# def table_sinhvien_hocphan(masv):
#     cursor.execute(f'''
#         SELECT BANGDIEM.MASV, BANGDIEM.MAHP, HOCPHAN.TENHP, HOCPHAN.SOTC, DIEMTHI 
#         FROM 
#             SINHVIEN JOIN BANGDIEM ON SINHVIEN.MASV = BANGDIEM.MASV
#             JOIN HOCPHAN ON HOCPHAN.MAHP = BANGDIEM.MAHP
#         where SINHVIEN.MASV = '{masv}'
#     ''')
#     return cursor.fetchall()

def update_bangdiem(masv, mahp, diem, manv):

    cursor.execute(f"execute SP_UPDATE_DIEM '{masv}', '{mahp}', {diem}, '{manv}' ")
    conn.commit()

def table_sinhvien_hocphan(masv, manv, mk):
    cursor.execute(f"SP_SEL_DIEM '{masv}', '{manv}', '{mk}'")
    return cursor.fetchall()

def update_info_sinhvien(masv, hoten, diachi):
    print("update: {} {} {}".format(masv, hoten, diachi))
    cursor.execute(f"update sinhvien set hoten = ?, diachi = ? where masv = ?", hoten, diachi, masv)
    conn.commit()

if __name__ == '__main__':    
    for row in table_sinhvien_hocphan('sv001', 'NV01', '1231'):
        print(row)