﻿unit gf_streams;

(****** LICENSE INFORMATION **************************************************
 
 - This Source Code Form is subject to the terms of the Mozilla Public
 - License, v. 2.0. If a copy of the MPL was not distributed with this
 - file, You can obtain one at http://mozilla.org/MPL/2.0/.           
 
------------------------------------------------------------------------------
 (c) 2000-2005 Marek Jedlinski <marek@tranglos.com> (Poland) [^1]
 (c) 2007-2015 Daniel Prado Velasco <dprado.keynote@gmail.com> (Spain) [^2]

 [^1]: Adapted from a set of routines by Ran Biron <Biron01@IBM.NET>
 [^2]: Changes since v. 1.7.0. Fore more information, please see 'README.md'
     and 'doc/README_SourceCode.txt' in https://github.com/dpradov/keynote-nf      
	 
 *****************************************************************************) 

{$I gf_base.inc}
 
(* 
 gf_streams - Streams handling routines
 
*)


interface
uses
   Winapi.Windows,
   System.Classes,
   System.SysUtils,
   gf_strings;

{$ALIGN OFF}

procedure SaveToFile(FN: string; Str: AnsiString);

procedure SaveStringToStream( S : AnsiString; Stream : TStream );
function LoadStringFromStream( Stream : TStream ) : Ansistring;
procedure SaveIntegerToStream( i : integer; Stream : TStream );
function LoadIntegerFromStream( Stream : TStream ) : Integer;
procedure SaveLongintToStream( i : integer; Stream : TStream );
function LoadLongintFromStream( Stream : TStream ) : longint;
procedure SaveFloatToStream( F : Real; Stream : TStream );
function LoadFloatFromStream( Stream : TStream ) : Real;
procedure SaveDateTimeToStream( TD : TDateTime; Stream : TStream );
function LoadDateTimeFromStream( Stream : TStream ) : TDateTime;
procedure SaveBLOBToStream( Dest, Source : TStream );
procedure LoadBLOBFromStream( Dest, Source : TStream );
procedure SaveBooleanToStream( B : Boolean; Stream : TStream );
function LoadBooleanFromStream( Stream : TStream ) : Boolean;

function NodeStreamIsRTF ( Stream : TMemoryStream ): boolean;
function NodeStreamIsUTF8_WithoutBOM (Stream : TMemoryStream; var NodeText: AnsiString): boolean; overload;
function NodeStreamIsUTF8_WithoutBOM ( Stream : TMemoryStream ): boolean; overload;
function NodeStreamIsUTF8WithBOM (Stream : TMemoryStream): boolean;
function AddUTF8_BOM ( Stream : TMemoryStream ): boolean;


type
  TTextFile = class           // ToDO: Replace the use of this class for TBufferedFileStream
  private
    fileName: string;
    buffer: PAnsiChar;
    bufSize: integer;
    posI, posF: integer;
  public
    F: TStream;
    constructor Create;
    destructor Destroy; Override;
    procedure AssignFile(const aFileName: string);
    procedure AssignStream(const stream: TStream);
    procedure Reset;
    procedure Rewrite;
    procedure Append;
    procedure CloseFile;
    function Readln: AnsiString;
    procedure WriteLn (const Args: array of const);
    procedure Write (const Buffer; Count: integer); overload;
    procedure Write (const Cad: AnsiString); overload;
    function Eof: boolean;
  end;


const
   UTF8_BOM = AnsiString(#$EF#$BB#$BF);


implementation



procedure SaveToFile(FN: String; Str: AnsiString);    // Better: IOUtils.TFile.WriteAllText(...)
var
  F : TTextFile;
begin
  F:= TTextFile.Create();
  F.Assignfile(FN );
  F.Rewrite;
  try
    F.Write(Str);
  finally
    F.Closefile();
  end;
end;


procedure SaveStringToStream( S : AnsiString; Stream : TStream );
var
 i : integer;
Begin
 i := Length( S );
 Stream.WriteBuffer( i, SizeOf( Integer ));
 if ( i > 0 ) then Stream.WriteBuffer( S[1], i );
End;

function LoadStringFromStream( Stream : TStream ) : AnsiString;
var
 i : integer;
begin
 Stream.ReadBuffer( i, SizeOf( Integer ));
 if ( i > 0 ) then
 begin
   SetLength( Result, i );
   Stream.ReadBuffer( Result[1], i );
 end
 else
   result := '';
End;

procedure SaveIntegerToStream( i : integer; Stream : TStream );
begin
 Stream.WriteBuffer( i, SizeOf( Integer ));
end;

function LoadIntegerFromStream( Stream : TStream ) : Integer;
Begin
 Stream.ReadBuffer( Result, SizeOf( integer ));
End;

procedure SaveLongintToStream( i : integer; Stream : TStream );
begin
  Stream.WriteBuffer( i, SizeOf( longint ));
end;

function LoadLongintFromStream( Stream : TStream ) : longint;
begin
  Stream.ReadBuffer( Result, SizeOf( longint ));
end;

procedure SaveFloatToStream( F : Real; Stream : TStream );
begin
 Stream.WriteBuffer( F, SizeOf( Real ));
End;

function LoadFloatFromStream( Stream : TStream ) : Real;
begin
  Stream.ReadBuffer( Result, SizeOf( Real ));
End;

function LoadDateTimeFromStream( Stream : TStream ) : TDateTime;
var
  r : real;
begin
  r := LoadFloatFromStream( Stream );
  result := r;
End;

procedure SaveDateTimeToStream( TD : TDateTime; Stream : TStream );
begin
  SaveFloatToStream( TD, Stream );
End;


procedure SaveBLOBToStream( Dest, Source : TStream );
var
 i : integer;
begin
 Source.Position := 0;
 i := Source.Size;
 Dest.write( i, SizeOf( Longint ));
 Dest.CopyFrom( Source, i );
end;

procedure LoadBLOBFromStream( Dest, Source : TStream );
var
 i : integer;
begin
 Source.read( i, SizeOf( Longint ));
 Dest.Size := i;
 Dest.CopyFrom( Source, i );
 Dest.Position := 0;
end;

procedure SaveBooleanToStream( B : Boolean; Stream : TStream );
begin
 Stream.WriteBuffer( B, SizeOf( Boolean ));
end;

function LoadBooleanFromStream( Stream : TStream ) : Boolean;
begin
 Stream.ReadBuffer( Result, SizeOf( Boolean ));
end;


function NodeStreamIsRTF ( Stream : TMemoryStream ): boolean;
var
    NodeText : AnsiString;
begin
    // From TForm_ExportNew.PerformExport:
    // <<now for some treachery. In KeyNote, a user can mark a note
    // as "plain text only". In such a node, all nodes are stored as
    // plain text, not RTF. However, the change from RTF to text (or
    // back) occurs only when a node is DISPLAYED. So, it is possible
    // that user enabled "plain text only", but some tree nodes have
    // not been viewed, hence are still in RTF. So, at this point
    // we cannot know if the node data we're about to export is RTF
    // or plain text data. Yet we must pass the correct information
    // to PutRichText. Which is why we must check manually, like so:

    Result:= False;
    if Stream.Size > 6 then begin
      // transfer stream contents to temp string
      SetLength( NodeText, 6 );
      move( Stream.Memory^, NodeText[1], 6 );
      Result := ( copy( NodeText, 1, 6 ) = '{\rtf1' );
    end;
end;


function NodeStreamIsUTF8_WithoutBOM (Stream : TMemoryStream; var NodeText: AnsiString): boolean;
var
    BOM: string[3];
    TextSize: integer;
    cad: AnsiString;
begin
    // Node is assumed to be plain text
    Result:= False;

    TextSize:= Stream.Size;
    if TextSize >= 3 then begin
       BOM:= Copy( PAnsiChar(Stream.Memory), 1, 3 );
       if BOM <> UTF8_BOM then begin
          SetLength( NodeText, TextSize );
          move( Stream.Memory^, NodeText[1], TextSize );
          cad:= Utf8ToAnsi(NodeText);                        //*** ¿Reemplazable por la función  CanSaveAsANSI()
          if (cad <> '') and (cad <> NodeText) then
             Result:= True;
       end;
    end;
end;


function NodeStreamIsUTF8WithBOM (Stream : TMemoryStream): boolean;
var
    BOM: string[3];
    TextSize: integer;
begin
    Result:= False;
    TextSize:= Stream.Size;
    if TextSize >= 3 then begin
       BOM:= Copy( PAnsiChar(Stream.Memory), 1, 3 );
       if BOM = UTF8_BOM then
          Result:= True;
    end;
end;


function NodeStreamIsUTF8_WithoutBOM ( Stream : TMemoryStream ): boolean;
var
    NodeText : AnsiString;
begin
    Result:= NodeStreamIsUTF8_WithoutBOM(Stream, NodeText);
end;

function AddUTF8_BOM ( Stream : TMemoryStream ): boolean;
var
    NodeText : AnsiString;
begin
    Result:= False;

    if NodeStreamIsUTF8_WithoutBOM(Stream, NodeText) then begin
       Stream.Position:= 0;
       if Stream.Position <> 0 then        //*** En Streams grandes (> 64Kb) no está funcionando Position:= 0, pero sí Seek ¿?
         Stream.Seek(0, soBeginning);


       Stream.Write(UTF8_BOM[1], length(UTF8_BOM));
       Stream.Write(NodeText[1], length(NodeText));
       Stream.Position:= 0;
       if Stream.Position <> 0 then        //*** En Streams grandes (> 64Kb) no está funcionando Position:= 0, pero sí Seek ¿?
         Stream.Seek(0, soBeginning);

       Result:= True;
    end;
end;


//===== TWTextFile

constructor TTextFile.Create;
begin
  posF:= 0;
end;

destructor TTextFile.Destroy;
begin
    if assigned(buffer) then begin
       FreeMem(buffer);
       buffer:= nil;
    end;
end;

procedure TTextFile.AssignFile(const aFileName: string);
begin
    if afileName = '' then
       raise Exception.CreateFmt( 'Error: Filename not specified', [''] );

    fileName:= aFileName;
    if assigned(F) then
       FreeAndNil(F);

    if assigned(buffer) then
       FreeMem(buffer);

    bufSize:= 1048576;  //1 MB
    GetMem(buffer, bufSize);
end;

procedure TTextFile.AssignStream(const stream: TStream);
begin
    if (fileName <> '') and assigned(F) then
       FreeAndNil(F);

    F:= stream;
    fileName := '';

    if assigned(buffer) then
       FreeMem(buffer);

    bufSize:= 4096;     //4Kb
    GetMem(buffer, bufSize);
end;

procedure TTextFile.Rewrite;
begin
    if assigned(F) then     //F will be a generic Stream, probably a TMemoryStream
       F.Position:= 0

    else begin
        if fileName = '' then
           raise Exception.CreateFmt( 'Error: Filename not specified', [''] )
        else
           F:= TFileStream.Create( fileName, ( fmCreate or fmShareExclusive ));
    end;

    posF:= 0;
end;

procedure TTextFile.Append;
begin
    CloseFile;

    if fileName = '' then
       raise Exception.CreateFmt( 'Error: Filename not specified', [''] )
    else
       F:= TFileStream.Create( fileName, ( fmOpenWrite or fmShareExclusive ));

    F.Seek(0, soEnd);
    posF:= 0;
end;


procedure TTextFile.Reset;
begin
    if assigned(F) then begin  //F will be a generic Stream, probably a TMemoryStream
       F.Position:= 0;
    end
    else begin
        if fileName = '' then
           raise Exception.CreateFmt( 'Error: Filename not specified', [''] )
        else
           F:= TFileStream.Create( fileName, ( fmOpenRead ));
    end;

    if F.Size = 0 then
       posF:= 0
    else begin
       posI:= bufSize;
       posF:= bufSize-1;
    end;
end;

procedure TTextFile.CloseFile;
begin
    if (fileName <> '') and assigned(F) then
       FreeAndNil(F);
end;

function TTextFile.Readln: AnsiString;
var
   i: integer;
   cad: AnsiString;
   lineReaden: boolean;
   nCrLf: integer;
begin

   Result:= '';
   if not assigned (F) or (posF=0) then exit;

   lineReaden:= false;
   nCrLf:= 0;
   repeat
     i:= posI;
     if i <= posF then begin
       while (not lineReaden) and (i <= posF) do begin
           if (buffer[i] = #13) or (buffer[i] = #10) then begin
              nCrLf:= nCrLf + 1;
              if buffer[i] = #10 then
                 lineReaden:= True;
           end;
           i:= i + 1;
       end;
       SetString(cad, PAnsiChar(@buffer[posI]), i-posI - nCrLf);
       Result:= Result + cad;
     end;

     if i <= posF then begin
        posI:= i;
     end
     else
        if F.Position < F.Size then begin
           posF:= F.Read(buffer[0], bufSize) -1;
           posI:= 0;
        end
        else begin
           lineReaden:= true;    // We have reached final of the file
           posF:= 0;
           end;

   until lineReaden;
end;

function TTextFile.Eof: boolean;
begin
   Result:= (posF = 0);
end;

{See: Variant Open Array Parameters}

procedure TTextFile.WriteLn (const Args: array of const);
var
  I: Integer;
  line: AnsiString;
  uline: string;
  lastParamWide: boolean;
  us: string;

  procedure checkToWrite (force: boolean = false);
  var
     S: RawByteString;
  begin
    if (uline <> '') and (not lastParamWide or force) then begin
        S:= UTF8Encode(uline);        //S:= WideStringToUTF8(wline);
        F.WriteBuffer(PAnsiChar(S)^, length(S));
        uline:= '';
    end;
    if (line <> '') and (lastParamWide or force) then begin
        F.WriteBuffer(PAnsiChar(line)^, length(line));
        line:= '';
    end;
  end;

begin
  if not assigned (F) then exit;

  for I := Low(Args) to High (Args) do begin
    lastParamWide:= False;
    case Args [I].VType of
      vtInteger:  line := line + IntToStr(Args [I].VInteger);
      vtChar:     line := line + Args [I].VChar;
      vtBoolean:  line := line + 'TRUE';   //Args [I].VBoolean;

      vtExtended:   line := line + FloatToStr(Args [I].VExtended^);
      vtInt64:      line := line + FloatToStr(Args [I].VInt64^);
      vtPChar:      line := line + PAnsiChar(Args [I].VPChar)^;
      vtString:     line := line + PShortString(Args [I].VString)^;
      vtAnsiString: line := line + AnsiString(Args [I].VAnsiString);
      vtWideChar:   begin
                    uline:= uline + Args [I].VWideChar;
                    lastParamWide:= true;
                    end;
      vtPWideChar,
      vtWideString:
             begin
                us:= WideString(Args [I].VPWideChar);
                if CanSaveAsANSI(us) then
                   line:= line + AnsiString(us)                   // To make it more compatible with older versions. Only use UTF8 if it's necessary
                else begin
                    uline:= uline + us;
                    lastParamWide:= true;
                end;
             end;

      vtUnicodeString:
             begin
                us:= UnicodeString(Args [I].VUnicodeString);
                if CanSaveAsANSI(us) then
                   line:= line + AnsiString(us)                   // To make it more compatible with older versions. Only use UTF8 if it's necessary
                else begin
                    uline:= uline + us;
                    lastParamWide:= true;
                end;
             end;

      vtCurrency:   line := line + CurrToStr(Args [I].VCurrency^);
    end; // case
    checkToWrite;
  end;
  line:= line + #13#10;
  checkToWrite (true);
end;

procedure TTextFile.Write (const Cad: AnsiString);
begin
   if not assigned (F) then exit;
   F.WriteBuffer(PAnsiChar(Cad)^, length(Cad));
end;

procedure TTextFile.Write (const Buffer; Count: integer);
begin
   if not assigned (F) then exit;
   F.WriteBuffer(Buffer, Count);
end;


end.
