(* ::Package:: *)

Block[{term = "starbucks", dir = "TwitterAnalysis"},
(* Get the general package *)
 Get[CloudObject[FileNameJoin[{dir, "Packages", "Utilities", "TwitterReaper.wl"}]]];
 (* Setup authentication *)
 TwitterReaper`SetAuthentication[CloudObject[FileNameJoin[{dir, "AccessTokens.wl"}]]];
 (* Setup the project directory *)
 TwitterReaper`SetProjectDirectory[dir];
 (* Gather the tweets *)
 TwitterReaper`GatherTweets[term]
]
