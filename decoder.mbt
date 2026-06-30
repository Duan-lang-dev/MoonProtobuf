// High-level Protobuf message decoder.

struct Decoder {
  bytes : Bytes
  mut pos : Int
}

/// Create a new Decoder from bytes.
pub fn Decoder::new(bytes : Bytes) -> Decoder {
  { bytes, pos: 0 }
}

/// Read the next tag. Returns (field_number, wire_type) or None at end.
pub fn Decoder::read_tag(self : Decoder) -> (UInt, UInt)? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      let (field_number, wire_type) = split_tag(value.to_uint())
      Some((field_number, wire_type))
    }
  }
}

/// Read an int32 value (wire type 0).
pub fn Decoder::read_int32(self : Decoder) -> Int? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(value.to_int())
    }
  }
}

/// Read an int64 value (wire type 0).
pub fn Decoder::read_int64(self : Decoder) -> Int64? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(value.to_int64())
    }
  }
}

/// Read a uint32 value (wire type 0).
pub fn Decoder::read_uint32(self : Decoder) -> UInt? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(value.to_uint())
    }
  }
}

/// Read a uint64 value (wire type 0).
pub fn Decoder::read_uint64(self : Decoder) -> UInt64? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(value)
    }
  }
}

/// Read a sint32 value (wire type 0, zigzag).
pub fn Decoder::read_sint32(self : Decoder) -> Int? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(decode_zigzag32(value.to_uint()))
    }
  }
}

/// Read a sint64 value (wire type 0, zigzag).
pub fn Decoder::read_sint64(self : Decoder) -> Int64? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(decode_zigzag64(value))
    }
  }
}

/// Read a bool value (wire type 0).
pub fn Decoder::read_bool(self : Decoder) -> Bool? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      Some(value != 0)
    }
  }
}

/// Read a fixed32 value (wire type 5).
pub fn Decoder::read_fixed32(self : Decoder) -> UInt? {
  let result = read_fixed32(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value)
    }
  }
}

/// Read an sfixed32 value (wire type 5).
pub fn Decoder::read_sfixed32(self : Decoder) -> Int? {
  let result = read_fixed32(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value.to_int())
    }
  }
}

/// Read a float value (wire type 5).
pub fn Decoder::read_float(self : Decoder) -> Float? {
  let result = read_fixed32(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value.reinterpret_as_float())
    }
  }
}

/// Read a fixed64 value (wire type 1).
pub fn Decoder::read_fixed64(self : Decoder) -> UInt64? {
  let result = read_fixed64(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value)
    }
  }
}

/// Read an sfixed64 value (wire type 1).
pub fn Decoder::read_sfixed64(self : Decoder) -> Int64? {
  let result = read_fixed64(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value.to_int64())
    }
  }
}

/// Read a double value (wire type 1).
pub fn Decoder::read_double(self : Decoder) -> Double? {
  let result = read_fixed64(self.bytes, self.pos)
  match result {
    None => None
    Some((value, new_pos)) => {
      self.pos = new_pos
      Some(value.reinterpret_as_double())
    }
  }
}

/// Read a string value (wire type 2).
pub fn Decoder::read_string(self : Decoder) -> String? {
  let len = self.read_length_delim_len()
  match len {
    None => None
    Some(length) => {
      if self.pos + length > self.bytes.length() {
        return None
      }
      let s = @utf8.decode_lossy(self.bytes[self.pos : self.pos + length])
      self.pos += length
      Some(s)
    }
  }
}

/// Read a bytes value (wire type 2).
pub fn Decoder::read_bytes(self : Decoder) -> Bytes? {
  let len = self.read_length_delim_len()
  match len {
    None => None
    Some(length) => {
      if self.pos + length > self.bytes.length() {
        return None
      }
      let b = self.bytes[self.pos : self.pos + length].to_owned()
      self.pos += length
      Some(b)
    }
  }
}

/// Read a nested message (wire type 2). Returns a new Decoder for the nested bytes.
pub fn Decoder::read_message(self : Decoder) -> Decoder? {
  let len = self.read_length_delim_len()
  match len {
    None => None
    Some(length) => {
      if self.pos + length > self.bytes.length() {
        return None
      }
      let nested_bytes = self.bytes[self.pos : self.pos + length].to_owned()
      self.pos += length
      Some(Decoder::new(nested_bytes))
    }
  }
}

/// Skip a field of the given wire type. Returns bytes consumed or None on error.
pub fn Decoder::skip_field(self : Decoder, wire_type : UInt) -> Int? {
  match wire_type {
    WIRE_VARINT => {
      let result = decode_varint(self.bytes, self.pos)
      match result {
        None => None
        Some((_value, consumed)) => {
          self.pos += consumed
          Some(consumed)
        }
      }
    }
    WIRE_FIXED64 => {
      if self.pos < 0 || self.pos + 8 > self.bytes.length() {
        return None
      }
      self.pos += 8
      Some(8)
    }
    WIRE_LENGTH_DELIMITED => {
      let len = self.read_length_delim_len()
      match len {
        None => None
        Some(length) => {
          if self.pos + length > self.bytes.length() {
            return None
          }
          self.pos += length
          Some(length)
        }
      }
    }
    WIRE_FIXED32 => {
      if self.pos < 0 || self.pos + 4 > self.bytes.length() {
        return None
      }
      self.pos += 4
      Some(4)
    }
    _ => None
  }
}

/// Internal: read the length prefix of a length-delimited field.
fn Decoder::read_length_delim_len(self : Decoder) -> Int? {
  let result = decode_varint(self.bytes, self.pos)
  match result {
    None => None
    Some((value, consumed)) => {
      self.pos += consumed
      let length = value.to_int()
      if length < 0 {
        return None
      }
      Some(length)
    }
  }
}
