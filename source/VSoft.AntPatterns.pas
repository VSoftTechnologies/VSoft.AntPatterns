unit VSoft.AntPatterns;

interface

uses
  Generics.Collections;

type
  IFileSystemPattern = interface
  ['{A7FC46D9-2FCE-4AF3-9D3B-82666C5C53B2}']
    function GetDirectory : string;
    function GetFileMask  : string;
    property Directory  : string read GetDirectory;
    property FileMask   : string read GetFileMask;
  end;


  TFileSystemPattern = class(TInterfacedObject, IFileSystemPattern)
  private
    FDirectory  : string;
    FFileMask   : string;
  protected
    function GetDirectory : string;
    function GetFileMask  : string;
  public
    constructor Create(const directory : string; const fileMask : string);
    property Directory  : string read GetDirectory;
    property FileMask   : string read GetFileMask;
  end;

  TWalkerFunc = reference to function (const path: string; const isDirectory: boolean): boolean;

  IAntPattern = interface
  ['{8271F607-C4CF-4E8E-8C73-1E44827C3512}']

 		/// <summary>
		/// Expands an 'Ant' style pattern into a series of FileSystem patterns
    /// that can easily be used for filecopy etc
		/// </summary>
		/// <param name="antPattern"></param>
		/// <returns>TArray of IFileSystemPattern</returns>
    function Expand(const antPattern : string) : TArray<IFileSystemPattern>;
    function ConvertAntToRegexString(const antPattern : string) : string;
  end;

  TAntPattern = class(TInterfacedObject, IAntPattern)
  private
    FRootDirectory : string;

  protected
    function IsRooted(const path : string) : boolean;
    function Combine(const root : string; pattern : string) : string;

    function NormalizeDirectorySeparators(const path : string) : string;


    /// <summary>
		/// Walk
		/// </summary>
		/// <param name="path"></param>
		/// <param name="walker">A func that is called for each file, the result is used to determine whether to continue checking files in the current dir.</param>
    procedure Walk(const path : string; const walker : TWalkerFunc);virtual;

    //IAntPattern
    function ConvertAntToRegexString(const antPattern : string) : string;
    function Expand(const antPattern : string) : TArray<IFileSystemPattern>;
  public
    constructor Create(const rootDirectory : string);

  end;

  /// <summary>
  /// Takes a path like 'c:\temp\foo\..\bar\test.txt' and
  ///  converts it to   'c:\temp\bar\test.txt'
  /// </summary>
  ///  Only public for testing
  function CompressRelativePath(const basePath : string; path : string) : string;


//exposed only for testing, do not use directly.
type
  TAntStringSplitOptions = (None, ExcludeEmpty);
function AntSplit(const value : string; const Separator: array of Char; Count: Integer;  Options: TAntStringSplitOptions): TArray<string>;


implementation

uses
  System.Types,
  System.IOUtils,
  System.SyncObjs,
  System.SysUtils,
  System.StrUtils,
  System.RegularExpressions;
var
  antPatternRegexCache : TDictionary<string,string>;
  
  //lazy create thread safe
  function InitCache: TDictionary<string,string>;
  var
   newObject: TDictionary<string,string>;
  begin
    if (antPatternRegexCache = nil) then
    begin
      //The object doesn't exist yet. Create one.
      newObject := TDictionary<string,string>.Create;

      //It's possible another thread also created one.
      //Only one of us will be able to set the AObject singleton variable
      if TInterlocked.CompareExchange(Pointer(antPatternRegexCache), Pointer(newObject), nil) <> nil then
      begin
         //The other beat us. Destroy our newly created object and use theirs.
         newObject.Free;
      end;
    end;

    Result := antPatternRegexCache;
  end;

  procedure AddToCache(const antPattern : string; const regex : string);
  begin
    InitCache;
    MonitorEnter(antPatternRegexCache);
    try
      antPatternRegexCache.AddOrSetValue(antPattern, regex);
    finally
      MonitorExit(antPatternRegexCache);
    end;
  end;

  function GetRegexFromCache(const antPattern : string) : string;
  begin
    result := '';
    if antPatternRegexCache = nil then
      exit;
    antPatternRegexCache.TryGetValue(antPattern, result);
  end;

  
  
{ TFileSystemPattern }

constructor TFileSystemPattern.Create(const directory, fileMask: string);
begin
  FDirectory := IncludeTrailingPathDelimiter(Trim(ExcludeTrailingPathDelimiter(directory)));
  FFileMask  := fileMask;
end;

function TFileSystemPattern.GetDirectory: string;
begin
  result := FDirectory;
end;

function TFileSystemPattern.GetFileMask: string;
begin
  result := FFileMask;
end;

//Copied from XE7
function StartsWith(const current : string; const Value: string; IgnoreCase: Boolean = false): Boolean;
begin
  if not IgnoreCase then
    Result := System.SysUtils.StrLComp(PChar(current), PChar(Value), Length(Value)) = 0
  else
    Result := System.SysUtils.StrLIComp(PChar(current), PChar(Value), Length(Value)) = 0;
end;

function EndsWith(const theString : string; const Value: string; IgnoreCase: Boolean = true): Boolean;
begin
  if IgnoreCase then
    Result := EndsText(Value, theString)
  else
    result := EndsStr(Value, theString);
end;



function IndexOfAny(const value : string; const AnyOf: array of Char; StartIndex, Count: Integer): Integer;
var
  I: Integer;
  C: Char;
  Max: Integer;
begin
  if (StartIndex + Count) >= Length(value) then
    Max := Length(value)
  else
    Max := StartIndex + Count;

  I := StartIndex;
  while I <= Max do
  begin
    for C in AnyOf do
      if value[I] = C then
        Exit(I);
    Inc(I);
  end;
  Result := -1;
end;

function LastIndexOf(const theString : string; Value: Char; StartIndex, Count: Integer): Integer;
var
  I: Integer;
  Min: Integer;
begin
  if StartIndex < Length(theString) then
    I := StartIndex
  else
    I := Length(theString);
  if (StartIndex - Count) < 0 then
    Min := 1
  else
    Min := StartIndex - Count;
  while I >= Min do
  begin
    if theString[I] = Value then
      Exit(I);
    Dec(I);
  end;
  Result := -1;
end;





function AntSplit(const value : string; const Separator: array of Char; Count: Integer;  Options: TAntStringSplitOptions): TArray<string>;
const
  DeltaGrow = 32;
var
  NextSeparator, LastIndex: Integer;
  Total: Integer;
  CurrentLength: Integer;
  S: string;
begin
  Total := 0;
  LastIndex := 1;
  CurrentLength := 0;
  NextSeparator := IndexOfAny(value, Separator, LastIndex, Length(value));
  while (NextSeparator >= 0) and (Total < Count) do
  begin
    S := Copy(value, LastIndex, NextSeparator - LastIndex);
    if (S <> '') or ((S = '') and (Options <> ExcludeEmpty)) then
    begin
      Inc(Total);
      if CurrentLength < Total then
      begin
        CurrentLength := Total + DeltaGrow;
        SetLength(Result, CurrentLength);
      end;
      Result[Total - 1] := S;
    end;
    LastIndex := NextSeparator + 1;
    NextSeparator := IndexOfAny(value, Separator, LastIndex, Length(value));
  end;

  if (LastIndex < Length(value)) and (Total < Count) then
  begin
    Inc(Total);
    SetLength(Result, Total);
    Result[Total - 1] := Copy(value, LastIndex, Length(value));
  end
  else
    SetLength(Result, Total);
end;


{ TAntPattern }

function TAntPattern.Combine(const root: string; pattern: string): string;
begin
  if StartsWith(pattern, PathDelim) then
    Delete(pattern,1,1);
  result := IncludeTrailingPathDelimiter(FRootDirectory) + pattern;
end;


function TAntPattern.ConvertAntToRegexString(const antPattern: string): string;
begin
    result := GetRegexFromCache(antPattern);
    if result <> '' then
      exit;

    result := TRegEx.Escape(Trim(antPattern));

    // Make all path delimiters the same (to simplify following expressions)
    result := TRegEx.Replace(result, '(\\\\|/)', '/');

    // start ** matches. e.g. any folder (recursive match)

    // ** at start or as complete pattern e.g. '**'
    result := TRegEx.Replace(result, '^\\\*\\\*($|/)', '.*');

    // ** end of pattern e.g. 'blah*/**' or 'blah*/**' matches blah1/a.txt and blah2/folder/b.txt
    result := TRegEx.Replace(result, '(?<c>[^/])\\\*/\\\*\\\*/?$', '${c}.*');

    // ** end of pattern e.g. 'blah/**' or 'blah/**/' matches blah/a.txt, blah/folder/b.txt and blah
    result := TRegEx.Replace(result, '/\\\*\\\*/?$', '(?:/.+)*');

    // ** end of delimited pattern e.g. 'blah/**;' or 'blah/**/;' matches blah/a.txt;, blah/folder/b.txt; and blah;
    result := TRegEx.Replace(result, '/\\\*\\\*/?$', '(?:/[^;]+)*;');

    // ** middle of pattern e.g. 'blah*/**/*b.txt' matches blah1/ab.txt and blah2/folder/b.txt
    //                          'blah*/**/a.txt' matches blah1/a.txt and blah2/folder/a.txt
    result := TRegEx.Replace(result, '(?<!(\\\*))\\\*/\\\*\\\*/(\\\*)?(?!(\\\*))', '[^/]*/.*');

    //** middle of pattern e.g. 'blah/**/*b.txt' matches blah/ab.txt and blah/folder/b.txt
    result := TRegEx.Replace(result, '(?<!(\\\*))/\\\*\\\*/(\\\*)(?!(\\\*))', '/.*');

    //** middle of pattern e.g. 'blah/**/b.txt' matches blah/b.txt and blah/folder/b.txt
    result := TRegEx.Replace(result, '(?<!(\\\*))/\\\*\\\*/(?!(\\\*))', '/(?:.*/)*');

    //** middle of pattern e.g. 'blah/**/a.txt' matches blah/a.txt and blah/folder/a.txt
    result := TRegEx.Replace(result, '(?<c>/?)\\\*\\\*', '${c}.*');

    // end of matches for **

    // Any path delimiter at start is optional
    result := TRegEx.Replace(result, '^/', '/?');

    // Make all path delimiters ambiguous (/ or \)
    result := TRegEx.Replace(result, '/', '(?:\\\\|/)');

    // Make all path delimiters ambiguous (/ or \) again in character class matching
    result := TRegEx.Replace(result, '\[\^\\\\\]', '[^\\/]');

    // * matches zero or more characters which are not a path delimiter
    result := StringReplace(result, '\*', '[^\\/]*', [rfReplaceAll]);

    // ? matches anything but a path delimiter
    result := StringReplace(result, '\?', '[^\\/]', [rfReplaceAll]);

    // Semicolons become |-delimited OR groups
    if Pos(';', result) > 0 then
    begin
      result := StringReplace(result, ';', ')|(?:', [rfReplaceAll]);
      result := '(?:' + result + ')';
    end;

    // Any match must take the entire string and may optionally start with /
    result := '^(?:' + result + ')$';

    AddToCache(antPattern, result);

end;

constructor TAntPattern.Create(const rootDirectory: string);
begin
  FRootDirectory := NormalizeDirectorySeparators(rootDirectory);
end;

function TAntPattern.Expand(const antPattern: string): TArray<IFileSystemPattern>;
var
  normalPattern : string;
  firstWildcard : integer;
  directory     : string;
  mask          : string;
  pattern       : string;
  root         : string;
  newPattern    : IFileSystemPattern;
  feck : string;
  regExPattern  : string;
  lastSepBeforeWildcard : integer;
  regEx : TRegEx;
  list : TList<IFileSystemPattern>;
begin
  list := TList<IFileSystemPattern>.Create;
  try
    normalPattern := NormalizeDirectorySeparators(antPattern);

    if not IsRooted(normalPattern) then //cannot use TPath.IsPathRooted as it matched \xxx
      normalPattern := Combine(ExcludeTrailingPathDelimiter(FRootDirectory),normalPattern); //TPath.Combine fails
    normalPattern := CompressRelativePath(FRootDirectory, normalPattern);
    firstWildcard := IndexOfAny(normalPattern, ['?', '*' ],1, Length(normalPattern));
    mask := ExtractFileName(normalPattern);
      // This is for when 'S:\' is passed in. Default it to '*' wildcard
    if mask = '' then
      mask := '*';
    if firstWildcard = -1 then
    begin
      directory := ExtractFilePath(normalPattern);
      newPattern := TFileSystemPattern.Create(directory, mask);
      list.Add(newPattern);
      exit;
    end;

    lastSepBeforeWildcard := LastIndexOf(normalPattern, PathDelim , firstWildcard, firstWildcard + 1);
    // C:\Foo\Bar\Go?\**\*.txt
    root := Copy(normalPattern, 1, lastSepBeforeWildcard );  // C:\Foo\Bar\
    feck := root;
    pattern := Copy(normalPattern, lastSepBeforeWildcard + 1, Length(normalPattern));   // Go?\**\*.txt

    if pattern = '' then // C:\Foo\bar\ == all files recursively in C:\Foo\bar\
      pattern := '**';

    regExPattern := ConvertAntToRegexString(pattern);
    if regExPattern = '' then
      exit;

    regEx := TRegEx.Create(regExPattern,[TRegExOption.roIgnoreCase]);

    Walk(root,
      function(const path : string; const isDirectory : boolean) : boolean
      var
        subPath : string;
      begin
        result := false;
        if not StartsWith(path, root) then
          exit;

        subPath := Copy(path,Length(root)+ 1);

        //-----------------------------------------------------------
        //this is a work around for an issue with TRegEx where it does not
        //match empty strings in earlier versions of Delphi. Not sure when
        //it was fixed but regex matches empty strings ok in 10.3.2
        //once we find out we can ifdef this out for newer versions
        if ((subPath = '') and (path = root) and isDirectory) then
          subPath := '*';
        //-----------------------------------------------------------

        if regEx.IsMatch(subPath) then
        begin
          if isDirectory then
          begin
            newPattern := TFileSystemPattern.Create(path, '*');
            list.Add(newPattern);
            exit(true);
          end;
          newPattern := TFileSystemPattern.Create(ExtractFilePath(path), mask);// ExtractFileName(path));
          list.Add(newPattern);
          result := true;
        end;

      end);
  finally
    result := list.ToArray();
    list.Free;
  end;

end;


function TAntPattern.IsRooted(const path: string): boolean;
begin
  result := TRegEx.IsMatch(path, '^[a-zA-z]\:\\|\\\\');
end;

function TAntPattern.NormalizeDirectorySeparators(const path: string): string;
begin
  //TODO : Check PathDelim for all platforms;
  {$IFDEF MSWINDOWS}
    result := StringReplace(path, '/', PathDelim, [rfReplaceAll]);
  {$ELSE}
    result := StringReplace(path, '\', PathDelim, [rfReplaceAll]);
  {$ENDIF}
end;

procedure TAntPattern.Walk(const path: string; const walker: TWalkerFunc);
var
  files : TStringDynArray;
  subs  : TStringDynArray;
  fileName : string;
  dir : string;
begin
  if not walker(path, true) then
  begin
    SetLength(files,0);
    try
      files := TDirectory.GetFiles(path,'*', TSearchOption.soTopDirectoryOnly);
    except
      //TODO : Catch Security, unauth, directory not found, let everything else go
    end;

    for fileName in files do
    begin
      if walker(fileName, false) then
          break;
    end;
    SetLength(subs,0);
    try
      subs := TDirectory.GetDirectories(path, '*', TSearchOption.soTopDirectoryOnly);   
    except
      //TODO : same as for above
    end;

    for dir in subs do
      Walk(dir,walker);
    
  end;
end;


function CompressRelativePath(const basePath : string; path : string) : string;
var
  stack : TStack<string>;
  segments : TArray<string>;
  segment : string;
  
begin
  if not TPath.IsPathRooted(path) then
    path := IncludeTrailingPathDelimiter(basePath) + path
  else if not StartsWith(path, basePath) then
    exit(path); //should probably except ?
    
  segments := AntSplit(path, [PathDelim], MaxInt, None);
  stack := TStack<string>.Create;
  try
    for segment in segments do
    begin
      if segment = '..' then
      begin
        if stack.Count > 0 then
          stack.Pop //up one
        else
          raise Exception.Create('Relative path goes below base path');
      end
      else if segment <> '.' then
        stack.Push(segment);
    end;
    result := '';
    while stack.Count > 0 do
    begin
      if result <> '' then
        result := stack.Pop + PathDelim + result
      else
        result := stack.Pop;
    end;
    if EndsWith(path, PathDelim) then
      result := IncludeTrailingPathDelimiter(result);
  finally
    stack.Free;
  end;
end;



end.
