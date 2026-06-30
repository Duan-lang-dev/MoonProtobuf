test "make_tag and split_tag" {
  let tag = make_tag(1U, WIRE_VARINT)
  assert_eq(tag, 8U) // (1 << 3) | 0 = 8
  let (field_num, wire_type) = split_tag(tag)
  assert_eq(field_num, 1U)
  assert_eq(wire_type, WIRE_VARINT)
}

test "make_tag field 2 length-delimited" {
  let tag = make_tag(2U, WIRE_LENGTH_DELIMITED)
  assert_eq(tag, 18U) // (2 << 3) | 2 = 18
  let (field_num, wire_type) = split_tag(tag)
  assert_eq(field_num, 2U)
  assert_eq(wire_type, WIRE_LENGTH_DELIMITED)
}

test "make_tag field 3 fixed64" {
  let tag = make_tag(3U, WIRE_FIXED64)
  assert_eq(tag, 25U) // (3 << 3) | 1 = 25
}

test "make_tag field 4 fixed32" {
  let tag = make_tag(4U, WIRE_FIXED32)
  assert_eq(tag, 37U) // (4 << 3) | 5 = 37
}

test "wire_type constant values" {
  assert_eq(WIRE_VARINT, 0U)
  assert_eq(WIRE_FIXED64, 1U)
  assert_eq(WIRE_LENGTH_DELIMITED, 2U)
  assert_eq(WIRE_FIXED32, 5U)
}

test "write_fixed32 / read_fixed32 roundtrip" {
  let buf = Buffer()
  write_fixed32(buf, 0x12345678U)
  let bytes = buf.to_bytes()
  let result = read_fixed32(bytes, 0)
  assert_eq(result, Some((0x12345678U, 4)))
}

test "write_fixed64 / read_fixed64 roundtrip" {
  let buf = Buffer()
  write_fixed64(buf, 0x123456789ABCDEF0UL)
  let bytes = buf.to_bytes()
  let result = read_fixed64(bytes, 0)
  assert_eq(result, Some((0x123456789ABCDEF0UL, 8)))
}

test "write_float / read_fixed32 roundtrip" {
  let buf = Buffer()
  write_float(buf, 1.5)
  let bytes = buf.to_bytes()
  let result = read_fixed32(bytes, 0)
  // Float 1.5 as uint32: sign=0, exp=127, mantissa=0.5 -> 0x3FC00000
  assert_eq(result, Some((0x3FC00000U, 4)))
}

test "write_double / read_fixed64 roundtrip" {
  let buf = Buffer()
  write_double(buf, 1.5)
  let bytes = buf.to_bytes()
  let result = read_fixed64(bytes, 0)
  // Double 1.5 as uint64: 0x3FF8000000000000
  assert_eq(result, Some((0x3FF8000000000000UL, 8)))
}

test "read_fixed32 negative pos returns None" {
  let bytes = Bytes::make(4, 0U.to_byte())
  assert_eq(read_fixed32(bytes, -1), None)
}

test "read_fixed64 negative pos returns None" {
  let bytes = Bytes::make(8, 0U.to_byte())
  assert_eq(read_fixed64(bytes, -1), None)
}
