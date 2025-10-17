;*****************************************************************************
;Chuong trinh bao ve chong sao chep cac tap tin .EXE bang cach cai Mat ma vao
; Cu phap : PROT_EXE < Duong dan & Ten tap tin .EXE >
; Tac gia : Thai Hung Van - Pham Nguyen Anh Huy
;*****************************************************************************
 Is_exe_file equ 5a4dh
 Num_of_byte equ 30
 Sector_size equ 512
 Len_in_512b equ 0004h
 Len_mod_512 equ 0002h
 Header_in_para equ 0008h
 Word_checksum equ 0012h
 Ip_at_entry equ 0014h
 Cs_displm equ 0016h
  .Model Small
  .Code
    ORG 80h
  num_of_char db ?
  filename label byte
    ORG 100h
   Include MyLib.mac
 Start :
       jmp Main
  Input_Hand dw ?
  Main_File  db 'PROT_EXE.COM',0
  Main_Hand  dw ?
  File_Size  dw 1276
  Error :
       @Write 'Error'
       int 20h
  Get_FileSize :
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       int 21h
       ret
  Main :
       mov ax,word ptr es:[2Ch]
       push es
       mov es,ax
       mov ax,1
       xor bx,bx
  Find_MainFile :
       cmp ax,es:[bx]
       jz D
       inc bx
       jmp Find_MainFile
  D :
       xor ax,ax
       cmp ax,es:[bx-2]
       jnz Find_MainFile
       add bx,2
       push ds
       push es
       pop ds
       pop es
       @Open bx
       mov [Main_Hand],bx
       pop ds
       jnc d2
       @Write 'Open error'
       int 20h
  d2 :
       mov [Input_hand],bx
       call Get_FileSize
       push ax ; Dong file co thay doi ah
       @Close
       pop ax
       cmp ax,File_Size
       jnz d0
       jmp Continue
  d0:
       @Write 'Tap tin da bi thay doi'
       @Write <CR,LF,'Tiep tuc (T)/Tro ve DOS (D) hay Phuc hoi lai (P)'>
       mov ah,1
       int 21h
       and al,5Fh;Doi thanh chu hoa
       cmp al,'T'
       jz Continue
       cmp al,'P'
       jz Make_NewFile
       int 20h
  Make_NewFile :
       @Write <CR,LF,'Phuc hoi lai tap tin PROT_EXE.COM'>
       mov dx,offset Main_File
       mov ah,3Ch
       xor cx,cx ;Thuoc tinh
       int 21h
       jnc d1
       jmp Error
  d1 :
       mov cx,File_Size
       @D_Write [Main_Hand],100h
       @Close [Main_Hand]
       int 20h
  Continue :
       mov di,offset Filename
       mov cl,[di-1]
       mov ch,0
       mov al,blank
       repe scasb
       dec di
       inc cx
       mov si,di
       repne scasb
       jnz Cuoi_dten
       dec di
  Cuoi_dten :
       mov [di],ch
       @open SI
       jnc d3
       jmp Error
  d3 :
       mov [Input_Hand],bx
       inc di
  GetStr :
       mov bx,0
       mov cx,5
       mov dx,di
       mov ah,3Fh
       int 21h
       sub ax,2
  Str2Num :
       mov cx,ax
       xor ax,ax
       mov bx,10
       mov si,di
       mov dh,0
  Loop1 :
       mul bx
       mov dl,[si]
       sub dl,'0'
       add ax,dx
       inc si
       loop Loop1
       mov cs:Sector,ax

       mov cx,num_of_byte
       @d_read [Input_Hand],<offset Data_Buffer>
       mov si,offset Data_Buffer
       mov ax,[si+ip_at_entry]
       mov cs:ip_save,ax
       mov ax,[si+cs_displm]
       mov cs:cs_save,ax
       add ax,[si+ip_at_entry]
       add ax,1234h
       cmp ax,[si+word_checksum]
       jnz not_prot
       jmp close_file
  Not_prot:
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       int 21h
       mov cx,sector_size
       div cx
       push bx
       push ax
       mov cl,5
       shl ax,cl
       sub ax,[si+header_in_para]
       mov [si+cs_displm],ax
       mov [si+ip_at_entry],dx
       add ax,dx
       add ax,1234h
       mov [si+word_checksum],ax
       pop bx
       mov ax,offset Cuoi_PhanThem - offset PhanThem
       add ax,dx
       xor dx,dx
       mov cx,sector_size
       div cx
       add bx,ax
       or dx,dx
       jz no_residue
       inc bx
 No_residue:
       mov [si+len_in_512b],bx
       mov [si+len_mod_512],dx
       pop bx
       mov ax,4200h
       xor cx,cx
       xor dx,dx
       int 21h
       mov dx,offset Data_Buffer
       mov cx,num_of_byte
       mov ah,40h
       int 21h
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       int 21h
       mov dx,offset PhanThem
       mov cx,offset Cuoi_PhanThem - offset PhanThem
       mov ah,40h
       int 21h
 Close_file:
       mov ah,3eh
       int 21h
       int 20h
 PhanThem:
       jmp Begin
 stacks db 128 dup('1234')
 Sector  dw 0
 sp_new  dw 0
 ip_save dw 0
 cs_save dw 0
 sp_save dw 0
 ss_save dw 0
 Begin :
       call A
 A :
       pop bp
       sub bp,offset A - offset Begin
       push es
       mov cs:[bp-2],ss
       mov cs:[bp-4],sp
       cli
       mov ax,cs
       mov ss,ax
       mov ax,bp
       sub ax,offset Begin-offset sp_new
       mov sp,ax
       sti
       mov ax,word ptr cs:[2Ch]
       mov es,ax
       mov ax,1
       xor bx,bx
 Find :
       cmp ax,es:[bx]
       jz F
       inc bx
       jmp Find
 F :
       xor ax,ax
       cmp ax,es:[bx-2]
       jnz Find
       add bx,3
       cmp byte ptr es:[bx],':'
       jnz G
       dec bx
       mov al,byte ptr es:[bx]
       and al,5Fh
       sub al,'A'
       jmp H
 G :
       mov ah,19h
       int 21h
 H :   ;AL dang chua o dia
       mov cx,1
       push cs
       pop ds
       mov bx,bp
       add bx,offset Cuoi_PhanThem - offset Begin
       int 25h
       pop dx
       mov cx,10
 L :
       cmp [bx],'V'
       jnz Exit
       loop L
       jmp Tiep
 Exit:
       mov ah,4ch
       int 21h
 Tiep:
       cli
       mov sp,cs:[bp-4]
       mov ss,cs:[bp-2]
       pop es
       mov ax,ds
       add ax,10h
       add ax,cs:[bp-6]
       push ax
       mov ax,cs:[bp-8]
       push ax
       sti
       retf
 Cuoi_PhanThem:
  Data_Buffer:
    End Start














