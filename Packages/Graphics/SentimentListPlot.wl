(* ::Package:: *)

Module[{bin = Databin["Short ID", All, "Sentiment"], data, quantiles},
	Get[CloudObject[FileNameJoin[{"TwitterAnalysis", "Packages", "Utilities", "TwitterStyling.wl"}]]];
	data = TimeSeries[
		List@@@Normal[
			Map[
				N[Total[#]]&,
				GroupBy[
					Lookup[TimeSeries[bin], "Sentiment"]["Path"],
					(DateValue[First[#], {"Year", "Month", "Day", "Hour24"}] &) -> Last
				]
			]
		]
	];
	quantiles =With[{max = Floor[Max[data], 10]}, Map[Round[max * #]&, {.2, .4, .6, .8}]];
	Framed[
		DateListPlot[{data, MovingAverage[data, 6]},
			Background -> TwitterStyling`BackgroundColor[],
			FrameStyle -> TwitterStyling`TextColor[],
			FrameTicks->{Automatic, quantiles},
			GridLines->{None, quantiles},
			GridLinesStyle->Directive[Dashed, TwitterStyling`TextColor[], Thin],
			ImageSize->Full,
			Joined->{False, True},
			PlotRange->{Automatic, {0, Automatic}},
			PlotRangePadding->{Automatic, None},
			PlotStyle->{Directive[Thickness[0.0005], TwitterStyling`DataColor[2]], TwitterStyling`DataColor[1]},
			PlotTheme->{"Wide", "Business"}
		],
		Background -> TwitterStyling`BackgroundColor[],
		FrameMargins -> {{15, 5}, {5, 15}},
		FrameStyle -> None
	]
]
