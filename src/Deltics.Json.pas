{
  * X11 (MIT) LICENSE *

  Copyright � 2011 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Smith
  skype           : deltics
  e-mail          : <EXTLINK mailto: jsmith@deltics.co.nz>jsmith@deltics.co.nz</EXTLINK>
  website         : <EXTLINK http://www.deltics.co.nz>www.deltics.co.nz</EXTLINK>
}

{$i deltics.json.inc}

  unit Deltics.Json;


interface

  uses
    Deltics.Strings,
    Deltics.Json.Exceptions,
    Deltics.Json.Factories,
    Deltics.Json.Formatter,
    Deltics.Json.Types,
    Deltics.Json.Utils;


  type
    TJsonValueType = Deltics.Json.Types.TValueType;
  const
    jsObject    = Deltics.Json.Types.jsObject;
    jsArray     = Deltics.Json.Types.jsArray;
    jsString    = Deltics.Json.Types.jsString;
    jsNumber    = Deltics.Json.Types.jsNumber;
    jsBoolean   = Deltics.Json.Types.jsBoolean;
    jsNull      = Deltics.Json.Types.jsNull;


  type
    TJsonDateTimeParts = Deltics.Json.Utils.TJsonDateTimeParts;
    TJsonDatePart      = Deltics.Json.Utils.TJsonDatePart;
  const
    dpYear    = Deltics.Json.Utils.dpYear;
    dpMonth   = Deltics.Json.Utils.dpMonth;
    dpDay     = Deltics.Json.Utils.dpDay;
    dpTime    = Deltics.Json.Utils.dpTime;
    dpOffset  = Deltics.Json.Utils.dpOffset;


  type
    TJsonFormat = Deltics.Json.Types.TJsonFormat;
  const
    jfStandard  = Deltics.Json.Types.jfStandard;
    jfCompact   = Deltics.Json.Types.jfCompact;
    jfConfig    = Deltics.Json.Types.jfConfig;


  type
    EJsonConvertError = Deltics.Json.Exceptions.EJsonConvertError;


  type
    IJsonArray        = Deltics.Json.Types.IJsonArray;
    IJsonCollection   = Deltics.Json.Types.IJsonCollection;
    IJsonMutableValue = Deltics.Json.Types.IJsonMutableValue;
    IJsonObject       = Deltics.Json.Types.IJsonObject;
    IJsonValue        = Deltics.Json.Types.IJsonValue;

    Json        = Deltics.Json.Utils.Json;

    JsonArray   = Deltics.Json.Factories.JsonArray;
    JsonObject  = Deltics.Json.Factories.JsonObject;
    JsonNull    = Deltics.Json.Factories.JsonNull;



  function JsonBoolean: Deltics.Json.Factories.JsonBoolean; overload;
  function JsonBoolean(const aValue: Boolean): IJsonMutableValue; overload;

  function JsonNumber: Deltics.Json.Factories.JsonNumber; overload;
  function JsonNumber(const aValue: Cardinal): IJsonMutableValue; overload;
  function JsonNumber(const aValue: Double): IJsonMutableValue; overload;
  function JsonNumber(const aValue: Extended): IJsonMutableValue; overload;
  function JsonNumber(const aValue: Integer): IJsonMutableValue; overload;
  function JsonNumber(const aValue: Int64): IJsonMutableValue; overload;

  function JsonString: Deltics.Json.Factories.JsonString; overload;
  function JsonString(const aValue: UnicodeString): IJsonMutableValue; overload;
  function JsonString(const aValue: Utf8String): IJsonMutableValue; overload;


implementation

  uses
    Deltics.Json.Value;



  function JsonBoolean: Deltics.Json.Factories.JsonBoolean;
  begin
    result := Deltics.Json.Factories.JsonBooleanFactory;
  end;


  function JsonBoolean(const aValue: Boolean): IJsonMutableValue;
  begin
    result := JsonBoolean.AsBoolean(aValue);
  end;





  function JsonNumber: Deltics.Json.Factories.JsonNumber;
  begin
    result := Deltics.Json.Factories.JsonNumberFactory;
  end;


  function JsonNumber(const aValue: Cardinal): IJsonMutableValue;
  begin
    result := JsonNumber.AsCardinal(aValue);
  end;


  function JsonNumber(const aValue: Double): IJsonMutableValue;
  begin
    result := JsonNumber.AsDouble(aValue);
  end;


  function JsonNumber(const aValue: Extended): IJsonMutableValue;
  begin
    result := JsonNumber.AsExtended(aValue);
  end;


  function JsonNumber(const aValue: Int64): IJsonMutableValue;
  begin
    result := JsonNumber.AsInt64(aValue);
  end;


  function JsonNumber(const aValue: Integer): IJsonMutableValue;
  begin
    result := JsonNumber.AsInteger(aValue);
  end;








  function JsonString: Deltics.Json.Factories.JsonString;
  begin
    result := Deltics.Json.Factories.JsonStringFactory;
  end;


  function JsonString(const aValue: UnicodeString): IJsonMutableValue;
  begin
    result := JsonString.AsString(aValue);
  end;


  function JsonString(const aValue: Utf8String): IJsonMutableValue;
  begin
    result := JsonString.Asutf8(aValue);
  end;






end.
