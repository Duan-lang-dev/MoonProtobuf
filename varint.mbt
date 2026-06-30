// Protobuf varint (ULEB128) encoding and decoding.
// Reference: https://protobuf.dev/programming-guides/encoding/#varints

/// Encode an unsigned 64-bit integer as a protobuf varint into the buffer.
pub fn encode_varint(buf : Buffer, value : UInt64) -> Unit {
  for v = value {
    if v < 128 {
      buf.write_byte(v.to_byte())
      break
    } else {
      buf.write_byte(((v & 127) | 128).to_byte())
      continue v >> 7
    }
  }
}

/// Decode a protobuf varint from bytes at a given position.
/// Returns `(value, bytes_consumed)` or `None` if the varint is truncated.
pub fn decode_varint(bytes : Bytes, pos : Int) -> (UInt64, Int)? {
  if pos < 0 {
    return None
  }
  let mut result : UInt64 = 0
  let mut shift = 0
  // Max bytes needed for a 64-bit varint is ceil(64/7) = 10
  for i in 0..<10 {
    if pos + i >= bytes.length() {
      return None
    }
    let byte = bytes[pos + i].to_uint64()
    if byte < 128 {
      result = result | (byte << shift)
      return Some((result, i + 1))
    }
    result = result | ((byte & 127) << shift)
    shift += 7
  }
  None
}

/// Zigzag encode a signed 32-bit integer to unsigned.
pub fn encode_zigzag32(value : Int) -> UInt {
  ((value << 1) ^ (value >> 31)).reinterpret_as_uint()
}

/// Zigzag decode an unsigned 32-bit integer to signed.
pub fn decode_zigzag32(value : UInt) -> Int {
  (value >> 1).reinterpret_as_int() ^ (-((value & 1).reinterpret_as_int()))
}

/// Zigzag encode a signed 64-bit integer to unsigned.
pub fn encode_zigzag64(value : Int64) -> UInt64 {
  ((value << 1) ^ (value >> 63)).reinterpret_as_uint64()
}

/// Zigzag decode an unsigned 64-bit integer to signed.
pub fn decode_zigzag64(value : UInt64) -> Int64 {
  (value >> 1).reinterpret_as_int64() ^ (-((value & 1).reinterpret_as_int64()))
}

/// Encode a signed 32-bit integer as a zigzag-encoded varint.
pub fn encode_sint32(buf : Buffer, value : Int) -> Unit {
  encode_varint(buf, encode_zigzag32(value).to_uint64())
}

/// Encode a signed 64-bit integer as a zigzag-encoded varint.
pub fn encode_sint64(buf : Buffer, value : Int64) -> Unit {
  encode_varint(buf, encode_zigzag64(value))
}

/// Decode a zigzag-encoded signed 32-bit varint from bytes at a given position.
/// Returns `(value, bytes_consumed)` or `None` if the varint is truncated.
pub fn decode_sint32(bytes : Bytes, pos : Int) -> (Int, Int)? {
  match decode_varint(bytes, pos) {
    None => None
    Some((value, consumed)) => Some((decode_zigzag32(value.to_uint()), consumed))
  }
}

/// Decode a zigzag-encoded signed 64-bit varint from bytes at a given position.
/// Returns `(value, bytes_consumed)` or `None` if the varint is truncated.
pub fn decode_sint64(bytes : Bytes, pos : Int) -> (Int64, Int)? {
  match decode_varint(bytes, pos) {
    None => None
    Some((value, consumed)) => Some((decode_zigzag64(value), consumed))
  }
}
