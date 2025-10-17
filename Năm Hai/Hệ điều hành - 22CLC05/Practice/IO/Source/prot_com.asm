;*****************************************************************************
;             Chuong trinh bao ve chong sao chep cac tap tin .COM
;             Cu phap : PROT_COM < Duong dan & Ten tap tin .COM >
;             Tac gia : Thai Hung Van
;*****************************************************************************
  Track  equ 80
  Side   equ 1
  Sector equ 1
  .Model Small
  .Code
    ORG 80h
  num_of_char db ?
  filename label byte
    ORG 100h
   Include MyLib.Mac
 Start :
       jmp Main
  Input_Hand dw ?
  Main_File  db 'PROT_COM.COM',0
  Main_Hand  dw ?
  File_Size  dw 664
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
       pop ds
       jnc d2
       @Write 'Open error'
       int 20h
 d2 :
       mov [Main_Hand],bx
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
       cmp al,'P'
       jz Make_NewFile
       cmp al,'T'
       jnz Exit
       jmp Continue
  Exit :
       int 20h
  Make_NewFile :
       @Write <CR,LF,'Phuc hoi lai tap tin PROT_COM.COM'>
       @Write <CR,LF,'Chuong trinh bao ve tap tin * Thai Hung Van - Tin hoc 2 - DHTH TPHCM *'
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
       mov cx,3
       @d_read [Input_Hand],<offset Data_Buffer>
       mov si,offset Data_Buffer
       mov di,offset save_3byte
       rep movsb
       xor cx,cx
       xor dx,dx
       mov ah,42h
       mov al,2
       int 21h
       sub ax,3
       mov si,offset Data_Buffer
       mov byte ptr [si],0E9h
       mov [si+1],ax
       mov cx,offset Cuoi_Phan_them - offset Phan_them
       @D_WRITE [Input_Hand],<offset Phan_Them>
       xor dx,dx
       xor cx,cx
       mov ah,42h
       mov al,0
       int 21h
       mov cx,3
       @d_write [Input_Hand],<offset Data_Buffer>
       @close [Input_Hand]
       int 20h
  Phan_Them :
       call Begin
  Begin :
       pop bx
       add bx,offset Cuoi_Phan_them - offset Phan_them
       mov dl,0
       mov dh,side
       mov cx,3
 Doctiep :
       push cx
       mov ch,track
       mov cl,sector
       mov al,1
       mov ah,2
       int 13h
       jc Doc_loi
       pop cx
       loop doctiep
       jmp Quit
 Doc_loi :
       cmp ah,4
       jz Tiep
       clc
       pop cx
       loop Doctiep
 Quit :
       int 20h
 Tiep :
       call Thuc_hien_CT
 Thuc_hien_CT :
       pop si
       add si,offset save_3byte - offset Thuc_hien_CT
       mov di,100h
       mov cx,3
       rep movsb
       mov di,100h
       jmp di
       save_3byte db 3 dup(?)
 Cuoi_Phan_them :
  Data_Buffer label byte
 End Start