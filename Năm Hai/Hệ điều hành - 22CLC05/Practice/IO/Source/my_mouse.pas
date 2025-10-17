(****************************************************************************
	   Thai Hung Van - Tin hoc 3 - DHTH TPHCM - 1993 1994
 ***************************************************************************)
  UNIT My_Mouse;
{---------------------------------INTERFACE---------------------------------}
  INTERFACE
  Uses dos;
 Function Reset_mouse : boolean;
 Procedure Show_Mouse;
 Procedure Hide_Mouse;
 Function Clicked : word;
 Function M_GetX : word;
 Function M_GetY : word;
 Procedure Set_Mouse(x,y : integer);
 Procedure MouseSetMoveArea(x1,y1,x2,y2 : integer);
 Var Mouse : Boolean;
{--------------------------IMPLEMENTATION---------------------------------}
  IMPLEMENTATION
Var Reg : registers;
 Function Reset_mouse;
   Begin
     Reg.AX := 0;
     Intr($33,Reg);
     Reset_mouse := (Reg.AX = $FFFF)
   End;
{--------------------------------------------------------------------------}
 Procedure Show_Mouse;
   Begin
     Reg.AX := 1;
     Intr($33,Reg);
   End;
{--------------------------------------------------------------------------}
 Procedure Hide_Mouse;
   Begin
     Reg.AX := 2;
     Intr($33,Reg);
   End;
{--------------------------------------------------------------------------}
 Function Clicked;
   Begin
     Reg.AX := 3;
     Intr($33,Reg);
     Clicked := (Reg.BX and $0007);
   End;
{--------------------------------------------------------------------------}
 Function M_GetX;
   Begin
     Reg.AX := 3;
     Intr($33,Reg);
     M_GetX := Reg.CX;
   End;
{--------------------------------------------------------------------------}
 Function M_GetY;
   Begin
     Reg.AX := 3;
     Intr($33,Reg);
     M_GetY := Reg.DX;
   End;
{--------------------------------------------------------------------------}
 Procedure Set_Mouse;
   Begin
     Reg.AX := 4;
     Reg.CX := x;
     Reg.DX := y;
     Intr($33,Reg);
   End;
{--------------------------------------------------------------------------}
 Procedure MouseSetMoveArea;
   Begin
     Reg.AX := 8;
     Reg.CX := y1;
     Reg.DX := y2;
     Intr($33,Reg);
     Reg.AX := 7;
     Reg.CX := x1;
     Reg.DX := x2;
     Intr($33,Reg);
   End;
{==========================================================================}
 BEGIN
   Mouse := Reset_Mouse;
 END.
