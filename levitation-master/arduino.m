(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



BeginPackage["arduino`",{"NETLink`","customListPlots`"}];
InstallNET[];


serialPortOpen=False;
arduinoAction = False;
arduinoSaveData = True;

numberOfActionParams = 16;

actionParams=Table[0,{numberOfActionParams}];

defaultBaudRate = 57600;
fastBaudRate = 1000000;
readBufferSize = 16384;
receivedBytesThreshold = 2048;

serialPort = NETNew["System.IO.Ports.SerialPort","COM8"];

serialPort@BaudRate = fastBaudRate;
serialPort@ReceivedBytesThreshold = receivedBytesThreshold;
(*serialPort@ReceivedBytesThreshold = 1*)
serialPort@ReadBufferSize = readBufferSize;

readBuffer = NETNew["System.Byte[]", serialPort@ReadBufferSize];

dataBuffer = Table[0,{10000000}];

dataIndex = 1;
bytesReceived := dataIndex - 1;

serialEventHandler = AddEventHandler[serialPort@DataReceived,mySerialEventFn];



readReceivedData[]:=Block[
	{btr,buff},

	btr = serialPort@BytesToRead;
	If[btr> readBufferSize/2,
	Print[{"bytes to read", btr}];
	];
	If[btr > 0,
	serialPort@Read[readBuffer, 0, btr];
	If[arduinoSaveData,
	buff=NETObjectToExpression[readBuffer];
dataBuffer[[dataIndex;;dataIndex + btr - 1]] = buff[[1;;btr]];
	dataIndex += btr]
	]
]

mySerialEventFn[sender_,evt_]:=readReceivedData[]

sendCommand[command_,p1_,p2_]:=Block[
	{bytes},
	bytes=MakeNETObject[Flatten[{ToCharacterCode[command],p1,p2}],"System.Byte[]"];
	serialPort@Write[bytes,0,3];
	ReleaseNETObject[bytes]
]

sendBytes[data_]:=Block[
	{bytes},
	bytes=MakeNETObject[data,"System.Byte[]"];
	serialPort@Write[bytes,0,Length[data]];
	ReleaseNETObject[bytes]
]

cleanup[]:=ReleaseNETObject/@{serialPort,readBuffer,serialEventHandler}

arduinoOpen[]:=(serialPort@Open[];serialPortOpen =True)

arduinoClose[]:=(serialPort@Close[];serialPortOpen = False)

resetReceivedData[]:=(dataIndex = 1)

receivedData[]:=(dataBuffer[[1;;dataIndex-1]])

arduinoStart[]:=Module[{com},
	com = Flatten[{Mod[#,256],Floor[#/256]}&/@actionParams];
	(sendBytes[{#}])&/@com;
	arduinoAction=True
]

arduinoStart[bytes_]:=(
sendBytes[bytes];
arduinoAction = True
)

arduinoStop[]:=(sendBytes[{0}];arduinoAction=False)



EndPackage[]


