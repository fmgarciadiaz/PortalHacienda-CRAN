# Test environments
* local OS X install, R 3.1.2
* ubuntu 12.04 (on travis-ci), R 3.1.2
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs. 


## 05-28-20 Resubmission
This is a resubmission. In this version I have:

 1. Fixed "This contradits each other: GPL-3 + file LICENSE means file LICENSE 
contains additional restrictions such as attribution requeirements. You 
should not specify a full license file here.If you want to allow GPL-2 in 
addition, simply write
License: GPL-2 | GPL-3 and omit the license file. " ---> Now GPL-3. Thanks!!

 2. Fixed "Is there some reference about the method you can add in the Description 
field in the form Authors (year) <doi:.....>?" ---> Added reference for the 
forecasting method (I simply use the forecast package, Hyndman RJ, Khandakar Y (2008))

## 07-06-20 Resubmission
This is a resubmission. In this version I have:

 0. Added Description in English 

 1. Fixed "Please add a DOI, arXiv or ISBN to your reference in your Description 
text in the form authors (year) <doi:...>
with no space after 'doi:', 'arXiv:' and angle brackets for auto-linking." 
**DONE:** (Added DOI)

 2. Fixed "Please do not comment out your examples and use \\donttest{} 
 instead:" **DONE:**  (Used \\donttest)

 3. Fixed. Please ensure that your functions do not modify (save or delete) the 
user's home filespace in your examples/vignettes/tests. That is not 
allow by CRAN policies. Please only write/save files if the user has 
specified a directory. In your examples/vignettes/tests you can write to 
tempdir(). I.e. download.file(..., file.path(tempdir(), "series-tiempo-metadatos.csv"))
**DONE:** changed the function so that it always write to tempdir()

## 07-06-20 Resubmission
This is a resubmission. In this version I have:
1. Fixed NOTES in automated tests (examples taking > 5 sec, removed possibly 
invalid URL).
2. Can't fix possibly miss-spelled words since they are just in Spanish!

## 06-13-20 v 0.1.1 Minor patch -  
As suggested by Uwe Ligges I'm moving some examples to /donttest since the take 
more than 5 secs. to run (there's no way I can reduce that running time since 
they involve connecting to the Ministry of Economy API, which has high latency). 
Also reduced the amount of retrieved data points in the examples, 
since big requests may come up with random server time-out errors, returning
ERROR in CRAN status.

## 06-14-20 Resubmission
- Temporary Ministry of Economy API error caused Readme.md to fail 

## 06-14-20 Resubmission
- Fixed Roxygen reexporting magrittr pipe causing WARNING

## 27-06-20 NEW VERSION V 0.1.3 UPDATES & Fixes
- Translated error messages to English as per Prof. Brian D. Ripley suggestion
- Updated to use timetk v 2.0 new parameters


## 07-15-20 Resumbission and version upgrade V 0.1.4:

Main changes & Fixes
--------------------

1) "Please single quote software names such as 'forecast' in the 
Description field and note that 'forecast' is a package rather than a 
library." Fixed as per Uwe Ligges request.

2) Prof. Brian d. Ripley requirement:
"You have *STILL* not complied with that policy:

   > TCN <- Get("174.1_T_DE_CATES_0_0_32", start_date = "2017")
     Downloading data series...
     Error in Get("174.1_T_DE_CATES_0_0_32", start_date = "2017") :
      Time-out error, please verify your internet connection.

There is nothing wrong with the check server's Internet (sic)
connection.  Yours is one of a handful of packages (out of 15800)
failing to connect."

- Sorry. I wasn't really understanding what was ment by the CRAN policy:

  > Packages which use Internet resources should fail gracefully with an
    informative message if the resource is not available (and not give a
    check warning nor error)

- CRAN Team: please accept my sincere apologies. Now I have:
  - Downgraded downloading ERRORS to MESSAGES to be in line with CRAN policy
  - The package now correctly identifies internet connection problems vs. other kind of download problems:
        - Added "no internet connection error" handling (via 'curl::has_internet')
        - Added user side request errors handling (via 'httr')
        - Added server side return errors handling (via 'httr') 
        - Server error messages are now returned to the user with a message

