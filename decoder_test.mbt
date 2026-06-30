test "decode int32 field" {
  let bytes = b"\x08\x2a"
  let dec = Decoder::new(bytes)
  let tag = dec.read_tag()
  assert_eq(tag, Some((1U, WIRE_VARINT)))
  let val = dec.read_int32()
  assert_eq(val, Some(42))
}

test "decode string field" {
  let bytes = b"\x0A\x02Hi"
  let dec = Decoder::new(bytes)
  let tag = dec.read_tag()
  assert_eq(tag, Some((1U, WIRE_LENGTH_DELIMITED)))
  let val = dec.read_string()
  assert_eq(val, Some("Hi"))
}

test "decode multiple fields" {
  let bytes = b"\x08\x0a\x12\x05hello"
  let dec = Decoder::new(bytes)

  let tag1 = dec.read_tag()
  assert_eq(tag1, Some((1U, WIRE_VARINT)))
  let val1 = dec.read_int32()
  assert_eq(val1, Some(10))

  let tag2 = dec.read_tag()
  assert_eq(tag2, Some((2U, WIRE_LENGTH_DELIMITED)))
  let val2 = dec.read_string()
  assert_eq(val2, Some("hello"))
}

test "decode bool true" {
  let bytes = b"\x08\x01"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  assert_eq(dec.read_bool(), Some(true))
}

test "decode bool false" {
  let bytes = b"\x08\x00"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  assert_eq(dec.read_bool(), Some(false))
}

test "decode float" {
  let bytes = b"\x0d\x00\x00\x80\x3f"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  let val = dec.read_float()
  if val is Some(f) {
    assert_eq(f > 0.99 && f < 1.01, true)
  } else {
    fail!("expected Some")
  }
}

test "decode double" {
  let bytes = b"\x09\x00\x00\x00\x00\x00\x00\xf0\x3f"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  let val = dec.read_double()
  if val is Some(d) {
    assert_eq(d > 0.99 && d < 1.01, true)
  } else {
    fail!("expected Some")
  }
}

test "decode nested message" {
  let bytes = b"\x12\x02\x08\x64"
  let dec = Decoder::new(bytes)
  let tag = dec.read_tag()
  assert_eq(tag, Some((2U, WIRE_LENGTH_DELIMITED)))
  let inner = dec.read_message()
  if inner is Some(d) {
    let tag2 = d.read_tag()
    assert_eq(tag2, Some((1U, WIRE_VARINT)))
    assert_eq(d.read_int32(), Some(100))
  } else {
    fail!("expected Some")
  }
}

test "decode empty message" {
  let bytes = b""
  let dec = Decoder::new(bytes)
  assert_eq(dec.read_tag(), None)
}

test "decode skip unknown field" {
  let bytes = b"\x08\x2a\x12\x05hello"
  let dec = Decoder::new(bytes)
  let tag = dec.read_tag()
  assert_eq(tag, Some((1U, WIRE_VARINT)))
  dec.skip_field(WIRE_VARINT) |> ignore
  let tag2 = dec.read_tag()
  assert_eq(tag2, Some((2U, WIRE_LENGTH_DELIMITED)))
  assert_eq(dec.read_string(), Some("hello"))
}

test "decode sint32" {
  let enc = Encoder::new()
  let enc = enc.encode_sint32(1U, -5)
  let bytes = enc.to_bytes()
  let dec = Decoder::new(bytes)
  let tag = dec.read_tag()
  assert_eq(tag, Some((1U, WIRE_VARINT)))
  assert_eq(dec.read_sint32(), Some(-5))
}

test "decode uint32" {
  let bytes = b"\x08\xac\x02"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  assert_eq(dec.read_uint32(), Some(300U))
}

test "decode bytes" {
  let bytes = b"\x0A\x03\x41\x42\x43"
  let dec = Decoder::new(bytes)
  dec.read_tag() |> ignore
  assert_eq(dec.read_bytes(), Some(b"ABC"))
}

test "decode roundtrip full message" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 123)
    .encode_string(2U, "test")
    .encode_bool(3U, true)
    .encode_double(4U, 3.14)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_int32 = 0
  let mut got_string = ""
  let mut got_bool = false
  let mut got_double = 0.0

  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      1U => got_int32 = dec.read_int32().unwrap()
      2U => got_string = dec.read_string().unwrap()
      3U => got_bool = dec.read_bool().unwrap()
      4U => if dec.read_double() is Some(d) { got_double = d }
      _ => dec.skip_field(wt) |> ignore
    }
  }

  assert_eq(got_int32, 123)
  assert_eq(got_string, "test")
  assert_eq(got_bool, true)
  assert_eq(got_double > 3.13 && got_double < 3.15, true)
}
