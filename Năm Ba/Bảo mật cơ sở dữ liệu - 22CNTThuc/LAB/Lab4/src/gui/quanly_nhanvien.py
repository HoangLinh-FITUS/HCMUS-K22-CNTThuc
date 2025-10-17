from PyQt6.QtWidgets import (
    QApplication,
    QLabel,
    QTableWidget,
    QTableWidgetItem,
    QPushButton, 
    QComboBox,
    QMainWindow,
    QWidget,
    QLineEdit
)

import widgets

from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

import sys, constants


class QuanlyNhanVien(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setMinimumSize(constants.WINDOW_WIDTH_QLLOPHOC, constants.WINDOW_HEIGHT_QLLOPHOC)
        self.setWindowTitle("Quản Lý Nhân Viên")
        
        self.create_table()
        self.create_title()

    def create_title(self):
        self.label_title = QLabel("Quản Lý Nhân Viên", self)
        self.label_title.setGeometry(10, 30, 1191, 111)
        self.label_title.setFont(QFont("Times New Roman", 36))
        self.label_title.setAlignment(Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignVCenter)

    def create_table(self):
        self.table_nhanvien = QTableWidget(self)
        self.table_nhanvien.setGeometry(10, 211, 771 + 300, 561)
        self.table_nhanvien.setFont(QFont("Times New Roman", 9))
        self.table_nhanvien.setColumnCount(len(constants.NHANVIEN_COLUMN))
        self.table_nhanvien.setHorizontalHeaderLabels(constants.NHANVIEN_COLUMN)

        self.show_all_nhanvien()

    def show_all_nhanvien(self):
        self.table_nhanvien.setRowCount(0)
        content_table_nhanvien = widgets.table_nhanvien()
        self.table_nhanvien.setRowCount(len(content_table_nhanvien))

        for id_row, value in enumerate(content_table_nhanvien):
            for i in range(len(constants.NHANVIEN_COLUMN)):
                self.table_nhanvien.setItem(id_row, i, QTableWidgetItem(str(value[i])))
            # exit(0)

    


if __name__ == '__main__':
    app = QApplication(sys.argv)

    window = QuanlyNhanVien()
    window.show()

    sys.exit(app.exec())