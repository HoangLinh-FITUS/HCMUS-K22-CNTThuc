from PyQt6.QtWidgets import (
    QApplication,
    QLabel,
    QTableWidget,
    QTableWidgetItem,
    QPushButton, 
    QComboBox,
    QMainWindow,
    QWidget,
    QAbstractItemView
)

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

import widgets
import constants
import sys 


class NhapDiem(QMainWindow):

    malop = ""
    
    def __init__(self, malop):
        super().__init__()

        self.setMinimumSize(constants.WINDOW_WIDTH_QLLOPHOC, constants.WINDOW_HEIGHT_QLLOPHOC)
        self.setWindowTitle("Nhap Diem")

        self.malop = malop

        self.create_title()
        self.create_table_sinhvien_lophoc()
        self.create_table_sinhvien_hocphan()
        

    def create_title(self):
        self.label_title = QLabel(f"Nhập Điểm Lớp {self.malop}", self)
        self.label_title.setGeometry(10, 30, 1191, 111)
        self.label_title.setFont(QFont("Times New Roman", 36))
        self.label_title.setAlignment(Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignVCenter)
        

    def create_table_sinhvien_lophoc(self):
        self.table_sinhvien_lophoc = QTableWidget(self)
        self.table_sinhvien_lophoc.setGeometry(30, 210, 471, 561)
        self.table_sinhvien_lophoc.setFont(QFont("Times New Roman", 9))
        self.table_sinhvien_lophoc.setColumnCount(len(constants.NHAPDIEM_NAME_COLUMN_SINHVIEN_LOPHOC))
        self.table_sinhvien_lophoc.setHorizontalHeaderLabels(constants.NHAPDIEM_NAME_COLUMN_SINHVIEN_LOPHOC)
        self.table_sinhvien_lophoc.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.table_sinhvien_lophoc.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)

        self.table_sinhvien_lophoc.itemSelectionChanged.connect(self.on_selected_sinhvien)
        
        content_table_sinhvien_lophoc = widgets.table_sinhvien(self.malop)
        self.table_sinhvien_lophoc.setRowCount(len(content_table_sinhvien_lophoc))

        for id_row, val_row in enumerate(content_table_sinhvien_lophoc):
            self.table_sinhvien_lophoc.setItem(id_row, 0, QTableWidgetItem(val_row.MASV))
            self.table_sinhvien_lophoc.setItem(id_row, 1, QTableWidgetItem(val_row.HOTEN))
            self.table_sinhvien_lophoc.setItem(id_row, 2, QTableWidgetItem(val_row.MALOP))
            self.table_sinhvien_lophoc.setItem(id_row, 3, QTableWidgetItem(constants.manv))

    def on_selected_sinhvien(self):
        row = self.table_sinhvien_lophoc.currentRow()
        
        if self.table_sinhvien_lophoc.item(row, 0):
            item_masv = self.table_sinhvien_lophoc.item(row, 0).text()
            self.show_bangdiem_sinhvien(item_masv)

    def create_table_sinhvien_hocphan(self):
        self.table_sinhvien_hocphan = QTableWidget(self)
        self.table_sinhvien_hocphan.setGeometry(530, 210, 621, 561)
        self.table_sinhvien_hocphan.setFont(QFont("Times New Roman", 9))
        self.table_sinhvien_hocphan.setColumnCount(len(constants.NHAPDIEM_NAME_COLUM_SINHVIEN_HOCPHAN))
        self.table_sinhvien_hocphan.setHorizontalHeaderLabels(constants.NHAPDIEM_NAME_COLUM_SINHVIEN_HOCPHAN)
    
        self.table_sinhvien_hocphan.cellChanged.connect(self.edit_diem)
    
    def edit_diem(self):
        row = self.table_sinhvien_hocphan.currentRow()
        if row >= 0:
            print("update row: {}".format(row))
            item_masv = self.table_sinhvien_hocphan.item(row, 0)
            item_mahp = self.table_sinhvien_hocphan.item(row, 1)
            item_diem = self.table_sinhvien_hocphan.item(row, 4)
            if item_masv and item_mahp and item_diem:
                widgets.update_bangdiem(item_masv.text(), item_mahp.text(), item_diem.text(), constants.manv)
            

    def setNoEdit(self, val_col):
        item = QTableWidgetItem(val_col)
        item.setFlags(Qt.ItemFlag.ItemIsSelectable | Qt.ItemFlag.ItemIsEnabled)
        return item

    def show_bangdiem_sinhvien(self, masv):
        self.table_sinhvien_hocphan.setRowCount(0)
        content_table_sinhvien_hocphan = widgets.table_sinhvien_hocphan(masv, constants.manv, constants.password)
        self.table_sinhvien_hocphan.setRowCount(len(content_table_sinhvien_hocphan))

        for id_row, val_row in enumerate(content_table_sinhvien_hocphan):

            self.table_sinhvien_hocphan.setItem(id_row, 0, self.setNoEdit(val_row.MASV))
            self.table_sinhvien_hocphan.setItem(id_row, 1, self.setNoEdit(val_row.MAHP))
            self.table_sinhvien_hocphan.setItem(id_row, 2, self.setNoEdit(val_row.TENHP))
            self.table_sinhvien_hocphan.setItem(id_row, 3, self.setNoEdit(str(val_row.SOTC)))

            diemthi = str(val_row.DIEMTHI)
            if diemthi == 'None': diemthi = ''
    
            self.table_sinhvien_hocphan.setItem(id_row, 4, QTableWidgetItem(diemthi))



if __name__ == '__main__':
    app = QApplication(sys.argv)

    window = NhapDiem("LOP01")
    window.show()

    sys.exit(app.exec())