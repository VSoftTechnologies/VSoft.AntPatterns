unit VSoftAntPatternTestSplit;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TSplitTests = class
  public
    [Test]
    procedure TestWithEndElipse;

  end;

implementation

uses
  VSoft.AntPatterns;

{ TSplitTests }

procedure TSplitTests.TestWithEndElipse;
var
  segments : TArray<string>;
begin
  segments := AntSplit('c:\test\..\',['\'], maxInt, TAntStringSplitOptions.None);
  Assert.AreEqual<integer>(3, length(segments));

end;

initialization
  TDUnitX.RegisterTestFixture(TSplitTests);


end.
