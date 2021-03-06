﻿<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.169
	 Created on:   	12/9/2019 9:38 AM
	 Created by:   	dz053479
	 Organization: 	CernerWorks
	 Filename:     	RescueTime.psd1
	 -------------------------------------------------------------------------
	 Module Manifest
	-------------------------------------------------------------------------
	 Module Name: RescueTime
	===========================================================================
#>


@{
	
	# Script module or binary module file associated with this manifest
	RootModule = 'RescueTime.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.0.2'
	
	# ID used to uniquely identify this module
	GUID = '4d9062a5-fa56-42a7-8f09-902181231dea'
	
	# Author of this module
	Author = 'Dakota Zinn'
	
	# Company or vendor of this module
	CompanyName = ''
	
	# Copyright statement for this module
	Copyright = '(c) 2019. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description = 'RescueTime Module to integrate with API functionality of RescueTime'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '3.0'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '2.0'
	
	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = '2.0.50727'
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules = @()
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-RescueTime',
		'Get-RTAnalytics',
		'Get-RTSummaryFeed',
		'Get-RTAlerts',
		'Get-RTHighlights',
		'New-RTHighlight',
		'Start-RTFocusTime',
		'Stop-RTFocusTime',
		'Get-RTFocusTime',
		'Add-RTOfflineTime'
	) #For performance, list functions explicitly
	
	# Cmdlets to export from this module
	CmdletsToExport = '*' 
	
	# Variables to export from this module
	VariablesToExport = '*'
	
	# Aliases to export from this module
	AliasesToExport = '*' #For performance, list alias explicitly
	
	# DSC class resources to export from this module.
	#DSCResourcesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @("Time","RescueTime","Tracking","Productivity")
			
			# A URL to the license for this module.
			# LicenseUri = ''
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/daz96050/RescueTime'
			
			# A URL to an icon representing this module.
			IconUri = 'https://images-na.ssl-images-amazon.com/images/I/41MuhTV09PL._SX466_.png'
			
			# ReleaseNotes of this module
			ReleaseNotes = @'
V1.0.0.2
-Added GitHub Project Site to submit reports and Pull Requests
-Added Tags
-Added Icon
-Fixed issues with the Get-RTFocusTime feed
-Added 'Add-RTOfflineTime' to add offline time
-Renamed Start-FocusTime to Start-RTFocusTime
'@
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}







