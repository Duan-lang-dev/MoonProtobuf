// High-level Protobuf message encoder using Builder pattern.

struct Encoder {
  buf : Buffer
}

/// Create a new Encoder.
pub fn Encoder::new() -> Encoder {
  { buf: Buffer() }
}

/// Get the encoded bytes from the encoder.
pub fn Encoder::to_bytes(self : Encoder) -> Bytes {
  self.buf.to_bytes()
}

/// Encode an int32 field (wire type 0, varint).
pub fn Encoder::encode_int32(self : Encoder, field_number : UInt, value : Int) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_varint(self.buf, value.to_int64().reinterpret_as_uint64())
  self
}

/// Encode an int64 field (wire type 0, varint).
pub fn Encoder::encode_int64(self : Encoder, field_number : UInt, value : Int64) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_varint(self.buf, value.reinterpret_as_uint64())
  self
}

/// Encode a uint32 field (wire type 0, varint).
pub fn Encoder::encode_uint32(self : Encoder, field_number : UInt, value : UInt) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_varint(self.buf, value.to_uint64())
  self
}

/// Encode a uint64 field (wire type 0, varint).
pub fn Encoder::encode_uint64(self : Encoder, field_number : UInt, value : UInt64) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_varint(self.buf, value)
  self
}

/// Encode a sint32 field (wire type 0, zigzag + varint).
pub fn Encoder::encode_sint32(self : Encoder, field_number : UInt, value : Int) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_sint32(self.buf, value)
  self
}

/// Encode a sint64 field (wire type 0, zigzag + varint).
pub fn Encoder::encode_sint64(self : Encoder, field_number : UInt, value : Int64) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_sint64(self.buf, value)
  self
}

/// Encode a bool field (wire type 0, varint).
pub fn Encoder::encode_bool(self : Encoder, field_number : UInt, value : Bool) -> Encoder {
  write_tag(self.buf, field_number, WIRE_VARINT)
  encode_varint(self.buf, if value { 1UL } else { 0UL })
  self
}

/// Encode a fixed32 field (wire type 5).
pub fn Encoder::encode_fixed32(self : Encoder, field_number : UInt, value : UInt) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED32)
  write_fixed32(self.buf, value)
  self
}

/// Encode a sfixed32 field (wire type 5).
pub fn Encoder::encode_sfixed32(self : Encoder, field_number : UInt, value : Int) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED32)
  write_fixed32(self.buf, value.reinterpret_as_uint())
  self
}

/// Encode a float field (wire type 5).
pub fn Encoder::encode_float(self : Encoder, field_number : UInt, value : Float) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED32)
  write_float(self.buf, value)
  self
}

/// Encode a fixed64 field (wire type 1).
pub fn Encoder::encode_fixed64(self : Encoder, field_number : UInt, value : UInt64) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED64)
  write_fixed64(self.buf, value)
  self
}

/// Encode a sfixed64 field (wire type 1).
pub fn Encoder::encode_sfixed64(self : Encoder, field_number : UInt, value : Int64) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED64)
  write_fixed64(self.buf, value.reinterpret_as_uint64())
  self
}

/// Encode a double field (wire type 1).
pub fn Encoder::encode_double(self : Encoder, field_number : UInt, value : Double) -> Encoder {
  write_tag(self.buf, field_number, WIRE_FIXED64)
  write_double(self.buf, value)
  self
}

/// Encode a string field (wire type 2, length-delimited).
/// Strings are encoded as UTF-8 bytes.
pub fn Encoder::encode_string(self : Encoder, field_number : UInt, value : String) -> Encoder {
  let temp = Buffer()
  temp.write_string_utf8(value)
  let str_bytes = temp.to_bytes()
  write_length_delimited_prefix(self.buf, field_number, str_bytes.length().reinterpret_as_uint())
  self.buf.write_bytes(str_bytes)
  self
}

/// Encode a bytes field (wire type 2, length-delimited).
pub fn Encoder::encode_bytes(self : Encoder, field_number : UInt, value : Bytes) -> Encoder {
  write_length_delimited_prefix(self.buf, field_number, value.length().reinterpret_as_uint())
  self.buf.write_bytes(value)
  self
}

/// Encode a nested message field (wire type 2, length-delimited).
pub fn Encoder::encode_message(self : Encoder, field_number : UInt, inner : Encoder) -> Encoder {
  let inner_bytes = inner.to_bytes()
  write_length_delimited_prefix(self.buf, field_number, inner_bytes.length().reinterpret_as_uint())
  self.buf.write_bytes(inner_bytes)
  self
}
