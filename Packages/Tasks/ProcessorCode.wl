(* ::Package:: *)

Block[{term = "starbucks", dir = "TwitterAnalysis", bin = Databin["Short ID"]},
 Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterProcessor.wl"}]]];
 Do[
  Print[file];
  TwitterProcessor`ProcessRawTwitterFile[file, bin, dir],
  {file, FileNames["*-"<>term, URLBuild[{dir, "Holding"}]]}
 ];
 "Done"
]
