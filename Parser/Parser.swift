//
//  Parser.swift
//  Crntl Parser
//
//  Created by Edwin Watkeys on 7/1/18.
//  Copyright © 2018 Thunk NYC Corp. All rights reserved.
//

import Foundation
import Crntl

public class Value : CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(type(of: self))"
    }
}

public class EndValue : Value {

}

public class ErrorValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(message)>"
    }

    let message: String;

    public init(_ message: String) {
        self.message = message
    }
}

public class PrimitiveValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(content)>"
    }

    var content: String

    public init(_ value: ParserValue) {
        let d = Data(bytes: value.content.token.wcs,
                     count: (value.content.token.wcs_length-1) * MemoryLayout<wchar_t>.size)
        let s = String(data: d, encoding: .utf32LittleEndian)
        self.content = s ?? "PARSEFAILED"
    }
}

public class BoxedValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(content)>"
    }

    var content: Value

    public init(_ value: ParserValue) {
        self.content = object(for_value: value.content.boxed_value.pointee)
    }
}

public class DerefValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class QuasiquoteValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class UnquoteValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class UnquoteSpliceValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class MetaValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class VarquoteValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class QuoteValue : BoxedValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class IntValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class FloatValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class SymbolValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class KeywordValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class StringValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class CharValue : PrimitiveValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class SequenceValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(contents)>"
    }

    var contents: [Value]

    public init(_ value: ParserValue) {
        self.contents = []
        var el = value.content.head_item
        while (el != nil) {
            contents.append(object(for_value: el!.pointee.value.i))
            el = el!.pointee.next
        }
    }

    public init(_ values: [Value]) {
        self.contents = values
    }

    public override init() {
        self.contents = []
    }
}

public class ListValue : SequenceValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class SetValue : SequenceValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class VectorValue : SequenceValue {
    public override init(_ value: ParserValue) {
        super.init(value)
    }
}

public class DictionaryEntryValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(key),\(value)>"
    }
    let key: Value;
    let value: Value;

    public init(_ key: Value, _ value: Value) {
        self.key = key
        self.value = value
    }
}

public class DictionaryValue : SequenceValue {
    public override init(_ value: ParserValue) {
        super.init()
        var el = value.content.head_item
        while (el != nil) {
            let k = object(for_value: el!.pointee.value.key_entry.k)
            let v = object(for_value: el!.pointee.value.key_entry.v)
            self.contents.append(DictionaryEntryValue(k, v))
            el = el!.pointee.next
        }
    }
}

public class TaggedValue : Value {
    public override var debugDescription: String {
        return "\(type(of: self))<\(tag),\(content)>"
    }
    let tag: SymbolValue
    let content: Value

    public init(_ value: ParserValue) {
        self.tag = object(for_value: value.content.tagged.tag.pointee) as! SymbolValue
        self.content = object(for_value: value.content.tagged.value.pointee)
    }
}

public class RawValue : Value {
    var value: ParserValue
    public init(_ value: ParserValue) {
        self.value = value
    }
    deinit {
        withUnsafeMutablePointer(to: &value, {
            crntl_freevalue($0)
        })
    }
}

public func object(for_value value: ParserValue) -> Value {
    switch value.type {
    case ERROR_VALUE:
        return ErrorValue("Error encountered while parsing")
    case END_VALUE:
        return EndValue()

    case PRIMITIVE_VALUE:
        switch value.content.token.type {
        case INTVAL:
            return IntValue(value)
        case FLOATVAL:
            return FloatValue(value)
        case SYMBOLVAL:
            return SymbolValue(value)
        case KEYWORDVAL:
            return KeywordValue(value)
        case STRINGVAL:
            return StringValue(value)
        case CHARVAL:
            return CharValue(value)

        default:
            return ErrorValue("Unknown primitive value")
        }

    case LIST_VALUE:
        return ListValue(value)
    case SET_VALUE:
        return SetValue(value)
    case VECT_VALUE:
        return VectorValue(value)

    case DICT_VALUE:
        return DictionaryValue(value)

    case TAGGED_VALUE:
        return TaggedValue(value)

    case DEREF_VALUE:
        return DerefValue(value)
    case QUASIQUOTE_VALUE:
        return QuasiquoteValue(value)
    case UNQUOTE_VALUE:
        return UnquoteValue(value)
    case UNQUOTESPLICE_VALUE:
        return UnquoteSpliceValue(value)
    case META_VALUE:
        return MetaValue(value)
    case VARQUOTE_VALUE:
        return VarquoteValue(value)
    case QUOTE_VALUE:
        return QuoteValue(value)

    default:
        return ErrorValue("Unknown composite value")
    }
}

internal func free(parser_value value: inout ParserValue) {
    withUnsafeMutablePointer(to: &value, { valuePtr in
        crntl_freevalue(valuePtr)
    })
}

public func parse(at_path path: String) -> [Value] {
    guard let filehandle = FileHandle(forReadingAtPath: path) else {
        return [ErrorValue("File does not exist")]
    }
    let mode: UnsafePointer<Int8> = "r".data(using: .utf8)!.withUnsafeBytes({$0})
    let fileptr = fdopen(filehandle.fileDescriptor, mode)

    defer { fclose(fileptr) }

    var state = TokenizerState()
    withUnsafeMutablePointer(to: &state, { crntl_state_init($0) })

    var values: [Value] = []

    var value = ParserValue()

    while(true) {
        withUnsafeMutablePointer(to: &value, { valuePtr in
            withUnsafeMutablePointer(to: &state, { statePtr in
                crntl_read(fileptr, valuePtr, statePtr)
            })
        })

        let o = object(for_value: value)

        switch o {
        case is ErrorValue:
            free(parser_value: &value)
            return [o]
        case is EndValue:
            free(parser_value: &value)
            return values
        default:
            free(parser_value: &value)
            values.append(o)
        }
    }
}

public func parse(string s: String) -> [Value] {
    let d = s.data(using: .utf8)
    let tmpDir = FileManager.default.temporaryDirectory
    var tmpUrl: URL
    repeat {
        let uuid = UUID()
        tmpUrl = URL(string: "\(uuid.uuidString).crntl", relativeTo: tmpDir)!
    } while FileManager.default.fileExists(atPath: tmpUrl.path)
    FileManager.default.createFile(atPath: tmpUrl.path, contents: d, attributes: [:])
    defer { FileManager.default.removeItem(atPath: tmpUrl.path) }
    return parse(at_path: tmpUrl.path)
}
