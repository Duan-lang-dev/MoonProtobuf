test "packed varint encode/decode" {
  let buf = Buffer()
  encode_packed_varint(buf, 1U, [1UL, 2UL, 300UL])
  let bytes = buf.to_bytes()
  // tag (1<<3|2)=0x0A, len=4, varints: 0x01 0x02 0xAC 0x02
  assert_eq(bytes, b"\x0a\x04\x01\x02\xac\x02")

  // Decode
  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        let packed_vals = decode_packed_varint(data)
        assert_eq(packed_vals.length(), 3)
        assert_eq(packed_vals[0], 1UL)
        assert_eq(packed_vals[1], 2UL)
        assert_eq(packed_vals[2], 300UL)
      } else {
        assert_eq(1, 0)
      }
    }
  }
}

test "packed fixed32 encode/decode" {
  let buf = Buffer()
  encode_packed_fixed32(buf, 1U, [100U, 200U, 300U])
  let bytes = buf.to_bytes()

  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        let f32_vals = decode_packed_fixed32(data)
        assert_eq(f32_vals.length(), 3)
        assert_eq(f32_vals[0], 100U)
        assert_eq(f32_vals[1], 200U)
        assert_eq(f32_vals[2], 300U)
      }
    }
  }
}

test "packed fixed64 encode/decode" {
  let buf = Buffer()
  encode_packed_fixed64(buf, 1U, [1000UL, 2000UL])
  let bytes = buf.to_bytes()

  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        let f64_vals = decode_packed_fixed64(data)
        assert_eq(f64_vals.length(), 2)
        assert_eq(f64_vals[0], 1000UL)
        assert_eq(f64_vals[1], 2000UL)
      }
    }
  }
}

test "packed float encode/decode" {
  let buf = Buffer()
  encode_packed_float(buf, 1U, [1.0, 2.5])
  let bytes = buf.to_bytes()

  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        let float_vals = decode_packed_fixed32(data)
        assert_eq(float_vals.length(), 2)
      }
    }
  }
}

test "packed double encode/decode" {
  let buf = Buffer()
  encode_packed_double(buf, 1U, [1.0, 2.5, 3.14])
  let bytes = buf.to_bytes()

  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        let double_vals = decode_packed_fixed64(data)
        assert_eq(double_vals.length(), 3)
      }
    }
  }
}

test "packed empty array" {
  let buf = Buffer()
  encode_packed_varint(buf, 1U, [])
  let bytes = buf.to_bytes()
  // tag + length 0
  assert_eq(bytes, b"\x0a\x00")

  let dec = Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, _wt)) {
    if fnum == 1U {
      if dec.read_bytes() is Some(data) {
        assert_eq(decode_packed_varint(data).length(), 0)
      }
    }
  }
}
