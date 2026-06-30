# MoonProto

A pure-runtime [Protocol Buffers](https://protobuf.dev/) wire format encoder/decoder for MoonBit.

## Features

- Varint (ULEB128) and Zigzag encoding/decoding
- All protobuf wire types: Varint, Fixed64, Length-delimited, Fixed32
- Builder-style Encoder API with method chaining
- Position-tracked Decoder API with field skipping
- Support for all scalar types: int32/64, uint32/64, sint32/64, fixed32/64, sfixed32/64, float, double, bool, string, bytes
- Nested message encoding/decoding

## Installation

```bash
moon add Duan525/moonproto
```

## Usage

### Encoding

```mbt
let enc = @moonproto.Encoder::new()
enc.encode_string(1U, "Alice")
  .encode_int32(2U, 30)
  .encode_message(3U, nested_encoder)
let bytes = enc.to_bytes()
```

### Decoding

```mbt
let dec = @moonproto.Decoder::new(bytes)
while dec.read_tag() is Some((field_num, wire_type)) {
  match field_num {
    1U => name = dec.read_string().unwrap()
    2U => age = dec.read_int32().unwrap()
    _ => dec.skip_field(wire_type) |> ignore
  }
}
```

## Wire Format Reference

| Wire Type | ID | Used For |
|-----------|----|----------|
| Varint | 0 | int32, int64, uint32, uint64, sint32, sint64, bool, enum |
| Fixed64 | 1 | fixed64, sfixed64, double |
| Length-delimited | 2 | string, bytes, embedded messages, packed repeated |
| Fixed32 | 5 | fixed32, sfixed32, float |

## License

MIT
