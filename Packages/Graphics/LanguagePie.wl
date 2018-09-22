(* ::Package:: *)

Module[{bin = Databin["<wolfram:slot id='short-id'/>", All, "Language"], data, dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = Values[bin]["Language"];
	With[{language = KeyMap[#["Name"]&, Take[KeySelect[Sort[Normal[Counts[data]], Greater], Head[#] === Entity&], UpTo[Length[TwitterStyling`Colors[]]]]]},
		Framed[
			PieChart[
				Values[language],
				Background -> None,
				ChartLegends -> Placed[Keys[language], Right],
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
