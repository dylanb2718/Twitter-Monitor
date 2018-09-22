(* ::Package:: *)

Module[{bin = Databin["<wolfram:slot id='short-id'/>", All, {"Source", "Language"}], data, dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = Dataset[bin];
	GraphicsRow[{
		With[{sources = Take[Sort[Normal[Counts[data[All, "Source"]]], Greater], UpTo[Length[TwitterStyling`Colors[]]]]},
			PieChart[
				Values[sources],
				Background -> None,
				ChartLegends -> Placed[ReplaceAll[Keys[sources], {None -> "Browser"}], Left],
				ChartStyle -> Map[Directive[#, EdgeForm[TwitterStyling`TextColor[]]]&, TwitterStyling`Colors[]],
				ImageSize -> Scaled[0.48],
				SectorOrigin -> {Automatic, 1}
			]
		],
		With[{language = KeyMap[#["Name"]&, Take[KeySelect[Sort[Normal[Counts[data[All, "Language"]]], Greater], Head[#] === Entity&], UpTo[Length[TwitterStyling`Colors[]]]]]},
			PieChart[
				Values[language],
				Background -> None,
				ChartLegends -> Placed[Keys[language], Right],
				ChartStyle -> Map[Directive[#, EdgeForm[TwitterStyling`TextColor[]]]&, TwitterStyling`Colors[]],
				ImageSize -> Scaled[0.48],
				SectorOrigin -> {Automatic, 1}
			]
		]},
		Alignment -> Center,
		BaseStyle -> {FontColor -> TwitterStyling`TextColor[]},
		Background -> TwitterStyling`BackgroundColor[],
		ImageSize -> 1005
	]
]
