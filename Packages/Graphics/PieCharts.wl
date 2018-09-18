(* ::Package:: *)

Module[{bin = Databin["Short ID", All, {"Source", "Language"}], data},
	Get[CloudObject[FileNameJoin[{"TwitterAnalysis", "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = Dataset[bin];
	GraphicsRow[{
		With[{sources = Normal[Counts[data[All, "Source"]]]},
			PieChart[
				Values[sources],
				Background -> None,
				ChartLegends -> Placed[ReplaceAll[Keys[sources], {None -> "Browser"}], Left],
				ChartStyle -> TwitterStyling`Colors[],
				ImageSize -> Scaled[0.48],
				SectorOrigin -> {Automatic, 1}
			]
		],
		With[{language = KeyMap[#["Name"]&, Take[KeySelect[Sort[Normal[Counts[data[All, "Language"]]], Greater], Head[#] === Entity&], UpTo[Length[Colors[]]]]]},
			PieChart[
				Values[language],
				Background -> None,
				ChartLegends -> Placed[Keys[language], Right],
				ChartStyle -> TwitterStyling`Colors[],
				ImageSize -> Scaled[0.48],
				SectorOrigin -> {Automatic, 1}
			]
		]},
		Alignment -> Center,
		Background -> TwitterStyling`BackgroundColor[],
		ImageSize -> Full
	]
]
