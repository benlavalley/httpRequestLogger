Nothing fancy, just a node app to log details of HTTP requests for troubleshooting purposes.

Bare-minimum code - add a server cert/key to use for HTTPS (guide here for MacOS https://t.ly/jQpKO)

Logs requests in the console and to files that reflect the request url, body, detected body character set, and the headers received.

Summarizing some of the techniques I shared on our Rewst call - these apply generically to any web backend that isn't processing requests properly...

* In the case of Powershell, you can update your Rewst scripts to send webhook requests to both Rewst and this NodeJS app to troubleshoot what it is sending.
* See "listusertest.ps1" which includes a few commented lines that show how you can have it also send its request payloads to flat files, or ingest them from flat files to send outbound when reproducing an issue.
* You can look at your Rewst workflow results and find live webhooks that are still awaiting responses if the original Rewst request fails (e.g. 500 error)
* Use Powershell or apps like Postman to try and manually send requests to that webhook for issue reproduction

Hopefully this is something you never have to use, but if you do - it should help :)

-Ben
