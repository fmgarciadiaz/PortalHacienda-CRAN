## Test environments
* local OS X install, R 3.1.2
* ubuntu 12.04 (on travis-ci), R 3.1.2
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs. 


---
## 05-28-20 Resubmission
---

- 1. "This contradits each other: GPL-3 + file LICENSE means file LICENSE 
contains additional restrictions such as attribution requeirements. You 
shold not specify a full license file here.If you want to allow GPL-2 in addition, somply write

License: GPL-2 | GPL-3 and omit the license file. " FIXED - Now only GPL-3

- 2. "Is there some reference about the method you can add in the Description 
field in the form Authors (year) <doi:.....>?" FIXED Added reference for the forecasting method (forecast package, Hyndman RJ, Khandakar Y (2008))