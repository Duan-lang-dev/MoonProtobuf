test "encode_varint zero" {
  let buf = Buffer()
  @moonproto.encode_varint(buf, 0UL)
  let result = buf.to_bytes()
  assert_eq(result, b"\x00")
}

test "encode_varint one" {
  let buf = Buffer()
  @moonproto.encode_varint(buf, 1UL)
  let result = buf.to_bytes()
  assert_eq(result, b"\x01")
}

test "encode_varint 300" {
  let buf = Buffer()
  @moonproto.encode_varint(buf, 300UL)
  let result = buf.to_bytes()
  assert_eq(result, b"\xac\x02")
}

test "decode_varint zero" {
  let bytes = b"\x00"
  let r = @moonproto.decode_varint(bytes, 0)
  assert_eq(r, Some((0UL, 1)))
}

test "decode_varint 300" {
  let bytes = b"\xac\x02"
  let r = @moonproto.decode_varint(bytes, 0)
  assert_eq(r, Some((300UL, 2)))
}

test "decode_varint at offset" {
  let bytes = b"\xff\xac\x02"
  let r = @moonproto.decode_varint(bytes, 1)
  assert_eq(r, Some((300UL, 2)))
}

test "decode_varint truncated" {
  let bytes = b"\x80"
  let r = @moonproto.decode_varint(bytes, 0)
  assert_eq(r, None)
}

test "decode_varint max uint64" {
  let bytes = b"\xff\xff\xff\xff\xff\xff\xff\xff\xff\x01"
  let r = @moonproto.decode_varint(bytes, 0)
  assert_eq(r, Some((18446744073709551615UL, 10)))
}

test "zigzag32 zero" {
  assert_eq(@moonproto.encode_zigzag32(0), 0U)
  assert_eq(@moonproto.decode_zigzag32(0U), 0)
}

test "zigzag32 signed" {
  assert_eq(@moonproto.encode_zigzag32(-1), 1U)
  assert_eq(@moonproto.decode_zigzag32(1U), -1)
  assert_eq(@moonproto.encode_zigzag32(1), 2U)
  assert_eq(@moonproto.decode_zigzag32(2U), 1)
}

test "zigzag64 signed" {
  assert_eq(@moonproto.encode_zigzag64(-1L), 1UL)
  assert_eq(@moonproto.decode_zigzag64(1UL), -1L)
  assert_eq(@moonproto.encode_zigzag64(1L), 2UL)
  assert_eq(@moonproto.decode_zigzag64(2UL), 1L)
}

test "encode_varint then decode_varint roundtrip" {
  for value in [0UL, 1UL, 127UL, 128UL, 300UL, 65535UL, 4294967295UL, 18446744073709551615UL] {
    let buf = Buffer()
    @moonproto.encode_varint(buf, value)
    let bytes = buf.to_bytes()
    let r = @moonproto.decode_varint(bytes, 0)
    assert_eq(r, Some((value, bytes.length())))
  }
}
