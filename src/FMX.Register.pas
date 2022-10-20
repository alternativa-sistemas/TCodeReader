unit FMX.Register;

interface

Uses
  System.classes,
  System.Types,
  DesignIntF,
  CodeReader.FMX.CodeReader,
  CodeReader.FMX.Android.Permissions;

Procedure Register;

implementation

Procedure Register;
Begin
RegisterComponents('Imperium Delphi', [TCodeReader, TAndroidPermissions]);
End;

end.
