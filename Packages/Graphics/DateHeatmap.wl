(* ::Package:: *)

Module[{bin = Databin["<wolfram:slot id='short-id'/>"], dates, data, max, range, empty = Association[Table[3*i -> 0, {i, 0, 8}]], dir = "<wolfram:slot id='dir'/>"},
	Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterStyling.wl"}]]];
	dates = Sort[bin["Timestamps"]];
	range = DateRange[DateValue[First[dates], {"Year", "Month", "Day"}], DateValue[Last[dates], {"Year", "Month", "Day"}], Quantity[1, "Days"]];data = KeySort[Merge[{Map[Merge[{empty, Counts[Floor[#, 3]]}, Last] &, GroupBy[Map[DateValue[#, {"Year", "Month", "Day", "Hour24"}] &, dates], Most -> Last]], Association @@ Map[Rule[#[[;; 3]], empty] &, range]}, Merge[#, First] &]];
   max = Max[data];
   ArrayPlot[
   Values[Map[Values, data]],
	AspectRatio -> 2/GoldenRatio,
	Background -> TwitterStyling`BackgroundColor[],
	BaseStyle -> {FontFamily -> TwitterStyling`TextFont[]},
	ColorFunction -> Function[{i}, With[{x = max*i}, If[x == 0, TwitterStyling`DataColor[2],Blend[{TwitterStyling`DataColor[1], TwitterStyling`DataColor[3]}, 1 - (x + max)/(2*max)]]]],
	Frame -> True,
	FrameStyle -> Opacity[0],
	FrameTicks -> {{MapIndexed[{#2[[1]], DateString[#1, {"MonthNameShort", " ", "Day"}]} &, range], None}, {None, Table[{i + 1, IntegerString[3*i, 10, 2] <> ":00"}, {i, 0, 7}]}},
	FrameTicksStyle -> Directive[Opacity[1], TwitterStyling`TextColor[]],
	ImageSize -> Full,
	PlotRange -> {All, {1, 8}, All}
   ]
]
