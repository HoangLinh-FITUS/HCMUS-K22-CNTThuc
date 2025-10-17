import constants
import sys
import widgets

from PyQt6.QtWidgets import (
    QApplication, 
    QWidget, 
    QLabel, 
    QPushButton,
    QLineEdit
)
from PyQt6.QtGui import QFont, QPixmap
from PyQt6.QtCore import Qt, QTimer
import quanly_lophoc


class LoginWindow(QWidget):

    username = ""
    password = ""

    def __init__(self):
        super().__init__()   
        self.setWindowFlag(Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.create_login()

    def create_login(self):
        self.box = QWidget(self)
        self.box.setGeometry(150, 10, constants.WINDOW_WIDTH_LOGIN, constants.WINDOW_HEIGHT_LOGIN)
        self.box.setStyleSheet("background-color: rgba(212, 53, 70, 0.88); border-radius: 20px;")
        
        self.label_image_user = QLabel(self.box)
        self.label_image_user.setPixmap(QPixmap(constants.IMAGE_USER_LOGIN))
        self.label_image_user.setScaledContents(True)
        self.label_image_user.setGeometry(110, 30, 131, 131)
        self.label_image_user.setStyleSheet("background-color: rgba(245, 40, 145, 0)")


        self.label_input_username = QLineEdit(self.box)
        self.label_input_username.setGeometry(10, 200, 301, 41)
        self.label_input_username.setPlaceholderText("Username")
        self.label_input_username.setStyleSheet("background-color: rgb(255, 255, 255); border-radius: 0px")
        self.label_input_username.setFont(QFont("Times New Roman", 12))
        self.label_input_username.textChanged.connect(self.inputted_username)

        self.label_input_password = QLineEdit(self.box)
        self.label_input_password.setGeometry(10, 250, 301, 41)
        self.label_input_password.setPlaceholderText("Password")
        self.label_input_password.setStyleSheet("background-color: rgb(255, 255, 255); border-radius: 0px")
        self.label_input_password.setFont(QFont("Times New Roman", 12))
        self.label_input_password.textChanged.connect(self.inputted_password)


        self.button_login = QPushButton("Login", self.box)
        self.button_login.setGeometry(60, 320, 211, 41)
        self.button_login.setStyleSheet("""
            QPushButton {
                border-radius: 10px; background-color: rgb(254, 248, 255);
            }

            QPushButton:hover {
                background-color: rgba(223, 222, 243, 1);
            }

            QPushButton:pressed {
                background-color: rgba(212, 53, 70, 0.88);
            }")
            """
        )
        self.button_login.setFont(QFont("Times New Roman", 16))

        self.button_login.clicked.connect(self.logging_in)

    def isSuccessfullyCompleted(self) -> bool:
        return widgets.login_account(self.username, self.password)
    
    def logging_in(self):
        
        print(self.username, self.password, self.isSuccessfullyCompleted())
        
        if self.isSuccessfullyCompleted():
            self.close()
        else: 
            self.button_login.setText("Failed")

        self.button_login.show()
        QTimer.singleShot(2000, lambda: self.button_login.setText("Login"))


    def inputted_password(self):
        self.password = self.label_input_password.text()
    
    def inputted_username(self):
        self.username = self.label_input_username.text()
        


if __name__ == '__main__':
    app = QApplication(sys.argv)

    window = LoginWindow()
    window.show()

    app.exec()

    window = quanly_lophoc.QLLopHoc()
    window.show()
    sys.exit(app.exec())
    
