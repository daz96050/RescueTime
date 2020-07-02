<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.169
	 Created on:   	12/9/2019 9:38 AM
	 Created by:   	Dakota Zinn
	 Organization: 	
	 Filename:     	RescueTime.psm1
	-------------------------------------------------------------------------
	 Module Name: RescueTime
	===========================================================================
#>


function Connect-RescueTime
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $false)]
		[string]$client_id,
		[Parameter(Mandatory = $false)]
		[string]$client_secret,
		[Parameter(Mandatory = $false)]
		[string]$redirect_uri,
		[Parameter(Mandatory = $false)]
		[string]$response_type = "code",
		[Parameter(Mandatory = $false)]
		[ValidateSet('time_data', 'category_data', 'productivity_data', 'alert_data', 'highlight_data', 'focustime_data')]
		[string[]]$scopes
	)
	
	$API = "https://www.rescuetime.com/oauth/authorize?client_id=$client_id&redirect_uri=$redirect_uri&response_type=$response_type&scope=$($scopes -join ",")"
	try
	{
		$AuthCode = Invoke-RestMethod -Method Get -Uri $API
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
	Try
	{
		$Body = [pscustomobject]@{
			client_id	  = $client_id
			client_secret = $client_secret
			grant_type    = "authorization_code"
			redirect_uri  = $redirect_uri
		} | ConvertTo-Json
		$AccessToken = Invoke-RestMethod -Method Post -Uri "https://www.rescuetime.com/oauth/token" -Body $Body
		return $AccessToken
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}




function Get-RTAnalytics
{
<#
	.SYNOPSIS
		A brief description of the Get-RescueTimeLogged function.
	
	.DESCRIPTION
		A detailed description of the Get-RescueTimeLogged function.
	
	.PARAMETER APIKey
		Your API key
	
	.PARAMETER access_token
		the access token from the Oauth2 Connection
	
	.PARAMETER Format
		A description of the Format parameter.
	
	.PARAMETER OrderBy
		A description of the OrderBy parameter.
	
	.PARAMETER GroupTimeBy
		Default is "hour". In an interval report, the X axis unit. In other words, data is summarizd into chunks of this size. "minute" will return data grouped into five-minute buckets, which is the most granular view available.
	
	.PARAMETER After
		Sets the start day for data batch, inclusive (always at time 00:00, start hour/minute not supported)
		Format ISO 8601 "YYYY-MM-DD"
	
	.PARAMETER Before
		Sets the end day for data batch, inclusive (always at time 00:00, end hour/minute not supported)
		Format ISO 8601 "YYYY-MM-DD"
	
	.PARAMETER GroupAspect
		A description of the GroupAspect parameter.
	
	.PARAMETER GroupComponent
		The name of a specific overview, category, application or website. For websites, use the domain component only if it starts with "www", eg. "www.nytimes.com" would be "nytimes.com". The easiest way to see what name you should be using is to retrieve a list that contains the name you want, and inspect it for the exact names.
	
	.PARAMETER GroupActivityName
		Refers to the specific "document" or "activity" we record for the currently active application, if supported. For example, the document name active when using Microsoft Word. Available for most major applications and web sites. Let us know if yours is not.
	
	.PARAMETER DeviceType
		Allows for querying by source device type
	
	.PARAMETER OAuthScope
		A description of the OAuthScope parameter.
	
	.EXAMPLE
		PS C:\> Get-RescueTimeLogged -APIKey 'Value1' -Format csv
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding(DefaultParameterSetName = 'API Key')]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('csv', 'json', 'psobject')]
		[string]$Format,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('rank', 'interval')]
		[Alias('Perspective')]
		[string]$OrderBy,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('month', 'week', 'day', 'hour', 'minute')]
		[Alias('Interval', 'ResolutionTime', 'rs', 'i')]
		[string]$GroupTimeBy = "hour",
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('RestrictBegin', 'rb')]
		[datetime]$After,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('RestrictEnd', 're')]
		[datetime]$Before,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('category', 'activity', 'productivity', 'document', 'efficiency')]
		[Alias('taxonomy', 'RestrictKind', 'rk', 'ty')]
		[string]$GroupAspect,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('RestrictThing', 'rt', 'taxon', 'tx')]
		[string]$GroupComponent,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('RestrictThingy', 'ry', 'sub_taxon', 'tn')]
		[string]$GroupActivityName,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('computers', 'mobile', 'offline')]
		[Alias('restrict_source_type')]
		[string]$DeviceType,
		[Parameter(ParameterSetName = 'OAuth2')]
		[ValidateSet('overview', 'category', 'productivity')]
		[string]$OAuthScope,
		[Parameter(ParameterSetName = 'OAuth2')]
		[string]$access_token
	)
	switch ($PSCmdlet.ParameterSetName)
	{
		"OAuth2" {
			switch ($PSBoundParameters.OAuthScope)
			{
				"overview"{ $API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/data?access_token=$Access_Token&format=csv" }
				"category"{ $API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/data?access_token=$Access_Token&format=csv" }
				"productivity"{ $API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/data?access_token=$Access_Token&format=csv" }
				default{ $API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/data?access_token=$Access_Token&format=csv" }
				
			}
		}
		"API Key"{ $API = [System.Text.StringBuilder]"https://www.rescuetime.com/anapi/data?key=$APIKey&format=csv" }
		
	}
	
	
	if ($OrderBy)
	{ $API = $API.Append("&perspective=$OrderBy") }
	if ($GroupTimeBy)
	{ $API = $API.Append("&resolution_time=$GroupTimeBy") }
	if ($After)
	{ $API = $API.Append("&restrict_begin=$($After.ToString("yyyy-MM-dd"))") }
	if ($Before)
	{ $API = $API.Append("&restrict_end=$($Before.ToString("yyyy-MM-dd"))") }
	if ($GroupAspect)
	{ $API = $API.Append("&restrict_kind=$GroupAspect") }
	if ($GroupComponent)
	{ $API = $API.Append("&restrict_thing=$GroupComponent") }
	if ($GroupActivityName)
	{ $API = $API.Append("&restrict_thingy=$GroupActivityName") }
	if ($DeviceType)
	{ $API = $API.Append("&restrict_source_type=$DeviceType") }
	
	try
	{
		$response = Invoke-RestMethod -Method Get -Uri $API.ToString()
		if ($psboundparameters.format -eq "csv")
		{ return $response }
		elseif ($psboundparameters.format -eq "json")
		{ return $($response | ConvertFrom-Csv | ConvertTo-Json) }
		elseif ($psboundparameters.format -eq "psobject")
		{ return $($response | ConvertFrom-Csv) }
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}



function Get-RTSummaryFeed
{
<#
	.SYNOPSIS
		Daily Summary Feed
	
	.DESCRIPTION
		The Daily Summary Feed API provides a high level rollup of the the time a user has logged for a full 24 hour period (defined by the user's selected time zone). This is useful for generating notifications that don't need to be real-time and don't require much granularity (for greater precision or more timely alerts, see the Alerts Feed API). This can be used to construct a customized daily progress report delivered via email. The summary can also be used to alert people to specific conditions. For example, if a user has more than 20% of their time labeled as 'uncategorized', that can be used to offer people a message to update their categorizations on the website.
	
	.PARAMETER APIKey
		Your API key
	
	.PARAMETER access_token
		the access token from the Oauth2 Connection
		
	.EXAMPLE
		PS C:\> Get-RTSummaryFeed -APIKey 'Value1'
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token
	)
	switch ($PsCmdlet.ParameterSetName)
	{
		"API Key"{ $API = "https://www.rescuetime.com/anapi/daily_summary_feed?key=$APIKey";break }
		"OAuth2"{ $API = "https://www.rescuetime.com/oauth/daily_summary_feed?$Access_Token";break }
	}
	try
	{
		$response = Invoke-RestMethod -Method Get -Uri $API
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}

function Get-RTAlerts
{
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token,
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'API Key')]
		[Parameter(ParameterSetName = 'OAuth2')]
		[ValidateSet('status', 'list')]
		[string]$op = "status",
		[Parameter(ParameterSetName = 'API Key')]
		[Parameter(ParameterSetName = 'OAuth2')]
		[string]$alert_id
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'OAuth2' {
			$API = "https://www.rescuetime.com/oauth/alerts_feed?access_token=$access_token&op=$op"
			break
		}
		'API Key' {
			$API = "https://www.rescuetime.com/anapi/alerts_feed?key=$APIKey&op=$op"
			break
		}
	}
	if ($PSBoundParameters.alert_id)
	{ $API += "&alert_id=$alert_id" }
	
	try
	{
		$response = Invoke-RestMethod -Method Get -Uri $API
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}



function Get-RTHighlights
{
<#
	.SYNOPSIS
		Daily Highlight events
	
	.DESCRIPTION
		The Highlights Feed API is a list of recently entered Daily Highlight events. These are user-entered strings that are meant to provide qualitative context for the automatically logged time about the user's activities. It is often used to keep a log of "what got done today". Highlights are a premium feature and as such the API will always return zero results for users on the RescueTime Lite plan.
	
	.PARAMETER APIKey
		Your API key
	
	.PARAMETER access_token
		the access token from the Oauth2 Connection
	
	.EXAMPLE
		PS C:\> Get-RTHighlights
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'OAuth2' {
			$API = "https://www.rescuetime.com/oauth/highlights_feed?access_token=$access_token"
		}
		'API Key' {
			$API = "https://www.rescuetime.com/anapi/highlights_feed?key=$APIKey"
		}
	}
	
	
	try
	{
		$response = Invoke-RestMethod -Method Get -Uri $API
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}


function New-RTHighlight
{
<#
	.SYNOPSIS
		Create a Highlight
	
	.DESCRIPTION
		The Highlights Post API makes it possible to post daily highlight events programmatically as an alternative to entering events manually on RescueTime.com. This is useful for capturing information from other systems and providing a view of the "output" that the user is creating (which is a counterpoint to the "input" attention data that RescueTime logs automatically). Examples include adding highlights whenever a code checkin is done, or marking an item in a to-do list application as complete.
	
	.PARAMETER APIKey
		Your API key
	
	.PARAMETER access_token
		the access token from the Oauth2 Connection
	
	.PARAMETER highlight_date
		The date the highlight will be posted for. This should be in the format of 'YYYY-MM-DD', but a unix timestamp is also acceptable.
	
	.PARAMETER description
		A 255 character or shorter string containing the text that will be entered for the highlight. This should be representative of an action that was taken by the user.
	
	.PARAMETER source
		A short string describing the 'source' of the action, or the label that should be applied to it. Think of this as a category that can group multiple highlights together in the UI. This is useful when many highlights will be entered. In the reporting UI, they will be collapsed under the expandable source label.
	
#>
	
	[CmdletBinding(DefaultParameterSetName = 'OAuth2',
				   ConfirmImpact = 'None')]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('date')]
		$highlight_date = (get-date),
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false)]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateLength(1, 255)]
		[Alias('Highlight')]
		[string]$description,
		[Parameter(ParameterSetName = 'OAuth2')]
		[Parameter(ParameterSetName = 'API Key')]
		[Alias('label', 'category')]
		[string]$source
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'OAuth2' {
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/highlights_post?access_token=$access_token"
		}
		'API Key' {
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/anapi/highlights_post?key=$APIKey"
		}
	}
	if ($PSBoundParameters.highlight_date -is [datetime])
	{ $API = $API.Append("&highlight_date=$(($PSBoundParameters.highlight_date).tostring("yyyy-MM-dd"))") }
	else{ $API = $API.Append("&highlight_date=$($PSBoundParameters.highlight_date)") }
	$API = $API.Append("&description=$($PSBoundParameters.description)")
	if ($PSBoundParameters.source)
	{ $API = $API.Append("&source=$source") }
	
	try
	{
		$response = Invoke-RestMethod -Method Post -Uri $API.tostring()
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}


function Start-RTFocusTime
{
<#
	.SYNOPSIS
		Start Focus Time
	
	.DESCRIPTION
		The FocusTime Trigger API makes it possible to start/end FocusTime on active devices as an alternative to starting/ending it manually from the desktop app. This is useful for automating FocusTime from 3rd party applications. An example would be starting/ending FocusTime at a certain time of day.
	
	.PARAMETER APIKey
		Your API Key
	
	.PARAMETER access_token
		the access token from the Oauth2 Connection
	
	.PARAMETER duration
		An integer representing the length of the FocusTime session in minutes, and must be a multiple of 5 (5, 10, 15, 20...). 
		A value of -1 can be passed to start FocusTime until the end of the day.
	
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false)]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateScript({
				if (($_ % 5) -eq 0)
				{ return $true }
				elseif ($_ -eq (-1))
				{ return $true }
				else { return $false }
			})]
		[Alias('length')]
		[int]$duration
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'API Key' {
			#TODO: Place script here
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/anapi/start_focustime?key=$APIKey"
		}
		'OAuth2' {
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/oauth/start_focustime?access_token=$access_token"
		}
	}
	$API = $API.Append("&duration=$duration")
	
	
	try
	{
		$response = Invoke-RestMethod -Method Post -Uri $API.tostring()
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}


function Stop-RTFocusTime
{
	[Alias('Stop-FocusTime')]
	[CmdletBinding(ConfirmImpact = 'Low')]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'API Key' {
			$API = "https://www.rescuetime.com/anapi/end_focustime?key=$APIKey"
		}
		'OAuth2' {
			$API = "https://www.rescuetime.com/oauth/end_focustime?access_token=$access_token"
		}
	}
	
	try
	{
		$response = Invoke-RestMethod -Method Post -Uri $API
		return $response
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
	
}


function Get-RTFocusTime
{
<#
	.SYNOPSIS
		Get Focus Time Sessions
	
	.DESCRIPTION
		The FocusTime Feed API is a running log of recently triggered started/ended FocusTime sessions. This is useful for performing 3rd party app interactions whenever a new FocusTime session has started/ended. FocusTime is a premium feature and as such the API will always return zero results for users on the RescueTime Lite plan.
	
	.PARAMETER APIKey
		Your API key
	
	.PARAMETER access_token
		The access token from the Oauth2 Connection
	
	.PARAMETER event_type
		A description of the event_type parameter.
	
	.EXAMPLE
				PS C:\> Get-RTFocusTimeFeed -access_token 'Value1' -event_type started
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false,
				   Position = 0)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false,
				   Position = 0)]
		[string]$access_token,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false)]
		[Parameter(ParameterSetName = 'API Key')]
		[ValidateSet('started', 'ended')]
		[string]$event_type
	)
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'OAuth2' {
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/api/oauth/focustime_$($event_type)_feed?access_token=$access_token"
			break
		}
		'API Key' {
			$API = [System.Text.StringBuilder]"https://www.rescuetime.com/anapi/focustime_$($event_type)_feed?key=$APIKey"
			break
		}
	}
	
	try
	{
		
		
		$response = Invoke-RestMethod -Uri $API.tostring()
		$response | % {
			$_.timestamp = $_.timestamp -as [datetime]
			$_.created_at = $_.created_at -as [datetime]
		}
		
		if ($psboundparameters.event_type -eq "started")
		{ return ($response | select id, @{ N = "initialDuration"; E = { $_.duration } }, timestamp, created_at)}
		elseif ($psboundparameters.event_type -eq "ended")
		{ return ($response | select id, timestamp, created_at)}
	}
	catch
	{
		$result = $_.Exception.Response.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($result)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$response = $reader.ReadToEnd();
		$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, $null)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
}

function Add-RTOfflineTime
{
<#
	.SYNOPSIS
		Add Offline time to RescueTime
	
	.DESCRIPTION
		The Offline Time Post API makes it possible to post offline time programmatically as an alternative to entering it manually on RescueTime.com. This is useful for capturing information from other systems. Examples include adding offline time after a meeting on a calendar app, or logging driving time based on location data.
	
	.PARAMETER APIKey
		A description of the APIKey parameter.
	
	.PARAMETER access_token
		A description of the access_token parameter.
	
	.PARAMETER start_time
		the start of the offline time block
	
	.PARAMETER duration
		integer representing the duration of the offline time block in minutes.
	
	.PARAMETER activity_name
		A 255 character or shorter string containing the text that will be entered as the name of the activity (e.g. "Meeting", "Driving", "Sleeping", etc).
	
	.PARAMETER activity_details
		A description of the activity_details parameter.
	
	.PARAMETER end_time
		A description of the end_time parameter.
	
	.EXAMPLE
		PS C:\> Add-RTOfflineTime
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(ParameterSetName = 'API Key',
				   Mandatory = $false)]
		[string]$APIKey,
		[Parameter(ParameterSetName = 'OAuth2',
				   Mandatory = $false)]
		[string]$access_token,
		[Parameter(Mandatory = $true)]
		[datetime]$start_time,
		[Parameter(Mandatory = $false)]
		[ValidateScript({ $_ -lt 320 -and $_ -gt 0 })]
		$duration,
		[Parameter(Mandatory = $true)]
		[ValidateLength(1, 255)]
		[Alias('Name', 'Summary')]
		[string]$activity_name,
		[Parameter(Mandatory = $false)]
		[ValidateLength(0, 255)]
		[Alias('Description', 'Details')]
		[string]$activity_details,
		[datetime]$end_time
	)

	process
	{
		if ($PSBoundParameters.end_time)
		{
			$json = [pscustomobject]@{
				start_time = ([datetime]$start_time).ToString("yyyy-MM-dd hh:mm:ss")
				end_time   = ([datetime]$end_time).ToString("yyyy-MM-dd hh:mm:ss")
				activity_name = $activity_name
			}
		}
		else
		{
			$json = [pscustomobject]@{
				start_time    = $start_time
				duration	  = $duration
				activity_name = $activity_name
			}
		}
		if ($PSBoundParameters.activity_details)
		{ $json | Add-Member -NotePropertyName activity_details $activity_details }
		
		
		
		
		switch ($PsCmdlet.ParameterSetName)
		{
			'OAuth2' {
				$API = "https://www.rescuetime.com/api/oauth/offline_time_post?access_token=$access_token"
				
			}
			'API Key' {
				$API = "https://www.rescuetime.com/anapi/offline_time_post?key=$APIKey"
				
			}
		}
		
		try
		{
			$response = Invoke-RestMethod -Method Post -Uri $API -Body ($json | ConvertTo-Json) -ContentType "Application/JSON" 
			return $response
		}
		catch
		{
			$result = $_.Exception.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($result)
			$reader.BaseStream.Position = 0
			$reader.DiscardBufferedData()
			$response = $reader.ReadToEnd();
			$ErrorRecord = New-Object System.Management.Automation.ErrorRecord("$response", "", [system.management.automation.errorcategory]::InvalidResult, ($json | ConvertTo-Json))
			$PSCmdlet.ThrowTerminatingError($ErrorRecord)
		}
	}
}

