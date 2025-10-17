;--------------------------------------------------
;    CHUONG TRINH CAI DAT DONG HO THUONG TRU
;--------------------------------------------------
   .286
   .Model small
   .Code
      ORG 100h
   Include Mylib.Mac
Begin : jmp main
    id_buf db '1234'
    OldInt60 dd ?
    OldInt1C dd ?
    Status DB  0 ; Thong bao het gio
    OnOff  DB  1 ; Tat/mo dong ho
    Chuoi_Thoigian label byte
      Gio  DB  0,0
           DB  ':'
      Phut DB  0,0
           DB  ':'
      Giay DB  0,0
      Buoi DB  0,0
           DB  0
Dongho proc far
            pusha
            push      ds
            push      es
            Mov       ax,cs
            Mov       ds,ax
            mov       ah,2
            int       16h
            mov       ah,al
            and       al,00001011b
            cmp       al,00001011b
            jb        T1             ;Doc tiep Ctrl_LeftShift

            lds       dx,cs:OldInt60
            mov       ax,2560h       ;Phuc hoi Int60
            int       21h

            lds       dx,cs:OldInt1C
            mov       ax,251Ch       ;Phuc hoi Int1C
            int       21h
            
            mov       ax,cs:[2ch]
            mov       es,ax          ;Giai phong vung nho moi truong
            mov       ah,49h
            int       21h
            mov       ax,cs
            mov       es,ax
            mov       ah,49h          ;Giai phong vung nho chuong trinh
            int       21h
            jmp       KT
      T1 :
            mov       al,ah
            and       al,00000110b
            cmp       al,00000110b     ;Ctrl_LShift ?
            jne       T2
            or        OnOff,1
      T2 :
            mov       al,ah
            and       al,00000101b
            cmp       al,00000101b
            jne       T3
            cmp       OnOff,1
            jne       T3
            and       OnOff,0
            call      InChuoi
      T3 :
            cmp       OnOff,0
            jz        KT
            Call      Xuly
      KT :
            pop       es
            pop       ds
            popa
            Iret
Dongho      endp
;--------------------------------------
;          THU TUC XU LY
;--------------------------------------
Xuly        proc
            push      es
            push      40h
            pop       es
            mov       ax,word ptr es:6Eh
            mov       Gio,al
            mov       Status,0
            mov       ax,word ptr es:6Ch ;ax=so xung cua dong ho trong 1 gio
            cmp       ax,0
            jnz       Cont
            mov       Status,1
 Cont :     Call      Tinhgio          ;Tinh phut va giay
            Call      DoiGio           ;Doi buoi AM hay PM va Gio tuong ung
            Call      Ingio            ;In dong ho ra man hinh
            cmp       Status,1
            jnz       Cont1
            mov       cx,300
 Chuong :   Call      Ring
            loop      Chuong
 Cont1 :
            pop       es
            ret
Xuly        endp
;--------------------------------------------------------
;            THU TUC TINH PHUT VA GIAY
;          ( Xu dung ket qua trong ax )
;--------------------------------------------------------
Tinhgio     proc
            push    bx
            push    cx
            push    dx
            xor     dx,dx ; dx:ax dang chua so xung
            mov     cx,10
            mul     cx    ; dx:ax se chua so xung * 10
            mov     cx,182
            div     cx    ; Ket qua ax chua so giay trong gio hien thoi
            mov     cl,60
            div     cl    ; Ket qua ah chua giay , al chua phut
            mov     byte ptr Phut,al
            mov     byte ptr Giay,ah
            pop     dx
            pop     cx
            pop     bx
            ret
Tinhgio  endp
;
DoiGio  proc  ; Doi buoi AM hay PM
            push     si
            mov      si,offset Buoi
            cmp      gio,12
            ja       Doi
            mov      [si],41h
            mov      [si+1],4Dh
            jmp      K
  Doi :
            mov      [si],50h
            mov      [si+1],4Dh
            sub      Gio,12
   K :      pop      si
            ret
DoiGio   endp
;---------------------------------------------
;     THU TUC IN GIO VOI THUOC TINH DAO
;Su dung dia chi man hinh B800h hay B000h
;---------------------------------------------
Ingio      proc
           push     ax
           mov      cl,10
           xor      ax,ax
           mov      al,Gio
           div      cl
           add      ax,3030h
           mov      word ptr Gio,ax
           xor      ax,ax
           mov      al,phut
           div      cl
           add      ax,3030h
           mov      word ptr Phut,ax
           xor      ax,ax
           mov      al,Giay
           div      cl
           add      ax,3030h
           mov      word ptr Giay,ax
           Call     InChuoi         ;Thu tuc in chuoi thoi gian ra man hinh
           pop      ax
           ret
Ingio      endp
;---------------------------------------------
;          THU TUC IN CHUOI
;Thu tuc nay in Chuoi_Thoigian ra man hinh
;  voi thuoc tinh dao tai dong 0 cot 69
;---------------------------------------------
InChuoi proc
           push     ax
           push     bx
           push     cx
           push     es
           push     di
           push     si
           mov      si,Offset Chuoi_Thoigian
           mov      ah,70h                   ;Thuoc tinnh dao
           cmp      OnOff,0
           jnz      TT
           mov      ah,00h
      TT :
           mov      di,140                   ;Cot 70 , dong 0
           mov      bx,0B000h
           push     40h
           pop      es
           mov      cx,es:63h
           cmp      cx,3D4h
           jnz      Trangden
           mov      bx,0B800h
Trangden:
           mov      es,bx
Continue:
       ;In dong ho ra man hinh
           Cld
           Lodsb
           or       al,al
           jz       Ketthuc
           stosw
           jmp      Continue
Ketthuc:
           pop      si
           pop      di
           pop      es
           pop      cx
           pop      bx
           pop      ax
           ret
InChuoi endp
;-----------------------------------------
;    THU TUC RING PHAT RA TIENG CHUONG
;-----------------------------------------
Ring      proc
          push      ax
          push      cx
          mov       al,182
          Out       67,al
          mov       al,0
          Out       66,al
          mov       al,05
          Out       66,al
          in        al,97
          push      ax
          or        al,3
          Out       97,al          ;Bat loa
          mov       cx,8080        ;Thoi gian ngat tieng reng
Nosound:  loop      nosound
          pop       ax
          Out       97,al
          pop       cx
          pop       ax
          ret
Ring      endp
;-----------------------------
;    CHUONG TRINH CHINH
;-----------------------------
Main:
       jmp Start
  MainFile DB 'CLOCK.COM',0
  Main_Hand  dw ?
  File_Size  dw 1122
  Error :
       @Write 'Error'
       int 20h
  Get_FileSize :
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       int 21h
       ret
  Start :
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
       jmp Conti
  d0:
       @Write 'FileSize has changed. Virus !?'
       @Write <CR,LF,'Continue (C) / Exit to DOS (D) or Restore (R) ? '>
       mov ah,1
       int 21h
       and al,5Fh;Doi thanh chu hoa
       cmp al,'R'
       jz Make_NewFile
       cmp al,'C'
       jnz Exit
       jmp Conti
  Exit :
       int 20h
  Make_NewFile :
       @Write <CR,LF,' File CLOCK.COM has restored'>
       @Write <CR,LF,' * Thai Hung Van - University of HCM city *'>
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
 Conti :
       mov ax,3560h
       int 21h
       mov si,offset id_buf
       mov di,bx
       mov cx,4
       repe cmpsb
       or cx,cx
       jnz Not_Already
       @Write 'Clock already resident'
       int 20h
  Not_Already :
         mov        ax,3560h
         int        21h
         mov        word ptr OldInt60,bx
         mov        word ptr OldInt60 + 2,es
         mov        ax,2560h
         mov        dx,offset id_buf
         int        21h
         mov        ax,351Ch
         int        21h
         mov        word ptr OldInt1C,bx
         mov        word ptr OldInt1C + 2,es
         mov        ax,251Ch
         mov        dx,Offset  Dongho
         int        21h
         @Write     <CR,LF,'Thai Hung Van''s clock is resident',CR,LF>
         @Write     <'  Ctrl_LeftShift  : On',CR,LF>
         @Write     <'  Ctrl_RightShift : Off',CR,LF>
         @Write     <'  Alt_Shift_Shift : Unload',CR,LF>
         mov        dx,Offset  Main
         int        27h
End      Begin
