(* ::Package:: *)

BeginPackage["TwitterProcessor`"];

ProcessRawTwitterData;
ProcessRawTwitterFile;

Begin["`Private`"];

(* This function is used to process the raw data in different fields. *)
processTweetData[{"created_at", date_}] := {Rule["Timestamp", TimeZoneConvert[DateObject[{date, {"DayNameShort", " ", "MonthNameShort", " ", "Day", " ", "Hour24", ":", "Minute", ":", "Second", " +0000 ", "Year"}}, TimeZone -> 0]]]}
processTweetData[{"id", id_}] := {Rule["ID", id]}
processTweetData[{"text", tweet_}] := {Rule["Tweet", ToString[tweet, CharacterEncoding->"ASCII"]], Rule["Sentiment", findSentiment[tweet]]}
processTweetData[{"source", sourceLink_}] := {Rule["Source", sourceName[sourceLink]]}
processTweetData[{"user", userData_}] := processUserData[userData]
processTweetData[{"geo", Null}] := {}
processTweetData[{"geo", geo_}] := {Rule["geo", formatLocation[Lookup[geo, "coordinates"]]]}
processTweetData[{"coordinates", Null}] := {}
processTweetData[{"coordinates", coor_}] := {Rule["coordinates", formatLocation[Reverse[Lookup[coor, "coordinates"]]]]}
processTweetData[{"place", Null}] := {}
processTweetData[{"place", place_}] := {Rule["place", With[{loc=Check[Interpreter["Location"][Lookup[place, "full_name"]], Missing[]]}, If[FailureQ[loc], Missing[], loc]]]}
processTweetData[{"retweet_count", count_}] := {Rule["Retweets", count]}
processTweetData[{"favorite_count", count_}] := {Rule["Favorites", count]}
processTweetData[{"lang", lang_}] := {Rule["Language", With[{l = Check[Interpreter["Language"][lang], lang]}, If[FailureQ[l], lang, l]]]}

findSentiment[text_] := 
If[Classify["Language", text] === Entity["Language", "English"],
Times @@ ReplaceAll[
List @@ Last[Normal[
Sort[Classify["Sentiment", text, "Probabilities", ClassPriors -> <|"Positive" -> 0.5, "Negative" -> 0.5|>]]
]], 
{"Negative" -> -100, "Positive" -> 100}],
0
]

formatLocation[loc_] := Quiet[Check[GeoPosition[loc], Missing[]]]

processUserData[data_] := {Rule["User", <|"UserID" -> Lookup[data, "id"], "ScreenName" -> Lookup[data, "screen_name"], "Location" -> With[{loc = Quiet[Check[Interpreter["Location"][Lookup[data, "location"]], Missing[]]]}, If[FailureQ[loc], Missing[], loc]], "Followers" -> Lookup[data, "followers_count"]|>]}

sourceName[name_] := 
 With[{raw = 
    Replace[StringCases[
      name, {">" ~~ Shortest[source__] ~~ "<" :> 
        source}], {{value_} :> value, {values__} :> 
       First[values], {} :> None}]},
  If[StringQ[raw],
   StringReplace[
    raw, {"Twitter for " -> "", "Twitter Web Client" -> "Web Client"}],
   raw
   ]
  ]

calculateLocation[data_] :=
 Module[{specific = Lookup[data, {"geo", "coordinates", "place"}]},
 Join[
 KeyDrop[data, {"geo", "coordinates", "place"}],
 <|"Location" -> 
 If[And @@ Map[MissingQ, specific], 
 Lookup[Lookup[data, "User"], "Location"],
 Last[DeleteCases[specific, _Missing|_Failure]]
 ]
 |>
 ]
 ]

(* This function takes all of the tweets and processes them individually.
On an EPC with parallel evaluations enabled, this step could be improved. *)
ProcessRawTwitterData[data_] := Map[calculateLocation[Association[Flatten[Map[processTweetData, List@@@#]]]]&, data]

(* This function takes the file to be processed, the Databin to be uploaded to, and the working directory of the system.
If the data is successfully processed and uploaded to the Databin, the raw file is moved to "Processed".
If any failure occurs, the raw file is moved to "Quarantine" to prevent it from be processed again by the task, but saved for a user to manually inspect the data for errors. *)
ProcessRawTwitterFile[file_, bin_, cDir_] :=
Module[{raw = Map[ImportString[#,"JSON"]&, ReadList[file]], data, qFile, copied},
data = ProcessRawTwitterData[raw];
Check[
DatabinUpload[bin, data],
qFile = CopyFile[CloudObject[file], CloudObject[URLBuild[{cDir, "Quarantine",FileNameTake[file]}]]];
If[!FailureQ[qFile] && FileExistsQ[qFile], DeleteObject[CloudObject[file]]];
Return[uploadFailure[file, qFile]],
Databin::apierr
];
copied = CopyFile[CloudObject[file], CloudObject[URLBuild[{cDir, "Processed", FileNameTake[file]}]]];
If[!FailureQ[copied] && FileExistsQ[copied], DeleteObject[CloudObject[file]]];
uploadSuccess[file, bin]
]

uploadSuccess[file_, bin_] := Success["DataUploaded", <|"MessageTemplate" :> "Data from `file` uploaded to `bin`", "MessageParameters" -> <|"file" -> file, "bin" -> bin["ShortID"]|>|>]

uploadFailure[file_, qFile_] := Failure["DataUploadFailure", <|"MessageTemplate" :> "Data from `file` failed to bo uploaded", "MessageParameters" -> <|"file" -> file|>, "Location" -> qFile|>]

End[];
EndPackage[]
