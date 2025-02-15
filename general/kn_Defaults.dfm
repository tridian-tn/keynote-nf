object Form_Defaults: TForm_Defaults
  Left = 379
  Top = 248
  HelpContext = 292
  BorderStyle = bsDialog
  Caption = 'Defaults'
  ClientHeight = 496
  ClientWidth = 375
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object LB_Scope: TLabel
    Left = 8
    Top = 4
    Width = 354
    Height = 18
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Change properties for current note'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = False
    StyleElements = [seClient, seBorder]
  end
  object Button_OK: TButton
    Left = 15
    Top = 465
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = Button_OKClick
  end
  object Button_Cancel: TButton
    Left = 103
    Top = 465
    Width = 75
    Height = 25
    Hint = 'Discard changes and close dialog box'
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = Button_CancelClick
  end
  object Pages: TPage95Control
    Left = 3
    Top = 28
    Width = 369
    Height = 376
    ActivePage = Tab_Tree
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    HotTrack = False
    TabInactiveColor = clBtnFace
    TabInactiveFont.Charset = DEFAULT_CHARSET
    TabInactiveFont.Color = clWindowText
    TabInactiveFont.Height = -11
    TabInactiveFont.Name = 'Tahoma'
    TabInactiveFont.Style = []
    ParentFont = False
    TabOrder = 2
    object Tab_Main: TTab95Sheet
      HelpContext = 254
      Caption = 'Note settings'
      GripAlign = gaLeft
      ImageIndex = -1
      StaticPageIndex = -1
      TabVisible = True
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GBox_Note: TGroupBox
        Left = 3
        Top = 3
        Width = 354
        Height = 337
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Label_TabSize: TLabel
          Left = 203
          Top = 120
          Width = 77
          Height = 14
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Tab &Size:'
          FocusControl = Spin_TabSize
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label1: TLabel
          Left = 15
          Top = 12
          Width = 74
          Height = 13
          AutoSize = False
          Caption = '&Note name:'
          FocusControl = Edit_NoteName
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label4: TLabel
          Left = 260
          Top = 12
          Width = 74
          Height = 13
          AutoSize = False
          Caption = 'Note &icon:'
          FocusControl = Combo_Icons
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label_EditorFonts: TLabel
          Left = 7
          Top = 258
          Width = 244
          Height = 13
          Caption = 'Default font and background color (Editor): '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
        end
        object Label14: TLabel
          Left = 30
          Top = 175
          Width = 58
          Height = 18
          AutoSize = False
          Caption = '&Language:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label_EditorSettings: TLabel
          Left = 7
          Top = 72
          Width = 116
          Height = 13
          Caption = 'RTF editor  settings: '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
        end
        object LB_Zoom: TLabel
          Left = 167
          Top = 95
          Width = 113
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Default Zoom (%)'
          FocusControl = Combo_Icons
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label3: TLabel
          Left = 171
          Top = 94
          Width = 17
          Height = 22
          Hint = 
            'Allows to use a default value other than 100%'#13#10'( Only as default' +
            's )'
          AutoSize = False
          Caption = '(*)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label6: TLabel
          Left = 305
          Top = 213
          Width = 17
          Height = 22
          Hint = 'Save as plain text (Not used as defaults)'
          AutoSize = False
          Caption = '(*)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object LB_PlainText: TLabel
          Left = 33
          Top = 214
          Width = 265
          Height = 13
          Hint = 
            'Normally, note contents are saved as Rich Text.'#13#10'If this option ' +
            'is checked, contents of this note will be saved as plain text (a' +
            'll formatting will be removed).'#13#10#13#10'( Not used as defaults )'
          AutoSize = False
          Caption = '&Plain text only'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Transparent = True
          StyleElements = [seClient, seBorder]
          OnClick = LB_PlainTextClick
        end
        object CB_WordWrap: TCheckBox
          Left = 15
          Top = 94
          Width = 152
          Height = 17
          Hint = 'Apply word-wrapping to long lines'
          Caption = '&Wrap long lines'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object CB_URLDetect: TCheckBox
          Left = 15
          Top = 143
          Width = 272
          Height = 17
          Hint = 'Highlight URLs in editor'
          Caption = 'Detect and highlight &URLs in editor'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
        end
        object CB_UseTabChar: TCheckBox
          Left = 15
          Top = 119
          Width = 203
          Height = 17
          Hint = 'Insert TAB character (#9) when Tab key pressed'
          Caption = 'Use &Tab character'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = CB_UseTabCharClick
        end
        object Spin_TabSize: TSpinEdit
          Left = 286
          Top = 117
          Width = 56
          Height = 22
          Hint = 'Number of spaces to insert when Tab key pressed'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 2
          MaxValue = 32
          MinValue = 1
          ParentFont = False
          TabOrder = 5
          Value = 4
        end
        object Edit_NoteName: TComboBox
          Left = 17
          Top = 30
          Width = 234
          Height = 21
          Hint = 'Enter name for new note'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnKeyPress = Edit_NoteNameKeyPress
        end
        object Combo_Icons: TGFXComboBox
          Left = 261
          Top = 30
          Width = 79
          Height = 22
          Hint = 'Click to select icon for note'
          Extended = False
          DropDownCount = 10
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object Combo_DefEdLang: TLanguagesCombo
          Left = 94
          Top = 172
          Width = 246
          Height = 22
          Language = 2048
          LanguageType = ltInstalled
          ViewType = lvtLocalized
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowFlag = False
          ShowHint = True
          TabOrder = 7
        end
        object CB_Zoom: TComboBox
          Left = 286
          Top = 90
          Width = 56
          Height = 21
          Hint = 'Allows to use a default value other than 100%'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnExit = CB_ZoomExit
          OnKeyPress = CB_ZoomKeyPress
          Items.Strings = (
            '250'
            '200'
            '150'
            '125'
            '110'
            '100'
            '90'
            '80'
            '75')
        end
        object CB_PlainText: TCheckBox
          Left = 15
          Top = 212
          Width = 17
          Height = 17
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 8
          StyleElements = [seClient, seBorder]
          OnClick = CB_PlainTextClick
        end
        object BitBtn_NoteHelp: TBitBtn
          Left = 129
          Top = 67
          Width = 25
          Height = 25
          ImageIndex = 60
          Images = Form_Main.IMG_Toolbar
          TabOrder = 9
          TabStop = False
          OnClick = BitBtn_NoteHelpClick
        end
        object BitBtn_NoteChromeHelp: TBitBtn
          Left = 257
          Top = 251
          Width = 25
          Height = 25
          ImageIndex = 60
          Images = Form_Main.IMG_Toolbar
          TabOrder = 10
          TabStop = False
          OnClick = BitBtn_NoteChromeHelpClick
        end
        object CB_InheritBGColor: TCheckBox
          Left = 131
          Top = 312
          Width = 218
          Height = 17
          TabStop = False
          Caption = 'Inherit &BG color from active node'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 11
        end
      end
    end
    object Tab_Tree: TTab95Sheet
      HelpContext = 255
      Caption = 'Tree settings'
      GripAlign = gaLeft
      ImageIndex = -1
      StaticPageIndex = -1
      TabVisible = True
      object GBox_Tree: TGroupBox
        Left = 2
        Top = 3
        Width = 349
        Height = 337
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object Label5: TLabel
          Left = 17
          Top = 27
          Width = 108
          Height = 26
          Caption = 'Default &Name for new tree nodes:'
          FocusControl = Edit_NodeName
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object Label_TreeSettings: TLabel
          Left = 7
          Top = 91
          Width = 84
          Height = 13
          Caption = ' Tree settings: '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
        end
        object Label2: TLabel
          Left = 18
          Top = 196
          Width = 95
          Height = 13
          Caption = 'I&mage icons in tree:'
          FocusControl = Combo_TreeImages
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Label8: TLabel
          Left = 7
          Top = 258
          Width = 237
          Height = 13
          Caption = 'Default font and background color (Tree): '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = False
        end
        object CB_TreeCheck: TCheckBox
          Left = 18
          Top = 141
          Width = 277
          Height = 17
          Hint = 'Display or hide checkboxes in ALL nodes'
          Caption = '&Show checkboxes in all nodes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
        object Edit_NodeName: TComboBox
          Left = 132
          Top = 25
          Width = 176
          Height = 21
          Hint = 'Enter default name for nodes added to tree'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object CB_AutoNumberNodes: TCheckBox
          Left = 144
          Top = 53
          Width = 188
          Height = 17
          Hint = 'When adding a node, append sequential number to its name'
          Caption = '&Append sequential number'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object BitBtn_TknHlp: TBitBtn
          Left = 315
          Top = 23
          Width = 25
          Height = 25
          Hint = 'Help for auto-naming tree nodes'
          ImageIndex = 60
          Images = Form_Main.IMG_Toolbar
          TabOrder = 6
          TabStop = False
        end
        object CB_Vertical: TCheckBox
          Left = 18
          Top = 118
          Width = 277
          Height = 17
          Hint = 'Check to show tree ABOVE the editor'
          Caption = '&Vertical layout (tree on top)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object Combo_TreeImages: TComboBox
          Left = 132
          Top = 193
          Width = 176
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
        end
        object CB_HideChecked: TCheckBox
          Left = 18
          Top = 165
          Width = 277
          Height = 17
          Hint = 'Show or hide checked nodes'
          Caption = '&Hide checked nodes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
        end
        object BitBtn_TreeChromeHelp: TBitBtn
          Left = 257
          Top = 251
          Width = 25
          Height = 25
          ImageIndex = 60
          Images = Form_Main.IMG_Toolbar
          TabOrder = 7
          TabStop = False
          OnClick = BitBtn_TreeChromeHelpClick
        end
        object CB_TreeChrome_AllNotes: TCheckBox
          Left = 21
          Top = 312
          Width = 180
          Height = 17
          Hint = 
            'Font and BG color will be changed in the panels of ALL tree note' +
            's in current file'
          TabStop = False
          Caption = 'A&pply to ALL tree notes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 8
        end
      end
    end
  end
  object BTN_Font: TBitBtn
    Left = 29
    Top = 337
    Width = 30
    Height = 25
    Hint = 'Change initial Font'
    ImageIndex = 11
    Images = Form_Main.IMG_Format
    TabOrder = 3
    OnClick = BTN_FontClick
  end
  object BTN_Color: TBitBtn
    Left = 62
    Top = 337
    Width = 30
    Height = 25
    Hint = 'Change Background Color'
    ImageIndex = 10
    Images = Form_Main.IMG_Format
    TabOrder = 4
    OnClick = BTN_ColorClick
  end
  object BTN_Defaults: TBitBtn
    Left = 99
    Top = 337
    Width = 27
    Height = 25
    Hint = 'Reset factory default fonts and colors'
    ImageIndex = 6
    Images = Form_Main.IMG_Toolbar
    TabOrder = 5
    OnClick = BTN_DefaultsClick
  end
  object Edit_Sample: TEdit
    Left = 140
    Top = 337
    Width = 209
    Height = 21
    TabStop = False
    MaxLength = 127
    ReadOnly = True
    TabOrder = 7
  end
  object Button_Help: TButton
    Left = 287
    Top = 465
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 8
    OnClick = Button_HelpClick
  end
  object GB_Defaults: TGroupBox
    Left = 5
    Top = 406
    Width = 367
    Height = 53
    TabOrder = 6
    object CB_SaveDefaults: TCheckBox
      Left = 10
      Top = 7
      Width = 344
      Height = 17
      Caption = 'Save as Defaults'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      StyleElements = [seClient, seBorder]
      OnClick = CB_SaveDefaultsClick
    end
    object CB_SaveAsDef: TCheckBox
      Left = 44
      Top = 28
      Width = 303
      Height = 17
      Hint = 
        'Normally, properties are saved as defaults for all new notes you' +
        ' create. '#13#10'You can define it as default only for the current fil' +
        'e.'
      Caption = 'Only for'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      StyleElements = [seClient, seBorder]
      OnClick = CB_SaveAsDefClick
    end
  end
  object ColorDlg: TColorDialog
    Options = [cdFullOpen, cdSolidColor, cdAnyColor]
    Left = 221
    Top = 464
  end
  object FontDlg: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [fdEffects, fdForceFontExist]
    Left = 194
    Top = 467
  end
  object FormPlacement: TFormPlacement
    IniSection = 'PropDlg'
    Options = [fpPosition]
    UseRegistry = True
    Left = 245
    Top = 463
  end
end
