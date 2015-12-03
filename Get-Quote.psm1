<#
Get-Quote

Chris Warwick, @cjwarwickps, January 2012.  This version, November 2015.

Read a Quote/Cookie/Fortune/MOTD from a file and display it.

The fortunes file consists of thousands of random quotes.  As a quote can contain
newline characters, each individual quote is delimited with a 0x00 character; the 
delimiter is also present as the first and last character in the file in order to
simplify the parsing below.

Rather than reading the entire file before selecting a random quote the script uses
the FileStream.Seek method to locate and read a randomly-placed small chunk of the
file. A quotes is then selected randomly and extracted from the resutling data.

Bugs: There's no error checking.  The quote file must be ASCII encoded.

Historical Note: The quote file used here is just over 600kB in size. Back in the 
day this could have take some considerable time to read from (slow) disk. Now, of
course, with tablets having GBs of memory and SSDs, this size is trivial and the
effort of attempting to read the file efficiently as opposed to simply grabbing the
whole thing with Get-Content is academic.  However, the techniques may still be of
value if truly large files are being processed... 

#>


#Requires -Version 2



<#
.Synopsis
  Searches for the file containing the huge list of quotes

.Example
  Find-ModuleQuoteFile
  C:\Users\john\Documents\WindowsPowerShell\Modules\Get-Quote\Fortunes.dat

.Outputs
  [System.String]
  The path pointing to the quotes file
#>
Function Find-QuoteFile {	 
    $ProjectRoot = Split-Path -Parent $Script:PSCommandPath
    Join-Path $ProjectRoot 'Fortunes.dat'

}


<#
.Synopsis
    This function displays a randomly chosen quote from a quote file
.Description
    Displays a random quote/cookie/fortune/message-of-the-day
.Example
    Get-Quote
    I've had a perfectly wonderful evening.  But this wasn't it.
		-- Groucho Marx
.Parameter QuoteFile
    A file containing quotes; will use '.\fortunes.dat' by default.
#>
Function Get-Quote {
[OutputType([String])]
[Alias('Cookie')]
Param (
    [String] $QuoteFile
)
    If ( -not $QuoteFile ) {
        $QuoteFile = Find-QuoteFile
    }
    
    # Use a filestream to randomly read the quote file
    $FileStreamArgs = @(
        $QuoteFile
        [System.IO.FileMode]::Open
        [System.IO.FileAccess]::Read
        [System.IO.FileShare]::ReadWrite
    )

    $FileStream = New-Object -TypeName System.IO.FileStream -ArgumentList $FileStreamArgs

    # Read a number of characters that's quick but which will include at least one whole quote.
    # Attempt to read approx 8kB worth of text (but don't try to read more than the size of the file)

    $CharactersToRead = [Math]::Min(8000,$FileStream.Length-1)   
    $Buffer = New-Object -TypeName Byte[] -ArgumentList $CharactersToRead

    # Pick some random place in the quote file, go there and read characters...
    $SeekPosition = Get-Random ($FileStream.Length-$CharactersToRead)
    [Void]$FileStream.Seek($SeekPosition,[System.IO.SeekOrigin]::Begin) 
    [Void]$FileStream.Read($Buffer,0,$CharactersToRead)

    # Convert the bytes into a string of ASCII characters...
    $Quotes = [System.Text.Encoding]::ASCII.GetString($Buffer) 

    # Quotes are delimited by 0x00 characters; discard any partial quotes on the front and end 
    # of the string, then split the remainder into individual quotes and pick one at random. 
    # NB: In the regex, \A matches the beginning of string and \z matches the very end (even after line breaks)

    $Quotes -Replace '(?s)\A.*?\x00' -Replace '(?s)\x00[^\x00]*\z' -Split "`0" | Get-Random
}
