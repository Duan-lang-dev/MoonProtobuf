// Packed repeated field encoding and decoding for protobuf.
// Reference: https://protobuf.dev/programming-guides/encoding/#packed

/// Encode a packed repeated varint field (int32, uint32, sint32, bool, enum, int64, etc.)
pub fn encode_packed_varint(buf : Buffer, field_number : UInt, values : Array[UInt64]) -> Unit {
  // First write all values to a temp buffer to compute length
  let temp = Buffer()
  for v in values {
    encode_varint(temp, v)
  }
  let data = temp.to_bytes()
  write_length_delimited_prefix(buf, field_number, data.length().reinterpret_as_uint())
  buf.write_bytes(data)
}

/// Encode a packed repeated fixed32 field.
pub fn encode_packed_fixed32(buf : Buffer, field_number : UInt, values : Array[UInt]) -> Unit {
  let len = values.length() * 4
  write_length_delimited_prefix(buf, field_number, len.reinterpret_as_uint())
  for v in values {
    write_fixed32(buf, v)
  }
}

/// Encode a packed repeated fixed64 field.
pub fn encode_packed_fixed64(buf : Buffer, field_number : UInt, values : Array[UInt64]) -> Unit {
  let len = values.length() * 8
  write_length_delimited_prefix(buf, field_number, len.reinterpret_as_uint())
  for v in values {
    write_fixed64(buf, v)
  }
}

/// Encode a packed repeated float field.
pub fn encode_packed_float(buf : Buffer, field_number : UInt, values : Array[Float]) -> Unit {
  let len = values.length() * 4
  write_length_delimited_prefix(buf, field_number, len.reinterpret_as_uint())
  for v in values {
    write_float(buf, v)
  }
}

/// Encode a packed repeated double field.
pub fn encode_packed_double(buf : Buffer, field_number : UInt, values : Array[Double]) -> Unit {
  let len = values.length() * 8
  write_length_delimited_prefix(buf, field_number, len.reinterpret_as_uint())
  for v in values {
    write_double(buf, v)
  }
}

/// Decode all varints from packed bytes into an array.
pub fn decode_packed_varint(data : Bytes) -> Array[UInt64] {
  let mut pos = 0
  let result : Array[UInt64] = []
  while pos < data.length() {
    if decode_varint(data, pos) is Some((v, consumed)) {
      result.push(v)
      pos += consumed
    } else {
      break
    }
  }
  result
}

/// Decode all fixed32 values from packed bytes into an array.
pub fn decode_packed_fixed32(data : Bytes) -> Array[UInt] {
  let mut pos = 0
  let result : Array[UInt] = []
  while pos + 4 <= data.length() {
    if read_fixed32(data, pos) is Some((v, new_pos)) {
      result.push(v)
      pos = new_pos
    } else {
      break
    }
  }
  result
}

/// Decode all fixed64 values from packed bytes into an array.
pub fn decode_packed_fixed64(data : Bytes) -> Array[UInt64] {
  let mut pos = 0
  let result : Array[UInt64] = []
  while pos + 8 <= data.length() {
    if read_fixed64(data, pos) is Some((v, new_pos)) {
      result.push(v)
      pos = new_pos
    } else {
      break
    }
  }
  result
}
