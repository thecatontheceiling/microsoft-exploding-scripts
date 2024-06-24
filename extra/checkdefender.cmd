@echo off

>nul fltmc || (
echo Right click on this script and run as admin.
pause
exit
)

mode 120, 1000
if exist "%~dp0results.txt" del /f /q "%~dp0results.txt"
powershell "$f=[io.file]::ReadAllText('%~f0') -split ':xrm\:.*';iex ($f[1])" >>"%~dp0defresults.txt"
type "%~dp0results.txt"
pause
exit /b

:xrm:
$defaultStatus = @{
	AMRunningMode               = 'Normal';
	AMServiceEnabled            = $true;
	AntispywareEnabled          = $true;
	AntispywareSignatureAge     = '0';
	AntivirusEnabled            = $true;
	BehaviorMonitorEnabled      = $true;
	DefenderSignaturesOutOfDate = $false;
	FullScanOverdue             = $false;
	FullScanRequired            = $false;
	InitializationProgress      = 'ServiceStartedSuccessfully';
	IoavProtectionEnabled       = $true;
	IsTamperProtected           = $true;
	OnAccessProtectionEnabled   = $true;
	RealTimeProtectionEnabled   = $true;
	RebootRequired              = $false;
	SmartAppControlState        = 'Off';
	TamperProtectionSource      = 'Signatures';
}

$defaultPrefs = @{
	AttackSurfaceReductionOnlyExclusions          = $null
	ControlledFolderAccessAllowedApplications     = $null
	ControlledFolderAccessProtectedFolders        = $null
	DefinitionUpdatesChannel                      = 0
	DisableArchiveScanning                        = $false
	DisableBehaviorMonitoring                     = $false
	DisableBlockAtFirstSeen                       = $false
	DisableCacheMaintenance                       = $false
	DisableIOAVProtection                         = $false
	DisablePrivacyMode                            = $false
	DisableRealtimeMonitoring                     = $false
	DisableScanningNetworkFiles                   = $false
	DisableScriptScanning                         = $false
	DisableTamperProtection                       = $false
	EnableControlledFolderAccess                  = 0
	EnableEcsConfiguration                        = $false
	EnableFileHashComputation                     = $false
	EnableFullScanOnBatteryPower                  = $false
	EnableLowCpuPriority                          = $false
	EnableNetworkProtection                       = 0
	EngineUpdatesChannel                          = 0
	ExclusionExtension                            = $null
	ExclusionIpAddress                            = $null
	ExclusionPath                                 = $null
	ExclusionProcess                              = $null
	ForceUseProxyOnly                             = $false
	HideExclusionsFromLocalUsers                  = $True
	HighThreatDefaultAction                       = 0
	LowThreatDefaultAction                        = 0
	MAPSReporting                                 = 2
	ModerateThreatDefaultAction                   = 0
	NetworkProtectionReputationMode               = 0
	OobeEnableRtpAndSigUpdate                     = $false
	PerformanceModeStatus                         = 1
	PlatformUpdatesChannel                        = 0
	ProxyBypass                                   = $null
	ProxyPacUrl                                   = ""
	ProxyServer                                   = ""
	PUAProtection                                 = 1
	QuarantinePurgeItemsAfterDelay                = 90
	QuickScanIncludeExclusions                    = 0
	RandomizeScheduleTaskTimes                    = $True
	RealTimeScanDirection                         = 0
	RemoteEncryptionProtectionAggressiveness      = 0
	RemoteEncryptionProtectionConfiguredState     = 0
	RemoteEncryptionProtectionExclusions          = $null
	RemoteEncryptionProtectionMaxBlockTime        = 0
	RemoveScanningThreadPoolCap                   = $false
	ReportDynamicSignatureDroppedEvent            = $false
	ReportingAdditionalActionTimeOut              = 10080
	ReportingCriticalFailureTimeOut               = 10080
	ReportingNonCriticalTimeOut                   = 1440
	ScanParameters                                = 1
	ScanPurgeItemsAfterDelay                      = 15
	ServiceHealthReportInterval                   = 60
	SevereThreatDefaultAction                     = 0
	SharedSignaturesPath                          = ""
	SharedSignaturesPathUpdateAtScheduledTimeOnly = $false
	SignatureAuGracePeriod                        = 0
	SignatureBlobFileSharesSources                = ""
	SignatureBlobUpdateInterval                   = 60
	SignatureDefinitionUpdateFileSharesSources    = ""
	SignatureDisableUpdateOnStartupWithoutEngine  = $false
	SignatureFallbackOrder                        = 'MicrosoftUpdateServer|MMPC'
	SignatureUpdateCatchupInterval                = 1
	SignatureUpdateInterval                       = 0
	SubmitSamplesConsent                          = 1
	ThreatIDDefaultAction_Actions                 = $null
	ThreatIDDefaultAction_Ids                     = $null
	TrustLabelProtectionStatus                    = 0
	UILockdown                                    = $false
	UnknownThreatDefaultAction                    = 0
}

Get-MpThreat
Get-MpThreatDetection

$status = Get-MpComputerStatus
$prefs = Get-MpPreference

$status.AMEngineVersion
$status.AMProductVersion
$status.AMServiceVersion
$status.AntispywareSignatureLastUpdated
$status.IsVirtualMachine


function Write-Diff($current, $template) {
	foreach ($key in $template.Keys) {
		$currentValue = $current.$key
	
		if ($currentValue -ne $template[$key]) {
			Write-Output "$key $currentValue"
		}
	}
}

Write-Diff $status $defaultStatus
if ($prefs) {
	Write-Diff $prefs $defaultPrefs

	$allowed = $prefs.ThreatIDDefaultAction_Ids

	if ($allowed) { 
		Write-Output "Allowed threats found:"
		Get-MpThreatCatalog -ThreatID $allowed 
	}
}
else {
	Write-Output "Get-MpPreference failed!"
}
:xrm:
