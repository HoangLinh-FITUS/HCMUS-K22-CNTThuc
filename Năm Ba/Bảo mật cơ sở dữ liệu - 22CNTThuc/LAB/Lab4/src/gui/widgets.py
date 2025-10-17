import pyodbc
import constants
import crypto.rsa
import crypto.sha1

conn = pyodbc.connect(f'''
    DRIVER={constants.CONFIG_DATABASE['DRIVER']};
    SERVER={constants.CONFIG_DATABASE['SERVER']};
    DATABASE={constants.CONFIG_DATABASE['DATABASE']}; 
    Trusted_Connection=yes;
    TrustServerCertificate=yes;             
''')

cursor = conn.cursor()
nhanvien = crypto.rsa.Cipher(constants.RSA_BITS)

def sign_in_account(manv: str, hoten: str, email: str, luong: int, tendn: str, mk: str):
 
    # encryption MK
    mk_encrypted = crypto.sha1.cipher(mk).encode()

    # create key pair RSA
    # nhanvien = crypto.rsa.Cipher(constants.RSA_BITS)
    private_key = nhanvien.get_private_key()
    public_key = nhanvien.get_public_key()

    # encryption MK
    luong_encrypted = nhanvien.encrypted(public_key, str(luong))

    # write key.pem containt private_key
    with open(f'keys/{manv}.pem', 'wb') as f:
        data = nhanvien.export_key(mk)
        f.write(data)
    
    # commit database
    PUB = public_key.export_key() # bytes 
    cursor.execute("SP_INS_PUBLIC_ENCRYPT_NHANVIEN ?, ?, ?, ?, ?, ?, ? ", 
                   manv, hoten, email, pyodbc.Binary(luong_encrypted), tendn, pyodbc.Binary(mk_encrypted), pyodbc.Binary(PUB))
    cursor.commit()

def login_account(TENDN: str, MK: str):

    mk_encrypted = crypto.sha1.cipher(MK).encode()
    
    cursor.execute('EXEC SP_SEL_PUBLIC_ENCRYPT_NHANVIEN ?, ?',TENDN, pyodbc.Binary(mk_encrypted))

    table = cursor.fetchall()

    if table == []:
        return False # login that bai

    constants.username = TENDN
    constants.password = MK 
    constants.manv = table[0].MANV
    return True 

def infor_account():

    mk_encrypted = crypto.sha1.cipher(constants.password).encode()
    cursor.execute('EXEC SP_SEL_PUBLIC_ENCRYPT_NHANVIEN ?, ?', constants.username, pyodbc.Binary(mk_encrypted))
    
    res = cursor.fetchall()
    
    luong_encrypted = res[0].LUONG

    nhanvien = crypto.rsa.Cipher(constants.RSA_BITS)
    with open(f'keys/{res[0].MANV}.pem') as f:
        private_key = f.read()
        nhanvien.import_key(private_key, constants.password)

    luong_decrypted = nhanvien.decrypted(nhanvien.get_private_key(), luong_encrypted)

    cursor.execute(f"SELECT * FROM NHANVIEN WHERE TENDN = '{constants.username}'")

    res = cursor.fetchall()
    
    return luong_decrypted, res[0]

def table_lophoc():

    cursor.execute('SELECT * FROM LOP')
    return cursor.fetchall()    

def table_lophoc_nhanvien():

    cursor.execute(f"SELECT * FROM LOP WHERE MANV = '{constants.manv}'")
    return cursor.fetchall()

def table_sinhvien(malop):
    
    cursor.execute(f"select * from sinhvien where malop = '{malop}'")
    return cursor.fetchall()

def table_nhanvien():
    
    cursor.execute(f"select * from nhanvien")
    return cursor.fetchall()

def update_bangdiem(masv, mahp, diem, manv):

    # nhanvien = crypto.rsa.Cipher(constants.RSA_BITS)

    cursor.execute('select PUBKEY from nhanvien where manv = ?', manv)
    PUB = cursor.fetchone()[0]
    nhanvien.import_key(PUB)
    diem_encrypted = nhanvien.encrypted(nhanvien.get_public_key(), str(diem))

    print('update MASV = {}, MAHP = {}, DIEM = {}'.format(masv, mahp, diem))

    cursor.execute('execute SP_UPDATE_DIEM ?, ?, ?, ?',masv, mahp, diem_encrypted, manv) # pydboc.Binary(diem_encrypted) can than ??? 
    conn.commit()

def table_sinhvien_hocphan(masv):
    cursor.execute("SP_SEL_DIEM ?", masv)
    
    # nhanvien = crypto.rsa.Cipher(constants.RSA_BITS)
    with open(f'keys/{constants.manv}.pem', 'rb') as f:
        nhanvien.import_key(f.read(), constants.password)
    
    private_key = nhanvien.get_private_key()

    res = []
    for val_row in cursor.fetchall():
        diemthi_decrypted = None
        if val_row.DIEMTHI is not None: 
            print('diem ma hoa: {}'.format(val_row.DIEMTHI))
            diemthi_decrypted = nhanvien.decrypted(private_key, val_row.DIEMTHI)
            print('diem da giai ma: {}'.format(diemthi_decrypted))
            
        res.append({
            'MASV': val_row.MASV,
            'MAHP': val_row.MAHP,
            'TENHP': val_row.TENHP,
            'SOTC': val_row.SOTC,
            'DIEMTHI': diemthi_decrypted
        })

    return res

def update_info_sinhvien(masv, hoten, diachi):
    print("update information sinhvien: {} {} {}".format(masv, hoten, diachi))
    cursor.execute(f"update sinhvien set hoten = ?, diachi = ? where masv = ?", hoten, diachi, masv)
    conn.commit()

if __name__ == '__main__':    
    pass

    # for row in table_sinhvien_hocphan('sv001', 'NV01', '1231'):
    #     print(row)

    # sign_in_account(manv = 'NV01', hoten='Nguyen Van Mot', email= 'vanmot@gmail.com', luong = 2000, tendn='user1', mk = '1231')
    # sign_in_account(manv = 'NV02', hoten='Nguyen Van Hai', email= 'vanhai@gmail.com', luong = 3000, tendn='user2', mk = '1232')
    # sign_in_account(manv = 'NV03', hoten='Nguyen Van Ba', email= 'vanba@gmail.com', luong = 4000, tendn='user3', mk = '1233')

    # LUONG = 2000 
    # nhanvien = crypto.rsa.Cipher(2048)
    # with open('keys/NV01_public.pem', 'rb') as f:
    #     nhanvien.import_key(f.read())
    
    # luong_encrypted = nhanvien.encrypted(nhanvien.get_public_key(), str(LUONG))
    # print(luong_encrypted)
    # with open('keys/NV01_private.pem', 'rb') as f:
    #     nhanvien.import_key(f.read(), '1231')

    # luong_decrypted = nhanvien.decrypted(nhanvien.get_private_key(), luong_encrypted)
    # print(luong_decrypted)

    update_bangdiem('SV001', 'HP001', diem='12', manv = 'NV01')
    print(table_sinhvien_hocphan('SV001'))
