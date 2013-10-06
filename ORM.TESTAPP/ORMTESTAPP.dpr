program ORMTESTAPP;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  UserEntity in 'UserEntity.pas',
  ORM.DataTypes in '..\Entities\ORM.DataTypes.pas',
  PaymentEntity in 'PaymentEntity.pas',
  ORM in '..\ORM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
