//Patch your Web.HTTPApp.pas file with these changes to add support for SameSite in Cookies for ISAPI/Apache Module
//Add to your search path C:\Program Files (x86)\Embarcadero\Studio\x0.0\source\internet\

  TCookie = class(TCollectionItem)
  private
    FName: string;
    FValue: string;
    FPath: string;
    FDomain: string;
    FSameSite: string;
    FExpires: TDateTime;
    FSecure: Boolean;
    FHttpOnly: Boolean;
  protected
    function GetHeaderValue: string;
  public
    constructor Create(Collection: TCollection); override;
    procedure AssignTo(Dest: TPersistent); override;
    property Name: string read FName write FName;
    property Value: string read FValue write FValue;
    property Domain: string read FDomain write FDomain;
    property Path: string read FPath write FPath;
    property SameSite: string read FSameSite write FSameSite;
    property Expires: TDateTime read FExpires write FExpires;
    property Secure: Boolean read FSecure write FSecure;
    property HeaderValue: string read GetHeaderValue;
    property HttpOnly: Boolean read FHttpOnly write FHttpOnly;
  end;
  
TWebResponse = class(TObject)  
    procedure SetCookieField(Values: TStrings; const ADomain, APath: string;
      AExpires: TDateTime; ASecure: Boolean; AHttpOnly: Boolean = False; ASameSite: string = 'None');
end;  
  
constructor TCookie.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FExpires  := -1;
  FSameSite := 'None';
end;

procedure TCookie.AssignTo(Dest: TPersistent);
begin
  if Dest is TCookie then
    with TCookie(Dest) do
    begin
      Name := Self.FName;
      Value := Self.FValue;
      Domain := Self.FDomain;
      Path := Self.FPath;
      Expires := Self.FExpires;
      Secure := Self.FSecure;
      HttpOnly := Self.FHttpOnly;
      SameSite := Self.FSameSite;
    end else inherited AssignTo(Dest);
end;

function TCookie.GetHeaderValue: string;
var
  S: string;
begin
  S := Format('%s=%s; ', [TNetEncoding.URL.Encode(FName), TNetEncoding.URL.Encode(FValue)]);
  if Domain <> '' then
    S := S + Format('domain=%s; ', [Domain]);  { do not localize }
  if Path <> '' then
    S := S + Format('path=%s; ', [Path]);      { do not localize }
  if Expires > -1 then
    S := S +
      Format(FormatDateTime('"expires="' + sDateFormat + ' "GMT; "', Expires),  { do not localize }
        [DayOfWeekStr(Expires), MonthStr(Expires)]);
  if Secure then S := S + 'secure; ';  { do not localize }
  if HttpOnly then S := S + 'httponly; ';  { do not localize } //corrected
  if FSameSite <> '' then S := S + 'SameSite="'+FSameSite+'"; ';  { do not localize }
  if Copy(S, Length(S) - 1, MaxInt) = '; ' then
    SetLength(S, Length(S) - 2);
  Result := S;
end;


procedure TWebResponse.SetCookieField(Values: TStrings; const ADomain,
  APath: string; AExpires: TDateTime; ASecure: Boolean; AHttpOnly: Boolean = False; ASameSite: string = 'None');
var
  I: Integer;
begin
  for I := 0 to Values.Count - 1 do
    with Cookies.Add do
    begin
      Name := Values.Names[I];
      Value := Values.Values[Values.Names[I]];
      Domain := ADomain;
      Path := APath;
      Expires := AExpires;
      Secure := ASecure;
      HttpOnly := AHttpOnly;
      SameSite := ASameSite;
    end;
end;
