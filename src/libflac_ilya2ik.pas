{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit libflac_ilya2ik;

{$warn 5023 off : no warning about unused units}
interface

uses
  OGLFLACWrapper, libflac_dynlite, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('libflac_ilya2ik', @Register);
end.
