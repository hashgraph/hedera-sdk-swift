# hedera-sdk-swift

## Logging
To control the level of logs that are printed to stdout, setup the `LoggingSystem` at the start of your program/application

```swift
import Logging

LoggingSystem.bootstrap { label in
  var handler = StreamLogHandler.standardOutput(label: label)
  handler.logLevel = .debug
  return handler
}
```