
function Compare-FileHash {
    <#
    .SYNOPSIS
        Compares stored files against file hash
    .DESCRIPTION
        Takes FileHashInfo objects, typically by importing from clixml, and tests each file by re-hashing the file with the same algorithm.  
    .EXAMPLE
        PS C:\> Import-CliXML filehash.xml | Compare-FileHash
        Tests each filehash in the pipeline from a saved CliXML like from Save-FileHash
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Writes error messages for any files that no longer match their hash
        Writes warnings for any missing files
        Write Verbose shows "OK" for each file passing hash check
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        HelpMessage = "File hashes to test - see Get-FileHash")]
        # Note takes PSObject which is output of import-clixml per docs, 
        # Actual object types seen with "Get-Member" are ..FileHash from Get-FileHash or Deserialized...FileHashInfo from import-clixml
        #[Microsoft.Powershell.Utility.FileHash[]]
        #[Deserialized.Microsoft.PowerShell.Commands.FileHashInfo[]]
        [PSObject[]]
        $Hashlist        
    )
    
    begin {
        
    }
    
    process {
        ForEach ($file in $Hashlist) {
            $output = $file.Path + ': '
            if (!(Test-Path -Path $file.Path)) {
                $output = $output + 'File missing!'
                Write-Warning -Message $output
                Continue
            }
            if ($file.Hash -EQ (Get-FileHash $file.Path -Algorithm $file.Algorithm).Hash ) {
                $output = $output + 'OK'
                Write-Verbose -Message "$output"
            }
            else {
                $output = $output + '[' + $file.Algorithm + '] mismatch'
                Write-Error -Message "$output"
            }
        }
    }
    
    end {
        
    }
}
