;{- Enumerations / DataSections
;{ Windows
Enumeration
  #MainWindow
EndEnumeration
;}
;{ Gadgets
Enumeration
  #Button_Roll
  #Button_Close
  #Frame3D_2
  #Text_3
  #Results
  #Text_5
  #Text_6
  #Text_7
  #Frame3D_8
  #Spin_Rolls
  #Spin_Dices
  #Spin_Bonus
  #Text_12
  #Text_13
  #String_Minimum
  #String_Maximum
  #Option_None
  #Option_17
  #Option_18
  #Option_19
  #Option_20
  #Option_21
  #Option_22
  #Option_23
  #Option_24
  #Option_25
  #Option_26
  #Option_27
  #CheckBox_Save
EndEnumeration
;}
;{ Fonts
Enumeration
  #Font_Results
EndEnumeration
;}
;
Global DiceType
Procedure ResetGUI()
SetGadgetText(#Spin_Rolls, "1")
SetGadgetText(#Spin_Dices, "1")
SetGadgetText(#Spin_Bonus, "0")
DisableGadget(#Spin_Dices, #True)
SetGadgetState(#Option_None, #True)
EndProcedure
Macro AlignLeft(Control) ; Partializer
Define I = GetWindowLong_(GadgetID(Control), #GWL_STYLE)
SetWindowLong_(GadgetID(Control), #GWL_STYLE, (I & ~#ES_RIGHT) | #ES_LEFT)
EndMacro
;
;}
Procedure OpenWindow_MainWindow()
  If OpenWindow(#MainWindow, 389, 384, 497, 232, "Polyhedron Dice", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_TitleBar|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    ButtonGadget(#Button_Roll, 380, 140, 75, 25, "Roll")
    ButtonGadget(#Button_Close, 380, 172, 75, 25, "Close")
    Frame3DGadget(#Frame3D_2, 10, 9, 160, 120, "Die Type")
    TextGadget(#Text_3, 15, 143, 85, 15, "Number of Rolls:")
    ListIconGadget(#Results, 180, 30, 305, 100, "", 0, #LVS_NOCOLUMNHEADER)
    TextGadget(#Text_5, 180, 15, 100, 15, "Roll Results:")
    TextGadget(#Text_6, 15, 173, 80, 15, "Number of Dice:")
    TextGadget(#Text_7, 15, 203, 80, 15, "Roll Bonus:")
    Frame3DGadget(#Frame3D_8, 180, 135, 175, 85, "Range")
    SpinGadget(#Spin_Rolls, 100, 140, 55, 21, 1, 10000, #PB_Spin_Numeric)
    SpinGadget(#Spin_Dices, 100, 170, 55, 20, 1, 100, #PB_Spin_Numeric)
    SpinGadget(#Spin_Bonus, 100, 200, 55, 20, -1000, 1000, #PB_Spin_Numeric)
    TextGadget(#Text_12, 190, 158, 45, 20, "Minimum:")
    TextGadget(#Text_13, 190, 190, 50, 15, "Maximum:")
    StringGadget(#String_Minimum, 250, 154, 95, 23, "0", #PB_String_Numeric)
    StringGadget(#String_Maximum, 250, 187, 95, 23, "99", #PB_String_Numeric)
    OptionGadget(#Option_None, 20, 26, 60, 15, "None")
    OptionGadget(#Option_17, 20, 42, 60, 15, "2-sided")
    OptionGadget(#Option_18, 20, 58, 60, 15, "3-sided")
    OptionGadget(#Option_19, 20, 74, 60, 15, "4-sided")
    OptionGadget(#Option_20, 20, 90, 60, 15, "5-sided")
    OptionGadget(#Option_21, 20, 106, 60, 15, "6-sided")
    OptionGadget(#Option_22, 90, 26, 60, 15, "8-sided")
    OptionGadget(#Option_23, 90, 42, 60, 15, "10-sided")
    OptionGadget(#Option_24, 90, 58, 60, 15, "12-sided")
    OptionGadget(#Option_25, 90, 74, 60, 15, "20-sided")
    OptionGadget(#Option_26, 90, 90, 60, 15, "30-sided")
    OptionGadget(#Option_27, 90, 106, 67, 15, "Percentile")
    CheckBoxGadget(#CheckBox_Save, 380, 205, 75, 15, "Save fields")
    ; Gadget Fonts
    SetGadgetFont(#Results, LoadFont(#Font_Results, "Microsoft Sans Serif", 8, #PB_Font_Bold|#PB_Font_HighQuality))
    ;
    AlignLeft(#Spin_Rolls) : AlignLeft(#Spin_Dices) : AlignLeft(#Spin_Bonus)
    If OpenPreferences("PolyDice.ini")
    DiceType = ReadPreferenceInteger("DType", 0)
    If DiceType >= 0 And DiceType <= #Option_27 - #Option_None
    Else : DiceType = 0
    EndIf : SetGadgetState(#Option_None + DiceType, #True)  
    SetGadgetState(#Spin_Rolls, ReadPreferenceInteger("Rolls", 1))
    SetGadgetState(#Spin_Bonus, ReadPreferenceInteger("Bonus", 1))
    SetGadgetState(#Spin_Dices, ReadPreferenceInteger("Dices", 0))
    SetGadgetText(#String_Minimum, Str(ReadPreferenceInteger("MinVal", 0)))
    SetGadgetText(#String_Maximum, Str(ReadPreferenceInteger("MaxVal", 99)))
    SetGadgetState(#CheckBox_Save, #True)
    Else : ResetGUI()
    EndIf
    HideWindow(#MainWindow, #False)
  EndIf
EndProcedure

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; Folding = --
; EnableXP