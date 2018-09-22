(* ::Package:: *)

Module[{bin = Databin["<wolfram:slot id='short-id'/>", All, "Sentiment"], data, quantiles, dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = TimeSeries[
		List@@@Normal[
			Map[
				N[Total[#]]&,
				GroupBy[
					Lookup[TimeSeries[bin], "Sentiment"]["Path"],
					(DateValue[First[#], {"Year", "Month", "Day", "Hour24"}]&) -> Last
				]
			]
		]
	];
	quantiles =With[{max = Floor[Max[data], 10]}, Map[Round[max * #]&, {.2, .4, .6, .8}]];
	Framed[
		DateListPlot[{data, MovingAverage[data, 2]},
			Background -> TwitterStyling`BackgroundColor[],
			BaseStyle -> {FontFamily -> TwitterStyling`TextFont[]},
			FrameStyle -> TwitterStyling`TextColor[],
			FrameTicks->{Automatic, quantiles},
			GridLines->{None, quantiles},
			GridLinesStyle->Directive[Dashed, TwitterStyling`TextColor[], Thin],
			ImageSize->Full,
			Joined->{False, True},
			PlotRange->{Automatic, {0, quantiles[[4]]+quantiles[[2]]}},
			PlotRangePadding->{Automatic, None},
			PlotStyle->{Directive[Thickness[0.0005], TwitterStyling`DataColor[2]], TwitterStyling`DataColor[1]},
			PlotTheme->{"Wide", "Business"}
		],
		Background -> TwitterStyling`BackgroundColor[],
		BaseStyle -> {FontFamily -> TwitterStyling`TextFont[]},
		FrameMargins -> {{15, 5}, {5, 15}},
		FrameStyle -> None
	]
]
