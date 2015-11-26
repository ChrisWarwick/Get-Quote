# Get-Quote
Chris Warwick, @cjwarwickps, November 2015


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


Script Help
-----------
````

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


````


Version History:
---------------

 V1.0 (This Version)
  - Initial release to the PowerShell Gallery 

 V0.1-0.9 Dev versions


Other Modules:
------------
See all my other PS Gallery modules: 

````
  Find-Module | Where Author -match 'Chris Warwick'
````
