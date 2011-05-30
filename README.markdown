# LIS

A simple interface to medical laboratory instruments. It implements a rough subset of ASTM E1394-97 (or, possibly CLSI LIS02-A2)

It listens for test requests and results and forwards them via HTTP.  It is intended to interface with the [worklist_manager](http://github.com/levinalex/worklist_manager) web application.


Developed for and tested with [DPC Immulite I2500][immulite] ([user manual][manual]) using the LIS specification version **600129-H** (not available online, but a [similar version might be
available][spec])

[immulite]: http://www.google.com/search?q=dpc+immulite+I2500
[manual]: http://sky2.ch/Doc/I2500.pdf
[spec]: http://www.google.com/search?q=dpc+lis+immulite+2000+filetype:pdf



## Copyright

Copyright (c) 2010-2011 Levin Alexander. See LICENSE for details.
