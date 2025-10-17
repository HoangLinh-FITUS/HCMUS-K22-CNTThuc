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


class InforAccount(QMainWindow):

    def __init__(self):
        super().__init__()

        self.setMinimumSize(constants.WINDOW_WIDTH_INFOR_ACCOUNT, constants.WINDOW_HEIGHT_INFOR_ACCOUNT)
        self.setWindowTitle("Tài Khoản")
        
        self.create_title()
        self.create_information()

    def create_title(self):
        self.label_title = QLabel("Thông Tin Tài Khoản", self)
        self.label_title.setGeometry(10, 10, 661, 111)
        self.label_title.setFont(QFont("Times New Roman", 36))
        self.label_title.setAlignment(Qt.AlignmentFlag.AlignHCenter | Qt.AlignmentFlag.AlignVCenter)
        
    def create_information(self):
        luong_cb, content_db = widgets.infor_account()
     
        infor = [
            ("MANV", (31, 170, 69, 24), (132, 172, 133, 20), content_db.MANV), 
            ("EMAIL", (31, 219, 76, 24), (132, 221, 133, 20), content_db.EMAIL), 
            ("LUONG", (31, 268, 83, 24), (132, 270, 133, 20), luong_cb), 
            ("PUBKEY", (31, 317, 95, 24), (132, 319, 133, 20), content_db.PUBKEY), 
            ("HOTEN", (319, 170, 81, 24), (440, 172, 133, 20), content_db.HOTEN), 
            ("TENDN", (319, 219, 79, 24), (440, 221, 133, 20), content_db.TENDN), 
            ("MATKHAU", (319, 268, 115, 24), (440, 270, 133, 20), constants.password)
        ]

        self.label = {}
        self.lineEdit = {}
        for name, pos_label, pos_lineEdit, cent in infor:
            self.label[name] = QLabel(f"<b>{name}:</b>", self)
            self.label[name].setGeometry(*pos_label)
            self.label[name].setFont(QFont("Times New Roman", 16))

            self.lineEdit[name] = QLineEdit(str(cent), self)
            self.lineEdit[name].setReadOnly(True)
            self.lineEdit[name].setGeometry(*pos_lineEdit)


if __name__ == '__main__':
    app = QApplication(sys.argv)

    window = InforAccount()
    window.show()

    sys.exit(app.exec())