;*****************************************************************************
;Chuong trinh bao ve chong sao chep cac tap tin .COM bang cach cai Mat ma vao
; Cu phap : PASS_COM < Duong dan & Ten tap tin .COM >
; Tac gia : Thai Hung Van - Pham Nguyen Anh Huy
;*****************************************************************************
 So_chu_trong_mat_ma EQU 11
  .Model Small
  .Code
    ORG 80h
  num_of_char db ?
  filename label byte
    ORG 100h
   Include MyLib.mac
 Start :
       jmp Main
  MainFile DB 'PASS_COM.COM',0
  Input_Hand dw ?
  Main_Hand  dw ?
  File_Size  dw 754
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
       @Write <CR,LF,'Tiep tuc (T) / Tro ve DOS (D) hay Phuc hoi lai (P) ? '>
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
       @Write <CR,LF,'Da phuc hoi lai tap tin PASS_COM.COM'>
       @Write <CR,LF,'Chuong trinh bao ve tap tin * Thai Hung Van - Tin hoc 2 - DHTH TPHCM *'>
       mov dx,offset MainFile
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
       mov [input_hand],bx
       @Write 'Password : '
       mov dx,offset Password
       mov bx,dx
       mov [bx],So_chu_trong_mat_ma + 1
       mov ah,0Ah
       int 21h
;
       mov dx,[bx]
       xor ch,ch
       mov cl,dh
       cmp cx,0
       jnz L                    ;    25/9/94
       int 20h                  ;
L:     xor [bx+2],0AAh
       inc bx
       loop L
;
       mov cx,3
       @d_read [input_hand],<offset Data_Buffer>
       mov si,offset Data_Buffer
       mov di,offset save_3byte
       rep movsb
       xor cx,cx
       xor dx,dx
       mov ax,4202h
       int 21h
       sub ax,3
       mov si,offset Data_Buffer
       mov byte ptr [si],0E9h
       mov [si+1],ax
       mov cx,offset Cuoi_Phan_them - offset Phan_them
       @D_Write [input_hand],<offset Phan_Them>
       xor dx,dx
       xor cx,cx
       mov ax,4200h
       int 21h
       mov cx,3
       @d_write [input_hand],<offset Data_Buffer>
       @close [input_hand]
       int 20h
 Phan_Them :
       jmp Begin
 TB DB 'Password : $'
  Begin :
       call In_TB
  In_TB :
       pop bx
       sub bx,offset In_TB - offset TB
       @Write_r bx
       call Doc_Matma
  Doc_Matma :
       pop si
       add si,offset Password - offset Doc_Matma + 1
  So_sanh :
       inc si
       cmp byte ptr ds:[si],CR
       jz Tiep
       mov ah,8
       int 21h
       xor al,0AAh
 ;
       cmp al,byte ptr ds:[si]
       je So_Sanh
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
       Password db So_chu_trong_mat_ma + 3 dup('$')
       Save_3byte db 3 dup(?)
 Cuoi_Phan_them :
  Data_Buffer label byte
 End Start