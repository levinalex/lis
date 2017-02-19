# LIS

[![Build Status](https://travis-ci.org/levinalex/lis.svg?branch=master)](https://travis-ci.org/levinalex/lis)

A simple interface to medical laboratory instruments. It implements a rough subset of ASTM E1394-97 (or, possibly CLSI LIS02-A2)

It listens for test requests and results and forwards them via HTTP.  It is intended to interface with the [worklist_manager](http://github.com/levinalex/worklist_manager) web application.


Developed for and tested with [DPC Immulite I2500][immulite] ([user manual][manual]) using the LIS specification version **600129-H** (not available online, but a [similar version might be
available][spec])

[immulite]: http://www.google.com/search?q=dpc+immulite+I2500
[manual]: http://sky2.ch/Doc/I2500.pdf
[spec]: http://www.google.com/search?q=dpc+lis+immulite+2000+filetype:pdf


## Usage

* run the LIS server:

    ```
    $ gem install lis
    $ lis help
    $ lis -l /dev/ttyUSB0 -e http://worklist.example/lis server
    ```

* now, whenever order requests arrive from the LIS hardware, lis2http will forward them to the specified HTTP endpoint:

    ```
    GET http://worklist.example/lis/{DEVICE_NAME}-{SPECIMEN_ID}
    ```

* this should return basic patient information as well as test IDs for all pending requests:

    ```
    ---
    id: '1234'
    patient:
      number: 98
      last_name: Sierra
      first_name: Rudolph
    types:
    - TSTID
    - TSH
    - FT3
    - FT4
    ```

* results are posted to the same URI as soon as they are received:

    ```
    POST http://worklist.example/lis/{DEVICE_NAME}-{SPECIMEN_ID}/{TEST_NAME}

    ---
    flags: N
    result_timestamp: '1993-10-11T09:12:33+00:00'
    status: F
    test_name: TSTID
    unit: mIU/mL
    value: '8.2'
    ```

## Changes

### 0.5.0 (2017-02-19)

* update dependencies
* test on modern rubies (2.0 to 2.4)

### 0.4.5 (2013-03-06)

* switched to using HTTParty from RestClient

### 0.4.4

* patient id is read from `patient/number` not `patient/id`
* switched command line tool to use Main, not GLI

### 0.4

* changed the HTTP Interface:

  * Requests now are at `{base_url}/{device_name}-{specimen_id}`
  * Results are posted to `{base_url}/{device_name}-{specimen_id}/{test_id}`


## Copyright

Copyright (c) 2010-2017 Levin Alexander. See LICENSE for details.
