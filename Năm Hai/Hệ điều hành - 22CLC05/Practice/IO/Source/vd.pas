{$R-}
 Uses dos,crt,vsystem;
  Const
   VideoBIOS=$10;
   MaxResX:integer=320;
   MaxResY:integer=200;
  type
    DACtype=record
       R,G,B:byte
      end;
    DACarray=array[0..255] of DACtype;
    Buffertype=array[1..1] of byte;
    Bufferptr=^Buffertype;
 Var Palete,OldPalete : DACarray;
     Buffer,OldBuffer : Bufferptr;
   R      : Registers;
   i,j    : Byte;
   f      : file;

 procedure GetPalete(var Palete);
   begin
    R.ax:=$1017;
    R.bx:=0;
    R.cx:=255;
    R.es:=seg(palete);
    R.dx:=ofs(palete);
    Intr(VideoBIOS,r);
   end;

 procedure SetPalete(var Palete);
   begin
    R.ax:=$1012;
    R.bx:=0;
    R.cx:=255;
    R.es:=seg(palete);
    R.dx:=ofs(palete);
    Intr(VideoBIOS,r);
   end;

  Procedure SaveVGAScreen( x1,y1,x2,y2:Integer; Var Buffer:Bufferptr );
   Var  i : Integer;
   Begin
    For i:=y1 To y2 Do
      Move(Ptr($A000,MaxResX*i+x1)^,Buffer^[MaxResX*i+x1],x2-x1+1);
   End;

  Procedure RestoreVGAScreen( x1,y1,x2,y2:Integer; Var Buffer:Bufferptr );
   Var i : Integer;
   Begin
     For i:=y1 To y2 Do
       Move( Buffer^[MaxResX*i+x1],Ptr($A000,MaxResX*i+x1)^,x2-x1+1 );
  End;

Procedure PutPic;
var i,j:integer;
begin
for j:=1 to MaxResX do
 begin
   for i:=0 to 199 div 2 do
     begin
     Move(Buffer^[(MaxResX-j)+MaxResX*i*2],Ptr($A000,MaxResX*i*2)^,j);
     Move(Buffer^[MaxResX*(i*2+1)],Ptr($A000,(MaxResX-j)+MaxResX*(i*2+1))^,j)
     end;
   r.bh := 0;
   r.ah := 2;
   r.dx := $0912;
   intr($10,r);

   r.ah := $A;
   r.bl := 243;
   r.cx := 1;
   r.al := 86; {V}
   intr($10,r);
   r.al := 65; {A}
   intr($10,r);
   r.al := 78; {N}
   intr($10,r);
 end;
end;

BEGIN
   if not VGAScreen then halt;
   R.ah:=0;
   R.al:=$13;
   Intr($10,r);

   r.bh := 0;
   r.ah := 2;
   r.dx := $0912;
   intr($10,r);

   r.ah := $A;
   r.al := ord('V');
   r.bl := 1;
   r.bh := 0;
   r.cx := 1;
   intr($10,r);

   GetMem( Buffer,64000 );
   Assign( F,'test2.pic' );
   Reset( F,1 );
   BlockRead(F,Buffer^,64000);
   Close( F );
   Assign( F,'test2.pal' );
   Reset( F,1 );
   Blockread(F,Palete,3*256);
   Close( F );
   GetPalete(OldPalete);
   Setpalete(Palete);
   PutPicModeC;

   FreeMem( Buffer,64000 );
   r.ah := $A;
   r.bl := 243;
   r.bh := 0;
   r.cx := 1;
   r.al := ord('V');
   intr($10,r);
   readln;
   SetPalete(OldPalete);
 END.