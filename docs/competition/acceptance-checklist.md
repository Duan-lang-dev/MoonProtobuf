# MoonProto — Competition Acceptance Checklist

## Core Features

### Varint & Zigzag
- [x] `encode_varint(buf, value)` — ULEB128 encode for UInt64
- [x] `decode_varint(bytes, pos)` — ULEB128 decode, returns (value, consumed)?
- [x] `encode_zigzag32(value)` / `decode_zigzag32(value)` — 32-bit zigzag
- [x] `encode_zigzag64(value)` / `decode_zigzag64(value)` — 64-bit zigzag
- [x] `encode_sint32(buf, value)` / `encode_sint64(buf, value)` — zigzag + varint
- [x] `decode_sint32(bytes, pos)` / `decode_sint64(bytes, pos)` — decode + zigzag

### Wire Type Layer
- [x] `make_tag(field_number, wire_type)` / `split_tag(tag)` — tag encode/decode
- [x] `write_tag(buf, field_number, wire_type)` — write tag to buffer
- [x] `write_length_delimited_prefix(buf, field_number, length)` — tag + length prefix
- [x] `write_fixed32(buf, value)` / `write_fixed64(buf, value)` — fixed-type write
- [x] `write_float(buf, value)` / `write_double(buf, value)` — float write
- [x] `read_fixed32(bytes, pos)` / `read_fixed64(bytes, pos)` — fixed-type read with bounds check

### High-level Encoder (20 methods)
- [x] `Encoder::new()` / `to_bytes()` — create encoder, get result
- [x] `encode_int32/64`, `encode_uint32/64`, `encode_sint32/64` — varint types
- [x] `encode_bool` — bool as varint
- [x] `encode_fixed32/64`, `encode_sfixed32/64` — fixed types
- [x] `encode_float`, `encode_double` — floating point
- [x] `encode_string`, `encode_bytes` — length-delimited
- [x] `encode_message` — nested message
- [x] Builder pattern: all methods return Encoder for chaining

### High-level Decoder (19 methods)
- [x] `Decoder::new(bytes)` — create decoder from bytes
- [x] `read_tag()` — read next (field_number, wire_type)?
- [x] `read_int32/64`, `read_uint32/64`, `read_sint32/64` — varint types
- [x] `read_bool` — bool from varint
- [x] `read_fixed32/64`, `read_sfixed32/64` — fixed types
- [x] `read_float`, `read_double` — floating point
- [x] `read_string`, `read_bytes` — length-delimited
- [x] `read_message` — nested message decoder
- [x] `skip_field(wire_type)` — skip unknown field

### Packed Repeated Fields
- [x] `encode_packed_varint/fixed32/fixed64/float/double` — 5 encode functions
- [x] `decode_packed_varint/fixed32/fixed64` — 3 decode functions

### Proto File Parser
- [x] `parse_proto(content)` — parse proto3 syntax
- [x] Message definitions with fields (name, number, type, label)
- [x] Enum definitions with values
- [x] Nested messages and enums
- [x] Repeated field label support

### Integration & Message Trait
- [x] `Message` trait with `encode(Self, Encoder) -> Unit`
- [x] Roundtrip tests: Person message, UTF-8, large integers, fixed types, nested (3 levels), 20 fields
- [x] Zero values, max values, field order independence
- [x] Skip mixed wire types across all 4 wire types

## Project Quality
- [x] `moon check` passes with 0 errors
- [x] `moon test` — 80 tests, all passing
- [x] `moon build` succeeds
- [x] CI configuration (`.github/workflows/ci.yml`)
- [x] README with installation, quick start, and API reference
- [x] MIT License
- [x] 15 meaningful commits

## Code Statistics
- varint: 87 lines source + 111 lines test (16 tests)
- wire: 79 lines source + 76 lines test (11 tests)
- encoder: 132 lines source + 83 lines test (11 tests)
- decoder: 288 lines source + 156 lines test (14 tests)
- packed: 95 lines source + 109 lines test (6 tests)
- proto_parser: 460 lines source + 121 lines test (8 tests)
- moonproto: 13 lines source + 406 lines test (8 tests)
- CLI: 62 lines
- Total: ~2,279 lines

## Competition Submission
- [x] GitHub repository created
- [ ] GitLink mirror pushed
- [x] 15 meaningful commits
- [ ] Project proposal PDF generated
