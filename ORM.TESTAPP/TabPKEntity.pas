unit TabPKEntity;

interface
uses ORM.DataTypes;
type
  FtabPK=record const
    PK='PK';
    X='X';
    Y='Y';
    H='H';
    X1='X1';
    Y1='Y1';
    H1='H1';
    Az='Az';
    X2='X2';
    Y2='Y2';
    H2='H2';
    PKType='PKType';
    MD='MD';
    ReceiverLoopSize='ReceiverLoopSize';
    Offset='Offset';
    Profile='Profile';
    ControlPK='ControlPK';
    Remarks='Remarks';
    fReserved='fReserved';
  end;//record

[Table('tab_PK')]
  TtabPK=class(TEntity)  //запись для таблицы tab_PK
  public
    [AutoGeneration]
    [Column(FtabPK.PK,ctPrimary)]
    PK:LongInt;

    [Column(FtabPK.X)]
    X:Double;

    [Column(FtabPK.Y)]
    Y:Double;

    [Column(FtabPK.H)]
    H:Double;

    [Column(FtabPK.X1)]
    X1:Double;

    [Column(FtabPK.Y1)]
    Y1:Double;

    [Column(FtabPK.H1)]
    H1:Double;

    [Column(FtabPK.Az)]
    Az:Double;

    [Column(FtabPK.X2)]
    X2:Double;

    [Column(FtabPK.Y2)]
    Y2:Double;

    [Column(FtabPK.H2)]
    H2:Double;

    [Column(FtabPK.PKType)]
    PKType:String;

    [Column(FtabPK.MD)]
    MD:LongInt;

    [Column(FtabPK.ReceiverLoopSize)]
    ReceiverLoopSize:Double;

    [Column(FtabPK.Offset)]
    Offset:Double;

    [Column(FtabPK.Profile)]
    Profile:Double;

    [Column(FtabPK.ControlPK)]
    ControlPK:Boolean;

    [Column(FtabPK.Remarks)]
    Remarks:Double;

    [Column(FtabPK.fReserved)]
    fReserved:String;
  end;//class(TEntity)


implementation

end.
