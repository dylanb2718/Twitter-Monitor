(* ::Package:: *)

BeginPackage["TwitterReaper`"];

SetAuthentication;
URLRequest;
TwitterRequest;
SetProjectDirectory;
GatherTweets;

Begin["`Private`"];

$TwitterAuthenticationKey = Missing[];

(* SetAuthentication is used to import the specific tokens required to authenticate to the Twitter API. 
The object storing these tokens should be Private for security, but should be in the cloud in order for the task to be able to access them. *)
SetAuthentication[assoc_Association] := ($TwitterAuthenticationKey = SecuredAuthenticationKey[<|"Name" -> "Twitter", "ConsumerKey" -> Lookup[assoc, "ConsumerKey"], "ConsumerSecret" -> Lookup[assoc, "ConsumerSecret"], "SignatureMethod" -> {"HMAC", "SHA1"}, "OAuthVersion" -> "1.0a", "OAuthType" -> "OneLegged", "OAuthToken" -> Lookup[assoc,"OAuthToken"], "OAuthTokenSecret" -> Lookup[assoc, "OAuthTokenSecret"]|>];)
SetAuthentication[f_String] := SetAuthentication[Get[f]]
SetAuthentication[f_File] := SetAuthentication[Get[f]]
SetAuthentication[co_CloudObject] := SetAuthentication[Get[co]]

(* This is the function actually used to make the request to Twitter. It returns both the StatusCode and Body of the response in order to determine if an error has occurred. *)
URLRequest[query_, auth_] :=
	URLRead[
		HTTPRequest[
			<|
				"Scheme"->"https",
				"Domain"->"api.twitter.com",
				"Path"->"/1.1/search/tweets.json",
				"Query"->query
			|>
		], 
		{"StatusCode","Body"}, 
		Authentication -> auth
	]

(* TwitterRequest takes a term or List of parameters to be used to make the request to Twitter.
If only a term is provided, be default the count will be limited to the past 100 most recent tweets.
Additionally, the value of $TwitterAuthenticationKey (set by SetAuthentication) will be used to authenticate the request. *)
TwitterRequest[term_String] := URLRequest[{"q"->term, "result_type"->"recent", "count"->"100"}, $TwitterAuthenticationKey]
TwitterRequest[params_List] := URLRequest[params, $TwitterAuthenticationKey]

(* Defines the directory in which the harvesting system is defined. *)
SetProjectDirectory[path_] := ($workingDirectory = path;)

(* GatherTweets is used to make the correct request to Twitter plus do the initial data cleaning.
Note: the data should not be completely cleaned up here, the task should simply be gather the specific fields that you want to preserve. *)
GatherTweets[term_String] := 
	Module[{paramLoc = CloudObject[URLBuild[{$workingDirectory, URLEncode[term]<>"-params"}]],
			dataLoc, params, runTime = DateString[{"Year","Month","Day","-","Hour24","Minute","Second","-",URLEncode[term]}],
			tweets, rawTweets, response, body, freshURL, nextParams, results},
		params = CloudGet[paramLoc];
		response = If[FailureQ[params],
				TwitterRequest[term],
				TwitterRequest[params]
			];
		If[response["StatusCode"] =!= 200,
			Return[$Failed]
		];
		body = ImportString[response["Body"], "JSON"];
		
		freshURL = Lookup[Lookup[body, "search_metadata"], "refresh_url"];
		nextParams = Append[Rule@@@URLDecode[StringSplit[StringSplit[StringTake[freshURL, 2;;], "&"], "="]], Rule["count", 100]];
		CloudPut[nextParams, paramLoc];

		rawTweets = Lookup[body, "statuses"];
		tweets = Map[processTweet, rawTweets];
		dataLoc = CloudObject[URLBuild[{$workingDirectory, "Holding", runTime}]];
		results = Map[Check[PutAppend[#, dataLoc], $Failed]&, tweets];
		If[And@@Map[FailureQ, results],
			DeleteObject[paramLoc];
			$Failed,
			dataLoc
		]
	]
	
GatherTweets[params_List] := 
	Module[{paramLoc = CloudObject[URLBuild[{$workingDirectory, URLEncode[Lookup[params, "q"]]<>"-params"}]],
			dataLoc, runTime = DateString[{"Year","Month","Day","-","Hour24","Minute","Second","-",URLEncode[Lookup[params, "q"]]}],
			tweets, rawTweets, response, body, freshURL, nextParams, results},
		response = TwitterRequest[params];
		If[response["StatusCode"] =!= 200,
			Return[$Failed]
		];
		body = ImportString[response["Body"], "JSON"];
		
		freshURL = Lookup[Lookup[body, "search_metadata"], "refresh_url"];
		nextParams = Append[Rule@@@URLDecode[StringSplit[StringSplit[StringTake[freshURL, 2;;], "&"], "="]], Rule["count", 100]];
		CloudPut[nextParams, paramLoc];

		rawTweets = Lookup[body, "statuses"];
		tweets = Map[processTweet, rawTweets];
		dataLoc = CloudObject[URLBuild[{$workingDirectory, "Holding", runTime}]];
		results = Map[Check[PutAppend[#, dataLoc], $Failed]&, tweets];
		If[And@@Map[FailureQ, results],
			DeleteObject[paramLoc];
			$Failed,
			dataLoc
		]
	]

(* Used to thin out the fields of data. *)
processTweet[data_] := 
	ExportString[
		MapAt[
			selectUserKeys,
			selectTweetKeys[data],
			Key["user"]
		],
		"JSON",
		"Compact"->True
	]
	
selectTweetKeys[data_] := KeySelect[data, MemberQ[$relevantTweetKeys, #]&]

$relevantTweetKeys = {
	"created_at",
	"id",
	"text",
	"source",
	"user",
	"geo",
	"coordinates",
	"place",
	"retweet_count",
	"favorite_count",
	"lang"
};

selectUserKeys[data_] := KeySelect[data, MemberQ[$relevantUserKeys, #]&]

$relevantUserKeys={"id", "screen_name", "location", "followers_count"};

End[];
EndPackage[]
