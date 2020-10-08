# Test environments
* local OS X install, R 3.1.2
* ubuntu 12.04 (on travis-ci), R 3.1.2
* win-builder (devel and release)

## 08-10-20
------------
- Updated Zenodo URL in README.md

Thanks, we see:
   Found the following (possibly) invalid URLs:
     URL: http://doi.org/10.5281/zenodo.3893947 (moved to 
https://doi.org/10.5281/zenodo.3893947)
       From: README.md
       Status: 200
       Message: OK
Please change http --> https, add trailing slashes, or follow moved 
content as appropriate.
Please fix and resubmit.


## 09-26-20 PortalHacienda 0.1.5
-----------
- Package was archived but I'm not sure why!! (I didn't get any warning notification)
- Anyway, I corrected these problems from V 0.1.4:
  - Description had a repeated line
  - Dropped readr from Imports (not needed after moving from download.file to GET)
  - Dropped download.file from NAMESPACE (which was not used)
- Plus: Added Tutorial Vignette


