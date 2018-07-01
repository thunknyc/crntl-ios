# CRNTL for iOS: C Reader for the Next Thousand Lisps, for iOS

For more information, please see the main [CRNTL](https://github.com/thunknyc/crntl) project.

Status:

It works. The sample function

```swift4
public func test_parse() {

    let values = parse(string: "{:answer 42}")
    for v in values {
        print("Value: \(v)")
    }
}
```

produces the output `Value: DictionaryValue<[DictionaryEntryValue<KeywordValue<answer>,IntValue<42>>]>`.
