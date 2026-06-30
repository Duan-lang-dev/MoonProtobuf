// Wire type encoding/decoding for protobuf wire format.
// Reference: https://protobuf.dev/programming-guides/encoding/

/// Make a protobuf tag from field number and wire type.
/// tag = (field_number << 3) | wire_type
pub fn make_tag(field_number : UInt, wire_type : UInt) -> UInt {
  (field_number << 3) | wire_type
}

/// Split a protobuf tag into (field_number, wire_type).
pub fn split_tag(tag : UInt) -> (UInt, UInt) {
  (tag >> 3, tag & 7)
}

/// Write a protobuf tag to the buffer.
pub fn write_tag(buf : Buffer, field_number : UInt, wire_type : UInt) -> Unit {
  encode_varint(buf, make_tag(field_number, wire_type).to_uint64())
}

/// Write a Length-delimited field prefix: tag + length as varint.
pub fn write_length_delimited_prefix(
  buf : Buffer,
  field_number : UInt,
  byte_length : UInt
) -> Unit {
  write_tag(buf, field_number, WIRE_LENGTH_DELIMITED)
  encode_varint(buf, byte_length.to_uint64())
}

/// Write a fixed32 value in little-endian format.
pub fn write_fixed32(buf : Buffer, value : UInt) -> Unit {
  buf.write_byte((value & 0xFF).to_byte())
  buf.write_byte(((value >> 8) & 0xFF).to_byte())
  buf.write_byte(((value >> 16) & 0xFF).to_byte())
  buf.write_byte(((value >> 24) & 0xFF).to_byte())
}

/// Write a fixed64 value in little-endian format.
pub fn write_fixed64(buf : Buffer, value : UInt64) -> Unit {
  for i in 0..<8 {
    buf.write_byte(((value >> (i * 8)) & 0xFF).to_byte())
  }
}

/// Write a float as fixed32.
pub fn write_float(buf : Buffer, value : Float) -> Unit {
  write_fixed32(buf, value.reinterpret_as_uint())
}

/// Write a double as fixed64.
pub fn write_double(buf : Buffer, value : Double) -> Unit {
  write_fixed64(buf, value.reinterpret_as_uint64())
}

/// Read a fixed32 value from bytes at the given position.
/// Returns (value, new_position) or None if out of bounds.
pub fn read_fixed32(bytes : Bytes, pos : Int) -> (UInt, Int)? {
  if pos < 0 || pos + 4 > bytes.length() {
    return None
  }
  let value = bytes[pos].to_uint()
    | (bytes[pos + 1].to_uint() << 8)
    | (bytes[pos + 2].to_uint() << 16)
    | (bytes[pos + 3].to_uint() << 24)
  Some((value, pos + 4))
}

/// Read a fixed64 value from bytes at the given position.
/// Returns (value, new_position) or None if out of bounds.
pub fn read_fixed64(bytes : Bytes, pos : Int) -> (UInt64, Int)? {
  if pos < 0 || pos + 8 > bytes.length() {
    return None
  }
  let mut value : UInt64 = 0
  for i in 0..<8 {
    value = value | (bytes[pos + i].to_uint64() << (i * 8))
  }
  Some((value, pos + 8))
}
