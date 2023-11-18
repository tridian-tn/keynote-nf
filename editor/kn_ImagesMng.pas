unit kn_ImagesMng;

(****** LICENSE INFORMATION **************************************************

 - This Source Code Form is subject to the terms of the Mozilla Public
 - License, v. 2.0. If a copy of the MPL was not distributed with this
 - file, You can obtain one at http://mozilla.org/MPL/2.0/.

------------------------------------------------------------------------------
 (c) 2007-2023 Daniel Prado Velasco <dprado.keynote@gmail.com> (Spain)

  Fore more information, please see 'README.md' and 'doc/README_SourceCode.txt'
  in https://github.com/dpradov/keynote-nf

 *****************************************************************************)


// See "kn_ImagesMng_Readme.txt"


interface

uses
   Winapi.Windows,
   Winapi.Messages,
   Winapi.ShellAPI,
   System.SysUtils,
   System.Math,
   System.Classes,
   System.Contnrs,
   System.IOUtils,
   System.Zip,
   Vcl.Graphics,
   Vcl.Controls,
   Vcl.Forms,
   Vcl.Dialogs,
   Vcl.StdCtrls,
   Vcl.ComCtrls,
   Vcl.Clipbrd,
   SynGdiPlus,
   RxRichEd,
   gf_streams,
   gf_miscvcl,
   gf_files,
   kn_Const,
   kn_NodeList,
   kn_NoteObj,
   kn_LocationObj,
   kn_ImagesUtils;



resourcestring
  STR_01 = 'Invalid Storage definition: ';
  STR_02 = 'Invalid Image definition: ';
  STR_03 = 'Invalid Embedded Image: ';
  STR_04 = 'Image not found: ';
  STR_09 = ' | %d instances';

  STR_05 = 'External storage not ready' + #13 +
           'New images will be saved provisionally [only] as Embedded KNT';

  STR_07 = 'Folder "%s" is not empty or valid';
  STR_08 = 'A file with that name already exists (%s)';
  STR_10 = 'Error %d opening "%s": "%s"';
  STR_11 = 'Folder "%s" does not exist or is empty';
  STR_12 = 'File "%s" does not exist or is not a valid Zip';
  STR_13 = 'All images will be adapted to the storage mode. If selected a new external storage, ' +
           'image files will only be added when you save the KNT file. Current external storage will not be modified.' + #13 +
           'You can change the storage again after saving the KNT file.' + #13+#13 + 'Continue?';
  STR_14 = 'Current external storage is not available or is invalid' + #13 +
            'If you moved the external storage, select "Relocated" and register its new location';
  STR_15 = 'All images have been adapted OK to the storage mode. Changes will be confirmed when KNT file is saved' + #13 +
            '(%d different images have been found)';

  STR_16 = 'Exception creating ZIP archive: ';
  STR_17 = 'Exception adding file to ZIP archive: ';
  STR_18 = 'Exception opening image viewer: ';
  STR_19 = 'Exception changing image storage mode: ';
  STR_20 = 'Exception processing image in RTF: ';


const
  SEP = '|';
  IMG_LOG_FILE = '_LOG.txt';
  NUM_MIN_TO_FREE_ImageStreamsNotRecentlyUsed = 15;

type


//---------------------------------------------------------------------
//  TFilesStorage
//---------------------------------------------------------------------
  
 TStorageType = (stZIP, stFolder, stEmbeddedKNT, stEmbeddedRTF);


type

  TKntImage = class;
  TKntImageArray = Array of TKntImage;


  TFilesStorage = class abstract

  strict protected
    FPath: String;
    FAbsolutePath: String;
    function GeStorageType: TStorageType; virtual; abstract;

  public
    constructor Create(const Path: String); virtual;
    procedure Relocate(const Path: String); virtual;

    property StorageType: TStorageType read GeStorageType;
    function GetStorageDefinition: String; inline;
    function IsValid: Boolean; virtual; abstract;

    property Path: String read FPath;
    property AbsolutePath: String read FAbsolutePath;

    function OpenForRead: boolean; virtual;
    function OpenForWrite: boolean; virtual;
    procedure Close; virtual;

    function ExistsFile (const Path: String; const Name: String): Boolean; virtual; abstract;

    function SaveFile (const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean; virtual; abstract;
    function DeleteFile (const Path: String; const Name: String): Boolean; virtual; abstract;
    function Save (SaveAllImages: boolean= false): integer;
    procedure RegisterInLogFile (Strs: TStrings); virtual;

    function GetImageStream (const Path: String; const Name: String): TMemoryStream; virtual; abstract;          // Caller must free stream
  end;


//---------------------------------------------------------------------
//   TZipStorage
//---------------------------------------------------------------------

  TZipStorage = class(TFilesStorage)
  private
    fZip: TZipFile;
    fZipDeleted: TZipFile;
    fDeletedImagesZipFile: String;

  strict protected
    function GeStorageType: TStorageType; override;
    function CreateZipFile (const Path: String): boolean;

  public
    constructor Create(const Path: String); override;
    procedure Relocate(const Path: String); override;
    destructor Destroy; override;

    class function IsValidZip (const Path: string): Boolean;
    function IsValid: Boolean; override;
    function ZipDeletedIsValid: Boolean;

    function CreateImagesZipFile: boolean;
    function CreateDeletedZipFile: boolean;
    function OpenForRead: boolean; override;
    function OpenForWrite: boolean; override;
    procedure Close; override;

    function ExistsFile(const Path: String; const Name: String): Boolean; override;

    function SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String;
                      CompresionMethod: TZipCompression = zcStored): Boolean; override;
    function DeleteFile(const Path: String; const Name: String): Boolean; override;
    function AddToDeletedZip(const Stream: TMemoryStream; const Path: String; const Name: String;
                      CompresionMethod: TZipCompression = zcStored): Boolean;

    function GetImageStream(const Path: String; const Name: String): TMemoryStream; override;
  end;


//---------------------------------------------------------------------
//   TFolderStorage
//---------------------------------------------------------------------

  TFolderStorage = class(TFilesStorage)
  private
    fNotOwned: boolean;

  strict protected
    function GeStorageType: TStorageType; override;

  public
    constructor Create(const Path: String); override;
    procedure Relocate(const Path: String); override;

    function IsValid: Boolean; override;
    function ExistsFile(const Path: String; const Name: String): Boolean; override;


    function SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String;
                      CompresionMethod: TZipCompression = zcStored): Boolean; override;
    function DeleteFile(const Path: String; const Name: String): Boolean; override;

    function GetImageStream(const Path: String; const Name: String): TMemoryStream; override;

    function GetImagePath(const Path: String; const Name: String): string;
  end;


//---------------------------------------------------------------------
//   TEmbeddedKNTStorage
//---------------------------------------------------------------------

  TEmbeddedKNTStorage = class(TFilesStorage)

  strict protected
    function GeStorageType: TStorageType; override;

  public
    function IsValid: Boolean; override;

    function ExistsFile(const Path: String; const Name: String): Boolean; override;
    function SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean; override;
    function DeleteFile(const Path: String; const Name: String): Boolean; override;

    function GetImageStream(const Path: String; const Name: String): TMemoryStream; override;
  end;





//---------------------------------------------------------------------
//  TKntImage
//---------------------------------------------------------------------

  TKntImage = class
  private
    FID: Integer;
    FName: String;          // File name
    FPath: String;          // Path of the file. Together with Name identifies the file in Storage
    FCaption: String;
    FOwned: boolean;
    FReferenceCount: Integer;
    FMustBeSavedExternally: Boolean;

    procedure SetImageStream (Stream: TMemoryStream);
    procedure FreeImageStream;
    procedure SetAccessed;
    function GetDetails: string;

  strict private
    FImageFormat: TImageFormat;
    FCRC32: DWORD;
    FOriginalPath: String;
    FWidth: Integer;
    FHeight: Integer;
    FImageStream: TMemoryStream;
    FLastAccessed: TDateTime;

    function GetName: String;
    function GetPath: String;
    function GetFileName: String;
    function GetImageStream: TMemoryStream; overload;
    function GetImageStreamAvailable: boolean;

  public
    constructor Create(ID: Integer;
                       const OriginalPath: String;
                       Owned: boolean;
                       ImageFormat: TImageFormat;
                       Width, Height: integer;
                       crc_32: DWORD;
                       ReferenceCount: Integer;
                       Stream: TMemoryStream= nil
                       );

    destructor Destroy; override;

    procedure GenerateName(Node: TNoteNode; Note: TTabNote; const Source: string; ZipPathFormat: boolean);

    property ID: Integer read FID;
    property ImageFormat: TImageFormat read FImageFormat;
    property Name: String read GetName;
    property Path: String read GetPath;
    property Caption: string read FCaption write FCaption;
    property CRC32: DWORD read FCRC32;
    property OriginalPath: String read FOriginalPath;
    property IsOwned: boolean read FOwned;
    property FileName: String read GetFileName;

    property Width: integer read FWidth;
    property Height: integer read FHeight;
    procedure SetDimensions(Width, Height: integer);

    property ImageStream: TMemoryStream read GetImageStream;
    property ImageStreamAvailable: boolean read GetImageStreamAvailable;

    property ReferenceCount: Integer read FReferenceCount;
    property LastAccessed: TDateTime read FLastAccessed;
    property MustBeSavedExternally: boolean read FMustBeSavedExternally write FMustBeSavedExternally;

    property Details: string read GetDetails;
    function ImageDefinition: String; inline;
  end;



//---------------------------------------------------------------------
//  TImageManager
//---------------------------------------------------------------------

  TImageManager = class

  strict private

    fStorageMode : TImagesStorageMode;
    fExternalStorageToRead:  TFilesStorage;
    fExternalStorageToSave:  TFilesStorage;              //  = fExternalStorageToRead, salvo cuando se est� cambiando a un almacenamiento externo distinto
    fNotOwnedStorage: TFolderStorage;                    // Permite acceder a las im�genes Linked (not owned)
    fWasInformedOfStorageNotAvailable: Boolean;

    fFileIsNew: boolean;                                          // Is New => Not saved yet
    fIntendedExternalStorageType: TImagesExternalStorage;
    fIntendedStorageLocationPath: string;
    fChangingImagesStorage: boolean;
    fSaveAllImagesToExtStorage: boolean;

    // Si <> nil => se utilizar� para recuperar los Stream de las im�genes que aparezcan referenciadas con sus IDs en los nodos de la
    // nota indicada (se usar� para notas concretas, en combinaci�n con NoteFile.UpdateImagesStorageModeInFile (fStorageMode, ApplyOnlyToNote)
    fExternalImagesManager: TImageManager;

    fImagesMode: TImagesMode;
    fImages: TList;                             // All images (TKntImage)
    fNextImageID: Integer;
    fNextTempImageID: Integer;
    fLastCleanUpImgStreams: TDateTime;

    fExportingMode: boolean;
    fImagesIDExported: TList;


    function GetNewID(): Integer;
    procedure SerializeEmbeddedImages(const tf: TTextFile);
    procedure SetExportingMode(Value: boolean);

    function GetExternalStorageType: TImagesExternalStorage;
    function GetExternalStorageLocation: string;
    function GetExternalStorageIsMissing: boolean;


  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure SetInitialValues;
    procedure Clear (SetIniValues: boolean= true; ClearImages: boolean = true);

    property StorageMode: TImagesStorageMode read fStorageMode;
    property ExternalStorageType: TImagesExternalStorage read GetExternalStorageType;
    property ExternalStorageLocation: string read GetExternalStorageLocation;
    property ExternalStorageIsMissing: boolean read GetExternalStorageIsMissing;

    property  ChangingImagesStorage: boolean read fChangingImagesStorage;
    procedure ConversionStorageMode_End;
    function  PrepareImagesStorageToSave(const FN: string): boolean;
    procedure SetInitialImagesStorageMode (StorageMode: TImagesStorageMode; ExternalStorageType: TImagesExternalStorage);
    function  SetImagesStorage (StorageMode: TImagesStorageMode; ExternalStorageType: TImagesExternalStorage; Path: string;
                                CreateExternalStorageOnNewFile: boolean= false;
                                ExternalStorageRelocated: boolean= false): boolean;
    procedure AdaptPathFormatInImages (ZipPathFormat: boolean);
    function GetDefaultExternalLocation (ExtType: TImagesExternalStorage; FN: string= ''): string;
    property FileIsNew: boolean read fFileIsNew write fFileIsNew;


    property Images: TList read fImages;
    property ImagesMode: TImagesMode read fImagesMode write fImagesMode;            // See TTabNote.ImagesMode  ==> ImagesManager.ProcessImagesInRTF
    property NextTempImageID: Integer read fNextTempImageID;

    function CheckRegisterImage (Stream: TMemoryStream; ImgFormat: TImageFormat;
                                 Width, Height: integer;
                                 Note: TTabNote;
                                 const OriginalPath: String;
                                 Owned: boolean;
                                 const Source: String;
                                 var Img: TKntImage
                                 ): boolean;

    function RegisterNewImage (Stream: TMemoryStream;
                               ImageFormat: TImageFormat;
                               Width, Height: integer;
                               crc32: DWORD;
                               const OriginalPath: String;
                               Owned: boolean;
                               const Source: String;
                               Note: TTabNote
                               ): TKntImage;

    function GetImageFromStream (Stream: TMemoryStream; var CRC32: DWORD; SetLastAccess: boolean= true): TKntImage;
    function GetImageFromID (ImgID: integer; SetLastAccess: boolean= true): TKntImage; overload;
    function GetImageFromFileName (const FileName: string; SetLastAccess: boolean= true): TKntImage; overload;
    function GetPrevImage (ImgID: integer; SetLastAccess: boolean= true): TKntImage;
    function GetNextImage (ImgID: integer; SetLastAccess: boolean= true): TKntImage;
    function GetImagePath (Img: TKntImage): string;

    procedure ReloadImageStream (Img: TKntImage);
    procedure CheckFreeImageStreamsNotRecentlyUsed;

    procedure InsertImage (FileName: String; Note: TTabNote; Owned: boolean);
    procedure InsertImageFromClipboard (Note: TTabNote; TryAddURLlink: boolean = true);

    function ProcessImagesInRTF (const RTFText: AnsiString; Note: TTabNote;
                                 ImagesModeDest: TImagesMode;
                                 const Source: string;
                                 FirstImageID: integer= 0;
                                 ExitIfAllImagesInSameModeDest: boolean= false
                                 ): AnsiString; overload;

    function ProcessImagesInRTF (const Buffer: Pointer; BufSize: integer; Note: TTabNote;
                                 ImagesModeDest: TImagesMode;
                                 const Source: string;
                                 FirstImageID: integer;
                                 var ImgIDsCorrected: TImageIDs;
                                 var ContainsImages: boolean;
                                 ExitIfAllImagesInSameModeDest: boolean = false
                                 ): AnsiString; overload;
                                 
    procedure ProcessImagesInClipboard(Editor: TRxRichEdit; Note: TTabNote; SelStartBeforePaste: integer; FirstImageID: integer= 0);
    procedure ReplaceCorrectedImageIDs (ImgCodesCorrected: TImageIDs; Editor: TRxRichEdit);

    procedure ResetAllImagesCountReferences;
    procedure RemoveImagesReferences (const IDs: TImageIDs);
    function  GetImagesIDInstancesFromRTF (Stream: TMemoryStream): TImageIDs;
    function  GetImagesIDInstancesFromTextPlain (TextPlain: AnsiString): TImageIDs;
    procedure UpdateImagesCountReferences (const IDsBefore: TImageIDs;  const IDsAfter: TImageIDs);
    function  ImageInCurrentEditors (ImgID: integer): Boolean;


    procedure LoadState (const tf: TTextFile; var FileExhausted: Boolean);
    procedure SaveState (const tf: TTextFile);
    procedure DeleteOrphanImages();
    procedure SerializeImagesDefinition  (const tf: TTextFile);
    procedure SaveEmbeddedImages (const tf: TTextFile);

    property  ExportingMode: boolean read fExportingMode write SetExportingMode;
    procedure SaveStateInExportingMode (const tf: TTextFile);
    procedure RegisterImagesReferencesExported (const IDs: TImageIDs);

    property ExternalImagesManager: TImageManager read fExternalImagesManager write fExternalImagesManager;

    procedure OpenImageFile(FilePath: string);
    procedure OpenImageViewer (ImgID: integer; ShowExternalViewer: boolean; SetLastFormImageOpened: boolean);
  end;




//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------

implementation

uses  System.DateUtils,
      WinApi.MMSystem,
      ComCtrls95,
      CRC32,
      gf_misc,
      gf_strings,
      kn_ClipUtils,
      kn_info,
      kn_Main,
      kn_Global,
      kn_TreeNoteMng,
      kn_RTFUtils,
      kn_LinksMng,
      kn_VCLControlsMng,
      kn_ImageForm;




//==========================================================================================
//                                         TFilesStorage
//==========================================================================================

constructor TFilesStorage.Create(const Path: String);
begin
  inherited Create;
  Relocate(Path);
end;

procedure TFilesStorage.Relocate(const Path: String);
begin
  FPath:= Path;
  if assigned(NoteFile) then
     FAbsolutePath := GetAbsolutePath(NoteFile.File_Path, Path)
  else
     FAbsolutePath := '';
end;


function TFilesStorage.GetStorageDefinition: String;
begin
//  <ALM>: SD= Type (Zip/Folder)| Path

   Result:= Format('%s=%d|%s',  [_StorageDEF,  Ord(StorageType), Path])
end;


function TFilesStorage.OpenForRead: boolean;
begin
   Result:= IsValid;
end;

function TFilesStorage.OpenForWrite: boolean;
begin
   Result:= IsValid;
end;


procedure TFilesStorage.Close;
begin
end;


function TFilesStorage.Save (SaveAllImages: boolean= false): integer;
var
   i, j: Integer;
   Img: TKntImage;
   Images: TList;
   Strs: TStrings;
   CompressionMethod: TZipCompression;
   ImgStream: TMemoryStream;
   MaxSavedImgID: integer;
begin
   { Browse all images added and not yet saved. Some of them may have subsequently been marked for deletion.
     At that time it is not removed from this list (FImagesToSave) in anticipation of it being rolled back based on the use of the UNDO mechanism.
     Now, when saving, we check if they are still marked for deletion. If so, they will be removed from both lists and of course not saved to disk.
   }
   Images:= ImagesManager.Images;

   MaxSavedImgID:= 0;

   Strs:= TStringList.Create;
   OpenForWrite;
   try
      for i := 0 to Images.Count -1 do begin
          try
             Img := TKntImage(Images[i]);
             if not Img.IsOwned then begin
                if Img.ID > MaxSavedImgID then
                   MaxSavedImgID:= Img.ID;
               continue;
             end;

             if not SaveAllImages and not Img.MustBeSavedExternally then continue;

             if Img.ReferenceCount = 0 then begin
                Img.FreeImageStream;
                Img.Free;
                Images[i]:= nil;
             end
             else begin
                CompressionMethod:= KeyOptions.ImgDefaultCompression;
                if Img.ImageFormat= imgJpg then
                   CompressionMethod:= zcStored;

                ImgStream:= Img.ImageStream;
                ImgStream.Position := 0;
                if SaveFile(ImgStream, Img.Path, Img.Name, CompressionMethod) then begin
                   Img.MustBeSavedExternally:= False;
                   Strs.Add(FormatDateTime('dd/MMM/yyyy HH:nn - ', Now) + 'Added:   ' + Img.ImageDefinition);
                   if Img.ID > MaxSavedImgID then
                      MaxSavedImgID:= Img.ID;
                end;
             end;

          except
          end;
      end;

      for i := Images.Count -1 downto 0 do begin
         Img := TKntImage(Images[i]);
         if Img = nil then
            Images.Delete(i);
      end;


      if Strs.Count > 0 then
         RegisterInLogFile (Strs);

   finally
      Close;
      Strs.Free;
   end;

   Result:= MaxSavedImgID;

end;


procedure TFilesStorage.RegisterInLogFile (Strs: TStrings);
var
  str, LogFN: string;
begin
   str:= Strs.Text;
   LogFN:= FAbsolutePath + IMG_LOG_FILE;

   if not FileExists(LogFN) then
      TFile.WriteAllText(LogFN, 'PD= IDImg|Path|Name|Format(GIF,PNG,JPG,BMP,TIF,WMF,EMF)|Width|Height|crc32|OriginalPath|Owned|RefCount|Caption|MustBeSavedExt' + #13#10#13#10);

   TFile.AppendAllText(LogFN, str, TEncoding.UTF8);
end;



//=====================================================================
//  TZipStorage
//=====================================================================

constructor TZipStorage.Create(const Path: String);
begin
  inherited Create (Path);
  try
     fZip:= TZipFile.Create();
     fZipDeleted:= TZipFile.Create();

     Relocate (Path);

  except on E: Exception do
     MessageDlg( STR_16 + E.Message, mtError, [mbOK], 0 );
  end;
end;


procedure TZipStorage.Relocate(const Path: String);
var
   p: integer;
begin
  inherited Relocate (Path);

  fDeletedImagesZipFile:= FAbsolutePath;
  p := lastpos( '.', fDeletedImagesZipFile );
  if ( p > 2 ) then begin
     delete( fDeletedImagesZipFile, p, length(fDeletedImagesZipFile));
     fDeletedImagesZipFile:= fDeletedImagesZipFile + 'Deleted.zip';
  end
  else
      fDeletedImagesZipFile:= '';
end;


destructor TZipStorage.Destroy;
begin
   if assigned(fZip) then
      fZip.Free;
   if assigned(fZipDeleted) then
      fZipDeleted.Free;

   inherited Destroy;
end;


function TZipStorage.GeStorageType: TStorageType;
begin
  Result:= stZIP;
end;

class function TZipStorage.IsValidZip (const Path: string): Boolean;
begin
   Result:= FileExists(Path) and TZipFile.IsValid(Path);
end;


function TZipStorage.IsValid: Boolean;
begin
   Result:= FileExists(FAbsolutePath) and fZip.IsValid(FAbsolutePath);
end;

function TZipStorage.ZipDeletedIsValid: Boolean;
begin
   Result:= FileExists(fDeletedImagesZipFile) and fZip.IsValid(fDeletedImagesZipFile);
end;


function TZipStorage.OpenForRead: boolean;
begin
   if fZip.Mode = zmRead then exit (true);

   if fZip.Mode <> zmClosed then
      fZip.Close;

   Result:= false;
   try
      if IsValid then begin
         fZip.Open(FAbsolutePath, zmRead);
         Result:= true;
      end;
   except
   end;
end;

function TZipStorage.OpenForWrite: boolean;
begin
   if fZip.Mode = zmReadWrite then exit (true);

   if fZip.Mode <> zmClosed then
      fZip.Close;

   Result:= false;
   try
      if IsValid then begin
         fZip.Open(FAbsolutePath, zmReadWrite);
         Result:= true;
      end;
   except
   end;
end;

procedure TZipStorage.Close;
begin
   fZip.Close;
end;


function TZipStorage.CreateImagesZipFile: boolean;
begin
    Result:= CreateZipFile (FAbsolutePath);
end;

function TZipStorage.CreateDeletedZipFile: boolean;
begin
    Result:= CreateZipFile (fDeletedImagesZipFile);
end;


function TZipStorage.CreateZipFile (const Path: String): boolean;
begin
   Result:= false;
   try
      if not FileExists(Path) then begin
         fZip.Open(Path, zmWrite);
         fZip.Close;
         Result:= true;
      end;
   except
   end;
end;



//https://en.delphipraxis.net/topic/3328-delphi%E2%80%99s-tzipfile-working-on-a-stream/

function TZipStorage.ExistsFile(const Path: String; const Name: String): Boolean;
begin
   Result:= fZip.IndexOf(Path + Name) >= 0;
end;

function TZipStorage.GetImageStream(const Path: String; const Name: String): TMemoryStream;
var
  LocalHeader: TZipHeader;
  Stream: TStream;
  FN: string;
begin
  Result:= TMemoryStream.Create;
  try
     FN:= Path + Name;                     // Use / instead of \
     fZip.Read(FN, Stream, LocalHeader);
     Result.CopyFrom(Stream, 0);

  except on E: Exception do
     FreeAndNil(Result);
  end;
end;

function TZipStorage.SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean;
begin
  Result:= false;
  try
    fZip.Add(Stream, Path + Name, CompresionMethod);
    Result:= true;

  except on E: Exception do
     MessageDlg( STR_17 + E.Message, mtError, [mbOK], 0 );
  end;
end;


function TZipStorage.DeleteFile(const Path: String; const Name: String): Boolean;
begin
  try
    fZip.Delete(Path + Name);
    Result:= true;
  except
    Result:= false;
  end;
end;


function TZipStorage.AddToDeletedZip(const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean;
begin
    if (fDeletedImagesZipFile = '') or (Stream = nil) then exit(false);

    if not ZipDeletedIsValid then begin
       if not CreateDeletedZipFile then
          exit(false);
    end;

   try
      fZipDeleted.Open(fDeletedImagesZipFile, zmReadWrite);
      Stream.Position := 0;
      fZipDeleted.Add(Stream, Path + Name, CompresionMethod);
      fZipDeleted.Close;
   except
   end;


end;


//=====================================================================
//  TFolderStorage
//=====================================================================

constructor TFolderStorage.Create(const Path: String);
begin
  inherited Create (Path);
  fNotOwned:= false;
  Relocate(Path);
end;

procedure TFolderStorage.Relocate(const Path: String);
begin
  inherited Relocate (Path);
  if (FAbsolutePath.Length > 1) and (FAbsolutePath[FAbsolutePath.Length] <> '\') then
     FAbsolutePath:= FAbsolutePath + '\';
end;


function TFolderStorage.GeStorageType: TStorageType;
begin
  Result:= stFolder;
end;

function TFolderStorage.IsValid: Boolean;
begin
  if fNotOwned then exit (true);

  Result:= TDirectory.Exists(FAbsolutePath);
end;


function TFolderStorage.ExistsFile(const Path: String; const Name: String): Boolean;
begin
    Result:= FileExists(FAbsolutePath + Path + Name);
end;

function TFolderStorage.GetImageStream(const Path: String; const Name: String): TMemoryStream;
var
   FilePath: String;
begin
    Result:= TMemoryStream.Create;
    try
       FilePath:= GetImagePath(Path, Name);
       Result.LoadFromFile(FilePath);
    except
       FreeAndNil (Result);
    end;
end;


function TFolderStorage.GetImagePath(const Path: String; const Name: String): string;
var
   FilePath: String;
begin
   FilePath:= Path + Name;
   if fNotOwned then
      FilePath:= GetAbsolutePath(NoteFile.File_Path, FilePath)
   else
      FilePath:= FAbsolutePath + FilePath;

   Result:= FilePath;
end;


function TFolderStorage.SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean;
var
  AbsolutePath: string;
begin
   if fNotOwned then exit (false);

   { If it cannot be saved because the folder corresponding to the storage is not available, or exists
     some problem in its access, the image will be temporarily saved in the KNT embedded storage}

    Result:= false;
    if IsValid then begin
       AbsolutePath:= FAbsolutePath + Path;              // Path:  *inside* the Storage
       if ForceDirectories (AbsolutePath) then begin
          try
             Stream.SaveToFile(AbsolutePath + Name);
             Result:= true;
          except
          end;
       end;
    end;

end;


function TFolderStorage.DeleteFile(const Path: String; const Name: String): Boolean;
var
   FileName, RecFolder: string;
begin
    Result:= false;
    if fNotOwned then exit;

   if IsValid then begin
      FileName:= FAbsolutePath + Path + Name;
      if KeyOptions.ImgUseRecycleBin then begin
         RecFolder:= FAbsolutePath + '_RecycleBin\';
         if ForceDirectories (RecFolder) then
            Result:= MoveFileExW_n (FileName, RecFolder + Name, 3)
      end
      else
         Result:= System.SysUtils.DeleteFile(FileName);
   end;

end;


//=====================================================================
//  TEmbeddedStorage
//=====================================================================


function TEmbeddedKNTStorage.GeStorageType: TStorageType;
begin
  Result:= stEmbeddedKNT;
end;

function TEmbeddedKNTStorage.IsValid: Boolean;
begin
   Result:= true;
end;

function TEmbeddedKNTStorage.ExistsFile(const Path: String; const Name: String): Boolean;
begin
   Result:= True;
end;


function TEmbeddedKNTStorage.GetImageStream(const Path: String; const Name: String): TMemoryStream;
begin
   // This method should not be called, since the images (TKntImages) must have and maintain the Stream
   Result:= nil;
end;

function TEmbeddedKNTStorage.SaveFile(const Stream: TMemoryStream; const Path: String; const Name: String; CompresionMethod: TZipCompression = zcStored): Boolean;
begin
    Result:= true;
end;

function TEmbeddedKNTStorage.DeleteFile(const Path: String; const Name: String): Boolean;
begin
    Result:= true;
end;



//==========================================================================================
//                                         TKNTImage
//==========================================================================================


constructor TKntImage.Create(ID: Integer;
                             const OriginalPath: String;
                             Owned: boolean;
                             ImageFormat: TImageFormat;
                             Width, Height: integer;
                             crc_32: DWORD;
                             ReferenceCount: Integer;
                             Stream: TMemoryStream= nil
                             );
begin
   inherited Create;

   FMustBeSavedExternally:= False;

   FID:= ID;
   FImageFormat:= ImageFormat;
   FWidth:= Width;
   FHeight:= Height;
   FOriginalPath:= OriginalPath;
   FOwned:= Owned;
   FReferenceCount:= ReferenceCount;
   FImageStream:= Stream;

   if crc_32 <> 0 then
      FCRC32:= crc_32
   else
      if Stream <> nil then
         CalcCRC32(Stream.Memory, Stream.Size, FCRC32);
end;


destructor TKntImage.Destroy;
begin
   if assigned(FImageStream) then
      FImageStream.Free;

   inherited Destroy;
end;


{ Generates a Name and Path for a new image, unique in the storage, and taking into account that it has been created on the indicated node/note  }

procedure TKntImage.GenerateName(Node: TNoteNode; Note: TTabNote; const Source: string; ZipPathFormat: boolean);
var
  src: String;
begin
    if not fOwned then exit;

    if FOriginalPath <> '' then
       FName:= Format('%d_%s', [ID, ExtractFilename(FOriginalPath)])

    else begin
       if Source = '' then
          src:= 'Image'
       else
          src:= Source;

       FName:= Format('%d_%s_%s%s', [ID, src, FormatDateTime( 'ddMMM', Now), IMAGE_FORMATS[FImageFormat] ]);
    end;
    FPath:= MakeValidFileName( Note.Name, [' '], MAX_FILENAME_LENGTH );
    if ZipPathFormat then
       FPath:= FPath + '/'
    else
       FPath:= FPath + '\'

end;


function TKntImage.GetName: String;
begin
   if fOwned then
      Result:= FName
   else
      Result:= ExtractFilename(FOriginalPath);
end;


function TKntImage.GetPath: String;
begin
   if fOwned then
      Result:= FPath
   else
      Result:= ExtractFilePath(FOriginalPath);
end;


function TKntImage.GetFileName: String;
begin
   if not fOwned then
      Result:= FOriginalPath
   else
      if FPath <> '' then
         Result:= FPath + FName
      else
         Result:= FName;
end;


procedure TKntImage.SetDimensions(Width, Height: integer);
begin
    FWidth:= Width;
    FHeight:= Height;
end;


function TKntImage.ImageDefinition: String;
var
  path, name: string;
begin
   { <IMG1>:
     PD= IDImg|Path|Name|ImageFormat|Width|Height|crc32|OriginalPath|Owned|ReferenceCount|Caption|MustBeSavedExternally
   }
   if fOwned then begin
      path:= Self.Path;
      name:= Self.Name;
   end;

   Result:= Format('%s=%d|%s|%s|%d|%d|%d|%s|%s|%s|%d|%s|%s',
               [_ImageDEF,  ID, path, name, Ord(ImageFormat), FWidth, FHeight, FCRC32.ToString,
                OriginalPath, BOOLEANSTR[FOwned], ReferenceCount, FCaption, BOOLEANSTR[FMustBeSavedExternally]]);
end;


function TKntImage.GetDetails: string;
var
  location: string;
  sizeKB: String;
begin
   //  MyFile.png | MyPath | 9.0 KB | 120x25 PNG ....

   if fOwned then begin
      location:= Name;
      if Path <> '' then
         location:= location + ' | ' + Path;
      if OriginalPath <> '' then
         location:= location + ' [ ' + OriginalPath + ' ]';
   end
   else
      location:= OriginalPath;

   if ImageStream <> nil then
      SizeKB:= SimpleRoundTo(fImageStream.Size/1024, -1).ToString
   else
      SizeKB:= '-- ';

   Result:= Format('%s | %s KB | %d x %d %s', [location, SizeKB, FWidth,FHeight,IMAGE_FORMATS[ImageFormat].ToUpper ]);

   if ReferenceCount <> 1 then
      Result:= Result + Format(STR_09, [ReferenceCount]);

end;


function TKntImage.GetImageStreamAvailable: boolean;
begin
   Result:= assigned(FImageStream);
end;


{ Returns the image content in the original format.
-> CALLER should not modify or release the stream }

function TKntImage.GetImageStream: TMemoryStream;
begin
   if FImageStream = nil then
      ImagesManager.ReloadImageStream(Self);

   Result:= FImageStream;
end;

procedure TKntImage.SetImageStream (Stream: TMemoryStream);
begin
   FImageStream:= Stream;
end;

procedure TKntImage.SetAccessed;
begin
   FLastAccessed:= Now;
end;

procedure TKntImage.FreeImageStream;
begin
   if assigned(FImageStream) then
      FreeAndNil(FImageStream);
end;




//==========================================================================================
//                                   TImageManager
//==========================================================================================

//----------------------------------
//          Creation / Destruction
//----------------------------------

{ Not created as Singleton because for the MergeFromKNTFile functionality we need to have a
  TImageManager object that manages the file to be merged. }

constructor TImageManager.Create;
begin
  inherited Create;

  fImages:= TList.Create;
  fNotOwnedStorage:= TFolderStorage.Create('');
  fNotOwnedStorage.fNotOwned:= True;
  fExternalImagesManager:= nil;
  fImagesIDExported:= nil;

  if (RichEditVersion <= 4) then
     KeyOptions.ImgFormatInsideRTF:= ifWmetafile8;

  SetInitialValues;
end;


destructor TImageManager.Destroy;
var
   i: Integer;
begin
   Clear;

   fImages.Free;
   fNotOwnedStorage.Free;
   if fExternalImagesManager <> nil then
      fExternalImagesManager.Free;

   if fImagesIDExported  <> nil then
      fImagesIDExported.Free;

   inherited Destroy;
end;

procedure TImageManager.SetInitialValues;
begin
   fImagesMode:= imImage;
   fStorageMode:= smEmbRTF;
   fLastCleanUpImgStreams:= Now;
   fWasInformedOfStorageNotAvailable:= false;
   fNextImageID:= 1;
   fNextTempImageID:= 1;
   fExportingMode:= false;
   fChangingImagesStorage:= false;
   fFileIsNew:= true;
   fIntendedExternalStorageType:= issFolder;
   fIntendedStorageLocationPath:= '';
end;


procedure TImageManager.Clear (SetIniValues: boolean= true; ClearImages: boolean = true);
var
  i: integer;
  Img: TKntImage;
begin
   if (fExternalStorageToSave <> fExternalStorageToRead) and (fExternalStorageToSave <> nil) then
      FreeAndNil(fExternalStorageToSave);

   fExternalStorageToSave:= nil;

   if assigned(fExternalStorageToRead) then
      FreeAndNil(fExternalStorageToRead);

   if clearImages then begin
      for i := 0 to fImages.Count-1 do begin
         Img:= TKntImage(fImages[i]);
         Img.FreeImageStream;
         Img.FID:= -1;
         Img.Free;
      end;
      fImages.Clear;
   end;

   if SetIniValues then
     SetInitialValues;
end;


procedure TImageManager.SetExportingMode(Value: boolean);
begin
  if fExportingMode = Value then exit;

  fExportingMode:= Value;

  if fExportingMode then
     fImagesIDExported:= TList.Create
  else
    if fImagesIDExported  <> nil then
       fImagesIDExported.Free;

end;


//-----------------------------------------
//      SAVE KNT -> SAVE IMAGES AND STATE
//-----------------------------------------


procedure TImageManager.SerializeImagesDefinition(const tf: TTextFile);
var
   Img: TKntImage;
   i: integer;
begin

   { *1
   We will copy the definition of those images that at this point are still in the list even with ReferenceCount = 0.
   This must be because they could not be deleted from the external storage as it is not available.
   They will be removed from there, and also from the list of definitions, when they become available.
   }

   for i := 0 to fImages.Count-1 do begin
     Img:= TKntImage(fImages[i]);
     //if Img.ReferenceCount > 0 then      // *1

     if fExportingMode and (fImagesIDExported.IndexOf(Pointer(Img.ID)) < 0) then
        continue;

     tf.WriteLine(Img.ImageDefinition(), true);
   end;
end;


{ Serializes the images that must remain embedded in the KNT file }

procedure TImageManager.SerializeEmbeddedImages(const tf: TTextFile);
var
   Img: TKntImage;
   ImgStream: TMemoryStream;
   i, NumImagesToBeSavedExternally: integer;
   OnlyImagesToBeSavedExternally: boolean;
   onlyStr: string;
begin

{
  %EI
  EI=IDImage|FileName|size
  <--imagen en binario-->
  ##END_IMAGE##
  EI=IDImage|FileName|size
  ....
}
   NumImagesToBeSavedExternally:= 0;

   { We can keep in the image definition section some that need to be deleted, but that could not be deleted from its external storage.
     We will keep them there until we manage to delete them, but we should not keep them in embedded images, among other things because
     we will not have their Stream }
   // TODO: n� of retries

   OnlyImagesToBeSavedExternally:= true;
   if ExportingMode or (fStorageMode = smEmbKNT) or (fStorageMode = smExternalAndEmbKNT)  then
      OnlyImagesToBeSavedExternally:= false;


   for i := 0 to fImages.Count-1 do begin
     Img:= TKntImage(fImages[i]);
     if not Img.FOwned then continue;
     if OnlyImagesToBeSavedExternally and not Img.MustBeSavedExternally  then continue;
     if Img.ReferenceCount = 0 then continue;

     if fExportingMode and (fImagesIDExported.IndexOf(Pointer(Img.ID)) < 0) then
        continue;


     if Img.MustBeSavedExternally then
        Inc(NumImagesToBeSavedExternally);

     ImgStream:= Img.ImageStream;
     tf.WriteLine(Format('%s=%d|%s|%d', [_EmbeddedImage, Img.ID, Img.FileName, ImgStream.Size]), true);
     ImgStream.Position := 0;
     tf.Write(ImgStream.Memory^, ImgStream.Size);
     tf.Write(_CRLF);
     tf.WriteLine(_END_OF_EMBEDDED_IMAGE, False);
   end;

   if (not ExportingMode) and (NumImagesToBeSavedExternally > 0) and not fWasInformedOfStorageNotAvailable then begin
      MessageDlg(STR_05, mtWarning, [mbOK], 0);
      fWasInformedOfStorageNotAvailable:= true;
   end;
end;


procedure TImageManager.SaveState(const tf: TTextFile);
var
   MaxSavedImgID: integer;
   ModeUseExternalStorage: boolean;

   procedure UpdateMaxSavedImgID;
   var
      i: integer;
      Img: TKntImage;
   begin
      MaxSavedImgID:= 0;
      for i := 0 to Images.Count -1 do begin
         Img := TKntImage(Images[i]);
         if Img.ReferenceCount = 0 then continue;
         if Img.ID > MaxSavedImgID then
            MaxSavedImgID:= Img.ID;
      end;
   end;

begin
   if ExportingMode then begin
      SaveStateInExportingMode(tf);
      exit;
   end;

   if fStorageMode = smEmbRTF then exit;

   ModeUseExternalStorage:= (fStorageMode = smExternal) or (fStorageMode = smExternalAndEmbKNT);

   tf.WriteLine(_NF_StoragesDEF);
   tf.WriteLine(_StorageMode + '=' + IntToStr(Ord(fStorageMode)));
   if ModeUseExternalStorage and (fExternalStorageToSave <> nil) then begin
      tf.WriteLine(fExternalStorageToSave.GetStorageDefinition(), true);
      MaxSavedImgID:= FExternalStorageToSave.Save (fSaveAllImagesToExtStorage);
      if MaxSavedImgID + 1 > fNextImageID then
         fNextImageID:= MaxSavedImgID + 1;
      fNextTempImageID:= fNextImageID;
   end
   else begin
      UpdateMaxSavedImgID;
      fNextImageID:= MaxSavedImgID + 1;
      fNextTempImageID:= fNextImageID;
   end;


   // Get the information to be saved about the images
   tf.WriteLine(_NF_ImagesDEF);
   tf.WriteLine(_IDNextImage + '=' + IntToStr(fNextImageID));
   SerializeImagesDefinition(tf);

end;


procedure TImageManager.SaveEmbeddedImages(const tf: TTextFile);
begin
   if ExportingMode and (KeyOptions.ImgStorageModeOnExport <> smeEmbKNT) then exit;

   // Images that, due to some problem, could not be saved externally (as configured) will also be saved.
   tf.WriteLine(_NF_EmbeddedIMAGES);
   SerializeEmbeddedImages(tf);

   if not ExportingMode then begin
     fFileIsNew:= false;
     fIntendedStorageLocationPath:= '';
   end;
end;


procedure TImageManager.SaveStateInExportingMode(const tf: TTextFile);
var
   i: Integer;
   MaxSavedImgID: integer;
begin
   if not ExportingMode then exit;

   if KeyOptions.ImgStorageModeOnExport <> smeEmbKNT then exit;

   tf.WriteLine(_NF_StoragesDEF);
   tf.WriteLine(_StorageMode + '=' + IntToStr(Ord(smEmbKNT)));

   // Get the information to be saved about the images
   tf.WriteLine(_NF_ImagesDEF);
   tf.WriteLine(_IDNextImage + '=' + IntToStr(fNextImageID));
   SerializeImagesDefinition(tf);
end;



procedure TImageManager.DeleteOrphanImages();
var
  Img: TKntImage;
  i: integer;
  Strs: TStrings;
begin
   if ExportingMode then exit;

   // Delete the (previously) saved images with ReferenceCount=0

   Strs:= TStringList.Create;
   try
      for i := fImages.Count-1 downto 0 do begin
        Img:= TKntImage(fImages[i]);

        if (Img.ReferenceCount = 0) then begin
           if Img.MustBeSavedExternally then
              continue;    // It will be a temporary image, added and deleted before saving, it will be discarded from SaveState

           if Img.IsOwned and (StorageMode = smExternal) or (StorageMode = smExternalAndEmbKNT) then begin
              if KeyOptions.ImgUseRecycleBin and (fExternalStorageToSave.StorageType = stZip) then
                 TZipStorage(fExternalStorageToSave).AddToDeletedZip(Img.ImageStream, Img.Path, Img.Name);

               if fExternalStorageToSave.OpenForWrite then begin
                  fExternalStorageToSave.DeleteFile(Img.Path, Img.Name);
                  // Delete might fail if the file no longer exists, but we'll ignore it. OpenForWrite has worked, then storage is available
                  Strs.Add(FormatDateTime('dd/MMM/yyyy HH:nn - ', Now) + 'Deleted: ' + Img.ImageDefinition);
                  fImages.Delete(i);
                  Img.FreeImageStream;
                  Img.Free;
               end
               else
                  Img.FreeImageStream;
                  // We keep the image with ReferenceCount = 0 -> it will be deleted when external storage is available
           end
           else begin
              fImages.Delete(i);
              Img.FreeImageStream;
              Img.Free;
           end;
        end;
      end;

      if Strs.Count > 0 then
         fExternalStorageToSave.RegisterInLogFile (Strs);


   finally
      if assigned(fExternalStorageToSave) then
         fExternalStorageToSave.Close;

      Strs.Free;
   end;

end;


//-----------------------------------------
//      OPEN KNT -> LOAD IMAGES AND STATE
//-----------------------------------------

procedure TImageManager.LoadState(const tf: TTextFile; var FileExhausted: Boolean);
var
  s, key : AnsiString;
  ws: String;
  p, i: Integer;
  Error: Boolean;

  Path, Name, OriginalPath, FileName, Caption: String;
  Owned, MustBeSavedExternally: boolean;
  section: (sNone, sStoragesDef, sImagesDef, sEmbeddedImgs);

  Stream: TMemoryStream;
  Strs: TStrings;
  Storage: TFilesStorage;
  Img: TKntImage;
  ImageFormat: TImageFormat;
  Width, Height: integer;
  crc32: DWORD;
  IDImg: Integer;
  StorageType: TStorageType;
  Size: Integer;
  NumberOfInstances: Integer;
  MaxImageID: Integer;

begin
  section:= sStoragesDef;
  MaxImageID:= 0;
  FNextImageID:= -1;

  Strs:= TStringList.Create;

  try
    while ( not tf.eof()) do begin
       Error:= False;

       s:= tf.readln();

       if s = _NF_StoragesDEF then begin
          // Storages definition section begins
          section:= sStoragesDef;
          continue;
       end;
       if s = _NF_ImagesDEF then begin
          // Images definition section begins
          section:= sImagesDef;
          continue;
       end;
       if s = _NF_EmbeddedImages then begin
         // Embedded images section begins
         section:= sEmbeddedImgs;
         continue;
       end;
       if ( s = _NF_EOF ) then begin
         FileExhausted := true;
         break; // END OF FILE
       end;


       p := pos('=', s );
       if p <> 3 then continue;  // not a valid key=value format
       key := copy(s, 1, 2);
       delete(s, 1, 3);
       Strs.Clear;

       // Storages definition
       if section = sStoragesDef then begin
          if ( key = _StorageMode ) then
             FStorageMode := TImagesStorageMode(StrToInt( s ))

          else
          if key = _StorageDEF then begin
            // <Store>: SD= Tipo (Zip/Folder)|Path
             try
               Storage:= nil;
               ws:= TryUTF8ToUnicodeString(s);
               SplitString(Strs, ws, SEP, false);

               StorageType:=  TStorageType(StrToInt(Strs[0]));
               case StorageType of
                 stZIP:         FExternalStorageToRead:= TZipStorage.Create(Strs[1]);
                 stFolder:      FExternalStorageToRead:= TFolderStorage.Create(Strs[1]);
               end;

               FExternalStorageToSave:= FExternalStorageToRead;

             except
                On E : Exception do
                  MessageDlg(STR_01 + ws, mtError, [mbOK], 0);
             end;
            continue;
          end;
       end
       else
       // Images definition
       if section = sImagesDef then begin
          if ( key = _IDNextImage ) then
             FNextImageID := StrToInt( s )

          else
          if key = _ImageDEF then begin
            {
              <IMG>: PD= IDImg|Path|Name|ImageFormat|Width|Height|crc32|OriginalPath|Owned|ReferenceCount|Caption|MustBeSavedExternally
            }
             try
               ws:= TryUTF8ToUnicodeString(s);
               SplitString(Strs, ws, SEP, false);


               IDImg:= StrToInt(Strs[0]);
         		   Path:= Strs[1];
			         Name:= Strs[2];
               ImageFormat:= TImageFormat(StrToInt(Strs[3]));
               Width:=  StrToInt(Strs[4]);
               Height:= StrToInt(Strs[5]);
               crc32:= StrToUInt(Strs[6]);
       			   OriginalPath:= Strs[7];
               Owned:= Strs[8] = BOOLEANSTR[true];
			         NumberOfInstances:= StrToInt(Strs[9]);
               Caption:= Strs[10];
               MustBeSavedExternally:= Strs[11] = BOOLEANSTR[true];

               Img:= TKntImage.Create(IDImg, OriginalPath, Owned, ImageFormat, Width, Height, crc32, NumberOfInstances, nil);
               Img.FPath:= Path;
               Img.FName:= Name;
               Img.FCaption:= Caption;
               Img.FMustBeSavedExternally:= MustBeSavedExternally;

               FImages.Add(Pointer(Img));

               MaxImageID:= Max(MaxImageID, IDImg);

             except
                On E : Exception do
                  MessageDlg(STR_02 + ws + ' :' + E.Message , mtError, [mbOK], 0);
             end;
            continue;
          end;
       end
       else
       // Embedded Images
       if section = sEmbeddedImgs then begin
          if key = _EmbeddedImage then begin
           {
            EI=IDImg|FileName|size
            <-- content image in binary-->
            ##END_IMAGE##
           }

             Stream:= TMemoryStream.Create;
             try
               ws:= TryUTF8ToUnicodeString(s);
               SplitString(Strs, ws, SEP, false);

               IDImg:= StrToInt(Strs[0]);
               FileName:= Strs[1];
			         Size:= StrToInt(Strs[2]);
               if tf.ReadToStream(Stream, Size) < Size then
                  Error:= True

               else begin
                  Img:= GetImageFromID(IDImg, false);
                  if Img <> nil then
                     Img.SetImageStream (Stream);
                  // else: the image is not referenced. We can ignore it. This must be an error  // ToDO: Save to some file and notify?

                  s:= tf.Readln;
                  s:= tf.Readln;
                  if s <> _END_OF_EMBEDDED_IMAGE then
                     Error:= True;
               end;

             except
                On E : Exception do begin
                  Error:= True;
                  MessageDlg(STR_03 + ws + ' :' + E.Message , mtError, [mbOK], 0);
                end;
             end;

             if Error then
                MessageDlg(STR_03 + ws, mtError, [mbOK], 0);

            continue;
          end;
       end;

    end;

  finally
     if assigned(Strs) then
        Strs.Free;

     if (FNextImageID < 0) or (FNextImageID <= MaxImageID) then
        FNextImageID:= MaxImageID + 1;
     FNextTempImageID:= FNextImageID;
     fFileIsNew:= false;
  end;
end;


//-----------------------------------------
//    CHANGE/SET - STORAGE MODE
//-----------------------------------------

procedure TImageManager.SetInitialImagesStorageMode(StorageMode: TImagesStorageMode; ExternalStorageType: TImagesExternalStorage);
begin
  fStorageMode:= StorageMode;
end;


function TImageManager.PrepareImagesStorageToSave (const FN: string): boolean;
begin
   if not fFileIsNew then exit (true);

   if (fIntendedStorageLocationPath = '') then
      fIntendedStorageLocationPath:= GetDefaultExternalLocation(fIntendedExternalStorageType, FN);

   Result:= SetImagesStorage(fStorageMode, fIntendedExternalStorageType, fIntendedStorageLocationPath, true);
end;


function TImageManager.SetImagesStorage(StorageMode: TImagesStorageMode; ExternalStorageType: TImagesExternalStorage; Path: string;
                                         CreateExternalStorageOnNewFile: boolean= false;
                                         ExternalStorageRelocated: boolean= false): boolean;
var
   AbsolutePath: String;
   CurrentStorageMode: TImagesStorageMode;
   ZipPathFormat: boolean;
   ok, ModifyPathFormat, OnlyRelocated, CreateExternalStorage: boolean;
   ExternalStoreTypeChanged: boolean;


   function CheckNewExternalStorage: boolean;
   begin
      Result:= false;

      if not fFileIsNew then begin
        if (fExternalStorageToRead <> nil) and not fExternalStorageToRead.IsValid then begin
           DoMessageBox(Format(STR_14, [AbsolutePath]), mtWarning, [mbOk], 0);
           exit;
        end;
      end;

      if ExternalStorageType = issFolder then begin
         if (TDirectory.Exists(AbsolutePath) and not TDirectory.IsEmpty(AbsolutePath)) or FileExists(AbsolutePath) then begin
            DoMessageBox(Format(STR_07, [AbsolutePath]), mtWarning, [mbOk], 0);
            exit;
         end;
      end
      else begin
         if TFile.Exists(AbsolutePath) then begin
            DoMessageBox(Format(STR_08, [AbsolutePath]), mtWarning, [mbOk], 0);
            exit;
         end;
      end;
      CreateExternalStorage:= true;
      Result:= true;
   end;

   function GetStorageType(extStorageType: TImagesExternalStorage): TStorageType;
   begin
        case extStorageType of
           issZip: Result:= stZip;
           issFolder: Result:= stFolder;
        end;
   end;

   function CheckRelocatedStorage: boolean;
   begin
      Result:= true;

      if ExternalStorageType = issFolder then begin
         if not TDirectory.Exists(AbsolutePath) or TDirectory.IsEmpty(AbsolutePath) then begin
            DoMessageBox(Format(STR_11, [AbsolutePath]), mtWarning, [mbOk], 0);
            Result:= false;
         end;
      end
      else begin
         if not TZipStorage.IsValidZip(Path) then begin
            DoMessageBox(Format(STR_12, [AbsolutePath]), mtWarning, [mbOk], 0);
            Result:= false;
         end;
      end;
   end;

   procedure CreateNewExternalStorage;
   begin
      if ExternalStorageType = issFolder then begin
         fExternalStorageToSave:= TFolderStorage.Create(Path);
         TDirectory.CreateDirectory(AbsolutePath);
      end
      else begin
         fExternalStorageToSave:= TZipStorage.Create(Path);
         TZipStorage(fExternalStorageToSave).CreateImagesZipFile;
      end;
      fSaveAllImagesToExtStorage:= true;
   end;

   procedure RefreshEditorInAllNotes;
   var
     i: integer;
     myNote: TTabNote;
   begin
     // In case they contain images that could not be located because the storage was moved

      for i := 0 to NoteFile.Notes.Count -1 do begin
         myNote := NoteFile.Notes[i];
         if not myNote.PlainText then begin
           myNote.EditorToDataStream;
           myNote.DataStreamToEditor;
         end;
      end;
   end;

begin
   Result:= false;
   if fChangingImagesStorage then exit;

   try
      ModifyPathFormat:= false;
      fSaveAllImagesToExtStorage:= false;
      OnlyRelocated:= false;
      CreateExternalStorage:= false;
      ExternalStoreTypeChanged:= (fExternalStorageToRead <> nil) and (fExternalStorageToRead.StorageType <> GetStorageType(ExternalStorageType));
      ok:= true;
      Path:= ExtractRelativePath(NoteFile.File_Path, Path);
      AbsolutePath:= GetAbsolutePath(NoteFile.File_Path, Path);
      if ExternalStorageType = issFolder then
         AbsolutePath:= AbsolutePath + '\';             // To be able to compare with fExternalStorageToRead.AbsolutePath

      if not fFileIsNew then begin                      // The storage mode of a previously saved file is being changed

         if fStorageMode = StorageMode then begin
            case StorageMode of
               smEmbRTF, smEmbKNT: exit;                // Nothing to do

               smExternal, smExternalAndEmbKNT: begin
                 if (not ExternalStoreTypeChanged) and ( (fExternalStorageToRead.AbsolutePath = AbsolutePath) or ExternalStorageRelocated ) then begin
                     if (fExternalStorageToRead.AbsolutePath = AbsolutePath) or (not CheckRelocatedStorage) then
                        exit
                     else begin
                        fExternalStorageToRead.Relocate(Path);
                        OnlyRelocated:= true;
                     end;
                 end
                 else begin
                    ok:= CheckNewExternalStorage;
                    ModifyPathFormat:= ExternalStoreTypeChanged;
                 end;
               end;
            end;

         end
         else begin
            case StorageMode of
               smEmbRTF, smEmbKNT: begin
                  ModifyPathFormat:= (fStorageMode in [smExternal, smExternalAndEmbKNT]) and (fExternalStorageToRead.StorageType = stZip);
                  if (not (fStorageMode in [smEmbKNT, smExternalAndEmbKNT])) and ExternalStorageIsMissing then begin
                     DoMessageBox(Format(STR_14, [AbsolutePath]), mtWarning, [mbOk], 0);
                     exit;
                  end;
               end;

               smExternal, smExternalAndEmbKNT:
                   if ((StorageMode = smExternal) and (fStorageMode = smExternalAndEmbKNT)) or
                      ((StorageMode = smExternalAndEmbKNT) and (fStorageMode = smExternal)) then begin
                      // It was External + [EmbKNT] and it is still External + [EmbKNT]. Has incorporated or removed the use of embKNT
                      if ExternalStorageIsMissing then begin
                         DoMessageBox(Format(STR_14, [AbsolutePath]), mtWarning, [mbOk], 0);
                         exit;
                      end;
                      ModifyPathFormat:= ((ExternalStoreTypeChanged) or (ExternalStorageType = issZip));
                      if (ExternalStoreTypeChanged) or (fExternalStorageToRead.AbsolutePath <> AbsolutePath) then begin  // Has it changed location and/or format (zip/folder)?
                         if (not ExternalStoreTypeChanged) and ExternalStorageRelocated then begin
                            ok:= CheckRelocatedStorage;
                            if ok then
                               fExternalStorageToRead.Relocate(Path);
                         end
                         else
                            ok:= CheckNewExternalStorage;              // => fExternalStorageToRead <> fExternalStorageToSave
                      end;
                   end
                   else begin
                      // Before it did not include External and now it does
                      ok:= CheckNewExternalStorage;
                      if ok then begin
                         fExternalStorageToRead:= fExternalStorageToSave;
                         ModifyPathFormat:= (ExternalStorageType = issZip);
                      end;
                   end;
            end;

         end;
      end
      else begin
         if not CreateExternalStorageOnNewFile then begin
            assert(fFileIsNew);
            fIntendedExternalStorageType:= ExternalStorageType;
            fIntendedStorageLocationPath:= Path;
         end
         else begin
            case StorageMode of
               smEmbRTF, smEmbKNT:;

               smExternal, smExternalAndEmbKNT: begin
                   ok:= CheckNewExternalStorage;
                   if ok then begin
                      fExternalStorageToRead:= fExternalStorageToSave;
                      ModifyPathFormat:= (ExternalStorageType = issZip);
                   end;
               end;
            end;
         end;

      end;

      if not ok then exit;
      if (not fFileIsNew) and not OnlyRelocated and (DoMessageBox(STR_13, mtConfirmation, [mbOK,mbCancel], 0) <> mrOK) then
         exit;


      Result:= true;

      if fFileIsNew and (fStorageMode= StorageMode) and (not CreateExternalStorageOnNewFile)  then
         exit;

      fStorageMode:= StorageMode;

      if OnlyRelocated then begin
         RefreshEditorInAllNotes;
         exit;
      end;


      fChangingImagesStorage:= true;

      if CreateExternalStorage then
         CreateNewExternalStorage;

      NoteFile.UpdateImagesStorageModeInFile (fStorageMode);


      if ModifyPathFormat then begin
         ZipPathFormat:= false;
         if assigned(fExternalStorageToSave) and (fExternalStorageToSave.StorageType= stZip) then
            ZipPathFormat:= true;

         AdaptPathFormatInImages(ZipPathFormat);
      end;

      DoMessageBox(Format(STR_15, [fImages.Count]), mtInformation, [mbOK]);

  except on E: Exception do
     MessageDlg( STR_16 + E.Message, mtError, [mbOK], 0 );
  end;
end;


procedure TImageManager.ConversionStorageMode_End();
begin
   case fStorageMode of
      smExternal, smExternalAndEmbKNT:
         if fExternalStorageToSave <> fExternalStorageToRead then begin
            fExternalStorageToRead.Free;
            fExternalStorageToRead:= fExternalStorageToSave;
         end;

     smEmbRTF:  Clear (false, true);
     smEmbKNT:  Clear (false, false);
   end;

   fChangingImagesStorage:= false;
   fSaveAllImagesToExtStorage:= false;
end;


//-----------------------------------------
//      STORAGE MANAGEMENT
//-----------------------------------------

function TImageManager.GetExternalStorageType: TImagesExternalStorage;
begin
 Result:= KeyOptions.ImgDefaultExternalStorage;

 if (fExternalStorageToSave <> nil) then begin
   case fExternalStorageToSave.StorageType of
       stFolder: Result:= issFolder;
       stZip:    Result:= issZIP;
   end;
 end
 else
    Result:= fIntendedExternalStorageType;

end;


function TImageManager.GetExternalStorageLocation: string;
begin
 Result:= '';

 if (fExternalStorageToSave <> nil) then
    Result:= fExternalStorageToSave.AbsolutePath
 else
    Result:= fIntendedStorageLocationPath;

 if (Result.Length > 1) and (Result[Result.Length] = '\') then
    Result:= Copy(Result, 1, Result.Length-1);
end;


function TImageManager.GetExternalStorageIsMissing: boolean;
begin
   Result:=  (fExternalStorageToRead <> nil) and not fExternalStorageToRead.IsValid;
end;


function TImageManager.GetDefaultExternalLocation (ExtType: TImagesExternalStorage; FN: string= ''): string;
begin
  if FN = '' then
     FN:= NoteFile.FileName;

  Result:= ExtractFilePath(FN) + ExtractFileNameNoExt(FN);
  if Result = '' then
     Result:= '<File path>\<FileName>';   // Fake path

  case ExtType of
    issZip:    Result:= Result + '_img.zip';
    issFolder: Result:= Result + '_img';
  end;

end;


//-----------------------------------------
//      IMAGES MANAGEMENT
//-----------------------------------------


function TImageManager.GetNewID(): Integer;
begin
   Result:= fNextTempImageID;
   Inc(fNextTempImageID);
end;


function TImageManager.GetImageFromStream (Stream: TMemoryStream; var CRC32: DWORD; SetLastAccess: boolean= true): TKntImage;
var
  Img: TKntImage;
  i: integer;
begin
   CalculateCRC32 (Stream.Memory, Stream.Size, CRC32);

   for i := fImages.Count-1 downto 0 do begin
     Img:= TKntImage(fImages[i]);

     if Img.CRC32 = CRC32 then begin
        if SetLastAccess then Img.SetAccessed;
        exit(Img);
     end;
   end;

   Result:= nil;
end;


function TImageManager.GetImageFromID (ImgID: integer; SetLastAccess: boolean= true): TKntImage;
var
  Img: TKntImage;
  i: integer;
begin
   Result:= nil;
   for i := fImages.Count-1 downto 0 do begin
     Img:= TKntImage(fImages[i]);

     if Img.ID = ImgID then begin
        if SetLastAccess then Img.SetAccessed;
        exit(Img);
     end;
   end;
end;


function TImageManager.GetNextImage (ImgID: integer; SetLastAccess: boolean= true): TKntImage;
var
  Img: TKntImage;
begin
   repeat
      Inc(ImgID);
      Img:= GetImageFromID (ImgID);
   until (Img <> nil) or (ImgID >= fNextTempImageID);
   Result:= Img;
end;

function TImageManager.GetPrevImage (ImgID: integer; SetLastAccess: boolean= true): TKntImage;
var
  Img: TKntImage;
begin
   repeat
      Dec(ImgID);
      Img:= GetImageFromID (ImgID);
   until (Img <> nil) or (ImgID <= 1);
   Result:= Img;
end;


function TImageManager.GetImageFromFileName (const FileName: string; SetLastAccess: boolean= true): TKntImage;
var
  Img: TKntImage;
  i: integer;
begin
   Result:= nil;
   for i := fImages.Count-1 downto 0 do begin
     Img:= TKntImage(fImages[i]);

     if String.Compare(Img.FileName, FileName, True) = 0 then begin
        if SetLastAccess then Img.SetAccessed;
        exit(Img);
     end;
   end;
end;


function TImageManager.GetImagePath (Img: TKntImage): string;
var
   Strg: TFilesStorage;

begin
    Result:= '';

    if Img.IsOwned then
       Strg:= fExternalStorageToRead
    else
       Strg:= fNotOwnedStorage;

    if not assigned(Strg) then exit;

    if (Strg.StorageType <> stFolder) then
       Result:= Strg.AbsolutePath
    else
       Result:= TFolderStorage(Strg).GetImagePath(Img.Path, Img.Name);
end;


procedure TImageManager.AdaptPathFormatInImages (ZipPathFormat: boolean);
var
  Img: TKntImage;
  i: integer;
  Src, Dst: Char;
begin
   if ZipPathFormat then begin
      Src:= '\';
      Dst:= '/';
   end
   else begin
      Src:= '/';
      Dst:= '\';
   end;

   for i := 0 to fImages.Count-1 do begin
     Img:= TKntImage(fImages[i]);
     if not Img.FOwned then continue;

     Img.FPath := StringReplace(Img.FPath, Src, Dst, [rfReplaceAll]);
   end;
end;



procedure TImageManager.ReloadImageStream (Img: TKntImage);
var
   i: integer;
   Strg: TFilesStorage;
   Stream: TMemoryStream;
begin
     if fExternalImagesManager <> nil then begin
        fExternalImagesManager.ReloadImageStream(Img);
        exit;
     end;


    if Img.IsOwned then
       Strg:= fExternalStorageToRead
    else
       Strg:= fNotOwnedStorage;

    if not assigned(Strg) then exit;

    Strg.OpenForRead;                                  // If it's already open, it won't open it again
    Stream:= Strg.GetImageStream(Img.Path, Img.Name);
    if Stream <> nil then begin
       Img.SetImageStream(Stream);
       Img.SetAccessed;
       exit;
    end;
end;

procedure TImageManager.CheckFreeImageStreamsNotRecentlyUsed;
var
  Img: TKntImage;
  i: integer;
  T: TDateTime;
begin

   if (fStorageMode <> smExternal) or (ExternalStorageIsMissing) then exit;

   T:= IncMinute(Now, -NUM_MIN_TO_FREE_ImageStreamsNotRecentlyUsed);
   if fLastCleanUpImgStreams > T then exit;

   try
      for i := 0 to fImages.Count-1 do begin
         Img:= TKntImage(fImages[i]);
         if Img.MustBeSavedExternally then continue;
         if Img.LastAccessed >= T then continue;
         if ImageInCurrentEditors (Img.ID) then
             continue;

         Img.FreeImageStream;
      end;

   finally
      fLastCleanUpImgStreams:= Now;
   end;

end;


function TImageManager.ImageInCurrentEditors (ImgID: integer): Boolean;
var
   i, j: integer;
   ImagesIDs: TImageIDs;
begin
    for i := 0 to NoteFile.NoteCount -1 do begin
       ImagesIDs:= NoteFile.Notes[i].ImagesInstances;
       for j := Low(ImagesIDs) to High(ImagesIDs) do begin
           if ImagesIDs[j] = ImgID then
               exit(true);
       end;
    end;
    Result:= false;
end;


//-----------------------------------------
//      IMAGES - Adding NEW images
//-----------------------------------------

function TImageManager.RegisterNewImage(
                                         Stream: TMemoryStream;
                                         ImageFormat: TImageFormat;
                                         Width, Height: integer;
                                         crc32: DWORD;
                                         const OriginalPath: String;
                                         Owned: boolean;
                                         const Source: String;
                                         Note: TTabNote
                                         ): TKntImage;
var
   Img: TKntImage;
   Path: string;
   Node: TNoteNode;
   ImgID: integer;
   ZipPathFormat: boolean;
   StreamIMG: TMemoryStream;

begin
   Node:= GetCurrentNoteNode;
   ImgID:= GetNewID();

   if not Owned and KeyOptions.ImgLinkRelativePath then
      Path:= ExtractRelativePath(NoteFile.File_Path, OriginalPath)
   else
      Path:= OriginalPath;

   if fExternalImagesManager <> nil then begin
      StreamIMG:= TMemoryStream.Create;
      StreamIMG.LoadFromStream(Stream);
   end
   else
      StreamIMG:= Stream;

   Img:= TKntImage.Create(ImgID, Path, Owned, ImageFormat, Width, Height, crc32, 0, StreamIMG);

   ZipPathFormat:= false;
   if (assigned(fExternalStorageToSave)) and (fExternalStorageToSave.StorageType= stZip) then
      ZipPathFormat:= true;

   Img.GenerateName(Node, Note, Source, ZipPathFormat);

   fImages.Add(Pointer(Img));
   if Owned and ((fStorageMode = smExternal) or (fStorageMode = smExternalAndEmbKNT)) then
      Img.MustBeSavedExternally:= true;

   Result:= Img;
end;



// Returns True if it has just been registered
function TImageManager.CheckRegisterImage (
                                           Stream: TMemoryStream;
                                           ImgFormat: TImageFormat;
                                           Width, Height: integer;
                                           Note: TTabNote;
                                           const OriginalPath: String;
                                           Owned: boolean;
                                           const Source: String;
                                           var Img: TKntImage
                                           ): boolean;
var
  crc32: DWORD;
begin
    Result:= false;          // No need to register

    Img:= GetImageFromStream (Stream, crc32);
    if (Img = nil) then begin
       Img:= RegisterNewImage(Stream, imgFormat, Width, Height, crc32, OriginalPath, Owned, Source, Note);
       Result:= True;        // Registered
    end;
end;



{ Explicit insertion of an image. Replaces the current method that relies on the use of the clipboard }

procedure TImageManager.InsertImage(FileName: String; Note: TTabNote; Owned: boolean);
var
  Stream: TMemoryStream;
  ImgFormat, ImgFormatDest: TImageFormat;
  Width, Height, WidthGoal, HeightGoal: integer;

  StrRTF: AnsiString;
  ImgID: integer;
  Img: TKntImage;
  StreamRegistered: boolean;

begin
  ImgID:= 0;
  ImgFormat:= imgUndefined;
  StreamRegistered:= False;

  Stream:= TMemoryStream.Create;
  try
     Stream.LoadFromFile(FileName);
     Stream.Position:= 0;

     if (fStorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
        ImgFormat:= GetImageFormat(Stream);
        StreamRegistered:= CheckRegisterImage (Stream, ImgFormat, Width, Height, Note, FileName, Owned, '', Img);
        ImgID:= Img.ID;
     end;

     Width:= -1;
     WidthGoal:= -1;
     StrRTF:= GetRTFforImageInsertion(ImgID, Stream, ImgFormat, Width, Height, WidthGoal, HeightGoal, True, StreamRegistered, true);

     if StreamRegistered then
        Img.SetDimensions(Width, Height);

     Note.Editor.PutRtfText(StrRTF, True);

  finally
     if not StreamRegistered then
        Stream.Free;
  end;

end;


procedure TImageManager.InsertImageFromClipboard(Note: TTabNote; TryAddURLlink: boolean = true);
var
  Stream: TMemoryStream;
  bmp: TBitmap;
  ImgFormat, ImgFormatDest: TImageFormat;
  Img: TKntImage;
  ImgID: integer;

  Width, Height, WidthGoal, HeightGoal: integer;

  p1, p2, p3: integer;
  HTMLText, SourceImg, TextAlt, StrRTF: AnsiString;
  TextURL: String;
  DefaultImageFormat_Bak: TImageFormat;

  Editor: TRxRichEdit;
  WasCopiedByKNT, StreamRegistered: boolean;
  Source: String;

begin
  // https://docwiki.embarcadero.com/RADStudio/Alexandria/en/Pasting_Graphics_from_the_Clipboard
  ImgID:= 0;
  ImgFormat:= imgUndefined;
  StreamRegistered:= false;

  if Note = nil then
     Note:= ActiveNote;

  Editor:= Note.Editor;

  if TryAddURLLink then begin
     HTMLText:= Clipboard.AsHTML;
     if HTMLText <> '' then begin
         p1:= Pos('<img ', HTMLText);
         if p1 > 0 then begin
              p2:= Pos('src="', HTMLText, p1);
              p3:= Pos('"', HTMLText, p2+5);
              SourceImg:= Copy(HTMLText, p2+5, p3-p2-5);
              p2:= Pos('alt="', HTMLText, p1);
              p3:= Pos('"', HTMLText, p2+5);
              TextAlt:= Copy(HTMLText, p2+5, p3-p2-5);
         end;
     end;
  end;

  Stream:= TMemoryStream.Create;

  bmp:= TBitmap.Create;
  try
     bmp.Assign(Clipboard);
     bmp.PixelFormat:= KeyOptions.ImgBmpPixelFormat;
     bmp.SaveToStream(Stream);

     Width:=  bmp.Width;
     Height:= bmp.Height;

     Stream.Position:= 0;

     WasCopiedByKNT:= ClipboardContentWasCopiedByKNT;
     if WasCopiedByKNT then
        ImgID:= LastCopiedIDImage;            // If <> 0 => We have copied this image from KNT and we had already registered it

     if (ImgID = 0) and (fStorageMode <> smEmbRTF) and (Note <> nil) then begin
        if _IS_CAPTURING_CLIPBOARD then
           Source:= 'ClipCap'
        else
           Source:= 'Clipb';

        ImgFormat:= imgBMP;
        ImgFormatDest:= KeyOptions.ImgDefaultFormatFromClipb;
        if SourceImg <> '' then begin                                         // Pasting from browser
           imgFormatDest:= imgJpg;
           Source := Source + 'WEB';
        end;

        ConvertStreamToImgFormatDest (Stream, ImgFormat, imgFormatDest);
        if (fStorageMode <> smEmbRTF) and NoteSupportsRegisteredImages then begin
           ImgFormat:= ImgFormatDest;
           StreamRegistered:= CheckRegisterImage (Stream, ImgFormatDest, Width, Height, Note, '', True, Source, Img);
           ImgID:=Img.ID;
        end;
     end;

     WidthGoal:= -1;

     StrRTF:= GetRTFforImageInsertion(ImgID, Stream, ImgFormat, Width, Height, WidthGoal, HeightGoal, True, StreamRegistered, WasCopiedByKNT);
     Editor.PutRtfText(StrRTF, True);


     if TryAddURLLink and (SourceImg <> '') then begin
         TextURL:= TryUTF8ToUnicodeString(TextAlt);
         TextURL:= ConvertHTMLAsciiCharacters(TextURL);
         Editor.SelText:= #13;
         Editor.SelStart:= Editor.SelStart + 1;
         InsertURL(SourceImg, TextURL, Note);
         if (Img <> nil) and StreamRegistered then
            Img.Caption:= TextURL;
     end;


  finally
     bmp.Free;
     if not StreamRegistered then
        Stream.Free;
  end;

end;



//------------------------------------------------------------------------------------------
//      IMAGES - Processing RTF - Conversion imLink / imImage - Registering new images
//------------------------------------------------------------------------------------------


{ Will only be called when it detects that the content on the clipboard was not copied by this application
 If it has been, there is no need to process the images, since they will already be adapted and with the
 hidden marks that have been precise }
procedure TImageManager.ProcessImagesInClipboard(Editor: TRxRichEdit; Note: TTabNote; SelStartBeforePaste: integer; FirstImageID: integer= 0);
var
  SelStartBak: integer;
  p1, p2: integer;
  RTFText, RTFTextOut: AnsiString;
  ImagesMode: TImagesMode;

begin
    p1:= SelStartBeforePaste;
    p2:= Editor.SelStart;
    SelStartBak:= p2;
    if p2 = Editor.TextLength then
       Inc(p2);

    Editor.SetSelection(p1, p2, true);
    RTFText:= Editor.RtfSelText;

    ImagesMode:= FImagesMode;
    RTFTextOut:= ProcessImagesInRTF(RTFText, Note, ImagesMode, 'Clipboard', FirstImageID);

    if RTFTextOut <> '' then
       Editor.PutRtfText(RTFTextOut,True,True);
end;


function TImageManager.ProcessImagesInRTF(const RTFText: AnsiString; Note: TTabNote;
                                          ImagesModeDest: TImagesMode;
                                          const Source: string;
                                          FirstImageID: integer= 0;
                                          ExitIfAllImagesInSameModeDest: boolean= false
                                          ): AnsiString;
var
   ImgIDsCorrected: TImageIDs;
   ContainsImages: boolean;
begin
   Result:= ProcessImagesInRTF(@RTFText[1], ByteLength(RTFText), Note, ImagesModeDest, Source, FirstImageID, ImgIDsCorrected, ContainsImages, ExitIfAllImagesInSameModeDest);
end;



// ---- ProcessImagesInRTF --------------------

{ If no images are found, '' will be returned
  If ExitIfAllImagesInSameModeDest and all images, if any, are in the same format, too, it is returned ''
  In all cases it is always indicated in ContainsImages if there are images, whether or not they have had to be processed, and they are
  in imImage (Pict..) or imLink mode 
}
function TImageManager.ProcessImagesInRTF(const Buffer: Pointer; BufSize: integer; Note: TTabNote;
                                          ImagesModeDest: TImagesMode;
                                          const Source: string;
                                          FirstImageID: integer;
                                          var ImgIDsCorrected: TImageIDs;
                                          var ContainsImages: boolean;
                                          ExitIfAllImagesInSameModeDest: boolean = false
                                          ): AnsiString;
var
  SelStartBak: integer;
  pIn, pOut,  pPict, pLinkImg, pRTFImageEnd, pID,pIDr: integer;
  pPatt1,pPatt2, pImgIni: integer;
  In_shppict: boolean;
  ImgRTF, RTFTextOut, ImgIDStr,StrAux: AnsiString;
  Stream: TMemoryStream;
  Width, Height, WidthGoal, HeightGoal: integer;
  ImgFormat, ImgFormatDest: TImageFormat;
  NBytes: integer;

  ImgID, ID: integer;
  Img: TKntImage;
  StreamRegistered, StreamNeeded, UseExtenalImagesManager, Owned: boolean;
  ImgIDwasPresent, IDcorrected, GetStream, MaintainWMF_EMF: boolean;
  ImageMode: TImagesMode;
  ImgCaption: string;
  RTFText: PAnsiChar;
  i, j: integer;

const
   beginIDImg = KNT_RTF_HIDDEN_MARK_L + KNT_RTF_HIDDEN_IMAGE;         // \'11I
   endIDImg = KNT_RTF_HIDDEN_MARK_R;                                  // \'12
   Lb = Length(beginIDImg);


   procedure CheckHiddenMarkInLink;
   var
     k: integer;
   begin
     { *1
      We are going to control a rare case: from imLink mode the user separated two images that did not have any separating
      character and that therefore appeared joined (although not internally). Depending on how you have positioned the cursor,
      it may be the case that white spaces are being interspersed between our hidden label and the hyperlink. (You could also
      enter other characters at that same point, but that is rarer and we will not control it. }
      k:= 1;
      while RTFTextOut[pOut-k] = ' ' do
          inc(k);
      pOut:= pOut-k + 1;
   end;


   procedure CheckHiddenMarkInImage;
   var
      k: integer;
      antBracket: boolean;
   begin
     // Rare case control but that could occur. See *1, above
      k:= 1;
      antBracket:= RTFTextOut[pOut-1] = '{';
      if antBracket then k:= 2;
      while RTFTextOut[pOut-k] = ' ' do
          inc(k);
      pOut:= pOut-k + 1;
      if antBracket then begin
         RTFTextOut[pOut]:= '{';
         inc(pOut);
      end;
   end;


begin
   ContainsImages:= false;

   StreamRegistered:= false;
   pRTFImageEnd:= -1;
   pIn:= 1;
   pOut:= 1;
   pPict:= -99;
   pLinkImg:= -99;
   pPatt1:= -99;
   pPatt2:= -99;
   In_shppict:= false;

   SetLength(ImgIDsCorrected, 0);

   RTFText:= PAnsiChar(Buffer);

   assert(Length(RTFText) <= BufSize );

   // fExtenalImagesManager <> nil : We are processing note images from a file we are merging (see MergeFromKNTFile)

   UseExtenalImagesManager:= (ImagesModeDest = imLink) and (fExternalImagesManager <> nil);
   StreamNeeded:=  (ImagesModeDest = imImage) or (fExternalImagesManager <> nil);


   if ExitIfAllImagesInSameModeDest then begin
      if fStorageMode <> smEmbRTF then        // If = smEmbRTF =>  fChangingImagesStorage=True
         MaintainWMF_EMF:= true;
      pPict:= pos('{\pict{', RTFText, pIn) -1;
      pLinkImg:= pos(KNT_IMG_LINK_PREFIX, RTFText, pIn) -1;
      if (pPict >= 0) or (pLinkImg >= 0) then
          ContainsImages:= true;

      if ImagesModeDest = imLink then begin
         if pPict = -1 then exit
      end
      else begin
         if pLinkImg = -1 then exit
      end;
   end;


   Stream:= TMemoryStream.Create;
   try
      try
         RTFTextOut:= '';
   (*
         RTFText:= '{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang3082{\fonttbl{\f0\fnil\fcharset0 Calibri;}} ' + #13#10 +
                   '{\*\generator Riched20 10.0.19041}\viewkind4\uc1' + #13#10 +
                   '\pard\sa200\sl276\slmult1\f0\fs22\lang10{\object\objemb{\*\objclass Excel.Sheet.12}\objw2400\objh735{\*\objdata ' + #13#10 +
                   '0105000011111111111111111' + #13#10 +
                   '}{\result{\pict{\*\picprop}\wmetafile8\picw2400\pich735\picwgoal2400\pichgoal735 '+ #13#10 +
                   '010009000003db08000006003806000000003806000026060f00660c574d464301000000000001'+ #13#10 +
                   '}}}\par IMAGEN1: '+ #13#10 +
                   '{\pict{\*\picprop}\wmetafile8\picw130\pich999\picwgoal4444\pichgoal735 '+ #13#10 +
                   '010009000003db08000006003806000000003806000026060f00660c574d464301000000000001'+ #13#10 +
                   '}\par IMAGEN EMF+WMF:'+ #13#10 +
                   '{\*\shppict{\pict{\*\picprop}\emfblip\picw130\pich999\picwgoal4444\pichgoal735 '+ #13#10 +
                   '010009000003db08000006003806000000003806000026060f00660c574d464301000000000001'+ #13#10 +
                   '}}{\*\nonshppict{\pict{\*\picprop}\wmetafile8\picw130\pich999\picwgoal4444\pichgoal735 '+ #13#10 +
                   '010009000003db08000006003806000000003806000026060f00660c574d464301000000000001'+ #13#10 +
                   '}}\par '+ #13#10 +
                   'BYE }';
          pIn:= 1;

        \v\'11I999999\'12\v0    -> 20 max (If necessary we can increase it)

        The hidden mark next to the image, seen in its RTF form, can be altered from how it was added:

          \v\'11I333\'12\v0{\*\shppict{\pict{\*\picprop}\emfblip
          \v\f0\fs20\lang1033\'11I333\'12\v0
          \pard\cf1\v\f0\fs20\lang1033\'11I333\'12\v0{\pict{...}\pngblip\
          \v\'11I333\'12\cf1\v0\lang1033{\pict ...

        But it seems that in all cases they are always necessarily kept together with the characters that make up the content.
        of the marker (\'11I333\'12 in example). What can happen is that other control characters are introduced within the
        hidden mark control characters.
        ...

           \v\'11I222\'12{\v0{\field{\*\fldinst{HYPERLINK ...
           \v\'11I-3\'12\v0 a{{\field{\*\fldinst{HYPERLINK "img:-
           {\cf0{\field{\*\fldinst{HYPERLINK "file: ...


       Note:
       When RTF content with images is saved to disk in imImage mode, the conversion made from imImage to imLink is
       the one saved. In this case the RTF constructed in this procedure is the saved one.
       An image will be saved in the form:

         \v\'11I9\'12\v0{\field{\*\fldinst{HYPERLINK "img:9,482,409"}}{\fldrslt{\ul\cf2\ul MAIN_NOTE\\9_sample.wmf}}}

       Notes/nodes edited in imLink mode (images not visible) will be saved exactly as those hyperlinks are interpreted by
       the editor. Thus, edited RTF expressions that include images will be saved as follows:

         \v\'11I9\'12{\v0{\field{\*\fldinst{HYPERLINK "img:9,482,409"}}{\fldrslt{\ul\cf2\ul MAIN_NOTE\\9_sample.wmf}}}}\v0

       Despite this alteration, subsequent conversion to imImage mode will be interpreted as expected:
         \v\'11I9\'12{\v0{\pict...}}\v0    ->    \v\'11I9\'12\v0{\pict..}

       (unedited notes/nodes are not altered)

   *)

         repeat
            if StreamRegistered then begin
               Stream:= TMemoryStream.Create;
               StreamRegistered:= False;
            end
            else
               Stream.Clear;

            Img:= nil;
            ImgID:= 0;
            ImgIDwasPresent:= false;
            IDcorrected:= false;

            if pPict = -99 then
               pPict:= pos('{\pict{', RTFText, pIn)-1;

            if pPict >= BufSize then
               pPict := -1;

            if pPict >= 0 then begin
                if (pPatt1 <> -1) and (pPatt1 < pPict) then begin
                   if pPatt1 < 0 then
                      pPatt1:= pos('\result{\pict{', RTFText, pIn)-1;
                   if (pPatt1 >= 0) and (pPatt1 < pPict) then begin
                      pIn:= pPatt1 + Length('\result{\pict{');
                      pPatt1:= -99;       // We will go back to look for another one. We have already 'consumed' this one
                      continue;
                   end;
                end;
                // {\*\shppict{\pict{.... }}{\*\nonshppict{\pict{.... }}     Usually in emfblip
                if (pPatt2 <> -1) and (pPatt2 < pPict) then begin
                   if pPatt2 < 0 then
                      pPatt2:= pos('{\*\shppict', RTFText, pIn)-1;
                   if (pPatt2 >= 0) and (pPatt2 < pPict) then begin
                      pPatt2:= -99;       // We will go back to look for another one. We have already 'consumed' this one
                      In_shppict:= true;
                   end;
                end;
            end;

            if (pLinkImg <> -1) and ((pLinkImg < pPict) or (pPict=-1)) then begin
               if pLinkImg < 0 then begin
                  pLinkImg:= pos(KNT_IMG_LINK_PREFIX, RTFText, pIn)-1;
                  if pLinkImg >= BufSize then
                     pLinkImg := -1;
               end;
            end;

            if (pPict = -1) and (pLinkImg = -1) then
               break;



            if (pLinkImg >= 0) and ((pLinkImg < pPict) or (pPict=-1)) then begin
               ImageMode:= imLink;                            // The image is in link mode
               pImgIni:= pLinkImg;
            end
            else begin
               ImageMode:= imImage;
               pImgIni:= pPict;
            end;
            NBytes:= pImgIni - pRTFImageEnd-1;                // Previous bytes to copy


            pID:= Pos(beginIDImg, RTFText, pIn);
            if (pID >= 1) and (pID < pImgIni) then begin
               pIDr:= Pos(endIDImg, RTFText, pID);                         // \v\'11I999999\'12\v0        pID: \'11I999999  pIDr: \'12      (Max-normal-: pIDr-pID=11) -> 12 ..
               if (pIDr >= 1) and ((pIDr-pID) <= 12) then begin
                  ImgIDStr:= Copy(RTFText, pID + Lb, (pIDr - pID) -Lb);
                  if TryStrToInt(ImgIDStr, ImgID) then
                     ImgIDwasPresent:= true;
               end;
            end;

            if (FirstImageID <> 0) and (ImgID = 0) then begin
               ImgID:= FirstImageID;
               FirstImageID:= 0;
            end;



            if RTFTextOut = '' then begin
               { If ImagesModeDest = imImage and the images come in Link mode, we will have to increase the length of the output string.
                 At the end we will adjust the length }
               SetLength(RTFTextOut, BufSize);
               {$IFDEF KNT_DEBUG}
               for var k: integer := 1 to BufSize do RTFTextOut[k]:= ' ';  //ZeroMemory(@RTFTextOut[1], BufSize);
               {$ENDIF}
            end;

            // Copy bytes previous to the image or link found
            if In_shppict then
               Dec(NBytes, Length('{\*\shppict'));
            Move(RTFText[pRTFImageEnd+1], RTFTextOut[pOut], NBytes);
            Inc(pOut, NBytes);


            Owned:= true;
            GetStream:= true;
            if ImgID <> 0 then begin

               if UseExtenalImagesManager then
                  Img:= fExternalImagesManager.GetImageFromID (ImgID)
               else
                  Img:= GetImageFromID (ImgID);

                if Img <> nil then begin
                   GetStream:= False;                     // We don't need RTFPictToImage to get the Stream from the content in the RTF
                   if StreamNeeded then
                      Stream:= Img.ImageStream;

                   ImgFormat:= Img.ImageFormat;
                   Width:= Img.Width;
                   Height:= Img.Height;
                   StreamRegistered:= true;
                end;


                if (Img = nil) or UseExtenalImagesManager then begin
                   { If UseExtenalImagesManager: We have only relied on it to obtain the Stream. The ID is not valid for us, it corresponds to the registration
                     in another file. If not, it must be a lost ID, which I should ignore. Maybe it's due to a deleted image
                     (after saving) and recovered in the editor by doing UNDO  }
                     // pID: \'11I999999  pIDr: \'12
                  if not UseExtenalImagesManager then begin
                     IDcorrected:= true;
                     SetLength(ImgIDsCorrected, Length(ImgIDsCorrected) + 2);
                     ImgIDsCorrected[Length(ImgIDsCorrected)-2]:= ImgID;
                  end;
                  ImgID:= 0;
                  if ImgIDwasPresent then begin
                     ImgIDwasPresent:= false;
                     ImgIDStr:= Copy(RTFText, pID, (pIDr - pID) + Length(endIDImg));
                     StrAux:= Copy(RTFText, pID, pImgIni - pID +1);
                     StrAux:= StringReplace(StrAux, ImgIDStr, '', []);
                     Move(StrAux[1], RTFTextOut[pOut - (pImgIni-pID+1)], pImgIni-pID +1);
                     Dec(pOut, Length(ImgIDStr));
                  end;
                end;
            end;


            if ImageMode = imLink then      // Imge is in link mode
               RTFLinkToImage (RTFText, pLinkImg, WidthGoal, HeightGoal, pRTFImageEnd )
            else
               RTFPictToImage (RTFText, pPict, Stream, ImgFormat, Width, Height, WidthGoal, HeightGoal, pRTFImageEnd, GetStream);

            //if fChangingImagesStorage and (fChangingImagesStorageFromMode = smEmbRTF) then
            //   CheckDimensionGoals (Width, Height, WidthGoal, HeightGoal);

            if (fStorageMode <> smEmbRTF) then begin
               if (ImgID = 0) and ((ImageMode = imImage) or UseExtenalImagesManager) and (Stream <> nil) and (Stream.Size > 0) and (Note <> nil) then begin
                  if Img <> nil then begin            // Processing images from MergeFromKNTFile
                    ImgCaption:= Img.Caption;
                    if CheckRegisterImage (Stream, Img.ImageFormat,  Width, Height, Note, Img.OriginalPath, Img.IsOwned, 'MergeKNT', Img) then begin
                       StreamRegistered:= true;
                       if ImgCaption <> '' then
                          Img.Caption:= ImgCaption;
                    end;
                    ImgID:= Img.ID;
                  end
                  else begin
                    ImgFormatDest := imgUndefined;
                    ConvertStreamToImgFormatDest (Stream, ImgFormat, imgFormatDest);
                    if Stream.Size > 0 then begin
                       ImgFormat:= ImgFormatDest;
                       if CheckRegisterImage (Stream, ImgFormatDest,  Width, Height, Note, '', true, Source, Img) then
                          StreamRegistered:= true;
                       ImgID:= Img.ID;
                    end;
                  end;
               end;
            end;

            if IDcorrected then begin
               ImgIDsCorrected[Length(ImgIDsCorrected)-1]:= ImgID;
            end;



            if ImgIDwasPresent and (ImagesModeDest = ImageMode) then begin
              { If ImagesMode = ImagesModeDest and the image is already registered, just copy it to the output string
                If the current mode is smEmbRTF and we are converting from a node with image registration (smEmbKNT, for example)
                we will have to remove the hidden ID marks anyway, we will do it later  }
                NBytes:= pRTFImageEnd - pImgIni +1;
                Move(RTFText[pImgIni], RTFTextOut[pOut], NBytes);
                Inc(pOut, NBytes);
            end
            else begin
                if (ImagesModeDest = imImage) and (Stream <> nil) and (Stream.Size > 0) then begin
                   if ImgIDwasPresent or (fStorageMode = smEmbRTF) then begin
                      ID:= 0;                                             // To not add the hidden tag from GetRTFforImageInsertion
                      if (fStorageMode <> smEmbRTF) then
                         CheckHiddenMarkInImage;
                   end
                   else
                      ID:= ImgID;
                   ImgRTF:= GetRTFforImageInsertion(ID, Stream, ImgFormat, Width, Height, WidthGoal, HeightGoal, False, StreamRegistered, MaintainWMF_EMF);
                   if ImageMode = imLink then
                      SetLength(RTFTextOut, Length(RTFTextOut) + Length(ImgRTF));

                end
                else begin
                  if Img = nil then begin                    // Image not included in the list of definitions (and we do not have its stream)
                     if IDcorrected then
                        ImgCaption:= STR_04 + 'Image ID=' + ImgIDsCorrected[Length(ImgIDsCorrected)-2].ToString
                     else
                        ImgCaption:= STR_04 + '?'
                  end
                  else
                     if (ImagesModeDest = imImage) then
                        ImgCaption:= STR_04 + Img.FileName
                     else begin
                        ImgCaption:= Img.Caption;
                        if ImgCaption = '' then ImgCaption:= Img.FileName;
                     end;


                  ImgRTF:= Format(KNT_IMG_LINK, [ImgID, WidthGoal, HeightGoal, URLToRTF(ImgCaption, true)]);         // {\field{\*\fldinst{HYPERLINK "img:%d:%d,%d}"}}{\fldrslt{\ul\cf1 %s}}}
                  if (fStorageMode <> smEmbRTF) and (ImgID <> 0) then begin
                      if not ImgIDwasPresent then     // The tag with the image ID was incorrect and had to be re-registered, or we are converting from smEmbRTF
                         ImgRTF:= Format(KNT_RTF_IMG_HIDDEN_MARK, [ImgID]) + ImgRTF
                      else
                         CheckHiddenMarkInLink;
                  end;

                  if ImageMode = imLink then
                     SetLength(RTFTextOut, Length(RTFTextOut) + Length(ImgRTF));     // The image in imLink format may be shorter than this one, which indicates Image not found..
                end;

                NBytes:= Length(ImgRTF);
                Move(ImgRTF[1], RTFTextOut[pOut], NBytes);
                Inc(pOut, NBytes);
            end;


            if In_shppict then begin
               pRTFImageEnd:= pos('}}', RTFText, pRTFImageEnd+1 +1); //-1;             '}}' corresponding to: {\*\nonshppict{\pict{
               //Inc(pRTFImageEnd);
               In_shppict:= false;
            end;

            if ImageMode = imLink then       // Image was in link mode
               pLinkImg:= -99                // We will go back to look for another one. We have already 'consumed' this one
            else
               pPict:= -99;                  // Idem

            pIn:= pRTFImageEnd + 1;

         until (pPict = -1) and (pLinkImg = -1);


         if (RTFTextOut <> '')  then begin
            if pIn < BufSize then begin
               NBytes:= BufSize-pIn +1;
               Move(RTFText[pIn], RTFTextOut[pOut], NBytes);
               Inc(pOut, NBytes);
            end;
            SetLength(RTFTextOut, pOut-2);

            ContainsImages:= true;
         end;

         Result:= RTFTextOut;

      except
        on E: Exception do
           MessageDlg( STR_20 + E.Message, mtError, [mbOK], 0 );
      end;


   finally
     if (fStorageMode = smExternal) and (fExternalStorageToRead <> nil) then          // It can be a new file
        fExternalStorageToRead.Close;

     if (not StreamRegistered) and (Stream <> nil) then
        Stream.Free;
   end;
end;



procedure TImageManager.ReplaceCorrectedImageIDs (ImgCodesCorrected: TImageIDs; Editor: TRxRichEdit);
var
    p, SS, SL, Offset: integer;
    CodInc, CodOk: integer;
    StrInc, StrOk: AnsiString;
    txtPlain: AnsiString;

begin
    txtPlain:= Editor.TextPlain;

    Offset:= 0;
    p:= 1;
    SS:= Editor.SelStart;
    SL:= Editor.SelLength;
    Editor.BeginUpdate;
    try
       for var i: integer := 0 to (Length(ImgCodesCorrected) div 2)-1 do begin
          CodInc:= ImgCodesCorrected[i];
          CodOk:=  ImgCodesCorrected[i+1];
          StrInc:= Format(KNT_RTF_IMG_HIDDEN_MARK_CHAR, [CodInc]);
          StrOk:= Format(KNT_RTF_IMG_HIDDEN_MARK_CHAR, [CodOk]);

          repeat
             p:= Pos(StrInc, txtPlain, p);
             if p > 0 then begin
                Editor.SetSelection(p + Offset, p + Offset + Length(StrInc)-1, true);
                if CodOK = 0 then begin
                   Editor.SelText := '';
                   StrOk:= '';
                end
                else
                   Editor.PutRtfText('{\rtf1\ansi ' + Format(KNT_RTF_IMG_HIDDEN_MARK, [CodOk]) + '}', true, true,  true);

                Inc(p, Length(StrInc));
                Inc(Offset, (Length(StrOk) - Length(StrInc)) );
             end;
          until p  = 0;

          Editor.SetSelection(SS, SS + SL, true);       // It might not be the exact situation, but it is a rare situation
       end;

    finally
       Editor.EndUpdate;
    end;

end;




//-----------------------------------------
//      IMAGES - Instances - ReferenceCount
//-----------------------------------------


procedure TImageManager.ResetAllImagesCountReferences;
var
  Img: TKntImage;
  i: integer;
begin
   for i := FImages.Count-1 downto 0 do begin
     Img:= TKntImage(FImages[i]);
     Img.FReferenceCount := 0;
   end;
end;


function TImageManager.GetImagesIDInstancesFromRTF (Stream: TMemoryStream): TImageIDs;
var
  pID,pIDr: integer;
  ImgID, Num: integer;
  Text: PAnsiChar;

const
   beginIDImg = KNT_RTF_HIDDEN_MARK_L + KNT_RTF_HIDDEN_IMAGE;         // \'11I
   endIDImg = KNT_RTF_HIDDEN_MARK_R;                                  // \'12
   Lb = Length(beginIDImg);

begin
    Result:= nil;

    pID:= 0;
    Num:= 0;
    Text:= PAnsiChar(Stream.Memory);

    repeat
       pID:= Pos(beginIDImg, Text, pID+1);
       if (pID > 0) and (pID < Stream.Size) then begin
          pIDr:= Pos(endIDImg, Text, pID);                             // \v\'11I999999\'12\v0        pID-> \'11I999999  pIDr-> \'12      (Max-normal-: pIDr-pID=11) -> 12 ..
          if (pIDr > 0) and ((pIDr-pID) <= 12) then begin
             if TryStrToInt(Copy(Text, pID + Lb, (pIDr - pID) -Lb), ImgID) then begin
                Inc(Num);
                SetLength(Result, Num);
                Result[Num-1]:= ImgID;
             end;
          end;
       end;

    until (pID = 0) or ((pID >= Stream.Size));

end;


function TImageManager.GetImagesIDInstancesFromTextPlain (TextPlain: AnsiString): TImageIDs;
var
  pID,pIDr: integer;
  ImgID, Num: integer;

const
   beginIDImg = KNT_RTF_HIDDEN_MARK_L_CHAR + KNT_RTF_HIDDEN_IMAGE;         // \'11I
   endIDImg = KNT_RTF_HIDDEN_MARK_R_CHAR;                                  // \'12
   Lb = Length(beginIDImg);

begin
   pID:= 0;
   Num:= 0;
   Result:= nil;

   repeat
      pID:= Pos(beginIDImg, TextPlain, pID+1);
      if pID > 0 then begin
         pIDr:= Pos(endIDImg, TextPlain, pID);                             // L1I999999R
         if (pIDr > 0) and ((pIDr-pID) <= 10) then begin
            if TryStrToInt(Copy(TextPlain, pID + Lb, (pIDr - pID) -Lb), ImgID) then begin
               Inc(Num);
               SetLength(Result, Num);
               Result[Num-1]:= ImgID;
            end;
         end;
      end;

   until pID = 0;

end;


procedure TImageManager.UpdateImagesCountReferences (const IDsBefore: TImageIDs;  const IDsAfter: TImageIDs);
var
   a, b, IDAfter, ID: integer;
   Img: TKntImage;
   _IDsBefore, _IDsAfter: TImageIDs;

begin
     _IDsBefore := IDsBefore;
     _IDsAfter := IDsAfter;
     SetLength(_IDsBefore, Length(IDsBefore));
     SetLength(_IDsAfter, Length(IDsAfter));

     for a := Low(_IDsAfter) to High(_IDsAfter) do begin
        IDAfter:= _IDsAfter[a];

         for b := Low(_IDsBefore) to High(_IDsBefore) do begin
            if IDAfter =  _IDsBefore[b] then begin
                _IDsAfter[a]:= 0;
                _IDsBefore[b]:= 0;
                break;
            end;
         end;
     end;

    // Added instances
    for a := Low(_IDsAfter) to High(_IDsAfter) do begin
        ID:= _IDsAfter[a];
        if ID <> 0 then begin
           Img:= GetImageFromID (ID);
           if Img <> nil then
              Inc(Img.FReferenceCount);
        end;
    end;

    // Deleted instances
    for b := Low(_IDsBefore) to High(_IDsBefore) do begin
        ID:= _IDsBefore[b];
        if ID <> 0 then begin
           Img:= GetImageFromID (ID);
           if Img <> nil then
              Dec(Img.FReferenceCount);
        end;
    end;

end;


procedure TImageManager.RemoveImagesReferences (const IDs: TImageIDs);
var
  i, ID: integer;
  Img: TKntImage;
begin
    for i := Low(IDs) to High(IDs) do begin
        ID:= IDs[i];
        if ID <> 0 then begin
           Img:= GetImageFromID (ID);
           if Img <> nil then                 // Could be nil if some image tag has been identified that we don't have in our list
              Dec(Img.FReferenceCount);
        end;
    end;
end;


procedure TImageManager.RegisterImagesReferencesExported (const IDs: TImageIDs);
var
  i, ID: integer;
begin
    for i := Low(IDs) to High(IDs) do begin
       ID:= IDs[i];
       if fImagesIDExported.IndexOf(Pointer(ID)) < 0 then
          fImagesIDExported.Add(Pointer(ID));
    end;
end;



//-----------------------------------------
//      IMAGE VIEWER
//-----------------------------------------


procedure TImageManager.OpenImageFile(FilePath: string);
var
  ShellExecResult: integer;

begin
  screen.Cursor := crAppStart;
  try
      ShellExecResult := ShellExecute( 0, 'open', PChar(FilePath), PChar(''), nil, SW_NORMAL );
  finally
      screen.Cursor := crDefault;
  end;

  if ( ShellExecResult <= 32 ) then begin
    if (( ShellExecResult > 2 ) or KeyOptions.ShellExecuteShowAllErrors ) then
      PopupMessage( Format(
        STR_10,
        [ShellExecResult, FilePath, TranslateShellExecuteError(ShellExecResult)] ), mtError, [mbOK], 0 );
  end
  else begin
    if KeyOptions.MinimizeOnURL then
       Application.Minimize;
  end;

end;


procedure TImageManager.OpenImageViewer (ImgID: integer; ShowExternalViewer: boolean; SetLastFormImageOpened: boolean);
var
  Form_Image, OpenedViewer: TForm_Image;
  Img: TKntImage;
  FilePath: string;
  UsingOpenViewer: boolean;

begin
   if ImgID = 0 then exit;

   try
      Img:= GetImageFromID(ImgID);
      if Img= nil then exit;

      if ShowExternalViewer then begin
         FilePath:= GetImagePath(Img);
         OpenImageFile(FilePath);
      end
      else begin
         ActiveNote.EditorToDataStream;

         UsingOpenViewer:= false;

         OpenedViewer:= ImgViewerInstance;
         if (OpenedViewer <> nil) and (KeyOptions.ImgSingleViewerInstance) then begin
            Form_Image:= OpenedViewer;
            UsingOpenViewer:= true;
         end
         else begin
            Form_Image := TForm_Image.Create( Form_Main );
            NewImageViewer(Form_Image);
         end;

         { We use kn_ImageForm.LastFormImageOpened to be able to give focus to the viewer from Form_Main.RxRTFMouseUp,
           since it is lost if we open the viewer by right-clicking on a link. But we do not want to lose focus on the
           main screen if KeyOptions.ImgSingleViewerInstance=True and the viewer had already been created previously
           (it was visible before clicking on the link) to, among others, favor being able to implement the
           ImgHotTrackViewer option. For this we look at ImgViewerInstance
         }
         if SetLastFormImageOpened and (OpenedViewer = nil) then
            kn_ImageForm.LastFormImageOpened:= Form_Image;
         Form_Image.Image:= Img;
         if not UsingOpenViewer then
            Form_Image.Show;
      end;

   except
     on E: Exception do
       MessageDlg( STR_18 + E.Message, mtError, [mbOK], 0 );
   end;
end;



initialization


end.