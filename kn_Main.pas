unit kn_Main;

(****** LICENSE INFORMATION **************************************************

 - This Source Code Form is subject to the terms of the Mozilla Public
 - License, v. 2.0. If a copy of the MPL was not distributed with this
 - file, You can obtain one at http://mozilla.org/MPL/2.0/.

------------------------------------------------------------------------------
 (c) 2007-2023 Daniel Prado Velasco <dprado.keynote@gmail.com> (Spain) [^]
 (c) 2000-2005 Marek Jedlinski <marek@tranglos.com> (Poland)

 [^]: Changes since v. 1.7.0. Fore more information, please see 'README.md'
     and 'doc/README_SourceCode.txt' in https://github.com/dpradov/keynote-nf

 *****************************************************************************)

{.$DEFINE DEBUG_IMG}

interface

uses
   Winapi.Windows,
   Winapi.Messages,
   Winapi.RichEdit,
   Winapi.ShellAPI,
   Winapi.MMSystem,
   System.SysUtils,
   System.Classes,
   System.IniFiles,
   System.ImageList,
   Vcl.Graphics,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.Dialogs,
   Vcl.Menus,
   Vcl.ComCtrls,
   Vcl.Samples.Spin,
   Vcl.ExtDlgs,
   Vcl.FileCtrl,
   Vcl.StdCtrls,
   Vcl.Clipbrd,
   Vcl.ExtCtrls,
   Vcl.HtmlHelpViewer,
   Vcl.ImgList,

   ComCtrls95,
   SystemImageList,
   cmpGFXListBox,
   TB97Ctls,
   TB97,
   TB97Tlbr,
   MRUFList,
   RxPlacemnt,
   RxRichEd,
   RXShell,
   RxNotify,
   RXCombos,
   RXCtrls,
   //RxGIF {, jpeg},
   TopWnd,
   ColorPicker,
   TreeNT,
   RichPrint,

   kn_Info,
   kn_Msgs,
   kn_NoteObj
   ;


  function DoMessageBox (text: string;
        DlgType: TMsgDlgType;  Buttons: TMsgDlgButtons;
        HelpCtx: Longint = 0; hWnd: HWND= 0): integer; overload;
  function PopUpMessage( const mStr : string; const mType : TMsgDlgType; const mButtons : TMsgDlgButtons;
        const mHelpCtx : integer) : word; overload;


type
  // cracker class, enables us to get at the protected
  // .EditorHandle property of the combo box control.
  // We need the handle so that we can send EM_xxx messages
  // to the control for undo, canundo, copy, paste, etc.
  TEditHandleComboBox = class( TCustomComboBox );
  TWordWrapMemo = class( TCustomMemo );

type
  TForm_Main = class(TForm)
    Menu_Main: TMainMenu;
    MMFile_: TMenuItem;
    MMEdit_: TMenuItem;
    MMNote_: TMenuItem;
    MMFormat_: TMenuItem;
    MMTools_: TMenuItem;
    MMHelp_: TMenuItem;
    MMSearch_: TMenuItem;
    MMView_: TMenuItem;
    MMHelpTip: TMenuItem;
    MMHelpAbout: TMenuItem;
    MMToolsOptions: TMenuItem;
    MMNoteNew: TMenuItem;
    MMNoteProperties: TMenuItem;
    N2: TMenuItem;
    MMNoteRemove: TMenuItem;
    MMFind: TMenuItem;
    MMFindNext: TMenuItem;
    MMFileNew: TMenuItem;
    MMFileProperties: TMenuItem;
    N3: TMenuItem;
    MMFileOpen: TMenuItem;
    MM_MRUSeparator_: TMenuItem;
    MMFileCopyTo: TMenuItem;
    MMFileExit: TMenuItem;
    FormStorage: TFormStorage;
    MRU: TdfsMRUFileList;
    StatusBar: TStatusBar;
    MMFileSave: TMenuItem;
    MMFileSaveAs: TMenuItem;
    N5: TMenuItem;
    MMFileAutoSave: TMenuItem;
    N6: TMenuItem;
    MMToolsExport: TMenuItem;
    MMToolsImport: TMenuItem;
    MMFileClose: TMenuItem;
    Dock_Top: TDock97;
    Toolbar_Main: TToolbar97;
    TB_FileSave: TToolbarButton97;
    TB_FileNew: TToolbarButton97;
    TB_FileOpen: TToolbarButton97;
    TB_EditCut: TToolbarButton97;
    sm3: TToolbarSep97;
    sm4: TToolbarSep97;
    TB_EditUndo: TToolbarButton97;
    TB_EditCopy: TToolbarButton97;
    TB_EditPaste: TToolbarButton97;
    Timer: TTimer;
    WinOnTop: TTopMostWindow;
    TrayIcon: TRxTrayIcon;
    MMNoteRename: TMenuItem;
    Menu_Tray: TPopupMenu;
    TMRestore: TMenuItem;
    N8: TMenuItem;
    TMExit: TMenuItem;
    Pages: TPage95Control;
    Menu_RTF: TPopupMenu;
    RTFMCut: TMenuItem;
    Menu_TAB: TPopupMenu;
    TAM_NewTab: TMenuItem;
    IMG_Toolbar: TImageList;
    TB_NoteDelete: TToolbarButton97;
    sm5: TToolbarSep97;
    TB_NoteNew: TToolbarButton97;
    TB_NoteEdit: TToolbarButton97;
    sm9: TToolbarSep97;
    //TB_Exit: TToolbarButton97;
    TB_Options: TToolbarButton97;
    sm10: TToolbarSep97;
    MMNoteReadOnly: TMenuItem;
    MMFormatWordWrap: TMenuItem;
    MMEditUndo: TMenuItem;
    N9: TMenuItem;
    MMEditCut: TMenuItem;
    MMEditCopy: TMenuItem;
    MMEditPaste: TMenuItem;
    MMEditDelete: TMenuItem;
    N10: TMenuItem;
    MMEditSelectAll: TMenuItem;
    N11: TMenuItem;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    MMEditRedo: TMenuItem;
    TB_EditRedo: TToolbarButton97;
    MMEditPasteAsText: TMenuItem;
    Toolbar_Format: TToolbar97;
    Combo_Font: TFontComboBox;
    sf1: TToolbarSep97;
    sf2: TToolbarSep97;
    TB_AlignLeft: TToolbarButton97;
    TB_Bold: TToolbarButton97;
    TB_Italics: TToolbarButton97;
    TB_Underline: TToolbarButton97;
    sf3: TToolbarSep97;
    TB_Strikeout: TToolbarButton97;
    TB_Bullets: TToolbarButton97;
    TB_AlignCenter: TToolbarButton97;
    sf4: TToolbarSep97;
    TB_AlignRight: TToolbarButton97;
    TB_Outdent: TToolbarButton97;
    TB_Indent: TToolbarButton97;
    IMG_Format: TImageList;
    TB_FileMgr: TToolbarButton97;
    sm2: TToolbarSep97;
    N12: TMenuItem;
    MMFontStyle_: TMenuItem;
    MMFormatBold: TMenuItem;
    MMFormatItalics: TMenuItem;
    MMFormatUnderline: TMenuItem;
    MMFormatStrikeout: TMenuItem;
    N13: TMenuItem;
    MMFormatClearFontAttr: TMenuItem;
    MMParastyle_: TMenuItem;
    MMAlignment_: TMenuItem;
    MMFormatAlignLeft: TMenuItem;
    MMFormatAlignCenter: TMenuItem;
    MMFormatAlignRight: TMenuItem;
    MMFormatBullets: TMenuItem;
    MMFormatLIndInc: TMenuItem;
    MMFormatLIndDec: TMenuItem;
    N14: TMenuItem;
    MMFormatFont: TMenuItem;
    MMFormatTextColor: TMenuItem;
    MMFormatBGColor: TMenuItem;
    MMViewOnTop: TMenuItem;
    MMFileManager: TMenuItem;
    FontDlg: TFontDialog;
    ColorDlg: TColorDialog;
    N16: TMenuItem;
    TAM_Properties: TMenuItem;
    TAM_Renametab: TMenuItem;
    N17: TMenuItem;
    TAM_Delete: TMenuItem;
    N18: TMenuItem;
    RTFMCopy: TMenuItem;
    RTFMPaste: TMenuItem;
    RTFMPasteAsText: TMenuItem;
    RTFMDelete: TMenuItem;
    N19: TMenuItem;
    RTFMWordwrap: TMenuItem;
    N20: TMenuItem;
    RTFMUndo: TMenuItem;
    N21: TMenuItem;
    RTFMSelectall: TMenuItem;
    N22: TMenuItem;
    MMViewTBMain: TMenuItem;
    MMViewTBFormat: TMenuItem;
    N23: TMenuItem;
    TB_FindNext: TToolbarButton97;
    TB_Find: TToolbarButton97;
    sm6: TToolbarSep97;
    N15: TMenuItem;
    MMInsertDate: TMenuItem;
    MMInsertTime: TMenuItem;
    MMFindGoTo: TMenuItem;
    N25: TMenuItem;
    RTFMProperties: TMenuItem;
    MMCopyFormat_: TMenuItem;
    MMPasteFormat_: TMenuItem;
    MMFormatCopyFont: TMenuItem;
    MMFormatCopyPara: TMenuItem;
    MMFormatPasteFont: TMenuItem;
    MMFormatPastePara: TMenuItem;
    TB_FileInfo: TToolbarButton97;
    sm1: TToolbarSep97;
    N4: TMenuItem;
    MMShiftTab_: TMenuItem;
    MMViewShiftTabLeft: TMenuItem;
    MMViewShiftTabRight: TMenuItem;
    sf7: TToolbarSep97;
    MMFontsize_: TMenuItem;
    MMFormatFontSizeInc: TMenuItem;
    MMFormatFontSizeDec: TMenuItem;
    N24: TMenuItem;
    TAM_ActiveName: TMenuItem;
    FolderMon: TRxFolderMonitor;
    N26: TMenuItem;
    MMEditJoin: TMenuItem;
    MMEditCase_: TMenuItem;
    MMEditUpper: TMenuItem;
    MMEditLower: TMenuItem;
    MMEditMixed: TMenuItem;
    MMEditDelLine: TMenuItem;
    TB_FontDlg: TToolbarButton97;
    MMNotePrint: TMenuItem;
    PrintDlg: TPrintDialog;
    N27: TMenuItem;
    MMNoteClipCapture: TMenuItem;
    N28: TMenuItem;
    MMFilePageSetup: TMenuItem;
    MMNotePrintPreview_: TMenuItem;
    MMEditCopyAll: TMenuItem;
    MMEditPasteAsNewNote: TMenuItem;
    MMEditRot13: TMenuItem;
    MMNoteEmail: TMenuItem;
    TB_EmailNote: TToolbarButton97;
    TB_ClipCap: TToolbarButton97;
    sm8: TToolbarSep97;
    N7: TMenuItem;
    MMViewAlphaTabs: TMenuItem;
    MMEditSort: TMenuItem;
    N29: TMenuItem;
    MMViewTabIcons: TMenuItem;
    Menu_TV: TPopupMenu;
    TVInsertNode: TMenuItem;
    TVAddNode: TMenuItem;
    TVAddChildNode: TMenuItem;
    N30: TMenuItem;
    TVDeleteNode: TMenuItem;
    N31: TMenuItem;
    TVSortNodes_: TMenuItem;
    N32: TMenuItem;
    TVRenameNode: TMenuItem;
    TVPasteNode_: TMenuItem;
    TVPasteNodeName: TMenuItem;
    TVPasteNodeNameAsDate: TMenuItem;
    TVPasteNodeNameAsTime: TMenuItem;
    TVPasteNodeNameAsDateTime: TMenuItem;
    TVSortSubtree: TMenuItem;
    TVSortTree: TMenuItem;
    MRUMenu: TPopupMenu;
    MruM_MRUSeparatorBTN_: TMenuItem;
    N33: TMenuItem;
    MMTree_: TMenuItem;
    MMTreeAdd_: TMenuItem;
    Toolbar_Tree: TToolbar97;
    IMG_TV: TImageList;
    MMViewToolbars_: TMenuItem;
    MMViewTBTree: TMenuItem;
    MMTreeInsert_: TMenuItem;
    MMTreeAddChild_: TMenuItem;
    MMTreeNodeDelete_: TMenuItem;
    N34: TMenuItem;
    MMTreeNodeRename_: TMenuItem;
    MMNodePaste_: TMenuItem;
    MMTreeNodeNameAsDateTime: TMenuItem;
    MMTreeNodeNameAsTime: TMenuItem;
    MMTreeNodeNameAsDate: TMenuItem;
    MMTreeNodeNamePaste: TMenuItem;
    N36: TMenuItem;
    MMTreeSort_: TMenuItem;
    MMTreeSortFull_: TMenuItem;
    MMTreeSortSubtree_: TMenuItem;
    Dock_Left: TDock97;
    MMTreeFullExpand: TMenuItem;
    MMTreeFullCollapse: TMenuItem;
    MMViewNodeIcons: TMenuItem;
    TVDeleteChildren: TMenuItem;
    N40: TMenuItem;
    TVMovenode_: TMenuItem;
    TVMoveNodeUp: TMenuItem;
    TVMoveNodeDown: TMenuItem;
    TVMoveNodeLeft: TMenuItem;
    TVMoveNodeRight: TMenuItem;
    MMTreeDeleteSubtree_: TMenuItem;
    N41: TMenuItem;
    MMMovenode_: TMenuItem;
    MMTreeMoveNodeRight_: TMenuItem;
    MMTreeMoveNodeLeft_: TMenuItem;
    MMTreeMoveNodeDown_: TMenuItem;
    MMTreeMoveNodeUp_: TMenuItem;
    MMToolsDefaults: TMenuItem;
    MMToolsMerge: TMenuItem;
    N35: TMenuItem;
    TVCopyNodeName: TMenuItem;
    N42: TMenuItem;
    N43: TMenuItem;
    RTFMWordWeb: TMenuItem;
    TB_WordWeb: TToolbarButton97;
    sm7: TToolbarSep97;
    N44: TMenuItem;
    TVVirtualNode: TMenuItem;
    N45: TMenuItem;
    MMFormatClearParaAttr: TMenuItem;
    MMFormatRIndInc: TMenuItem;
    MMFormatRIndDec: TMenuItem;
    MMEditLines_: TMenuItem;
    MMEditEvaluate: TMenuItem;
    MMEditEval_: TMenuItem;
    MMEditPasteEval: TMenuItem;
    MMFindNode: TMenuItem;
    MMFindNodeNext: TMenuItem;
    N39: TMenuItem;
    MMFormatSubscript: TMenuItem;
    N47: TMenuItem;
    MMFormatDisabled: TMenuItem;
    MMFormatSpBefInc: TMenuItem;
    MMFormatSpBefDec: TMenuItem;
    MMFormatSpAftInc: TMenuItem;
    MMFormatSpAftDec: TMenuItem;
    N48: TMenuItem;
    MMLineSpacing_: TMenuItem;
    MMFormatLS1: TMenuItem;
    MMFormatLS15: TMenuItem;
    MMFormatLS2: TMenuItem;
    MMEditRepeat: TMenuItem;
    RTFMRepeatCmd: TMenuItem;
    Toolbar_Style: TToolbar97;
    Combo_Style: TComboBox;
    TB_Style: TToolbarButton97;
    MMEditTransform_: TMenuItem;
    MMEditReverse: TMenuItem;
    MMViewTBStyle: TMenuItem;
    Menu_Style: TPopupMenu;
    MSStyleApply: TMenuItem;
    MSStyleFont: TMenuItem;
    MSStylePara: TMenuItem;
    MSStyleBoth: TMenuItem;
    N50: TMenuItem;
    MSStyleRename: TMenuItem;
    MSStyleDelete: TMenuItem;
    ToolbarSep9717: TToolbarSep97;
    N51: TMenuItem;
    MMFormatFIndInc: TMenuItem;
    MMFormatFindDec: TMenuItem;
    Dock_Bottom: TDock97;
    N52: TMenuItem;
    MSStyleDescribe: TMenuItem;
    N53: TMenuItem;
    MMFormatHighlight: TMenuItem;
    MSStyleRedef: TMenuItem;
    N54: TMenuItem;
    MMFormatView_: TMenuItem;
    MMViewFormatFont: TMenuItem;
    MMViewFormatPara: TMenuItem;
    MMViewFormatBoth: TMenuItem;
    N55: TMenuItem;
    MMViewFormatNone: TMenuItem;
    MMFormatNoHighlight: TMenuItem;
    N49: TMenuItem;
    TB_Color: TColorBtn;
    TB_Hilite: TColorBtn;
    TVTransfer_: TMenuItem;
    TVCopySubtree: TMenuItem;
    TVGraftSubtree: TMenuItem;
    N56: TMenuItem;
    TVEraseTreeMem: TMenuItem;
    MMInsertTerm: TMenuItem;
    MMToolsGlosAddTerm: TMenuItem;
    TVExport: TMenuItem;
    N58: TMenuItem;
    MMEditTrim_: TMenuItem;
    MMEditTrimLeft: TMenuItem;
    MMEditTrimRight: TMenuItem;
    N60: TMenuItem;
    MMEditTrimBoth: TMenuItem;
    MMEditCompress: TMenuItem;
    MMEditPasteOther_: TMenuItem;
    MMEditInvertCase: TMenuItem;
    N59: TMenuItem;
    N62: TMenuItem;
    MMInsertCharacter: TMenuItem;
    MMFindBracket: TMenuItem;
    N63: TMenuItem;
    MMToolsStatistics: TMenuItem;
    MMFormatSuperscript: TMenuItem;
    N46: TMenuItem;
    MMBkmSet_: TMenuItem;
    MMBkmJump_: TMenuItem;
    MMBkmSet1: TMenuItem;
    MMBkmSet2: TMenuItem;
    MMBkmSet0: TMenuItem;
    MMBkmSet3: TMenuItem;
    MMBkmSet4: TMenuItem;
    MMBkmSet5: TMenuItem;
    MMBkmSet6: TMenuItem;
    MMBkmSet7: TMenuItem;
    MMBkmSet8: TMenuItem;
    MMBkmSet9: TMenuItem;
    MMBkmJ0: TMenuItem;
    MMBkmJ1: TMenuItem;
    MMBkmJ2: TMenuItem;
    MMBkmJ3: TMenuItem;
    MMBkmJ4: TMenuItem;
    MMBkmJ5: TMenuItem;
    MMBkmJ6: TMenuItem;
    MMBkmJ8: TMenuItem;
    MMBkmJ7: TMenuItem;
    MMBkmJ9: TMenuItem;
    MMInsert_: TMenuItem;
    N65: TMenuItem;
    MMInsertWordWeb: TMenuItem;
    N57: TMenuItem;
    MMFormatParagraph: TMenuItem;
    MMInsertLinkToFile: TMenuItem;
    MMInsertObject: TMenuItem;
    MMInsertPicture: TMenuItem;
    MMEditPasteSpecial: TMenuItem;
    MMEditPasteAsWebClip: TMenuItem;
    N67: TMenuItem;
    MMInsertFileContents: TMenuItem;
    N68: TMenuItem;
    N69: TMenuItem;
    MMToolsGlosEdit: TMenuItem;
    N70: TMenuItem;
    RTFMFont: TMenuItem;
    RTFMPara: TMenuItem;
    TB_ParaDlg: TToolbarButton97;
    TVRefreshVirtualNode: TMenuItem;
    N72: TMenuItem;
    MMHelpVisitWebsite: TMenuItem;
    MMHelpEmailAuthor: TMenuItem;
    Combo_FontSize: TComboBox;
    MMInsertMarkLocation: TMenuItem;
    MMInsertKNTLink: TMenuItem;
    MMFindReplace: TMenuItem;
    MMFindReplaceNext: TMenuItem;
    N74: TMenuItem;
    MMInsertURL: TMenuItem;
    MMFormatApplyStyle: TMenuItem;
    N73: TMenuItem;
    MMToolsPluginRun: TMenuItem;
    MMToolsPluginRunLast: TMenuItem;
    N75: TMenuItem;
    Toolbar_Macro: TToolbar97;
    ToolbarSep9715: TToolbarSep97;
    TB_Macro: TToolbarButton97;
    TB_MacroPause: TToolbarButton97;
    TB_MacroRecord: TToolbarButton97;
    Menu_Macro: TPopupMenu;
    MacMMacro_Play: TMenuItem;
    N66: TMenuItem;
    MacMMacro_Edit: TMenuItem;
    MacMMacro_Delete: TMenuItem;
    N76: TMenuItem;
    MMViewTBAll: TMenuItem;
    MMViewTBHideAll: TMenuItem;
    Sep9719: TToolbarSep97;
    N77: TMenuItem;
    MMToolsMacroRun: TMenuItem;
    N78: TMenuItem;
    MacMMacroUserCommand: TMenuItem;
    MMToolsMacroSelect: TMenuItem;
    MMTreeSaveToFile: TMenuItem;
    N79: TMenuItem;
    MMHelpKeyboardRef: TMenuItem;
    MMHelpMain: TMenuItem;
    MMTemplates_: TMenuItem;
    MMToolsTemplateCreate: TMenuItem;
    MMToolsTemplateInsert: TMenuItem;
    MMViewCheckboxesAllNodes: TMenuItem;
    N80: TMenuItem;
    TVBoldNode: TMenuItem;
    TVCheckNode: TMenuItem;
    MMViewTree: TMenuItem;
    TVNodeColor_: TMenuItem;
    TVDefaultNodeFont: TMenuItem;
    MMFormatLanguage: TMenuItem;
    MMNoteSpell: TMenuItem;
    Pages_Res: TPage95Control;
    Splitter_Res: TSplitter;
    MMViewResPanel: TMenuItem;
    ResTab_Find: TTab95Sheet;
    ResTab_RTF: TTab95Sheet;
    ResTab_Macro: TTab95Sheet;
    ResTab_Template: TTab95Sheet;
    Res_RTF: TRxRichEdit;
    Dock_ResMacro: TDock97;
    ListBox_ResMacro: TGFXListBox;
    Panel_ResFind: TPanel;
    ListBox_ResTpl: TGFXListBox;
    Menu_Template: TPopupMenu;
    TPLMTplInsert: TMenuItem;
    N83: TMenuItem;
    TPLMTplCreate: TMenuItem;
    TPLMTplDelete: TMenuItem;
    MacMMacro_Record: TMenuItem;
    Ntbk_ResFind: TNotebook;
    Label1: TLabel;
    Combo_ResFind: TComboBox;
    Btn_ResFind: TButton;
    Btn_ResFlip: TButton;
    CB_ResFind_CaseSens: TCheckBox;
    CB_ResFind_WholeWords: TCheckBox;
    CB_ResFind_AllNotes: TCheckBox;
    MMEditSelectWord: TMenuItem;
    ResTab_Plugins: TTab95Sheet;
    Dock_ResPlugins: TDock97;
    Toolbar_Plugins: TToolbar97;
    ToolbarSep9720: TToolbarSep97;
    TB_PluginRun: TToolbarButton97;
    TB_PluginConfigure: TToolbarButton97;
    ToolbarSep9721: TToolbarSep97;
    Menu_Plugins: TPopupMenu;
    PLM_RunPlugin: TMenuItem;
    PLM_ConfigurePlugin: TMenuItem;
    N64: TMenuItem;
    PLM_ReloadPlugins: TMenuItem;
    ListBox_ResPlugins: TGFXListBox;
    Splitter_plugins: TSplitter;
    Panel_ResPlugins: TPanel;
    LB_PluginInfo: TLabel;
    Menu_ResPanel: TPopupMenu;
    ResMHidepanel: TMenuItem;
    N71: TMenuItem;
    ResMMultilineTabs: TMenuItem;
    ResMTabPosition: TMenuItem;
    N81: TMenuItem;
    ResMTop: TMenuItem;
    ResMBottom: TMenuItem;
    ResMLeft: TMenuItem;
    ResMRight: TMenuItem;
    ResMFindTab: TMenuItem;
    ResMScratchTab: TMenuItem;
    ResMMacroTab: TMenuItem;
    ResMTemplateTab: TMenuItem;
    ResMPluginTab: TMenuItem;
    //List_ResFind: TTextListBox;
    FindAllResults: TRxRichEdit;
    MMToolsMacroRunLast: TMenuItem;
    ResMPanelPosition: TMenuItem;
    ResMPanelLeft: TMenuItem;
    ResMPanelRight: TMenuItem;
    N84: TMenuItem;
    Menu_StdEdit: TPopupMenu;
    StdEMUndo: TMenuItem;
    N85: TMenuItem;
    StdEMCut: TMenuItem;
    StdEMCopy: TMenuItem;
    StdEMPaste: TMenuItem;
    StdEMDelete: TMenuItem;
    N86: TMenuItem;
    StdEMSelectAll: TMenuItem;
    N87: TMenuItem;
    MMTreeMasterNode: TMenuItem;
    RG_ResFind_Type: TRadioGroup;
    RG_ResFind_Scope: TRadioGroup;
    TVCopyNode_: TMenuItem;
    TVCopyNodePath: TMenuItem;
    TVCopyNodeText: TMenuItem;
    N88: TMenuItem;
    TVCopyPathtoEditor: TMenuItem;
    Menu_FindAll: TPopupMenu;
    FAMCopytoEditor: TMenuItem;
    FAMCopyAlltoEditor: TMenuItem;
    MMTreeNodeFromSel: TMenuItem;
    TVAddSibling: TMenuItem;
    MMTreeAddSibling_: TMenuItem;
    TVVirtualNode_: TMenuItem;
    ResTab_Favorites: TTab95Sheet;
    ListBox_ResFav: TGFXListBox;
    ResMFavTab: TMenuItem;
    Menu_Fav: TPopupMenu;
    FavMJump: TMenuItem;
    N89: TMenuItem;
    FavMAdd: TMenuItem;
    FavMDel: TMenuItem;
    N90: TMenuItem;
    TVUnlinkVirtualNode: TMenuItem;
    FavMAddExternal: TMenuItem;
    N91: TMenuItem;
    MMEditPasteAsNewNode: TMenuItem;
    StdEMWordWrap: TMenuItem;
    MMTreeOutlineNum: TMenuItem;
    N92: TMenuItem;
    MMHistoryGoBack: TMenuItem;
    MMHistoryGoForward: TMenuItem;
    Sep9722: TToolbarSep97;
    TB_GoForward: TToolbarButton97;
    TB_GoBack: TToolbarButton97;
    TB_Numbers: TToolbarButton97;
    sf6: TToolbarSep97;
    MMFormatNumbers: TMenuItem;
    Menu_Numbers: TPopupMenu;
    MMArabicNumbers: TMenuItem;
    MMLoLetter: TMenuItem;
    MMUpLetter: TMenuItem;
    MMLoRoman: TMenuItem;
    MMUpRoman: TMenuItem;
    N94: TMenuItem;
    N95: TMenuItem;
    TB_Space2: TToolbarButton97;
    TB_Space1: TToolbarButton97;
    TB_Space15: TToolbarButton97;
    N96: TMenuItem;
    N97: TMenuItem;
    N98: TMenuItem;
    N99: TMenuItem;
    TB_Repeat: TToolbarButton97;
    TB_ResPanel: TToolbarButton97;
    TB_WordWrap: TToolbarButton97;
    sf5: TToolbarSep97;
    TB_Print: TToolbarButton97;
    TB_Spell: TToolbarButton97;
    TB_Replace: TToolbarButton97;
    TB_Subscript: TToolbarButton97;
    TB_Superscript: TToolbarButton97;
    TB_OnTop: TToolbarButton97;
    N100: TMenuItem;
    MMHelpWhatsNew: TMenuItem;
    N101: TMenuItem;
    MMViewTBRefresh: TMenuItem;
    TVSelectNodeImage: TMenuItem;
    N102: TMenuItem;
    MMViewCustomIcons: TMenuItem;
    N103: TMenuItem;
    TVNodeTextColor: TMenuItem;
    TVNodeBGColor: TMenuItem;
    MMToolsCustomKBD: TMenuItem;
    N61: TMenuItem;
    N82: TMenuItem;
    MMTreeNodeNameAsSel: TMenuItem;
    N104: TMenuItem;
    TVPasteNodeNameAsSel: TMenuItem;
    MMTreeNav_: TMenuItem;
    MMTreeNavUp: TMenuItem;
    MMTreeNavDown: TMenuItem;
    MMTreeNavLeft: TMenuItem;
    MMTreeNavRight: TMenuItem;
    StdEMPastePlain: TMenuItem;
    MMAddTreeNode_: TMenuItem;
    MMFormatAlignJustify: TMenuItem;
    N38: TMenuItem;
    FavMRef: TMenuItem;
    N105: TMenuItem;
    MMToolsUAS: TMenuItem;
    MMToolsUASConfig: TMenuItem;
    MMEditCycleCase: TMenuItem;
    TB_AlignJustify: TToolbarButton97;
    Combo_Zoom: TComboBox;
    N106: TMenuItem;
    MMViewZoomIn: TMenuItem;
    MMViewZoomOut: TMenuItem;
    MMViewTBSaveConfig: TMenuItem;
    Menu_Paste: TPopupMenu;
    MMP_Paste: TMenuItem;
    MMP_PastePlain: TMenuItem;
    MMP_PasteAsWebClip: TMenuItem;
    N107: TMenuItem;
    MMP_PasteSpecial: TMenuItem;
    MMP_PasteAsNote: TMenuItem;
    MMP_PasteAsNode: TMenuItem;
    Menu_Date: TPopupMenu;
    Menu_Time: TPopupMenu;
    Menu_Symbols: TPopupMenu;
    N108: TMenuItem;
    N109: TMenuItem;
    Toolbar_Insert: TToolbar97;
    ToolbarButton971: TToolbarButton97;
    ToolbarButton972: TToolbarButton97;
    ToolbarButton973: TToolbarButton97;
    MMViewTBInsert: TMenuItem;
    N110: TMenuItem;
    N111: TMenuItem;
    md1: TMenuItem;
    md2: TMenuItem;
    md3: TMenuItem;
    md4: TMenuItem;
    md6: TMenuItem;
    md7: TMenuItem;
    md8: TMenuItem;
    md9: TMenuItem;
    md10: TMenuItem;
    md11: TMenuItem;
    md12: TMenuItem;
    md13: TMenuItem;
    md14: TMenuItem;
    md15: TMenuItem;
    md16: TMenuItem;
    md17: TMenuItem;
    md18: TMenuItem;
    md19: TMenuItem;
    md20: TMenuItem;
    md21: TMenuItem;
    md22: TMenuItem;
    md23: TMenuItem;
    md24: TMenuItem;
    md25: TMenuItem;
    mt1: TMenuItem;
    mt2: TMenuItem;
    mt3: TMenuItem;
    mt4: TMenuItem;
    mt5: TMenuItem;
    mt6: TMenuItem;
    mt7: TMenuItem;
    mt8: TMenuItem;
    mt9: TMenuItem;
    ms1: TMenuItem;
    ms2: TMenuItem;
    ms3: TMenuItem;
    ms4: TMenuItem;
    ms5: TMenuItem;
    ms6: TMenuItem;
    ms7: TMenuItem;
    ms8: TMenuItem;
    ms9: TMenuItem;
    ms10: TMenuItem;
    MMEditDecimalToRoman: TMenuItem;
    N112: TMenuItem;
    MMEditRomanToDecimal: TMenuItem;
    MMViewStatusBar: TMenuItem;
    FavMProperties: TMenuItem;
    N113: TMenuItem;
    TMClipCap: TMenuItem;
    Img_System: TdfsSystemImageList;
    MMViewHideCheckedNodes: TMenuItem;
    TB_HideChecked: TToolbarButton97;
    TVChildrenCheckbox: TMenuItem;
    CB_ResFind_HiddenNodes: TCheckBox;
    CB_ResFind_Filter: TCheckBox;
    TB_FilterTree: TToolbarButton97;
    MMViewFilterTree: TMenuItem;
    TB_SetAlarm: TToolbarButton97;
    N114: TMenuItem;
    TVAlarmNode: TMenuItem;
    TVGraftSubtreeMirror: TMenuItem;
    TVInsertMirrorNode: TMenuItem;
    N115: TMenuItem;
    TVNavigateNonVirtualNode: TMenuItem;
    TB_AlarmMode: TToolbarButton97;
    NU01: TMenuItem;
    MMRightParenthesis: TMenuItem;
    MMEnclosed: TMenuItem;
    MMPeriod: TMenuItem;
    MMOnlyNumber: TMenuItem;
    MMWithoutNextNumber: TMenuItem;
    MMStartsNewNumber: TMenuItem;
    NU02: TMenuItem;
    MMEditPasteAsWebClipText: TMenuItem;
    MMP_PasteAsWebClipText: TMenuItem;
    MMEditPlainDefaultPaste: TMenuItem;
    N116: TMenuItem;
    N117: TMenuItem;
    MMP_PlainDefaultPaste: TMenuItem;
    TB_CopyFormat: TToolbarButton97;
    ToolbarSep971: TToolbarSep97;
    MMFormatCopy: TMenuItem;
    CB_ResFind_CurrentNodeAndSubtree: TCheckBox;
    Btn_ResFind_Prev: TToolbarButton97;
    Btn_ResFind_Next: TToolbarButton97;
    LblFindAllNumResults: TLabel;
    MMAlternativeMargins: TMenuItem;
    MMShowImages: TMenuItem;
    ToolbarSep972: TToolbarSep97;
    TB_Images: TToolbarButton97;
    N118: TMenuItem;
    RTFMRestoreProportions: TMenuItem;
    RG_ResFind_ChkMode: TRadioGroup;
    TVChildrenCheckboxes_: TMenuItem;
    TVHideCheckedChildren: TMenuItem;
    TVHideUncheckedChildren: TMenuItem;
    TVShowNonFilteredChildren: TMenuItem;
    N119: TMenuItem;
    N120: TMenuItem;
    MMAlarms: TMenuItem;
    MMSetAlarm: TMenuItem;
    MMShowAlarms: TMenuItem;
    MMAlarmsPopup: TMenuItem;
    MMViewHistory: TMenuItem;
    MMHelpChkUpd: TMenuItem;
    N1: TMenuItem;
    MMTreeFocus_: TMenuItem;
    MMTreeFocusToogle: TMenuItem;
    MMTreeFocusEditor: TMenuItem;
    MMTreeFocusTree: TMenuItem;
    MMFindAll: TMenuItem;
    procedure MMStartsNewNumberClick(Sender: TObject);
    procedure MMRightParenthesisClick(Sender: TObject);
    procedure TntFormResize(Sender: TObject);
    procedure TB_AlarmModeMouseEnter(Sender: TObject);
    procedure TB_AlarmModeClick(Sender: TObject);
    procedure TVNavigateNonVirtualNodeClick(Sender: TObject);
    procedure TVInsertMirrorNodeClick(Sender: TObject);
    procedure TVGraftSubtreeMirrorClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure TVAlarmNodeClick(Sender: TObject);
    procedure TB_SetAlarmMouseEnter(Sender: TObject);
    procedure TB_SetAlarmClick(Sender: TObject);
    procedure MMViewFilterTreeClick(Sender: TObject);
    procedure TB_FilterTreeClick(Sender: TObject);
    procedure PagesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TB_HideCheckedClick(Sender: TObject);
    procedure TVChildrenCheckboxClick(Sender: TObject);
    procedure TVHideCheckedChildrenClick(Sender: TObject);
    procedure TVHideUncheckedChildrenClick(Sender: TObject);
    procedure TVShowNonFilteredClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TimerTimer(Sender: TObject);
    procedure TrayIconClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MMFileExitClick(Sender: TObject);
    procedure TMRestoreClick(Sender: TObject);
    procedure MMFileNewClick(Sender: TObject);
    procedure MMFileOpenClick(Sender: TObject);
    procedure MMFileSaveClick(Sender: TObject);
    procedure MMFileSaveAsClick(Sender: TObject);
    procedure MMNoteNewClick(Sender: TObject);
    procedure MMHelpTipClick(Sender: TObject);
    procedure MMFileCloseClick(Sender: TObject);
    procedure MMNoteRenameClick(Sender: TObject);
    procedure MMFilePropertiesClick(Sender: TObject);
    procedure MMFileAutoSaveClick(Sender: TObject);
    procedure RxRTFChange(Sender: TObject);
    procedure RxRTFKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RxRTFProtectChange(Sender: TObject; StartPos,
      EndPos: Integer; var AllowChange: Boolean);
    procedure RxRTFProtectChangeEx(Sender: TObject;
      const Message: TMessage; StartPos, EndPos: Integer;
      var AllowChange: Boolean);
    procedure RxRTFAuxiliarProtectChangeEx(Sender: TObject;
      const Message: TMessage; StartPos, EndPos: Integer;
      var AllowChange: Boolean);
    procedure RxFindAllResultsSelectionChange(Sender: TObject);
    procedure RxRTFSelectionChange(Sender: TObject);
    procedure RxRTFURLClick(Sender: TObject; const URLText: string; Button: TMouseButton);
    procedure RxRTFKeyPress(Sender: TObject; var Key: Char);
    procedure MMEditSelectAllClick(Sender: TObject);
    procedure MMFormatWordWrapClick(Sender: TObject);
    procedure PagesChange(Sender: TObject);
    procedure PagesTabShift(Sender: TObject);
    procedure MMEditCutClick(Sender: TObject);
    procedure MMEditCopyClick(Sender: TObject);
    procedure MMEditPasteClick(Sender: TObject);
    procedure MMEditDeleteClick(Sender: TObject);
    procedure MMEditUndoClick(Sender: TObject);
    procedure MMEditRedoClick(Sender: TObject);
    procedure MMEditPasteAsTextClick(Sender: TObject);
    procedure MMNoteReadOnlyClick(Sender: TObject);
    procedure Combo_FontChange(Sender: TObject);
    procedure MMFormatBoldClick(Sender: TObject);
    procedure MMFormatItalicsClick(Sender: TObject);
    procedure MMFormatUnderlineClick(Sender: TObject);
    procedure MMFormatStrikeoutClick(Sender: TObject);
    procedure MMFormatClearFontAttrClick(Sender: TObject);
    procedure MMFormatBulletsClick(Sender: TObject);
    procedure MMFormatLIndIncClick(Sender: TObject);
    procedure MMFormatLIndDecClick(Sender: TObject);
    procedure MMFormatAlignLeftClick(Sender: TObject);
    procedure MMFormatAlignCenterClick(Sender: TObject);
    procedure MMFormatAlignRightClick(Sender: TObject);
    procedure MMFormatFontClick(Sender: TObject);
    procedure MMFormatTextColorClick(Sender: TObject);
    procedure MMFormatBGColorClick(Sender: TObject);
    procedure MRUMRUItemClick(Sender: TObject; AFilename: string);
    procedure DebugMenuClick(Sender: TObject);
    procedure MMFormatNumbersClick(Sender: TObject);
    procedure MMFormatAlignJustifyClick(Sender: TObject);
    procedure MMToolsOptionsClick(Sender: TObject);
    procedure MMHelpAboutClick(Sender: TObject);
    procedure MMViewOnTopClick(Sender: TObject);
    procedure MMViewTBMainClick(Sender: TObject);
    procedure MMViewTBFormatClick(Sender: TObject);
    procedure MMFileManagerClick(Sender: TObject);
    procedure MMInsertDateClick(Sender: TObject);
    procedure MMInsertTimeClick(Sender: TObject);
    procedure MMNoteRemoveClick(Sender: TObject);
    procedure MMFileCopyToClick(Sender: TObject);
    procedure MMFindGoToClick(Sender: TObject);
    procedure MMToolsImportClick(Sender: TObject);
    procedure MMNotePropertiesClick(Sender: TObject);
    procedure TB_ExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MMSortClick(Sender: TObject);
    procedure MMFormatCopyClick(Sender: TObject);
    procedure MMFormatCopyFontClick(Sender: TObject);
    procedure MMFormatPasteFontClick(Sender: TObject);
    procedure MMFormatCopyParaClick(Sender: TObject);
    procedure MMFormatPasteParaClick(Sender: TObject);
    procedure MMFindClick(Sender: TObject);
    procedure MMFindNextClick(Sender: TObject);
    procedure MMViewShiftTabLeftClick(Sender: TObject);
    procedure MMViewShiftTabRightClick(Sender: TObject);
    procedure MMFormatFontSizeDecClick(Sender: TObject);
    procedure MMFormatFontSizeIncClick(Sender: TObject);
    procedure MMEditJoinClick(Sender: TObject);
    procedure MMEditUpperClick(Sender: TObject);
    procedure MMEditLowerClick(Sender: TObject);
    procedure MMEditMixedClick(Sender: TObject);
    procedure MMEditDelLineClick(Sender: TObject);
    procedure FolderMonChange(Sender: TObject);
    procedure MMNotePrintClick(Sender: TObject);
    procedure MMNoteClipCaptureClick(Sender: TObject);
    procedure MMFilePageSetupClick(Sender: TObject);
    procedure RichPrinterBeginDoc(Sender: TObject);
    procedure RichPrinterEndDoc(Sender: TObject);
    procedure MMNotePrintPreview_Click(Sender: TObject);
    procedure MMEditCopyAllClick(Sender: TObject);
    procedure MMEditPasteAsNewNoteClick(Sender: TObject);
    procedure MMEditRot13Click(Sender: TObject);
    procedure MMNoteEmailClick(Sender: TObject);
    procedure TB_ClipCapClick(Sender: TObject);
    procedure MMViewAlphaTabsClick(Sender: TObject);
    procedure MMViewTabIconsClick(Sender: TObject);
    procedure MMToolsDefaultsClick(Sender: TObject);
    procedure MMToolsMergeClick(Sender: TObject);
    procedure RTFMWordWebClick(Sender: TObject);
    procedure MMHelp_WhatisClick(Sender: TObject);
    procedure MMFormatClearParaAttrClick(Sender: TObject);
    procedure MMFormatRIndIncClick(Sender: TObject);
    procedure MMFormatRIndDecClick(Sender: TObject);
    procedure MathParserParseError(Sender: TObject; ParseError: Integer);
    procedure MMEditEvaluateClick(Sender: TObject);
    procedure MMEditPasteEvalClick(Sender: TObject);

    procedure TVChange(Sender: TObject; Node: TTreeNTNode);
    procedure TVEdited(Sender: TObject; Node: TTreeNTNode; var S: string);
    procedure TVEditCanceled(Sender: TObject);
    procedure TVEditing(Sender: TObject; Node: TTreeNTNode; var AllowEdit: Boolean);
    procedure TVSavingTree(Sender: TObject; Node: TTreeNTNode; var S: string);
    procedure TVDblClick(Sender: TObject);
    procedure TVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TVEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure TVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TVStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure TVAddNodeClick(Sender: TObject);
    (* procedure TVM_SelectIconClick(Sender: TObject); REMOVED *)
    procedure TVInsertNodeClick(Sender: TObject);
    procedure TVAddChildNodeClick(Sender: TObject);
    procedure MMRenamenodeClick(Sender: TObject);
    procedure MMViewTBTreeClick(Sender: TObject);
    procedure TVDeleteNodeClick(Sender: TObject);
    procedure TVDeletion(Sender: TObject; Node: TTreeNTNode);
    procedure MMTreeFullExpandClick(Sender: TObject);
    procedure MMTreeFullCollapseClick(Sender: TObject);
    procedure TVClick(Sender: TObject);
    procedure SplitterNoteMoved(Sender: TObject);
    procedure TVOnHint(Sender: TObject; Node: TTreeNTNode;  var NewText: string);
    procedure CheckRestoreTreeWidth;
    procedure CheckExpandTreeWidth;
    {
    procedure TVBeforeItemPaint(Sender: TObject;
      Node: TTreeNTNode; ItemRect: TRect; NodeStates: TNodeStates;
      var OwnerDraw: Boolean);
    }
    procedure TVSortSubtreeClick(Sender: TObject);
    procedure TVDeleteChildrenClick(Sender: TObject);
    procedure TVSortTreeClick(Sender: TObject);
    procedure TVMoveNodeUpClick(Sender: TObject);
    procedure TVMoveNodeDownClick(Sender: TObject);
    procedure TVMoveNodeLeftClick(Sender: TObject);
    procedure TVMoveNodeRightClick(Sender: TObject);
    procedure TVPasteNodeNameClick(Sender: TObject);
    procedure TVCopyNodeNameClick(Sender: TObject);
    procedure MMViewNodeIconsClick(Sender: TObject);
    procedure TVVirtualNodeClick(Sender: TObject);
    procedure PagesDblClick(Sender: TObject );
    procedure MMFindNodeClick(Sender: TObject);
    procedure MMFindNodeNextClick(Sender: TObject);
    procedure MMMergeNotestoFileClick(Sender: TObject);
    procedure RxRTFMouseDown(Sender: TObject;   Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RxRTFMouseUP(Sender: TObject;   Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RxRTFDblClick(Sender: TObject);
    procedure RxRTFEnter(Sender: TObject);
    procedure TVEnter(Sender: TObject);
    procedure MMFormatDisabledClick(Sender: TObject);
    procedure MMFormatSubscriptClick(Sender: TObject);
    procedure MMFormatSpBefIncClick(Sender: TObject);
    procedure MMFormatSpBefDecClick(Sender: TObject);
    procedure MMFormatSpAftIncClick(Sender: TObject);
    procedure MMFormatSpAftDecClick(Sender: TObject);
    procedure MMFormatLS1Click(Sender: TObject);
    procedure MMFormatLS15Click(Sender: TObject);
    procedure MMFormatLS2Click(Sender: TObject);
    procedure MMEditRepeatClick(Sender: TObject);
    procedure MMEditReverseClick(Sender: TObject);
    procedure MMViewTBStyleClick(Sender: TObject);
    procedure Btn_StyleClick(Sender: TObject);
    procedure BtnStyleApplyClick(Sender: TObject);
    procedure MMFormatFIndIncClick(Sender: TObject);
    procedure MMFormatFindDecClick(Sender: TObject);
    procedure Combo_StyleChange(Sender: TObject);
    procedure MMFormatHighlightClick(Sender: TObject);
    procedure MMViewFormatNoneClick(Sender: TObject);
    procedure MMFormatNoHighlightClick(Sender: TObject);
    procedure TB_ColorClick(Sender: TObject);
    procedure TB_HiliteClick(Sender: TObject);
    procedure TVCopySubtreeClick(Sender: TObject);
    procedure PagesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PagesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MMInsertTermClick(Sender: TObject);
    procedure MMToolsGlosAddTermClick(Sender: TObject);
    procedure Toolbar_FormatClose(Sender: TObject);
    procedure TVExportClick(Sender: TObject);
    procedure MMEditTrimLeftClick(Sender: TObject);
    procedure MMEditCompressClick(Sender: TObject);
    procedure MMEditInvertCaseClick(Sender: TObject);
    procedure MMInsertCharacterClick(Sender: TObject);
    procedure MMFindBracketClick(Sender: TObject);
    procedure MMToolsStatisticsClick(Sender: TObject);
    procedure MMFormatSuperscriptClick(Sender: TObject);
    procedure MMBkmJ9Click(Sender: TObject);
    procedure MMBkmSet9Click(Sender: TObject);
    procedure MMFormatParagraphClick(Sender: TObject);
    procedure MMInsertLinkToFileClick(Sender: TObject);
    procedure MMInsertObjectClick(Sender: TObject);
    procedure MMInsertPictureClick(Sender: TObject);
    procedure MMEditPasteSpecialClick(Sender: TObject);
    procedure MMInsertFileContentsClick(Sender: TObject);
    procedure MMToolsGlosEditClick(Sender: TObject);
    procedure TVRefreshVirtualNodeClick(Sender: TObject);
    procedure MMHelpVisitWebsiteClick(Sender: TObject);
    //procedure MMHelpEmailAuthorClick(Sender: TObject);
    procedure Combo_FontSizeKeyPress(Sender: TObject; var Key: Char);
    procedure Combo_FontSizeClick(Sender: TObject);
    procedure MMInsertMarkLocationClick(Sender: TObject);
    procedure MMInsertKNTLinkClick(Sender: TObject);
    procedure MMFindReplaceClick(Sender: TObject);
    procedure MMFindReplaceNextClick(Sender: TObject);
    procedure MMInsertURLClick(Sender: TObject);
    procedure Combo_StyleKeyPress(Sender: TObject; var Key: Char);
    procedure Toolbar_StyleRecreating(Sender: TObject);
    procedure Toolbar_StyleRecreated(Sender: TObject);
    procedure MMToolsPluginRunClick(Sender: TObject);
    procedure MMToolsPluginRunLastClick(Sender: TObject);
    procedure MacMMacro_EditClick(Sender: TObject);
    procedure TB_MacroClick(Sender: TObject);
    procedure MacMMacro_DeleteClick(Sender: TObject);
    procedure TB_MacroRecordClick(Sender: TObject);
    procedure TB_MacroPauseClick(Sender: TObject);
    procedure MacMMacroUserCommandClick(Sender: TObject);
    procedure Combo_MacroClick(Sender: TObject);
    procedure Combo_MacroKeyPress(Sender: TObject; var Key: Char);
    procedure MMToolsMacroSelectClick(Sender: TObject);
    procedure MMViewTBHideAllClick(Sender: TObject);
    procedure MMTreeSaveToFileClick(Sender: TObject);
    procedure MMHelpKeyboardRefClick(Sender: TObject);
    procedure MMHelpMainClick(Sender: TObject);
    // procedure MMToolsCalculatorClick(Sender: TObject);
    procedure MMToolsTemplateCreateClick(Sender: TObject);
    procedure MMToolsTemplateInsertClick(Sender: TObject);
    procedure TVKeyPress(Sender: TObject; var Key: Char);
    procedure MMViewCheckboxesAllNodesClick(Sender: TObject);
    procedure TVChecked(Sender: TObject; Node: TTreeNTNode);
    procedure TVChecking(Sender: TObject; Node: TTreeNTNode;
      var AllowCheck: Boolean);
    procedure TVCheckNodeClick(Sender: TObject);
    procedure TVBoldNodeClick(Sender: TObject);
    procedure MMViewTreeClick(Sender: TObject);
    procedure MMFormatLanguageClick(Sender: TObject);
    procedure MMNoteSpellClick(Sender: TObject);
    procedure Markaslink1Click(Sender: TObject);
    procedure Hiddentext1Click(Sender: TObject);
    procedure MMInsHyperlinkClick(Sender: TObject);
    procedure Combo_FontKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MMViewResPanelClick(Sender: TObject);
    procedure Pages_ResChange(Sender: TObject);
    procedure ListBox_ResMacroDblClick(Sender: TObject);
    procedure ListBox_ResTplDblClick(Sender: TObject);
    procedure TPLMTplDeleteClick(Sender: TObject);
    procedure TPLMTplInsertClick(Sender: TObject);
    procedure Menu_RTFPopup(Sender: TObject);
    procedure Splitter_ResMoved(Sender: TObject);
    procedure Btn_ResFlipClick(Sender: TObject);
    procedure VisibilityControlsFindAllResults (Visible: boolean);
    procedure MMEditSelectWordClick(Sender: TObject);
    procedure PLM_ReloadPluginsClick(Sender: TObject);
    procedure ListBox_ResPluginsClick(Sender: TObject);
    procedure PLM_RunPluginClick(Sender: TObject);
    procedure PLM_ConfigurePluginClick(Sender: TObject);
    procedure ResMRightClick(Sender: TObject);
    procedure ResMMultilineTabsClick(Sender: TObject);
    procedure Menu_ResPanelPopup(Sender: TObject);
    procedure ResMPluginTabClick(Sender: TObject);
    procedure MMToolsMacroRunLastClick(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const R: TRect);
    procedure Combo_ResFindChange(Sender: TObject);
    procedure Btn_ResFindClick(Sender: TObject);
    procedure Combo_ResFindKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Combo_FontSizeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
{ // [dpv]
    procedure List_ResFindDblClick(Sender: TObject);
    procedure List_ResFindKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
}
    procedure ResMPanelRightClick(Sender: TObject);
    procedure StdEMSelectAllClick(Sender: TObject);
    procedure Menu_StdEditPopup(Sender: TObject);
    procedure MMTreeMasterNodeClick(Sender: TObject);
    procedure TVCopyNodePathClick(Sender: TObject);
    procedure TVCopyNodeTextClick(Sender: TObject);
    procedure TVCopyPathtoEditorClick(Sender: TObject);
    procedure FAMCopytoEditorClick(Sender: TObject);
    procedure FAMCopyAlltoEditorClick(Sender: TObject);
    procedure RG_ResFind_TypeClick(Sender: TObject);
    procedure MMTreeNodeFromSelClick(Sender: TObject);
    procedure TVAddSiblingClick(Sender: TObject);
    procedure FavMJumpClick(Sender: TObject);
    procedure FavMAddClick(Sender: TObject);
    procedure FavMDelClick(Sender: TObject);
    procedure ListBox_ResFavClick(Sender: TObject);
    procedure ListBox_ResTplClick(Sender: TObject);
    procedure TVUnlinkVirtualNodeClick(Sender: TObject);
    procedure FavMAddExternalClick(Sender: TObject);
    procedure MMEditPasteAsNewNodeClick(Sender: TObject);
    {
    procedure RTFMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    }
    procedure MMTreeOutlineNumClick(Sender: TObject);
    procedure MMHistoryGoBackClick(Sender: TObject);
    procedure MMHistoryGoForwardClick(Sender: TObject);
    procedure MMUpRomanClick(Sender: TObject);
    procedure MMHelpWhatsNewClick(Sender: TObject);
    procedure MMViewTBRefreshClick(Sender: TObject);
    procedure TVSelectNodeImageClick(Sender: TObject);
    procedure TVNodeTextColorClick(Sender: TObject);
    procedure TVDefaultNodeFontClick(Sender: TObject);
    procedure TVNodeBGColorClick(Sender: TObject);
    procedure Res_RTFKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RxRTFStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure RxRTFEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure MMToolsCustomKBDClick(Sender: TObject);
    procedure MMTreeNavRightClick(Sender: TObject);
    procedure MMToolsExportExClick(Sender: TObject);
    procedure FavMRefClick(Sender: TObject);
    procedure MMToolsUASClick(Sender: TObject);
    procedure MMToolsUASConfigClick(Sender: TObject);
    procedure MMEditCycleCaseClick(Sender: TObject);
    procedure Combo_ZoomDblClick(Sender: TObject);
    procedure MMViewZoomInClick(Sender: TObject);
    procedure MMViewZoomOutClick(Sender: TObject);
{ // dpv
    procedure List_ResFindDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
}
    procedure Menu_TVPopup(Sender: TObject);
    procedure MMViewTBSaveConfigClick(Sender: TObject);
    procedure Menu_TimePopup(Sender: TObject);
    procedure Menu_DatePopup(Sender: TObject);
    procedure md25Click(Sender: TObject);
    procedure mt8Click(Sender: TObject);
    procedure ms11Click(Sender: TObject);
    procedure Menu_SymbolsPopup(Sender: TObject);
    procedure MMViewTBInsertClick(Sender: TObject);
    //procedure MMToolsURLClick(Sender: TObject);
    procedure Combo_StyleDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DoBorder1Click(Sender: TObject);
    procedure MMEditDecimalToRomanClick(Sender: TObject);
    procedure MMEditRomanToDecimalClick(Sender: TObject);
    procedure MMViewStatusBarClick(Sender: TObject);
    procedure FavMPropertiesClick(Sender: TObject);
    procedure MMEditPasteAsWebClipClick(Sender: TObject);
    procedure MMEditPasteAsWebClipTextClick(Sender: TObject);
    procedure MMEditPlainDefaultPasteClick(Sender: TObject);
    procedure MMP_PlainDefaultPasteClick(Sender: TObject);
    procedure PlainDefaultPaste_Toggled;

    // Antes privadas...
    procedure AppMinimize(Sender: TObject);
    procedure AppRestore(Sender: TObject);
    procedure DisplayAppHint( sender: TObject );
    procedure ShowException( Sender : TObject; E : Exception );
    procedure TB_CopyFormatClick(Sender: TObject);
    procedure CB_ResFind_AllNotesClick(Sender: TObject);
    procedure Btn_ResFind_PrevClick(Sender: TObject);
    procedure Btn_ResFind_NextClick(Sender: TObject);
    procedure FindAllResultsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Combo_ZoomExit(Sender: TObject);
    procedure Combo_FontSizeExit(Sender: TObject);
    procedure MMAlternativeMarginsClick(Sender: TObject);
    procedure MMShowImagesClick(Sender: TObject);
    procedure TB_ImagesClick(Sender: TObject);
    procedure RTFMRestoreProportionsClick(Sender: TObject);
    procedure MMShowAlarmsClick(Sender: TObject);
    procedure MMAlarmsPopupClick(Sender: TObject);
    procedure MMHelpChkUpdClick(Sender: TObject);
    function FormHelp(Command: Word; Data: NativeInt;
      var CallHelp: Boolean): Boolean;
    procedure MMTreeFocusToogleClick(Sender: TObject);
    procedure MMTreeFocusEditorClick(Sender: TObject);
    procedure MMTreeFocusTreeClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MMFindAllClick(Sender: TObject);

  private
    { Private declarations }
    procedure AppMessage( var Msg : TMsg; var Handled : boolean );
    procedure WMActivate( Var msg: TWMActivate ); message WM_ACTIVATE;
    procedure WMHotkey( Var msg: TWMHotkey ); message WM_HOTKEY; // for Activation Hotkey
    procedure WMQueryEndSession (var Msg : TMessage); message WM_QUERYENDSESSION;
    procedure WndProc( var M : TMessage ); override;
    procedure AppDeactivate( sender : TObject );
    procedure WMChangeCBChain( var Msg : TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard( var Msg : TWMDrawClipboard); message WM_DRAWCLIPBOARD; // for Clipboard capture
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMCopyData(Var msg: TWMCopyData); message WM_COPYDATA; // interprocess comm.
    procedure WMJumpToKNTLink( var Msg : TMessage ); message WM_JUMPTOKNTLINK; // custom
    procedure WMJumpToLocation( var DummyMSG : integer ); message WM_JUMPTOLOCATION; //custom
    procedure WMShowTipOfTheDay( var DummyMSG : integer ); message WM_TIPOFTHEDAY; //custom
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

    procedure FormatCopyClick(AlloMultiMode: Boolean);
    procedure ShowFindAllOptions;
    procedure ExecuteCallArgs (fromKntLauncher: boolean);

  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;

  public

    RichPrinter: TRichPrinter;
    procedure UpdateWordWrap;

(*
    {$IFDEF WITH_TIMER}
    procedure StoreTick( const Msg : string; const Tick : integer );
    procedure SaveTicks;
    {$ENDIF}
*)

    procedure AssignOnMessage;

    function NoteSelText : TRxTextAttributes;

    procedure ActivatePreviousInstance; // sends message to already-running instance and shuts down this instance
    procedure CloseNonModalDialogs; // close all non-modal dialogs that might be open

    // perform commands requested by messages sent from other instances, plugins, etc.
    procedure ProcessControlMessage( const msgID : integer; kntmsg : TKeyNoteMsg  );

    // misc file-related functions
    procedure OnFileDropped( Sender : TObject; FileList : TStringList );

    // sanity checks. Many functions cannot be performed
    // if we have no active note or if the note is read-only
    function HaveNotes( const Warn, CheckCount : boolean ) : boolean;
    function NoteIsReadOnly( const aNote : TTabNote; const Warn : boolean ) : boolean;

    // search / replace
    procedure FindNotify( const Active : boolean );

    procedure GoToEditorLine( s : string );

    procedure FindTreeNode;

    // status bar etc. display updates
    procedure ShowInsMode;
    procedure ShowImages(Show: boolean; ForceMode: boolean);

    // config file management
    procedure SetupToolbarButtons;
    procedure ResolveToolbarRTFv3Dependencies;

    // VCL updates when config loaded or changed
    procedure UpdateStatusBarState;

    procedure UpdateTreeVisible( const ANote : TTreeNote );
    procedure CheckRestoreAppWindowWidth (EnsureTreeVisible: boolean= False);

    procedure UpdateTabAndTreeIconsShow;
    procedure UpdateShowImagesState;
    procedure AutoSaveToggled;
    //procedure GetKeyStates;                   // {Not used}
    procedure OnNoteLoaded( sender : TObject );

    // misc stuff
    procedure ShowAbout;
    procedure NotImplemented( const aStr : string );
    procedure ErrNoTextSelected;
    procedure NewVersionInformation;
    procedure DisplayHistoryFile;

    procedure AnotherInstance;
    procedure ShiftTab( const ShiftRight : boolean );

    procedure NodesDropOnTabProc( const DropTab : TTab95Sheet );

    procedure Form_CharsClosed( sender : TObject );
    procedure CharInsertProc( const ch : Char; const Count : integer; const FontName : string; const FontCharset : TFontCharset; Unicode: boolean= true );

    procedure HotKeyProc( const TurnOn : boolean );

    {$IFDEF WITH_IE}
    function SelectVisibleControlForNode( const aNode : TNoteNode ) : TNodeControl;
    {$ENDIF}

    procedure FilterApplied (note: TTreeNote);   // [dpv]
    procedure FilterRemoved (note: TTreeNote);   // [dpv]
    procedure OnNoteChange(Note: TTabNote);

    procedure ShowAlarmStatus;
    procedure SetAlarm (ConsiderNoteAlarm: Boolean);
  end;

function GetFilePassphrase( const FN : string ) : string;
function IsAParentOf( aPerhapsParent, aChild : TTreeNTNode ) : boolean;
function MillisecondsIdle: DWord;


var
  Form_Main: TForm_Main;


implementation
uses
   Parser,
   gf_misc,
   gf_miscvcl,
   kn_Global,
   kn_Pass,
   kn_Macro,
   kn_Plugins,
   kn_filemgr,
   kn_About,
   kn_DateTime,
   kn_Chest,
   kn_clipUtils,
   kn_LocationObj,
   kn_History,
   kn_EditorUtils,
   kn_LinksMng,
   kn_Cmd,
   kn_Const,
   kn_NodeList,
   kn_StyleObj,
   kn_ImageForm,
   kn_ImagesUtils,
   kn_UpdateVersion,
   kn_ExportNew,
   kn_NoteMng,
   kn_MacroMng,
   kn_PluginsMng,
   kn_TreeNoteMng,
   kn_TemplateMng,
   kn_FindReplaceMng,
   kn_ConfigMng,
   kn_StyleMng,
   kn_FavoritesMng,
   kn_BookmarksMng,
   kn_VirtualNodeMng,
   kn_NoteFileMng,
   kn_AlertMng,
   kn_VCLControlsMng
   {$IFNDEF EXCLUDEEMAIL}
   ,kn_SendMail,
   {$ENDIF}
 {$IFDEF KNT_DEBUG}
   ,GFLog
 {$ENDIF}
   ;

{$R *.DFM}
{$R .\resources\catimages}
{$R .\resources\resources}

resourcestring
  STR_01 = 'Unable to assign "%s" as activation hotkey.';
  STR_02 = 'Unexpcted error while turning %s Activation hotkey "%s": %s';
  STR_03 = '&Restore (%s)';
  STR_04 = '&Restore';
  STR_05 = 'Function key assignment updated';
  STR_06 = 'Revert to last saved version of' + #13 + '%s?';  ////
  STR_07 = 'OK to quit %s?';   ///
  STR_08 = 'Unexpected error:  %s' + #13#13 +      ///
    'This message may indicate a bug in KeyNote NF. If the problem persists, please submit a bug reports with the Issue Manager' +
    ' available in KeyNote NF website: %s' + #13#13 +
    'You can continue working or terminate KeyNote NF. ' + #13 +
    'Terminate application?';
  STR_09 = 'KeyNote NF Error';
  STR_10 = 'Function not implemented. ';
  STR_11 = ' INS';
  STR_12 = ' OVR';
  STR_13 = ' Overwrite mode disabled through INI file';
  STR_14 = 'Tree node not assigned. Text will be lost.' + #13 + 'Please create a tree node first.';
  STR_15_ActiveNote = '(none)';
  STR_16 = ' Select some text before issuing this command.';
  STR_17 = 'You seem to have upgraded KeyNote from version %s to %s.' + #13 +
    'Files "history.txt" and "%s" contain information about ' +
    'the latest changes and additions.' + #13#13 +
    'Do you want to view the file "history.txt" now?';
  STR_18 = 'History file not found: "%s"';
  STR_19 = 'Custom date formats reloaded (%d)';
  STR_20 = 'Cannot load custom date formats from %s. Check if the file exists.';
  STR_21 = 'Custom time formats reloaded (%d)';
  STR_22 = 'Cannot load custom time formats from %s. Check if the file exists.';
  STR_23 = 'Remove Filter on tree note';
  STR_24 = 'Apply Filter on tree note';
  STR_25 = 'This operation cannot be performed because no file is open.';
  STR_26 = 'This operation cannot be performed because the currently open file has no notes.';
  STR_27 = ' Cannot perform operation: Note is Read-Only';
  STR_29 = ' Printing note...';
  STR_30 = ' Finished printing note.';
  STR_31 = ' Preparing to send note via email...';
  STR_32 = ' Note sent';
  STR_33 = ' Note not sent';
  STR_35 = 'Set alarm... (Ctrl:Add  Shift:->Note)';
  STR_36 = 'Drag: ';
  STR_37 = 'TV dragover';
  STR_38_Dragged = '<nothing>';
  STR_39 = 'Cannot drop node %s on itself';
  STR_41= 'Cannot drop node %s - invalid source';
  STR_42= 'Cannot drop node %s onto its child %s';
  STR_43= 'Node "%s" promoted to TOP';
  STR_44= 'Node "%s" promoted to parent''s level';
  STR_45= 'Node "%s" moved to top of siblings';
  STR_46= 'Node "%s" inserted after node "%s"';
  STR_47= 'Node "%s" made child of node "%s"';
  STR_48= 'Nothing to drop or invalid drop target';
  STR_49= 'OK to sort the entire tree?';
  STR_50= ' Node name cannot be blank!';
  STR_51= ' Node renamed.';
  STR_52= ' Cannot edit: Note is read-only.';
  STR_53= 'Edit node name';
  STR_54= 'Enter new name:';
  STR_55= 'Node name cannot be blank!';
  STR_56= 'Parser stack overflow';
  STR_57= 'Bad cell range';
  STR_58= 'Expected expression';
  STR_59= 'Expected operator';
  STR_60= 'Expected opening parenthesis';
  STR_61= 'Expected operator or closing parenthesis';
  STR_62= 'Invalid numeric expression';
  STR_63= 'Cannot evaluate: ';
  STR_64= 'Error at position ';
  STR_65= 'No notes in file, or current note is not a Tree-type note.';
  STR_66= 'Find tree node';
  STR_67= 'Find node containing text:';
  STR_68= ' Node not found!';
  STR_69= 'The Style toolbar must be visible to use this command. Show the Style toolbar now?';
  STR_70= 'No style available or none selected';
  STR_71= 'Error: StyleManager does not exist.';
  STR_72= 'Tree nodes can only be dropped on the tree, or on another tab.';
  STR_73= 'Cannot transfer nodes to "%s", because it is not a Tree-type note.';
  STR_74= 'Cannot transfer nodes to "%s", because target note is Read-Only.';
  STR_75= 'Move';
  STR_76= 'Copy';
  STR_77= '%s dragged nodes to tab "%s"?';
  STR_78= 'Failed to acquire source nodes.';
  STR_79= ' Tab %d: %s';
  STR_80= 'Unexpected error.';
  STR_81= 'Could not open KeyNote file "%s"';
  STR_82= 'This command will start your browser and direct it to KeyNote NF website, where ' +
    'you can download the latest version of the program, read the FAQ, submit bug reports or feature requests with the Issue Manager. ' +  #13+#13+ 'Continue?';
  STR_82B= 'Save tree structure to file';
  STR_83= 'Hide &Resource Panel';
  STR_84= 'Show &Resource Panel';
  STR_85= 'Results';
  STR_86= 'Options';
  STR_87= 'Cannot hide the last visible tab. At least one tab must remain visible on the resource panel.';
  STR_88= 'Resource panel position will be updated after KeyNote is restarted.';
  STR_89= 'External: %s';
  STR_90= ' File: ';
  STR_91= ' Node: ';
  STR_92= '%s Note: %s%s';
  STR_93= 'Double-click to insert selected template';
  STR_94= 'Toolbar configuration file "%s" not found. Default toolbar configuration file has been created.';
  STR_95= 'Saved toolbar layout to "%s".';
  STR_96= 'Starting number for numbered paragraphs:';

const
  _TIMER_INTERVAL = 2000; // 2 seconds


// callback from TNoteFile, to prompt for passphrase
// when file is encrypted
function GetFilePassphrase( const FN : string ) : string;
var
  PassForm : TForm_Password;
begin
  result := '';
  PassForm := TForm_Password.Create( Application );
  try
    PassForm.myFileName := FN;
    if ( PassForm.ShowModal = mrOK ) then
      result := PassForm.Edit_Pass.Text;
  finally
    PassForm.Free;
  end;
end; // GetFilePassphrase


procedure TForm_Main.HotKeyProc( const TurnOn : boolean );
var
  HKeyCode : Word;
  HShiftState : TShiftState;
begin
  try

    if TurnOn then
    begin
      // register activation hotkey
      if ( KeyOptions.HotKeyActivate and ( KeyOptions.HotKey > 0 )) then
      begin
        ShortCutToKey( KeyOptions.HotKey, HKeyCode, HShiftState );
        if RegisterHotkey( Handle, 1,
          ShiftStateToHotKey( HShiftState ), HKeyCode
        ) then
        begin
          HotKeySuccess := true;
        end
        else
        begin
          HotKeySuccess := false;
          if ( KeyOptions.HotKeyWarn and KeyOptions.SingleInstance ) then
          begin
            // No warning if we can be running more than 1 instance of KeyNote,
            // because only the first instance will be able to register the hotkey,
            // so we would ALWAYS be getting the damn warning on each subsequent instance.
            Messagedlg( Format(
              STR_01,
              [ShortCutToText( KeyOptions.HotKey )] ),
              mtWarning, [mbOK], 0 );
          end;
        end;
      end;
    end
    else
    begin
      if HotKeySuccess then
        UnRegisterHotkey( Handle, 1 );
      HotKeySuccess := false;
    end;

  except
    On E : Exception do
    begin
      HotKeySuccess := false;
      messagedlg( Format(
        STR_02,
        [TOGGLEARRAY[TurnOn], ShortCutToText( KeyOptions.HotKey ), E.Message]
        ), mtError, [mbOK], 0 );

    end;
  end;

  if HotKeySuccess then
    TMRestore.Caption := Format(
      STR_03, [ShortCutToText( KeyOptions.HotKey )]
    )
  else
    TMRestore.Caption := STR_04;

end; // HotKeyProc



procedure TForm_Main.FormCreate(Sender: TObject);
begin
  InitializeKeynote(Self);
  MMP_PlainDefaultPaste.Hint:= MMEditPlainDefaultPaste.Hint;
end; // CREATE

procedure TForm_Main.FormActivate(Sender: TObject);
begin
  if ( not Initializing ) then exit;

  Log_StoreTick( 'FormActivate - Begin', 1, +1 );
  OnActivate := nil; // don't return here again

  try

    UpdateResPanelContents;
    Splitter_ResMoved( Splitter_Res );
    // Pages_Res.Visible := KeyOptions.ResPanelShow;
    HideOrShowResPanel( KeyOptions.ResPanelShow );
    Btn_ResFind.Enabled := ( Combo_ResFind.Text <> '' );
  except
  end;
  Log_StoreTick( 'After update respanel', 2 );

  EnableOrDisableUAS;

  if KeyOptions.AltMargins then begin
     MMAlternativeMargins.Checked:= true;
     if assigned(ActiveNote) then
        SetMargins();
  end;

  if _GLOBAL_URLText <> '' then
    JumpToKNTLocation( _GLOBAL_URLText );

  if opt_Title <> '' then begin
     Caption:= opt_Title;
     opt_Title:= '';
  end;

  opt_Minimize := ( opt_Minimize or KeyOptions.StartMinimized ) and (_GLOBAL_URLText = '');

  Application.ProcessMessages;

  { Before this method is executed, on Form.DoShow: (FormStorage) => TFormPlacement.RestoreFormPlacement -> RestorePlacement -> RxAppUtils.InternalReadFormPlacement => PostMessage(...)
    Although at this point WindowState <> wsMinimized, it will end up being, if we do not queue a subsequent request for it to be restored }

  if (not opt_Minimize) then
     Application.Restore;

  {
  if KeyOptions.TipOfTheDay then
    ShowTipOfTheDay;
  }
  Initializing := false;

  FocusActiveNote;

  Log_StoreTick( 'After FocusActiveNote', 2 );

  if ( KeyOptions.RunAutoMacros and ( StartupMacroFile <> '' )) then
  begin
    if ( pos( '\', StartupMacroFile ) = 0 ) then
      StartupMacroFile := Macro_Folder + StartupMacroFile;
    if FileExists( StartupMacroFile ) then
    begin
      Application.ProcessMessages;
      ExecuteMacro( StartupMacroFile, '' );
    end;
  end;

  Log_StoreTick( 'After automacro', 2 );

  if ( StartupPluginFile <> '' ) then
  begin
    if ( pos( '\', StartupPluginFile ) = 0 ) then
      StartupPluginFile := Plugin_Folder + StartupPluginFile;
    if FileExists( StartupPluginFile ) then
    begin
      Application.ProcessMessages;
      ExecutePlugin( StartupPluginFile );
    end;
  end;

  Log_StoreTick( 'After autoplugin', 2 );

  if KeyOptions.TipOfTheDay then
    postmessage( Handle, WM_TIPOFTHEDAY, 0, 0 );


  MMViewOnTop.Checked := KeyOptions.AlwaysOnTop;
  TB_OnTop.Down := MMViewOnTop.Checked;

  if opt_Minimize then
    Application.Minimize
  else
    WinOnTop.AlwaysOnTop := KeyOptions.AlwaysOnTop;

  Combo_Font.OnClick  := Combo_FontChange;
  Combo_Font.OnChange := nil;
  Combo_FontSize.OnClick := Combo_FontSizeClick;
  Combo_Zoom.OnClick := Combo_FontSizeClick;

  // Timer.Enabled := true;
  Application.OnDeactivate := AppDeactivate;
  // FolderMon.onChange := FolderMonChange;

  Log_StoreTick( 'FormActivate - End', 1, -1 );

end; // ACTIVATE

procedure TForm_Main.ActivatePreviousInstance;
var
  CopyData : TCopyDataStruct;
  //msg : TKeyNoteMsg;
  Args: string;
begin
{
  if ( NoteFileToLoad <> '' ) then
  begin
    msg.strData := NoteFileToLoad;
    copydata.dwData := KNT_MSG_SHOW_AND_LOAD_FILE;
  end
  else
  if ( CmdLineFileName <> '' ) then
  begin
    msg.strData := CmdLineFileName;
    copydata.dwData := KNT_MSG_SHOW_AND_EXECUTE_FILE;
  end
  else
  begin
    msg.strData := NO_FILENAME_TO_LOAD;
    copydata.dwData := KNT_MSG_SHOW;
  end;

  copydata.cbData := sizeof( msg );
  copydata.lpData := @msg;
}

  // The other instance will process the main command line arguments: .KNT, .KNE, .KNL, or .KNM files, as well as the -jmp switch
  // It is more general than the use of KNT_MSG_SHOW_AND_LOAD_FILE, KNT_MSG_SHOW_AND_EXECUTE_FILE, NO_FILENAME_TO_LOAD
  Args:= GetCommandLine;
  copydata.dwData := KNT_MSG_OTHER_INSTANCE_CALL;
  copydata.cbData:= ByteLength(Args)+1;
  copydata.lpData := PChar(Args);

  SendMessage( _OTHER_INSTANCE_HANDLE,
    WM_COPYDATA,
    Handle,
    integer( @copydata ));

  //ShowWindow(_OTHER_INSTANCE_HANDLE, SW_RESTORE);  // See comment to ExecuteCallArgs
  sleep(100);
  SetForegroundWindow(_OTHER_INSTANCE_HANDLE);

end; // ActivatePreviousInstance


procedure TForm_Main.ProcessControlMessage(
  const msgID : integer;
  kntmsg : TKeyNoteMsg
  );
        function Check( mustbereadonly : boolean ) : boolean;
        begin
          result := ( assigned( NoteFile ) and
            HaveNotes( false, true ));
          if ( result and mustbereadonly ) then
            result := ( result and ( not NoteIsReadOnly( ActiveNote, false )));
        end;
begin
  case MsgID of
    KNT_MSG_PERFORMKEY : if Check( true ) then
    begin
      ShortCutToKey( kntmsg.intData1, LastRTFKey.Key, LastRTFKey.Shift );
      PostKeyEx( ActiveNote.Editor.Handle, LastRTFKey.Key, LastRTFKey.Shift, LastRTFKey.Special );
      Application.ProcessMessages;
    end;
    KNT_MSG_INSERTTEXT : if Check( true ) then
    begin
      ActiveNote.Editor.SelLength := 0;
      Text := kntmsg.strData;
      ActiveNote.Editor.SelLength := 0;
    end;
    KNT_MSG_MOVECARET : if Check( false ) then
    begin
      case kntmsg.intData1 of
        _CARET_RIGHT : with ActiveNote.Editor do
        begin
          Perform( WM_KEYDOWN, VK_RIGHT, 0 );
          Perform( WM_KEYUP, VK_RIGHT, 0 );
        end;
        _CARET_LEFT : with ActiveNote.Editor do
        begin
          Perform( WM_KEYDOWN, VK_LEFT, 0 );
          Perform( WM_KEYUP, VK_LEFT, 0 );
        end;
        _CARET_UP : with ActiveNote.Editor do
        begin
          Perform( WM_KEYDOWN, VK_UP, 0 );
          Perform( WM_KEYUP, VK_UP, 0 );
        end;
        _CARET_DOWN : with ActiveNote.Editor do
        begin
          Perform( WM_KEYDOWN, VK_DOWN, 0 );
          Perform( WM_KEYUP, VK_DOWN, 0 );
        end;
      end;
    end;
    KNT_MSG_RELOADCONFIG : begin
      case kntmsg.intData1 of
        _CFG_RELOAD_MAIN : begin
          // [x] not implemented
        end;
        _CFG_RELOAD_KEYS : begin
          // ReadFuncKeys;
          // StatusBar.Panels[PANEL_HINT].Text := STR_05;
        end;
      end;
    end;
  end;
end; // ProcessControlMessage


procedure TForm_Main.WMCopyData (Var msg: TWMCopyData);
var
  kntmsg : TKeyNoteMsg;
  TypeMsg: NativeUInt;
  Args: string;
begin
  TypeMsg:= msg.Copydatastruct^.dwData;
  if TypeMsg <> KNT_MSG_LAUNCHER_CALL then
     ReplyMessage( 0 );

  case TypeMsg of
    KNT_MSG_LAUNCHER_CALL, KNT_MSG_OTHER_INSTANCE_CALL: begin
      //PopupMessage( Format('KNT_MSG_LAUNCHER/OTHER_INSTANCE_CALL: %d', [TypeMsg]), mtConfirmation, [mbYes], 0 );
      Args:= PChar(msg.Copydatastruct^.lpData);
      if CheckCallArgs(Args, (TypeMsg = KNT_MSG_LAUNCHER_CALL)) then begin
         ReplyMessage( 0 );
         ExecuteCallArgs((TypeMsg = KNT_MSG_LAUNCHER_CALL));
      end
      else
         ReplyMessage( -1 );
      exit;
    end
    else begin
      kntmsg := PKeyNoteMsg( msg.Copydatastruct^.lpData )^;
      ProcessControlMessage( msg.Copydatastruct^.dwData, kntmsg );
      exit;
    end;
  end;
end; // WMCopyData


(*    // Old WMCopyData

procedure TForm_Main.WMCopyData(Var msg: TWMCopyData);
var
  kntmsg : TKeyNoteMsg;
  ext : string;
begin
  ReplyMessage( 0 );

  // StatusBar.Panels[PANEL_HINT].Text := ' Received message from other instance';

  kntmsg := PKeyNoteMsg( msg.Copydatastruct^.lpData )^;

  case msg.Copydatastruct^.dwData of
    KNT_MSG_SHOW : begin
      NoteFileToLoad := '';
      CmdLineFileName := '';
    end;
    KNT_MSG_SHOW_AND_LOAD_FILE : begin
      if ( kntmsg.strData <> NO_FILENAME_TO_LOAD ) then
        NoteFileToLoad := normalFN( kntmsg.strData )
      else
        NoteFileToLoad := '';
      CmdLineFileName := '';
    end;
    KNT_MSG_SHOW_AND_EXECUTE_FILE : begin
      // CmdLineFileName
      NoteFileToLoad := '';
      CmdLineFileName := normalFN( kntmsg.strData );
    end;
    KNT_MSG_SHOW_LOCATION: begin
       JumpToKNTLocation( kntmsg.strData);
       exit;
    end
    else begin
      ProcessControlMessage( msg.Copydatastruct^.dwData, kntmsg );
      exit;
    end;
  end;

  Application.Minimize;
  Application.Restore;
  Application.BringToFront;


  if ( NoteFileToLoad <> '' ) then begin
     if HaveNotes( false, false ) then begin
        if ( NoteFileToLoad = NoteFile.FileName ) then begin
          if ( PopupMessage( Format(STR_06, [NoteFile.Filename]), mtConfirmation, [mbYes,mbNo], 0 ) <> mrYes ) then exit;
          NoteFile.Modified := false; // to prevent automatic save if modified
        end;
     end;
     NoteFileOpen( NoteFileToLoad );
  end
  else
  if ( CmdLineFileName <> '' ) then begin
     if HaveNotes( false, false ) then begin
        ext := ansilowercase( extractfileext( CmdLineFileName ));
        if ( ext = ext_Macro ) then
           ExecuteMacro( CmdLineFileName, '' )
        else
        if ( ext = ext_Plugin ) then
           ExecutePlugin( CmdLineFileName );
     end;
  end;

end; // WMCopyData
*)

procedure TForm_Main.ExecuteCallArgs (fromKntLauncher: boolean);
var
  Open: boolean;
begin
{
  It does not work correctly. It is best that the calling application takes care of this, giving it its focus (-> ActivatePreviousInstance)
  However, restore the window by running ShowWindow(_OTHER_INSTANCE_HANDLE, SW_RESTORE); from the calling instance it is problematic
  he window is restored but not minimized until the other one is closed (or after multiple minimizes/restorations of that one)
}
   Application.Restore;
// Application.BringToFront;


   if not fromKntLauncher and ( NoteFileToLoad <> '' ) then begin
      //PopupMessage( Format('NoteFileToLoad: %s', [NoteFileToLoad]), mtConfirmation, [mbYes], 0 );
      Open:= true;
      if HaveNotes( false, false ) then begin
         if ( NoteFileToLoad.ToUpper = NoteFile.FileName.ToUpper ) then begin
           if ( PopupMessage( Format(STR_06, [NoteFile.Filename]), mtConfirmation, [mbYes,mbNo], 0 ) <> mrYes ) then
              Open:= false;
           NoteFile.Modified := false; // to prevent automatic save if modified
         end;
      end;
      if Open then
         NoteFileOpen( NoteFileToLoad );
   end;


   if _GLOBAL_URLText <> '' then begin
     //PopupMessage( Format('JUMP: %s', [_GLOBAL_URLText]), mtConfirmation, [mbYes], 0 );
     JumpToKNTLocation( _GLOBAL_URLText, urlOpen, true);      // OpenInCurrentFile
   end;


   if StartupMacroFile <> '' then
      ExecuteMacro( StartupMacroFile, '' );

   if StartupPluginFile <> '' then
      ExecutePlugin( StartupPluginFile );
end;


procedure TForm_Main.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if opt_DoNotDisturb then
     Params.WinClassName := UniqueAppName_KEYNOTE10_dnd
  else
     Params.WinClassName := UniqueAppName_KEYNOTE10;
end; // CreateParams


procedure TForm_Main.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i : integer;
begin
  if IsRunningMacro then
  begin
    MacroAbortRequest := true;
  end
  else
  if IsRecordingMacro then
  begin
    TB_MacroRecordClick( TB_MacroRecord ); // stop recording
  end;

  CloseNonModalDialogs;

  if ( not ( ClosedByWindows or TerminateClick )) then
  begin
    if KeyOptions.MinimizeOnClose then
    begin
      CanClose := false;
      Application.Minimize;
      AppIsClosing := false;
      exit;
    end;
  end;

  if CanClose then
    if ( KeyOptions.ConfirmExit and ( not ClosedByWindows )) then
      CanClose := ( PopupMessage( format(STR_07, [Program_Name]), mtConfirmation, [mbYes,mbNo], 0 ) = mrYes );
  { note: if windows is closing, we do not honor the "Confirm exit" config option }

  try
    if CanClose then
       CanClose := CheckModified( not KeyOptions.AutoSave, true );

    if CanClose then
    begin

      try

        FindOptions.FindAllHistory := '';
        for i := 1 to Combo_ResFind.Items.Count do
        begin
          if ( i > FindOptions.HistoryMaxCnt ) then break;
          if ( i > 1 ) then
            FindOptions.FindAllHistory := FindOptions.FindAllHistory + HISTORY_SEPARATOR + AnsiQuotedStr( Combo_ResFind.Items[pred( i )], '"' )
          else
            FindOptions.FindAllHistory := AnsiQuotedStr( Combo_ResFind.Items[0], '"' );
        end;

        if KeyOptions.UseCtrlHideTreePanel then begin
           Visible:= False;
           CheckRestoreAppWindowWidth;
        end;

        SaveOptions;
        if Res_RTF.Modified then
          StoreResScratchFile;

        { SaveFuncKeys is not called, because key assignments
        do not change inside KeyNote }
        // SaveFuncKeys;

        if ( not opt_NoSaveOpt ) then
        begin
          SaveFileManagerInfo( MGR_FN );
          if StylesModified then
          begin
            SaveStyleManagerInfo( Style_FN );
            StylesModified := false;
          end;
          SaveFavorites( FAV_FN );
          if opt_NoRegistry then
            IniSaveToolbarPositions( Self, changefileext( INI_FN, ext_MRU ), 'TB97a' )
          else
            RegSaveToolbarPositions( Self, 'Software\General Frenetics\Keynote\FormPos\TB97a' );
        end;

      except
      end;
    end;

  finally
    if CanClose then
    begin
     {$IFDEF KNT_DEBUG}
       Log.Flush( true );
       Log.Add( 'CloseQuery result: ' + BOOLARRAY[CanClose] );
     {$ENDIF}
    end;
    AppIsClosing := true;
    ClosedByWindows := false;
    TerminateClick := false;
  end;
end; // CLOSEQUERY

procedure TForm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  HotKeyProc( false ); // unregister hotkey
end; // FORM CLOSE

procedure TForm_Main.FormDestroy(Sender: TObject);
begin
  // close shop!!
  ClipCapActive := false;
  if ( ClipCapNextInChain <> 0 ) then
    SetClipCapState( false );

  FolderMon.Active := false;
{$IFNDEF KNT_DEBUG}
  // in final release, set the event to NIL (keep only for debugging)
  Application.OnException := nil;
{$ENDIF}
  Application.OnDeactivate := nil;
  Application.OnHint := nil;
  ActiveNote := nil;
  // ClipCapNote := nil;
  Pages.OnChange := nil;

  // [x] The access violation error which happens
  // on closing app if a virtual node was clicked
  // occurs in MRU.RemoveAllItems, because the
  // popup menu has aparently been freed but not nil'ed.
  // So, we just cause MRU to forget it ever had a popup
  // menu, so that it won't try to remove its items.
  TB_FileOpen.DropdownMenu := nil;
  MRU.PopupMenu := nil;

  // TB97CALLCOUNT := 0;

  try
    try

      if assigned( NoteFile ) then NoteFile.Free;
      if assigned( TransferNodes ) then TransferNodes.Free;
      // DestroyVCLControls;

    except
      // at this stage, we can only swallow all exceptions (and pride)
     {$IFDEF KNT_DEBUG}
        on E : Exception do begin
          showmessage( 'Exception in OnDestroy: ' + #13#13 +E.Message );
          if assigned( Log ) then Log.Add( 'Exception in OnDestroy: ' + E.Message );
        end;
     {$ENDIF}
    end;
  finally
    {$IFDEF KNT_DEBUG}
      if assigned( Log ) then
         Log.Free;
      log := nil;
    {$ENDIF}
  end;

end; // DESTROY




procedure TForm_Main.ResolveToolbarRTFv3Dependencies;
begin
  // this must always be done after "LoadToolbars".
  // Disable buttons and menu items if RichEdit version < 3
  // but also check if they were not previously hidden
  // via toolbar configuration
  TB_Numbers.Visible := TB_Numbers.Visible and ( _LoadedRichEditVersion > 2 );
  TB_AlignJustify.Visible := TB_AlignJustify.Visible and ( _LoadedRichEditVersion > 2 );
  MMFormatNumbers.Visible := ( _LoadedRichEditVersion > 2 );
  MMFormatNumbers.Enabled := ( _LoadedRichEditVersion > 2 );
  MMFormatAlignJustify.Visible := ( _LoadedRichEditVersion > 2 );
  MMFormatAlignJustify.Enabled := ( _LoadedRichEditVersion > 2 );
  Combo_Zoom.Visible := Combo_Zoom.Visible and ( _LoadedRichEditVersion > 2 );
  Combo_Zoom.Enabled := ( _LoadedRichEditVersion > 2 );
  MMViewZoomIn.Visible := ( _LoadedRichEditVersion > 2 );
  MMViewZoomOut.Visible := ( _LoadedRichEditVersion > 2 );
end; // ResolveToolbarRTFv3Dependencies


procedure TForm_Main.SetupToolbarButtons;
begin
  TB_AlignCenter.Hint := MMFormatAlignCenter.Hint;
  TB_AlignLeft.Hint := MMFormatAlignLeft.Hint;
  TB_AlignRight.Hint := MMFormatAlignRight.Hint;
  TB_AlignJustify.Hint := MMFormatAlignJustify.Hint;
  TB_Bold.Hint := MMFormatBold.Hint;
  TB_Bullets.Hint := MMFormatBullets.Hint;
  TB_ClipCap.Hint := MMNoteClipCapture.Hint;
  TB_EditCopy.Hint := MMEditCopy.Hint;
  TB_EditCut.Hint := MMEditCut.Hint;
  TB_EditPaste.Hint := MMEditPaste.Hint;
  TB_EditRedo.Hint := MMEditRedo.Hint;
  TB_EditUndo.Hint := MMEditUndo.Hint;

{$IFNDEF EXCLUDEEMAIL}
  TB_EmailNote.Hint := MMNoteEmail.Hint;
{$ELSE}
  MMNoteEmail.Visible:= False;
  TB_EmailNote.Visible:= False;
{$ENDIF}
  //TB_Exit.Hint := MMFileExit.Hint;
  TB_FileInfo.Hint := MMFileproperties.Hint;
  TB_FileMgr.Hint := MMFileManager.Hint;
  TB_FileNew.Hint := MMFileNew.Hint;
  TB_FileOpen.Hint := MMFileOpen.Hint;
  TB_FileSave.Hint := MMFileSave.Hint;
  TB_Find.Hint := MMFind.Hint;
  TB_FindNext.Hint := MMFindNext.Hint;
  TB_FontDlg.Hint := MMFormatFont.Hint;
  TB_GoBack.Hint := MMHistoryGoBack.Hint;
  TB_GoForward.Hint := MMHistoryGoForward.Hint;
  TB_Indent.Hint := MMFormatLIndInc.Hint;
  TB_Italics.Hint := MMFormatItalics.Hint;
  TB_Macro.Hint := MMToolsMacroRun.Hint;
  // TB_MacroPause.Hint := .Hint;
  // TB_MacroRecord.Hint := .Hint;
  TB_HideChecked.Hint := MMViewHideCheckedNodes.Hint;    // [dpv]
  TB_NoteDelete.Hint := MMNoteRemove.Hint;
  TB_NoteEdit.Hint := MMNoteProperties.Hint;
  TB_NoteNew.Hint := MMNoteNew.Hint;
  TB_Numbers.Hint := MMFormatNumbers.Hint;
  TB_OnTop.Hint := MMViewOnTop.Hint;
  TB_Options.Hint := MMToolsOptions.Hint;
  TB_Outdent.Hint := MMFormatLIndDec.Hint;
  TB_ParaDlg.Hint := MMFormatParagraph.Hint;
  // TB_PluginConfigure.Hint := .Hint;
  TB_PluginRun.Hint := MMToolsPluginRun.Hint;
  TB_Print.Hint := MMNotePrint.Hint;
  TB_Repeat.Hint := MMEditRepeat.Hint;
  TB_Replace.Hint := MMFindReplace.Hint;
  TB_ResPanel.Hint := MMViewResPanel.Hint;
  TB_Space1.Hint := MMFormatLS1.Hint;
  TB_Space15.Hint := MMFormatLS15.Hint;
  TB_Space2.Hint := MMFormatLS2.Hint;
  TB_Spell.Hint := MMNoteSpell.Hint;
  TB_Strikeout.Hint := MMFormatStrikeout.Hint;
  TB_Style.Hint := MMFormatApplyStyle.Hint;
  TB_Subscript.Hint := MMFormatSubScript.Hint;
  TB_Superscript.Hint := MMFormatSuperScript.Hint;
  TB_Underline.Hint := MMFormatUnderline.Hint;
  TB_WordWeb.Hint := MMInsertWordWeb.Hint;
  TB_WordWrap.Hint := MMFormatWordWrap.Hint;
end; // SetupToolbarButtons



procedure TForm_Main.AppMessage( var Msg : TMsg; var Handled : boolean );
begin
  // keep track of when application was last "active",
  // i.e. the user was doing something in the program
  case Msg.Message of
    WM_KEYFIRST..WM_KEYLAST, WM_LBUTTONDOWN..WM_MOUSELAST : begin
      // Note: we are not using WM_MOUSEFIRST, because that includes
      // WM_MOUSEMOVE, so just freely moving the mouse over the form
      // would trigger this event, which would be counterproductive.
      // IOW, we do not consider mouse movement an "activity"; only
      // actual clicks and keypresses count.
      AppLastActiveTime := Now;
    end;
  end;
end; // AppMessage

procedure TForm_Main.AssignOnMessage;
begin
  Application.OnMessage := AppMessage;
end;


procedure TForm_Main.AppMinimize(Sender: TObject);
begin
  TMRestore.Enabled := true;
  WinOnTop.AlwaysOnTop := false;
  // FormStorage.Options := [fpPosition];
  if KeyOptions.UseTray then
    ShowWindow(Application.Handle, SW_HIDE);
end; // AppMinimize;

procedure TForm_Main.AppRestore(Sender: TObject);
begin
    TMRestore.Enabled := false;
    AppLastActiveTime := now;
    FormStorage.Options := [fpState,fpPosition];
    ShowWindow( Application.Handle, SW_SHOW );
    WinOnTop.AlwaysOnTop := KeyOptions.AlwaysOnTop;
    Application.BringToFront;
    if _REOPEN_AUTOCLOSED_FILE then
    begin
      _REOPEN_AUTOCLOSED_FILE := false;
      NoteFileOpen( KeyOptions.LastFile );
    end;
end; // AppRestore;

procedure TForm_Main.DisplayAppHint( sender: TObject );
begin
  if KeyOptions.StatBarShow then
    StatusBar.Panels[PANEL_HINT].Text := GetShortHint( Application.Hint );
end; // DisplayAppHint


procedure TForm_Main.TrayIconClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  AppLastActiveTime := now;
  Application.Restore;
  Application.BringToFront;
end;

procedure TForm_Main.MMFileExitClick(Sender: TObject);
begin
  TerminateClick := true;
  Close;
end;

procedure TForm_Main.TMRestoreClick(Sender: TObject);
begin
  Application.Restore;
  Application.BringToFront;
end;

procedure TForm_Main.TntFormResize(Sender: TObject);
begin
  Form_Main.Refresh;
  if assigned(ActiveNote) then
     ActiveNote.Editor.Invalidate;
end;

procedure TForm_Main.TimerTimer(Sender: TObject);
const
  bools : array[false..true] of string = ( 'No', 'Yes' );
var
  Hrs, Mins : integer;
  _MillisecondsIdle: DWord;
begin
  inc( Timer_Tick );
  inc( Timer_TickAlarm);
  {
    timer may trigger THREE kinds of things:
    1. auto-saving current file
    2. minimizing keynote and/or closing file after a period of inactivity.

    3. Show Alarms on nodes           [dpv*]
    4. Invoke ImagesManager.CleanUp   [dpv]
  }

  if ( Timer_Tick >= KeyOptions.AutoSaveOnTimerInt * ( 60000 div _TIMER_INTERVAL ) ) then
  begin
    Timer_Tick := 0;
    if Form_Main.HaveNotes( false, false ) then
    begin
      if (( not FileChangedOnDisk ) and NoteFile.Modified and KeyOptions.AutoSave and KeyOptions.AutoSaveOnTimer ) then
      begin
        if (( NoteFile.FileName <> '' ) and ( not NoteFile.ReadOnly )) then begin
          // only if saved previously
         {$IFDEF KNT_DEBUG}
           Log.Add( '-- Saving on TIMER' );
         {$ENDIF}
           NoteFileSave( NoteFile.FileName );
        end;
      end;
    end;
  end;

  try
    if KeyOptions.TimerClose then
    begin
      Hrs := ( KeyOptions.TimerCloseInt DIV 60 );
      Mins := ( KeyOptions.TimerCloseInt MOD 60 );
      if (( AppLastActiveTime + EncodeTime( Hrs, Mins, 0, 0 )) < Now ) then
      begin
        Timer_Tick := 0;
        AutoCloseFile;
        // auto-closing minimizes too, so we exit here
        exit;
      end;
    end;

    if KeyOptions.TimerMinimize then
    begin
      if ( not IsIconic( Application.Handle )) then
      begin
        Hrs := ( KeyOptions.TimerMinimizeInt DIV 60 );
        Mins := ( KeyOptions.TimerMinimizeInt MOD 60 );
        if (( AppLastActiveTime + EncodeTime( Hrs, Mins, 0, 0 )) < Now ) then
        begin
          Application.Minimize;
        end;
      end;
    end;


    if ( Timer_TickAlarm >=  ( 60000 div _TIMER_INTERVAL )/4 ) then begin    // Comprobamos cada 15 segundos
        Timer_TickAlarm:= 0;
        AlarmManager.checkAlarms;
        ImagesManager.CheckFreeImageStreamsNotRecentlyUsed;     // This method will only work if ImageManager.Enabled and if more than X minutes have passed since the previous cleanup
    end;


    _MillisecondsIdle:= MillisecondsIdle;
    if KeyOptions.CheckUpdOnStartup and (_MillisecondsIdle > 3000) then
       CheckForUpdate(true);

    if EditorOptions.WordCountTrack and (_MillisecondsIdle >= 450) then
       UpdateWordCount;

    if (NoteFile <> nil) and (not NoteFile.TextPlainVariablesInitialized) and (_MillisecondsIdle >= 450) then
       NoteFile.UpdateTextPlainVariables(150);


  except
     // drop all exceptions here
  end;

end; // OnTimer

function MillisecondsIdle: DWord;
var
   liInfo: TLastInputInfo;
begin
   liInfo.cbSize := SizeOf(TLastInputInfo) ;
   GetLastInputInfo(liInfo) ;
   Result := (GetTickCount - liInfo.dwTime);
end;

procedure TForm_Main.AppDeactivate( sender : TObject );
begin
  if FileChangedOnDisk then exit;
  if (( not ( AppIsClosing or Initializing or FileIsBusy )) and
      ( HaveNotes( false, false ))) then
  begin
    if ( KeyOptions.AutoSave and KeyOptions.AutoSaveOnFocus and NoteFile.Modified ) then
    begin
      if (( NoteFile.FileName <> '' ) and ( not NoteFile.ReadOnly )) then begin
        // only if saved previously
        {$IFDEF KNT_DEBUG}
          Log.Add( '-- Saving on Application DEACTIVATE' );
        {$ENDIF}
          NoteFileSave( NoteFile.FileName );
      end;
    end;
  end;
end; // AppDeactivate

procedure TForm_Main.WMActivate( Var msg: TWMActivate );
begin
  if ( msg.Active <> WA_INACTIVE ) then
  begin
    AppIsActive := true; // used with ClipCap to ignore copy events coming from Keynote itself
    if FileChangedOnDisk then begin
      {$IFDEF KNT_DEBUG}
        Log.Add( 'FileChangedOnDisk!' );
      {$ENDIF}
        FileChangedOnDisk := false;
        SomeoneChangedOurFile;
    end;
    AppIsClosing := false;
  end
  else
  begin
    AppIsActive := false;
  end;
  inherited;
end; // WMActivate

procedure TForm_Main.WMHotkey( Var msg: TWMHotkey );
begin
  if ( msg.hotkey = 1 ) then
  begin
    if IsIconic( Application.Handle ) then
      Application.Restore;
    Application.BringToFront;
  end;
end; // WMHotkey

procedure TForm_Main.WMQueryEndSession( var Msg : TMessage );
begin
  ClosedByWindows := true;
  {$IFDEF KNT_DEBUG}
  Log.Add( 'Closed by Windows: WM_QUERYENDSESSION' );
  {$ENDIF}
  Msg.Result := 1;
  inherited;
end; // WMQueryEndSession

procedure TForm_Main.WndProc( var M : TMessage );
begin
  if M.Msg = _KNT_WINMSG_ID then
  begin
    case M.WParam of
      KNT_MSG_PLUGIN_SHUTDOWN : begin
        // resident plugin shuts down and has notified us about it
        UnloadResidentPlugin( M.LParam );
      end;
    end;
  end;
  inherited WndProc( M );
end; // WndProc

procedure TForm_Main.ShowException( Sender : TObject; E : Exception );
begin
  {$IFDEF KNT_DEBUG}
  if assigned( Log ) then
  begin
    Log.Add( '!! Unhandled exception: ' + e.message );
    Log.Flush( true );
  end;
  {$ENDIF}

  If Application.MessageBox(
    PChar(format(STR_08, [E.Message, URL_Issues])), PChar(STR_09),
    MB_YESNO+MB_SYSTEMMODAL+MB_ICONHAND+MB_DEFBUTTON2) = ID_YES Then
  begin
    ClosedByWindows := true; // means: don't display exit confirmation dialog
    TerminateClick := true;
    PostMessage( Handle, WM_QUIT, 0, 0 ); // docs say to use PostQuitMessage, but I've had problems with it
    Application.Terminate;
  end;
end; // ShowException

procedure TForm_Main.NotImplemented( const aStr : string );
begin
  PopupMessage( STR_10 + aStr, mtInformation, [mbOK], 0 );
{$IFDEF KNT_DEBUG}
  Log.Add( 'Not implemented call: ' + aStr );
{$ENDIF}
end; // NotImplemented

procedure TForm_Main.CloseNonModalDialogs;
begin
  if ( Form_Chars <> nil ) then
    Form_Chars.Close;
  if ( Form_FindReplace <> nil ) then
    Form_FindReplace.Close;
end; // CloseNonModalDialogs

procedure TForm_Main.MMFileNewClick(Sender: TObject);
begin
  NoteFileNew( '' );
end;

procedure TForm_Main.MMFileOpenClick(Sender: TObject);
begin
  NoteFileOpen( '' );
end; // MMOpenClick

procedure TForm_Main.MMFileSaveClick(Sender: TObject);
begin
{$IFDEF KNT_DEBUG}
  Log.Add( '-- Saving on user request' );
{$ENDIF}
  if ShiftDown then
  begin
    NoteFileSave( '' )
  end
  else
  begin
    if HaveNotes( false, false ) then
      NoteFileSave( NoteFile.FileName )
    else
      NoteFileSave( '' );
  end;
end;

procedure TForm_Main.MMFileSaveAsClick(Sender: TObject);
begin
  NoteFileSave( '' );
end;

procedure TForm_Main.MMNoteNewClick(Sender: TObject);
begin
  CreateNewNote;
end;

procedure TForm_Main.MMHelpTipClick(Sender: TObject);
begin
  ShowTipOfTheDay;
end;

procedure TForm_Main.MMFileCloseClick(Sender: TObject);
begin
  NoteFileClose;
end;

procedure TForm_Main.MMNoteRenameClick(Sender: TObject);
begin
  RenameNote;
end;

procedure TForm_Main.UpdateTabAndTreeIconsShow;
begin
  if assigned( NoteFile ) then
  begin
    MMViewTabIcons.Enabled := NoteFile.ShowTabIcons;
    if ( NoteFile.ShowTabIcons and TabOptions.Images ) then
      Pages.Images := Chest.IMG_Categories
    else
      Pages.Images := nil;
  end
  else
  begin
    MMViewTabIcons.Enabled := true;
    Pages.Images := Chest.IMG_Categories;
  end;

end; // UpdateTabAndTreeIconsShow

procedure TForm_Main.MMFilePropertiesClick(Sender: TObject);
begin
  NoteFileProperties;
end;

procedure TForm_Main.MMFileAutoSaveClick(Sender: TObject);
begin
  KeyOptions.AutoSave := ( not KeyOptions.AutoSave );
  AutoSaveToggled;
end;

procedure TForm_Main.AutoSaveToggled;
begin
  MMFileAutoSave.Checked := KeyOptions.AutoSave;
  if ( not Initializing ) then
    UpdateNoteFileState( [fscModified] );
end; // AutoSaveToggled;

procedure TForm_Main.AnotherInstance;
begin
  // rcvStr contains the commandline passed to
  // the new instance. We use it to load
  // a different file.
  Application.Restore;
  Application.BringToFront;
  // NewFileRequest( rcvStr );
end; // AnotherInstance

procedure TForm_Main.ShowInsMode;
begin
  if ActiveNote.IsInsertMode then
    StatusBar.Panels[PANEL_INS].Text := STR_11
  else
    StatusBar.Panels[PANEL_INS].Text := STR_12;
end; // ShowInsMode

procedure TForm_Main.PagesDblClick(Sender: TObject );
begin
  if ShiftDown then
    EditNoteProperties( propThisNote )
  else
    RenameNote;
end; // PagesDblClick

procedure TForm_Main.RxRTFMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

var
   bakS, S: integer;
   MousePos: TPoint;
begin
  if not assigned( ActiveNote ) then exit;

  ActiveNote.FocusMemory := focRTF;

  if (Button = mbRight) then begin
      With TTabRichEdit(sender) do begin
         if SelLength > 0 then exit;

         bakS:= SelStart;
         MousePos.X  := X;
         MousePos.Y  := Y;
         S:= GetCharFromPos(MousePos);

         BeginUpdate;
         SetSelection(S, S + 1, false);
         if SelAttributes.Link then
            TTabRichEdit(sender).PopUpMenu := nil;

         SetSelection(bakS, bakS, false);
         EndUpdate;
      end;
  end;

end;

procedure TForm_Main.RxRTFMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not assigned(ActiveNote) then exit;

  if (CopyFormatMode <> cfDisabled) then
     PerformCmd(ecPasteFormat);

  if Button = mbRight then
     TTabRichEdit(sender).PopupMenu := Menu_RTF;

  if kn_ImageForm.LastFormImageOpened <> nil then begin
     LastFormImageOpened.BringToFront;
     LastFormImageOpened:= nil;
  end;
end;


procedure TForm_Main.RxRTFDblClick(Sender: TObject);
var
  ImgID, p, SL: integer;
  txt: AnsiString;
  ImgIDs: TImageIDs;

begin
   ImgID:= 0;
   if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
      SL:= ActiveNote.Editor.SelLength;
      if SL = 1 then
         ImgID:= CheckToIdentifyImageID(ActiveNote.Editor, p)

      else if SL > 1 then begin
         txt:= ActiveNote.Editor.SelVisibleText;
         if Length(txt) < SL then begin
           ImgIDs:= ImagesManager.GetImagesIDInstancesFromTextPlain(ActiveNote.Editor.SelText);
           if ImgIDs <> nil then
              ImgID:= ImgIDs[0];
         end;
      end;
   end;

   if ImgID <> 0 then
      ImagesManager.OpenImageViewer(ImgID, CtrlDown, false);
end;



procedure TForm_Main.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of

    VK_TAB :
    if ( shift = [ssCtrl] ) then begin // Ctrl+Tab: switch to next tab
       key := 0;
       Pages.SelectNextPage( true );
       // RxRTFKeyProcessed := true;
    end
    else
      if ( shift = [ssCtrl,ssShift] ) then begin
         Key := 0;
         Pages.SelectNextPage( false );
      end;

    VK_PRIOR : if ( shift = [ssCtrl] ) then // Page Up
    begin
      key := 0;
      Pages.SelectNextPage( false );
    end
    else
    if ( KeyOptions.ResPanelShow and ( shift = [ssAlt] )) then
    begin
      key := 0;
      Pages_Res.SelectNextPage( false );
    end;

    VK_NEXT : if ( shift = [ssCtrl] ) then // Page Down
    begin
      key := 0;
      Pages.SelectNextPage( true );
    end
    else
    if ( KeyOptions.ResPanelShow and ( shift = [ssAlt] )) then
    begin
      key := 0;
      Pages_Res.SelectNextPage( true );
    end;

    VK_ESCAPE : begin
      //_Is_Dragging_Text := false;
      if (( shift = [] ) and ( not (
        Combo_Font.DroppedDown or
        Combo_FontSize.DroppedDown or
        Combo_Style.DroppedDown or
        Combo_ResFind.DroppedDown or
        Combo_Zoom.DroppedDown ))) then
      begin
        // ESC has different functions depending on
        // what's happening at the moment:
        key := 0;
        if ( Is_Replacing or SearchInProgress ) then
        begin
          UserBreak := true; // will abort search
        end
        else
        if IsRunningMacro then
        begin
          MacroAbortRequest := true; // will abort macro
        end
        else
        if IsRecordingMacro then
        begin
          TB_MacroRecordClick( TB_MacroRecord ); // aborts macro recording
        end
        else if CopyFormatMode <> cfDisabled then begin
           EnableCopyFormat(False);
        end
        else
        begin
          if ( activecontrol = Combo_FontSize ) or
             ( activecontrol = Combo_Font ) or
             ( activecontrol = FindAllResults ) or (activecontrol = Btn_ResFind) or (activecontrol = Btn_ResFlip) or
             (( activecontrol = combo_ResFind ) and (combo_resfind.Text = '')) or
             ( activecontrol = Res_RTF ) or
             ( activecontrol = ListBox_ResMacro ) or
             ( activecontrol = ListBox_ResTpl ) or
             ( activecontrol = ListBox_ResPlugins ) or
             ( activecontrol = ListBox_ResFav ) or
             ( activecontrol = Combo_Zoom ) or
             ( activecontrol = Combo_Style ) then
          begin
            // if these controls are focused,
            // switch focus to editor
            if activecontrol = Combo_Zoom then
               Combo_Zoom.Text := '';        // To ignore the value set
            key := 0;
            FocusActiveNote;
          end
          else
          if ( activecontrol = combo_ResFind ) then
          begin
            combo_resfind.Text := '';
          end
          else
          begin
            // otherwise perform the function which
            // is configured in options
            case KeyOptions.EscAction of
              ESC_MINIMIZE : Application.Minimize;
              ESC_QUIT : Close;
            end;
          end;
        end;
      end;
    end;


    VK_INSERT:
       if ( shift = [ssShift] ) then begin
         if CmdPaste(false, false) then key:= 0;
       end
       else if shift = [ssCtrl] then begin
         if CmdCopy then key:= 0;
       end;

    VK_DELETE:
       if ( shift = [ssShift] ) then begin
         if CmdCut then key:= 0;
       end;

// We'll manage CTR-V,CTR-C,CTR-X from FormShortCut. From this only CTR-V can be intercepted
//    ELSE BEGIN
//        ShortCutToKey(16470, myKey, myShift);
//        if (myKey=key) and (myShift=Shift) then begin
//            if CmdPaste(false) then key:= 0;
//        end
//    END;
  end;

  if not (key in [0, 17, 18]) and
           ( (ssCtrl in Shift) or (ssAlt in Shift) ) or
           ( (Shift = [ssShift]) and (key in [VK_F1..VK_F4]) ) then begin
     if PerformOtherCommandShortcut( Key, Shift ) then
         Key := 0;
  end;

end; // KEY DOWN



{ https://answers.microsoft.com/en-us/windows/forum/all/ctrlshift0-in-windows-10/337b6542-4159-4143-83a8-a4496f8f995c
<< it appears that the KeyDown event is not getting through in some cases for Ctrl+Shift+0, but the KeyUp event is. >>
}
procedure TForm_Main.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = Ord('0')) and (Shift = [ssCtrl, ssShift]) then
     PerformCmd( ecClearParaAttr );
end;


function TForm_Main.FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
begin
   CallHelp:= False;
   if AltDown or CtrlDown or ShiftDown then exit;

   // -1 -> 536-1   "Restore image[s] proportions" -> Dimensions and proportions
   // -2 -> 284-11  "Children Checkboxes" -> Tree-type Notes [284] / 11 (Using Hidden nodes)
   // -3 -> 282-9   Menu Number -> KeyNote Editor [282]/ 9 (Using bullets and numbered lists)
   // -4 -> 11-1    Menu ResPanel -> KeyNote Screen [11] / Marker: 1
   // -5 -> 479-5   Find All
   if (Command = HELP_CONTEXT) and (Data < 0) then
       Command:= HELP_COMMAND;
       case Data of
         -1: Data:= NativeInt(PChar('536-1'));
         -2: Data:= NativeInt(PChar('284-11'));
         -3: Data:= NativeInt(PChar('282-9'));
         -4: Data:= NativeInt(PChar('11-1'));
         -5: Data:= NativeInt(PChar('479-5'));
       end;

   ActiveKeyNoteHelp_FormHelp(Command, Data);
end;



procedure TForm_Main.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  ShiftPressed: boolean;
  ShortCut: TShortCut;
  ShortCutItem: TMenuItem;
begin
   if not Active then exit;         // => ImgViewerInstance.Active = True

   ShortCut := ShortCutFromMessage(Msg);
   if ShortCut = MMViewResPanel.ShortCut then begin
       MMViewResPanelClick (nil);
       Handled:= true;
   end;

   if (GetKeyState(VK_CONTROL) < 0) and not (GetKeyState(VK_MENU) < 0) then
   begin
      ShiftPressed:= (GetKeyState(VK_SHIFT) < 0);

      ShortCutItem:= nil;
      if ShiftPressed then begin
         //ShortCut := ShortCutFromMessage(Msg);
         ShortCutItem := Menu.FindItem(ShortCut, fkShortCut);
      end;

      if assigned(ShortCutItem) then exit;

      if Msg.CharCode = Ord('C')  then begin
          if CmdCopy then Handled:= true;
      end else if Msg.CharCode = Ord('V') then begin
          if shiftPressed then begin
              if CmdPaste(false, true)  then Handled:= true;    // Plain text
          end
          else begin
              if CmdPaste(false, false) then Handled:= true;
          end;
      end else if Msg.CharCode = Ord('X') then begin
          if CmdCut then Handled:= true;

      end
      else if (not ShiftPressed) then begin
        if Msg.CharCode = VK_DOWN then begin
           ActiveNote.Editor.ScrollLinesBy(1);
           Handled:= true;
        end else if Msg.CharCode = VK_UP then begin
           ActiveNote.Editor.ScrollLinesBy(-1);
           Handled:= true;
        end else if Msg.CharCode = VK_RETURN then begin
           if activeControl = ListBox_ResFav then begin
             JumpToFavorite;
             Handled:= true;
           end;
        end;
      end
      else if KeyOptions.UseCtrlHideTreePanel then begin
          // Check if the keys combination, without Ctrl, is a shortcut to MMViewTree
          ShortCutItem := Menu.FindItem(ShortCut - scCtrl, fkShortCut);
          if ShortCutItem = MMViewTree then begin
             MMViewTreeClick(nil);
             Handled:= true;
          end;
      end;

   end;
end;

procedure TForm_Main.Combo_StyleChange(Sender: TObject);
var
  idx : integer;
  name : string;
begin
  idx := Combo_Style.ItemIndex;
  Combo_Style.Hint := '';
  if ( idx < 0 ) then exit;
  name := Combo_Style.Items[idx];
  if ( StyleManager.Count > idx ) then
  begin
    case TStyle( StyleManager.Objects[idx] ).Range of
      srFont : StatusBar.Panels[PANEL_HINT].Text :=
        TStyle( StyleManager.Objects[idx] ).FontInfoToStr( true );
      srParagraph : StatusBar.Panels[PANEL_HINT].Text :=
        TStyle( StyleManager.Objects[idx] ).ParaInfoToStr( true );
      srBoth : StatusBar.Panels[PANEL_HINT].Text :=
        TStyle( StyleManager.Objects[idx] ).FontInfoToStr( true ) +
        TStyle( StyleManager.Objects[idx] ).ParaInfoToStr( true );
    end;
    Combo_Style.Hint := StatusBar.Panels[PANEL_HINT].Text;
  end;

end; // Combo_StyleChange


procedure TForm_Main.RxRTFKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  NextIndent, Indent, posFirstChar : integer;
  LineStr : string;
  ptCursor :  TPoint;
  Editor: TRxRichEdit;
  URLStr, TxtSel: string;
  L, R: Integer;
  Offset: integer;
  ch: char;

begin
  _IS_FAKING_MOUSECLICK := false;
  if assigned( ActiveNote ) then
     ActiveNote.FocusMemory := focRTF
  else
     exit;

  Editor:= TRxRichEdit(sender);

  if ( not ( key in [16..18] )) then begin  // skip bare modifier keys
    LastRTFKey.Key := Key;
    LastRTFKey.Shift := Shift;
    if IsRecordingMacro then
       AddMacroKeyPress( Key, Shift );
  end;


  if ( shift = [] ) then begin
    case Key of

      VK_LEFT: begin   // Left cursor
        with Editor do begin
           { Suppose something like 'LEFT visible text'<hidden text>'RIGHT visible text' where we use the <hidden text> as metadata linked to the
             visible text on its right, next to the one we want it to remain. That hidden text can be a marker that we will use as a target reference
             of a hyperlink.

             It is not possible to put the cursor inside hidden text, and if we advance from 'LEFT' by pressing the right cursor, we will be able to
             position ourselves just before of <hidden text> or past the 'T' of visible text. Therefore, if after placing the cursor just after LEFT
             we write something (eg **"), those characters will be written to the left of the hidden text. Ok

             But if from 'RIGHT visible text' we move to the left with the cursor, we can place it just to the right of <hidden text>, immediately
             before the first visible character from the right. That would be a problem if we don't control it, because if we write something
             (eg ** or line breaks) we would be separating the hidden text from the visible text with which it should be linked.

             Note: In MS Word this would not happen, because moving to the left would also skip non-visible characters

             For this reason, we are interested in detecting if, in the case of completing the displacement to the left, we would place ourselves
             immediately leaving to our left the hidden character. Since we are going to use a specific character (completely unusual) to delimit
             these hidden texts, we will check if that is the one that would be to our left. And for more security, we will verify if it is hidden,
             which we will verify in a simple way based on another behavior of the RichEdit control: since it does not allow placing the cursor
             inside hidden texts, if we change the position of it (with SelStart) to the left of the character we are checking, the final position
             of the cursor will not be the one we are setting if it was hidden, but it will correspond to the first position immediately before the hidden text.

             This has the advantage that although our hidden text can be of variable length, we can easily place the cursor at the beginning of the
             same.
             If instead of checking if SelStart has been respected we did SelLength:= 1; and then look at SelAttributes.Hidden; we would see that it
             is True because we would be selecting hidden text.

             Comparison with '"', to detect the possible end of the hidden text of a hyperlink. If we have added a hidden mark next to a link,
             we are also interested in ensuring that no text or other items are interspersed between the two
           }

          L:= SelStart;
          if SelLength = 0 then
             Offset:= 2
          else
             Offset:= 1;

          if L >= Offset then begin
             TxtSel:= GetTextRange(L-Offset, L-Offset + 1);
             if Length(TxtSel) > 0 then begin
                ch:= TxtSel[1];
                if (ch = KNT_RTF_HIDDEN_MARK_R_CHAR) or (ch = '"') then begin
                   OnSelectionChange := nil;
                   try
                     SelStart:= L-Offset;
                     if SelStart <> L-Offset then
                        key:= 0                    // It will have been placed to the left of the first hidden character
                     else
                        SelStart:= L;              // It was not hidden. We leave it where it was and allow the keyboard event to be handled as normal.
                   finally
                      OnSelectionChange := RxRTFSelectionChange;
                   end;
                end;
             end;
          end;
        end;
      end;


      VK_INSERT : begin
        if EditorOptions.DisableINSKey then begin
          key := 0;
          StatusBar.Panels[PANEL_HINT].Text := STR_13;
        end
        else
          PerformCmdEx( ecInsOvrToggle );
      end;

      VK_HOME: begin
          GetIndentInformation(Editor, Indent, NextIndent, LineStr, posFirstChar);
          if ((Editor.SelStart > (posFirstChar + Indent)) or
              ((Indent>0) and (Editor.SelStart = posFirstChar)) ) then begin
             Editor.SelStart:= posFirstChar + Indent;
             key:= 0;
             // Apparently it wouldn't matter if we entered if (Indent=0), but when
             // wrapping is enabled and we are at the final of one line SelStart can return the
             // same value as if we were at the beginning of the next one. In that case, the cursor
             // would move incorrectly to the first character of next line.
          end;
      end;

      VK_RETURN :
           if EditorOptions.AutoIndent and (Editor.Paragraph.TableStyle = tsNone) then begin
              if NoteIsReadOnly( ActiveNote, true ) then exit;
              GetIndentInformation(Editor, Indent, NextIndent, LineStr, posFirstChar, true);
              with Editor do begin
                if (Indent = length(LineStr)) and (Paragraph.Numbering <> nsNone) and (Paragraph.NumberingStyle <> nsNoNumber) then
                   Paragraph.Numbering :=  nsNone
                else if (length(LineStr)= 0) and (Paragraph.NumberingStyle = nsNoNumber) then begin
                    key := 0;
                    SelText := #13#10;
                    SelStart := ( SelStart+SelLength ) -1;
                    Paragraph.NumberingStyle := nsNoNumber;
                    end
                else
                  if NextIndent > 0 then begin
                    // insert a linebreak followed by the substring of blanks and tabs
                    // If we are inside a hyperlink, do nothing here. It's risky and unuseful
                    ActiveNote.Editor.GetLinkAtCursor(URLStr, TxtSel, L, R, false);
                    if URLStr = '' then begin
                       key := 0;
                       TxtSel:= #13 + Copy(LineStr, 1, NextIndent);
                       SelText := TxtSel;
                       SelStart := SelStart + Length(TxtSel);
                    end;
                  end;

              end;
           end;

       VK_DELETE:
          CheckToSelectImageHiddenMarkOnDelete (Editor);

       VK_BACK:
          if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
             if Editor.SelLength = 0 then
                Offset:= -1
             else
                Offset:= 0;
             CheckToSelectLeftImageHiddenMark(Editor, Offset);
          end;
    end;

  end  // if ( shift = [] )
  else
  if ( shift = [ssShift] ) then begin
    case key of
      VK_F10 : begin
        key := 0;
        GetCursorPos( ptCursor );
        Menu_RTF.Popup( ptCursor.X, ptCursor.Y );
      end;
    end;
  end
  else
  if ( shift = [ssCtrl] ) then begin
    case Key of

      { grey  *}
      VK_MULTIPLY : if Combo_Style.Visible then
        try
          Combo_Style.SetFocus;
        except
        end;

      { grey / }
      111 : if KeyOptions.ResPanelShow then  // if Combo_Macro.Visible then
        try
          Pages_Res.ActivePage := ResTab_Macro;
          ListBox_ResMacro.SetFocus;
        except
        end;

      { backslash }
      220 : if ( Shift = [ssCtrl] ) then begin
        Key := 0;
        MMTreeFocusTreeClick (nil);
      end;
    end;

  end;

end; // RxRTFKeyDown

procedure TForm_Main.RxRTFKeyPress(Sender: TObject; var Key: Char);
var
  Sel: TCharRange;
  SelectionLength: integer;
  posBegin, posEnd: integer;
  L, toLine: integer;
  MoveSelectedLines, ShiftPressed: boolean;
  RTFAux : TRxRichEdit;
  Str: string;
  SpacesAsTab: string;

  procedure SendSpaces(Editor: TRxRichEdit; n: integer);
  var
    i: integer;
  begin
     for i := 1 to n do
         Editor.Perform(WM_CHAR, 32, 0);
  end;

  procedure RemoveTABorSpaces(Editor: TRxRichEdit; Line: integer; NSpaces: integer);
  var
    i, num: integer;
    Str: string;
  begin
     Str:= Editor.Lines[Line];
     i:= 1;
     num:= 0;
     while (i <= Length(Str)) and (num < NSpaces) do begin
        if (Str[i] = ' ') or ((Str[i] = #9) and (num = 0)) then
           Inc(num);
        if (Str[i] <> ' ') then
           break;
        Inc(i);
     end;
     if num > 0  then begin
        Editor.SelLength:= num;
        Editor.SelText:= '';
     end;
  end;


begin
  if ( RxRTFKeyProcessed or ((Key = #9) and (GetKeyState(VK_CONTROL) < 0)) ) then begin
    Key := #0;
    RxRTFKeyProcessed := false;
    exit;
  end;

  if not assigned(ActiveNote) or NoteIsReadOnly( ActiveNote, true ) then exit;

  posBegin:= 0;     // To avoid compiler warning on SelStart:= posBegin (but really no necessary)

  case key of

    #9 :    with ActiveNote.Editor do begin
               ShiftPressed:= (GetKeyState( VK_SHIFT ) < 0 );
               Sel:= GetSelection;
               MoveSelectedLines:= false;
               if not (Sel.cpMin= Sel.cpMax) then begin   // There is text selected
                  if FindText(#13, Sel.cpMin, Sel.cpMax-Sel.cpMin, []) > 0 then begin
                     MoveSelectedLines:= true;
                     posBegin := FindText(#13, Sel.cpMin, -1, [stBackward]) + 1;
                     posEnd :=   FindText(#13, Sel.cpMax-1, -1, []);
                     if posEnd < 0 then
                        posEnd:= TextLength;
                     SetSelection(posBegin, posEnd+1, true);
                  end;
               end;

               if not MoveSelectedLines then begin
                  if ShiftPressed then begin
                     Key := #0;
                     MMTreeFocusTreeClick (nil);
                  end
                  else
                     if not UseTabChar then begin
                         Key := #0;
                         SendSpaces(ActiveNote.Editor, TabSize);
                     end;
               end
               else begin
                   SpacesAsTab:= StringOfChar (' ', TabSize);

                   RTFAux:= CreateRTFAuxEditorControl (ActiveNote);

                   toLine:=   RTFAux.Lines.Count-1;
                   BeginUpdate;
                   try
                      Key := #0;
                      if not ShiftPressed then begin
                         for L := 0 to toLine do begin
                            RTFAux.SelStart:= RTFAux.Perform(EM_LINEINDEX, L, 0);
                            if UseTabChar then
                               RTFAux.Perform(WM_CHAR, 9, 0)
                            else
                               RTFAux.SelText := SpacesAsTab;
                         end;
                      end
                      else
                         for L := 0 to toLine do begin
                            RTFAux.SelStart:= RTFAux.Perform(EM_LINEINDEX, L, 0);
                            RemoveTABorSpaces(RTFAux, L, TabSize);
                         end;

                      SelectionLength:= RTFAux.TextLength;
                      if ActiveNote.PlainText  then
                         Str:= RTFAux.Text + #13#10
                      else
                         Str:= RTFAux.RtfText;

                      ActiveNote.Editor.PutRtfText(Str, True);

                      SelStart:= posBegin;                           // MoveSelectedLines=True => posBegin is initialized
                      SelLength:= SelectionLength + 1;
                   finally
                      RTFAux.Free;
                      EndUpdate;
                   end;
               end;

            end;

       else begin
          if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
             if ActiveNote.Editor.SelLength > 0 then
                CheckToSelectLeftImageHiddenMark (ActiveNote.Editor);
          end;
       end;


  end;

  if EditorOptions.WordCountTrack then begin
     if key in WordDelimiters then
        CheckWordCount
     else
        CheckWordCountWaiting;

  end;

end;  // RxRTF_KeyPress


procedure TForm_Main.RxRTFProtectChange(Sender: TObject; StartPos,
  EndPos: Integer; var AllowChange: Boolean);
begin
  AllowChange := EditorOptions.EditProtected;
end; // RxRTF_ProtectChange

procedure TForm_Main.RxRTFProtectChangeEx(Sender: TObject;
  const Message: TMessage; StartPos, EndPos: Integer;
  var AllowChange: Boolean);
begin
  AllowChange := EditorOptions.EditProtected;
end; // RxRTF_ProtectChangeEx

procedure TForm_Main.RxRTFAuxiliarProtectChangeEx(Sender: TObject;
  const Message: TMessage; StartPos, EndPos: Integer;
  var AllowChange: Boolean);
begin
  AllowChange := True;
end; // RxRTFAuxiliarProtectChangeEx


procedure TForm_Main.RxFindAllResultsSelectionChange(Sender: TObject);
begin
  FindAllResults_OnSelectionChange (sender as TRxRichEdit);
end;

procedure TForm_Main.RxRTFSelectionChange(Sender: TObject);
var
  myRTF : TTabRichEdit;
  FontStyles: TFontStyles;
  SubscriptStyle: TSubscriptStyle;
  Numbering: TRxNumbering;
  SelAttributes: TRxTextAttributes;
begin
  RTFUpdating := true;
  try
    myRTF := ( sender as TTabRichEdit );


    { Ensure that the hidden mark accompanies its image in the event that it moves by dragging
      *1:
       Finally I apply ClearUndo because SupendUndo and ResumeUndo do not work as expected here:
       if you press Undo then the image does not return to its initial position, and the added
       hidden characters become visible.
       Could have not used SupendUndo and ResumeUndo, but in that case we risk pressing Undo an
       insufficient number of times, and the operation being left halfway, with the image moved
       but without the hidden label correctly added next to it
     }
    if (DraggingImageID > 0) then begin
       var DraggingImage_NewPosImage: integer;
       var RTFHiddenMark: AnsiString;
       var pI, pF, Len: integer;

       RTFHiddenMark:= Format(KNT_RTF_IMG_HIDDEN_MARK_CHAR, [DraggingImageID]);
       DraggingImageID:= 0;

       with myRTF do begin
          OnSelectionChange := nil;
          BeginUpdate;
          myRTF.SuspendUndo;
          try
             DraggingImage_NewPosImage:= myRTF.SelStart;
             myRTF.SelLength:= 0;
             myRTF.SelText:= RTFHiddenMark;
             myRTF.SelAttributes.Hidden := True;

             pI:= DraggingImage_PosFirstHiddenChar;
             pF:= DraggingImage_PosImage;
             if DraggingImage_NewPosImage < DraggingImage_PosImage then begin
                Len:= Length(RTFHiddenMark)+1;
                inc(pI, Len);
                inc(pF, Len);
                inc(DraggingImage_NewPosImage, Len);
             end;
             myRTF.SetSelection(pI, pF, true);
             myRTF.SelText:= '';
             myRTF.SelStart:= DraggingImage_NewPosImage;

          finally
            myRTF.ResumeUndo;
            myRTF.ClearUndo;                                         // *1
            EndUpdate;
            OnSelectionChange := Form_Main.RxRTFSelectionChange;
          end;
       end;
    end;
    DraggingImageID:= 0;


    Combo_Font.FontName := myRTF.SelAttributes.Name;
    Combo_FontSize.Text := inttostr( myRTF.SelAttributes.Size );

    FontStyles:= myRTF.SelAttributes.Style;

    TB_Bold.Down := fsBold in FontStyles;
    MMFormatBold.Checked := TB_Bold.Down;

    TB_Italics.Down := fsItalic in FontStyles;
    MMFormatItalics.Checked := TB_Italics.Down;

    TB_Underline.Down := fsUnderline in FontStyles;
    MMFormatUnderline.Checked := TB_Underline.Down;

    TB_Strikeout.Down := fsStrikeOut in FontStyles;
    MMFormatStrikeout.Checked := TB_Strikeout.Down;

    case myRTF.Paragraph.LineSpacing of
      0 : begin
        MMFormatLS1.Checked := true;
        TB_Space1.Down := true;
      end;
      1 : begin
        MMFormatLS15.Checked := true;
        TB_Space15.Down := true;
      end;
      2 : begin
        MMFormatLS2.Checked := true;
        TB_Space2.Down := true;
      end;
    end;

    Numbering:= myRTF.Paragraph.Numbering;

    if ( _LoadedRichEditVersion > 2 ) then
    begin
      TB_Bullets.Down := ( Numbering = nsBullet );
      MMFormatBullets.Checked := TB_Bullets.Down;
      TB_Numbers.Down := ( not ( Numbering in [nsNone, nsBullet] ));
      MMFormatNumbers.Checked := TB_Numbers.Down;
    end
    else
    begin
      TB_Bullets.Down := ( Numbering <> nsNone );
      MMFormatBullets.Checked := TB_Bullets.Down;
    end;

    SelAttributes:= myRTF.SelAttributes;
    MMFormatDisabled.Checked := SelAttributes.Disabled;

    SubscriptStyle:= SelAttributes.SubscriptStyle;
    MMFormatSubscript.Checked := SubscriptStyle = ssSubscript;
    TB_Subscript.Down := MMFormatSubscript.Checked;
    MMFormatSuperscript.Checked := SubscriptStyle = ssSuperscript;
    TB_Superscript.Down := MMFormatSuperscript.Checked;

    case myRTF.Paragraph.Alignment of
      paLeftJustify : begin
        TB_AlignLeft.Down := true;
        MMFormatAlignLeft.Checked := true;
      end;
      paRightJustify : begin
        TB_AlignRight.Down := true;
        MMFormatAlignRight.Checked := true;
      end;
      paCenter : begin
        TB_AlignCenter.Down := true;
        MMFormatAlignCenter.Checked := true;
      end;
      paJustify : begin
        TB_AlignJustify.Down := true;
        MMFormatAlignJustify.Checked := true;
      end;
    end;

    UpdateCursorPos;
  finally
    RTFUpdating := false;
  end;


  if KeyOptions.ImgHotTrackViewer then begin
     if ImgViewerInstance <> nil then begin
        var ImgID, p: integer;
        ImgID:= 0;

        if (ActiveNote.Editor.SelLength = 1) then
           ImgID:= CheckToIdentifyImageID(ActiveNote.Editor, p)

        else begin
            if ShowingImageOnTrack  then
               ShowingImageOnTrack:= false
            else
              if SelAttributes.Link and (ActiveNote.Editor.SelLength = 0) then begin
                 var URLText, TxtSel: string;
                 var chrg: TCharRange;
                 var L, R: integer;
                 ActiveNote.Editor.GetLinkAtCursor(URLText, TxtSel, L, R, false);
                 ImgID:= GetImageIDinPlaintext(URLText);
              end;
        end;

        if (ImgID > 0) and (ImgViewerInstance.Image.ID <> ImgID) then begin
           ImagesManager.OpenImageViewer(ImgID, false, false);
           ShowingImageOnTrack:= true;
        end;
     end;

     CheckRestoreTreeWidth;
  end;
end; // RxRTFSelection Change

procedure TForm_Main.RxRTFChange(Sender: TObject);
begin
  if ( sender as TTabRichEdit ).Modified then
     OnNoteChange(ActiveNote);
end; // RxRTFChange

procedure TForm_Main.OnNoteChange(Note: TTabNote);
begin
  if not assigned(Note) then exit;                   // It could occur if recreating RichEdit window very soon

  Note.Modified := true;
  NoteFile.Modified := true;
  UpdateNoteFileState( [fscModified] );

  if (ActiveNote.Kind = ntTree) then begin
      with TTreeNote(ActiveNote) do
        if assigned(SelectedNode) then
           SelectedNode.RTFModified := true
        else
           messagedlg( STR_14, mtError, [mbOK], 0 );
  end;

  TB_EditUndo.Enabled := Note.Editor.CanUndo;
  TB_EditRedo.Enabled := Note.Editor.CanRedo;
  RTFMUndo.Enabled := TB_EditUndo.Enabled;

  if CopyFormatMode= cfEnabled then
     EnableCopyFormat(False);

end; // OnNoteChange


procedure TForm_Main.UpdateWordWrap;
var
  isWordWrap : boolean;
begin
  if assigned( ActiveNote ) and assigned( ActiveNote.Editor ) then
  begin
    isWordWrap := ActiveNote.Editor.WordWrap;
    MMFormatWordWrap.Checked := isWordWrap;
    TB_WordWrap.Down := isWordWrap;
    RTFMWordwrap.Checked := isWordWrap;
  end;
end; // UpdateWordWrap

procedure TForm_Main.MMEditSelectAllClick(Sender: TObject);
begin
    PerformCmd( ecSelectAll );
end;

procedure TForm_Main.MMFormatWordWrapClick(Sender: TObject);
begin
    PerformCmd( ecWordWrap );
end;

procedure TForm_Main.MMNoteReadOnlyClick(Sender: TObject);
begin
  PerformCmdEx( ecReadOnly );
end;

procedure TForm_Main.MMEditEvaluateClick(Sender: TObject);
begin
  EvaluateExpression;
end;


procedure TForm_Main.PagesChange(Sender: TObject);
var
   ModifiedDataStream: TMemoryStream;
   SelectedNode: TNoteNode;
begin

  try
    if (( Pages.PageCount > 0 ) and assigned( Pages.ActivePage )) then begin
      if assigned(ActiveNote) then begin
         CheckRestoreAppWindowWidth (true);
         ModifiedDataStream:= ActiveNote.EditorToDataStream;   // If its Editor is not modified it will do nothing. Necessary to ensure that changes are seen among mirror nodes
      end;

      if not _Executing_History_Jump then begin
         AddHistoryLocation (ActiveNote, true);                  // true: add to local history maintaining it's index, and without removing forward history
         _LastMoveWasHistory := false;
      end;

      ActiveNote := TTabNote( Pages.ActivePage.PrimaryObject );
      if (ActiveNote.Kind = ntTree) then begin
          SelectedNode:= TTreeNote(ActiveNote).SelectedNode;
          if assigned(SelectedNode) and (SelectedNode.Stream = ModifiedDataStream) then
             ActiveNote.DataStreamToEditor;
      end;

      ActiveNote.ImagesMode := ImagesManager.ImagesMode;


      TAM_ActiveName.Caption := ActiveNote.Name;
      TB_Color.AutomaticColor := ActiveNote.EditorChrome.Font.Color;
      if not SearchInProgress then
         FocusActiveNote;

    end
    else begin
      ActiveNote := nil;
      TB_Color.AutomaticColor := clWindowText;
      TAM_ActiveName.Caption := STR_15_ActiveNote;
    end;

  finally
    UpdateNoteDisplay;
    if assigned(ActiveNote) then
       CheckWordCount(true);
    if not _Executing_History_Jump then
       UpdateHistoryCommands;
    StatusBar.Panels[PANEL_HINT].Text := '';
  end;
end; // PagesChange

procedure TForm_Main.PagesTabShift(Sender: TObject);
begin
  try
    ActiveNote := TTabNote( Pages.ActivePage.PrimaryObject );
    if assigned( ActiveNote ) then
    begin
      ActiveNote.TabIndex := Pages.ActivePage.TabIndex;
      Pages.ActivePage.ImageIndex := ActiveNote.ImageIndex;
      TAM_ActiveName.Caption := ActiveNote.Name;
      FocusActiveNote;
    end
    else
    begin
      TAM_ActiveName.Caption := '';
    end;
  finally
    NoteFile.Modified := true;
    UpdateNoteFileState( [fscModified] );
  end;

end; // TAB SHIFT

procedure TForm_Main.MMEditCutClick(Sender: TObject);
begin
    CmdCut;
end; // CUT

procedure TForm_Main.MMEditCopyClick(Sender: TObject);
begin
    CmdCopy;
end; // COPY

procedure TForm_Main.MMEditPasteClick(Sender: TObject);
begin
    CmdPaste(sender is TToolbarButton97, false);
end; // PASTE

procedure TForm_Main.MMEditDeleteClick(Sender: TObject);
begin
    PerformCmd( ecDelete );
end; // DELETE

procedure TForm_Main.MMEditUndoClick(Sender: TObject);
begin
    PerformCmd( ecUndo );
end;

procedure TForm_Main.MMEditRedoClick(Sender: TObject);
begin
    PerformCmd( ecRedo );
end;

procedure TForm_Main.MMEditPasteAsTextClick(Sender: TObject);
begin
  PerformCmd( ecPastePlain );
end;

function TForm_Main.NoteSelText : TRxTextAttributes;
begin
  result := ActiveNote.Editor.SelAttributes;
end; // NoteSelText


procedure TForm_Main.ErrNoTextSelected;
begin
  StatusBar.Panels[PANEL_HINT].Text := STR_16;
end;

procedure TForm_Main.NewVersionInformation;
begin
  if ( not KeyOptions.IgnoreUpgrades and ( IsLaterVersion(KeyOptions.LastVersion, Program_Version_Number ) )) then begin
     //KeyOptions.TipOfTheDay := true;
     KeyOptions.TipOfTheDayIdx := -1;
     case messagedlg(
       Format(STR_17
       , [KeyOptions.LastVersion, Program_Version, SampleFileName] ),
       mtInformation, [mbYes,mbNo], 0
     ) of
       mrYes : begin
         DisplayHistoryFile;
       end;
     end;
  end;

end; // NewVersionInformation

procedure TForm_Main.DisplayHistoryFile;
var
  fn : string;
begin
  ActiveKeyNoteHelp(_KNT_HELP_FILE_NOTE_WHATSNEW_ID, 2, 0);   // What's New [2]
  {
  fn := extractfilepath( Application.Exename ) + 'doc\history.txt';
  if FileExists( fn ) then
    ShellExecute( 0, 'open', PChar( fn ), nil, nil, SW_NORMAL )
  else
    DoMessageBox( Format( STR_18, [fn] ), mtError, [mbOK], 0 );
   }
end; // DisplayHistoryFile

procedure TForm_Main.Combo_FontChange(Sender: TObject);
var
  oldsel : TNotifyEvent;
begin
  oldsel := nil;
  if ( not assigned( ActiveNote )) then exit;
  oldSel := ActiveNote.Editor.OnSelectionChange;
  ActiveNote.Editor.OnSelectionChange := nil;
  try
    if ( ActiveNote.FocusMemory = focTree ) then
    begin
      SetTreeNodeFontFace( false, ShiftDown );
    end
    else
    begin
      PerformCmd( ecFontName );
    end;
    // do not jump when in tree
  finally
    if assigned( oldsel ) then
      ActiveNote.Editor.OnSelectionChange := oldsel;
  end;

end; // Combo_FontChange

procedure TForm_Main.Combo_FontKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( not assigned( ActiveNote )) then exit;
  if ( shift = [] ) then
  begin
    case key of
      VK_RETURN, VK_ESCAPE : begin
        if ( key = VK_RETURN ) then
        begin
          if ( ActiveNote.FocusMemory = focTree ) then
          begin
            SetTreeNodeFontFace( false, ShiftDown );
          end
          else
          begin
            PerformCmd( ecFontName );
          end;
        end;
        key := 0;
        try
          if ( ActiveNote.FocusMemory = focRTF ) then
            ActiveNote.Editor.SetFocus
          else
          if ( ActiveNote.FocusMemory = focTree ) then
            TTreeNote( ActiveNote ).TV.SetFocus;
        except
        end;
      end;
    end;
  end;
end; // Combo_FontKeyDown

procedure TForm_Main.Combo_FontSizeClick(Sender: TObject);
var
  oldsel : TNotifyEvent;
begin
  if ( RTFUpdating or FileIsBusy ) then exit;
  if (( Sender = Combo_FontSize ) and ( Combo_FontSize.Text = '' )) then exit;

  oldsel := nil;
  if assigned( ActiveNote ) then begin
    oldSel := ActiveNote.Editor.OnSelectionChange;
    ActiveNote.Editor.OnSelectionChange := nil;
  end;

  try
    if ( Sender = Combo_FontSize ) then
       PerformCmd( ecFontSize )
    else if ( Sender = Combo_Zoom ) then begin
       SetEditorZoom( -1, Combo_Zoom.Text );
       FocusActiveNote;
    end;

  finally
    if assigned( oldsel ) then
      ActiveNote.Editor.OnSelectionChange := oldsel;
  end;
end; // Combo_FontSizeClick


procedure TForm_Main.Combo_FontSizeExit(Sender: TObject);
begin
  if Combo_FontSize.Text <> '' then
     PerformCmd( ecFontSize )
  else
  try
     Combo_FontSize.Text := IntToStr( ActiveNote.Editor.SelAttributes.Size );
  except
  end;
end;


procedure TForm_Main.Combo_FontSizeKeyPress(Sender: TObject;
  var Key: Char);
begin
  if ( not assigned( ActiveNote )) then exit;

  if not (key in [#8, #9, #13, #27, #37..#40, #46, '0'..'9', '%']) then begin
    key := #0;
    exit;
  end;

  if ( key = #13 ) then begin
    key := #0;

    if ( Sender = Combo_Zoom ) then
      SetEditorZoom( -1, Combo_Zoom.Text );

    try
      if ( ActiveNote.FocusMemory = focRTF ) then
        ActiveNote.Editor.SetFocus
      else if ( ActiveNote.FocusMemory = focTree ) then
        TTreeNote( ActiveNote ).TV.SetFocus;
    except
    end;
  end
  {                                      It's controlled from TForm_Main.FormKeyDown
  else
  if ( key = #27 ) then begin
    key := #0;
    FocusActiveNote;
  end;
  }
end; // Combo_FontSizeKeyPress


procedure TForm_Main.MMFormatBoldClick(Sender: TObject);
var
  BoldWasDown : boolean;
begin
  if ( self.ActiveControl is TTreeNT ) then
  begin
    BoldWasDown := ( not TB_Bold.Down ); // button .Down state has ALREADY changed
    try
      SetTreeNodeBold( ShiftDown )
    finally
      TB_Bold.Down := BoldWasDown;
    end;
  end
  else
  begin
    PerformCmd( ecBold );
  end;
end;

procedure TForm_Main.MMFormatItalicsClick(Sender: TObject);
begin
  PerformCmd( ecItalics );
end;

procedure TForm_Main.MMFormatUnderlineClick(Sender: TObject);
begin
  PerformCmd( ecUnderline );
end;

procedure TForm_Main.MMFormatStrikeoutClick(Sender: TObject);
begin
  PerformCmd( ecStrikeOut );
end;

procedure TForm_Main.MMFormatClearFontAttrClick(Sender: TObject);
begin
  PerformCmd( ecClearFontAttr );
end;

procedure TForm_Main.MMFormatClearParaAttrClick(Sender: TObject);
begin
  PerformCmd( ecClearParaAttr );
end;

procedure TForm_Main.MMFormatBulletsClick(Sender: TObject);
begin
  PerformCmd( ecBullets );
end;

procedure TForm_Main.MMFormatLIndIncClick(Sender: TObject);
begin
  PerformCmd( ecIndent );
end;

procedure TForm_Main.MMFormatLIndDecClick(Sender: TObject);
begin
  PerformCmd( ecOutdent );
end;

procedure TForm_Main.MMFormatFIndIncClick(Sender: TObject);
begin
    PerformCmd( ecFirstIndent );
end;

procedure TForm_Main.MMFormatFindDecClick(Sender: TObject);
begin
    PerformCmd( ecFirstOutdent );
end;

procedure TForm_Main.MMFormatRIndIncClick(Sender: TObject);
begin
  PerformCmd( ecRightIndent );
end;

procedure TForm_Main.MMFormatRIndDecClick(Sender: TObject);
begin
  PerformCmd( ecRightOutdent )
end;


procedure TForm_Main.MMFormatAlignLeftClick(Sender: TObject);
begin
  PerformCmd( ecAlignLeft );
end;

procedure TForm_Main.MMFormatAlignCenterClick(Sender: TObject);
begin
  PerformCmd( ecAlignCenter );
end;

procedure TForm_Main.MMFormatAlignRightClick(Sender: TObject);
begin
  PerformCmd( ecAlignRight );
end;

procedure TForm_Main.MMFormatNumbersClick(Sender: TObject);
begin
  PerformCmd( ecNumbers );
end;

procedure TForm_Main.MMFormatAlignJustifyClick(Sender: TObject);
begin
  PerformCmd( ecAlignJustify );
end;

procedure TForm_Main.MMFormatFontClick(Sender: TObject);
begin
  PerformCmd( ecFontDlg );
end;

procedure TForm_Main.MMFormatTextColorClick(Sender: TObject);
begin
  if KeyOptions.UseOldColorDlg then
    PerformCmd( ecFontColorDlg ) // bring up color dialog
  else
    PerformCmd( ecFontColor ); // apply last color
end;

procedure TForm_Main.MMFormatHighlightClick(Sender: TObject);
begin
  if KeyOptions.UseOldColorDlg then
    PerformCmd( ecHighlightDlg )
  else
    PerformCmd( ecHighlight );
end;

procedure TForm_Main.MMViewFilterTreeClick(Sender: TObject);
begin
    TB_FilterTreeClick(nil);
end;

procedure TForm_Main.MMViewFormatNoneClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
  begin
    case ( sender as TMenuItem ).Tag of
      ord( low( TStyleRange ))..ord( high( TStyleRange )) : begin
        EditorOptions.TrackStyle := true;
        EditorOptions.TrackStyleRange := TStyleRange(( sender as TMenuItem ).Tag );
      end;
      else
      begin
        EditorOptions.TrackStyle := false;
      end;
    end;
    ( sender as TMenuItem ).Checked := true;
    UpdateCursorPos;
  end;
end;


procedure TForm_Main.MMFormatNoHighlightClick(Sender: TObject);
begin
  PerformCmd( ecNoHighlight );
end;

procedure TForm_Main.TB_ColorClick(Sender: TObject);
begin
  TB_Color.OnClick := nil;
  try
    if ( self.ActiveControl is TTreeNT ) then
      SetTreeNodeColor( false, true, false, ShiftDown  )
    else
      PerformCmd( ecFontColorBtn );
  finally
    TB_Color.OnClick := TB_ColorClick;
  end;
end;

procedure TForm_Main.TB_HiliteClick(Sender: TObject);
begin
  TB_Hilite.OnClick := nil;
  try
    if ( self.ActiveControl is TTreeNT ) then
      SetTreeNodeColor( false, false, false, ShiftDown )
    else
      PerformCmd( ecHighlightBtn );
  finally
    TB_Hilite.OnClick := TB_HiliteClick;
  end;
end;

procedure TForm_Main.MMFormatBGColorClick(Sender: TObject);
begin
  PerformCmd( ecBGColorDlg );
end;

procedure TForm_Main.MRUMRUItemClick(Sender: TObject; AFilename: string);
begin
  NoteFileOpen( AFilename );
  FocusActiveNote;
end; // MRUMRUItemClick

procedure TForm_Main.DebugMenuClick(Sender: TObject);
var
  s : string;
  // i : integer;
begin
{$IFDEF KNT_DEBUG}
  if assigned( Log ) then Log.Flush( true );
{$ENDIF}
  { [debug] }

  s := 'Win32Platform: ' + Win32Platform.ToString + #13 +
       'Win32MajorVersion: ' + Win32MajorVersion.ToString + #13 +
       'Win32MinorVersion: ' + Win32MinorVersion.ToString + #13 +
       'RichEdit version: '  + _LoadedRichEditVersion.ToString + #13 +
       'AllocMemSize: ' + AllocMemSize.ToString;

  if ( messagedlg( s, mtInformation, [mbOK,mbCancel], 0 ) = mrCancel ) then exit;

  if HaveNotes( false, false ) then begin
    s := 'Filename: ' + ExtractFilename( NoteFile.FileName ) +#13+
         'Notes modified: ' + BOOLARRAY[NoteFile.Modified] +#13+
         'Notes count: ' + inttostr( NoteFile.NoteCount ) +#13+
         'File Read-Only: ' + BOOLARRAY[NoteFile.ReadOnly] +#13+
         'File Busy: ' + BOOLARRAY[FileIsBusy] +#13+
         'File format: ' + FILE_FORMAT_NAMES[NoteFile.FileFormat] + #13#13+
         'FolderMon active: ' + BOOLARRAY[FolderMon.Active] +#13+
         'FolderMon folder: ' + FolderMon.FolderName + #13#13 +
         'IS_OLD_FILE_FMT: ' + BOOLARRAY[_IS_OLD_KEYNOTE_FILE_FORMAT] +#13+
         'USE_OLD_FILE_FMT: ' + BOOLARRAY[_USE_OLD_KEYNOTE_FILE_FORMAT] +#13#13;

    if NoteFile.FileFormat = nffEncrypted then
      s := s + 'Encrypted with: ' + CRYPT_METHOD_NAMES[NoteFile.CryptMethod] + #13 +
               'Pass: ' + NoteFile.PassPhrase +#13#13;

    if assigned( ActiveNote ) then begin
      s := s +
         'Active note name: ' + ActiveNote.Name +#13+
         'Active note kind: ' + TABNOTE_KIND_NAMES[ActiveNote.Kind] +#13;

      if ( ActiveNote.Kind = ntTree ) then begin
        s := s + 'Number of Tree nodes: ' + inttostr( TTreeNote( ActiveNote ).TV.Items.Count ) + #13 +
          'Number of Note nodes: ' + inttostr( TTreeNote( ActiveNote ).NodeCount ) + #13;
        if assigned( TTreeNote( ActiveNote ).SelectedNode ) then
          s := s + 'Selected node: ' + TTreeNote( ActiveNote ).SelectedNode.Name +#13;
      end;
    end
    else
      s := s + 'ActiveNote NOT assigned' + #13;

    if ( _OTHER_INSTANCE_HANDLE <> 0 ) then
      s := s + 'Found other instance!' + #13;

  end
  else
     s := 'No notes.' + #13;


  if assigned( FileManager ) then
    s := s + #13 + 'File Manager count: ' + inttostr( FileManager.Count )
  else
    s := s + 'File Manager NOT assigned.';

{$IFDEF KNT_DEBUG}
  s := s + #13 + '(Log enabled)';
{$ENDIF}

  if DoMessageBox( s, mtInformation, [mbOK,mbCancel], 0 ) = mrCancel then exit;

end; // DEBUG MENU CLICK


procedure TForm_Main.ShowAbout;
var
  AboutBox : TAboutBox;
begin
  AboutBox := TAboutBox.Create( self );
  try
    AboutBox.ShowModal;
  finally
    AboutBox.Free;
  end;
end; // ShowAbout

procedure TForm_Main.MMToolsOptionsClick(Sender: TObject);
begin
  AdjustOptions;
end;

procedure TForm_Main.MMHelpChkUpdClick(Sender: TObject);
begin
    CheckForUpdate (false);
end;

procedure TForm_Main.MMHelpAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TForm_Main.MMViewOnTopClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    AlwaysOnTop := ( not AlwaysOnTop );
    WinOnTop.AlwaysOnTop := AlwaysOnTop;
    MMViewOnTop.Checked := AlwaysOnTop;
    TB_OnTop.Down := MMViewOnTop.Checked;
  end;
end; // MMViewOnTopClick

procedure TForm_Main.MMViewTBMainClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    ToolbarMainShow := ( not ToolbarMainShow );
    Toolbar_Main.Visible := ToolbarMainShow;
    MMViewTBMain.Checked := ToolbarMainShow;
  end;
end;

procedure TForm_Main.MMViewTBInsertClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    ToolbarInsertShow := ( not ToolbarInsertShow );
    Toolbar_Insert.Visible := ToolbarInsertShow;
    MMViewTBInsert.Checked := ToolbarInsertShow;
  end;
end;

procedure TForm_Main.MMViewTBFormatClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    ToolbarFormatShow := ( not ToolbarFormatShow );
    Toolbar_Format.Visible := ToolbarFormatShow;
    MMViewTBFormat.Checked := ToolbarFormatShow;
  end;
end;

procedure TForm_Main.MMViewTBStyleClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    ToolbarStyleShow := ( not ToolbarStyleShow );
    Toolbar_Style.Visible := ToolbarStyleShow;
    MMViewTBStyle.Checked := ToolbarStyleShow;
  end;
end;


procedure TForm_Main.MMViewTBTreeClick(Sender: TObject);
begin
  with KeyOptions do
  begin
    ToolbarTreeShow := ( not ToolbarTreeShow );
    Toolbar_Tree.Visible := ( ToolbarTreeShow and assigned( ActiveNote ) and ( ActiveNote.Kind = ntTree ));
    MMViewTBTree.Checked := ToolbarTreeShow;
  end;
end;

procedure TForm_Main.MMFileManagerClick(Sender: TObject);
begin
  RunFileManager;
end; // MMFileManagerClick

procedure TForm_Main.MMInsertDateClick(Sender: TObject);
begin
  if ShiftDown and ( sender is TToolbarButton97 ) then
  begin
    if LoadDateFormatsList then
      messagedlg( Format( STR_19, [DATE_FORMAT_LIST.Count] ), mtInformation, [mbOK], 0 )
    else
      messagedlg( Format( STR_20, [_DateFormatsFile] ), mtError, [mbOK], 0 );
  end
  else
    PerformCmd( ecInsDate );
end;

procedure TForm_Main.MMInsertTimeClick(Sender: TObject);
begin
  if ShiftDown and ( sender is TTOolbarButton97 ) then
  begin
    if LoadTimeFormatsList then
      messagedlg( Format( STR_21, [TIME_FORMAT_LIST.Count] ), mtInformation, [mbOK], 0 )
    else
      messagedlg( Format( STR_22, [_TimeFormatsFile] ), mtError, [mbOK], 0 );
  end
  else
    PerformCmd( ecInsTime );
end;

procedure TForm_Main.MMNoteRemoveClick(Sender: TObject);
begin
  DeleteNote;
end;

procedure TForm_Main.MMFileCopyToClick(Sender: TObject);
var
  SavedNotes, SavedNodes: integer;
begin
  NoteFileCopy (SavedNotes, SavedNodes);
end;

procedure TForm_Main.MMFindGoToClick(Sender: TObject);
begin
  PerformCmdEx( ecGoTo );
end;

procedure TForm_Main.MMFormatDisabledClick(Sender: TObject);
begin
  PerformCmd( ecDisabled );
end;

procedure TForm_Main.MMFormatSubscriptClick(Sender: TObject);
begin
  PerformCmd( ecSubscript );
end;

procedure TForm_Main.MMFormatSuperscriptClick(Sender: TObject);
begin
  PerformCmd( ecSuperscript );
end;

procedure TForm_Main.MMFormatSpBefIncClick(Sender: TObject);
begin
  PerformCmd( ecSpaceBeforeInc );
end;

procedure TForm_Main.MMFormatSpBefDecClick(Sender: TObject);
begin
  PerformCmd( ecSpaceBeforeDec );
end;

procedure TForm_Main.MMFormatSpAftIncClick(Sender: TObject);
begin
  PerformCmd( ecSpaceAfterInc );
end;

procedure TForm_Main.MMFormatSpAftDecClick(Sender: TObject);
begin
  PerformCmd( ecSpaceAfterDec );
end;


procedure TForm_Main.MMToolsImportClick(Sender: TObject);
begin
  ImportFiles;
end;

procedure TForm_Main.MMToolsDefaultsClick(Sender: TObject);
begin
  EditNoteProperties( propDefaults );
end;

procedure TForm_Main.MMNotePropertiesClick(Sender: TObject);
begin
  // EditNote;
  EditNoteProperties( propThisNote );
end;

procedure TForm_Main.TB_ExitClick(Sender: TObject);
begin
  Close; // No "TerminateClick"!
end;

procedure TForm_Main.TB_FilterTreeClick(Sender: TObject);
var
   note: TTreeNote;
begin
    if not assigned (ActiveNote) then exit;

    note:= TTreeNote(ActiveNote);
    if not note.Filtered then begin
        ShowFindAllOptions;
        CB_ResFind_Filter.Checked:= true;
        TB_FilterTree.Down:= false;
    end
    else begin
        note:= TTreeNote(ActiveNote);
        RemoveFilter (note);
        FilterRemoved (note);
    end;
end;

procedure TForm_Main.FilterApplied (note: TTreeNote);   // [dpv]
begin
    note.Filtered:= true;
    if note = ActiveNote then begin
      TB_FilterTree.Down:= true;
      MMViewFilterTree.Checked:= true;
      TB_FilterTree.Hint:= STR_23;
    end;
end;
procedure TForm_Main.FilterRemoved (note: TTreeNote);   // [dpv]
begin
    note.Filtered:= false;
    if note = ActiveNote then begin
      TB_FilterTree.Down:= false;
      MMViewFilterTree.Checked:= false;
      TB_FilterTree.Hint:= STR_24;
    end;
end;

procedure TForm_Main.MMSortClick(Sender: TObject);
begin
  PerformCmd( ecSort );
end;

procedure TForm_Main.MMFormatCopyClick(Sender: TObject);
begin
  FormatCopyClick(False);
end;

procedure TForm_Main.TB_CopyFormatClick(Sender: TObject);
begin
  FormatCopyClick(True);
end;

procedure TForm_Main.FormatCopyClick(AlloMultiMode: Boolean);
begin
  if not assigned( NoteFile ) then exit;

  if CopyFormatMode= cfDisabled then begin
     if AlloMultiMode and (GetKeyState(VK_CONTROL) < 0) then
        CopyFormatMode:= cfEnabledMulti
     else
        CopyFormatMode:= cfEnabled;

     EnableCopyFormat(True);
     PerformCmdEx(ecCopyFormat)
  end
  else
     EnableCopyFormat(False);
end;


procedure TForm_Main.MMFormatCopyFontClick(Sender: TObject);
begin
  PerformCmdEx( ecFontFormatCopy );
end;

procedure TForm_Main.MMFormatPasteFontClick(Sender: TObject);
begin
  PerformCmd( ecFontFormatPaste );
end;

procedure TForm_Main.MMFormatCopyParaClick(Sender: TObject);
begin
  PerformCmdEx( ecParaFormatCopy );
end;

procedure TForm_Main.MMFormatPasteParaClick(Sender: TObject);
begin
  PerformCmd( ecParaFormatPaste );
end;

procedure TForm_Main.MMFindClick(Sender: TObject);
begin
  if assigned(ActiveNote) and ( ActiveNote.FocusMemory = focTree ) then
     MMFindNodeClick(nil)
  else
     RunFinder;
end;

procedure TForm_Main.MMFindNextClick(Sender: TObject);
begin
  if assigned(ActiveNote) and ( ActiveNote.FocusMemory = focTree ) then
     MMFindNodeNextClick(nil)
  else
     DoFindNext;
end; // MMFindagainClick

procedure TForm_Main.MMFindReplaceClick(Sender: TObject);
begin
  RunReplace;
end; // MMReplaceClick

procedure TForm_Main.MMFindReplaceNextClick(Sender: TObject);
begin
  if ( FindOptions.Pattern = '' ) then
    RunReplace
  else
    RunReplaceNext;
end; // MMReplaceNextClick

procedure TForm_Main.MMFindAllClick(Sender: TObject);
begin
   ShowFindAllOptions;
end;


function TForm_Main.HaveNotes( const Warn, CheckCount : boolean ) : boolean;
var
  msg : string;
begin
  result := true;
  msg := '';
  if ( not assigned( NoteFile )) then
  begin
    result := false;
    if Warn then
      msg := STR_25;
  end
  else
  begin
    if ( CheckCount and (( NoteFile.Notes.Count < 1 ) or ( Pages.PageCount < 1 ))) then
    begin
      result := false;
      if Warn then
        msg := STR_26;
    end;
  end;

  if (( not result ) and Warn ) then
    PopupMessage( msg, mtInformation, [mbOK], 0 );

end; // HaveNotes

function TForm_Main.NoteIsReadOnly( const aNote : TTabNote; const Warn : boolean ) : boolean;
begin
  result := assigned( ANote ) and ANote.ReadOnly;
  if ( result and Warn ) then
    StatusBar.Panels[PANEL_HINT].Text := STR_27;
end; // NoteIsReadOnly

(*  Not used. Referenced by kn_Main.GetKeyStates, not used
procedure TForm_Main.GetKeyStates;
var
  i : TLockKeys;
begin
  for i := low( TLockKeys ) to high( TLockKeys ) do
    if ( odd( GetKeyState( lock_Keys[i] )) <> lock_states[i] ) then
    begin
      lock_states[i] := ( not lock_states[i] );
      StatusBar.Panels[lock_panels[i]].Enabled := lock_states[i];
    end;
end; // GetKeyStates
*)

procedure TForm_Main.ShiftTab( const ShiftRight : boolean );
var
  i, idx : integer;
begin
  if ( Pages.PageCount < 2 ) then exit;
  idx := Pages.ActivePage.ImageIndex;
  i := Pages.ActivePage.PageIndex;
  case ShiftRight of
    true : if ( i >= pred( Pages.PageCount )) then
      i := 0
    else
      inc( i );
    false : if ( i < 1 ) then
      i := pred( Pages.PageCount )
    else
      dec( i );
  end;

  Pages.ActivePage.PageIndex := i;
  Pages.ActivePage.ImageIndex := idx;
  NoteFile.Modified := true;
  UpdateNoteFileState( [fscModified] );

end; // ShiftTab

procedure TForm_Main.MMViewShiftTabLeftClick(Sender: TObject);
begin
  ShiftTab( false );
end;

procedure TForm_Main.MMViewShiftTabRightClick(Sender: TObject);
begin
  ShiftTab( true );
end;


procedure TForm_Main.MMFormatFontSizeDecClick(Sender: TObject);
begin
  PerformCmd( ecFontSizeDec );
end;

procedure TForm_Main.MMFormatFontSizeIncClick(Sender: TObject);
begin
  PerformCmd( ecFontSizeInc );
end;

procedure TForm_Main.OnNoteLoaded( sender : TObject );
begin
  Application.ProcessMessages;
end; // OnNoteLoaded

procedure TForm_Main.MMEditJoinClick(Sender: TObject);
begin
  PerformCmd( ecJoinLines );
end;

procedure TForm_Main.MMEditUpperClick(Sender: TObject);
begin
  PerformCmd( ecToUpperCase );
end;

procedure TForm_Main.MMEditLowerClick(Sender: TObject);
begin
  PerformCmd( ecToLowerCase );
end;

procedure TForm_Main.MMEditMixedClick(Sender: TObject);
begin
  PerformCmd( ecToMixedCase );
end;

procedure TForm_Main.MMEditCycleCaseClick(Sender: TObject);
begin
  PerformCmd( ecCycleCase );
end;

procedure TForm_Main.MMEditDelLineClick(Sender: TObject);
begin
  PerformCmd( ecDeleteLine )
end;

procedure TForm_Main.FolderMonChange(Sender: TObject);
begin
  FolderChanged;
end; // FOLDERMON CHANGE

procedure TForm_Main.MMNotePrintClick(Sender: TObject);
begin
  PrintRTFNote;
end;

procedure TForm_Main.WMChangeCBChain(var Msg: TWMChangeCBChain);
begin
  if Msg.Remove = ClipCapNextInChain then
    ClipCapNextInChain := Msg.Next
  else
    SendMessage( ClipCapNextInChain, WM_CHANGECBCHAIN, Msg.Remove, Msg.Next );
  Msg.Result := 0;
end; // WMChangeCBChain

procedure TForm_Main.WMDrawClipboard(var Msg: TWMDrawClipboard);
var
  ClpStr : string;

begin
  SendMessage( ClipCapNextInChain, WM_DRAWCLIPBOARD, 0, 0 );
  Msg.Result := 0;

  if ( _IS_CAPTURING_CLIPBOARD or _IS_CHAINING_CLIPBOARD ) then exit;

  {*1 We need to calc CRC32 even if ClipOptions.TestDupClips=False, because it will be used for several other things,
     but here, depending on that configuration (TestDupClips="Ignore duplicate clips") we will consider or not to paste the text }

  {*2 We must register LogRTFHandleInClipboard, since the ecCut or ecCopy operations have been interrupted just after sending content to the
     clipboard, before we can register the handle that we are using to identify if the Clipboard contains content copied by the application itself }


  _IS_CAPTURING_CLIPBOARD:= True;
  try
   try
      if _IS_COPYING_TO_CLIPBOARD then        // *2
         LogRTFHandleInClipboard();

      if ( ClipCapActive and assigned( NoteFile ) and ( NoteFile.ClipCapNote <> nil )) then begin
         if (( GetActiveWindow <> self.Handle ) or // only when inactive
            (( not ClipOptions.IgnoreSelf ) and // explicitly configured to capture from self...
            ( not ( NoteFile.ClipCapNote = ActiveNote )))) then begin // but never capture text copied from the note that is being used for capture
               ClpStr := Clipboard.TryAsText;
               if ((ClpStr <> '') or not NoteFile.ClipCapNote.PlainText ) and (not TestCRCForDuplicates(ClpStr) or (not ClipOptions.TestDupClips)) then     // *1
                  PasteOnClipCap(ClpStr);
         end;
      end;

   except
     On E : Exception do
        //Log_StoreTick( 'WMDrawClipboard- Exception: '+ E.Message, 1);
   end;

  finally
     _IS_CAPTURING_CLIPBOARD:= False;
  end;
end; // WMDrawClipboard

procedure TForm_Main.MMNoteClipCaptureClick(Sender: TObject);
begin
  TB_ClipCap.Down := ( not TB_ClipCap.Down );
  ToggleClipCap( TB_ClipCap.Down, ActiveNote );
end;

procedure TForm_Main.MMFilePageSetupClick(Sender: TObject);
begin
  if ( not assigned( RichPrinter )) then    // [dpv]
  begin
      try                                     // [DPV]
         RichPrinter := TRichPrinter.Create(Form_Main);
      except
        On E : Exception do
        begin
          showmessage( E.Message );
          exit;
        end;
      end;
  end;

   try                                     // [DPV]
      RichPrinter.PageDialog;
    // PageSetupDlg.Execute;
   except
      On E : Exception do
      begin
        showmessage( E.Message );
      end;
   end;

end;

procedure TForm_Main.RichPrinterBeginDoc(Sender: TObject);
begin
  StatusBar.Panels[PANEL_HINT].Text := STR_29;
end;

procedure TForm_Main.RichPrinterEndDoc(Sender: TObject);
begin
  StatusBar.Panels[PANEL_HINT].Text := STR_30;
end;

procedure TForm_Main.MMNotePrintPreview_Click(Sender: TObject);
begin
  if ( not HaveNotes( true, true )) then exit;
  if ( not assigned( ActiveNote )) then exit;

  if ( not assigned( RichPrinter )) then    // [dpv]
  begin
      try                                     // [DPV]
         Form_Main.RichPrinter := TRichPrinter.Create(Form_Main);
      except
        On E : Exception do
        begin
          showmessage( E.Message );
          exit;
        end;
      end;
  end;

  RichPrinter.PrintRichEditPreview( TCustomRichEdit( ActiveNote.Editor ));
end; // MMPrintpreviewClick

procedure TForm_Main.MMEditCopyAllClick(Sender: TObject);
begin
  PerformCmd( ecSelectAll );
  PerformCmdEx( ecCopy );
end;

procedure TForm_Main.MMEditPasteAsNewNoteClick(Sender: TObject);
begin
  PasteIntoNew( true );
end;

procedure TForm_Main.MMEditPasteAsNewNodeClick(Sender: TObject);
begin
  PasteIntoNew( false );
end;

procedure TForm_Main.MMEditRot13Click(Sender: TObject);
begin
  PerformCmd( ecROT13 );
end;

procedure TForm_Main.MMNoteEmailClick(Sender: TObject);
{$IFNDEF EXCLUDEEMAIL}
var
  Form_Mail : TForm_Mail;
{$ENDIF}
begin
{$IFNDEF EXCLUDEEMAIL}
  if ( not HaveNotes( true, true )) then exit;
  if ( not assigned( ActiveNote )) then exit;

  StatusBar.Panels[PANEL_HINT].Text := STR_31;
  Form_Mail := TForm_Mail.Create( self );
  try
    with Form_Mail do
    begin
      ShowHint := KeyOptions.ShowTooltips;
      myActiveNote := ActiveNote;
      myNotes := NoteFile;
      myINI_FN := MailINI_FN;
    end;
    case Form_Mail.ShowModal of
      mrOK : StatusBar.Panels[PANEL_HINT].Text := STR_32;
      else
        StatusBar.Panels[PANEL_HINT].Text := STR_33;
    end;
  finally
    Application.OnException := ShowException;
    Form_Mail.Free;
  end;
{$ENDIF}
end; // MMEmailnoteClick


procedure TForm_Main.ShowAlarmStatus;
var
   HasNoteAlarms, HasNodeAlarms: Boolean;
   myNode: TNoteNode;

begin
  HasNodeAlarms:= false;
  HasNoteAlarms:= false;

  if assigned(ActiveNote) then begin
     myNode:= ActiveNote.GetSelectedNode;
     if assigned(myNode) then begin
        HasNodeAlarms:= myNode.HasAlarms(false);
        TVAlarmNode.Checked:= HasNodeAlarms;
     end;
     HasNoteAlarms:= ActiveNote.HasAlarms(false);
  end;

  TB_SetAlarm.Down:= HasNoteAlarms or HasNodeAlarms;
  MMSetAlarm.Checked:= HasNoteAlarms or HasNodeAlarms;
end;

procedure TForm_Main.TB_AlarmModeClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then begin
     if assigned(ActiveNote) then begin
         TB_AlarmMode.Down:= not KeyOptions.DisableAlarmPopup;
         AlarmManager.ShowAlarms(true);
         ShowAlarmStatus;
     end;
  end
  else
      MMAlarmsPopupClick (nil);
end;

procedure TForm_Main.MMAlarmsPopupClick(Sender: TObject);
begin
   KeyOptions.DisableAlarmPopup:= not KeyOptions.DisableAlarmPopup;
   MMAlarmsPopup.Checked:= not KeyOptions.DisableAlarmPopup;
   TB_AlarmMode.Down:= (not KeyOptions.DisableAlarmPopup);
   TB_AlarmMode.Hint:= AlarmManager.GetAlarmModeHint;
end;


procedure TForm_Main.MMShowAlarmsClick(Sender: TObject);
begin
   if assigned(ActiveNote) then begin
      AlarmManager.ShowAlarms(false);
      ShowAlarmStatus;
   end;
end;


procedure TForm_Main.TB_AlarmModeMouseEnter(Sender: TObject);
begin
    AlarmManager.StopFlashMode;
end;


procedure TForm_Main.TB_SetAlarmClick(Sender: TObject);      // [dpv*]
begin
   SetAlarm (True);
end;

procedure TForm_Main.SetAlarm(ConsiderNoteAlarm: Boolean);      // [dpv*]
var
    myNode: TNoteNode;
    HasNoteAlarms, HasNodeAlarms: Boolean;

begin
   if not assigned( NoteFile ) or (not assigned(ActiveNote)) then exit;

   HasNoteAlarms:= ActiveNote.HasAlarms(false);
   HasNodeAlarms:= false;
   myNode:= ActiveNote.GetSelectedNode;
   if myNode <> nil then
      HasNodeAlarms:= myNode.HasAlarms(false);

   if ConsiderNoteAlarm and (ShiftDown or (HasNoteAlarms and not HasNodeAlarms)) then
      myNode:= nil;

   AlarmManager.EditAlarms (myNode, ActiveNote, (GetKeyState(VK_CONTROL) < 0));
   ShowAlarmStatus;
end;


procedure TForm_Main.TB_SetAlarmMouseEnter(Sender: TObject);    // [dpv*]
var
    myNode: TNoteNode;
    hint: string;
    sep: String;
    I, N: integer;
    Alarms: TList;

    procedure AddAlarmsToHint;
    begin
        I:= 0;
        while I <= Alarms.Count - 1 do begin
           hint:= hint + sep + FormatAlarmInstant(TAlarm(Alarms[i]).ExpirationDate) + ' [' + StringReplace(TAlarm(Alarms[i]).AlarmNote, #13#10, '. ', [rfReplaceAll]) + ']';
           sep:= ' // ';
           inc(I);
           inc(N);
        end;
    end;

begin
    if not assigned(ActiveNote) then exit;

    sep:= '';
    hint:= '';
    N:= 0;
    myNode:= ActiveNote.GetSelectedNode;

    if assigned(myNode) and myNode.HasAlarms(false) then begin
       Alarms:= myNode.getAlarms(false);
       AddAlarmsToHint;
    end;
    if ActiveNote.HasAlarms(false) and ActiveNote.HasAlarms(false) then begin
       Alarms:= ActiveNote.getAlarms(false);
       AddAlarmsToHint;
    end;

    if hint = '' then
       hint:= STR_35
    else
       hint:= '(' + N.ToString + ') ' + hint;


    TB_SetAlarm.Hint:= hint;
end;

procedure TForm_Main.TB_ClipCapClick(Sender: TObject);
begin
  ToggleClipCap( TB_ClipCap.Down, ActiveNote );
end;

procedure TForm_Main.MMViewAlphaTabsClick(Sender: TObject);
begin
  SortTabs;
end;


procedure TForm_Main.MMViewTabIconsClick(Sender: TObject);
begin
  TabOptions.Images := ( not TabOptions.Images );
  MMViewTabIcons.Checked := TabOptions.Images;
  if TabOptions.Images then
    Pages.Images := Chest.IMG_Categories
  else
    Pages.Images := nil;
end; // MMViewTabIconsClick


procedure TForm_Main.TVChange(Sender: TObject; Node: TTreeNTNode);
begin
  if ( Node <> _LAST_NODE_SELECTED ) then
  begin
    try
      TreeNodeSelected( Node );
    finally
      _LAST_NODE_SELECTED := Node;
    end;
  end;
end; // TVChange

procedure TForm_Main.OnFileDropped( Sender : TObject; FileList : TStringList );
begin
      FileDropped( Sender, FileList );
end;


procedure TForm_Main.WMDropFiles(var Msg: TWMDropFiles);
var
  FileList : TStringList;
begin
  FileList := GetDropFiles(Msg.Drop);
  try
    FileDropped( self, FileList );

  finally
    FileList.Free;
  end;

end; // WMDropFiles


procedure TForm_Main.CreateWnd;
begin
  inherited;
  DragAcceptFiles( handle, true );
end; // CreateWnd

procedure TForm_Main.DestroyWnd;
begin
  DragAcceptFiles( handle, false );
  inherited;
end; // DestroyWnd

procedure TForm_Main.TVDeletion(Sender: TObject; Node: TTreeNTNode);
var
   myTNote : TTreeNote;
   myNode: TNoteNode;
begin
  if not assigned( Node ) then exit;

  myTNote:= TTreeNote(NoteFile.GetNoteByTreeNode(Node));
  if assigned( myTNote ) then begin
    myNode:= TNoteNode( Node.Data );

     if NoteFile.FileName <> '<DESTROYING>' then          // FileName='<DESTROYING>'=> is closing. All nodes will be deleted all the way
        NoteFile.ManageMirrorNodes(3, Node, nil);

    myTNote.RemoveNode( myNode);

  end;
end;

procedure TForm_Main.SplitterNoteMoved(Sender: TObject);
var
  myNote: TTreeNote;
  Width: integer;
begin
   myNote:= TTreeNote(ActiveNote);
   if myNote.VerticalLayout then
      Width := myNote.TV.Height
   else
      Width := myNote.TV.Width;

   TSplitter(Sender).Color:= clBtnFace;

   if AltDown then begin
      myNote.TreeMaxWidth:= -myNote.TreeMaxWidth;        // Toggle width fixed
      if myNote.TreeMaxWidth < 0 then
         TSplitter(Sender).Color:= clSkyBlue;
      exit;
   end;

   if CtrlDown then begin
      if Width = Abs(myNote.TreeWidth)  then
         Width:= 0;
      myNote.TreeMaxWidth:= Width;
   end
   else begin
      myNote.TreeWidth:= Width;
      myNote.TreeMaxWidth:= Abs(myNote.TreeMaxWidth);
   end;

   if KeyOptions.ModifiedOnTreeResized then begin
      myNote.Modified := true;
      NoteFile.Modified := true;
      UpdateNoteFileState( [fscModified] );
   end;
end;


procedure TForm_Main.TVOnHint(Sender: TObject; Node: TTreeNTNode;
  var NewText: string);
begin
   CheckExpandTreeWidth;
end;

procedure TForm_Main.CheckExpandTreeWidth;
var
  myNote: TTreeNote;
  Width: integer;
begin
   if (ActiveNote.Kind = ntTree) then begin
      myNote:= TTreeNote(ActiveNote);
      if myNote.VerticalLayout then
         Width := myNote.TV.Height
      else
         Width := myNote.TV.Width;

      if (myNote.TreeMaxWidth > 0) and (myNote.TreeMaxWidth > Width) then
         if myNote.VerticalLayout then
            myNote.TV.Height:= myNote.TreeMaxWidth
         else
            myNote.TV.Width:= myNote.TreeMaxWidth;
   end;
end;

procedure TForm_Main.CheckRestoreTreeWidth;
var
   Width: integer;
   myNote: TTreeNote;
begin
   if (ActiveNote.Kind = ntTree) then begin
       myNote:= TTreeNote(ActiveNote);

       if (myNote.TreeMaxWidth > 0) and (myNote.TV.Visible) and (not myNote.TV.Focused) then begin
          if myNote.VerticalLayout then
             Width := myNote.TV.Height
          else
             Width := myNote.TV.Width;

          if (Width > TTreeNote(ActiveNote).TreeWidth) then begin
              if myNote.VerticalLayout then
                 myNote.TV.Height:= myNote.TreeWidth
              else
                 myNote.TV.Width:= myNote.TreeWidth;
          end;
       end;
   end;

end;

procedure TForm_Main.RxRTFEnter(Sender: TObject);
begin
   CheckRestoreTreeWidth;
end;

procedure TForm_Main.TVEnter(Sender: TObject);
begin
   CheckExpandTreeWidth;
end;



procedure TForm_Main.TVClick(Sender: TObject);
begin
 // ( sender as TTreeNT ).PopupMenu := Menu_TV;
 if assigned( ActiveNote ) then ActiveNote.FocusMemory := focTree;
end;

procedure TForm_Main.TVDblClick(Sender: TObject);
begin
  // MMRenamenodeClick( Sender );
end;

procedure TForm_Main.TVStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  // StatusBar.Panels[PANEL_HINT].Text := 'Drag: ' + DragObject.GetName;
  DraggedTreeNode := TTreeNote( ActiveNote ).TV.Selected;
  if assigned( DraggedTreeNode ) then
  begin
     // {N}
    StatusBar.Panels[PANEL_HINT].Text := STR_36 + DraggedTreeNode.Text;
  end;
end; // TVStartDrag


procedure TForm_Main.TVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  ThisNode : TTreeNTNode;
begin

  StatusBar.Panels[0].Text := STR_37;

  if (( source is TRxRichEdit )) then
  begin
    accept := true;

  end;

  accept := false;
  if (( not assigned( DraggedTreeNode )) or ( sender <> source )) then
    exit;

  ThisNode := ( sender as TTreeNT ).GetNodeAt( X, Y );
  if ( not ( assigned( ThisNode ) and ( ThisNode <> DraggedTreeNode ))) then
    exit;

  Accept := true;

end; // TVDragOver

function IsAParentOf( aPerhapsParent, aChild : TTreeNTNode ) : boolean;
var
  i, leveldifference : integer;
begin
  result := false;
  if ( not ( assigned( aPerhapsParent ) and assigned( aChild ))) then exit;

  leveldifference := aChild.Level - aPerhapsParent.Level;
  if ( leveldifference < 1 ) then exit; // cannot be a parent if its level is same or greater than "child's"

  for i := 1 to leveldifference do
  begin
    aChild := aChild.Parent;
    if assigned( aChild ) then
    begin
      if ( aChild = aPerhapsParent ) then
      begin
        result := true;
        break;
      end;
    end
    else
    begin
      break; // result = false
    end;
  end;
end; // IsAParentOf

procedure TForm_Main.TVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  DropTreeNode, PreviousParent : TTreeNTNode;
  s : string;
  myTNote : TTreeNote;
begin
  if NoteIsReadOnly( ActiveNote, true ) then
  begin
    DraggedTreeNode := nil;
    if ( Sender is TTreeNT ) then
      ( sender as TTreeNT ).EndDrag( false );
    exit;
  end;

  s := STR_38_Dragged;
  DropTreeNode := ( sender as TTreeNT ).GetNodeAt( X, Y );

  myTNote := TTreeNote( ActiveNote );

  try

    if assigned( DraggedTreeNode ) and assigned( DropTreeNode ) then
    begin

      // check if we can drop DraggedTreeNode onto DropNode
      // 1. Cannot drop node on itself
      if ( DropTreeNode = DraggedTreeNode ) then
      begin
        // {N}
        s := Format( STR_39, [DraggedTreeNode.Text] );
        exit;
      end;
      // 2. Cannot drop between treeviews
      if ( DropTreeNode.TreeView <> DraggedTreeNode.TreeView ) then
      begin
        // {N}
        s := Format( STR_41, [DraggedTreeNode.Text] );
        exit;
      end;
      // 3. Cannot drop a node onto its own child
      if IsAParentOf( DraggedTreeNode, DropTreeNode ) then
      begin
        // {N}
        s := Format( STR_42, [DraggedTreeNode.Text, DropTreeNode.Text] );
        exit;
      end;

      // now figure out where to move the node
      // 1. If dropping on immediate parent, then
      //    make node first child of parent
      // 2. If dropping on any other node, then
      //    make node LAST child of that node,
      //    unless SHIFT is down, in which case
      //    make node FIRST child of that node

      myTNote.TV.OnChange := nil; // stop event
      PreviousParent := DraggedTreeNode.Parent;

      myTNote.TV.OnChecked := nil;

      if (( DropTreeNode.Level = 0 ) and CtrlDown ) then
      begin
        // make TOP node
        DraggedTreeNode.MoveTo( nil, naAddFirst );
        // {N}
        s := Format( STR_43, [DraggedTreeNode.Text] );
      end
      else
      if ( DraggedTreeNode.Parent = DropTreeNode ) then
      begin
        if ShiftDown then
        begin
          DraggedTreeNode.MoveTo( DropTreeNode, naInsert );
          // {N}
          s := Format( STR_44, [DraggedTreeNode.Text] );
        end
        else
        begin
          DraggedTreeNode.MoveTo( DropTreeNode, naAddChildFirst );
          // {N}
          s := Format( STR_45, [DraggedTreeNode.Text] );
        end;
      end
      else
      begin
        if ShiftDown then
        begin
          DraggedTreeNode.MoveTo( DropTreeNode, naInsert );
          // {N}
          s := Format( STR_46, [DraggedTreeNode.Text, DropTreeNode.Text] );
        end
        else
        begin
          DraggedTreeNode.MoveTo( DropTreeNode, naAddChildFirst );
          // {N}
          s := Format( STR_47, [DraggedTreeNode.Text, DropTreeNode.Text] );
        end;
      end;

      // update node icon
      SelectIconForNode( DraggedTreeNode, myTNote.IconKind );
      SelectIconForNode( DraggedTreeNode.Parent, myTNote.IconKind );
      SelectIconForNode( PreviousParent, myTNote.IconKind );
      myTNote.TV.Invalidate;

    end
    else
    begin
      s := STR_48;
      DraggedTreeNode := nil;
      if ( Sender is TTreeNT ) then
        ( sender as TTreeNT ).EndDrag( false );
    end;

  finally
    NoteFile.Modified := true;
    if TNoteNode(DraggedTreeNode.Data).Checked then begin
       DraggedTreeNode.CheckState := csChecked;
    end;
    myTNote.TV.OnChange := TVChange;
    myTNote.TV.OnChecked:= Form_Main.TVChecked;
    UpdateNoteFileState( [fscModified] );
    StatusBar.Panels[PANEL_HINT].Text := s;
  end;

end; // TVDragDrop

procedure TForm_Main.TVEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  // StatusBar.Panels[PANEL_HINT].Text := 'End drag';
  DraggedTreeNode := nil;
end;

procedure TForm_Main.TVVirtualNodeClick(Sender: TObject);
begin
  VirtualNodeProc( vmNone, nil, '' );
end; // TVMVirtualNodeClick

procedure TForm_Main.TVRefreshVirtualNodeClick(Sender: TObject);
begin
  VirtualNodeRefresh( TreeOptions.ConfirmNodeRefresh );
end;


procedure TForm_Main.TVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ptCursor : TPoint;
begin
  if ( not ( assigned( activenote ) and ( activenote.kind = ntTree ))) then
    exit;
  if TTreeNote( ActiveNote ).TV.IsEditing then exit;

  ActiveNote.FocusMemory := focTree;

  case key of
    VK_F10 : if ( shift = [ssShift] ) then
    begin
      key := 0;
      GetCursorPos( ptCursor );
      Menu_TV.Popup( ptCursor.X, ptCursor.Y );
    end;

    VK_SPACE : if ( Shift = [] ) then
    begin
      // rename node
      key := 0;
      MMRenamenodeClick( sender );
    end;

    220 : if ( Shift = [ssCtrl] ) then begin // backslash
      Key := 0;
      MMTreeFocusEditorClick (nil);
    end;

  end;

end; // TVKeyDown


procedure TForm_Main.TVKeyPress(Sender: TObject; var Key: Char);
begin
  if ( sender as TTreeNT ).IsEditing then
  begin
    if ( key = KNTLINK_SEPARATOR ) then
      key := #0; // disallow | character in node name, because it breaks KNT links (which use | as delimiter)
  end;
end; // TVKeyPress

procedure TForm_Main.TVAddNodeClick(Sender: TObject);
begin
  AddNodeToTree( tnAddLast );
end; // TVMAddNodeClick

procedure TForm_Main.TVInsertMirrorNodeClick(Sender: TObject);
var
  myTreeNode: TTreeNTNode;
  mirrorNode: TTreeNTNode;
begin
  myTreeNode:= TTreeNote( ActiveNote ).TV.Selected;
  if assigned(myTreeNode) then begin
     AddNodeToTree( tnInsertBefore );
     mirrorNode:= TTreeNote( ActiveNote ).TV.Selected;
     TNoteNode(mirrorNode.Data).Assign( myTreeNode.Data );
     UpdateTreeNode(mirrorNode);
     TNoteNode(mirrorNode.Data).MirrorNode:= myTreeNode;
     SelectIconForNode( mirrorNode, TTreeNote(ActiveNote).IconKind );
     AddMirrorNode(myTreeNode, mirrorNode); 
     ActiveNote.DataStreamToEditor;
  end;
end;

procedure TForm_Main.TVInsertNodeClick(Sender: TObject);
begin
  AddNodeToTree( tnInsertBefore );
end; // TVMInsertNodeClick

procedure TForm_Main.TVAddChildNodeClick(Sender: TObject);
begin
  AddNodeToTree( tnAddChild );
end;

procedure TForm_Main.TVAddSiblingClick(Sender: TObject);
begin
  AddNodeToTree( tnAddAfter );
end;

procedure TForm_Main.TVAlarmNodeClick(Sender: TObject);
begin
   SetAlarm (false);
end;

procedure TForm_Main.TVDeleteNodeClick(Sender: TObject);
begin
  DeleteTreeNode( true );
end;

procedure TForm_Main.TVDeleteChildrenClick(Sender: TObject);
begin
  DeleteTreeNode( false );
end;

procedure TForm_Main.TVMoveNodeUpClick(Sender: TObject);
begin
  MoveTreeNode( nil, dirUp );
end;

procedure TForm_Main.TVMoveNodeDownClick(Sender: TObject);
begin
  MoveTreeNode( nil, dirDown );
end;

procedure TForm_Main.TVMoveNodeLeftClick(Sender: TObject);
begin
  MoveTreeNode( nil, dirLeft );
end;

procedure TForm_Main.TVMoveNodeRightClick(Sender: TObject);
begin
  MoveTreeNode( nil, dirRight );
end;

procedure TForm_Main.TVPasteNodeNameClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
    PasteNodeName( TPasteNodeNameMode(( sender as TMenuItem ).Tag ));
end;



procedure TForm_Main.TVCopyNodeNameClick(Sender: TObject);
begin
  CopyNodeName( ShiftDown );
end;

procedure TForm_Main.MMTreeFullExpandClick(Sender: TObject);
begin
  TTreeNote( ActiveNote ).TV.FullExpand;
  TreeNodeSelected( TTreeNote( ActiveNote ).TV.Selected );
  TTreeNote( ActiveNote ).TV.Selected.MakeVisible;
end;

procedure TForm_Main.MMTreeFocusToogleClick(Sender: TObject);
begin
  if not assigned(ActiveNote) then exit;
  if ActiveNote.Kind <> ntTree then exit;

  try
     if TTreeNote(ActiveNote).TV.Focused then
        MMTreeFocusEditorClick (nil)
     else
        MMTreeFocusTreeClick (nil);

  except
  end;

end;

procedure TForm_Main.MMTreeFocusEditorClick(Sender: TObject);
begin
  if not assigned(ActiveNote) then exit;

  try
     ActiveNote.FocusMemory := focRTF;
     ActiveNote.Editor.SetFocus;
  except
  end;

end;

procedure TForm_Main.MMTreeFocusTreeClick(Sender: TObject);
begin
  if not assigned(ActiveNote) then exit;
  if ActiveNote.Kind <> ntTree then exit;

  try
     if TTreeNote( ActiveNote ).TreeHidden then
        MMViewTreeClick(nil);

     TTreeNote(ActiveNote).TV.SetFocus;
  	 ActiveNote.FocusMemory := focTree;
  except
  end;
end;


procedure TForm_Main.MMTreeFullCollapseClick(Sender: TObject);
begin
  TTreeNote( ActiveNote ).TV.FullCollapse;
  TreeNodeSelected( TTreeNote( ActiveNote ).TV.Selected );
end;

procedure TForm_Main.TVSortSubtreeClick(Sender: TObject);
var
  myTreeNode : TTreeNTNode;
begin
  if ( ActiveNote.FocusMemory <> focTree ) then exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;
  myTreeNode := GetCurrentTreeNode;
  if ( assigned( myTreeNode ) and myTreeNode.HasChildren ) then
  begin
    TTreeNote( ActiveNote ).TV.OnChange := nil;
    try
      myTreeNode.AlphaSort;
    finally
      NoteFile.Modified := true;
      TTreeNote( ActiveNote ).TV.OnChange := TVChange;
      UpdateNoteFileState( [fscModified] );
    end;
  end;
end; // Sort Child Nodes


procedure TForm_Main.TVSortTreeClick(Sender: TObject);
begin
  if NoteIsReadOnly( ActiveNote, true ) then exit;
  if ( assigned( ActiveNote ) and ( activenote.Kind = ntTree )) then
  begin

    if ( messagedlg(
      STR_49,
      mtConfirmation, [mbYes,mbNo], 0 ) <> mrYes ) then exit;

    TTreeNote( ActiveNote ).TV.OnChange := nil;
    try
      TTreeNote( ActiveNote ).TV.AlphaSort;
    finally
      NoteFile.Modified := true;
      TTreeNote( ActiveNote ).TV.OnChange := TVChange;
      UpdateNoteFileState( [fscModified] );
    end;
  end;
end; // Sort full tree



procedure TForm_Main.TVEdited(Sender: TObject; Node: TTreeNTNode;
  var S: string);
begin
  ( sender as TTreeNT ).PopupMenu := Menu_TV;
  S := trim( copy( S, 1, TREENODE_NAME_LENGTH ));
  if ( S = '' ) then
  begin
    StatusBar.Panels[PANEL_HINT].Text := STR_50;
    S := _OLD_NODE_NAME;
    exit;
  end;
  _ALLOW_VCL_UPDATES := false;
  try
    if assigned( TNoteNode( Node.Data )) then
      TNoteNode( Node.Data ).Name := S;  // {N} must add outline numbering, if any
    StatusBar.Panels[PANEL_HINT].Text := STR_51;
    ActiveNote.Modified := true;
  finally
    _ALLOW_VCL_UPDATES := true;
    NoteFile.Modified := true;
    UpdateNoteFileState( [fscModified] );
  end;
end; // TVEdited

procedure TForm_Main.TVEditCanceled(Sender: TObject);
begin
  ( sender as TTreeNT ).PopupMenu := Menu_TV;
end; // TVEditCanceled

procedure TForm_Main.TVEditing(Sender: TObject; Node: TTreeNTNode;
  var AllowEdit: Boolean);
begin
  if (( assigned( ActiveNote )) and ( not ActiveNote.ReadOnly )) then
  begin
    // {N}
    _OLD_NODE_NAME := node.text;
    // stop menu events triggered by shortcut keys:
    ( sender as TTreeNT ).PopupMenu := nil;
  end
  else
  begin
    StatusBar.Panels[PANEL_HINT].Text := STR_52;
    AllowEdit := false;
  end;
end; // TVEditing


procedure TForm_Main.TVSavingTree(Sender: TObject; Node: TTreeNTNode; var S: string);
begin
   if not ShowHiddenMarkers then exit;
   if assigned( TNoteNode( Node.Data )) then
      S:= Format('%s [%d]', [S, TNoteNode(Node.Data).ID]);
end;


procedure TForm_Main.MMRenamenodeClick(Sender: TObject);
var
  myNode : TNoteNode;
  myName : string;
begin
  if NoteIsReadOnly( ActiveNote, true ) then exit;

  myNode := GetCurrentNoteNode;
  if assigned( myNode ) then
  begin
    if ( ActiveNote.FocusMemory <> focTree ) then exit;
    if TreeOptions.EditInPlace then
    begin
      TTreeNote( ActiveNote ).TV.Selected.EditText;
    end
    else
    begin
      myName := myNode.Name;
      _OLD_NODE_NAME := myName;
      if InputQuery( STR_53, STR_54, myName ) then
      begin
        myName := trim( myName );
        if ( myName <> '' ) then
        begin
          myNode.Name := myName;
          // {N}
          TTreeNote( ActiveNote ).TV.Selected.Text := myNode.Name; // TNoteNode does NOT update its treenode's properties!
          ActiveNote.Modified := true;
          UpdateNoteFileState( [fscModified] );
        end
        else
        begin
          messagedlg( STR_55, mtError, [mbOK], 0 );
        end;
      end;
    end;
  end;
end;

// RenameNode


procedure TForm_Main.MMViewNodeIconsClick(Sender: TObject);
var
  tNote : TTreeNote;
  mi : TMenuItem;
begin
  if ( not ( sender is TMenuItem )) then exit;
  mi := ( sender as TMenuItem );
  if ( assigned( ActiveNote ) and ( ActiveNote.Kind = ntTree )) then
  begin
    tNote := TTreeNote( ActiveNote );
    if mi.Checked then
    begin
      tNote.IconKind := niNone;
    end
    else
    begin
      tNote.IconKind := TNodeIconKind( mi.Tag );
    end;
    ShowOrHideIcons( tNote, ( tNote.IconKind <> niNone ));
    NoteFile.Modified := true;
    UpdateNoteFileState( [fscModified] );
  end;
end; // MMViewNodeIconsClick



procedure TForm_Main.MMViewCheckboxesAllNodesClick(Sender: TObject);
var
  tNote : TTreeNote;
begin
  // show or hide checkboxes in active note's tree panel
  if ( assigned( ActiveNote ) and ( ActiveNote.Kind = ntTree )) then
  begin
    tNote := TTreeNote( ActiveNote );
    tNote.Checkboxes := ( not tNote.Checkboxes );
    MMViewCheckboxesAllNodes.Checked := tNote.Checkboxes;
    TVChildrenCheckbox.Enabled := not MMViewCheckboxesAllNodes.Checked;       // [dpv]
    ShowOrHideCheckBoxes( tNote );
  end;
end;



procedure TForm_Main.TVChecked(Sender: TObject; Node: TTreeNTNode);
var
  myNode : TNoteNode;

begin
  if ( assigned( node ) and assigned( node.Data )) then  begin
      ChangeCheckedState(TTreeNT(Node.TreeView), Node, Node.CheckState = csChecked, false);
  end;
end; // TVChecked

procedure TForm_Main.TVChecking(Sender: TObject; Node: TTreeNTNode;
  var AllowCheck: Boolean);
begin
  AllowCheck := ( not NoteIsReadOnly( ActiveNote, false ));
end;

procedure TForm_Main.MMToolsMergeClick(Sender: TObject);
begin
  MergeFromKNTFile( '' );
end;

procedure TForm_Main.MMMergeNotestoFileClick(Sender: TObject);
begin
  // MergeToKNTFile;
end;

procedure TForm_Main.RTFMRestoreProportionsClick(Sender: TObject);
begin
   ActiveNote.ReconsiderImageDimensionGoalsOnEditor (true);
end;

procedure TForm_Main.RTFMWordWebClick(Sender: TObject);
begin
  WordWebLookup;
end;

procedure TForm_Main.MMHelp_WhatisClick(Sender: TObject);
begin
  Perform( WM_SYSCOMMAND, SC_CONTEXTHELP, 0 );
end;

procedure TForm_Main.MathParserParseError(Sender: TObject;
  ParseError: Integer);
var
  Msg : string;
begin
  if ( not ( sender is TMathParser )) then exit;

  case ParseError of
    1 : Msg := STR_56;
    2 : Msg := STR_57;
    3 : Msg := STR_58;
    4 : Msg := STR_59;
    5 : Msg := STR_60;
    6 : Msg := STR_61;
    7 : Msg := STR_62;
  end; { case }
  Msg := STR_63 + Msg + #13 + STR_64 + IntToStr(( sender as TMathParser ).Position);
  MessageDlg( Msg, mtError, [mbOk], 0 );
end; // MathParserParseError


procedure TForm_Main.MMEditPasteEvalClick(Sender: TObject);
begin
  if ( NoteIsReadOnly( ActiveNote, true )) then exit;
  ActiveNote.Editor.SelText := LastEvalExprResult;
end;

procedure TForm_Main.MMFindNodeClick(Sender: TObject);
begin
  SearchNode_TextPrev := SearchNode_Text;
  SearchNode_Text := '';
  FindTreeNode;
end;

procedure TForm_Main.MMFindNodeNextClick(Sender: TObject);
begin
  FindTreeNode;
end;

procedure TForm_Main.FindTreeNode;
var
  myNode : TTreeNTNode;
  found : boolean;  
  myNote : TTabNote;
  selectedNode : TTreeNTNode;
  FindAllTabs: boolean;
  FindHiddenNodes: boolean;

  procedure GetFirstNode;
  begin
	  myNode := TTreeNote(myNote).TV.Items.GetFirstNode;
	  if assigned( myNode ) and myNode.Hidden and (not FindHiddenNodes) then
		 myNode := myNode.GetNextNotHidden;
  end;
  
  procedure GetNextNode();
  begin
	 if FindHiddenNodes then
		myNode := myNode.GetNext
	 else
		myNode := myNode.GetNextNotHidden;
  end;
  

  procedure GetNextNote();
  var
     tabidx : integer;
  begin
     if FindAllTabs and (Form_Main.Pages.PageCount > 1) then begin
          tabidx := myNote.TabSheet.PageIndex;
          if tabidx < pred(Form_Main.Pages.PageCount) then
             inc(tabidx)
          else
             tabidx := 0;

          myNote := TTabNote(Form_Main.Pages.Pages[tabidx].PrimaryObject);
          if myNote.Kind = ntTree then
             GetFirstNode;
      end;
   end;
begin

  myNode := GetCurrentTreeNode;
  if not assigned( myNode ) then
  begin
    showmessage( STR_65 );
    exit;
  end;

  if ( SearchNode_Text = '' ) then begin
    SearchNode_Text:= ActiveNote.Editor.SelVisibleText;
    if ( SearchNode_Text = '' ) then
       SearchNode_Text := SearchNode_TextPrev;
    if InputQuery( STR_66, STR_67, SearchNode_Text ) then
       SearchNode_Text := AnsiLowercase( SearchNode_Text )
    else
       exit;
  end;

  if ( SearchNode_Text = '' ) then exit;

  found := false;
  selectedNode:= myNode;
  GetNextNode;
  myNote := ActiveNote;

  FindAllTabs := CB_ResFind_AllNotes.Checked;
  FindHiddenNodes:= CB_ResFind_HiddenNodes.Checked;

  repeat
     if assigned(myNode) then
     	  repeat
					if ( Pos( SearchNode_Text, AnsiLowercase( myNode.Text )) > 0 ) then
					begin
					  found := true;
					  if (myNote <> ActiveNote) then begin
						   Form_Main.Pages.ActivePage := myNote.TabSheet;
						   Form_Main.PagesChange(Pages);
						   TTreeNote( ActiveNote ).TV.SetFocus;
						   ActiveNote.FocusMemory := focTree;
					  end;
					  myNode.MakeVisible;        // Could be hidden
					  myNode.TreeView.Selected := myNode;
					  break;
					end;
					GetNextNode;
			  until not assigned(myNode) or (myNode = selectedNode);

		 if not found and (myNode <> selectedNode) then
			  repeat
			 	  GetNextNote();
			  	if (myNote.Kind = ntTree) then
				      GetFirstNode();
		    until (myNote.Kind = ntTree) or (myNode = selectedNode);

  until found or (myNode = selectedNode);

  if ( not found ) or (myNode = selectedNode) then
     statusbar.panels[PANEL_HINT].Text := STR_68;

end; // FindTreeNode

procedure TForm_Main.CB_ResFind_AllNotesClick(Sender: TObject);
var
  AllNotes: Boolean;
begin
    AllNotes:= CB_ResFind_AllNotes.Checked;
    if AllNotes then
       CB_ResFind_CurrentNodeAndSubtree.Checked := False;

    CB_ResFind_CurrentNodeAndSubtree.Enabled:= not AllNotes;
end;


procedure TForm_Main.MMFormatLS1Click(Sender: TObject);
begin
  PerformCmd( ecSpace1 );
end;

procedure TForm_Main.MMFormatLS15Click(Sender: TObject);
begin
  PerformCmd( ecSpace15 );
end;

procedure TForm_Main.MMFormatLS2Click(Sender: TObject);
begin
  PerformCmd( ecSpace2 );
end;

procedure TForm_Main.MMEditRepeatClick(Sender: TObject);
begin
  RepeatLastCommand;
end;


procedure TForm_Main.MMEditReverseClick(Sender: TObject);
begin
  PerformCmd( ecReverseText );
end;

procedure TForm_Main.Btn_StyleClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
  begin
    LastStyleRange := TStyleRange(( sender as TMenuItem ).Tag );
    ( sender as TMenuItem ).Checked := true;
    // Btn_MakeStyle.ImageIndex := STYLE_IMAGE_BASE + ord( LastStyleRange );
    StyleCreate( LastStyleRange, nil );
  end;

end;


procedure TForm_Main.BtnStyleApplyClick(Sender: TObject);
begin
  if ( not Toolbar_Style.Visible ) then
  begin
    case messagedlg(
      STR_69,
      mtConfirmation, [mbYes,mbNo], 0 ) of
      mrYes : begin
        // [x] this assumes .Visible is always synced with KeyOptions.ShowStyleToolbar
        // which SHOULD always be the case...
        MMViewTBStyleClick( MMViewTBStyle );
      end;
      else
        exit;
    end;
  end;
  if ( Combo_Style.ItemIndex < 0 ) then
  begin
    messagedlg( STR_70, mtInformation, [mbOK], 0 );
    exit;
  end;
  if ( not assigned( StyleManager )) then
  begin
    messagedlg( STR_71, mtError, [mbOK], 0 );
    exit;
  end;


  if ( sender is TMenuItem ) then
  begin
    case ( sender as TMenuItem ).Tag of
      ITEM_STYLE_APPLY : begin
        StyleApply( Combo_Style.Items[Combo_Style.ItemIndex] );
      end;
      ITEM_STYLE_RENAME : begin // rename style
        StyleRename( Combo_Style.Items[Combo_Style.ItemIndex] );
      end;
      ITEM_STYLE_DELETE : begin // delete style
        StyleDelete( Combo_Style.Items[Combo_Style.ItemIndex] );
      end;
      ITEM_STYLE_REDEFINE : begin // redefine style
        StyleRedefine;
      end;
      ITEM_STYLE_DESCRIBE : begin // describe style
        StyleDescribe( false, true );
      end;
    end;
  end
  else
  begin
    // Apply button was clicked
    StyleApply( Combo_Style.Items[Combo_Style.ItemIndex] );
  end;
end;


procedure TForm_Main.TVCopySubtreeClick(Sender: TObject);
begin
  TreeTransferProc(( sender as TMenuItem ).Tag, nil, KeyOptions.ConfirmTreePaste, false, false );
end;

procedure TForm_Main.TVGraftSubtreeMirrorClick(Sender: TObject);
begin
  TreeTransferProc(1, nil, KeyOptions.ConfirmTreePaste, true, false ); 
end;

procedure TForm_Main.NodesDropOnTabProc( const DropTab : TTab95Sheet );
var
  oldPage : TTab95Sheet;
  tNote : TTreeNote;
  s : string;
  DoMoveNodes : boolean;
begin
  DoMoveNodes := ( ShiftDown or KeyOptions.DropNodesOnTabMove );

  if ( DropTab = Pages.ActivePage ) then
  begin
    showmessage( STR_72 );
    exit;
  end;

  if ( TTabNote( DropTab.PrimaryObject ).Kind <> ntTree ) then
  begin
    DoMessageBox( Format(STR_73, [DropTab.Caption]), mtError, [mbOK], 0 );
    exit;
  end;

  tNote := TTreeNote( DropTab.PrimaryObject );
  oldPage := Pages.ActivePage;

  if tNote.ReadOnly then
  begin
    DoMessageBox( Format(STR_74, [DropTab.Caption]), mtError, [mbOK], 0 );
    exit;
  end;

  if KeyOptions.DropNodesOnTabPrompt then
  begin
    if DoMoveNodes then
      s := STR_75
    else
      s := STR_76;
    if ( DoMessageBox( Format(STR_77, [s, DropTab.Caption]
      ), mtConfirmation, [mbYes,mbNo], 0 ) <> mrYes ) then
      exit;
  end;

  try // [x]
    CopyCutFromNoteID:= ActiveNote.ID; 
    if TreeTransferProc( 0, nil, false, false, false ) then // step 1 - copy
    begin
      Pages.ActivePage := DropTab;
      PagesChange( Pages );
      if TreeTransferProc( 1, tNote, false, false, DoMoveNodes ) then // step 2 - paste
      begin
        if DoMoveNodes then // MOVE instead of copy, so delete originals
        begin
          Pages.ActivePage := oldPage;
          PagesChange( Pages );
          DeleteTreeNode( true );
        end;
      end;
    end
    else
    begin
      messagedlg( STR_78, mtError, [mbOK], 0 );
    end;
  finally
    if ( TransferNodes <> nil ) then
    begin
      TransferNodes.Free;
      TransferNodes := nil;
    end;
  end;

end; // NodesDropOnTabProc

procedure TForm_Main.PagesDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i : integer;
  myTab : TTab95Sheet;
begin
  Accept := ( Source is TTreeNT );
  if Accept then
  begin
    i := Pages.GetTabAt(X,Y);
    myTab := Pages.Pages[i];
    if assigned( myTab ) then
      StatusBar.Panels[PANEL_HINT].Text := Format(STR_79, [i, myTab.Caption] );
  end;
end;

procedure TForm_Main.PagesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   ptCursor : TPoint;
begin
  if Button = mbRight then begin         // [dpv]
     GetCursorPos( ptCursor );
     Menu_TAB.Popup(ptCursor.x, ptCursor.y);
  end;

end;

// PagesDragOver

procedure TForm_Main.PagesDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DropTabIdx : integer;
begin
  DropTabIdx := Pages.GetTabAt( X, Y );
  if (( DropTabIdx >= 0 ) and ( DropTabIdx < Pages.PageCount )) then
  begin
    NodesDropOnTabProc( Pages.Pages[DropTabIdx] );
  end;
end; // PagesDragDrop

procedure TForm_Main.MMInsertTermClick(Sender: TObject);
begin
  ExpandTermProc;
end;


procedure TForm_Main.MMToolsGlosAddTermClick(Sender: TObject);
begin
  AddGlossaryTerm;
end;

procedure TForm_Main.Toolbar_FormatClose(Sender: TObject);
begin
  if ( sender is TToolbar97 ) then
  begin
    case ( sender as TToolbar97 ).Tag of
      1 : begin
        KeyOptions.ToolbarMainShow := false;
        MMViewTBMain.Checked := false;
      end;
      2 : begin
        KeyOptions.ToolbarFormatShow := false;
        MMViewTBFormat.Checked := false;
      end;
      3 : begin
        KeyOptions.ToolbarStyleShow := false;
        MMViewTBStyle.Checked := false;
      end;
      4 : begin
        KeyOptions.ToolbarTreeShow := false;
        MMViewTBTree.Checked := false;
      end;
      5 : begin
        KeyOptions.ToolbarInsertShow := false;
        MMViewTBInsert.Checked := false;
      end;
    end;
  end;

end;

procedure TForm_Main.TVExportClick(Sender: TObject);
begin
  ExportTreeNode;
end;

procedure TForm_Main.TB_HideCheckedClick(Sender: TObject);   // [dpv]
var
  tNote : TTreeNote;
  Hide: boolean;
begin
  if ( assigned( ActiveNote ) and ( ActiveNote.Kind = ntTree )) then
  begin
    tNote := TTreeNote( ActiveNote );

    Hide:= not tNote.HideCheckedNodes;
    if CtrlDown and Hide then
       Hide:= False;

    tNote.HideCheckedNodes := Hide;
    MMViewHideCheckedNodes.Checked:= Hide;
    TB_HideChecked.Down := Hide;

    if Hide then
       HideChildNodesUponCheckState (tNote, nil, csChecked)
    else
       ShowCheckedNodes (tNote, nil);
  end;

end;

procedure TForm_Main.TVHideCheckedChildrenClick(Sender: TObject);
var
  tNote : TTreeNote;
begin
    tNote := TTreeNote( ActiveNote );
    HideChildNodesUponCheckState (tNote, tNote.TV.Selected, csChecked);
end;

procedure TForm_Main.TVHideUncheckedChildrenClick(Sender: TObject);
var
  tNote : TTreeNote;
begin
    tNote := TTreeNote( ActiveNote );
    HideChildNodesUponCheckState (tNote, tNote.TV.Selected, csUnchecked);
end;

procedure TForm_Main.TVShowNonFilteredClick(Sender: TObject);
var
  tNote : TTreeNote;
begin
    tNote := TTreeNote( ActiveNote );
    ShowCheckedNodes (tNote, tNote.TV.Selected);
end;



procedure TForm_Main.MMEditTrimLeftClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
    TrimBlanks(( sender as TMenuItem ).Tag );
end;

procedure TForm_Main.MMEditCompressClick(Sender: TObject);
begin
  CompressWhiteSpace;
end;

procedure TForm_Main.MMEditInvertCaseClick(Sender: TObject);
begin
  PerformCmd( ecInvertCase );
end;

procedure TForm_Main.Form_CharsClosed( sender : TObject );
begin

  try
    try
      {                                       // Unncessary with TForm_CharsNew
      with Form_Chars.FontDlg.Font do
      begin
        InsCharFont.Name := Name;
        InsCharFont.Charset := Charset;
        InsCharFont.Size := Size;
      end;
      KeyOptions.InsCharFullSet := Form_Chars.myShowFullSet;
      }

      KeyOptions.InsCharAutoAddNew := Form_Chars.AutoAddNew;
      KeyOptions.InsCharCustom:= Form_Chars.RTFCustomChars;
      Form_Chars.Release;
    except
    end;
  finally
    Form_Chars := nil;
  end;
end; // Form_CharsClosed

procedure TForm_Main.CharInsertProc( const ch : Char; const Count : integer; const FontName : string; const FontCharset : TFontCharset; Unicode: boolean= true);
var
  s : String;
  CurrentFontName: string;
  CurrentCharset: TFontCharset;
  Cmd: TEditCmd;
  AnsiCh: AnsiChar;
begin
  if ( not ( HaveNotes( false, true ) and assigned( ActiveNote ))) then
    exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;

  try
    if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
       if ActiveNote.Editor.SelLength > 0 then
          CheckToSelectLeftImageHiddenMark (ActiveNote.Editor);
    end;

    if Unicode then
       Cmd:= ecInsCharacterU
    else begin
       Cmd:= ecInsCharacter;
       AnsiCh:= AnsiChar(Ch);
    end;

    with CommandRecall do begin
      CharInfo.Code := ord( ch );
      CharInfo.Name := FontName;
      CharInfo.Count := Count;
      CharInfo.Charset := FontCharset;
    end;
    UpdateLastCommand( Cmd );
    if IsRecordingMacro then
      AddMacroEditCommand( Cmd );

    if Unicode then begin
       if ( Count = 1 ) then
         s := ch
       else
         s:= StringOfChar(ch, Count);
    end
    else begin
       if ( Count = 1 ) then
         s := AnsiCh
       else
         s:= StringOfChar(AnsiCh, Count);
    end;

    with ActiveNote.Editor do begin
       SelText := s;
       if ( FontName <> '' ) then begin
         CurrentFontName:= NoteSelText.Name;
         CurrentCharset:= NoteSelText.Charset;
         NoteSelText.Name := FontName;
         NoteSelText.Charset := FontCharset;
       end;
       SelStart := SelStart + Count;

       NoteSelText.Name := CurrentFontName;
       NoteSelText.Charset := CurrentCharset;
    end;

    NoteFile.Modified := true;
    UpdateNoteFileState( [fscModified] );

  except
    showmessage( STR_80 );
  end;

end; // CharInsertProc

procedure TForm_Main.MMInsertCharacterClick(Sender: TObject);
begin
  InsertSpecialCharacter;
end;

procedure TForm_Main.GoToEditorLine( s : string );
var
  curIdx, newIdx : integer;
  P : TPoint;
begin
  p := ActiveNote.Editor.CaretPos;
  curIdx := succ( p.Y ); // zero-based
  if ( s[1] in ['+','-'] ) then
  begin
    newIdx := curIdx + strtoint( s );
  end
  else
  begin
    newIdx := strtoint( s );
  end;

  if ( newIdx < 1 ) then
    newIdx := 1
  else
  if ( newIdx > ActiveNote.Editor.Lines.Count ) then
    newIdx := ActiveNote.Editor.Lines.Count;

  ActiveNote.Editor.selstart := ActiveNote.Editor.Perform( EM_LINEINDEX, pred( newIdx ), 0 );
  ActiveNote.Editor.Perform( EM_SCROLLCARET, 0, 0 );

end; // GoToEditorLine


procedure TForm_Main.MMFindBracketClick(Sender: TObject);
begin
  PerformCmdEx( ecMatchBracket );
end;

procedure TForm_Main.MMToolsStatisticsClick(Sender: TObject);
begin
  ShowStatistics;
end;


procedure TForm_Main.MMBkmJ9Click(Sender: TObject);
begin
  // Jump to bookmark
  if ( sender is TMenuItem ) then
  begin
    // See comment in MMBkmSet9Click
    //BookmarkGoTo( ord(( sender as TMenuItem ).Caption[2] ) - 48 );

    BookmarkGoTo( ord(TMenuItem(sender).Name[7]) - 48 );
  end;
end;

procedure TForm_Main.MMBkmSet9Click(Sender: TObject);
begin
  // Set bookmark
  if ( sender is TMenuItem ) then
  begin
    // This line only works after the "Set boomark" menu is first unfold, because only then Caption
    // changes from "1" to "&1" (e.g).  This behaviour is probably specific to TMenuItem.
    // So I will use the Name property instead of Caption (rather than asking for the last character of Caption)
    //BookmarkAdd( ord(( sender as TMenuItem ).Caption[2] ) - 48 );

    BookmarkAdd( ord(TMenuItem(sender).Name[9]) - 48 );
  end;
end;

procedure TForm_Main.MMFormatParagraphClick(Sender: TObject);
begin
  PerformCmd( ecParaDlg );
end;


procedure TForm_Main.MMInsertURLClick(Sender: TObject);
begin
  InsertURL('', '', ActiveNote);   // Ask the user
end; // Insert URL


procedure TForm_Main.MMInsertLinkToFileClick(Sender: TObject);
begin
  InsertFileOrLink( '', true );
end;

procedure TForm_Main.MMInsertObjectClick(Sender: TObject);
begin
  InsertPictureOrObject( false );
end;

procedure TForm_Main.MMInsertPictureClick(Sender: TObject);
begin
  InsertPictureOrObject( true );
end;

procedure TForm_Main.WMJumpToKNTLink( var Msg : TMessage );
var
   UrlAction: TURLAction;
begin
  UrlAction:= TURLAction(Msg.WParam);
  JumpToKNTLocation( _GLOBAL_URLText, UrlAction );
end; // WMJumpToKNTLink

procedure TForm_Main.WMShowTipOfTheDay( var DummyMSG : integer );
begin
  ShowTipOfTheDay;
end; // WMShowTipOfTheDay

procedure TForm_Main.WMJumpToLocation( var DummyMSG : integer );
begin
  try
    if assigned( _Global_Location ) then
    begin
      if ( _Global_Location.FileName <> '' ) then
      begin
        if (( not FileExists( _Global_Location.Filename )) or
           ( NoteFileOpen( _Global_Location.Filename ) <> 0 )) then
        begin
          DoMessageBox( Format(STR_81,[_Global_Location.Filename] ), mtError, [mbOK], 0 );
          exit;
        end;
      end;
      JumpToLocation( _Global_Location );
      ActiveNote.FocusMemory := focRTF;
      FocusActiveNote;
    end;
  finally
    _Global_Location := nil;
  end;
end; // WMJumpToLocation

procedure TForm_Main.MMEditPasteSpecialClick(Sender: TObject);
var
  FormatSelected: integer;
  HasImage: boolean;
  rtfText: String;

begin
  if ( not assigned( ActiveNote )) then exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;

  HasImage:= Clipboard.HasFormat(CF_BITMAP);
  if not HasImage then
     Clipboard.TryOfferRTF();

  try
     FormatSelected:= ActiveNote.Editor.PasteSpecialDialog (false);      // Will paste the user selecton, except if it is Windows Bitmap

     ActiveNote.Editor.BeginUpdate;
     try
         if FormatSelected= 5 then                                       // CF_BMP
            PasteBestAvailableFormat(ActiveNote, false, false, true)    // It will insert the image, using ImageManager
         else
            if HasImage and (FormatSelected= 0) and (ActiveNote.Editor.SelLength = 1) then begin
               if (ActiveNote.Editor.SelLength = 1) then begin
                   rtfText:= ActiveNote.Editor.RtfSelText;
                   if not rtfText.Contains('{\object') and rtfText.Contains('\pict{') then
                      PasteBestAvailableFormat(ActiveNote, false, false, true);       // It will insert the image, using ImageManager
               end;
            end;
     finally
        ActiveNote.Editor.EndUpdate;
     end;

  except
    On E : Exception do begin
       // ActiveNote.Editor.PasteSpecialDialog can raise an exception if for example RTF format obtained converting HTML is not correct
       // See PasteBestAvailableFormatInEditor (kn_EditorUtils)
       MessageDlg( E.Message, mtError, [mbOK], 0 );
       exit;
    end;
  end;

end;

procedure TForm_Main.MMEditPlainDefaultPasteClick(Sender: TObject);
begin
   EditorOptions.PlainDefaultPaste:= not EditorOptions.PlainDefaultPaste;
   PlainDefaultPaste_Toggled
end;

procedure TForm_Main.MMP_PlainDefaultPasteClick(Sender: TObject);
begin
   EditorOptions.PlainDefaultPaste:= not EditorOptions.PlainDefaultPaste;
   PlainDefaultPaste_Toggled;
end;

procedure TForm_Main.PlainDefaultPaste_Toggled;
begin
    MMP_PlainDefaultPaste.Checked := EditorOptions.PlainDefaultPaste;
    MMEditPlainDefaultPaste.Checked := EditorOptions.PlainDefaultPaste;
end;


procedure TForm_Main.MMInsertFileContentsClick(Sender: TObject);
begin
  InsertFileOrLink( '', false );
end;

procedure TForm_Main.MMToolsGlosEditClick(Sender: TObject);
begin
  EditGlossaryTerms;
end;


procedure TForm_Main.MMHelpVisitWebsiteClick(Sender: TObject);
begin
  if messagedlg(STR_82, mtConfirmation, [mbOK,mbCancel], 0) <> mrOK then exit;

  screen.Cursor := crHourGlass;
  ShellExecute( 0, 'open', PChar( Program_URL ), nil, nil, SW_NORMAL );
  screen.Cursor := crDefault;
end;

//procedure TForm_Main.MMHelpEmailAuthorClick(Sender: TObject);
//begin
//  if messagedlg('',
//    mtConfirmation, [mbOK,mbCancel], 0
//    ) <> mrOK then exit;
//  screen.Cursor := crHourGlass;
//  ShellExecute( 0, 'open', PChar( 'mailto:' + Program_Email ), nil, nil, SW_NORMAL );
//  screen.Cursor := crDefault;
//end;


procedure TForm_Main.MMInsertMarkLocationClick(Sender: TObject);
begin
  InsertOrMarkKNTLink( nil, false, '' );
end;

procedure TForm_Main.MMInsertKNTLinkClick(Sender: TObject);
begin
  InsertOrMarkKNTLink( nil, true, ActiveNote.Editor.SelVisibleText);
end;


procedure TForm_Main.Combo_StyleKeyPress(Sender: TObject; var Key: Char);
begin
  if ( key = #13 ) then
  begin
    key := #0;
    BtnStyleApplyClick( TB_Style );
  end;
end;

procedure TForm_Main.Toolbar_StyleRecreating(Sender: TObject);
begin
  Combo_Style.Tag := Combo_Style.ItemIndex;
end;

procedure TForm_Main.Toolbar_StyleRecreated(Sender: TObject);
begin
  // when toolbar changes dock, combo loses its ItemIndex.
  // This is how we fix that.
  if ( Combo_Style.Items.Count > 0 ) then
  begin
    if (( Combo_Style.Tag > -1 ) and ( Combo_Style.Tag < Combo_Style.Items.Count )) then
      Combo_Style.ItemIndex := Combo_Style.Tag
    else
      Combo_Style.ItemIndex := 0;
  end;
  Combo_Style.Tag := -1;
end;

procedure TForm_Main.MMToolsPluginRunClick(Sender: TObject);
begin
  ExecutePlugin( '' );
end;

procedure TForm_Main.MMToolsPluginRunLastClick(Sender: TObject);
begin
  if ( LastPluginFN <> '' ) then
    ExecutePlugin( LastPluginFN );
end;

procedure TForm_Main.MacMMacro_EditClick(Sender: TObject);
begin
  EditMacro( false );
end;

procedure TForm_Main.TB_MacroClick(Sender: TObject);
begin
  if IsRunningMacro then
    MacroAbortRequest := true
  else
    ExecuteMacro( '', '' );
end;

procedure TForm_Main.MMToolsMacroRunLastClick(Sender: TObject);
begin
  ExecuteMacro( LastMacroFN, '' );
end;

procedure TForm_Main.MacMMacro_DeleteClick(Sender: TObject);
begin
  DeleteMacro;
end;

procedure TForm_Main.TB_MacroRecordClick(Sender: TObject);
begin
  RecordMacro;
end;

procedure TForm_Main.TB_MacroPauseClick(Sender: TObject);
begin
  if IsRecordingMacro then
    PauseRecordingMacro
  else
    TB_MacroPause.Down := false;
end;

procedure TForm_Main.MacMMacroUserCommandClick(Sender: TObject);
begin
  AddUserMacroCommand;
end;

procedure TForm_Main.Combo_MacroClick(Sender: TObject);
var
  Macro : TMacro;
  index: integer;
begin
  ListBox_ResMacro.Hint := '';
  Macro := GetCurrentMacro( false, index);
  if assigned( macro ) then begin
    StatusBar.Panels[PANEL_HINT].Text := Macro.Description;
    ListBox_ResMacro.Hint := Macro.Description;
  end
  else
    StatusBar.Panels[PANEL_HINT].Text := '';
end;

procedure TForm_Main.Combo_MacroKeyPress(Sender: TObject; var Key: Char);
begin
  if ( key = #13 ) then
  begin
    key := #0;
    TB_MacroClick( TB_Macro );
  end;
end;

procedure TForm_Main.MMToolsMacroSelectClick(Sender: TObject);
begin
  ExecuteMacroFile;
end;

procedure TForm_Main.MMViewTBHideAllClick(Sender: TObject);
var
  DoShow : boolean;
begin
  if ( sender is TMenuItem ) then
  begin
    DoShow := (( sender as TMenuItem ).Tag > 0 );
    if ( MMViewTBMain.Checked <> DoShow ) then MMViewTBMainClick( MMViewTBMain );
    if ( MMViewTBFormat.Checked <> DoShow ) then MMViewTBFormatClick( MMViewTBFormat );
    if ( MMViewTBStyle.Checked <> DoShow ) then MMViewTBStyleClick( MMViewTBStyle );
    if ( MMViewTBTree.Checked <> DoShow ) then MMViewTBTreeClick( MMViewTBTree );
    if ( MMViewTBInsert.Checked <> DoShow ) then MMViewTBInsertClick( MMViewTBInsert );
  end;
end;

procedure TForm_Main.MMTreeSaveToFileClick(Sender: TObject);
var
  fn, oldFilter : string;
begin
  if ( not HaveNotes( true, true )) then exit;
  if ( not assigned( ActiveNote )) then exit;
  if ( ActiveNote.Kind <> ntTree ) then exit;

  ShowHiddenMarkers:= CtrlDown;

  with SaveDlg do
  begin
    oldFilter := Filter;
    Filter := FILTER_TEXTFILES;
    FilterIndex := 1;
    Title := STR_82B;
    Options := Options - [ofAllowMultiSelect];
  end;

  try
    if SaveDlg.Execute then
    begin
      fn := normalFN( SaveDlg.Filename );
      TTreeNote( ActiveNote ) .TV.SaveToFile( fn, false );
    end;
  finally
    ShowHiddenMarkers:= false;
    SaveDlg.Filter := oldFilter;
  end;

end;


procedure TForm_Main.MMHelpKeyboardRefClick(Sender: TObject);
begin
  ActiveKeyNoteHelp(18);  // Keyboard Reference [18]
  //HtmlHelp(0, PAnsiChar(Application.HelpFile), HH_HELP_CONTEXT, 30);
end;

procedure TForm_Main.MMHelpMainClick(Sender: TObject);
begin
  ActiveKeyNoteHelp(2);  // Welcome to KeyNote NF [2]
  //HtmlHelp(0, PAnsiChar(Application.HelpFile), HH_HELP_CONTEXT, 10);
end;

procedure TForm_Main.MMToolsTemplateCreateClick(Sender: TObject);
begin
  CreateTemplate;
end;


procedure TForm_Main.MMToolsTemplateInsertClick(Sender: TObject);
begin
  InsertTemplate( '' );
end;

procedure TForm_Main.TVCheckNodeClick(Sender: TObject);
var
  myNoteNode : TNoteNode;
  myTreeNode : TTreeNTNode;
begin
  if NoteIsReadOnly( ActiveNote, false ) then exit;
  myNoteNode := GetCurrentNoteNode;
  if ( not assigned( myNoteNode )) then exit;
  if ( ActiveNote.FocusMemory <> focTree ) then exit;
  myTreeNode := TTreeNote( ActiveNote ).TV.Selected;

  myNoteNode.Checked := ( not myNoteNode.Checked );
  TVCheckNode.Checked := myNoteNode.Checked;
  if myNoteNode.Checked then
    myTreeNode.CheckState := csChecked
  else
    myTreeNode.CheckState := csUnchecked;

end;

procedure TForm_Main.TVChildrenCheckboxClick(Sender: TObject);    // [dpv]
var
  myNoteNode : TNoteNode;
  myTreeNode : TTreeNTNode;
begin
  if NoteIsReadOnly( ActiveNote, false ) then exit;
  myNoteNode := GetCurrentNoteNode;
  if ( not assigned( myNoteNode )) then exit;
  if ( ActiveNote.FocusMemory <> focTree ) then exit;
  myTreeNode := TTreeNote( ActiveNote ).TV.Selected;

  myNoteNode.ChildrenCheckbox := ( not myNoteNode.ChildrenCheckbox );
  TVChildrenCheckbox.Checked := myNoteNode.ChildrenCheckbox;
  ShowOrHideChildrenCheckBoxes (myTreeNode);
end;

// TVCheckNodeClick


procedure TForm_Main.TVBoldNodeClick(Sender: TObject);
begin
  SetTreeNodeBold( ShiftDown );
end; // TVMBoldClick

procedure TForm_Main.MMViewTreeClick(Sender: TObject);
begin
  if ( assigned( ActiveNote ) and ( ActiveNote.Kind = ntTree )) then
  begin
    MMViewTree.Checked := ( not MMViewTree.Checked );

    TTreeNote( ActiveNote ).TreeHidden := ( not MMViewTree.Checked );
    UpdateTreeVisible( TTreeNote( ActiveNote ));

    if ( not MMViewTree.Checked ) then
    try
      ActiveNote.Editor.SetFocus;
    except
    end;

    MMViewNodeIcons.Enabled := MMViewTree.Checked;
    MMViewCustomIcons.Enabled := MMViewTree.Checked;
    MMViewCheckboxesAllNodes.Enabled := MMViewTree.Checked;
    MMViewHideCheckedNodes.Enabled := MMViewTree.Checked;     // [dpv]
  end;
end; // MMViewTreeClick




procedure TForm_Main.MMFormatLanguageClick(Sender: TObject);
begin
  PerformCmd( ecLanguage );
end;

procedure TForm_Main.MMNoteSpellClick(Sender: TObject);
begin
  RunSpellcheckerForNote;
end;

procedure TForm_Main.Markaslink1Click(Sender: TObject);
begin
  with NoteSelText do
    Link := ( not Link );
end;

procedure TForm_Main.Hiddentext1Click(Sender: TObject);
begin
  with NoteSelText do
    Hidden := ( not Hidden );
end;


procedure TForm_Main.MMInsHyperlinkClick(Sender: TObject);
begin
  // CreateHyperlink;
end;

procedure TForm_Main.RxRTFURLClick(Sender: TObject; const URLText: string; Button: TMouseButton);
var
  chrg: TCharRange;
  myURLAction: TURLAction;
  CtrlWasDown, AltWasDown: boolean;
  EnsureAsk: boolean;

begin
  CtrlWasDown := CtrlDown and ( not _IS_FAKING_MOUSECLICK );
  AltWasDown := AltDown and ( not _IS_FAKING_MOUSECLICK );

  EnsureAsk:= false;

  if Button = mbLeft then begin
      if CtrlWasDown then
          myURLAction:= KeyOptions.URLCtrlAction
      else
         if AltWasDown then
            myURLAction:= urlCopy
         else
            myURLAction:= KeyOptions.URLAction;
  end
  else begin
      EnsureAsk:= true;
      if TTabRichEdit(sender).PopUpMenu = nil then
         myURLAction:= urlAsk
      else
         exit;
  end;

  chrg:= TRxRichEdit(Sender).LinkClickRange;
  kn_LinksMng.ClickOnURL (URLText, chrg, myURLAction, EnsureAsk);
end;


procedure TForm_Main.MMViewResPanelClick(Sender: TObject);
begin
  if (Sender = nil) and KeyOptions.ResPanelShow and assigned(ActiveNote) then begin
     if ActiveNote.Editor.Focused or ((ActiveNote.Kind = ntTree) and TTreeNote(ActiveNote).TV.Focused) then begin
        FocusResourcePanel;
        CheckRestoreTreeWidth;
        exit;
     end;
  end;

  KeyOptions.ResPanelShow := ( not KeyOptions.ResPanelShow );

  UpdateResPanelContents;
  HideOrShowResPanel( KeyOptions.ResPanelShow );
  MMViewResPanel.Checked := KeyOptions.ResPanelShow;
  if KeyOptions.ResPanelShow then
    ResMHidepanel.Caption := STR_83
  else
    ResMHidepanel.Caption := STR_84;
  TB_ResPanel.Down := MMViewResPanel.Checked;
  if KeyOptions.ResPanelShow then
    FocusResourcePanel
  else
    FocusActiveNote;

  CheckRestoreTreeWidth;
end; // MMViewResPanelClick


procedure TForm_Main.ListBox_ResMacroDblClick(Sender: TObject);
begin
  TB_MacroClick( TB_Macro );
end;

procedure TForm_Main.ListBox_ResTplDblClick(Sender: TObject);
var
  i : integer;
begin
  i := ListBox_ResTpl.ItemIndex;
  if ( i < 0 ) then exit;
  InsertTemplate( Template_Folder + ListBox_ResTpl.Items[i] );
end; // ListBox_ResTplDblClick

procedure TForm_Main.TPLMTplDeleteClick(Sender: TObject);
begin
  RemoveTemplate;
end;

procedure TForm_Main.TPLMTplInsertClick(Sender: TObject);
begin
  ListBox_ResTplDblClick( ListBox_ResTpl );
end;

procedure TForm_Main.Menu_RTFPopup(Sender: TObject);
begin
  RTFMWordwrap.Checked := ActiveNote.Editor.WordWrap;
end; // Menu_RTFPopup

procedure TForm_Main.Splitter_ResMoved(Sender: TObject);
begin
  Combo_ResFind.Width := ResTab_Find.Width - 15;
  RG_ResFind_Type.Width:= Combo_ResFind.Width;
  RG_ResFind_Scope.Width:= Combo_ResFind.Width;
  RG_ResFind_ChkMode.Width:= Combo_ResFind.Width;
  UpdateFindAllResultsWidth;
end;

procedure TForm_Main.VisibilityControlsFindAllResults (Visible: boolean);
begin
  Btn_ResFind_Prev.Visible := Visible;
  Btn_ResFind_Next.Visible := Visible;
  LblFindAllNumResults.Visible:= Visible;
  Pages_Res.ShowHint:= not Visible;
end;

procedure TForm_Main.Btn_ResFlipClick(Sender: TObject);
var
  IsShownOptions: boolean;
begin
  IsShownOptions:= (Ntbk_ResFind.PageIndex = 0);
  if IsShownOptions then begin
    Btn_ResFlip.Caption := STR_85;
    Ntbk_ResFind.PageIndex := 1;
  end
  else begin
    Btn_ResFlip.Caption := STR_86;
    Ntbk_ResFind.PageIndex := 0;
  end;

  VisibilityControlsFindAllResults (not IsShownOptions);
end;

procedure TForm_Main.ShowFindAllOptions;
begin
   if not KeyOptions.ResPanelShow then
      MMViewResPanelClick( MMViewResPanel );

   Pages_Res.ActivePage:= ResTab_Find;
   if (Ntbk_ResFind.PageIndex = 0) then
       Btn_ResFlipClick(nil);

   FocusResourcePanel;
end;


procedure TForm_Main.MMEditSelectWordClick(Sender: TObject);
begin
  PerformCmdEx( ecSelectWord );
end;

procedure TForm_Main.Pages_ResChange(Sender: TObject);
begin
  UpdateResPanelContents;
  if KeyOptions.ResPanelShow then
    FocusResourcePanel;
end; // Pages_ResChange

procedure TForm_Main.PLM_ReloadPluginsClick(Sender: TObject);
begin
  ListBox_ResPlugins.Items.Clear;
  EnumeratePlugins;
  DisplayPlugins;
end;

procedure TForm_Main.ListBox_ResPluginsClick(Sender: TObject);
begin
  ShowPluginInfo;
end;


procedure TForm_Main.PLM_RunPluginClick(Sender: TObject);
begin
  ExecutePlugin( '' );
end; // RunPlugin

procedure TForm_Main.PLM_ConfigurePluginClick(Sender: TObject);
begin
  ConfigurePlugin( '' );
end; // ConfigurePlugin

procedure TForm_Main.ResMRightClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
  begin
    ResPanelOptions.TabOrientation := TTabOrientation(( sender as TMenuItem ).Tag );
    RecreateResourcePanel;
  end;
end;

procedure TForm_Main.ResMMultilineTabsClick(Sender: TObject);
begin
  ResPanelOptions.Stacked := ( not ResPanelOptions.Stacked );
  RecreateResourcePanel;
end;

procedure TForm_Main.Menu_ResPanelPopup(Sender: TObject);
begin
  with ResPanelOptions do
  begin
    case TabOrientation of
      tabposTop : ResMTop.Checked := true;
      tabposBottom : ResMBottom.Checked := true;
      tabposLeft : ResMLeft.Checked := true;
      tabposRight : ResMRight.Checked := true;
    end;

    if KeyOptions.ResPanelLeft then
      ResMPanelLeft.Checked := true
    else
      ResMPanelRight.Checked := true;

    ResMMultilineTabs.Checked := Stacked;
    ResMFindTab.Checked := ShowFind;
    ResMScratchTab.Checked := ShowScratch;
    ResMMacroTab.Checked := ShowMacro;
    ResMTemplateTab.Checked := ShowTemplate;
    ResMPluginTab.Checked := ShowPlugin;
    ResMFavTab.Checked := ShowFavorites;
  end;
end;

procedure TForm_Main.ResMPluginTabClick(Sender: TObject);
var
  sheet : TTab95Sheet;
  CantHideTab : boolean;
  VisibleTabs : integer;

  procedure CannotHideTabMsg;
  begin
    messagedlg( STR_87, mtInformation, [mbOK], 0 );
  end;

begin
  sheet := nil;

  VisibleTabs := 0;
  with ResPanelOptions do
  begin
    if ShowFind then inc( VisibleTabs );
    if ShowScratch then inc( VisibleTabs );
    if ShowMacro then inc( VisibleTabs );
    if ShowTemplate then inc( VisibleTabs );
    if ShowPlugin then inc( VisibleTabs );
    if ShowFavorites then inc( VisibleTabs );
  end;
  CantHideTab := ( VisibleTabs < 2 );

  if ( sender is TMenuItem ) then
  begin
    with ResPanelOptions do
    begin
      case ( sender as TMenuItem ).Tag of
        0 : begin
          ShowFind := ( not ShowFind );
          if ( CantHideTab and ( not ShowFind )) then
          begin
            CannotHideTabMsg;
            ShowFind := true;
            exit;
          end;
          sheet := ResTab_Find;
        end;
        1 : begin
          ShowScratch := ( not ShowScratch );
          if ( CantHideTab and ( not ShowScratch )) then
          begin
            CannotHideTabMsg;
            ShowScratch := true;
            exit;
          end;
          sheet := ResTab_RTF;
        end;
        2 : begin
          ShowMacro := ( not ShowMacro );
          if ( CantHideTab and ( not ShowMacro )) then
          begin
            CannotHideTabMsg;
            ShowMacro := true;
            exit;
          end;
          sheet := ResTab_Macro;
        end;
        3 : begin
          ShowTemplate := ( not ShowTemplate );
          if ( CantHideTab and ( not ShowTemplate )) then
          begin
            CannotHideTabMsg;
            ShowTemplate := true;
            exit;
          end;
          sheet := ResTab_Template;
        end;
        4 : begin
          ShowPlugin := ( not ShowPlugin );
          if ( CantHideTab and ( not ShowPlugin )) then
          begin
            CannotHideTabMsg;
            ShowPlugin := true;
            exit;
          end;
          sheet := ResTab_Plugins;
        end;
        5 : begin
          ShowFavorites := ( not ShowFavorites );
          if ( CantHideTab and ( not ShowFavorites )) then
          begin
            CannotHideTabMsg;
            ShowFavorites := true;
            exit;
          end;
          sheet := ResTab_Favorites;
        end;
      end;
    end;
  end;

  with ResPanelOptions do
  begin
    ResTab_Find.TabVisible := ShowFind;
    ResTab_RTF.TabVisible := ShowScratch;
    ResTab_Macro.TabVisible := ShowMacro;
    ResTab_Template.TabVisible := ShowTemplate;
    ResTab_Plugins.TabVisible := ShowPlugin;
    ResTab_Favorites.TabVisible := ShowFavorites;
  end;

  if (( sender is TMenuItem ) and assigned( sheet )) then
  begin
    if sheet.TabVisible then
      Pages_Res.ActivePage := sheet
    else
      Pages_Res.SelectNextPage( false );
    UpdateResPanelContents;
  end;

end; // ResMPluginTabClick


procedure TForm_Main.StatusBarDblClick(Sender: TObject);
var
  myAction : integer;
begin

  if ShiftDown then
    myAction := KeyOptions.StatBarDlbClkActionShft
  else
    myAction := KeyOptions.StatBarDlbClkAction;

  case myAction of
    DBLCLK_NOTHING : begin end;
    DBLCLK_MINIMIZE : Application.Minimize;
    DBLCLK_FILEPROP : NoteFileProperties;
    DBLCLK_FILEMGR : RunFileManager;
    DBLCLK_NOTEPROP : EditNoteProperties( propThisNote );
    DBLCLK_NEWNOTE : CreateNewNote;
    DBLCLK_RESPANEL : MMViewResPanelClick( MMViewResPanel );
  end;
end;


procedure TForm_Main.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const R: TRect);
var
  Index: integer;
begin

  Index:= Panel.Index;
  if Index <> 1 then
     exit;

  with StatusBar.Canvas do begin
      if SBGlyph.Graphic is TBitmap then  begin
         // Draw it transparently
         StatusBar.Canvas.BrushCopy(Bounds(R.Left, R.Top, SBGlyph.Width, SBGlyph.Height),
                                   SBGlyph.Bitmap,
                                   Rect(0, 0, SBGlyph.Width, SBGlyph.Height),
                                   SBGlyph.Bitmap.Canvas.Pixels[0, SBGlyph.Height-1]);
      end else
         StatusBar.Canvas.Draw(R.Left, R.Top, SBGlyph.Graphic);


      Panel.Width:= SBGlyph.Width + 9;
  end;
end;


procedure TForm_Main.Combo_ResFindChange(Sender: TObject);
begin
  Btn_ResFind.Enabled := ( Combo_ResFind.Text <> '' );
end;

procedure TForm_Main.Btn_ResFindClick(Sender: TObject);
begin
  VisibilityControlsFindAllResults (true);

  RunFindAllEx;
end;

procedure TForm_Main.Btn_ResFind_PrevClick(Sender: TObject);
begin
  FindAllResults_SelectMatch (true);
end;

procedure TForm_Main.Btn_ResFind_NextClick(Sender: TObject);
begin
  FindAllResults_SelectMatch (false);
end;

procedure TForm_Main.Combo_ResFindKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( shift = [] ) then
  begin
    case key of
      VK_RETURN : begin
        key := 0;
        if Btn_ResFind.Enabled then
          Btn_ResFindClick( Btn_ResFind );
      end;
    end;
  end;
end; // Combo_ResFindKeyDown

procedure TForm_Main.Combo_FontSizeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 27 then
  begin
    key := 0;
    FocusActiveNote;
  end;
end;

{         // [dpv]
procedure TForm_Main.List_ResFindDblClick(Sender: TObject);
var
  i : integer;
  Location : TLocation;
begin
  i := List_ResFind.ItemIndex;
  if ( i < 0 ) then exit;

  Location := TLocation( List_ResFind.Items.Objects[i] );
  if ( not assigned( Location )) then exit;
  JumpToLocation( Location );
  try
    List_ResFind.SetFocus;
  except
  end;
end; // List_ResFindDblClick

procedure TForm_Main.List_ResFindKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ( shift = [] ) then
  begin
    case key of
      VK_RETURN : begin
        key := 0;
        List_ResFindDblClick( List_ResFind );
      end;
    end;
  end;
end;
}

procedure TForm_Main.ResMPanelRightClick(Sender: TObject);
var
  WillChange : boolean;
begin
  WillChange := false;
  if ( sender is TMenuItem ) then
  begin
    case ( sender as TMenuItem ).Tag of
      0 : begin // Left
        WillChange := ( not KeyOptions.ResPanelLeft );
        KeyOptions.ResPanelLeft := true;
      end;
      1 : begin // Right
        WillChange := KeyOptions.ResPanelLeft;
        KeyOptions.ResPanelLeft := false;
      end;
    end;
    if WillChange then
    begin
      messagedlg( STR_88, mtInformation, [mbOK], 0 );
    end;
  end;
end; // ResMPanelRightClick



procedure TForm_Main.StdEMSelectAllClick(Sender: TObject);
var
  Handle : THandle;
  TempRichText : string;
  RTFSelStart : integer;
begin
  if ( sender is TMenuItem ) then
  begin
    Handle := 0;
    if ( Menu_StdEdit.PopupComponent is TCustomMemo ) then
    begin
      Handle := ( Menu_StdEdit.PopupComponent as TCustomMemo ).Handle;
    end
    else
    if ( Menu_StdEdit.PopupComponent is TCustomEdit ) then
    begin
      Handle := ( Menu_StdEdit.PopupComponent as TCustomEdit ).Handle;
    end
    else
    if ( Menu_StdEdit.PopupComponent is TCustomComboBox ) then
    begin
      Handle := TEditHandleComboBox( Menu_StdEdit.PopupComponent as TCustomComboBox ).EditHandle;
      // Handle := ( Menu_StdEdit.PopupComponent as TCustomComboBox ).Handle;
    end;

    if ( Handle = 0 ) then exit;

    case ( sender as TMenuItem ).Tag of
      0 : begin // Undo
        SendMessage( Handle, WM_UNDO, 0, 0 );
      end;
      1 : begin // Cut
        SendMessage( Handle, WM_CUT, 0, 0 );
      end;
      2 : begin // Copy
        SendMessage( Handle, WM_COPY, 0, 0 );
      end;
      3 : begin // Paste
        SendMessage( Handle, WM_PASTE, 0, 0 );
      end;
      4 : begin // Paste as Text
         with TWordWrapMemo(( Menu_StdEdit.PopupComponent as TCustomMemo )) do
         begin
           SelText := Clipboard.TryAsText;
         end;
      end;
      5 : begin // Delete
        SendMessage( Handle, WM_CLEAR, 0, 0 );
      end;
      6 : begin // SelectAll
        if ( Menu_StdEdit.PopupComponent is TCustomComboBox ) then
          ( Menu_StdEdit.PopupComponent as TCustomComboBox ).SelectAll
        else
          SendMessage( Handle, EM_SETSEL, 0, -1 );
      end;
      7 : begin // WordWrap
        (*
        // this is a generic solution, and it works, but because
        // we need to specifically protect the RichEdit from loss
        // of formatting on RecreateWnd, we'll do an ugly hack instead.
        if ( Menu_StdEdit.PopupComponent is TCustomMemo ) then
        begin
          with TWordWrapMemo(( Menu_StdEdit.PopupComponent as TCustomMemo )) do
          begin
            WordWrap := ( not WordWrap );
            ( sender as TMenuItem ).Checked := WordWrap;
          end;
        end;
        *)
        try
          RTFSelStart := Res_RTF.SelStart;
          TempRichText := Res_RTF.RtfText;
          Res_RTF.WordWrap := ( not Res_RTF.WordWrap );
          ( sender as TMenuItem ).Checked := Res_RTF.WordWrap;
          Res_RTF.Lines.BeginUpdate;
          try
            Res_RTF.Lines.Clear;
            Res_RTF.PutRtfText(TempRichText, true);
          finally
            Res_RTF.Lines.EndUpdate;
            Res_RTF.SelStart := RTFSelStart;
            Res_RTF.Perform( EM_SCROLLCARET, 0, 0 );
          end;
        except
        end;
      end;
    end;
  end;
end; // StdEMSelectAllClick

procedure TForm_Main.Menu_StdEditPopup(Sender: TObject);
type
  TSelection = record
    StartPos, EndPos: Integer;
  end;
var
  Handle : THandle;
  Selection: TSelection;
  HasSelection : boolean;
begin
  if ( sender is TPopupMenu ) then
  begin
    HasSelection := false;
    if ( Menu_StdEdit.PopupComponent is TCustomEdit ) then
    begin
      Handle := ( Menu_StdEdit.PopupComponent as TCustomEdit ).Handle;
      StdEMUndo.Enabled := ( sendmessage( Handle, EM_CANUNDO, 0, 0 ) <> 0 );
      SendMessage( Handle, EM_GETSEL, Longint( @Selection.StartPos ),
        Longint( @Selection.EndPos ));
      HasSelection := Selection.EndPos > Selection.StartPos;
    end
    else
    if ( Menu_StdEdit.PopupComponent is TCustomComboBox ) then
    begin
      Handle := TEditHandleComboBox( Menu_StdEdit.PopupComponent as TCustomComboBox ).EditHandle;
      StdEMUndo.Enabled := ( sendmessage( Handle, EM_CANUNDO, 0, 0 ) <> 0 );
      HasSelection := (( Menu_StdEdit.PopupComponent as TCustomComboBox ).SelLength > 0 );
    end;

    StdEMCut.Enabled := HasSelection;
    StdEMCopy.Enabled := HasSelection;
    StdEMDelete.Enabled := HasSelection;


    if ( Menu_StdEdit.PopupComponent is TCustomMemo ) then
    begin
      StdEMWordWrap.Visible := true;
      StdEMWordWrap.Checked := TWordWrapMemo(( Menu_StdEdit.PopupComponent as TCustomMemo )).WordWrap;
      StdEMPastePlain.Visible := true;
    end
    else
    begin
      StdEMWordWrap.Visible := false;
      StdEMPastePlain.Visible := false;
    end;

  end;

end; // Menu_StdEditPopup

procedure TForm_Main.MMTreeMasterNodeClick(Sender: TObject);
begin
  CreateMasterNode;
end;

procedure TForm_Main.TVCopyNodePathClick(Sender: TObject);
begin
  CopyNodePath( false );
end;

procedure TForm_Main.TVCopyNodeTextClick(Sender: TObject);
begin
  CopyNodeName( true );
end;

procedure TForm_Main.TVCopyPathtoEditorClick(Sender: TObject);
begin
  CopyNodePath( true );
end;

procedure TForm_Main.FAMCopytoEditorClick(Sender: TObject);
begin
  FindResultsToEditor( true );
end;

procedure TForm_Main.FAMCopyAlltoEditorClick(Sender: TObject);
begin
  FindResultsToEditor( false );
end;

procedure TForm_Main.RG_ResFind_TypeClick(Sender: TObject);
begin
//  CB_ResFind_NodeNames.Enabled := ( TSearchMode( RG_ResFind_Type.ItemIndex ) = smPhrase );
end;

procedure TForm_Main.MMTreeNodeFromSelClick(Sender: TObject);
begin
  CreateNodefromSelection;
end;


{$IFDEF WITH_IE}
function TForm_Main.SelectVisibleControlForNode( const aNode : TNoteNode ) : TNodeControl;
begin
  result := ncNone;
  if ( not assigned( aNode )) then exit;

  case aNode.VirtualMode of
    vmNone, vmText, vmRTF, vmHTML : result := ncRTF;
    vmIELocal, vmIERemote : begin
      if _IE4Available then
        result := ncIE;
    end;
  end;
end; // SelectVisibleControlForNode
{$ENDIF}


procedure TForm_Main.FavMJumpClick(Sender: TObject);
begin
  JumpToFavorite;
end;

procedure TForm_Main.FavMAddClick(Sender: TObject);
begin
  AddFavorite( false );
end;

procedure TForm_Main.FavMDelClick(Sender: TObject);
begin
  DeleteFavorite;
end;

procedure TForm_Main.ListBox_ResFavClick(Sender: TObject);
var
  myFav : TLocation;
  fn, nn : string;
begin
  myFav := GetSelectedFavorite;
  if ( not assigned( myFav )) then exit;

  if myFav.ExternalDoc then
  begin
    StatusBar.Panels[PANEL_HINT].Text := Format(STR_89, [myFav.Filename] );
    exit;
  end;

  if (( not HaveNotes( false, false )) or
     ( AnsiCompareText( NoteFile.FileName, myFav.FileName ) <> 0 )) then
  begin
    fn := STR_90 + ExtractFilename( myFav.Filename );
  end
  else
  begin
    fn := '';
  end;

  if ( myFav.NodeID > 0 ) then
  begin
    nn := STR_91 + myFav.NodeName;
  end
  else
  begin
    nn := '';
  end;

  StatusBar.Panels[PANEL_HINT].Text := Format(STR_92, [fn, myFav.NoteName, nn]);

end; // ListBox_ResFavClick

procedure TForm_Main.ListBox_ResTplClick(Sender: TObject);
begin
  StatusBar.Panels[PANEL_HINT].Text := STR_93;
end;

procedure TForm_Main.TVUnlinkVirtualNodeClick(Sender: TObject);
begin
  VirtualNodeUnlink;
end;

procedure TForm_Main.FavMAddExternalClick(Sender: TObject);
begin
  AddFavorite( true );
end;



procedure TForm_Main.MMTreeOutlineNumClick(Sender: TObject);
begin
  OutlineNumberNodes;
end;

procedure TForm_Main.MMHistoryGoBackClick(Sender: TObject);
begin
  NavigateInHistory( hdBack );
end;

procedure TForm_Main.MMHistoryGoForwardClick(Sender: TObject);
begin
  NavigateInHistory( hdForward );
end;

procedure TForm_Main.MMUpRomanClick(Sender: TObject);
var
  actualNumbering : TRxNumbering;
begin
  KeyOptions.LastNumbering := TRxNumbering(( sender as TMenuItem ).Tag );
  ( sender as TMenuItem ).Checked := true;

  actualNumbering:= ActiveNote.Editor.Paragraph.Numbering;
  if not (actualNumbering in [nsNone, nsBullet]) then
      PerformCmd( ecNumbers );
end;

procedure TForm_Main.MMRightParenthesisClick(Sender: TObject);
var
  actualNumbering : TRxNumbering;
  numberingStyle: TRxNumberingStyle;
  actualNumberingStyle : TRxNumberingStyle;
begin
  numberingStyle:= TRxNumberingStyle(( sender as TMenuItem ).Tag );
  actualNumbering:= ActiveNote.Editor.Paragraph.Numbering;
  actualNumberingStyle:= ActiveNote.Editor.Paragraph.NumberingStyle;

  KeyOptions.LastNumberingStyle := numberingStyle;

  case numberingStyle of
    nsNoNumber :
         try
           PerformCmd( ecNumbers );
         finally
           KeyOptions.LastNumberingStyle:= actualNumberingStyle;   // restore actual numbering style
           NumberingStart:= 1;
         end
    else begin
        ( sender as TMenuItem ).Checked := true;
         if not (actualNumbering in [nsNone, nsBullet]) then begin
            PerformCmd( ecNumbers );
         end;
        end;
  end;
end;

procedure TForm_Main.MMStartsNewNumberClick(Sender: TObject);
var
   actualNumbering : TRxNumbering;
begin
   actualNumbering:= ActiveNote.Editor.Paragraph.Numbering;
   try
      NumberingStart:= StrToInt(InputBox( 'KeyNote NF', STR_96, '1' ));
      PerformCmd( ecNumbers );
   except
   end;
   NumberingStart:= 1;
end;


procedure TForm_Main.MMHelpWhatsNewClick(Sender: TObject);
begin
  DisplayHistoryFile;
end;

procedure TForm_Main.MMViewTBRefreshClick(Sender: TObject);
begin
  if fileexists( Toolbar_FN ) then
  begin
    LoadToolbars;
    ResolveToolbarRTFv3Dependencies;
  end
  else
  begin
    SaveToolbars;
    messagedlg( Format(
      STR_94, [Toolbar_FN] ), mtError, [mbOK], 0 );
  end;
end;

procedure TForm_Main.MMViewTBSaveConfigClick(Sender: TObject);
begin
  SaveToolbars;
  messagedlg( Format(
    STR_95, [Toolbar_FN] ), mtInformation, [mbOK], 0 );
end;

procedure TForm_Main.TVSelectNodeImageClick(Sender: TObject);
begin
  SetTreeNodeCustomImage;
end;


procedure TForm_Main.TVNodeTextColorClick(Sender: TObject);
begin
  SetTreeNodeColor( true, true, false, ShiftDown );
end;

procedure TForm_Main.TVDefaultNodeFontClick(Sender: TObject);
var
  ShiftWasDown : boolean;
begin
  ShiftWasDown := ShiftDown;
  SetTreeNodeColor( false, true, true, ShiftWasDown );
  SetTreeNodeColor( false, false, true, ShiftWasDown );
  SetTreeNodeFontFace( true, ShiftWasDown );
end;

procedure TForm_Main.TVNavigateNonVirtualNodeClick(Sender: TObject);
var
  myTreeNode: TTreeNTNode;
begin
    myTreeNode:= GetCurrentTreeNode;
    if assigned(myTreeNode) and assigned(myTreeNode.Data) then begin
        NavigateToTreeNode(TNoteNode(myTreeNode.Data).MirrorNode);
    end;
end;

procedure TForm_Main.TVNodeBGColorClick(Sender: TObject);
begin
  SetTreeNodeColor( true, false, false, ShiftDown );
end;

procedure TForm_Main.Res_RTFKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ptCursor : TPoint;
begin
  case key of
    VK_F10 : if ( shift = [ssShift] ) then
    begin
      key := 0;
      GetCursorPos( ptCursor );
      Menu_StdEdit.Popup( ptCursor.X, ptCursor.Y );
    end;
  end;
end; // Res_RTFKeyDown

{  See comment in SetUpVCLControls (kn_VCLControlsMng.pas)

procedure TForm_Main.RxRTFStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  _Is_Dragging_Text := true;
end;

procedure TForm_Main.RxRTFEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  _Is_Dragging_Text := false;
  // StatusBar.Panels[0].Text := 'RTF end drag';
end;
}

procedure TForm_Main.RxRTFStartDrag(Sender: TObject; var DragObject: TDragObject);
var
  Editor: TRxRichEdit;
begin
  // To ensure that the hidden image mark accompanies it in the event that it moves by dragging
   if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
      Editor:= TRxRichEdit(Sender);
      if Editor.SelLength = 1 then begin
         DraggingImageID:= CheckToIdentifyImageID(Editor, DraggingImage_PosFirstHiddenChar);
         if DraggingImageID > 0 then begin
            DraggingImage_PosImage:= Editor.SelStart;
            DraggingImageID:= - DraggingImageID;
         end;
      end;
   end;
end;

procedure TForm_Main.RxRTFEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  { The action that incorporates the hidden mark near the image is not performed here, since this event
    does not occur exactly at the completion of the action. If we compare Editor.SelStart here and from
    RxRTFSelectionChange we can see that when dragging to a later position, the value is different (not
    updated at this point), but it does match if you drag to an earlier position.
    To avoid problems, the action will be performed from RxRTFSelectionChange, and from here what we do
    is confirm that the action must be performed because the dragging action has not been canceled, and
    has been finished within the same editor. This is the reason why at RxRTFStartDrag we are assigning
    DraggingImageID a negative value.   }
  DraggingImageID:= - DraggingImageID;
end;



procedure TForm_Main.MMToolsCustomKBDClick(Sender: TObject);
begin
  CustomizeKeyboard;
end;



procedure TForm_Main.MMTreeNavRightClick(Sender: TObject);
begin
  if ( sender is TMenuItem ) then
    NavigateInTree( TNavDirection(( sender as TMenuItem ).Tag ));
end;

procedure TForm_Main.MMToolsExportExClick(Sender: TObject);
begin
  ExportNotesEx;
end;

procedure TForm_Main.FindAllResultsContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  FindAllResults_RightClick ( Form_Main.FindAllResults.GetCharFromPos(MousePos) );
end;

procedure TForm_Main.FindNotify( const Active : boolean );
begin

  // This procedure is called from non-modal dialogs (Find, Replace)
  // every time the dialog form is actiovated or deactivated. When
  // non-modal dialog form is activated, we disable main menu,
  // because otherwise keypresses in the non-modal dialog trigger
  // main menu commands. (Perhaps context menus should be disabled
  // as well?)
  MMFile_.Enabled := Active;
  MMEdit_.Enabled := Active;
  MMView_.Enabled := Active;
  MMInsert_.Enabled := Active;
  MMFormat_.Enabled := Active;
  MMNote_.Enabled := Active;
  MMTree_.Enabled := Active;
  MMSearch_.Enabled := Active;
  MMTools_.Enabled := Active;
  MMHelp_.Enabled := Active;
end; // FindNotify

procedure TForm_Main.FavMRefClick(Sender: TObject);
begin
  RefreshFavorites;
end;

procedure TForm_Main.MMToolsUASClick(Sender: TObject);
begin
  KeyOptions.UASEnable := ( not KeyOptions.UASEnable );
  EnableOrDisableUAS;
end;

procedure TForm_Main.MMToolsUASConfigClick(Sender: TObject);
begin
  ConfigureUAS;
end;

procedure TForm_Main.Combo_ZoomDblClick(Sender: TObject);
begin
  SetEditorZoom( DefaultEditorProperties.DefaultZoom, '' );
  FocusActiveNote;
end;

procedure TForm_Main.Combo_ZoomExit(Sender: TObject);
begin
   if Pos('%', Combo_Zoom.Text, 1) = 0 then
      SetEditorZoom( -1, Combo_Zoom.Text );
end;

procedure TForm_Main.MMViewZoomInClick(Sender: TObject);
begin
  if ShiftDown then
    SetEditorZoom( DefaultEditorProperties.DefaultZoom, '' )
  else
    SetEditorZoom( 0, '', KeyOptions.ZoomIncrement );
end;

procedure TForm_Main.MMViewZoomOutClick(Sender: TObject);
begin
  if ShiftDown then
    SetEditorZoom( DefaultEditorProperties.DefaultZoom, '' )
  else
    SetEditorZoom( 0, '', - KeyOptions.ZoomIncrement );
end;


procedure TForm_Main.MMAlternativeMarginsClick(Sender: TObject);
begin
  MMAlternativeMargins.Checked:= not MMAlternativeMargins.Checked;

  if assigned(ActiveNote) then begin
     SetMargins();
     ActiveNote.Editor.Refresh;
  end;
end;

procedure TForm_Main.UpdateShowImagesState;
var
  Enabled, Checked: boolean;
begin
   Checked:= (ImagesManager.ImagesMode = imImage);
   Enabled:= (ImagesManager.StorageMode <> smEmbRTF) and (NoteSupportsRegisteredImages);

   MMShowImages.Checked:= Checked;
   MMShowImages.Enabled:= Enabled;
   TB_Images.Enabled:=  Enabled;
   TB_Images.Down:=     Checked;
end;



procedure TForm_Main.MMShowImagesClick(Sender: TObject);
var
  ForceMode, Show: boolean;
begin
   ForceMode:= false;
   Show:= not MMShowImages.Checked;

   try
      if CtrlDown then begin
         if ImagesManager.ImagesMode = imImage then begin
            ActiveNote.ReloadImagesOnEditor;
            exit;
         end
         else begin
            Show:= false;
            ForceMode:= true;
         end;
      end;

     ShowImages (Show, ForceMode);

   finally
     if _LastZoomValue <> 100 then
        SetEditorZoom(ActiveNote.Editor, _LastZoomValue, '' );
   end;

end;


procedure TForm_Main.TB_ImagesClick(Sender: TObject);
var
   SS: integer;
begin
{$IF Defined(DEBUG_IMG) AND Defined(DEBUG)}
  if (CtrlDown and AltDown) then begin
     var str: string;
     var i: integer;

     if NoteFile <> nil then begin
        str:=       ActiveNote.NoteTextPlain    + #13 + '--------     ' + #13;
        str:= str + ActiveNote.Editor.TextPlain + #13 + '--------     ' + #13;
        str:= str + ActiveNote.Editor.RtfText   + #13 + '--------     ' + #13;
        Form_Main.Res_RTF.Text:= str;
     end;

     TB_Images.Down:= not TB_Images.Down;
     exit;
  end;
{$ENDIF}

   if ActiveNote = nil then exit;

   if CtrlDown or AltDown then begin
      SS:= ActiveNote.Editor.SelStart;
      TB_Images.Down:= not TB_Images.Down;

      if CtrlDown then begin
         if ImagesManager.ImagesMode = imImage then
            ActiveNote.ReloadImagesOnEditor
         else
            ShowImages (False, True);
      end
      else
         ActiveNote.ReconsiderImageDimensionGoalsOnEditor (ActiveNote.Editor.SelLength > 0);

      ActiveNote.Editor.SelStart:= SS;
      Application.ProcessMessages;
      ActiveNote.Editor.SelLength:= 0;
   end
   else
      ShowImages (TB_Images.Down, False);

   if _LastZoomValue <> 100 then
      SetEditorZoom(ActiveNote.Editor, _LastZoomValue, '' );
end;


procedure TForm_Main.ShowImages(Show: boolean; ForceMode: boolean);
var
   ImageModeDest: TImagesMode;

begin
  MMShowImages.Checked:= Show;
  TB_Images.Down := Show;

  if Show then
     ImageModeDest:= imImage
  else
     ImageModeDest:= imLink;

   ImagesManager.ImagesMode:= ImageModeDest;
   ActiveNote.SetImagesMode (ImageModeDest, ForceMode);
end;


{    // [dpv]
procedure TForm_Main.List_ResFindDrawItem(Control: TWinControl;
  Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB : TTextListBox;
  Loc : TLocation;
  theColor : TColor;
begin
  // custom draw for List_ResFind
  LB := ( Control as TTextListBox );

  if ( odSelected in State ) then
  begin
    theColor := clHighlight;
  end
  else
  begin
    if ( Index > 0 ) then
    begin
      Loc := TLocation( LB.Items.Objects[index] );

      case Loc.Tag of
        0 : theColor := clWindow;
        else
          theColor := ResPanelOptions.FindListAltColor;
      end;
    end
    else
    begin
      theColor := clWindow;
    end;
  end;


  with LB do
  begin
    canvas.Brush.Color := theColor;
    canvas.Brush.Style := bsSolid;
    canvas.FillRect( Rect );
    canvas.Brush.Style := bsClear;
    TCanvas(canvas).TextRect( Rect, Rect.Left+2, Rect.Top, Items[index] );
  end;
end;
}


procedure TForm_Main.Menu_TVPopup(Sender: TObject);
var
  myNode : TNoteNode;
begin
  myNode := GetCurrentNoteNode;
  if assigned( myNode ) then
    VirtualNodeUpdateMenu( myNode.VirtualMode <> vmNone, myNode.VirtualMode = vmKNTNode )
  else
    VirtualNodeUpdateMenu( false, false );
end;


procedure TForm_Main.Menu_TimePopup(Sender: TObject);
var
  ItemTag, i : integer;
  ListCount, MenuCount : integer;
  item : TMenuItem;
  nowDate : TDateTime;
begin
  nowDate := now;
  MenuCount := Menu_Time.Items.Count;
  ListCount := TIME_FORMAT_LIST.Count;

  for i := 1 to MenuCount do
  begin
    item := Menu_Time.Items[pred( i )];
    ItemTag := Item.Tag;
    if ( ItemTag <= ListCount ) then
    begin
      Item.Visible := true;
      case Item.Tag of
        0 : begin { nothing } end;
        1 : item.Caption := GetDateTimeFormatted( KeyOptions.TimeFmt, now );
        else
          item.Caption := GetDateTimeFormatted( TIME_FORMAT_LIST[ItemTag-1], now );
      end;
    end
    else
    begin
      Item.Visible := false;
    end;
  end;
end; // Menu_TimePopup

procedure TForm_Main.Menu_DatePopup(Sender: TObject);
var
  ItemTag, i : integer;
  ListCount, MenuCount : integer;
  item : TMenuItem;
  nowDate : TDateTime;
begin
  nowDate := now;
  MenuCount := Menu_Date.Items.Count;
  ListCount := DATE_FORMAT_LIST.Count;

  for i := 1 to MenuCount do
  begin
    Item := Menu_Date.Items[pred( i )];
    ItemTag := Item.Tag;
    if ( ItemTag <= ListCount ) then
    begin
      Item.Visible := true;
      case ItemTag of
        0 : begin { nothing } end;
        1 : item.Caption := GetDateTimeFormatted( KeyOptions.DateFmt, nowDate );
        else
        begin
          item.Caption := GetDateTimeFormatted( DATE_FORMAT_LIST[ItemTag-1], nowDate );
        end;
      end;
    end
    else
    begin
      Item.Visible := false;
    end;
  end;

end; // Menu_DatePopup

procedure TForm_Main.md25Click(Sender: TObject);
var
  ItemTag : integer;
begin
  if ( not assigned( ActiveNote )) then exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;
  if ( sender is TMenuItem ) then
  begin
    ItemTag := ( sender as TMenuItem ).Tag;
    if (( ItemTag > 0 ) and ( ItemTag <= DATE_FORMAT_LIST.Count )) then
    begin
      case ItemTag of
        1 : KeyOptions.DTLastDateFmt := KeyOptions.DateFmt;
        else
        begin
          KeyOptions.DTLastDateFmt := DATE_FORMAT_LIST[ItemTag-1];
        end;
      end;

      ActiveNote.Editor.SelText := GetDateTimeFormatted( KeyOptions.DTLastDateFmt, now ) + #32;
      ActiveNote.Editor.SelStart := ActiveNote.Editor.SelStart + ActiveNote.Editor.SelLength;
      ( sender as TMenuItem ).Checked := true;
    end;
  end;
end;

procedure TForm_Main.mt8Click(Sender: TObject);
var
  ItemTag : integer;
begin
  if ( not assigned( ActiveNote )) then exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;
  if ( sender is TMenuItem ) then
  begin
    ItemTag := ( sender as TMenuItem ).Tag;
    if (( ItemTag > 0 ) and ( ItemTag <= TIME_FORMAT_LIST.Count )) then
    begin
      case ItemTag of
        1 : KeyOptions.DTLastTimeFmt := KeyOptions.TimeFmt;
        else
          KeyOptions.DTLastTimeFmt := TIME_FORMAT_LIST[ItemTag-1];
      end;

      ActiveNote.Editor.SelText := GetDateTimeFormatted( KeyOptions.DTLastTimeFmt, now ) + #32;
      ActiveNote.Editor.SelStart := ActiveNote.Editor.SelStart + ActiveNote.Editor.SelLength;
      ( sender as TMenuItem ).Checked := true;
    end;
  end;
end;

procedure TForm_Main.Menu_SymbolsPopup(Sender: TObject);
var
  i, cnt : integer;
  item : TMenuItem;
begin
  cnt := Menu_Symbols.Items.Count;
  for i := 1 to cnt do
  begin
    item := Menu_Symbols.Items[pred( i )];
    if ( Item.Tag > 0 ) then
      item.Caption := SYMBOL_NAME_LIST[Item.Tag];
  end;
end;


procedure TForm_Main.ms11Click(Sender: TObject);
var
  t : integer;
begin
  if ( not assigned( ActiveNote )) then exit;
  if NoteIsReadOnly( ActiveNote, true ) then exit;
  if ( sender is TMenuItem ) then
  begin
    t := ( sender as TMenuItem ).Tag;
    if (( t > 0 ) and ( t <= high( SYMBOL_CODE_LIST ))) then
    begin
      if (ImagesManager.StorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
         if ActiveNote.Editor.SelLength > 0 then
            CheckToSelectLeftImageHiddenMark (ActiveNote.Editor);
      end;

      ActiveNote.Editor.SelText := SYMBOL_CODE_LIST[t];
      ActiveNote.Editor.SelStart := ActiveNote.Editor.SelStart + 1;
    end;
  end;

end;


(*    // [dpv] Unnecessary. It is possible to activate the link with ENTER
procedure TForm_Main.MMToolsURLClick(Sender: TObject);
var
  pt : TPoint;
begin
  // fake a mouseclick to simulate clicking a hyperlink

  if ( not assigned( ActiveNote )) then exit;

  GetCaretPos( pt );
  // pt := ActiveNote.Editor.ClientToScreen( pt );
  // SetCursorPos( pt.x, pt.y );
  _IS_FAKING_MOUSECLICK := true;

  {
  mouse_event( MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0 );
  mouse_event( MOUSEEVENTF_LEFTUP, 0, 0, 0, 0 );
  }

  // alternate solution, does not move the mouse
  PostMessage( ActiveNote.Editor.Handle, WM_LBUTTONDOWN, MK_LBUTTON,
               MakeLParam( pt.x, pt.y ));
  PostMessage( ActiveNote.Editor.Handle, WM_LBUTTONUP, 0,
               MakeLParam( pt.x, pt.y ));

end; // MMToolsURLClick
*)

procedure TForm_Main.Combo_StyleDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  myIcon : TIcon;
  myIconIdx : integer;
  myOffset : integer;
  myPos : TPoint;
  myText : string;
  myLen : integer;
  myRect : TRect;
  myStyle : TStyle;
  r : integer;
begin
  r := Combo_Style.ItemHeight;
  myOffset := 2;
  myText := Combo_Style.Items[Index];
  myLen := length( myText );

  myIconIdx := STYLE_IMAGE_BASE + ord( TStyle( StyleManager.Objects[Index] ).Range );
  myIcon := TIcon.Create;
  try
      Combo_Style.Canvas.FillRect( Rect );
      IMG_Toolbar.GetIcon( myIconIdx, myIcon );
      myPos := Point( myOffset + 2, Rect.Top + (( Rect.Bottom - Rect.Top - IMG_Toolbar.Height) div 2));
      DrawIconEx( Combo_Style.Canvas.Handle, myPos.X, myPos.Y, myIcon.Handle, IMG_Toolbar.Width, IMG_Toolbar.Height, 0, Combo_Style.Canvas.Brush.Handle, DI_Normal );

      inc( myOffset, myPos.X+IMG_Toolbar.Width+2 );

      SetRect( myRect, myOffset, Rect.Top, Rect.Right, Rect.Bottom);
  finally
      myIcon.Free;
  end;


  if KeyOptions.StyleShowSamples then begin
    // draw style sample (only for styles which have font info)

    myStyle := TStyle( StyleManager.Objects[Index] );
    if ( myStyle.Range <> srParagraph ) then begin
      with Combo_Style.Canvas.Font do
      begin
        Name := myStyle.Font.Name;
        Charset := myStyle.Font.Charset;
        Style := myStyle.Font.Style;
        if ( not ( odSelected in State )) then
          Color := myStyle.Font.Color;
        // Size := myStyle.Font.Size; [x] cannot do this
      end;

      if (( not ( odSelected in State )) and myStyle.Text.HasHighlight ) then
         Combo_Style.Canvas.Brush.Color := myStyle.Text.Highlight;
    end;
    DrawText( Combo_Style.Canvas.Handle, PChar(myText), myLen, myRect, DT_SingleLine or DT_VCenter);
  end
  else  // do not draw style samples, but show style images instead
      DrawText( Combo_Style.Canvas.Handle, PChar(myText), myLen, myRect, DT_SingleLine or DT_VCenter);
end;

procedure TForm_Main.DoBorder1Click(Sender: TObject);
var
  Paragraph: TParaFormat2;
begin
  FillChar(Paragraph, SizeOf(Paragraph), 0);
  Paragraph.cbSize := SizeOf(Paragraph);

  Paragraph.dwMask := PFM_BORDER;
  Paragraph.wBorders := 64;

  SendMessage( ActiveNote.Editor.Handle, EM_SETPARAFORMAT, 0, LPARAM(@Paragraph));
end;

procedure TForm_Main.MMEditDecimalToRomanClick(Sender: TObject);
begin
  ArabicToRoman;
end;


procedure TForm_Main.MMEditRomanToDecimalClick(Sender: TObject);
begin
  RomanToArabic;
end;

procedure TForm_Main.MMViewStatusBarClick(Sender: TObject);
begin
  // show or hide status bar
  KeyOptions.StatBarShow := ( not KeyOptions.StatBarShow );
  UpdateStatusBarState;
end;

procedure TForm_Main.UpdateStatusBarState;
begin
  StatusBar.Visible := KeyOptions.StatBarShow;
  MMViewStatusBar.Checked := KeyOptions.StatBarShow;
end; // UpdateStatusBarState


procedure TForm_Main.UpdateTreeVisible( const ANote : TTreeNote );
var
   Inc: Integer;
begin
  with ANote do begin
    TV.Visible := ( not TreeHidden );
    if TreeHidden then
      FocusMemory := focRTF;

    if KeyOptions.UseCtrlHideTreePanel then
        if TreeHidden then begin
           if CtrlDown then begin
              _WindowWidthIncToRestore:= TV.Width;
              Inc:= _WindowWidthIncToRestore;
              With Form_Main do
                SetBounds(Left + Inc, Top, Width - Inc, Height );
           end;
        end
        else
           CheckRestoreAppWindowWidth;
  end;
end; // UpdateTreeVisible


procedure TForm_Main.CheckRestoreAppWindowWidth (EnsureTreeVisible: boolean= False);
var
   Inc: Integer;
begin
    if _WindowWidthIncToRestore > 0 then begin
       if EnsureTreeVisible and (ActiveNote.Kind = ntTree) then
          TTreeNote(ActiveNote).TV.Visible := True;

       Inc:= _WindowWidthIncToRestore;
       _WindowWidthIncToRestore:= 0;
       With Form_Main do
         SetBounds(Left - Inc, Top, Width + Inc, Height );
    end;
end;



procedure TForm_Main.FavMPropertiesClick(Sender: TObject);
begin
  FavoriteEditProperties;
end;



procedure TForm_Main.MMEditPasteAsWebClipClick(Sender: TObject);
begin
  PasteAsWebClip(false);
end;

procedure TForm_Main.MMEditPasteAsWebClipTextClick(Sender: TObject);
begin
  PasteAsWebClip(true);
end;

function DoMessageBox (text: string;
        DlgType: TMsgDlgType;  Buttons: TMsgDlgButtons;
        HelpCtx: Longint = 0; hWnd: HWND= 0): integer;
var
   caption: string;
begin
    if assigned(NoteFile) then
       caption:= ExtractFilename(NoteFile.FileName) + ' - ' + Program_Name
    else
       caption:= Program_Name;

    Result:= DoMessageBox(text,caption, DlgType, Buttons,0, hWnd);
end;

function PopUpMessage( const mStr : string; const mType : TMsgDlgType;
        const mButtons : TMsgDlgButtons; const mHelpCtx : integer) : word;
var
   caption: string;
begin
    if assigned(NoteFile) then
       caption:= ExtractFilename(NoteFile.FileName) + ' - ' + Program_Name
    else
       caption:= Program_Name;

    Result:= PopUpMessage(mStr, caption, mType, mButtons, mHelpCtx);
end;


Initialization
   SBGlyph:= nil;
   ShowingImageOnTrack:= false;

end.

