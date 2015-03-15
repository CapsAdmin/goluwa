local env = ...

local function make_is(name) 
	env["is" .. name:lower()] = function(var) 
		return type(var) == name
	end
end

make_is("nil")
make_is("string")
make_is("number")
make_is("table")
make_is("bool")
make_is("Entity")
make_is("Angle")
make_is("Vector")
make_is("Color")
make_is("function")

function Material() end
function DEFINE_BASECLASS() end
function GetGlobalVector() end
function CreateSound() end
function AddConsoleCommand() end
function TypeID() end
function CompileString() end
function Msg() end
function MsgN() end
function BroadcastLua() end
function NamedColor() end
function Mesh() end
function EyeAngles() end
function LoadPresets() end
function EmitSound() end
function EmitSentence() end
function SetGlobalEntity() end
function SetGlobalAngle() end
function SetGlobalVector() end
function SetGlobalString() end
function GetGlobalInt() end
function SetGlobalInt() end
function GetViewEntity() end
function DOFModeHack() end
function IsEntity() end
function AddCSLuaFile() end
function ParticleEffectAttach() end
function UnPredictedCurTime() end
function ConVarExists() end
function GetConVarString() end
function ErrorNoHalt() end
function DebugInfo() end
function SetGlobalBool() end
function VGUIFrameTime() end
function FrameTime() end
function RunString() end
function DisableClipping() end
function FrameNumber() end
function Player() end
function IsFirstTimePredicted() end
function DamageInfo() end
function Entity() end
function GetHUDPanel() end
function Matrix() end
function ClientsideScene() end
function HSVToColor() end
function isentity() end
function Error() end
function PrecacheParticleSystem() end
function EffectData() end
function isthisbroken() end
function MsgC() end
function DeriveGamemode() end
function ColorToHSV() end
function AddonMaterial() end
function GetConVarNumber() end
function LocalToWorld() end
function MsgAll() end
function GetGlobalFloat() end
function str() end
function EyeVector() end
function RunConsoleCommand() end
function LerpVector() end
function CreateConVar() end
function DynamicLight() end
function GetGlobalEntity() end
function GetGlobalBool() end
function int() end
function Cvar() end
function WorldToLocal() end
function RunStringEx() end
function ScrH() end
function ParticleEmitter() end
function GetGlobalAngle() end
function ScrW() end
function GetRenderTarget() end
function CreateClientConVar() end
function SetPhysConstraintSystem() end
function OrderVectors() end
function SoundDuration() end
function FindMetaTable() end
function EyePos() end
function SavePresets() end
function RenderAngles() end
function ParticleEffect() end
function SetGlobalFloat() end
function ClientsideRagdoll() end

function GetGlobalString() end
function CompileFile() end
function CreateMaterial() end
function ProtectedCall() end
function SetClipboardText() end
function LerpAngle() end
function GetRenderTargetEx() end
function ClientsideModel() end
function Localize() end