unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Data.Win.ADODB, ORM,
  Vcl.Grids, UserEntity, Vcl.ExtCtrls;

type

  TForm1 = class(TForm)
    Panel1: TPanel;
    TaskPanel: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    cbTask: TComboBox;
    Panel2: TPanel;
    ComboBox1: TComboBox;
    Button2: TButton;
    Button12: TButton;
    LogPanel: TPanel;
    mLog: TMemo;
    Label6: TLabel;
    CodePanel: TPanel;
    Label7: TLabel;
    mCode: TMemo;
    BodyPanel: TPanel;
    Panel4: TPanel;
    Id: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    StringGrid1: TStringGrid;
    procedure Button2Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure cbTaskChange(Sender: TObject);
  private
    ORM1:TORM;
    users:TArray<TUser>;
    ADOConnection:TADOConnection;
    procedure OnMessage(Sender:TObject; Msg:String);
    procedure SetCode(Code:String);
    function GetConnectionString(UdlFileName:String):string;
    procedure ShowInTable();
    procedure ClearUsers();
    procedure SelectUsers();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses RTTI, ORM.DataTypes, PaymentEntity;

{$R *.dfm}

procedure TForm1.OnMessage(Sender:TObject; Msg:String);
begin
  if Sender<>nil then begin
    mLog.Lines.Add(Format('%s %s: %s',[TimeToStr(Now),Sender.ClassName,Msg]));
  end else begin
    mLog.Lines.Add(Format('%s %s',[TimeToStr(Now),Msg]));
  end;
end;

procedure TForm1.SetCode(Code:String);
begin
  mCode.Clear;
  mCode.Lines.Add(Code);
end;

procedure TForm1.cbTaskChange(Sender: TObject);
begin
  case cbTask.ItemIndex of
    0: begin
      SetCode('ORM1.Owner:=''postgres'';'+#13#10+'ORM1.Sync([TUser,TPayment],true,true,true,true);');
    end;
    1: begin
      SetCode('users:=ORM1.Select<TUser>.Open; // users:TArray<TUser>');
    end;
    2: begin
      SetCode('users:=ORM1.Select<TUser>'+#13#10+
      '.Where(TORM.LessOrEqual(FUser.Id,4) and (not TORM.Equals(FUser.Name,''Petrov'')))'+#13#10+
      '.Open; // users:TArray<TUser>');
    end;
    3: begin
      SetCode('users:=ORM1.Select<TUser>'+#13#10+
      '.OrderBy(FUser.Age).OrderBy(FUser.Id,otDESC).Open;');
    end;
    4: begin
      SetCode('count:=ORM1.Select<TUser>.Count; // count:integer');
    end;
    5: begin
      SetCode('Res:=ORM1.Select<TUser>.OrderBy(FUser.Name).Distinct'+#13#10+
        '.OpenEx([FUser.Name]); // Res:TORMResult');
    end;
    6: begin
      SetCode('Res:=ORM1.Select<TUser>.Join(TPayment)'+#13#10+
        '.OpenEx([TField.Create(TUser,FUSer.Name),TField.Create(TPayment,FPayment.Total)]);');
    end;
    7: begin
      SelectUsers();
      SetCode('ORM1.Save(user); // user:TUser');
    end;
    8: begin
      SelectUsers();
      SetCode('ORM1.Save(user); // user:TUser');
    end;
    9: begin
      SelectUsers();
      SetCode('ORM1.Delete(user); // user:TUser');
    end;
    10: begin
      SelectUsers();
      SetCode('ORM1.Save(TArray<TEntity>(users)); // users:TArray<TUser>');
    end;
    11: begin
      SetCode('');
    end;
  end;
end;

procedure TForm1.Button12Click(Sender: TObject);
var i,j,count:integer;
    Res:TORMResult;
    user:TUser;
begin
  case cbTask.ItemIndex of
    0: begin
      ORM1.Owner:='postgres';
      ORM1.Sync([TUser,TPayment],true,true,true,true);
    end;
    1: begin
      ClearUsers;
      users:=ORM1.Select<TUser>.Open;
      ShowInTable;
    end;
    2: begin
      ClearUsers;
      users:=ORM1.Select<TUser>
      .Where(TORM.LessOrEqual(FUser.Id,4) and (not TORM.Equals(FUser.Name,'Petrov')))
      .Open; // users:TArray<TUser>
      ShowInTable;
    end;
    3: begin
      ClearUsers;

      users:=ORM1.Select<TUser>
      .OrderBy(FUser.Age).OrderBy(FUser.Id,otDESC).Open;

      ShowInTable;
    end;
    4: begin
      count:=ORM1.Select<TUser>.Count;
      ShowMessage(Format('Count = %d',[count]));
    end;
    5: begin
      try
        Res:=ORM1.Select<TUser>.OrderBy(FUser.Name).Distinct
        .OpenEx([FUser.Name]); // Res:TORMResult

        StringGrid1.RowCount:=Res.Count+1;

        for i := 0 to Res.Count-1 do begin
          for j := 0 to Res.FieldsCount-1 do begin
            StringGrid1.Cells[j,i+1]:=Res.Value(Res.Field[j],i);
          end;
          for j := Res.FieldsCount to StringGrid1.ColCount-1 do begin
            StringGrid1.Cells[j,i+1]:='';
          end;
        end;
      finally
        FreeAndNil(Res);
      end;
    end;
    6: begin
      try
        Res:=ORM1.Select<TUser>.Join(TPayment)
        .OpenEx([TField.Create(TUser,FUSer.Name),TField.Create(TPayment,FPayment.Total)]);
        StringGrid1.RowCount:=Res.Count+1;

        for i := 0 to Res.Count-1 do begin
          for j := 0 to Res.FieldsCount-1 do begin
            StringGrid1.Cells[j,i+1]:=Res.Value(Res.Field[j],i);
          end;
          for j := Res.FieldsCount to StringGrid1.ColCount-1 do begin
            StringGrid1.Cells[j,i+1]:='';
          end;
        end;
      finally
        FreeAndNil(Res);
      end;
    end;
    7: begin
      try
        user:=TUser.Create;
        user.Id:=StrToInt(Edit2.Text);
        user.Name:=Edit3.Text;
        user.Age:=StrToFloat(Edit4.Text);

        try
          ORM1.Save(user);
          ShowMessage('Пользователь добавлен');
          SelectUsers();
        except
          on E:Exception do ShowMessage('Ошибка при добавлении! '+e.Message);
        end;
      finally
        FreeAndNil(user);
      end;
    end;
    8:begin
      if (StringGrid1.Row<1) or (StringGrid1.Row>Length(Users)) then exit;

      try
        // Update User
        users[StringGrid1.Row-1].Id:=StrToInt(Edit2.Text);
        users[StringGrid1.Row-1].Name:=Edit3.Text;
        users[StringGrid1.Row-1].Age:=StrToFloat(Edit4.Text);

        ORM1.Save(users[StringGrid1.Row-1]);
        SelectUsers();

        ShowMessage('Пользователь обновлен');
      except
        on E:Exception do ShowMessage('Ошибка при обновлении! '+e.Message);
      end;
    end;
    9:begin
      if (StringGrid1.Row<1) or (StringGrid1.Row>Length(Users)) then exit;
      try
        ORM1.Delete(users[StringGrid1.Row-1]);
        SelectUsers();
        ShowMessage('Пользователь удален!');
      except
        on E:Exception do ShowMessage('Ошибка при удалении! '+e.Message);
      end;
    end;
    10:begin
      try
        SetLength(users,10);
        for i := 0 to High(users) do begin
          users[i]:=TUser.Create;
          users[i].Name:=Edit3.Text+'_'+IntToStr(i);
          users[i].Age:=Round(Random()*1000)/10;
        end;

        ORM1.Save(TArray<TEntity>(users)); // users:TArray<TUser>

        SelectUsers();
        ShowMessage('Добавлено 10 новых пользователей!');
      finally
        TORM.FreeArr<TUser>(users);
      end;
    end;
    11:begin

    end;
    12:begin

    end;
  end;
end;

procedure TForm1.SelectUsers();
begin
  ClearUsers;
  users:=ORM1.Select<TUser>.Open;
  ShowInTable;
end;

function TForm1.GetConnectionString(UdlFileName:String):String;
var sl:TStringList;
begin
  Result:='';
  try
    sl:=TStringList.Create;
    sl.LoadFromFile(UdlFileName);
    if sl.Count>=3 then begin
      Result:=sl.Strings[2];
    end;
  finally
    FreeAndNil(sl);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  TaskPanel.Visible:=false;
  CodePanel.Visible:=false;
  BodyPanel.Visible:=false;
  LogPanel.Visible:=false;
  Label1.Visible:=true;

  if ADOConnection<>nil then begin
    FreeAndNil(ADOConnection);
  end;

  ADOConnection:=TADOConnection.Create(Self);
  ADOConnection.LoginPrompt:=false;

  case ComboBox1.ItemIndex of
    0: begin
      ADOConnection.ConnectionString:=GetConnectionString('msaccess.udl');
      ADOConnection.Connected:=true;
      ORM1.Connection:=ADOConnection;
      ORM1.DatabaseType:=odbAccess;
    end;
    1: begin
      ADOConnection.ConnectionString:=GetConnectionString('msss.udl');
      ADOConnection.Connected:=true;
      ORM1.Connection:=ADOConnection;
      ORM1.DatabaseType:=odbSqlServer;
    end;
    2: begin
      ADOConnection.ConnectionString:=GetConnectionString('postgresql.udl');
      //ADOConnection1.ConnectionString:='Driver={PostgreSQL UNICODE};Server=localhost;Port=5432;Database=ormtest;Uid=postgres;Pwd=123;';
      ADOConnection.Connected:=true;
      ORM1.Connection:=ADOConnection;
      ORM1.DatabaseType:=odbPostgreSQL;
    end;
  end;

  Label1.Visible:=false;
  TaskPanel.Visible:=true;
  CodePanel.Visible:=true;
  BodyPanel.Visible:=true;
  LogPanel.Visible:=true;
  //ShowMessage('Подключение прошло успешно!');
end;

procedure TForm1.ClearUsers();
var i:integer;
begin
  for i := 0 to High(users) do begin
    if users[i]<>nil then FreeAndNil(users[i]);
  end;
  SetLength(users,0);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ORM1:=TORM.Create(Self);
  ORM1.Log:=OnMessage;
end;

procedure TForm1.ShowInTable();
var i:integer;
begin
  // Show in Table
  StringGrid1.RowCount:=Length(users)+1;
  for i:=0 to High(users) do begin
    StringGrid1.Cells[0,i+1]:=IntToStr(users[i].Id);
    StringGrid1.Cells[1,i+1]:=users[i].Name;
    StringGrid1.Cells[2,i+1]:=FloatToStr(users[i].Age);
  end;
  if Length(users)>0 then StringGrid1.FixedRows:=1;

end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (ARow>0) and (ARow<=Length(users)) then begin
    Edit2.Text:=IntToStr(Users[ARow-1].Id);
    Edit3.Text:=Users[ARow-1].Name;
    Edit4.Text:=FloatToStr(Users[ARow-1].Age);
  end;
end;

end.
