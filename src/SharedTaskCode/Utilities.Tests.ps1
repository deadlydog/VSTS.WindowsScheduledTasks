# Pester v5 introduces breaking changes that we need to update to support, so until then use v4.
Install-Module -Name Pester -RequiredVersion 4.10.1 -Repository PSGallery
Import-Module -Name Pester -RequiredVersion 4.10.1

# Import the module to test.
Set-StrictMode -Version Latest
[string] $THIS_SCRIPTS_PATH = $PSCommandPath
[string] $moduleFilePathToTest = $THIS_SCRIPTS_PATH.Replace('.Tests.ps1', '.psm1') | Resolve-Path
Write-Verbose "Importing the module file '$moduleFilePathToTest' to run tests against it." -Verbose
Import-Module -Name $moduleFilePathToTest -Force

Describe 'Get-BoolValueFromString' {
	function Assert-BoolValueIsReturnedCorrectly
	{
		param
		(
			[string] $testDescription,
			[string] $string,
			[bool] $required,
			[bool] $expectedValue,
			[bool] $expectExceptionToBeThrown
		)

		It $testDescription {
			if ($expectExceptionToBeThrown)
			{
				# Act and Assert.
				{ Get-BoolValueFromString -string $string -required:$required } | Should -Throw
			}
			else
			{
				# Act.
				$result = Get-BoolValueFromString -string $string -required:$required

				# Assert.
				$result | Should -Be $expectedValue
			}
		}
	}

	[hashtable[]] $tests = @(
		@{	testDescription = 'When "true" is given, it should return true.'
			string = 'true'
			required = $false
			expectedValue = $true
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When "True" is given, it should return true.'
			string = 'True'
			required = $true
			expectedValue = $true
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When "TRUE" is given, it should return true.'
			string = 'TRUE'
			required = $false
			expectedValue = $true
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When "0" is given, it should return false.'
			string = '0'
			required = $false
			expectedValue = $false
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When "false" is given, it should return false.'
			string = 'false'
			required = $false
			expectedValue = $false
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When "1" is given, it should return false.'
			string = '1'
			required = $false
			expectedValue = $false
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When an empty string is given, it should return false.'
			string = ''
			required = $false
			expectedValue = $false
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When an invalid string is given, it should return false.'
			string = 'invalidValue'
			required = $false
			expectedValue = $false
			expectExceptionToBeThrown = $false
		}
		@{	testDescription = 'When an empty string is given and the required parameter was specified, it should throw an exception.'
			string = ''
			required = $true
			expectedValue = $false
			expectExceptionToBeThrown = $true
		}
		@{	testDescription = 'When an whitespace is given and the required parameter was specified, it should throw an exception.'
			string = '     '
			required = $true
			expectedValue = $false
			expectExceptionToBeThrown = $true
		}
	)
	$tests | ForEach-Object {
		[hashtable] $parameters = $_
		Assert-BoolValueIsReturnedCorrectly @parameters
	}
}
