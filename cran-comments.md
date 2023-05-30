# Test environments
* local OS X install, R 3.1.2
* ubuntu 12.04 (on travis-ci), R 3.1.2
* win-builder (devel and release)

## 14-10-20 v0.1.7
-------------------
- Minor bug correction. Lazydata = FALSE to remove note.


## 14-10-20 v0.1.6
-------------------
- Fixed: httr::GET timeout was not handled properly, resulting in random errors.
  API (random) timeouts are now properly handled with purrr::safely. 
  I think this is why the package was removed:
  
  << v0.1.5 was removed from CRAN because of that problem:
   Error: processing vignette 'Tutorial.Rmd' failed with diagnostics:
    Timeout was reached: [apis.datos.gob.ar] Operation timed out after 154 milliseconds with 0 bytes received
    --- failed re-building ‘Tutorial.Rmd’ >>


## 10-10-20
------------
- Updated another Zenodo URL in README.md (Sorry, had missed that one in the last submit)

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

