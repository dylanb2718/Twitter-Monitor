(* ::Package:: *)

Module[{bin = Databin["<wolfram:slot id='short-id'/>", All, "Source"], data, dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = Values[bin]["Source"];
	With[{sources = Take[Sort[Normal[Counts[data]], Greater], UpTo[Length[TwitterStyling`Colors[]]]]},
		Framed[
			PieChart[
				Values[sources],
				Background -> None,
				ChartLegends -> Placed[ReplaceAll[Keys[sources], {None -> "Browser"}], Right],
				ChartStyle -> Map[Directive[#, EdgeForm[TwitterStyling`TextColor[]]]&, TwitterStyling`Colors[]],
				ImageSize -> Scaled[0.48],
				SectorOrigin -> {Automatic, 1}
			],
			Background -> TwitterStyling`BackgroundColor[],
			BaseStyle -> {FontFamily -> TwitterStyling`TextFont[]},
			FrameStyle -> None
		]
	]
]
