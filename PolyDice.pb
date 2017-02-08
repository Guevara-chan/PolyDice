; /=\=/=\=/=\=/=\=/=\=/=\=/=\=/=\=/=\
; Polyhedron Dice simulator v1.0
; Developed in 2010 by Guevara-chan
; \=/=\=/=\=/=\=/=\=/=\=/=\=/=\=/=\=/

EnableExplicit ; Essential.
IncludeFile "PolyGUI.pbi"

; --Structures--
Structure EventData
Type.i
SubType.i
Gadget.i
EndStructure

; --Varibales--
Global GUIEvent.EventData
Global DiceMax, OutputSize

; -Constants-
#MaxColumns = 10
#CDDS_ITEM = $10000 
#CDDS_SUBITEM = $20000 
#CDDS_PREPAINT = $1 
#CDDS_ITEMPREPAINT = #CDDS_ITEM | #CDDS_PREPAINT 
#CDDS_SUBITEMPREPAINT = #CDDS_SUBITEM | #CDDS_ITEMPREPAINT 

;{ Procedures
; --Math & Logic--
Macro Rnd(Min, Max) ; Pseudo-procedure.
(Random(Max-Min) + Min)
EndMacro

Macro SetColumnWidth(Num, Value) ; Partializer
SendMessage_(GadgetID(#Results), #LVM_SETCOLUMNWIDTH, Num, Value)
EndMacro

Procedure RollDices()
; Preprations
HideGadget(#Results, #True)
Define RollCount = GetGadgetState(#Spin_Rolls)
Define Min, Max, DiceCount, Bonus = GetGadgetState(#Spin_Bonus)
If DiceMax = 0 : DiceCount = 1
Min = Val(GetGadgetText(#String_Minimum))
Max = Val(GetGadgetText(#String_Maximum)) 
If Min > Max : Min = 0 : Max = 0 : EndIf
Else : Max = DiceMax : Min = 1
DiceCount = GetGadgetState(#Spin_Dices)
EndIf
; -RollOut-
Define I, J, Accum, StrAccum.s, Width, MaxWidth
NewList Results.s()
For I = 1 To RollCount
For J = 1 To DiceCount
Accum + Rnd(Min, Max) + Bonus
Next J : AddElement(Results())
StrAccum = Str(Accum) : Results() = StrAccum : Accum = 0 : StrAccum + "   "
Width = SendMessage_(GadgetID(#Results), #LVM_GETSTRINGWIDTH, 0, @StrAccum)
If Width > MaxWidth : MaxWidth = Width : EndIf
Next I
; -Output formatting-
Define Result.s, MaxColumn = OutputSize / MaxWidth
If MaxColumn > #MaxColumns : MaxColumn = #MaxColumns : EndIf
Width = OutputSize / MaxColumn : I = 1 : J = 0
Define Offset = OutputSize - Width * MaxColumn
ClearGadgetItems(#Results) ; May blink, however.
ForEach Results() : I + 1 : Result + Chr(10) + Results()
If I > MaxColumn : AddGadgetItem(#Results, J, Result) : J + 1 : I = 1 : Result = "" : EndIf
Next : If Result : AddGadgetItem(#Results, J, Result) : EndIf
; -Final resizing-
For I = MaxColumn To 1 Step - 1
If Offset : SetColumnWidth(I, Width + 1) : Offset - 1
Else : SetColumnWidth(I, Width) : EndIf
Next I
For I = MaxColumn + 1 To #MaxColumns
SetColumnWidth(I, 0)
Next I
HideGadget(#Results, #False)
EndProcedure

;{ --GUI management--
Procedure AddListIconColumn(gadget,pos,width,align,text$,hImage) ; Not mine.
#LVCF_IMAGE = $10
#LVCFMT_COL_HAS_IMAGES = $8000
#LI_CENTERED = #LVCFMT_CENTER
#LI_LEFT = #LVCFMT_LEFT
#LI_RIGHT= #LVCFMT_RIGHT
Structure LVCOLUMN_
lv.LV_COLUMN
iImage.l
iOrder.l
EndStructure
If GetObjectType_(hImage)=#OBJ_BITMAP
; Add Image to List
Define hImgL = SendMessage_(GadgetID(gadget),#LVM_GETIMAGELIST,#LVSIL_SMALL,0)
If hImgL=0
hImgL = ImageList_Create_(16,16,#ILC_COLOR32,1,1)
SendMessage_(GadgetID(gadget),#LVM_SETIMAGELIST,#LVSIL_SMALL,hImgL)
EndIf
Define idx = ImageList_Add_(hImgL,hImage,0)
Else ; was an index
idx = hImage
EndIf
Define LVC.LVCOLUMN_
LVC\lv\mask = #LVCF_IMAGE|#LVCF_TEXT|#LVCF_WIDTH|#LVCF_FMT
LVC\lv\fmt = align|#LVCFMT_COL_HAS_IMAGES
LVC\lv\pszText = @text$
LVC\lv\cchTextMax = Len(text$)
LVC\lv\iSubItem = pos
LVC\lv\cx = width
LVC\iImage= idx
LVC\iOrder= pos
SendMessage_(GadgetID(gadget),#LVM_INSERTCOLUMN,pos,@LVC)
EndProcedure

Procedure ReceiveEvent(*Container.EventData)
With *Container
\Type = WaitWindowEvent()
\SubType = EventType()
If \Type = #PB_Event_Gadget
\Gadget = EventGadget()
Else : \Gadget = #Null
EndIf
EndWith
EndProcedure

Procedure EnforceRange(Field, Min = 0, Max = 1000000000)
Define Value.i = Val(GetGadgetText(Field))
If Value < Min : Value = Min
ElseIf Value > Max : Value = Max
Else : ProcedureReturn
EndIf
SetGadgetText(Field, Str(Value))
Define Selection = Len(Str(Value))
SendMessage_(GadgetID(Field), #EM_SETSEL, Selection, Selection)
MessageRequester("Incorrect input:","Please enter an integer between "+Str(Min)+" and "+Str(Max)+".",#MB_ICONWARNING)
EndProcedure

Procedure NormalizeSpin(SpinID)
Define Offset, SStart, SEnd, Text.s = GetGadgetText(SpinID)
SendMessage_(GadgetID(SpinID), #EM_GETSEL, @SStart, @SEnd)
Define Try = Val(Text)
If Try < 0 And GetGadgetAttribute(SpinID, #PB_Spin_Minimum) >= 0
SetGadgetState(SpinID, -Try)
Else : SetGadgetState(SpinID, GetGadgetState(SpinID))
EndIf : Offset = (Len(Text) - Len(GetGadgetText(SpinID)))
If Offset > SStart : SStart = 0 : SEnd = 0
Else : SStart - Offset : SEnd - Offset
EndIf : SendMessage_(GadgetID(SpinID), #EM_SETSEL, SStart, SEnd)
EndProcedure

Macro DisableFields() ; Pseudo-procedure.
DisableGadget(#String_Minimum, #True)
DisableGadget(#String_Maximum, #True)
DisableGadget(#Spin_Dices, #False)
DiceType = GUIEvent\Gadget - #Option_None
EndMacro

Procedure.l NotifyCallback(WindowID.l, Message.l, wParam.l, lParam.l) ; Not mine.
Define Min, Max, *LView
; process NOTIFY message only 
If Message = #WM_NOTIFY 
; set stucture pointer 
Define *LVCDHeader.NMLVCUSTOMDRAW = lParam 
; CUSTOMDRAW message from desired gadget?
If  *LVCDHeader\nmcd\hdr\code = #NM_CUSTOMDRAW 
Select *LVCDHeader\nmcd\dwDrawStage 
Case #CDDS_PREPAINT : *LView = GadgetID(#Results)
ShowScrollBar_(*LView, #SB_VERT, #True)
GetScrollRange_(*LView, #SB_VERT, @Min, @Max)
If Max > 5 : EnableScrollBar_(*LView, #SB_VERT, #ESB_ENABLE_BOTH)
Else   : EnableScrollBar_(*LView, #SB_VERT, #ESB_DISABLE_BOTH)
EndIf
ProcedureReturn #CDRF_NOTIFYITEMDRAW 
Case #CDDS_ITEMPREPAINT 
ProcedureReturn #CDRF_NOTIFYSUBITEMDRAW 
Case #CDDS_SUBITEMPREPAINT 
Define Col = *LVCDHeader\iSubItem, Row = *LVCDHeader\nmcd\dwItemSpec
If GetGadgetItemText(#Results, Row, Col)
If Row % 2 = 0
If Col % 2 : *LVCDHeader\clrTextBk = #White : Else : *LVCDHeader\clrTextBk = $F0F0D0 : EndIf
ElseIf Col % 2 : *LVCDHeader\clrTextBk = $E0E0E0 : Else : *LVCDHeader\clrTextBk = $D8D8C8
EndIf 
Else : *LVCDHeader\clrTextBk = #White
EndIf
ProcedureReturn #CDRF_DODEFAULT 
EndSelect 
EndIf 
Else 
ProcedureReturn #PB_ProcessPureBasicEvents 
EndIf 
EndProcedure 

Macro AddColumns() ; Partializer.
Define I, Style, Box.Rect
For I = 1 To #MaxColumns
AddListIconColumn(#Results, I, 0, #LVCFMT_CENTER, Str(I), #Null)
Next I
SetWindowCallback(@NotifyCallback()) 
GetClientRect_(GadgetID(#Results), @Box)
OutputSize = Box\Right - GetSystemMetrics_(#SM_CXVSCROLL)
SetScrollRange_(GadgetID(#Results), #SB_VERT, 0, 0, #True)
EndMacro

Procedure Quit()
If GetGadgetState(#CheckBox_Save)
CreatePreferences("PolyDice.ini")
WritePreferenceInteger("DType", DiceType)
WritePreferenceInteger("Rolls", GetGadgetState(#Spin_Rolls))
WritePreferenceInteger("Bonus", GetGadgetState(#Spin_Bonus))
WritePreferenceInteger("Dices", GetGadgetState(#Spin_Dices))
WritePreferenceString("MinVal", GetGadgetText(#String_Minimum))
WritePreferenceString("MaxVal", GetGadgetText(#String_Maximum))
EndIf : End ; Finally.
EndProcedure

Macro CheckDice() ; Partializer.
GUIEvent\Type = #PB_Event_Gadget 
GUIEvent\Gadget = DiceType + #Option_None
Goto Hack
EndMacro
;}
;} EndProcedures

; ==Preparations==
OpenWindow_MainWindow()
SetWindowLong_(WindowID(#Mainwindow), #GWL_EXSTYLE, GetWindowLong_(WindowID(#Mainwindow), #GWL_EXSTYLE) |
#WS_EX_LAYERED | #WS_EX_COMPOSITED)
EnforceRange(#String_Minimum)
EnforceRange(#String_Maximum)
AddColumns() : CheckDice()
; ==Main loop==
With GUIEvent
Repeat : ReceiveEvent(GUIEvent)
Hack: : Select \Type
Case #PB_Event_Gadget 
Select \Gadget
; Buttons.
Case #Button_Close : Quit()
Case #Button_Roll  : RollDices()
; Options.
Case #Option_None : DiceMax = 0 : DiceType = 0
DisableGadget(#String_Minimum, #False)
DisableGadget(#String_Maximum, #False)
DisableGadget(#Spin_Dices, #True)
Case #Option_17 To #Option_21 : DisableFields() : DiceMax = \Gadget - #Option_None + 1 ; 2 to 6
Case #Option_22 : DisableFields() : DiceMax = 8
Case #Option_23 : DisableFields() : DiceMax = 10
Case #Option_24 : DisableFields() : DiceMax = 12
Case #Option_25 : DisableFields() : DiceMax = 20
Case #Option_26 : DisableFields() : DiceMax = 30
Case #Option_27 : DisableFields() : DiceMax = 100
; Other.
Case #String_Minimum, #String_Maximum 
If \SubType = #PB_EventType_Change : EnforceRange(\Gadget) : EndIf
Case #Spin_Rolls, #Spin_Dices, #Spin_Bonus : NormalizeSpin(\Gadget)
EndSelect
; Window events.
Case #PB_Event_CloseWindow : Quit()
EndSelect
ForEver
EndWith
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; Folding = --
; EnableXP
; UseIcon = Resources\Dices.ico
; Executable = PolyDice.exe
; IncludeVersionInfo
; VersionField0 = 1,0,0,0
; VersionField1 = 1,0,0,0
; VersionField2 = Guevara-chan [~R.i.P]
; VersionField3 = <PolyDice>
; VersionField4 = 1.0
; VersionField5 = 1.0
; VersionField6 = <PolyDice> PB Application
; VersionField7 = <PolyDice>
; VersionField8 = PolyDice.exe
; VersionField9 = Copyright © 2010, Guevara-chan
; VersionField17 = 0409 English (United States)