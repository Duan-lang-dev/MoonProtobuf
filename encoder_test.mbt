test "encode int32 field" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 42)
  let bytes = enc.to_bytes()
  assert_eq(bytes, b"\x08\x2a")
}

test "encode string field" {
  let enc = Encoder::new()
  let enc = enc.encode_string(1U, "Hi")
  let bytes = enc.to_bytes()
  // tag 0x0A, len 2, "Hi"
  assert_eq(bytes, b"\x0A\x02Hi")
}

test "encode nested message" {
  let inner = Encoder::new()
  let inner = inner.encode_int32(1U, 100)
  let outer = Encoder::new()
  let outer = outer.encode_message(2U, inner)
  let bytes = outer.to_bytes()
  // tag (2<<3|2)=0x12, len=2, inner: tag 0x08, varint 100=0x64
  assert_eq(bytes, b"\x12\x02\x08\x64")
}

test "encode bool true" {
  let enc = Encoder::new()
  let enc = enc.encode_bool(1U, true)
  let bytes = enc.to_bytes()
  assert_eq(bytes, b"\x08\x01")
}

test "encode float" {
  let enc = Encoder::new()
  let enc = enc.encode_float(1U, 1.0)
  let bytes = enc.to_bytes()
  // tag (1<<3|5)=0x0D, float 1.0 = 0x3F800000 in IEEE754 LE
  assert_eq(bytes, b"\x0d\x00\x00\x80\x3f")
}

test "encode double" {
  let enc = Encoder::new()
  let enc = enc.encode_double(1U, 1.0)
  let bytes = enc.to_bytes()
  // tag (1<<3|1)=0x09, double 1.0 = 0x3FF0000000000000 in IEEE754 LE
  assert_eq(bytes, b"\x09\x00\x00\x00\x00\x00\x00\xf0\x3f")
}

test "encode negative int32" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, -1)
  let bytes = enc.to_bytes()
  // tag 0x08, varint -1 as uint64 = 10 bytes of 0xFF + 0x01
  assert_eq(bytes, b"\x08\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01")
}

test "encode sint32 (zigzag)" {
  let enc = Encoder::new()
  let enc = enc.encode_sint32(1U, -1)
  let bytes = enc.to_bytes()
  // tag 0x08, zigzag(-1)=1, varint 1=0x01
  assert_eq(bytes, b"\x08\x01")
}

test "encode uint32" {
  let enc = Encoder::new()
  let enc = enc.encode_uint32(1U, 300U)
  let bytes = enc.to_bytes()
  assert_eq(bytes, b"\x08\xac\x02")
}

test "encoder builder pattern chaining" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 10).encode_string(2U, "hello")
  let bytes = enc.to_bytes()
  assert_eq(bytes, b"\x08\x0a\x12\x05hello")
}

test "encoder empty message" {
  let enc = Encoder::new()
  let bytes = enc.to_bytes()
  assert_eq(bytes, b"")
}
