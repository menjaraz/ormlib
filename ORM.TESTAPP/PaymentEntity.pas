unit PaymentEntity;

interface

uses ORM.DataTypes, UserEntity;

type

    FPayment=record const
      Id='payment_id';
      User='user_id';
      Total='payment_total';
      Date='payment_date';
    end;

    [Table('payment_tab')]
    TPayment=class(TEntity)
    public
      [Column(FPayment.Id,ctPrimary)]
      Id:LongInt;

      [Column(FPayment.User)]
      [ForeignKey(TUser,FUser.Id)]
      User:LongInt;

      [Column(FPayment.Total)]
      Total:Double;

      [Column(FPayment.Date)]
      Date:TDateTime;

      procedure Init(); override;
    end;

implementation

procedure TPayment.Init();
begin

end;

end.
