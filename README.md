# Twitter-Monitor #
The README file reiterates the contents of Workflow.nb, but without any code. For more specific details, please look at either Workflow.nb or Deployment.nb

[![View notebooks](https://wolfr.am/HAAhzkRq)](https://wolfr.am/KhKG983y)

## Harvesting ##
Within the harvesting process, there are three major components; the reaper, the processor, and the silo.

The reaper is a cloud task that accesses Twitter and gets the raw data. It does some minor trimming, but its main purpose is to simply get the raw data.

The processor is also a cloud task, but instead of accessing Twitter, it goes through the data gathered by the reaper and cleans it further, does any kind of individual analysis (i.e. sentiment analysis or identifying the geo-location), and stores the formatted data in the silo.

The silo is a Databin that stores all processed data. By storing the data in a Databin rather than a file, import speeds and queries are improved. That is, it becomes much easier to request data for only a certain time range or a specific field rather than the dataset as a whole.

### Reaper Task ###
To make the task easier to modify, the code for the reaper task has been broken into three components; a package containing general functions, a package containing the specific higher-level functions to be called by the task, and the task itself.

#### TwitterReaper.wl ####
This package contains the general functions needed to connect to Twitter and gather data about a specific search term. It selects only the relevant fields of data, but does no further processing before saving the data to a file within the 'Holding' directory.

#### ReaperCode.wl ####
This package is defined to be the code run by the ReaperTask. It is defined within a separate package rather than the task for two reasons:

1. It makes it easier to deploy multiple ReaperTasks since the task code is much shorter.
2. It makes it easier to make changes to the ReaperTasks since the task code can now be modified without accidentally modifying the schedule for the task.

#### ReaperTask ####
This is all the code that is needed to deploy the ReaperTask. A couple of things to note:

* NotificationFunction is set to None in order to prevent messages about task failures. If you wish to be notified when the task fails, you can change it to Automatic.
* The schedule for this task is set to "Hourly" but can be changed for your individual situation. The schedule should be setup such that you are making requests to Twitter frequently enough to not miss many tweets but not so frequent as to get tweets multiple times. Additionally, it should be noted that the Wolfram Public Cloud limits tasks to only run, at most, once per hour, so if you wish for more frequent reaping, you will either need to deploy multiple tasks or by using a Wolfram Enterprise Private Cloud.

### Processor Task ###

#### TwitterProcessor.wl ####
This package contains the general functions needed to refine the data gathered from Twitter and upload it to the Silo Databin. It does not connect to Twitter, just reads in the data found within the specified files, tries to process the data uploading it to the Silo Databin if successful and moving the raw data to a separate folder if something fails.

#### ProcessorCode.wl ####
This package is defined to be the code run by the ProcessorTask. It is defined within a separate package rather than the task for two reasons:

1. It makes it easier to deploy multiple ProcessorTasks since the task code is much shorter.
2. It makes it easier to make changes to the ProcessorTasks since the task code can now be modified without accidentally modifying the schedule for the task.

#### ProcessorTask ####
This is all the code that is needed to deploy the ProcessorTask. A couple of things to note:

* NotificationFunction is set to None in order to prevent messages about task failures. If you wish to be notified when the task fails, you can change it to Automatic.
* The schedule for this task is set to "Hourly" but can be changed for your individual situation. The schedule should be setup such that you are able to process all of the data gathered by the ReaperTask(s). If you have more than 2 reapers, you will likely need more processors. If you notice that you have a backlog of unprocessed data, you can manually trigger the ProcessorTask in order to catch up. This can be useful if part of the system goes down for maintenance.

### Silo Databin ###
The Silo Databin is probably the easiest part of the system since it requires the least about of work to create. Once the bin has been created, make sure to include the correct DatabinID in ProcessorCode.wl and for use in the Dashboard.

## Twitter Dashboard ##
Within the dashboard, there are two components; the individual charts/graphs/maps to be displayed and the notebook that displays all of the results.

The graphics listed below are all basic examples, but more can easily be created and added to the notebook. The basic deployment for these graphics is as an AutoRefreshed, this is in order to refresh the data being displayed without having to constantly regenerate images whenever someone wants to view them.

The dashboard notebook simply gets the latest copy of all the graphics and displays them. The layout can be changed and an HTML page can be substituted for the notebook, but this gets the idea across.

### Graphics ###
Each of the following subsections (with the exception of the first) is used to generate a graphic for the dashboard. They include the code for generating the graphic itself as well as the code needed to deploy the AutoRefreshed object.

#### Style Utilities ####
This subsection defines a color pallette to be used by the graphics. This allows for a more unique feel for the dashboard since the colors can be setup for whatever topic is being analyzed.

#### Sentiment Histogram ####
The sentiment histogram shows a GeoHistogram of the sentiment for all English language tweets within the dataset. The sentiment is limited to English as that is the only language for which the Wolfram Language has a built in Classifier defined.

#### Sentiment List Plot ####
The sentiment list plot shows a DateListPlot of the sentiment for all tweets within the dataset as well as the moving average of the sentiment.

#### Pie Charts ####
There are two PieCharts included within this visualization. First is a breakdown of what type of device the tweet came from, i.e. browser, iOS, android, etc. The second is a breakdown of what language the tweets are written in.

### Dashboard Notebook ###
The graphics described above can all be viewed individually, but analysis is much easier if they are all displayed on a single dashboard. The example given here is a notebook that pulls in the latest graphics generated and displays them. This could also easily be done in an HTML page.

#### Examples ####

[![View example](https://wolfr.am/xQPKlplt)](https://wolfr.am/xQPb6kqB)    [![View example](https://wolfr.am/xQPFUW7y)](https://wolfr.am/xQPHnnu2)
