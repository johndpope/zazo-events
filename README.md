Zazo SQS worker
===============

[![wercker status](https://app.wercker.com/status/f7ba9ca361242d452a563b4fd3b049f6/m "wercker status")](https://app.wercker.com/project/bykey/f7ba9ca361242d452a563b4fd3b049f6)

The service for:
* storing events data from SQS queue triggered by S3 and Zazo API.
* API for statistics metrics calculated from stored events.

Stack
------

* Rails 4.2
* PostgreSQL 9.4.1 (Amazon RDS)
* AWS SDK
* Rollbar
* wercker
* NewRelic RPM

Documentation
-------------

* [Events API](./blob/dev/doc/events.apib)
* [Metrics API](./doc/metrics.apib)
