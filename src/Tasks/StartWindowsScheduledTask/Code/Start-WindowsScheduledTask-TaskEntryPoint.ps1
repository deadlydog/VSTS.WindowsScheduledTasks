param
(
	[parameter(Mandatory=$true,HelpMessage="The full name, including the path, of the Windows Scheduled Task to start.")]
	[ValidateNotNullOrEmpty()]
	[string] $ScheduledTaskFullName,

	[parameter(Mandatory=$false,HelpMessage="Comma-separated list of the computer(s) to start the scheduled task on.")]
	[string] $ComputerNames,

	[parameter(Mandatory=$false,HelpMessage="The username to use to connect to the computer(s).")]
	[string] $Username,

	[parameter(Mandatory=$false,HelpMessage="The password to use to connect to the computer(s).")]
	[string] $Password,

	[parameter(Mandatory = $false, HelpMessage = "The authentication mechanism to use when connecting to remote computers.")]
	[ValidateSet('Default', 'Basic', 'CredSSP', 'Digest', 'Kerberos', 'Negotiate', 'NegotiateWithImplicitCredential')]
	[string] $AuthenticationOptions,

	[parameter(Mandatory = $false, HelpMessage = "The protocol to use when connecting to remote computers.")]
	[ValidateSet('HTTP', 'HTTPS')]
	[string] $ProtocolOptions,

	[parameter(Mandatory = $false, HelpMessage = "If SkipCACheck should be used when connecting to remote computers or not.")]
	[string] $ProtocolSkipCaCheckString,

	[parameter(Mandatory = $false, HelpMessage = "If SkipCNCheck should be used when connecting to remote computers or not.")]
	[string] $ProtocolSkipCnCheckString,

	[parameter(Mandatory = $false, HelpMessage = "If SkipRevocationCheck should be used when connecting to remote computers or not.")]
	[string] $ProtocolSkipRevocationCheckString
)

Process
{
	Write-Verbose "Will attempt to start Windows Scheduled Task '$ScheduledTaskFullName' on '$ComputerNames'." -Verbose

	[bool] $protocolSkipCaCheck = Get-BoolValueFromString -string $ProtocolSkipCaCheckString
	[bool] $protocolSkipCnCheck = Get-BoolValueFromString -string $ProtocolSkipCnCheckString
	[bool] $protocolSkipRevocationCheck = Get-BoolValueFromString -string $ProtocolSkipRevocationCheckString

	[string[]] $computers = Get-ComputersToConnectToOrNull -computerNames $ComputerNames
	[PSCredential] $credential = Convert-UsernameAndPasswordToCredentialsOrNull -username $Username -password $Password
	[hashtable] $taskNameAndPath = Get-ScheduledTaskNameAndPath -fullTaskName $ScheduledTaskFullName

	[hashtable] $winRmSettings = Get-WinRmSettings -computers $computers -credential $credential -authenticationMechanism $AuthenticationOptions -protocol $ProtocolOptions -skipCaCheck $protocolSkipCaCheck -skipCnCheck $protocolSkipCnCheck -skipRevocationCheck $protocolSkipRevocationCheck

	Start-WindowsScheduledTask -ScheduledTaskName $taskNameAndPath.Name -ScheduledTaskPath $taskNameAndPath.Path -WinRmSettings $winRmSettings -Verbose
}

Begin
{
	# Display environmental information before doing anything else in case we encounter errors.
	[string] $operatingSystemVersion = [System.Environment]::OSVersion
	[string] $powerShellVersion = $PSVersionTable.PSVersion
	Write-Verbose "Running on operating system '$operatingSystemVersion' and PowerShell version '$powerShellVersion'." -Verbose

	# Build paths to modules to import and import them.
	[string] $THIS_SCRIPTS_DIRECTORY_PATH = $PSScriptRoot
	[string] $codeDirectoryPath = $THIS_SCRIPTS_DIRECTORY_PATH

	[string] $utilitiesModuleFilePath = Join-Path -Path $codeDirectoryPath -ChildPath 'Shared\Utilities.psm1'
	Write-Debug "Importing module '$utilitiesModuleFilePath'."
	Import-Module -Name $utilitiesModuleFilePath -Force

	[string] $userInputToScheduledTaskMapperModuleFilePath = Join-Path -Path $codeDirectoryPath -ChildPath 'Shared\UserInputToScheduledTaskMapper.psm1'
	Write-Debug "Importing module '$userInputToScheduledTaskMapperModuleFilePath'."
	Import-Module -Name $userInputToScheduledTaskMapperModuleFilePath -Force

	[string] $userInputToWinRmSettingsMapperModuleFilePath = Join-Path -Path $codeDirectoryPath -ChildPath 'Shared\UserInputToWinRmSettingsMapper.psm1'
	Write-Debug "Importing module '$userInputToWinRmSettingsMapperModuleFilePath'."
	Import-Module -Name $userInputToWinRmSettingsMapperModuleFilePath -Force

	[string] $startWindowsScheduledTaskModuleFilePath = Join-Path -Path $codeDirectoryPath -ChildPath 'Start-WindowsScheduledTask.psm1'
	Write-Debug "Importing module '$startWindowsScheduledTaskModuleFilePath'."
	Import-Module -Name $startWindowsScheduledTaskModuleFilePath -Force
}
