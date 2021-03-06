
{$i deltics.json.inc}

  unit Deltics.Json.Value;


interface

  uses
    TypInfo,
    Deltics.Datetime,
    Deltics.InterfacedObjects,
    Deltics.Unicode,
    Deltics.Json.Exceptions,
    Deltics.Json.Types;


  type
    TJsonValue = class(TComInterfacedObject, IJsonMutableValue)
    // IJsonValue
    protected
      function get_AsBoolean: Boolean;
      function get_AsCardinal: Cardinal; virtual;
      function get_AsDate: TDate;
      function get_AsTime: TTime;
      function get_AsDateTime: TDateTime;
      function get_AsDouble: Double; virtual;
      function get_AsEnum(const aTypeInfo: PTypeInfo): Integer;
      function get_AsExtended: Extended; virtual;
      function get_AsGuid: TGuid;
      function get_AsInt64: Int64; virtual;
      function get_AsInteger: Integer; virtual;
      function get_AsSingle: Single;
      function get_AsString: UnicodeString;
      function get_AsUtf8: Utf8String;
      function get_IsNull: Boolean;
      function get_ValueType: TValueType;
      procedure set_AsBoolean(const aValue: Boolean);
      procedure set_AsCardinal(const aValue: Cardinal); virtual;
      procedure set_AsDate(const aValue: TDate);
      procedure set_AsTime(const aValue: TTime);
      procedure set_AsDateTime(const aValue: TDateTime);
      procedure set_AsDouble(const aValue: Double); virtual;
      procedure set_AsExtended(const aValue: Extended); virtual;
      procedure set_AsGuid(const aValue: TGuid);
      procedure set_AsInt64(const aValue: Int64); virtual;
      procedure set_AsInteger(const aValue: Integer); virtual;
      procedure set_AsSingle(const aValue: Single);
      procedure set_AsString(const aValue: UnicodeString);
      procedure set_AsUtf8(const aValue: Utf8String);

    private
      fIsNull: Boolean;
      fValue: UnicodeString;
      fValueType: TValueType;
    protected
      constructor CreateArray;
      constructor CreateObject;
      procedure ErrorIfNull(ExceptionClass: EJsonClass = NIL);
      procedure SetNull;
      procedure SetValue(const aValueType: TValueType; const aValue: AnsiString); overload;
      procedure SetValue(const aValueType: TValueType; const aValue: UnicodeString); overload;
      procedure SetValueUtf8(const aValueType: TValueType; const aValue: Utf8String);
    public
      constructor Create;
      property AsString: UnicodeString read fValue write set_AsString;
      property IsNull: Boolean read fIsNull;
      property ValueType: TValueType read fValueType;
    end;



implementation

  uses
    SysUtils,
  {$ifNdef DELPHIXE__}
    Windows,
  {$endif}
    Deltics.Guids,
    Deltics.Strings,
    Deltics.Json.Utils;


  const
    VALUETYPENAME : array[jsObject..jsNull] of String = ('Object', 'Array', 'String', 'Number', 'Boolean', 'Null');


{ TJsonValue }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJsonValue.Create;
  begin
    inherited;

    fIsNull     := TRUE;
    fValueType  := jsNull;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJsonValue.CreateArray;
  begin
    inherited Create;

    fValueType := jsArray;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TJsonValue.CreateObject;
  begin
    inherited Create;

    fValueType := jsObject;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.ErrorIfNull(ExceptionClass: EJsonClass);
  begin
    if IsNull then
    begin
      if ExceptionClass = NIL then
        ExceptionClass := EJsonConvertError;

      raise ExceptionClass.Create('Value is null');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsBoolean: Boolean;
  var
    s: UnicodeString;
  begin
    ErrorIfNull;

    case ValueType of
      jsBoolean : result := (AsString = 'true');
      jsString  : begin
                    s := Wide.Lowercase(AsString);
                    if (s = 'true') then        result := TRUE
                     else if (s = 'false') then result := FALSE
                    else
                      raise EJsonConvertError.CreateFmt('''%s'' is not a valid Boolean value', [AsString]);
                  end;

    else
      raise EJsonConvertError.Create('Not a Boolean or String');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsCardinal: Cardinal;
  var
    i: Int64;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : begin
                    if  NOT TryStrToInt64(AsString, i)
                     or ((i < Low(Integer)) or (i > High(Integer))) then
                      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as a Cardinal', [AsString]);

                    result := Cardinal(i);
                  end;
    else
      raise EJsonConvertError.Create('Not a Number or String');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsDate: TDate;
  begin
    ErrorIfNull;

    case ValueType of
      jsString  : result := DateTimeFromISO8601(AsString, [dtDate]);
    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as a Date', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsTime: TTime;
  begin
    ErrorIfNull;

    case ValueType of
      jsString  : result := DateTimeFromISO8601(AsString, [dtTime]);
    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as a Time', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsDateTime: TDateTime;
  begin
    ErrorIfNull;

    case ValueType of
      jsString  : result := DateTimeFromISO8601(AsString, [dtDate, dtTime]);
    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as a Date/Time', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsDouble: Double;
  const
    MaxDouble: Double =  1.7976931348623157E+308;
    MinDouble: Double = -1.7976931348623157E+308;
  var
    e: Extended;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : begin
                    if  NOT TryStrToFloat(AsString, e)
                     or (e > MaxDouble) or (e < MinDouble) then
                      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Double', [AsString]);

                    result := e;
                  end;
    else
      raise EJsonConvertError.Create('Not a Number or String');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsEnum(const aTypeInfo: PTypeInfo): Integer;
  var
    enum: PTypeData;
  begin
    if IsNull then
      raise EJsonConvertError.Create('Null cannot be converted to Enum');

    case ValueType of
      jsNumber  : begin
                    enum := GetTypeData(aTypeInfo);

                    if  NOT TryStrToInt(AsString, result)
                     or (result < enum.MinValue)
                     or (result > enum.MaxValue) then
                      raise EJsonConvertError.CreateFmt('''%s'' is not a valid ordinal value for the enum ''%s''', [AsString, aTypeInfo.Name]);
                  end;
      jsString  : result := GetEnumValue(aTypeInfo, AsString);
    else
      raise EJsonConvertError.Create('Not a Number or String');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsExtended: Extended;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : if  NOT TryStrToFloat(AsString, result) then
                    raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Extended', [AsString]);
    else
      raise EJsonConvertError.Create('Not a Number or String');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsGuid: TGuid;
  begin
    if IsNull then
      raise EJsonConvertError.Create('Null cannot be converted to Guid');

    case ValueType of
      jsBoolean : raise EJsonConvertError.Create('Boolean cannot be converted to Guid');
      jsNumber  : raise EJsonConvertError.Create('Number cannot be converted to Guid');
      jsString  : if NOT Guid.FromString(AsString, result) then
                    EJsonConvertError.CreateFmt('''%s'' is not a valid Guid', [AsString]);
    else
      raise EJsonConvertError.Create('Cannot convert to Guid');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsInt64: Int64;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : if not TryStrToInt64(AsString, result) then
                    raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Int64', [AsString]);

    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Int64', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsInteger: Integer;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : if not TryStrToInt(AsString, result) then
                    raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Integer', [AsString]);
    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as an Integer', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsSingle: Single;
  begin
    ErrorIfNull;

    case ValueType of
      jsNumber,
      jsString  : if not TryStrToFloat(AsString, result) then
                    raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as Single', [AsString]);
    else
      raise EJsonConvertError.CreateFmt('''%s'' cannot be expressed as an Single', [AsString]);
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsString: UnicodeString;
  begin
    ErrorIfNull;
    result := fValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_AsUtf8: Utf8String;
  begin
    ErrorIfNull;
    result := Utf8.FromWide(fValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_IsNull: Boolean;
  begin
    result := fIsNull;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TJsonValue.get_ValueType: TValueType;
  begin
    result := fValueType;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.SetNull;
  begin
    fIsNull     := TRUE;
    fValue      := '';
    fValueType  := jsNull;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.SetValue(const aValueType: TValueType;
                                const aValue: AnsiString);
  begin
    SetValue(aValueType, Wide.FromAnsi(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.SetValue(const aValueType: TValueType;
                                const aValue: UnicodeString);
  begin
    fValueType  := aValueType;
    fValue      := aValue;
    fIsNull     := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.SetValueUtf8(const aValueType: TValueType;
                                    const aValue: Utf8String);
  begin
    fValueType  := aValueType;
    fValue      := Wide.FromUtf8(aValue);
    fIsNull     := FALSE;
  end;


//  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
//  function TJsonValue.IsEqual(const aOther: TJsonValue): Boolean;
//  begin
//    result := (ValueType = aOther.ValueType)
//              and (Name = aOther.Name)
//              and (AsString = aOther.AsString);
//  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsBoolean(const aValue: Boolean);
  begin
    case aValue of
      TRUE  : SetValue(jsBoolean, 'true');
      FALSE : SetValue(jsBoolean, 'false');
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsCardinal(const aValue: Cardinal);
  begin
    SetValue(jsNumber, IntToStr(Int64(aValue)));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsDateTime(const aValue: TDateTime);
  begin
    SetValue(jsString, DateTimeToISO8601(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsDouble(const aValue: Double);
  var
    opt: TFormatSettings;
  begin
    {$ifdef DELPHIXE__}
      opt := TFormatSettings.Create;
    {$else}
      GetLocaleFormatSettings(GetThreadLocale, opt);
    {$endif}
    SetValue(jsNumber, FloatToStr(aValue, opt));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsExtended(const aValue: Extended);
  var
    opt: TFormatSettings;
  begin
    {$ifdef DELPHIXE__}
      opt := TFormatSettings.Create;
    {$else}
      GetLocaleFormatSettings(GetThreadLocale, opt);
    {$endif}
    SetValue(jsNumber, FloatToStr(aValue, opt));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsGUID(const aValue: TGUID);
  begin
    SetValue(jsString, GUIDToString(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsInt64(const aValue: Int64);
  begin
    SetValue(jsNumber, IntToStr(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsInteger(const aValue: Integer);
  begin
    SetValue(jsNumber, IntToStr(aValue));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsSingle(const aValue: Single);
  var
    opt: TFormatSettings;
  begin
    {$ifdef DELPHIXE__}
      opt := TFormatSettings.Create;
    {$else}
      GetLocaleFormatSettings(GetThreadLocale, opt);
    {$endif}
    SetValue(jsNumber, FloatToStr(aValue, opt));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsString(const aValue: UnicodeString);
  begin
    SetValue(jsString, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsDate(const aValue: TDate);
  begin
    AsString := DateTimeToISO8601(aValue, [dtDate]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsTime(const aValue: TTime);
  begin
    AsString := DateTimeToISO8601(aValue, [dtTime]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TJsonValue.set_AsUtf8(const aValue: Utf8String);
  begin
    SetValueUtf8(jsString, aValue);
  end;





end.

