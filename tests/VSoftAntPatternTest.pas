unit VSoftAntPatternTest;

interface

uses
  DUnitX.TestFramework,
  Generics.Collections,
  VSoft.AntPatterns,
  VSoft.AntPatterns2;

type
  [TestFixture]
  TAntPatternTests = class
  private
    FFileSystem : TList<TTestRec>;
    FAntPattern : IAntPattern;
  public
    [SetupFixture]
    procedure FixtureSetup;

    [TearDownFixture]
    procedure FixtureTearDown;

    [Test]
    procedure Asterisk_Returns_One_Pattern_ForEach_Dir_With_Mask_Set_To_Astk;

    [Test]
    procedure Exact_Filename_Will_Match_Single_File;

    [Test]
    procedure Extension_Masking_Works;

    [Test]
    procedure Single_Astk_Only_Matches_Single_Dir;

    [Test]
    procedure AstkAskt_With_Ext_Matches_All_Files_In_All_Dirs_With_Matching_Extension;

    [Test]
    procedure AstkAskt_With_Ext_Matches_All_Files_In_All_Dirs_With_Matching_Extension2;

    [Test]
    procedure Test_Unrooted_Path;

    [Test]
    procedure Test_Files_with_dots;

    [Test]
    procedure Test_Directory_Recursion_AfterText;

    [Test]
    procedure Test_DirectoryRecursion_BeforeText;

    [Test]
    procedure Test_DirectoryRecursion_BeforeAndAfterText;

    [Test]
    procedure Test_DirectoryRecursion_BeforeAndAfterText2;

    [Test]
    procedure Test_DirectoryRecursion_Complex;

    [Test]
    procedure Test_DirectoryRecursion_Complex2;

    [Test]
    procedure Test_DirectoryRecursion_Extra_Slashes_At_End;

    [Test]
    procedure Test_DirectoryRecursion_Extra_Slashes_At_End2;

    [Test]
    procedure Test_DirectoryRecursion_Extra_Slashes_At_End3;

    [Test]
    procedure Double_Astk_Matches_Multiple_Directories;

    [Test]
    procedure Double_Astk_With_File_Ext_Matches_Files_In_Multiple_Directories;

    [Test]
    procedure Single_Astk_With_File_Ext_Matches_Files_In_Single_Directory;

    [Test]
     procedure RootFolder_Matches_Files_In_Single_Folder;

		[TestCase('1', '*|a,b,abc|a\b,abc\d,a\b\c', '|')]
		[TestCase('2', '**|a,b,abc,a\b,a/b,abc\d,a\b\c|', '|')]
 		[TestCase('3', 'c:\t*|c:\t,c:\test,c:\test.txt|c:\x,d:\test,c:\test\x' , '|')]
		[TestCase('4', 'c:\t*t|c:\tt,c:\test,c:\test.txt|c:\t,c:\testy,c:\test.exe,c:\test\test' , '|')]
		[TestCase('5', 'c:\t??t|c:\test,c:\text,c:\teat|c:\tt,c:\test.txt,c:\t,c:\testy,c:\test.exe,c:\test\test' , '|')]
		[TestCase('6', 'c:\t?t?t|c:\tetst,c:\tetet,c:\tatat|,c:\ttt,c:\tetst.txt,c:\t,c:\tetsty,c:\tetst.exe,c:\tetst\tetst' , '|')]
		[TestCase('7', 'c:\t**|c:\t,c:\test,c:\test.txt,c:\test\test,c:\test\x,c:\test\x\y,c:\test\x\y\test.txt|c:\x,d:\test,c:\feckin\test' , '|')]
		[TestCase('8', 'c:\t**t|c:\tt,c:\test,c:\test.txt,c:\test\test,c:\test\t,c:\test\x\t,c:\test\x\y\test.txt|c:\x,d:\test,c:\feckin\test,c:\test\test.exe' , '|')]
		[TestCase('9', 'c:\t*t*t|c:\ttt,c:\testest,c:\test.txt|c:\x,c:\t,c:\tt,d:\test,c:\feckin\test,c:\test\test.exe,c:\test\test,c:\test\t,c:\test\x\t,c:\test\x\y\test.txt' , '|')]
		[TestCase('10', 'c:\*\*|c:\t\t,c:\test\test,c:\test\test.txt,c:\feckin\test,c:\test\test.exe|c:\x,c:\test,d:\test\test,c:\test\test\test,c:\test\test\test.txt' , '|')]
		[TestCase('11', 'c:\t*t*t|c:\ttt,c:\testest,c:\test.txt|c:\x,c:\t,c:\tt,d:\test,c:\feckin\test,c:\test\test.exe,c:\test\test,c:\test\t,c:\test\x\t,c:\test\x\y\test.txt' , '|')]
		[TestCase('12', 'c:\t*t?t|c:\ttet,c:\testet,c:\test.txt,c:\textat|c:\x,c:\t,c:\tt,d:\tet,c:\testest,c:\feckin\tetet,c:\test\tet.exe,c:\test\tet,c:\testet\t,c:\tetet\x\t,c:\testet\x\y\testet.txt' , '|')]
		[TestCase('13', 'c:\t**t?t|c:\ttet,c:\testet,c:\test.txt,c:\textat,c:\test\tet,c:\testet\x\y\testet.txt|c:\x,c:\t,c:\tt,d:\tet,c:\testest,c:\feckin\tetet,c:\test\test.exe,c:\testet\t,c:\tetet\x\t' , '|')]
		[TestCase('14', 'c:\t*;c:\x*|c:\t,c:\x,c:\test,c:\xylophone,c:\test.txt,c:\xylophone.txt|d:\test,c:\y,c:\test\x,d:\xylophone,c:\xylophone\t' , '|')]
		[TestCase('15', 'c:\test\test.txt*|c:\test\test.txt|', '|')]

     procedure Test_AntToRegExConversion(antPattern : string; matchingValues : string; nonMatchingValues : string);



		 [TestCase('1', 'c:\temp\foo\..\bar\test.txt|c:\temp\bar\test.txt|', '|')]
		 [TestCase('2', 'c:\temp\foo\fooy\..\..\.\bar\test.txt|c:\temp\bar\test.txt|', '|')]
		 [TestCase('3', '.\bar\test.txt|c:\temp\bar\test.txt|', '|')]
     procedure TestCompress_Relative_Path(const path, expected : string);



  end;

implementation

uses
  System.RegularExpressions,
  System.SysUtils;


procedure TAntPatternTests.Exact_Filename_Will_Match_Single_File;
var
  patterns : TArray<IFileSystemPattern>;
begin
	  patterns := FAntPattern.Expand('C:\Foo\1.txt');

  	Assert.AreEqual<integer>(1, Length(patterns));
    Assert.AreEqual('C:\Foo\', patterns[0].Directory);
		Assert.AreEqual('1.txt', patterns[0].FileMask);
end;


procedure TAntPatternTests.FixtureSetup;
begin
  FFileSystem := TList<TTestRec>.Create;
  FFileSystem.Add(TTestRec.Create('C:\a.txt', true));
  FFileSystem.Add(TTestRec.Create('C:\Foo\', true));
  FFileSystem.Add(TTestRec.Create('C:\Foo\1.txt', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\2.txt', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\3.bat', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\', true));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\a.jpg', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\b.gif', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\c.jpg', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\dup\', true));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\dup\a.jpg', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\dup\b.txt', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\dup\c.bat', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\', true));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\Continua.Modules.Builds.TeamFoundation.2008.config', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\Continua.Modules.Builds.TeamFoundation.2010.config', false));
  FFileSystem.Add(TTestRec.Create('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\Continua.Modules.Builds.TeamFoundation.2012.config', false));

  FAntPattern := TAntPattern2.Create('C:\Foo', FFileSystem);
end;

procedure TAntPatternTests.FixtureTearDown;
begin
  FFileSystem.Free;
end;


procedure TAntPatternTests.Asterisk_Returns_One_Pattern_ForEach_Dir_With_Mask_Set_To_Astk;
var
  patterns : TArray<IFileSystemPattern>;
//  pattern: IFileSystemPattern;
begin
  patterns := FAntPattern.Expand('**');
//  for pattern in patterns do
//  begin
//    Self.Log(pattern.Directory + pattern.FileMask);
//  end;

  Assert.AreEqual<integer>(4, Length(patterns));

  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('*', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\bar\', patterns[1].Directory);
  Assert.AreEqual('*', patterns[1].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[2].Directory);
  Assert.AreEqual('*', patterns[2].FileMask);

  Assert.AreEqual('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\', patterns[3].Directory);
  Assert.AreEqual('*', patterns[3].FileMask);
end;


procedure TAntPatternTests.Extension_Masking_Works;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Foo\**\*.*');

	Assert.AreEqual<integer>(12, Length(patterns));
end;


procedure TAntPatternTests.Single_Astk_Only_Matches_Single_Dir;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Foo\*');
  Assert.AreEqual<integer>(1, Length(patterns));
end;


procedure TAntPatternTests.AstkAskt_With_Ext_Matches_All_Files_In_All_Dirs_With_Matching_Extension;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**\*.txt');
  Assert.AreEqual<integer>(3, Length(patterns));
end;


procedure TAntPatternTests.AstkAskt_With_Ext_Matches_All_Files_In_All_Dirs_With_Matching_Extension2;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('\**\*.txt');
  Assert.AreEqual<integer>(3, Length(patterns));
end;


procedure TAntPatternTests.Test_Unrooted_Path;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('\**');
  Assert.AreEqual<integer>(4, Length(patterns));
end;


procedure TAntPatternTests.Test_Files_with_dots;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\*.config');
  Assert.AreEqual<integer>(3, Length(patterns));
end;


procedure TAntPatternTests.Test_Directory_Recursion_AfterText;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\F**');
  Assert.AreEqual<integer>(4, Length(patterns));
  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('*', patterns[0].FileMask);

end;


procedure TAntPatternTests.Test_DirectoryRecursion_BeforeText;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**.jpg');
  Assert.AreEqual<integer>(3, Length(patterns));
end;

procedure TAntPatternTests.TestCompress_Relative_Path(const path, expected : string);
const
  base = 'c:\temp';
var
  compressed : string;
begin
  compressed := CompressRelativePath(base, path);
  Assert.AreEqual(expected, compressed);
end;

procedure TAntPatternTests.Test_AntToRegExConversion(antPattern, matchingValues, nonMatchingValues: string);
var
  regExPattern : string;
  matchingValuesArry :TArray<string>;
  nonMatchingValuesArray : TArray<string>;
  re : TRegEx;
  value : string;
  match : TMatch;
begin
  regExPattern := FAntPattern.ConvertAntToRegexString(antPattern);
  re := TRegEx.Create(regExPattern);

  matchingValuesArry := matchingValues.Split([',']);
  nonMatchingValuesArray := nonMatchingValues.Split([',']);

  for value in matchingValuesArry do
  begin
    match := re.Match(value);
    Assert.IsTrue(match.Success, 'The value ' + value + ' should match the ANT pattern ' + antPattern +'. The converted regex pattern ' + regExPattern + ' is incorrect' );
  end;

  for value in nonMatchingValuesArray do
  begin
    match := re.Match(value);
    Assert.IsFalse(re.IsMatch(value), 'The value ' + value + ' should not match the ANT pattern ' + antPattern +'. The converted regex pattern ' + regExPattern + ' is incorrect' );
  end;

end;

procedure TAntPatternTests.Test_DirectoryRecursion_BeforeAndAfterText;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**up**');
  Assert.AreEqual<integer>(1, Length(patterns));
  Assert.AreEqual('C:\Foo\bar\dup\', patterns[0].Directory);
  Assert.AreEqual('*', patterns[0].FileMask);
end;


procedure TAntPatternTests.Test_DirectoryRecursion_BeforeAndAfterText2;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**ba**');
  Assert.AreEqual<integer>(4, Length(patterns));

  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('3.bat', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\bar\', patterns[1].Directory);
  Assert.AreEqual('*', patterns[1].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[2].Directory);
  Assert.AreEqual('*', patterns[2].FileMask);

  Assert.AreEqual('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\', patterns[3].Directory);
  Assert.AreEqual('*', patterns[3].FileMask);
end;

procedure TAntPatternTests.Test_DirectoryRecursion_Complex;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\**ba**');
  Assert.AreEqual<integer>(4, Length(patterns));

  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('3.bat', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\bar\', patterns[1].Directory);
  Assert.AreEqual('*', patterns[1].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[2].Directory);
  Assert.AreEqual('*', patterns[2].FileMask);

  Assert.AreEqual('C:\Foo\bar\Continua.Modules.Builds.TeamFoundation\', patterns[3].Directory);
  Assert.AreEqual('*', patterns[3].FileMask);
end;


procedure TAntPatternTests.Test_DirectoryRecursion_Complex2;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Fo**?.tx**');
  Assert.AreEqual<integer>(3, Length(patterns));

  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('1.txt', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\', patterns[1].Directory);
  Assert.AreEqual('2.txt', patterns[1].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[2].Directory);
  Assert.AreEqual('b.txt', patterns[2].FileMask);

end;

procedure TAntPatternTests.Test_DirectoryRecursion_Extra_Slashes_At_End;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**\a.jpg\**');
  Assert.AreEqual<integer>(2, Length(patterns));

  Assert.AreEqual('C:\Foo\bar\', patterns[0].Directory);
  Assert.AreEqual('a.jpg', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[1].Directory);
  Assert.AreEqual('a.jpg', patterns[1].FileMask);

end;

procedure TAntPatternTests.Test_DirectoryRecursion_Extra_Slashes_At_End2;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**\a.jpg\**\');
  Assert.AreEqual<integer>(2, Length(patterns));

  Assert.AreEqual('C:\Foo\bar\', patterns[0].Directory);
  Assert.AreEqual('a.jpg', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[1].Directory);
  Assert.AreEqual('a.jpg', patterns[1].FileMask);
end;

procedure TAntPatternTests.Test_DirectoryRecursion_Extra_Slashes_At_End3;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('**\a.jpg\**\**');
  Assert.AreEqual<integer>(0, Length(patterns));
end;


procedure TAntPatternTests.Double_Astk_Matches_Multiple_Directories;
var
  patterns : TArray<IFileSystemPattern>;
  pattern : IFileSystemPattern;
begin
  patterns := FAntPattern.Expand('C:\Foo\**');
  Assert.AreEqual<integer>(4, Length(patterns));
  for pattern in patterns do
  begin
    Assert.AreEqual('*', pattern.FileMask);
  end;
end;


procedure TAntPatternTests.Double_Astk_With_File_Ext_Matches_Files_In_Multiple_Directories;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Foo\**.txt');
  Assert.AreEqual<integer>(3, Length(patterns));
  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('1.txt', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\', patterns[1].Directory);
  Assert.AreEqual('2.txt', patterns[1].FileMask);

  Assert.AreEqual('C:\Foo\bar\dup\', patterns[2].Directory);
  Assert.AreEqual('b.txt', patterns[2].FileMask);

end;


procedure TAntPatternTests.Single_Astk_With_File_Ext_Matches_Files_In_Single_Directory;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\Foo\*.txt');
  Assert.AreEqual<integer>(2, Length(patterns));
  Assert.AreEqual('C:\Foo\', patterns[0].Directory);
  Assert.AreEqual('1.txt', patterns[0].FileMask);

  Assert.AreEqual('C:\Foo\', patterns[1].Directory);
  Assert.AreEqual('2.txt', patterns[1].FileMask);

end;

procedure TAntPatternTests.RootFolder_Matches_Files_In_Single_Folder;
var
  patterns : TArray<IFileSystemPattern>;
begin
  patterns := FAntPattern.Expand('C:\');
  Assert.AreEqual<integer>(1, Length(patterns));
  Assert.AreEqual('C:\', patterns[0].Directory);
  Assert.AreEqual('*', patterns[0].FileMask);

end;



initialization
  TDUnitX.RegisterTestFixture(TAntPatternTests);

end.
