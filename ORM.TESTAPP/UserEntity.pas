unit UserEntity;

interface

uses ORM.DataTypes;

type

    FUser=record const
      Id='user_id';
      Name='user_name';
      Age='user_age';
    end;

    [Table('user_tab')]
    TUser=class(TEntity)
    public
      [AutoGeneration]
      [Column(FUser.Id,ctPrimary)]
      Id:LongInt;

      [Column(FUser.Name,60)]
      Name:String;

      [Column(FUser.Age)]
      Age:Double;
      procedure Init; override;
    end;

implementation

procedure TUser.Init;
begin
  Id:=-1;
end;

end.
