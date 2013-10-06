unit ORM;

interface

uses ADODB, SysUtils, ORM.DataTypes, RTTI, Classes, Generics.Collections;

type

  TORMConfig=class
    class var UPDATE_IDENTITY:Boolean;
  end;

  TORMQuery<T:TEntity>=class;

  TORMConditionType=(octEmpty,octSingle,octAnd,octOr,octNot,octXor);
  TCondition=(conEquals,conLess,conLessOrEqual,conMore,conMoreOrEqual,conLike);

  TORM=class;

  TORMCondition=record
  private
    //SQLStr:string;
    Arr:TArray<TORMCondition>;
    condType:TORMConditionType;
    fClass:TEntityClass;
    fField:string;
    fCondition:TCondition;
    fValue:TValue;
  public
    class operator LogicalAnd(a: TORMCondition; b: TORMCondition): TORMCondition;
    class operator LogicalOr(a: TORMCondition; b: TORMCondition): TORMCondition;
    class operator LogicalNot(a: TORMCondition): TORMCondition;
    class operator LogicalXor(a: TORMCondition; b: TORMCondition): TORMCondition;
    procedure Init(Field:String; Condition:TCondition; Value:TValue; EntityClass:TEntityClass=nil);
    procedure Clear;
    function IsEmpty:Boolean;
    function ToString(ORM:TORM=nil):String;
  end;



  TEntityRequestProcedure=procedure(const ORM:TORM; EntityClass:TEntityClass) of object;
  TDataUpdateProcedure=procedure(const Action,SQL:String; Entity:TEntity) of object;
  TConnectionErrorFunction=function(const ORM:TORM; EntityClass:TEntityClass; E:Exception):Boolean of object; // Result - Have to repeat
  TORMDatabase=(odbAccess,odbSqlServer,odbPostgreSQL);

  TSaveMode=(smInsert,smInsertOrUpdate);

  TOnSendMessage=procedure(Sender:TObject; Msg:String) of object;

  TORM=class(TComponent)
  private
    fConn:TADOConnection;
    fEntityRequest:TEntityRequestProcedure;
    fDataUpdate:TDataUpdateProcedure;
    fConnectionError:TConnectionErrorFunction;
    fORMDatabase:TORMDatabase;
    fSelectFromView:boolean;
    fIgnoreMissingFields:boolean;
    fOwner:String;
    class var fOnMessage:TOnSendMessage;
    class procedure OnMessage(Sender:TObject; Msg:String);
  protected
    procedure BackupPrimaryKeys(Entity:TEntity);
  public
    class property Log:TOnSendMessage read fOnMessage write fOnMessage;
    property Connection:TADOConnection read fConn write fConn;
    property OnBeforeEntityRequest:TEntityRequestProcedure read fEntityRequest write fEntityRequest;
    property OnAfterDataUpdate:TDataUpdateProcedure read fDataUpdate write fDataUpdate;
    property OnConnectionError:TConnectionErrorFunction read fConnectionError write fConnectionError;

    procedure CheckConnection(EntityClass:TEntityClass);
    function Select<T:TEntity>:TORMQuery<T>;
    function Update<T:TEntity>:TORMQuery<T>;
    function Save(Entity:TEntity):Integer; overload;
    function Save(Arr:TArray<TEntity>; SaveMode:TSaveMode=smInsertOrUpdate):Integer; overload;
    function Insert(Arr:TArray<TEntity>):integer;
    function Delete(Entity:TEntity):Integer;
    function Sync(EntityClass:TEntityClass; CreateTable:Boolean=false; CreateColumns:Boolean=true; CreateKeys:Boolean=false; CreateCounters:Boolean=false):Integer; overload; // синхронизаци€ таблицы
    function Sync(Entities:array of TEntityClass; CreateTable:Boolean=false; CreateColumns:Boolean=true; CreateKeys:Boolean=false; CreateCounters:Boolean=false):Integer; overload; // синхронизаци€ таблицы
    function CreateEntity(T:TEntityClass):TEntity; // создание экземпл€ра класса T
    function Parent<T:TEntity>(const Child:TEntity):T;
    function Childs<T:TEntity>(const Parent:TEntity):TArray<T>;


    property DatabaseType:TORMDatabase read fORMDatabase write fORMDatabase;
    property SelectFromView:boolean read fSelectFromView write fSelectFromView;
    property IgnoreMissingFields:boolean read fIgnoreMissingFields write fIgnoreMissingFields;
    property Owner:String read fOwner write fOwner;
    //property OnEditMode:boolean

    class function Equals(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class function More(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class function MoreOrEqual(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class function Less(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class function LessOrEqual(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class function Likeis(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
    class procedure FreeArr<T:TEntity>(var Arr:TArray<T>);

    procedure Free;
  end;

  TORMResult=class
  protected
    fFieldIndex:TDictionary<String,Integer>;
    Data:TArray<TArray<Variant>>;
    Fields:TStringList;
    function GetField(Index:Integer):String;
  public
    constructor Create;
    function Count:Integer;
    function FieldsCount:Integer;
    function ToLowerCase:TORMResult;

    function Value(Field:String; Index:Integer):Variant; overload;
    function Value(EntityClass:TEntityClass; Field:String; Index:Integer):Variant; overload;

    property Field[Index:Integer]:String read GetField;

    procedure Free;
  end;

  TOrderType=(otASC,otDESC);
  TQueryType=(qtSelect,qtCount,qtSelectEx,qtMax);

  TORMQuery<T:TEntity>=class
  private
    type
      TJoinClass=record
        Field:String;
        Entity:TEntityClass;
        JoinEntity:TEntityClass;
        JoinField:String;
      end;
    var
    fORMObj:TORM;
    fWhere:string;
    fOrderBy:string;
    fDistinct:boolean;
    fFirst:boolean;
    fMax:boolean;
    fJoinClasses:TArray<TJoinClass>;
    function GetJoinSQL:String;
    function ToSQL(QueryType:TQueryType):String;
    function GetConnection:TADOConnection;
  public
    constructor Create(ORMObj:TORM);
    function EntityClass:TEntityClass;
    function Open:TArray<T>;
    function OpenEx(Columns:array of string):TORMResult; overload;
    function OpenEx(Columns:array of TField):TORMResult; overload;
    function Count:Integer;
    function First:T;
    procedure InitClass(Condition:TORMCondition);
    function Where(Condition:TORMCondition; AutoClear:Boolean=false):TORMQuery<T>; // AutoClear - выполнить метод Clear у записи Condition
    function OrderBy(Column:String; OrderType:TOrderType=otASC):TORMQuery<T>; overload;
    function OrderBy(Field:TField; OrderType:TOrderType=otASC):TORMQuery<T>; overload;
    function Distinct:TORMQuery<T>;
    function Max(Columns:array of string):Integer{TORMQuery<T>};
    function Join(JoinClass:TEntityClass):TORMQuery<T>; overload;
    function Join(JoinClass:TEntityClass; JoinField:String; Field:String):TORMQuery<T>; overload;
    function Join(Class1:TEntityClass; Field1:String; Class2:TEntityClass; Field2:String):TORMQuery<T>; overload;
  end;


implementation

uses DB, Windows, System.TypInfo, StrUtils, Variants;

class procedure TORM.OnMessage(Sender:TObject; Msg:String);
begin
  if Sender<>nil then begin
    OutputDebugString(PChar('['+Sender.ClassName+'] '+Msg));
  end else begin
    OutputDebugString(PChar(Msg));
  end;
end;

function TORMCondition.ToString(ORM:TORM=nil):String;
const ConStr:array[0..5] of string=('=','<','<=','>','>=','LIKE');
var c1,c2:string;
    UseView:Boolean;
    dt:TDateTime;
    fType,ValStr:String;
begin
  if condType=octSingle then begin
    c1:='';
    c2:='';
    UseView:=false;
    if ORM<>nil then begin
      if ORM.DatabaseType in [odbAccess,odbSqlServer] then begin
        c1:='[';
        c2:=']';
      end;
      if ORM.DatabaseType in [odbPostgreSQL] then begin
        c1:='"';
        c2:='"';
      end;

      UseView:=ORM.SelectFromView;
    end;

    if fClass=nil then begin
      Result:='';
    end else begin
      if UseView then begin
        Result:=fClass.ViewName+'.';
      end else begin
        Result:=fClass.EntityName+'.';
      end;
    end;

    Result:=Result+c1+fField+c2;
    c1:='';
    ValStr:=fValue.ToString;

    if fValue.Kind in [tkInteger,tkFloat,tkInt64] then begin
      if (fValue.Kind=tkFloat) and (fClass<>nil) then begin
        fType:=fClass.GetEntityInfo.ColumnType[fField];
        dt:=fValue.AsExtended;
        if fType='TDate' then begin
          c1:='''';
          ValStr:=DateToStr(dt);
        end;
        if fType='TTime' then begin
          c1:='''';
          ValStr:=TimeToStr(dt);
        end;
        if fType='TDateTime' then begin
          c1:='''';
          ValStr:=DateTimeToStr(dt);
        end;

        if (c1='''') and (ORM<>nil) and (ORM.DatabaseType in [odbAccess,odbSqlServer]) then begin
          c1:='#';
        end;

      end;
    end else begin
      if not((Length(fValue.ToString)>0) and (fValue.ToString[1]='#')) then begin
        c1:='''';
      end;
    end;

    Result:=Format('%s %s %s%s%s',[Result,ConStr[Integer(fCondition)],c1,VaLStr,c1]);

  end else begin
    case condType of
      octEmpty: Result:='';
      octAnd: Result:=Format('(%s and %s)',[Arr[0].ToString(ORM),Arr[1].ToString(ORM)]);
      octOr: Result:=Format('(%s or %s)',[Arr[0].ToString(ORM),Arr[1].ToString(ORM)]);
      octXor: Result:=Format('(%s xor %s)',[Arr[0].ToString(ORM),Arr[1].ToString(ORM)]);
      octNot: Result:=Format('(not %s)',[Arr[0].ToString(ORM)]);
    end;
  end;


end;

procedure TORMCondition.Clear;
var i:integer;
begin
  for i := 0 to High(Arr) do begin
    Arr[i].Clear;
  end;
  SetLength(Arr,0);
  condType:=octEmpty;
end;

function TORMCondition.IsEmpty:Boolean;
begin
  Result:=condType=octEmpty;
end;

procedure TORMCondition.Init(Field:String; Condition:TCondition; Value:TValue; EntityClass:TEntityClass=nil);
begin
  condType:=octSingle;
  fField:=Field;
  fCondition:=Condition;
  fValue:=Value;
  fClass:=EntityClass;
end;

function TORMQuery<T>.Max(Columns:array of string):Integer;
var Q:TADOQuery;
    n,i:integer;

    names:string;
    sql:string;
    cols:string;
begin
  try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=GetConnection;

    for i:=0 to High(Columns) do begin
      if Length(cols)>0 then cols:=cols+', ';
      cols:=cols+Columns[i];
    end;
    sql:=Format(ToSQL(qtMax),[cols]);

    Q.SQL.Add(sql);

    TORM.Log(Self,'OPEN SQL: '+Q.SQL.CommaText);
    Q.Open;

    n:=Q.RecordCount;
    if n>0 then
      begin
        Q.FindFirst;
        Result:=Q.FieldByName('MaxNo').AsInteger;
      end;//if
  finally
    FreeAndNil(Q);
  end;//try
end;//max

procedure TORM.BackupPrimaryKeys(Entity:TEntity);
var arr:TArray<TRttiField>;
    c : TRttiContext;
    t : TRttiType;
    a : TCustomAttribute;
    i,n:integer;
begin
  c:=TRttiContext.Create;
  t:=c.GetType(Entity.ClassInfo);
  arr:=t.GetFields;

  n:=0;
  SetLength(Entity.PrimaryKeys,0);
  for i := 0 to High(arr) do begin
    for a in arr[i].GetAttributes do begin
      if a is Column then begin
        if Column(a).CType=ctPrimary then begin
          SetLength(Entity.PrimaryKeys,n+1);
          Entity.PrimaryKeys[n]:=arr[i].GetValue(TObject(Entity));
          Inc(n);
        end;
      end;
    end;
  end;
end;

procedure TORM.CheckConnection(EntityClass:TEntityClass);
var fConnected:boolean;
    Q:TADOQuery;
    Exc:Exception;
begin
  fConnected:=true;
  try
    try
      Q:=TADOQuery.Create(nil);
      Q.Connection:=fConn;
      Q.SQL.Add('select 1;');
      Q.Open;
    except
      on E:Exception do begin
        Exc:=E;
        fConnected:=false;
      end;
    end;
  finally
    FreeAndNil(Q);
  end;

  if not fConnected then begin
    if Assigned(OnConnectionError) then begin
      OnConnectionError(Self,EntityClass,Exc);
    end;
  end;

end;

procedure TORM.Free;
begin
  if fConn<>nil then begin
    FreeAndNil(fConn);
  end;
end;

function TORM.Select<T>:TORMQuery<T>;
begin
  if Assigned(fEntityRequest) then fEntityRequest(Self,T);

  Result:=TORMQuery<T>.Create(Self);
end;

function TORM.Update<T>:TORMQuery<T>;
begin
  raise Exception.Create('TORM.Update<T> not supported');
  if Assigned(fEntityRequest) then fEntityRequest(Self,T);

  Result:=TORMQuery<T>.Create(Self);
end;

function TORM.Save(Entity:TEntity):integer;
var ADOTable:TADOTable;
    EntityInfo:TEntityInfo;
    n,i,j:integer;
    rt : TRttiType;
    IsNew:Boolean;
    Filter, Action, col,field:String;
    st:Cardinal;
    ms:TMemoryStream;
    arr:TArray<TEntity>;
begin
  if Assigned(fEntityRequest) then fEntityRequest(Self,TEntityClass(Entity.ClassType));

  if Length(Entity.PrimaryKeys)=0 then begin
    Action:='SAVE';
  end else begin
    Action:='UPDATE';
  end;

  SetLength(arr,1);
  arr[0]:=Entity;
  Save(arr);
  BackupPrimaryKeys(Entity);
  if Assigned(fDataUpdate) then fDataUpdate(Action,'',Entity);


  {try
    CheckConnection(TEntityClass(Entity.ClassType));
    IsNew:=Length(Entity.PrimaryKeys)=0;
    ADOTable:=TADOTable.Create(nil);
    ADOTable.Connection:=fConn;
    ADOTable.TableName := Entity.EntityName;
    ADOTable.DisableControls;
    EntityInfo:=Entity.GetEntityInfo;
    n:=EntityInfo.ColCount;
    col:='';
    field:='';

    if IsNew then begin
      Action:='SAVE';
      ADOTable.Open;
      ADOTable.Append;

      for i := 0 to n - 1 do begin
        if EntityInfo.Columns[i].AutoGeneration then begin
          col:=EntityInfo.Columns[i].Name;
          field:=EntityInfo.FieldNames[i];
        end;
      end;

    end else begin
      Action:='UPDATE';
      Filter:='';
      j:=0;
      for i := 0 to n - 1 do begin
        if EntityInfo.Columns[i].CType=ctPrimary then begin
          if Length(Filter)>0 then Filter:=Filter+' and ';
          Filter:=Filter+EntityInfo.Columns[i].Name+'='+Entity.PrimaryKeys[j].ToString;
          //case DatabaseType of
          //  odbAccess,odbSqlServer: Filter:=Filter+'['+EntityInfo.Columns[i].Name+']='+Entity.PrimaryKeys[j].ToString;
          //  odbPostgreSQL:Filter:=Filter+'"'+EntityInfo.Columns[i].Name+'"='+Entity.PrimaryKeys[j].ToString;
          //end;

          Inc(j);
        end;
      end;


      ADOTable.Open;

      ADOTable.Filter:=Filter;
      ADOTable.Filtered:=true;

      ADOTable.Edit;
    end;

    rt:=TRttiContext.Create.GetType(Entity.ClassInfo);
    for i := 0 to n - 1 do begin
      try
        if not EntityInfo.Columns[i].AutoGeneration then begin
          if rt.GetField(EntityInfo.FieldNames[i]).FieldType.Name='Boolean' then begin
            if rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).AsBoolean then begin
              ADOTable.FieldByName(EntityInfo.Columns[i].Name).Value:=1;
            end else begin
              ADOTable.FieldByName(EntityInfo.Columns[i].Name).Value:=0;
            end;
          end else begin
            if (rt.GetField(EntityInfo.FieldNames[i]).FieldType.Name='TMemoryStream') then begin
              if (DatabaseType=odbAccess) then begin
                st:=GetTickCount;
                ms:=rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).AsObject  as TMemoryStream;
                (ADOTable.FieldByName(EntityInfo.Columns[i].Name) as TBLOBField).LoadFromStream(ms);

                OutputDebugString(PChar(Format('TBLOBField.LoadFromStream [%.3f sec].',[(GetTickCount-st)/1000])));
              end;


            end else begin
              ADOTable.FieldByName(EntityInfo.Columns[i].Name).Value:=rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).AsVariant;
            end;
          end;
        end else begin
          if TORMConfig.UPDATE_IDENTITY then begin
            ADOTable.FieldByName(EntityInfo.Columns[i].Name).Value:=rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).AsVariant;
          end;
        end;
      except
        on E:Exception do begin
          raise Exception.Create('TORM.Save: [Field='+EntityInfo.Columns[i].Name+'] '+E.Message);
        end;
      end;
    end;

    ADOTable.Post;

    //for i := 0 to ADOTable.Fields.Count-1 do begin
    //  OutputDebugString(PChar(Format('FieldValue["%s"]=%s',[ADOTable.Fields[i].FieldName,VarToStr(ADOTable.FieldValues[ADOTable.Fields[i].FieldName])])));
    //end;

    if col<>'' then begin
      rt.GetField(field).SetValue(Entity,TValue.FromVariant(ADOTable.FieldValues[col]));
    end;

    BackupPrimaryKeys(Entity);
  finally
    FreeAndNil(ADOTable);
    FreeAndNil(rt);
  end;

  if Assigned(fDataUpdate) then fDataUpdate(Action,'',Entity); }
end;

function TORM.Delete(Entity:TEntity):Integer;
var Q:TADOQuery;
    i,n,j:integer;
    EntityInfo:TEntityInfo;
    Cond:TORMCondition;
    Filter:String;
begin
  if Assigned(fEntityRequest) then fEntityRequest(Self,TEntityClass(Entity.ClassType));

  Result:=0;
  if Length(Entity.PrimaryKeys)=0 then exit;

  CheckConnection(TEntityClass(Entity.ClassType));
  try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=fConn;
    EntityInfo:=Entity.GetEntityInfo;
    n:=EntityInfo.ColCount;

    j:=0;
    for i := 0 to n - 1 do begin
      if EntityInfo.Columns[i].CType=ctPrimary then begin
        if Cond.IsEmpty then begin
          Cond:=Equals(EntityInfo.Columns[i].Name,Entity.PrimaryKeys[j]);
        end else begin
          Cond:=Cond and Equals(EntityInfo.Columns[i].Name,Entity.PrimaryKeys[j]);
        end;
        Inc(j);
      end;
    end;
    Filter:=Cond.ToString(Self);
    Q.SQL.Add(Format('delete from %s where %s',[Entity.EntityName, Filter]));
    Result:=Q.ExecSQL;
  finally
    FreeAndNil(Q);
  end;

  if Assigned(fDataUpdate) then fDataUpdate('DELETE','',Entity);
end;

constructor TORMQuery<T>.Create(ORMObj:TORM);
begin
  fORMObj:=ORMObj;
  fWhere:='';
  fOrderBy:='';
  fDistinct:=false;
  fMax:=false;
end;

function TORMQuery<T>.GetConnection:TADOConnection;
begin
  Result:=nil;
  if fORMObj<>nil then begin
    fORMObj.CheckConnection(EntityClass);
    Result:=fORMObj.Connection;
  end;

end;

function TORMQuery<T>.EntityClass:TEntityClass;
begin
  Result:=T;
end;

function TORMQuery<T>.Open:TArray<T>;
var Q:TADOQuery;
    n,i,j,m:integer;
    fields:TArray<TRttiField>;
    names:string;
    FieldType:TFieldType;
    EntityInfo:TEntityInfo;
    rt : TRttiType;

    bf:TBlobField;
    ms:TMemoryStream;

    rta:TArray<TRttiField>;
    ta:TArray<Integer>;
    b:boolean;

    ss:TStringStream;
    ct1,ct2:Cardinal;
begin
  try
    ct1:=GetTickCount;
    Q:=TADOQuery.Create(nil);
    Q.Connection:=GetConnection;
    ct2:=GetTickCount;
    Q.SQL.Add(ToSQL(qtSelect));

    Q.Open;


    TORM.Log(Self,'SQL: '+Q.SQL.CommaText);
    TORM.Log(Self,Format('SQL EXECUTE TIME: %.3fsec.',[(GetTickCount-ct2)/1000]));
    ct2:=GetTickCount;
    rt:=TRttiContext.Create.GetType(EntityClass);
    n:=Q.RecordCount;
    SetLength(Result,n);
    if n>0 then begin
      EntityInfo:=EntityClass.GetEntityInfo;

      m:=EntityInfo.ColCount;
      SetLength(rta,EntityInfo.ColCount);
      SetLength(ta,EntityInfo.ColCount);

      for i := 0 to High(rta) do begin
        rta[i]:=rt.GetField(EntityInfo.FieldNames[i]);
        ta[i]:=-1;

        if rta[i].FieldType.Name='Boolean' then begin
          ta[i]:=1;
        end;

        if rta[i].FieldType.Name='string' then begin
          ta[i]:=2;
        end;

        if rta[i].FieldType.Name='Integer' then begin
          ta[i]:=3;
        end;

        if rta[i].FieldType.Name='Double' then begin
          ta[i]:=4;
        end;

        if (rta[i].FieldType.Name='TDateTime') or (rta[i].FieldType.Name='TDate') or (rta[i].FieldType.Name='TTime') then begin
          ta[i]:=5;
        end;

        if rta[i].FieldType.Name='TMemoryStream' then begin
          ta[i]:=6;
        end;
      end;

      Q.FindFirst;
      for i := 0 to n-1 do begin

        //Result[i]:=T(EntityClass.NewInstance);
        //EntityClass.InitInstance(TObject(Result[i]));

        Result[i]:=T(fORMObj.CreateEntity(T));


        for j := 0 to m-1 do begin
          if (Q.FieldList.IndexOf(EntityInfo.Columns[j].Name)<0) and (fORMObj.IgnoreMissingFields) then begin
            continue;
          end;
          try
            case ta[j] of
              -1: raise Exception.Create('Unknown ['+rta[j].FieldType.Name+'] field type');
              1,2,3,4,5: begin
                if fORMObj.DatabaseType=odbPostgreSQL then begin
                  if ta[j]=1 then begin
                    b:=Q.FieldByName(EntityInfo.Columns[j].Name).AsBoolean;

                    rta[j].SetValue(TObject(Result[i]),TValue.FromVariant(b));
                  end else begin
                    rta[j].SetValue(TObject(Result[i]),TValue.FromVariant(Q.FieldByName(EntityInfo.Columns[j].Name).AsVariant));
                  end;
                end else begin
                  rta[j].SetValue(TObject(Result[i]),TValue.FromVariant(Q.FieldByName(EntityInfo.Columns[j].Name).AsVariant));
                end;

                if (ta[j]=2) and (Q.FieldByName(EntityInfo.Columns[j].Name).IsNull) then begin
                  rta[j].SetValue(TObject(Result[i]),'');
                end;

              end;
              6: begin
                ms:=rta[j].GetValue(TObject(Result[i])).AsObject as TMemoryStream;
                if ms=nil then begin
                  rta[j].SetValue(TObject(Result[i]),TMemoryStream.Create);
                end;

                ms:=rta[j].GetValue(TObject(Result[i])).AsObject as TMemoryStream;

                if ms<>nil then begin
                  if fORMObj.DatabaseType=odbPostgreSQL then begin
                    try
                      ss:=TStringStream.Create(Q.FieldByName(EntityInfo.Columns[j].Name).AsString);
                      ss.SaveToStream(ms);
                    finally
                      FreeAndNil(ss);
                    end;
                  end else begin
                    (Q.FieldByName(EntityInfo.Columns[j].Name) as TBLOBField).SaveToStream(ms);
                  end;

                end;

                ms:=nil;
              end;
            end;
          except
            on E:Exception do begin
              if j<>-1 then begin
                raise Exception.Create(E.Message+' [Field='+EntityInfo.Columns[j].Name+']');
              end else begin
                raise E;
              end;
            end;
          end;
        end;

        fORMObj.BackupPrimaryKeys(Result[i]);
        if i<n-1 then
          Q.FindNext;
      end;
    end;
  finally
    FreeAndNil(Q);
  end;
  TORM.Log(Self,Format('DATA PREPARE TIME: %.3fsec.',[(GetTickCount-ct2)/1000]));
  TORM.Log(Self,Format('[TORMQuery.Open] RUNTIME: %.3fsec.',[(GetTickCount-ct1)/1000]));
  {try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=fORMObj.fConn;
    Q.SQL.Add(ToSQL(qtSelect));
    OutputDebugString(PWideChar('OPEN SQL: '+Q.SQL.CommaText));
    Q.Open;
    rt:=TRttiContext.Create.GetType(EntityClass);
    n:=Q.RecordCount;
    SetLength(Result,n);
    if n>0 then begin
      EntityInfo:=EntityClass.GetEntityInfo;
      Q.FindFirst;
      for i := 0 to n-1 do begin

        Result[i]:=T(EntityClass.NewInstance);
        EntityClass.InitInstance(TObject(Result[i]));

        m:=EntityInfo.ColCount;
        for j := 0 to m-1 do begin
          if (rt.GetField(EntityInfo.FieldNames[j]).FieldType.Name='TMemoryStream') then begin
            ms:=rt.GetField(EntityInfo.FieldNames[j]).GetValue(TObject(Result[i])).AsObject as TMemoryStream;
            if ms=nil then begin
              rt.GetField(EntityInfo.FieldNames[j]).SetValue(TObject(Result[i]),TMemoryStream.Create);
            end;
            ms:=rt.GetField(EntityInfo.FieldNames[j]).GetValue(TObject(Result[i])).AsObject as TMemoryStream;

            if ms<>nil then begin
              (Q.FieldByName(EntityInfo.Columns[j].Name) as TBLOBField).SaveToStream(ms);
            end;

            ms:=nil;
          end else begin
            rt.GetField(EntityInfo.FieldNames[j]).SetValue(TObject(Result[i]),TValue.FromVariant(Q.FieldByName(EntityInfo.Columns[j].Name).AsVariant));
          end;
        end;

        fORMObj.BackupPrimaryKeys(Result[i]);
        if i<n-1 then
          Q.FindNext;
      end;
    end;
  finally
    FreeAndNil(Q);
  end;}
end;

function TORMQuery<T>.OpenEx(Columns:array of String):TORMResult;
var Q:TADOQuery;
    n,i,j,m:integer;

    names:string;
    sql:string;
    cols,s:string;
    t0:Cardinal;
begin
  Result:=TORMResult.Create;
  try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=GetConnection;
    cols:='';
    for i:=0 to High(Columns) do begin
      if Length(cols)>0 then cols:=cols+', ';
      case fORMObj.DatabaseType of
        odbAccess,odbSqlServer: begin
          if pos('.',Columns[i])<=0 then begin
            cols:=cols+'['+Columns[i]+']';
          end else begin
            cols:=cols+Columns[i];
          end;
        end;
        odbPostgreSQL: begin
          if pos('.',Columns[i])<=0 then begin
            cols:=cols+'"'+Columns[i]+'"';
          end else begin
            cols:=cols+Columns[i];
          end;
        end;
      end;

    end;

    if cols='' then cols:='*';

    if fORMObj.SelectFromView then begin
      for i := 0 to High(fJoinClasses) do begin
        if Pos(fJoinClasses[i].Entity.EntityName,cols)>0 then begin
          cols:=ReplaceStr(cols,fJoinClasses[i].Entity.EntityName,fJoinClasses[i].Entity.ViewName);
        end;
        if Pos(fJoinClasses[i].JoinEntity.EntityName,cols)>0 then begin
          cols:=ReplaceStr(cols,fJoinClasses[i].JoinEntity.EntityName,fJoinClasses[i].JoinEntity.ViewName);
        end;
      end;
    end;


    sql:=Format(ToSQL(qtSelectEx),[cols]);

    Q.SQL.Add(sql);
    TORM.Log(Self,'OPEN SQL: '+Q.SQL.CommaText);
    t0:=GetTickCount;
    Q.Open;
    TORM.Log(Self,Format('RUN TIME: %.3f sec.',[(GetTickCount-t0)/1000]));

    n:=Q.RecordCount;
    m:=Q.FieldCount;
    for i := 0 to Q.Fields.Count-1 do begin
      Result.Fields.Add(Q.Fields[i].FieldName);
      //OutputDebugString(PChar(Format('%d - %s',[i,Q.Fields[i].FieldName])));
    end;

    SetLength(Result.Data,n);

    if n>0 then begin
      Q.FindFirst;
      for i := 0 to n-1 do begin
        SetLength(Result.Data[i],m);
        for j := 0 to m-1 do begin
          Result.Data[i][j]:=Q.Fields[j].Value;
        end;
        if i<n-1 then
          Q.FindNext;
      end;
    end;
  finally
    FreeAndNil(Q);
  end;
  Result.ToLowerCase;
end;

function TORMQuery<T>.OpenEx(Columns:array of ORM.DataTypes.TField):TORMResult;
var Arr:array of string;
    i:integer;
begin
  SetLength(Arr,Length(Columns));
  for i := 0 to High(Columns) do begin
    Arr[i]:=Columns[i].ToString;
  end;
  Result:=OpenEx(Arr);
end;

function TORMQuery<T>.Count:Integer;
var Q:TADOQuery;
    n:integer;
begin
  Result:=0;
  try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=GetConnection;
    Q.SQL.Add(ToSQL(qtCount));
    TORM.Log(Self,'OPEN SQL: '+Q.SQL.CommaText);
    Q.Open;
    n:=Q.RecordCount;

    if n>0 then begin
      Q.FindFirst;
      Result:=Q.FieldValues['RowCount'];
    end;
  finally
    FreeAndNil(Q);
  end;
end;

function TORMQuery<T>.GetJoinSQL:String;
var i,j:integer;
    jc:TArray<TEntityClass>;
    ClassAdded:Boolean;
    s:string;
    EntityName:string;
begin
  Result:='';
  for i := 0 to High(fJoinClasses) do begin
    ClassAdded:=false;
    for j := 0 to High(jc) do begin
      if jc[j]=fJoinClasses[i].JoinEntity then begin
        ClassAdded:=true;
        break;
      end;
    end;

    if fORMObj.SelectFromView then begin
      if not ClassAdded then begin
        s:='';
        for j := 0 to High(fJoinClasses) do begin
          if fJoinClasses[j].JoinEntity=fJoinClasses[i].JoinEntity then begin
            if s<>'' then s:=s+' and ';
            s:=s+Format('%s.[%s]=%s.[%s]',[fJoinClasses[j].JoinEntity.ViewName,fJoinClasses[j].JoinField,fJoinClasses[j].Entity.ViewName,fJoinClasses[j].Field]);
          end;
        end;

        if Result='' then Result:=EntityClass.ViewName;

        Result:=' ('+Result+Format(' inner join %s on %s)',[fJoinClasses[i].JoinEntity.ViewName,s]);
        SetLength(jc,Length(jc)+1);
        jc[High(jc)]:=fJoinClasses[i].JoinEntity;
      end;
    end else begin
      if not ClassAdded then begin
        s:='';
        for j := 0 to High(fJoinClasses) do begin
          if fJoinClasses[j].JoinEntity=fJoinClasses[i].JoinEntity then begin
            if s<>'' then s:=s+' and ';
            s:=s+Format('%s.[%s]=%s.[%s]',[fJoinClasses[j].JoinEntity.EntityName,fJoinClasses[j].JoinField,fJoinClasses[j].Entity.EntityName,fJoinClasses[j].Field]);
          end;
        end;

        if Result='' then Result:=EntityClass.EntityName;

        Result:=' ('+Result+Format(' inner join %s on %s)',[fJoinClasses[i].JoinEntity.EntityName,s]);
        SetLength(jc,Length(jc)+1);
        jc[High(jc)]:=fJoinClasses[i].JoinEntity;
      end;
    end;



  end;

  if fORMObj.DatabaseType=odbPostgreSQL then begin
    Result:=ReplaceStr(Result,'[','"');
    Result:=ReplaceStr(Result,']','"');
  end;
end;

function TORMQuery<T>.ToSQL(QueryType:TQueryType):String;
var i,j:integer; s:string;
begin
  case QueryType of
    qtSelect: Result:='select *';
    qtSelectEx: if fDistinct then Result:='select DISTINCT %s' else Result:='select %s';
    qtCount: begin
      case fORMObj.fORMDatabase of
        odbAccess,odbSqlServer: Result:='select count(*) as [RowCount]';
        odbPostgreSQL: Result:='select count(*) as RowCount';
      end;
    end;
    qtMax: Result:='select MAX (%s) as ''MaxNo''';
  end;

  if Length(fJoinClasses)>0 then begin
    Result:=Result+' from '+GetJoinSQL;
  end else begin
    if fORMObj.SelectFromView then begin
      Result:=Result+Format(' from %s',[EntityClass.ViewName]);
    end else begin
      Result:=Result+Format(' from %s',[EntityClass.EntityName]);
    end;
  end;

  if fORMObj.fORMDatabase=odbPostgreSQL then begin
    fWhere:=ReplaceStr(fWhere,'[','"');
    fWhere:=ReplaceStr(fWhere,']','"');
  end;


  if fWhere<>'' then
    Result:=Result+Format(' where %s',[fWhere]);

  if fOrderBy<>'' then
    Result:=Result+Format(' order by %s',[fOrderBy]);

  if fFirst then begin
    case fORMObj.fORMDatabase of
      odbAccess,odbSqlServer: Result:=ReplaceStr(Result,'select','select TOP 1');
      odbPostgreSQL: Result:=Format(Result,[''])+' LIMIT 1';
    end;
  end;
end;

procedure TORMQuery<T>.InitClass(Condition:TORMCondition);
var i:integer;
begin
  if Condition.fClass=nil then begin
    Condition.fClass:=T;
  end;
  for i := 0 to High(Condition.Arr) do begin
    InitClass(Condition.Arr[i]);
  end;
end;

function TORMQuery<T>.Where(Condition:TORMCondition; AutoClear:Boolean=false):TORMQuery<T>;
begin
  InitClass(Condition);
  fWhere:=Condition.ToString(fORMObj);
  if AutoClear then
    Condition.Clear;
  Result:=Self;
end;

function TORMQuery<T>.OrderBy(Field:ORM.DataTypes.TField; OrderType:TOrderType=otASC):TORMQuery<T>;
var s:string;
begin
  if fOrderBy<>'' then fOrderBy:=fOrderBy+', ';

  if Field.EntityClass<>nil then begin
    if fORMObj.SelectFromView then begin
      fOrderBy:=fOrderBy+Field.EntityClass.ViewName+'.';
    end else begin
      fOrderBy:=fOrderBy+Field.EntityClass.EntityName+'.';
    end;
  end;

  case fORMObj.fORMDatabase of
    odbAccess,odbSqlServer: fOrderBy:=fOrderBy+'['+Field.Name+']';
    odbPostgreSQL: fOrderBy:=fOrderBy+'"'+Field.Name+'"';
  end;

  case OrderType of
    otASC: fOrderBy:=fOrderBy+' ASC';
    otDESC: fOrderBy:=fOrderBy+' DESC';
  end;
  Result:=Self;
end;

function TORMQuery<T>.OrderBy(Column:String; OrderType:TOrderType=otASC):TORMQuery<T>;
begin
  Result:=OrderBy(ORM.DataTypes.TField.Create(nil,Column),OrderType);
end;

function TORMQuery<T>.Distinct:TORMQuery<T>;
begin
  fDistinct:=true;
  Result:=Self;
end;

function TORMQuery<T>.Join(Class1:TEntityClass; Field1:String; Class2:TEntityClass; Field2:String):TORMQuery<T>;
var n:Integer;
begin
  n:=Length(fJoinClasses);
  SetLength(fJoinClasses,n+1);
  fJoinClasses[n].JoinEntity:=Class1;
  fJoinClasses[n].JoinField:=Field1;
  fJoinClasses[n].Entity:=Class2;
  fJoinClasses[n].Field:=Field2;

  Result:=Self;
end;

function TORMQuery<T>.Join(JoinClass:TEntityClass; JoinField:String; Field:String):TORMQuery<T>;
begin
  Result:=Join(JoinClass,JoinField,EntityClass,Field);
end;

function TORMQuery<T>.Join(JoinClass:TEntityClass):TORMQuery<T>;
var ei:TEntityInfo;
    i,j,n:integer;
    jc:TArray<TEntityClass>;
    hasClass:Boolean;
begin
  // extract different join classes
  n:=1;
  SetLength(jc,1);
  jc[0]:=EntityClass;

  for i := 0 to High(fJoinClasses) do begin
    hasClass:=false;
    for j := 0 to High(jc) do begin
      if jc[j]=fJoinClasses[i].JoinEntity then begin
        hasClass:=true;
        break;
      end;
    end;
    if not hasClass then begin
      SetLength(jc,n+1);
      jc[n]:=fJoinClasses[i].JoinEntity;
      inc(n);
    end;
  end;

  n:=0;
  ei:=JoinClass.GetEntityInfo;
  for i := 0 to High(ei.Columns) do begin
    if (ei.Columns[i].IsForeign) then begin
      hasClass:=false;
      for j := 0 to High(jc) do begin
        if jc[j]=ei.Columns[i].FKClass then begin
          hasClass:=true;
          break;
        end;
      end;

      if hasClass then begin
        n:=Length(fJoinClasses);
        SetLength(fJoinClasses,n+1);
        fJoinClasses[n].JoinEntity:=JoinClass;
        fJoinClasses[n].JoinField:=ei.Columns[i].Name;
        fJoinClasses[n].Field:=ei.Columns[i].FKColumn;
        fJoinClasses[n].Entity:=ei.Columns[i].FKClass;
      end;
    end;
  end;

  for i := 0 to High(jc) do begin
    ei:=jc[i].GetEntityInfo;
    for j := 0 to High(ei.Columns) do begin
      if (ei.Columns[j].IsForeign) and (ei.Columns[j].FKClass=JoinClass) then begin
        n:=Length(fJoinClasses);
        SetLength(fJoinClasses,n+1);
        fJoinClasses[n].JoinEntity:=JoinClass;
        fJoinClasses[n].JoinField:=ei.Columns[j].FKColumn;
        fJoinClasses[n].Field:=ei.Columns[j].Name;
        fJoinClasses[n].Entity:=jc[i];
      end;
    end;
  end;


  Result:=Self;
end;

function TORMQuery<T>.First:T;
var Arr:TArray<T>;
begin
  Result:=nil;
  try
    fFirst:=true;
    Arr:=Open;
    if Length(Arr)>0 then begin
      Result:=Arr[0];
      Arr[0]:=nil;
    end;
  finally
    fFirst:=false;
    TORM.FreeArr<T>(Arr);
  end;
end;

class function TORM.Equals(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conEquals,Value,EntityClass);
end;

class function TORM.More(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conMore,Value,EntityClass);
end;

class function TORM.MoreOrEqual(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conMoreOrEqual,Value,EntityClass);
end;

class function TORM.Less(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conLess,Value,EntityClass);
end;

class function TORM.LessOrEqual(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conLessOrEqual,Value,EntityClass);
end;

class function TORM.Likeis(Column:String; Value:TValue; EntityClass:TEntityClass=nil):TORMCondition;
begin
  Result.Init(Column,conLike,Value,EntityClass);
end;//class function Likeis

class procedure TORM.FreeArr<T>(var Arr:TArray<T>);
var i:integer;
begin
  for i := 0 to High(Arr) do begin
    FreeAndNil(Arr[i]);
  end;
  SetLength(Arr,0);
end;

class operator TORMCondition.LogicalAnd(a: TORMCondition; b: TORMCondition): TORMCondition;
begin
  Result.condType:=octAnd;
  SetLength(Result.Arr,2);
  Result.Arr[0]:=a;
  Result.Arr[1]:=b;
end;

class operator TORMCondition.LogicalOr(a: TORMCondition; b: TORMCondition): TORMCondition;
begin
  Result.condType:=octOr;
  SetLength(Result.Arr,2);
  Result.Arr[0]:=a;
  Result.Arr[1]:=b;
end;

class operator TORMCondition.LogicalXor(a: TORMCondition; b: TORMCondition): TORMCondition;
begin
  Result.condType:=octXor;
  SetLength(Result.Arr,2);
  Result.Arr[0]:=a;
  Result.Arr[1]:=b;
end;

class operator TORMCondition.LogicalNot(a: TORMCondition): TORMCondition;
begin
  Result.condType:=octNot;
  SetLength(Result.Arr,1);
  Result.Arr[0]:=a;
end;

function TORM.Sync(EntityClass:TEntityClass; CreateTable:Boolean=false; CreateColumns:Boolean=true; CreateKeys:Boolean=false; CreateCounters:Boolean=false):Integer;
const ColumnTypes:array[0..9,0..3] of string=(
// FieldType   Access   ProtgreSQL SQLServer
('Boolean','YESNO','boolean DEFAULT false','[bit]'),
('string','Varchar(%d)','character varying(%d) NOT NULL','[nvarchar](%d) COLLATE Cyrillic_General_CI_AS NULL'),
('Integer','INTEGER','integer','[int]'),
('Double','FLOAT','double precision','[float]'),
('TArray<System.Byte>','TEXT','text','[text]'),
('string(%d)','MEMO','text','[text]'),
('TMemoryStream','MEMO','text','[text]'),
('TDateTime','DATETIME','timestamp without time zone','[datetime]'),
('TDate','DATETIME','date','[date]'),
('TTime','DATETIME','time without time zone','[time]'));

var tables,fields:TStringList;
    i,j:integer;
    found,NewTable:Boolean;
    Q:TADOQuery;
    sql,fn,ft,pk,fk,t:string;
    InDB:TArray<Boolean>;
    ei:TEntityInfo;
    rt:TRttiType;
begin
  Result:=0;
  NewTable:=true;
  try
    tables:=TStringList.Create;
    fConn.GetTableNames(tables);
    for i := 0 to tables.Count-1 do begin
      if LowerCase(tables[i])=LowerCase(EntityClass.EntityName) then begin
        NewTable:=false;
        found:=true;
        break;
      end;
    end;
  finally
    FreeAndNil(tables);
  end;

  if (CreateTable) and (NewTable) then begin
    {$REGION 'Create table'}
    case fORMDatabase of
      odbAccess:     sql:='CREATE TABLE '+ EntityClass.EntityName;
      odbSqlServer:     sql:='CREATE TABLE '+ EntityClass.EntityName+' (_temp_column [bit]);';
      odbPostgreSQL: sql:='CREATE TABLE '+ EntityClass.EntityName+' ()';
    end;


    try
      Q:=TADOQuery.Create(nil);
      Q.Connection:=Connection;
      Q.SQL.Add(sql);
      TORM.Log(Self,'TORM.Sync: '+sql);
      Q.ExecSQL;
      Q.Close;
      Inc(Result);
    finally
      FreeAndNil(Q);
    end;
    {$ENDREGION}
  end else begin
    if NewTable then
      exit;
  end;

  ei:=EntityClass.GetEntityInfo;

  if CreateColumns then begin
    {$REGION 'Create columns'}
    try
      fields:=TStringList.Create;
      fConn.GetFieldNames(LowerCase(EntityClass.EntityName),fields);

      SetLength(InDB,Length(ei.Columns));

      for i:=0 to fields.Count-1 do begin
        for j := 0 to High(ei.Columns) do begin
          if LowerCase(fields[i])=LowerCase(ei.Columns[j].Name) then begin
            InDB[j]:=true;
          end;
        end;
      end;
    finally
      FreeAndNil(fields);
    end;

    rt:=TRttiContext.Create.GetType(EntityClass);
    try
      for i := 0 to High(ei.Columns) do begin
        //OutputDebugString(PChar(rt.GetField(ei.FieldNames[i]).FieldType.Name));
        if not InDB[i] then begin
          sql:='';

          fn:=rt.GetField(ei.FieldNames[i]).FieldType.Name;
          if ei.Columns[i].Len>255 then
            fn:='string(%d)';

          for j := 0 to High(ColumnTypes) do begin
            if ColumnTypes[j][0]=fn then begin
              ft:='';
              case fORMDatabase of
                odbAccess:     ft:=ColumnTypes[j][1];
                odbPostgreSQL: ft:=ColumnTypes[j][2];
                odbSqlServer:  ft:=ColumnTypes[j][3];
              end;
              if rt.GetField(ei.FieldNames[i]).FieldType.Name='string' then begin
                if ei.Columns[i].Len<=0 then
                  ei.Columns[i].Len:=255;
                ft:=Format(ft,[ei.Columns[i].Len]);
              end;
              case fORMDatabase of
                odbAccess:     sql:=Format('ALTER TABLE [%s] ADD COLUMN [%s] %s',[EntityClass.EntityName,ei.Columns[i].Name,ft]);
                odbSqlServer: begin
                  sql:=Format('ALTER TABLE [%s] ADD [%s] %s',[EntityClass.EntityName,ei.Columns[i].Name,ft]);
                  if ei.Columns[i].IsPrimary then begin
                    sql:=sql+'  IDENTITY(1,1) NOT NULL';
                  end;

                end;
                odbPostgreSQL: sql:=Format('ALTER TABLE %s ADD COLUMN "%s" %s',[EntityClass.EntityName,ei.Columns[i].Name,ft]);
              end;
            end;
          end;

          if sql='' then begin
            raise Exception.Create('Unable to add ['+ei.Columns[i].Name+'] column');
          end;


          if sql<>'' then begin
            try
              Q:=TADOQuery.Create(nil);
              Q.Connection:=Connection;
              Q.SQL.Add(sql);
              TORM.Log(Self,'TORM.Sync: '+sql);
              Q.ExecSQL;
              Q.Close;
              Inc(Result);
            finally
              FreeAndNil(Q);
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(rt);
    end;


    {$ENDREGION}
  end;

  if CreateKeys and NewTable then begin
    {$REGION 'Create keys'}


  // ADD PRIMARY KEYS
  pk:='';
  for i := 0 to High(ei.Columns) do begin
    if ei.Columns[i].IsPrimary then begin
      if pk<>'' then pk:=pk+',';
      case fORMDatabase of
        odbAccess, odbSqlServer:     pk:=pk+'['+ei.Columns[i].Name+']';
        odbPostgreSQL: pk:=pk+'"'+ei.Columns[i].Name+'"';
      end;
    end;
  end;

  if pk<>'' then begin
    try
      Q:=TADOQuery.Create(nil);
      Q.Connection:=Connection;
      case fORMDatabase of
        odbAccess, odbSqlServer:     sql:=Format('ALTER TABLE [%s] ADD PRIMARY KEY (%s)',[EntityClass.EntityName,pk]);
        odbPostgreSQL: sql:=Format('ALTER TABLE %s ADD PRIMARY KEY (%s)',[EntityClass.EntityName,pk]);
      end;

      Q.SQL.Add(sql);
      OutputDebugString(PChar('TORM.Sync: '+sql));
      Q.ExecSQL;
      Q.Close;
      Inc(Result);
    finally
      FreeAndNil(Q);
    end;
  end;
  // ADD FOREIGN KEYS
  try
    tables:=TStringList.Create;
    for i := 0 to High(ei.Columns) do begin
      if (ei.Columns[i].IsForeign) and (tables.IndexOf(ei.Columns[i].FKClass.EntityName)<0) then begin
        t:=ei.Columns[i].FKClass.EntityName;
        pk:='';
        fk:='';
        for j := i to High(ei.Columns) do begin
          if (ei.Columns[j].IsForeign) and (ei.Columns[j].FKClass.EntityName=t) then begin
            if pk<>'' then begin
              pk:=pk+',';
              fk:=fk+',';
            end;
            case fORMDatabase of
              odbAccess: begin
                pk:=pk+'['+ei.Columns[j].FKColumn+']';
                fk:=fk+'['+ei.Columns[j].Name+']';
              end;
              odbPostgreSQL: begin
                pk:=pk+'"'+ei.Columns[j].FKColumn+'"';
                fk:=fk+'"'+ei.Columns[j].Name+'"';
              end;
            end;
          end;
        end;

        if pk<>'' then begin
          try
            Q:=TADOQuery.Create(nil);
            Q.Connection:=Connection;
            case fORMDatabase of
              odbAccess, odbSqlServer:     sql:=Format('ALTER TABLE [%s] ADD FOREIGN KEY (%s) REFERENCES [%s](%s) ON DELETE CASCADE ON UPDATE CASCADE',[EntityClass.EntityName,fk,ei.Columns[i].FKClass.EntityName,pk]);
              odbPostgreSQL: sql:=Format('ALTER TABLE %s ADD FOREIGN KEY (%s) REFERENCES %s(%s) ON DELETE CASCADE ON UPDATE CASCADE',[EntityClass.EntityName,fk,ei.Columns[i].FKClass.EntityName,pk]);
            end;

            Q.SQL.Add(sql);
            OutputDebugString(PChar('TORM.Sync: '+sql));
            Q.ExecSQL;
            Q.Close;
            Inc(Result);
          finally
            FreeAndNil(Q);
          end;
        end;

        tables.Add(t);
      end;
    end;
  finally
    FreeAndNil(tables);
  end;


    {$ENDREGION}
  end;

  if CreateCounters and NewTable then begin
    {$REGION 'Create counters'}

    for i := 0 to High(ei.Columns) do begin
      if ei.Columns[i].AutoGeneration then begin
        try
          Q:=TADOQuery.Create(nil);
          Q.Connection:=Connection;
          sql:='';
          case fORMDatabase of
            odbAccess:     sql:=Format('ALTER TABLE [%s] ALTER COLUMN [%s] counter',[EntityClass.EntityName,ei.Columns[i].Name]);
            //odbSqlServer:  sql:=Format('ALTER TABLE [%s] ALTER COLUMN [%s] IDENTITY(1,1)',[EntityClass.EntityName,ei.Columns[i].Name]);
            odbPostgreSQL: begin
              sql:=Format('CREATE SEQUENCE %0:s_%1:s_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1; ',[EntityClass.EntityName,ei.Columns[i].Name]);
              sql:=sql+Format('ALTER TABLE %0:s_%1:s_seq OWNER TO "%s"; ',[EntityClass.EntityName,ei.Columns[i].Name,fOwner]);
              sql:=sql+Format('ALTER TABLE %0:s ALTER COLUMN "%1:s" SET DEFAULT nextval(''%0:s_%1:s_seq''); ',[EntityClass.EntityName,ei.Columns[i].Name]);
            end;
          end;

          if sql='' then continue;

          Q.SQL.Add(sql);
          OutputDebugString(PChar('TORM.Sync: '+sql));
          Q.ExecSQL;
          Q.Close;
          Inc(Result);
        finally
          FreeAndNil(Q);
        end;
      end;

    end;
    {$ENDREGION}
  end;

end;

function TORM.Sync(Entities:array of TEntityClass; CreateTable:Boolean=false; CreateColumns:Boolean=true; CreateKeys:Boolean=false; CreateCounters:Boolean=false):Integer;
var i:integer;
begin
  for i := 0 to High(Entities) do
    Sync(Entities[i],CreateTable,CreateColumns,CreateKeys,CreateCounters);
end;

procedure AddInsertAndUpdateQuery(const Q:TADOQuery; const Arr:TArray<TEntity>; DatabaseType:TORMDatabase; SaveMode:TSaveMode);
const insert_sql='INSERT INTO ' +
      '%s  ( %s ) ' +
      ' VALUES ' +
      '( %s );';
      update_sql='UPDATE %s ' +
      'SET %s ' +
      'where %s;';
var i,j,n,k:integer;
    rta:TArray<TRttiField>;
    ta:TArray<Integer>;
    EntityInfo:TEntityInfo;
    rt : TRttiType;
    cols,vals,val,tn,Filter,setstr:string;
    sl:TStringList;
    update:boolean;
begin
  if Length(Arr)=0 then exit;
  sl:=TStringList.Create;

  EntityInfo:=Arr[0].GetEntityInfo;
  rt:=TRttiContext.Create.GetType(Arr[0].ClassInfo);
  tn:=Arr[0].EntityName;
  SetLength(rta,EntityInfo.ColCount);
  SetLength(ta,EntityInfo.ColCount);
  n:=EntityInfo.ColCount;
  cols:='';
  for i := 0 to High(rta) do begin
    rta[i]:=rt.GetField(EntityInfo.FieldNames[i]);
    ta[i]:=-1;

    if rta[i].FieldType.Name='Boolean' then begin
      ta[i]:=1;
    end;

    if rta[i].FieldType.Name='string' then begin
      ta[i]:=2;
    end;

    if rta[i].FieldType.Name='Integer' then begin
      ta[i]:=3;
    end;

    if rta[i].FieldType.Name='Double' then begin
      ta[i]:=4;
    end;

    if rta[i].FieldType.Name='TDateTime' then begin
      ta[i]:=5;
    end;

    if rta[i].FieldType.Name='TMemoryStream' then begin
      ta[i]:=6;
    end;

    if rta[i].FieldType.Name='TDate' then begin
      ta[i]:=7;
    end;

    if rta[i].FieldType.Name='TTime' then begin
      ta[i]:=8;
    end;

    if (not EntityInfo.Columns[i].AutoGeneration) or (TORMConfig.UPDATE_IDENTITY) then begin
      if Length(cols)>0 then cols:=cols+',';
      case DatabaseType of
        odbAccess,odbSqlServer: cols:=cols+'['+EntityInfo.Columns[i].Name+']';
        odbPostgreSQL: cols:=cols+'"'+EntityInfo.Columns[i].Name+'"';
      end;


    end else begin
      ta[i]:=0;
    end;
  end;

  setstr:='';
  for i := 0 to High(Arr) do begin
    update:=(Length(Arr[i].PrimaryKeys)>0) and (SaveMode=smInsertOrUpdate);

    vals:='';
    setstr:='';
    for j := 0 to High(rta) do begin
      val:='';
      case ta[j] of
        -1: raise Exception.Create('Unknown ['+rta[j].FieldType.Name+'] field type');
        0: continue;
        1: case DatabaseType of
             odbAccess,odbSqlServer: if rta[j].GetValue(Arr[i]).AsBoolean then val:='1' else val:='0';
             odbPostgreSQL: if rta[j].GetValue(Arr[i]).AsBoolean then val:='TRUE' else val:='FALSE';
           end;
        2: val:=''''+rta[j].GetValue(Arr[i]).AsString+'''';
        3: val:=IntToStr(rta[j].GetValue(Arr[i]).AsInteger);
        4: val:=FloatToStr(rta[j].GetValue(Arr[i]).AsExtended);
        5: val:=''''+DateTimeToStr(rta[j].GetValue(Arr[i]).AsExtended)+'''';
        6: val:='''''';
        7: val:=''''+DateToStr(rta[j].GetValue(Arr[i]).AsExtended)+'''';
        8: val:=''''+TimeToStr(rta[j].GetValue(Arr[i]).AsExtended)+'''';
      end;

      if update then begin
        if Length(setstr)>0 then setstr:=setstr+',';
        case DatabaseType of
          odbAccess,odbSqlServer: setstr:=setstr+'['+EntityInfo.Columns[j].Name+']='+val;
          odbPostgreSQL: setstr:=setstr+'"'+EntityInfo.Columns[j].Name+'"='+val;
        end;
      end else begin
        if Length(vals)>0 then vals:=vals+',';
        vals:=vals+val;
      end;


    end;

    if update then begin
      {$REGION 'Update Query'}
      j:=0;
      Filter:='';
      for k := 0 to n - 1 do begin
        if EntityInfo.Columns[k].CType=ctPrimary then begin
          if Length(Filter)>0 then Filter:=Filter+' and ';
          //Filter:=Filter+EntityInfo.Columns[i].Name+'='+Arr[i].PrimaryKeys[j].ToString;

          case DatabaseType of
            odbAccess,odbSqlServer: Filter:=Filter+'['+EntityInfo.Columns[k].Name+']='+Arr[i].PrimaryKeys[j].ToString;
            odbPostgreSQL:Filter:=Filter+'"'+EntityInfo.Columns[k].Name+'"='+Arr[i].PrimaryKeys[j].ToString;
          end;

          Inc(j);
        end;
      end;

      sl.Add(Format(update_sql,[tn,setstr,Filter]));
      {$ENDREGION}
    end else begin
      sl.Add(Format(insert_sql,[tn,cols,vals]));
    end;
  end;

  Q.SQL.AddStrings(sl);
end;

function TORM.Save(Arr:TArray<TEntity>; SaveMode:TSaveMode=smInsertOrUpdate):Integer;
const _buf_size=8192; // 2^13
var Q:TADOQuery;
    buf:TArray<TEntity>;
    i,j:integer;
    n,m:integer;
    buf_size:integer;
begin

  Result:=0;
  if Length(Arr)=0 then exit;
  CheckConnection(TEntityClass(Arr[0].ClassType));
  if Assigned(fEntityRequest) then fEntityRequest(Self,TEntityClass(Arr[0].ClassType));

  if DatabaseType=odbAccess then begin
    buf_size:=1;
  end else begin
    buf_size:=_buf_size;
  end;

  try
    Q:=TADOQuery.Create(nil);
    Q.Connection:=fConn;
    if Length(Arr)<=buf_size then begin
      AddInsertAndUpdateQuery(Q,Arr,DatabaseType,SaveMode);
      //ArrToSql(Arr,Q.SQL);
      //OutputDebugStringCurrency('Q.SQL.Count',Q.SQL.Count);
      //Q.SQL.Delete(Q.SQL.Count-1);
      //Q.SQL.SaveToFile('C:\Temp\Insert.sql');
      Result:=Q.ExecSQL;
    end else begin
      SetLength(buf,buf_size);
      n:=Length(Arr) div buf_size;
      m:=Length(Arr) mod buf_size;
      for i := 0 to n - 1 do begin
        for j := 0 to buf_size-1 do begin
          buf[j]:=Arr[i*buf_size+j];
        end;
        AddInsertAndUpdateQuery(Q,buf,DatabaseType,SaveMode);
        Q.ExecSQL;
        Q.Close;
        Q.SQL.Clear;
      end;

      if m >0 then begin
        SetLength(buf,m);
        for i := 0 to m-1 do begin
          buf[i]:=Arr[n*buf_size+i];
        end;
        AddInsertAndUpdateQuery(Q,buf,DatabaseType,SaveMode);
        Q.ExecSQL;
        Q.Close;
        Q.SQL.Clear;
      end;

      Result:=Length(Arr);
    end;
  finally
    FreeAndNil(Q);
  end;
end;

function TORM.Insert(Arr:TArray<TEntity>):integer;
begin
  Result:=Save(Arr,smInsert);
end;

function TORM.CreateEntity(T:TEntityClass):TEntity;
begin
  Result:=TEntity(T.NewInstance);
  Result.Init;
end;

function TORM.Parent<T>(const Child:TEntity):T;
var ei:TEntityInfo;
    con:TORMCondition;
    q:TORMQuery<T>;
    i:integer;
    rc:TRttiContext;
    rt:TRttiType;

begin
  try
    ei:=Child.GetEntityInfo;
    rc:=TRttiContext.Create;
    rt:=rc.GetType(Child.ClassInfo);

    for i := 0 to High(ei.Columns) do begin
      if (ei.Columns[i].IsForeign) and (ei.Columns[i].FKClass=TEntityClass(T)) then begin
        if con.IsEmpty then begin
          con:=TORM.Equals(ei.Columns[i].FKColumn,rt.GetField(ei.FieldNames[i]).GetValue(TObject(Child)));
        end else begin
          con:=con and TORM.Equals(ei.Columns[i].FKColumn,rt.GetField(ei.FieldNames[i]).GetValue(TObject(Child)));
        end;
      end;
    end;

    if con.IsEmpty  then begin
      q:=Select<T>();
      q.Where(con);
      Result:=q.First;
    end else begin
      Result:=nil;
    end;

    //ei.Columns[0].
  finally
    FreeAndNil(rt);
    //FreeAndNil(ei);
    FreeAndNil(q);
  end;
end;

function TORM.Childs<T>(const Parent:TEntity):TArray<T>;
var ei,ei2:TEntityInfo;
    con:TORMCondition;
    q:TORMQuery<T>;
    i,j:integer;
    rc:TRttiContext;
    rt:TRttiType;
    val:TValue;
begin
  try
    ei:=T.GetEntityInfo;
    ei2:=Parent.GetEntityInfo;
    rc:=TRttiContext.Create;
    rt:=rc.GetType(Parent.ClassInfo);

    for i := 0 to High(ei.Columns) do begin
      if (ei.Columns[i].IsForeign) and (ei.Columns[i].FKClass=Parent.ClassType) then begin
        for j := 0 to High(ei2.Columns) do begin
          if ei2.Columns[j].Name=ei.Columns[i].FKColumn then begin
            val:=rt.GetField(ei2.FieldNames[j]).GetValue(TObject(Parent));
            if con.IsEmpty then begin
              con:=TORM.Equals(ei.Columns[i].Name,val);
            end else begin
              con:=con and TORM.Equals(ei.Columns[i].Name,val);
            end;
          end;
        end;


      end;
    end;

    if con.IsEmpty then begin
      q:=Select<T>();
      q.Where(con);
      Result:=q.Open;
    end else begin
      Result:=nil;
    end;

    //ei.Columns[0].
  finally
    FreeAndNil(rt);
    //FreeAndNil(ei);
    //FreeAndNil(ei2);
    FreeAndNil(q);
  end;
end;

constructor TORMResult.Create;
begin
  Fields:=TStringList.Create;
  fFieldIndex:=TDictionary<String,Integer>.Create;
end;

function TORMResult.GetField(Index:Integer):String;
begin
  Result:=Fields[Index];
end;

function TORMResult.Count:Integer;
begin
  Result:=Length(Data);
end;

function TORMResult.FieldsCount:Integer;
begin
  Result:=Fields.Count;
end;

function TORMResult.Value(Field:String; Index:Integer):Variant;
var idx:integer;
  i:integer;
  f:string;
begin
  Result:=NULL;
  if Index>High(Data) then exit;
  //Result:=0;
  //exit;

  if fFieldIndex.ContainsKey(Field) then begin
    Result:=Data[Index][fFieldIndex.Items[Field]];
  end else begin
    f:=LowerCase(Field);
    idx:=Fields.IndexOf(f);

    if idx>=0 then begin
      Result:=Data[Index][idx];
      fFieldIndex.Add(Field,idx);
    end else begin
      i:=Pos('.',Field);
      if i>0 then begin
        idx:=Fields.IndexOf(Copy(f,i+1,Length(f)-i));
        if (idx>=0) then begin
          Result:=Data[Index][idx];
          fFieldIndex.Add(Field,idx);
        end;

      end;
    end;
  end;
  //Result:=Value(nil,Field,Index);
end;

function TORMResult.Value(EntityClass:TEntityClass; Field:String; Index:Integer):Variant;
var f:ORM.DataTypes.TField;
    s:string;
begin
  f:=ORM.DataTypes.TField.Create(EntityClass,Field);
  Result:=Value(f.ToString,Index);

  //s:=EntityClass.EntityName;
  //Result:=Value(Field,Index);
end;

function TORMResult.ToLowerCase:TORMResult;
var i:integer;
begin
  for i := 0 to Fields.Count-1 do begin
    Fields.Strings[i]:=LowerCase(Fields.Strings[i]);
  end;
  Result:=self;
end;

procedure TORMResult.Free;
begin
  SetLength(Data,0,0);
  FreeAndNil(Fields);
end;

initialization begin
  TORMConfig.UPDATE_IDENTITY:=false;
  TORM.Log:=TORM.OnMessage;
end;

end.
