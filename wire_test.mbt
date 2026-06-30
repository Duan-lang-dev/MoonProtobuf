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
