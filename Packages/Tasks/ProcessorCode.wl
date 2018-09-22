(* ::Package:: *)

Block[{term = "<wolfram:slot id='term'/>", dir = "<wolfram:slot id='dir'/>", bin = Databin["<wolfram:slot id='short-id'/>"]},
 Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterProcessor.wl"}]]];
 Do[
  Print[file];
  TwitterProcessor`ProcessRawTwitterFile[file, bin, dir],
  {file, FileNames["*-"<>term, URLBuild[{dir, "Holding"}]]}
 ];
 "Done"
]
