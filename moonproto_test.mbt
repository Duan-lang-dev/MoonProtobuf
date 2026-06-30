// Integration tests: encode → decode roundtrips.

struct Person {
  name : String
  age : Int
  active : Bool
}

fn encode_person(p : Person) -> Bytes {
  let enc = Encoder::new()
  let enc = enc.encode_string(1U, p.name)
    .encode_int32(2U, p.age)
    .encode_bool(3U, p.active)
  enc.to_bytes()
}

fn decode_person(bytes : Bytes) -> Person? {
  let dec = Decoder::new(bytes)
  let mut name = ""
  let mut age = 0
  let mut active = false

  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      1U => if dec.read_string() is Some(s) { name = s }
      2U => if dec.read_int32() is Some(i) { age = i }
      3U => if dec.read_bool() is Some(b) { active = b }
      _ => dec.skip_field(wt) |> ignore
    }
  }

  Some({ name, age, active })
}

test "roundtrip person message" {
  let p = { name: "Alice", age: 30, active: true }
  let bytes = encode_person(p)
  assert_eq(bytes, b"\x0a\x05Alice\x10\x1e\x18\x01")

  let decoded = decode_person(bytes)
  if decoded is Some(d) {
    assert_eq(d.name, "Alice")
    assert_eq(d.age, 30)
    assert_eq(d.active, true)
  } else {
    assert_eq(1, 0) // force fail
  }
}

test "roundtrip person with UTF-8 name" {
  let p = { name: "你好", age: 25, active: false }
  let bytes = encode_person(p)
  let decoded = decode_person(bytes)
  if decoded is Some(d) {
    assert_eq(d.name, "你好")
    assert_eq(d.age, 25)
    assert_eq(d.active, false)
  } else {
    assert_eq(1, 0)
  }
}

test "roundtrip large integers" {
  let enc = Encoder::new()
  let enc = enc.encode_uint64(1U, 18446744073709551615UL)
    .encode_int64(2U, -9223372036854775808L)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_uint = 0UL
  let mut got_int = 0L

  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      1U => if dec.read_uint64() is Some(v) { got_uint = v }
      2U => if dec.read_int64() is Some(v) { got_int = v }
      _ => dec.skip_field(wt) |> ignore
    }
  }

  assert_eq(got_uint, 18446744073709551615UL)
  assert_eq(got_int, -9223372036854775808L)
}

test "roundtrip fixed types" {
  let enc = Encoder::new()
  let enc = enc.encode_fixed32(1U, 4000000000U).encode_fixed64(2U, 18000000000000000000UL)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_f32 : UInt = 0
  let mut got_f64 : UInt64 = 0

  while dec.read_tag() is Some((fnum, _wt)) {
    match fnum {
      1U => if dec.read_fixed32() is Some(v) { got_f32 = v }
      2U => if dec.read_fixed64() is Some(v) { got_f64 = v }
      _ => ()
    }
  }

  assert_eq(got_f32, 4000000000U)
  assert_eq(got_f64, 18000000000000000000UL)
}

test "roundtrip nested messages" {
  let inner = Encoder::new()
  let inner = inner.encode_string(1U, "hello")

  let outer = Encoder::new()
  let outer = outer.encode_int32(1U, 1)
  let outer = outer.encode_message(2U, inner)

  let bytes = outer.to_bytes()

  let dec = Decoder::new(bytes)
  let mut id = 0
  let mut inner_value = ""

  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      1U => if dec.read_int32() is Some(v) { id = v }
      2U => if dec.read_message() is Some(inner_dec) {
        while inner_dec.read_tag() is Some((ifnum, _)) {
          match ifnum {
            1U => if inner_dec.read_string() is Some(s) { inner_value = s }
            _ => inner_dec.skip_field(WIRE_LENGTH_DELIMITED) |> ignore
          }
        }
      }
      _ => dec.skip_field(wt) |> ignore
    }
  }

  assert_eq(id, 1)
  assert_eq(inner_value, "hello")
}

test "skip unknown fields across wire types" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 42)
  let enc = enc.encode_double(2U, 2.5)
  let enc = enc.encode_string(3U, "skip")
  let enc = enc.encode_float(4U, 1.5)
  let enc = enc.encode_int32(5U, 99)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut target = 0

  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      5U => if dec.read_int32() is Some(v) { target = v }
      _ => dec.skip_field(wt) |> ignore
    }
  }

  assert_eq(target, 99)
}


// --- Conformance-style tests ---

test "all varint wire types roundtrip" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 42)
    .encode_int64(2U, 123456789L)
    .encode_uint32(3U, 999U)
    .encode_uint64(4U, 123456789UL)
    .encode_sint32(5U, -100)
    .encode_sint64(6U, -99999L)
    .encode_bool(7U, true)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_int32 = 0
  let mut got_int64 = 0L
  let mut got_uint32 : UInt = 0
  let mut got_uint64 = 0UL
  let mut got_sint32 = 0
  let mut got_sint64 = 0L
  let mut got_bool = false

  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_int32() is Some(v) { got_int32 = v }
      2U => if dec.read_int64() is Some(v) { got_int64 = v }
      3U => if dec.read_uint32() is Some(v) { got_uint32 = v }
      4U => if dec.read_uint64() is Some(v) { got_uint64 = v }
      5U => if dec.read_sint32() is Some(v) { got_sint32 = v }
      6U => if dec.read_sint64() is Some(v) { got_sint64 = v }
      7U => if dec.read_bool() is Some(v) { got_bool = v }
      _ => ()
    }
  }

  assert_eq(got_int32, 42)
  assert_eq(got_int64, 123456789L)
  assert_eq(got_uint32, 999U)
  assert_eq(got_uint64, 123456789UL)
  assert_eq(got_sint32, -100)
  assert_eq(got_sint64, -99999L)
  assert_eq(got_bool, true)
}

test "all fixed types roundtrip" {
  let enc = Encoder::new()
  let enc = enc.encode_fixed32(1U, 0xDEADBEEF)
    .encode_fixed64(2U, 0xFEEDFACECAFEBEEFUL)
    .encode_sfixed32(3U, -1)
    .encode_sfixed64(4U, -1L)
    .encode_float(5U, 3.14159)
    .encode_double(6U, 2.718281828)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_fixed32 : UInt = 0
  let mut got_fixed64 = 0UL
  let mut got_sfixed32 = 0
  let mut got_sfixed64 = 0L
  let mut got_float : Float = 0.0
  let mut got_double : Double = 0.0

  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_fixed32() is Some(v) { got_fixed32 = v }
      2U => if dec.read_fixed64() is Some(v) { got_fixed64 = v }
      3U => if dec.read_sfixed32() is Some(v) { got_sfixed32 = v }
      4U => if dec.read_sfixed64() is Some(v) { got_sfixed64 = v }
      5U => if dec.read_float() is Some(v) { got_float = v }
      6U => if dec.read_double() is Some(v) { got_double = v }
      _ => ()
    }
  }

  assert_eq(got_fixed32, 0xDEADBEEF)
  assert_eq(got_fixed64, 0xFEEDFACECAFEBEEFUL)
  assert_eq(got_sfixed32, -1)
  assert_eq(got_sfixed64, -1L)
}

test "zero values roundtrip" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 0)
    .encode_bool(2U, false)
    .encode_string(3U, "")
    .encode_bytes(4U, b"")
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_int = 1
  let mut got_bool = true
  let mut got_string = "x"
  let mut got_bytes = b"ÿ"

  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_int32() is Some(v) { got_int = v }
      2U => if dec.read_bool() is Some(v) { got_bool = v }
      3U => if dec.read_string() is Some(v) { got_string = v }
      4U => if dec.read_bytes() is Some(v) { got_bytes = v }
      _ => ()
    }
  }

  assert_eq(got_int, 0)
  assert_eq(got_bool, false)
  assert_eq(got_string, "")
  assert_eq(got_bytes, b"")
}

test "max values roundtrip" {
  let enc = Encoder::new()
  let enc = enc.encode_uint32(1U, 4294967295U)
    .encode_uint64(2U, 18446744073709551615UL)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_u32 : UInt = 0
  let mut got_u64 = 0UL
  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_uint32() is Some(v) { got_u32 = v }
      2U => if dec.read_uint64() is Some(v) { got_u64 = v }
      _ => ()
    }
  }
  assert_eq(got_u32, 4294967295U)
  assert_eq(got_u64, 18446744073709551615UL)
}

test "field order independence" {
  // Encode fields in one order, verify decode handles any order
  let enc = Encoder::new()
  let enc = enc.encode_string(3U, "hello")
    .encode_int32(1U, 42)
    .encode_bool(2U, true)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut got_int32 = 0
  let mut got_bool = false
  let mut got_string = ""

  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_int32() is Some(v) { got_int32 = v }
      2U => if dec.read_bool() is Some(v) { got_bool = v }
      3U => if dec.read_string() is Some(v) { got_string = v }
      _ => ()
    }
  }

  assert_eq(got_int32, 42)
  assert_eq(got_bool, true)
  assert_eq(got_string, "hello")
}

test "three level nested messages" {
  // Level1 { a: 1, level2: { b: "hi", level3: { c: true } } }
  let level3 = Encoder::new()
  let level3 = level3.encode_bool(1U, true)

  let level2 = Encoder::new()
  let level2 = level2.encode_string(1U, "hi")
  let level2 = level2.encode_message(2U, level3)

  let level1 = Encoder::new()
  let level1 = level1.encode_int32(1U, 1)
  let level1 = level1.encode_message(2U, level2)

  let bytes = level1.to_bytes()

  let dec = Decoder::new(bytes)
  let mut a = 0
  let mut b = ""
  let mut c = false

  while dec.read_tag() is Some((fnum, _)) {
    match fnum {
      1U => if dec.read_int32() is Some(v) { a = v }
      2U => if dec.read_message() is Some(l2) {
        while l2.read_tag() is Some((fnum2, _)) {
          match fnum2 {
            1U => if l2.read_string() is Some(v) { b = v }
            2U => if l2.read_message() is Some(l3) {
              while l3.read_tag() is Some((fnum3, _)) {
                match fnum3 {
                  1U => if l3.read_bool() is Some(v) { c = v }
                  _ => ()
                }
              }
            }
            _ => ()
          }
        }
      }
      _ => ()
    }
  }

  assert_eq(a, 1)
  assert_eq(b, "hi")
  assert_eq(c, true)
}

test "lots of fields (20 fields)" {
  let enc = Encoder::new()
  let mut enc = enc
  for i in 1..=20 {
    enc = enc.encode_int32(i.reinterpret_as_uint(), i)
  }
  let bytes = enc.to_bytes()
  let dec = Decoder::new(bytes)
  let mut count = 0
  while dec.read_tag() is Some((fnum, _)) {
    if dec.read_int32() is Some(v) {
      count += 1
    }
  }
  assert_eq(count, 20)
}

test "skip mixed wire types" {
  let enc = Encoder::new()
  let enc = enc.encode_int32(1U, 1)
    .encode_double(2U, 1.0)
    .encode_string(3U, "skip me")
    .encode_float(4U, 2.0)
    .encode_int32(5U, 99999)
    .encode_fixed64(6U, 555UL)
    .encode_bytes(7U, b"more skip")
    .encode_int32(8U, 42)
  let bytes = enc.to_bytes()

  let dec = Decoder::new(bytes)
  let mut target = 0
  while dec.read_tag() is Some((fnum, wt)) {
    if fnum == 8U {
      if dec.read_int32() is Some(v) { target = v }
    } else {
      dec.skip_field(wt) |> ignore
    }
  }
  assert_eq(target, 42)
}
