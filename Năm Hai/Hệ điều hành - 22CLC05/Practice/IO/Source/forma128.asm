track equ 80
side equ 1
sector equ 1
s_size equ 0
 code segment
      assume cs:code,ds:code,es:code
      org 100h
start:
    mov dl,0
    mov ch,track
    mov dh,side
    mov al,1
    mov ah,5
    mov bx,offset data_
    int 13h
    int 20h
   data_ db track,side,sector,s_size
 code ends
      end start

