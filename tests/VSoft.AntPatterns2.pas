unit VSoft.AntPatterns2;

interface

uses
  Generics.Collections,
  VSoft.AntPatterns;

type
  TTestRec = record
    path : string;
    isDir : boolean;
    constructor Create(const APath : string; const AIsDir : boolean);
  end;

  TAntPattern2 = class(TAntPattern)
  private
    FFiles : TList<TTestRec>;
  protected
    // walk a 'virtual' file system.. not ideal as we're not really testing the walk function
    // but creating a virtual file system is just too much work for this simple lib!
    procedure Walk(const path: string; const walker: TWalkerFunc); override;
  public
    constructor Create(const rootDirectory : string; const files : TList<TTestRec>);
  end;

implementation

uses
  System.SysUtils;

{ TAntPattern }

constructor TAntPattern2.Create(const rootDirectory: string; const files: TList<TTestRec>);
begin
  inherited Create(rootDirectory);
  FFiles := files;;
end;

procedure TAntPattern2.Walk(const path: string; const walker: TWalkerFunc);
var
  skipWhileDir : string;
  fileRec : TTestRec;
begin
  skipWhileDir := '';
  for fileRec in FFiles do
  begin
    if skipWhileDir <> '' then
    begin
      if (not fileRec.isDir) and SameText(skipWhileDir, ExtractFilePath(fileRec.path)) then
        continue;

        skipWhileDir := '';
    end;

    if walker(fileRec.path, fileRec.isDir) then
      skipWhileDir := ExtractFilePath(fileRec.path);
  end;

end;

{ TTestRec }

constructor TTestRec.Create(const APath: string; const AIsDir: boolean);
begin
  path := APath;
  isDir := AIsDir;
end;

end.
