# MyLogger


## Usage

LogLevel: all, debug, info, warn, error, fatal, and off

``` swift
let log = MyLogger(level: LogLevel.debug, name: "test")

log.debug("This is a debug message.")
log.info("This is an info message.")
log.warn("This is a warn message.")
log.error("This is an error message.")

```
