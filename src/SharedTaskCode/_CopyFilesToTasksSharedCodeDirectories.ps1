[string] $THIS_SCRIPTS_DIRECTORY_PATH = $PSScriptRoot
if ($THIS_SCRIPTS_DIRECTORY_PATH -ne 'SharedTaskCode')
{
	throw "This script should only be ran from the SharedTaskCode directory, not a specific task's directory. Directory this is being rane from is '$THIS_SCRIPTS_DIRECTORY_PATH'."
}

[string] $srcDirectoryPath = Split-Path -Path $THIS_SCRIPTS_DIRECTORY_PATH -Parent
[string[]] $tasksSharedCodeDirectoryPaths = @(
	'Tasks\InstallWindowsScheduledTask\Code\Shared'
	'Tasks\UninstallWindowsScheduledTask\Code\Shared'
)

$tasksSharedCodeDirectoryPaths | ForEach-Object {
	$tasksLocalSharedCodeDirectoryPath = $_
	$tasksDirectoryToCopyFilesTo = Join-Path -Path $srcDirectoryPath -ChildPath $tasksLocalSharedCodeDirectoryPath -Resolve

	Write-Verbose "Copying files from '$THIS_SCRIPTS_DIRECTORY_PATH' to '$tasksDirectoryToCopyFilesTo'." -Verbose
	Get-ChildItem -Path $THIS_SCRIPTS_DIRECTORY_PATH -Recurse -Force | Copy-Item -Destination $tasksDirectoryToCopyFilesTo -Force
}

Write-Output "Completed copying files"