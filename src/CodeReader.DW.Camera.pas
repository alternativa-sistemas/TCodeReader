unit CodeReader.DW.Camera;

{*******************************************************}
{                                                       }
{                      Kastri                           }
{                                                       }
{         Delphi Worlds Cross-Platform Library          }
{                                                       }
{    Copyright 2020 Dave Nottage under MIT LICENSE      }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

{$I DW.GlobalDefines.inc}
interface

uses
  // RTL
  System.classes, System.Types, System.Messaging, System.Sensors,
  // FMX
  FMX.Controls, FMX.Media, FMX.Graphics,
  // DW
  CodeReader.DW.Types;

type
  TFaceDetectMode = (None, Simple, Full);

  TFaceDetectModes = set of TFaceDetectMode;

  TFace = record
    Bounds: TRectF;
    LeftEyePosition: TPointF;
    MouthPosition: TPointF;
    RightEyePosition: TPointF;
    Score: Integer;
  end;

  TFaces = array of TFace;

  TDetectedFacesEvent = procedure(Sender: TObject; const ImageStream: TStream; const Faces: TFaces) of object;

  TImageAvailableEvent = procedure(Sender: TObject; const ImageStream: TStream) of object;

  TCamera = class;

  TCustomPlatformCamera = class(TObject)
  private
    FCamera: TCamera;
    FCameraPosition: TDevicePosition;
    FFaceDetectMode: TFaceDetectMode;
    FFlashMode: TFlashMode;
    FWasActive: Boolean;
    procedure ApplicationEventMessageHandler(const Sender: TObject; const M: TMessage);
    function GetIsActive: Boolean;
    function GetCameraPosition: TDevicePosition;
    procedure ResetCamera;
    procedure ResignCamera;
    procedure RestoreCamera;
    procedure SetCameraPosition(const Value: TDevicePosition);
    procedure SetIsActive(const Value: Boolean);
  protected
    FAvailableFaceDetectModes: TFaceDetectModes;
    FIsActive: Boolean;
    FIsCapturing: Boolean;
    FIsFaceDetectActive: Boolean;
    FIsSwapping: Boolean;
    FMaxImageWidth: Integer;
    FMaxPreviewWidth: Integer;
    procedure SetMaxImageWidth(const Value: Integer); Virtual;
    procedure CaptureImage;
    procedure CloseCamera; virtual;
    procedure ContinuousCaptureChanged; virtual;
    procedure DoAuthorizationStatus(const AStatus: TAuthorizationStatus);
    procedure DoCaptureImage; virtual;
    procedure DoCapturedImage(const AImageStream: TStream);
    procedure DoDetectedFaces(const AImageStream: TStream; const AFaces: TFaces);
    procedure DoStatusChange;
    function GetFlashMode: TFlashMode;
    function GetPreviewControl: TControl; virtual;
    function GetResolutionHeight: Integer; virtual;
    function GetResolutionWidth: Integer; virtual;
    function GetCapturedHeight: Integer; virtual;
    function GetCapturedWidth: Integer; virtual;
    function GetCameraOrientation: Integer; Virtual;
    procedure InternalSetActive(const AValue: Boolean);
    procedure OpenCamera; virtual;
    procedure QueueAuthorizationStatus(const AStatus: TAuthorizationStatus);
    procedure RequestPermission; virtual; abstract;
    procedure SetFaceDetectMode(const Value: TFaceDetectMode); virtual;
    procedure SetFlashMode(const Value: TFlashMode);
    procedure StartCapture; virtual;
    procedure StopCapture; virtual;
    property IsActive: Boolean read GetIsActive write SetIsActive;
    property Camera: TCamera read FCamera;
    property CameraPosition: TDevicePosition read GetCameraPosition write SetCameraPosition;
    property FaceDetectMode: TFaceDetectMode read FFaceDetectMode write SetFaceDetectMode;
    property FlashMode: TFlashMode read GetFlashMode write SetFlashMode;
  public
    constructor Create(const ACamera: TCamera); virtual;
    destructor Destroy; override;
    Procedure DoFocus; Virtual; Abstract;
    property PreviewControl: TControl read GetPreviewControl;
    property MaxImageWidth : Integer Read FMaxImageWidth Write SetMaxImageWidth;
    Property CameraOrientation : Integer Read GetCameraOrientation;
    Property MaxPreviewWidth : Integer Read FMaxPreviewWidth Write FMaxPreviewWidth;
  end;

  TCamera = class(TObject)
  private
    FAuthorizationStatus: TAuthorizationStatus;
    FIncludeLocation: Boolean;
    FLocation: TLocationCoord2D;
    FPlatformCamera: TCustomPlatformCamera;
    FOnAuthorizationStatus: TAuthorizationStatusEvent;
    FOnDetectedFaces: TDetectedFacesEvent;
    FOnImageCaptured: TImageAvailableEvent;
    FOnStatusChange: TNotifyEvent;
    FMaxImageWidth: Integer;
    FMaxPreviewWidth: Integer;
    function GetIsActive: Boolean;
    function GetAvailableFaceDetectModes: TFaceDetectModes;
    function GetCameraPosition: TDevicePosition;
    function GetFaceDetectMode: TFaceDetectMode;
    function GetFlashMode: TFlashMode;
    function GetPreviewControl: TControl;
    function GetResolutionHeight: Integer;
    function GetResolutionWidth: Integer;
    procedure SetIsActive(const Value: Boolean);
    procedure SetCameraPosition(const Value: TDevicePosition);
    procedure SetFaceDetectMode(const Value: TFaceDetectMode);
    procedure SetFlashMode(const Value: TFlashMode);
    procedure SetMaxImageWidth(const Value: Integer);
    function GetCapturedHeight: Integer;
    function GetCapturedWidth: Integer;
    procedure SetMaxPreviewWidth(const Value: Integer);
    function GetCameraOrientation: Integer;
  protected
    procedure DoAuthorizationStatus(const AStatus: TAuthorizationStatus);
    procedure DoCapturedImage(const AImageStream: TStream);
    procedure DoDetectedFaces(const AImageStream: TStream; const AFaces: TFaces);
    procedure DoStatusChange;
  public
    constructor Create;
    Procedure DoFocus;
    destructor Destroy; override;
    /// <summary>
    ///   Captures a still image, returned in OnImageCaptured
    /// </summary>
    procedure CaptureImage;
    /// <summary>
    ///   Requests camera permissions, returned in OnAuthorizationStatus
    /// </summary>
    procedure RequestPermission;

    /// <summary>
    ///   Maximum image width on CaptureImage
    /// </summary>
    property MaxImageWidth : Integer Read FMaxImageWidth Write SetMaxImageWidth;

    /// <summary>
    ///   Maximum image width on preview
    /// </summary>
    property MaxPreviewWidth : Integer Read FMaxPreviewWidth Write SetMaxPreviewWidth;


    /// <summary>
    ///   Modes that are available for face detection
    /// </summary>
    property AvailableFaceDetectModes: TFaceDetectModes read GetAvailableFaceDetectModes;
    /// <summary>
    ///   Current authorization status
    /// </summary>
    property AuthorizationStatus: TAuthorizationStatus read FAuthorizationStatus;
    /// <summary>
    ///   Position of the currently selected camera, i.e. Front or Back
    /// </summary>
    property CameraPosition: TDevicePosition read GetCameraPosition write SetCameraPosition;
    /// <summary>
    ///   Currently selected mode of face detection
    /// </summary>
    property FaceDetectMode: TFaceDetectMode read GetFaceDetectMode write SetFaceDetectMode;
    /// <summary>
    ///   Currently selected flash mode
    /// </summary>
    property FlashMode: TFlashMode read GetFlashMode write SetFlashMode;
    /// <summary>
    ///   Include location data with the captured image. See also Location property
    /// </summary>
    property IncludeLocation: Boolean read FIncludeLocation write FIncludeLocation;
    /// <summary>
    ///   Location data to be included with the captured image.
    /// </summary>
    /// <remarks>
    ///   Set this value before calling CaptureImage
    /// </remarks>
    property Location: TLocationCoord2D read FLocation write FLocation;
    /// <summary>
    ///   Signifies whether or not the camera is active
    /// </summary>
    property IsActive: Boolean read GetIsActive write SetIsActive;
    /// <summary>
    ///   The control in which to show the camera preview
    /// </summary>
    property PreviewControl: TControl read GetPreviewControl;
    /// <summary>
    ///   Vertical resolution
    /// </summary>      
    property ResolutionHeight: Integer read GetResolutionHeight;
    /// <summary>
    ///   Horizontal resolution
    /// </summary>   
    property ResolutionWidth: Integer read GetResolutionWidth;
    /// <summary>
    ///   Event fired when an authorization request has returned
    /// </summary>
    property OnAuthorizationStatus: TAuthorizationStatusEvent read FOnAuthorizationStatus write FOnAuthorizationStatus;
    /// <summary>
    ///   Event fired when faces are detected
    /// </summary>
    property OnDetectedFaces: TDetectedFacesEvent read FOnDetectedFaces write FOnDetectedFaces;
    /// <summary>
    ///   Event fired when a still image is captured
    /// </summary>
    property OnImageCaptured: TImageAvailableEvent read FOnImageCaptured write FOnImageCaptured;
    /// <summary>
    ///   Event fired when the status of the camera changes
    /// </summary>
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
    Property CapturedWidth  : Integer Read GetCapturedWidth;
    Property CapturedHeight : Integer Read GetCapturedHeight;
    Property CameraOrientation : Integer Read GetCameraOrientation;
  end;

implementation

uses
  // FMX
  FMX.Platform,
  // DW
{$IF Defined(ANDROID)}
  CodeReader.DW.Camera.Android,
{$ENDIF}
{$IF Defined(IOS)}
  CodeReader.DW.Camera.iOS, DW.iOSapi.Helpers,
{$ENDIF}
  CodeReader.DW.Messaging;

type
  TPlatformCameraDefault = class(TCustomPlatformCamera)
  private
    FPreviewControl: TControl;
  protected
    function GetPreviewControl: TControl; override;
    procedure RequestPermission; override;
  public
    constructor Create(const ACamera: TCamera); override;
    procedure DoFocus; override;
    destructor Destroy; override;
  end;

{$IF Defined(MSWINDOWS)}
   TPlatformCamera = TPlatformCameraDefault;
{$ENDIF}

{ TPlatformCameraDefault }

constructor TPlatformCameraDefault.Create(const ACamera: TCamera);
begin
  inherited;
  FPreviewControl := TControl.Create(nil);
end;

destructor TPlatformCameraDefault.Destroy;
begin
  FPreviewControl.Free;
  inherited;
end;

procedure TPlatformCameraDefault.DoFocus;
begin
  // Do nothing.
end;

function TPlatformCameraDefault.GetPreviewControl: TControl;
begin
  Result := FPreviewControl;
end;

procedure TPlatformCameraDefault.RequestPermission;
begin
  // Do nothing.
end;

{ TCustomPlatformCamera }

constructor TCustomPlatformCamera.Create(const ACamera: TCamera);
begin
  inherited Create;
  FCamera := ACamera;
  FMaxPreviewWidth := 1200;
  TMessageManager.DefaultManager.SubscribeToMessage(TApplicationEventMessage, ApplicationEventMessageHandler);
end;

destructor TCustomPlatformCamera.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(TApplicationEventMessage, ApplicationEventMessageHandler);
  inherited;
end;

procedure TCustomPlatformCamera.InternalSetActive(const AValue: Boolean);
begin
  FIsActive := AValue;
  TThread.Synchronize(nil,
    procedure
    begin
      DoStatusChange;
    end);
end;

procedure TCustomPlatformCamera.ApplicationEventMessageHandler(const Sender: TObject; const M: TMessage);
var
  LEvent: TApplicationEvent;
begin
LEvent := TApplicationEventMessage(M).Value.Event;
case LEvent of
   TApplicationEvent.EnteredBackground : ResignCamera;
   TApplicationEvent.BecameActive      : RestoreCamera;
   end;
end;

procedure TCustomPlatformCamera.CaptureImage;
begin
DoCaptureImage;
end;

procedure TCustomPlatformCamera.CloseCamera;
begin
  //
end;

procedure TCustomPlatformCamera.ContinuousCaptureChanged;
begin
  //
end;

procedure TCustomPlatformCamera.DoAuthorizationStatus(const AStatus: TAuthorizationStatus);
begin
  FCamera.DoAuthorizationStatus(AStatus);
end;

procedure TCustomPlatformCamera.DoCapturedImage(const AImageStream: TStream);
begin
  AImageStream.Position := 0;
  FCamera.DoCapturedImage(AImageStream);
end;

procedure TCustomPlatformCamera.DoCaptureImage;
begin
  //
end;

procedure TCustomPlatformCamera.DoDetectedFaces(const AImageStream: TStream; const AFaces: TFaces);
begin
  AImageStream.Position := 0;
  FCamera.DoDetectedFaces(AImageStream, AFaces);
end;

procedure TCustomPlatformCamera.DoStatusChange;
begin
  FCamera.DoStatusChange;
end;

function TCustomPlatformCamera.GetIsActive: Boolean;
begin
  Result := FIsActive;
end;

function TCustomPlatformCamera.GetCameraOrientation: Integer;
begin
Result := 0;
end;

function TCustomPlatformCamera.GetCameraPosition: TDevicePosition;
begin
  Result := FCameraPosition;
end;

function TCustomPlatformCamera.GetCapturedHeight: Integer;
begin
Result := 0;
end;

function TCustomPlatformCamera.GetCapturedWidth: Integer;
begin
Result := 0;
end;

function TCustomPlatformCamera.GetFlashMode: TFlashMode;
begin
  Result := FFlashMode;
end;

function TCustomPlatformCamera.GetPreviewControl: TControl;
begin
  Result := nil;
end;

function TCustomPlatformCamera.GetResolutionHeight: Integer;
begin
  Result := 0;
end;

function TCustomPlatformCamera.GetResolutionWidth: Integer;
begin
  Result := 0;
end;

procedure TCustomPlatformCamera.OpenCamera;
begin
  //
end;

procedure TCustomPlatformCamera.QueueAuthorizationStatus(const AStatus: TAuthorizationStatus);
begin
  TThread.Queue(nil,
    procedure
    begin
      DoAuthorizationStatus(AStatus);
    end
  );
end;

procedure TCustomPlatformCamera.ResetCamera;
begin
  if FIsActive then
  begin
    CloseCamera;
    OpenCamera;
    FIsSwapping := False;
  end;
end;

procedure TCustomPlatformCamera.ResignCamera;
begin
FWasActive := FIsActive;
if FIsActive then
   CloseCamera;
end;

procedure TCustomPlatformCamera.RestoreCamera;
begin
if FWasActive then
   OpenCamera;
end;

procedure TCustomPlatformCamera.SetIsActive(const Value: Boolean);
begin
  if FIsActive <> Value then
  begin
    if Value then
      OpenCamera
    else
      CloseCamera;
  end;
end;

procedure TCustomPlatformCamera.SetMaxImageWidth(const Value: Integer);
begin
FMaxImageWidth := Value;
end;

procedure TCustomPlatformCamera.SetCameraPosition(const Value: TDevicePosition);
begin
  if Value <> FCameraPosition then
  begin
    FCameraPosition := Value;
    FIsSwapping := True;
    ResetCamera;
  end;
end;

procedure TCustomPlatformCamera.SetFaceDetectMode(const Value: TFaceDetectMode);
begin
  FFaceDetectMode := Value;
end;

procedure TCustomPlatformCamera.SetFlashMode(const Value: TFlashMode);
begin
  FFlashMode := Value;
end;

procedure TCustomPlatformCamera.StartCapture;
begin
  //
end;

procedure TCustomPlatformCamera.StopCapture;
begin
  //
end;

{ TCamera }

constructor TCamera.Create;
begin
  inherited;
  FPlatformCamera := TPlatformCamera.Create(Self);
  MaxImageWidth   := 0;
end;

destructor TCamera.Destroy;
begin
  FPlatformCamera.Free;
  inherited;
end;

procedure TCamera.DoAuthorizationStatus(const AStatus: TAuthorizationStatus);
begin
  FAuthorizationStatus := AStatus;
  if Assigned(FOnAuthorizationStatus) then
    FOnAuthorizationStatus(Self, FAuthorizationStatus);
end;

procedure TCamera.DoCapturedImage(const AImageStream: TStream);
begin
  if Assigned(FOnImageCaptured) then
    FOnImageCaptured(Self, AImageStream);
end;

procedure TCamera.DoDetectedFaces(const AImageStream: TStream; const AFaces: TFaces);
begin
  if Assigned(FOnDetectedFaces) then
    FOnDetectedFaces(Self, AImageStream, AFaces);
end;

procedure TCamera.DoFocus;
begin
FPlatformCamera.DoFocus;
end;

procedure TCamera.DoStatusChange;
begin
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self);
end;

function TCamera.GetIsActive: Boolean;
begin
  Result := FPlatformCamera.IsActive;
end;

function TCamera.GetAvailableFaceDetectModes: TFaceDetectModes;
begin
  Result := FPlatformCamera.FAvailableFaceDetectModes;
end;

function TCamera.GetCameraOrientation: Integer;
begin
Result := FPlatformCamera.CameraOrientation;
end;

function TCamera.GetCameraPosition: TDevicePosition;
begin
  Result := FPlatformCamera.CameraPosition;
end;

function TCamera.GetCapturedHeight: Integer;
begin
Result := FPlatformCamera.GetCapturedHeight;
end;

function TCamera.GetCapturedWidth: Integer;
begin
Result := FPlatformCamera.GetCapturedWidth;
end;

function TCamera.GetFaceDetectMode: TFaceDetectMode;
begin
  Result := FPlatformCamera.FaceDetectMode;
end;

function TCamera.GetFlashMode: TFlashMode;
begin
  Result := FPlatformCamera.FlashMode;
end;

function TCamera.GetPreviewControl: TControl;
begin
  Result := FPlatformCamera.PreviewControl;
end;

function TCamera.GetResolutionHeight: Integer;
begin
  Result := FPlatformCamera.GetResolutionHeight;
end;

function TCamera.GetResolutionWidth: Integer;
begin
  Result := FPlatformCamera.GetResolutionWidth;
end;

procedure TCamera.RequestPermission;
begin
  FPlatformCamera.RequestPermission;
end;

procedure TCamera.SetIsActive(const Value: Boolean);
begin
  FPlatformCamera.IsActive := Value;
end;

procedure TCamera.SetMaxImageWidth(const Value: Integer);
begin
FMaxImageWidth                := Value;
FPlatFormCamera.MaxImageWidth := Value;
end;

procedure TCamera.SetMaxPreviewWidth(const Value: Integer);
begin
FMaxPreviewWidth                := Value;
FPlatformCamera.MaxPreviewWidth := Value;
end;

procedure TCamera.SetCameraPosition(const Value: TDevicePosition);
begin
  FPlatformCamera.CameraPosition := Value;
end;

procedure TCamera.SetFaceDetectMode(const Value: TFaceDetectMode);
begin
  FPlatformCamera.FaceDetectMode := Value;
end;

procedure TCamera.SetFlashMode(const Value: TFlashMode);
begin
  FPlatformCamera.FlashMode := Value;
end;

procedure TCamera.CaptureImage;
begin
  if IsActive then
    FPlatformCamera.CaptureImage;
end;

end.
