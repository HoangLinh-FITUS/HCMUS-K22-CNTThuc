from PyQt6.QtWidgets import (
    QApplication,
    QLabel,
    QTableWidget,
    QTableWidgetItem,
    QPushButton, 
    QComboBox,
    QMainWindow,
    QWidget,
    QMenu,
    QAbstractItemView  
)

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

import sys 
import constants
import widgets
import datetime
import infor_account, nhapdiem, quanly_nhanvien


class QLLopHoc(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setMinimumSize(constants.WINDOW_WIDTH_QLLOPHOC, constants.WINDOW_HEIGHT_QLLOPHOC)
        self.setWindowTitle("Main Window")
        menu = self.menuBar()
        home = menu.addMenu("Home")
        
        tk = home.addAction("Tài Khoản")
        nhanviens = home.addAction("Danh Sách Nhân Viên")

        tk.triggered.connect(self.move_window_inforaccount)
        nhanviens.triggered.connect(self.move_window_quanlynhanvien)

        self.create_title()
        self.create_button_nhapdiem()
        self.create_combobox_quanly()
        self.create_table_lophoc()
        self.create_table_sinhvien()

    def create_title(self):
        self.label_title = QLabel("Quản Lý Lớp Học", self)
        self.label_title.setGeometry(10, 30, 1191, 111)
        self.label_title.setFont(QFont("Times New Roman", 36))
        self.label_title.setAlignment(Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignVCenter)
        
    def create_button_nhapdiem(self):
        self.btn_nhapdiem = QPushButton("Nhập Điểm", self)
        self.btn_nhapdiem.setGeometry(30, 180, 111, 23)
        self.btn_nhapdiem.setFont(QFont("Times New Roman", 9))
        self.btn_nhapdiem.clicked.connect(self.move_window_nhapdiem)


    def create_combobox_quanly(self):
        self.combobox_quanly = QComboBox(self)
        self.combobox_quanly.addItems(["Tất Cả", "Lớp Quản Lý"])
        self.combobox_quanly.setGeometry(160, 180, 231, 22)
        self.combobox_quanly.activated.connect(self.combobox_to_show)

    def combobox_to_show(self):
        if self.combobox_quanly.currentText() == "Tất Cả":
            self.show_all_lophoc()
        else:
            self.show_all_lop_nhanvien()
            

    def create_table_lophoc(self):
        self.table_lophoc = QTableWidget(self)
        self.table_lophoc.setGeometry(30, 210, 361, 561)
        self.table_lophoc.setFont(QFont("Times New Roman", 9))
        self.table_lophoc.setColumnCount(len(constants.QUANLYLOPHOC_NAME_COLUMN_LOPHOC))
        self.table_lophoc.setHorizontalHeaderLabels(constants.QUANLYLOPHOC_NAME_COLUMN_LOPHOC)
        
        self.table_lophoc.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self.table_lophoc.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.table_lophoc.itemSelectionChanged.connect(self.on_item_table_lophoc)

        self.show_all_lophoc()

    def on_item_table_lophoc(self):
        print(self.combobox_quanly.currentText())
        row = self.table_lophoc.currentRow()
        
        if self.table_lophoc.item(row, 0):
            self.show_all_sinhvien(self.table_lophoc.item(row, 0).text())

        if self.combobox_quanly.currentText() != 'Tất Cả':
            item_malop = self.table_lophoc.item(row, 0) 
            item_tenlop = self.table_lophoc.item(row, 1)
            if item_malop and item_tenlop:
                return item_malop.text(), item_tenlop.text()
            
        return (0, 0)    

    def show_all_lophoc(self):
        self.table_lophoc.setRowCount(0)
        content_table_lophoc = widgets.table_lophoc()
        self.table_lophoc.setRowCount(len(content_table_lophoc))
        for id_row, (malop, tenlop, manv) in enumerate(content_table_lophoc):
            self.table_lophoc.setItem(id_row, 0, QTableWidgetItem(malop))
            self.table_lophoc.setItem(id_row, 1, QTableWidgetItem(tenlop))
            self.table_lophoc.setItem(id_row, 2, QTableWidgetItem(manv))
    
    def show_all_lop_nhanvien(self):
        self.table_lophoc.setRowCount(0)
        content_table_lophoc = widgets.table_lophoc_nhanvien()
        self.table_lophoc.setRowCount(len(content_table_lophoc))

        for id_row, (malop, tenlop, manv) in enumerate(content_table_lophoc):
            self.table_lophoc.setItem(id_row, 0, QTableWidgetItem(malop))
            self.table_lophoc.setItem(id_row, 1, QTableWidgetItem(tenlop))
            self.table_lophoc.setItem(id_row, 2, QTableWidgetItem(manv))

    def create_table_sinhvien(self):
        self.table_sinhvien = QTableWidget(self)
        self.table_sinhvien.setGeometry(435, 211, 771, 561)
        self.table_sinhvien.setFont(QFont("Times New Roman", 9))
        self.table_sinhvien.setColumnCount(len(constants.QUANLYLOPHOC_NAME_COLUMN_SINHVIEN))
        self.table_sinhvien.setHorizontalHeaderLabels(constants.QUANLYLOPHOC_NAME_COLUMN_SINHVIEN)
        self.table_sinhvien.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)

    def setNoEdit(self, val_col):
        item = QTableWidgetItem(val_col)
        item.setFlags(Qt.ItemFlag.ItemIsSelectable | Qt.ItemFlag.ItemIsEnabled)
        return item
    
    def show_all_sinhvien(self, malop):
        self.table_sinhvien.setRowCount(0)
        content_table_sinhvien = widgets.table_sinhvien(malop)
        self.table_sinhvien.setRowCount(len(content_table_sinhvien))

        if self.combobox_quanly.currentText() != 'Tất Cả':
            self.table_sinhvien.setEditTriggers(QAbstractItemView.EditTrigger.AllEditTriggers)
        
        for id_row, val_row in enumerate(content_table_sinhvien):
            for id_col, val_col in enumerate(val_row):
                if id_col == 6: val_col = '****'

                if id_col in [1, 3]:
                    self.table_sinhvien.setItem(id_row, id_col, QTableWidgetItem(str(val_col)))
                else:
                    self.table_sinhvien.setItem(id_row, id_col, self.setNoEdit(str(val_col)))
        
        self.table_sinhvien.cellChanged.connect(self.edit_info)

    def edit_info(self):
        row = self.table_sinhvien.currentRow()
        if row >= 0:
            print("update row infor student: {}".format(row))
            item_masv = self.table_sinhvien.item(row, 0)
            item_hoten = self.table_sinhvien.item(row, 1)
            item_diachi = self.table_sinhvien.item(row, 3)
            widgets.update_info_sinhvien(item_masv.text(), item_hoten.text(), item_diachi.text())

    def move_window_inforaccount(self):
        self.window = infor_account.InforAccount()
        self.window.show()

    def move_window_quanlynhanvien(self):
        self.window = quanly_nhanvien.QuanlyNhanVien()
        self.window.show()

    def move_window_nhapdiem(self):
        malop, tenlop = self.on_item_table_lophoc()

        if malop != 0 and tenlop != 0:
            self.window = nhapdiem.NhapDiem(malop)
            self.window.show()


if __name__ == '__main__':
    app = QApplication(sys.argv)

    window = QLLopHoc()
    window.show()

    sys.exit(app.exec())