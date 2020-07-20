# Test environments
* local OS X install, R 3.1.2
* ubuntu 12.04 (on travis-ci), R 3.1.2
* win-builder (devel and release)

## 07-18-20 Resumbission and version upgrade V 0.1.4:
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

- There were no ERRORs nor WARNINGs (1 NOTE due to spanish words in description)
        - local OS X with R 3.6.2
        - win-builder
        - R-hub Fedora & Ubuntu
