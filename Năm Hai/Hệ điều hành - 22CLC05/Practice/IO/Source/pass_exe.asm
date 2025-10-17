;*****************************************************************************
;Chuong trinh bao ve chong sao chep cac tap tin .EXE bang cach cai Mat ma vao
; Cu phap : PASS_EXE < Duong dan & Ten tap tin .EXE >
; Tac gia : Thai Hung Van
;*****************************************************************************
 Num_of_char equ 11
 Num_of_byte equ 30
 Sector_size equ 512
 Len_in_512b equ 0004h
 Len_mod_512 equ 0002h
 Header_in_para equ 0008h
 Word_checksum equ 0012h
 Ip_at_entry equ 0014h
 Cs_displm equ 0016h
  .Model small
  .Code
    ORG 80h
  Num_char db ?
  Filename label byte
    ORG 100h
      Include MYLIB.MAC
 Start :
       jmp Main
  Main_File  db 'PASS_EXE.COM',0
  Input_Hand dw ?
  Main_Hand  dw ?
  File_Size  dw 816
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
       @Write <CR,LF,'Tiep tuc (T)/Tro ve DOS (D) hay Phuc hoi lai (P) ? '>
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
       @Write <CR,LF,'Da phuc hoi lai tap tin PASS_EXE.COM'>
       @Write <CR,LF,'Chuong trinh bao ve tap tin * Thai Hung Van Tin hoc 2 DHTH TPHCM *'>
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
       @Write 'Password : '
       mov dx,offset Password
       mov bx,dx
       mov [bx],num_of_char + 1
       mov ah,0Ah
       int 21h

       mov dx,[bx]
       xor ch,ch
       mov cl,dh
       cmp cx,0
       jnz L;
       mov ah,4Ch
       int 21h
 L:    xor [bx+2],0AAh
       inc bx
       loop L
;
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
       mov ax,offset Cuoi_Phan_them - offset Phan_them
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
       mov dx,offset Phan_them
       mov cx,offset Cuoi_Phan_them - offset Phan_Them
       mov ah,40h
       int 21h
 Close_file:
       mov ah,3eh
       int 21h
       int 20h
 Phan_them:
       jmp Begin
 TB DB 'Password : $'
 Password db num_of_char + 3 dup('$')
 ip_save dw 0
 cs_save dw 0
 Begin :
       call In_TB
 In_TB :
       pop dx
       push ds
       push cs
       pop ds
       sub dx,offset In_TB - offset TB
       mov ah,9
       int 21h
       call Doc_Matma
 Doc_Matma :
       pop si
       sub si,offset Doc_Matma - offset Password - 1
 So_sanh :
       inc si
       cmp byte ptr ds:[si],CR
       jz Thuc_hien_CT
       mov ah,8
       int 21h
       xor al,0AAh
       cmp al,byte ptr ds:[si]
       je So_sanh
       pop ds
       mov ah,4Ch
       int 21h
Thuc_hien_CT:
       pop ds
       call A
 A:
       pop bp
       sub bp,offset A - offset Begin
       cli
       mov ax,ds
       add ax,10h
       add ax,cs:[bp-2]
       push ax
       mov ax,cs:[bp-4]
       push ax
       sti
       retf
 Cuoi_Phan_them:
  Data_Buffer:
   End Start