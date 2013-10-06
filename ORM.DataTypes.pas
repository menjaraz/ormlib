unit ORM.DataTypes;

interface

uses RTTI, Classes, Generics.Collections;

type

  TSimpleAttribute=class(TCustomAttribute)
  private
    fName:string;
  public
    constructor Create(Name:String);
    property Name:String read fName;
  end;

  Table=class(TSimpleAttribute);
  View=class(TSimpleAttribute);

  TColumnType=(ctPrimary,ctCommon);

  Column = class(TCustomAttribute)
  private
    fName:string;
    fCType:TColumnType;
    fLen:Integer;
  public
    constructor Create(FieldName:String; ColumnType:TColumnType=ctCommon); overload;
    constructor Create(FieldName:String; Len:Integer); overload;

    property Name:String read fName;
    property CType:TColumnType read fCType;
  end;

  AutoGeneration = class(TCustomAttribute);

  TEntity=class;

  TEntityClass=class of TEntity;

  TColumn=record
    Name:string;
    CType:TColumnType;
    Len:Integer;
    AutoGeneration:Boolean;
    IsPrimary:Boolean;
    IsForeign:Boolean;
    FKClass:TEntityClass;
    FKColumn:String;

    procedure Load(Col:Column);
  end;

  TEntityInfo=record
  private
    fEntityClass:Pointer;
    fColCount:Integer;
    fColumns:TArray<TColumn>;
    fFieldNames:TArray<String>;
    function GetColumnType(Column:String):String;
  public
    constructor Create(EntityClass:Pointer);
    property ColCount:Integer read fColCount;
    property Columns:TArray<TColumn> read fColumns;
    property FieldNames:TArray<String> read fFieldNames;
    property ColumnType[Column:String]:String read GetColumnType;
  end;

  TEntity=class
  private
    class var fEntitiesName:TDictionary<String, String>;
    class var fEntitiesInfo:TDictionary<String, TEntityInfo>;
  public
    PrimaryKeys:TArray<TValue>;
    class function EntityName:String;
    class function ViewName:String;
    class function GetEntityInfo:TEntityInfo;
    constructor Create;
    procedure SetAsNew;
    procedure Init; virtual; abstract;
  end;

  ForeignKey=class(TCustomAttribute)
  private
    fEntityClass:TEntityClass;
    fColumnName:String;
  public
    constructor Create(EntityClass:TEntityClass; ColumnName:String);
    property EntityClass:TEntityClass read fEntityClass;
    property ColumnName:string read fColumnName;
  end;



  TFieldType=(ftNone,ftALL);

  TField=record
  private
    FieldType:TFieldType;
  public
    EntityClass:TEntityClass;
    Name:String;
    constructor Create(EntityClass:TEntityClass; Name:String);
    constructor ALL(EntityClass:TEntityClass);
    function ToString:String;
  end;

  function EntityToStr(Entity:TEntity):String;

implementation

uses SysUtils;

constructor TEntity.Create;
begin
  Init;
end;

procedure TEntity.SetAsNew;
begin
  SetLength(PrimaryKeys,0);
end;

procedure TColumn.Load(Col:Column);
begin
  Self.Name:=Col.Name;
  Self.CType:=Col.CType;
  Self.Len:=Col.fLen;
end;

constructor TSimpleAttribute.Create(Name:String);
begin
  fName:=Name;
end;

constructor Column.Create(FieldName:String; ColumnType:TColumnType=ctCommon);
begin
  fName:=FieldName;
  fCType:=ColumnType;
  fLen:=-1;
end;

constructor Column.Create(FieldName:String; Len:Integer);
begin
  fName:=FieldName;
  fCType:=ctCommon;
  fLen:=Len;
end;

constructor ForeignKey.Create(EntityClass:TEntityClass; ColumnName:String);
begin
  fEntityClass:=EntityClass;
  fColumnName:=ColumnName;
end;

constructor TEntityInfo.Create(EntityClass:Pointer);
var arr:TArray<TRttiField>;
    c : TRttiContext;
    t : TRttiType;
    a : TCustomAttribute;
    i:integer;
    ag,fk:boolean;

    fkclass:TEntityClass;
    fkcol:String;
begin
  fEntityClass:=EntityClass;
  fColCount:=0;
  c:=TRttiContext.Create;
  t:=c.GetType(EntityClass);
  arr:=t.GetFields;

  for i := 0 to High(arr) do begin
    ag:=false;
    fk:=false;
    for a in arr[i].GetAttributes do begin
      if a is AutoGeneration then begin
        ag:=true;
      end;

      if a is ForeignKey then begin
        fk:=true;
        fkclass:=ForeignKey(a).EntityClass;
        fkcol:=ForeignKey(a).ColumnName;
      end;
    end;
    for a in arr[i].GetAttributes do begin
      if a is Column then begin
        SetLength(fFieldNames,fColCount+1);
        SetLength(fColumns,fColCount+1);

        fFieldNames[fColCount]:=arr[i].Name;
        fColumns[fColCount].Load(Column(a));
        fColumns[fColCount].AutoGeneration:=ag;

        fColumns[fColCount].IsPrimary:=(Column(a).fCType=ctPrimary);

        fColumns[fColCount].IsForeign:=fk;
        fColumns[fColCount].FKClass:=fkclass;
        fColumns[fColCount].FKColumn:=fkcol;

        Inc(fColCount);
      end;
    end;
  end;
end;

function TEntityInfo.GetColumnType(Column:String):String;
var c:TRttiContext;
    t:TRttiType;
    i:integer;
begin
  Result:='Unknown';
  try
    for i := 0 to High(fColumns) do begin
      if fColumns[i].Name=Column then begin
        c:=TRttiContext.Create;
        t:=c.GetType(fEntityClass);
        Result:= t.GetField(fFieldNames[i]).FieldType.Name;
        break;
      end;
    end;

    //t.GetField()
  finally
    FreeAndNil(t);
  end;

end;

class function TEntity.EntityName:String;
var c : TRttiContext;
    t : TRttiType;
    a : TCustomAttribute;
begin
  if fEntitiesName=nil then begin
    fEntitiesName:=TDictionary<String,String>.Create;
  end;

  if fEntitiesName.ContainsKey(ClassName) then begin
    Result:=fEntitiesName.Items[ClassName];
  end else begin
    Result:=ClassName;

    c:=TRttiContext.Create;
    t:=c.GetType(ClassInfo);
    for a in t.GetAttributes do begin
      if a is Table then begin
        if Length(Table(a).Name)>0 then begin
          Result:=Table(a).Name;
        end;
      end;
    end;
    fEntitiesName.Add(ClassName,Result);
  end;
end;

class function TEntity.ViewName:String;
var c : TRttiContext;
    t : TRttiType;
    a : TCustomAttribute;
begin
  Result:=ClassName;

  c:=TRttiContext.Create;
  t:=c.GetType(ClassInfo);
  for a in t.GetAttributes do begin
    if a is Table then begin
      if Length(Table(a).Name)>0 then begin
        Result:=Table(a).Name;
      end;
    end;
    if a is View then begin
      if Length(View(a).Name)>0 then begin
        Result:=View(a).Name;
        break;
      end;
    end;
  end;
end;

class function TEntity.GetEntityInfo:TEntityInfo;
begin
  if fEntitiesInfo=nil then begin
    fEntitiesInfo:=TDictionary<String,TEntityInfo>.Create;
  end;

  if fEntitiesInfo.ContainsKey(EntityName) then begin
    Result:=fEntitiesInfo.Items[EntityName];
  end else begin
    Result:=TEntityInfo.Create(ClassInfo);
    fEntitiesInfo.Add(EntityName,Result);
  end;
  Result:=TEntityInfo.Create(ClassInfo);
end;

constructor TField.Create(EntityClass:TEntityClass; Name:String);
begin
  Self.EntityClass:=EntityClass;
  Self.Name:=Name;
  FieldType:=ftNone;
end;

constructor TField.ALL(EntityClass:TEntityClass);
begin
  Self.EntityClass:=EntityClass;
  FieldType:=ftALL;
end;

function TField.ToString:String;
begin
  Result:='';
  case FieldType of
    ftNone: begin
      if EntityClass<>nil then begin
        Result:=EntityClass.EntityName+'.';
      end;
      Result:=Result+Name;
    end;
    ftALL: begin
      Result:=Format('%s.*',[EntityClass.EntityName]);
    end;
  end;
end;

function EntityToStr(Entity:TEntity):String;

  procedure AddParam(var S:String; Name:String; Value:String);
  begin
    if Length(S)>0 then
      S:=S+#9;
    S:=S+Name+'='+Value;
  end;

var rt : TRttiType;
    EntityInfo:TEntityInfo;
    i,n:integer;
    s:string;
begin
  Result:='';
  EntityInfo:=Entity.GetEntityInfo;
  n:=EntityInfo.ColCount;

  rt:=TRttiContext.Create.GetType(Entity.ClassInfo);
    for i := 0 to n - 1 do begin
      try
          if rt.GetField(EntityInfo.FieldNames[i]).FieldType.Name='Boolean' then begin
            if rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).AsBoolean then begin
              AddParam(Result,EntityInfo.FieldNames[i],'TRUE');
            end else begin
              { TODO -oGROM : bool or int??? }
              AddParam(Result,EntityInfo.FieldNames[i],'FALSE');
            end;
          end else begin
            if rt.GetField(EntityInfo.FieldNames[i]).FieldType.Name='TMemoryStream' then begin

            end else begin
              AddParam(Result,EntityInfo.FieldNames[i], rt.GetField(EntityInfo.FieldNames[i]).GetValue(TObject(Entity)).ToString);
            end;
          end;

      except
        on E:Exception do begin
          raise Exception.Create('EntityToStr: [Field='+EntityInfo.Columns[i].Name+'] '+E.Message);
        end;
      end;
    end;
end;

end.
