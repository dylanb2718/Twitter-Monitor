(* ::Package:: *)

Module[{max, min, full, bin = Databin["<wolfram:slot id='short-id'/>"], data, dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data=Dataset[bin];
	Column[{
		GeoHistogram[
			Association@@Map[
				Rule[Lookup[#, "Location"], Lookup[#, "Sentiment"] * Max[Lookup[Lookup[#, "User"], "Followers"], 1]*Max[Lookup[#, "Retweets"], 1]] &,
				Normal[data[Select[!MissingQ[#Location]&]][All, {"Location", "Sentiment", "User", "Retweets"}]]
			],
			{"Hexagon", 100},
			Function[{bins, counts},
				max = Max[counts];
				min = Min[counts];
				full = Max[Abs[{max, min}]];
				counts
			],
			ColorFunction -> Function[{i}, With[{x = (max - min)*i + min}, If[x == 0, TwitterStyling`DataColor[2], Blend[{TwitterStyling`DataColor[1], TwitterStyling`DataColor[3]}, 1 - (x + full)/(2 * full)]]]],
			GeoBackground -> GeoStyling[{"CountryBorders", "Land" -> TwitterStyling`BackgroundColor[1], "Ocean" -> TwitterStyling`BackgroundColor[2], "Border" -> Directive[TwitterStyling`TextColor[1], Dotted, Thin]}],
			GeoRange -> "World",
			ImageSize -> Full,
			PlotStyle -> Directive[EdgeForm[Directive[TwitterStyling`TextColor[1], Thickness[0.000075]]], Opacity[0.9]]
		],
		Graphics[{
			Table[{
				Blend[{TwitterStyling`DataColor[1], TwitterStyling`DataColor[3]}, 1 - i],
				Rectangle[{i, 0}, {i + 0.05, 0.05}]},
				{i, 0, 1, 0.05}
			],
			TwitterStyling`TextColor[-1],
			Text[Style["-", 24], {0.025, 0.025}, {0, 0}, Background -> None],
			Text[Style["+", 24], {1.025, 0.025}, {0, 0}, Background -> None]},
			ImageSize -> Full,
			PlotRange -> {{0, 1.05}, {0, 0.05}},
			PlotRangePadding -> None
		]},
		Spacings->0
	]
]
