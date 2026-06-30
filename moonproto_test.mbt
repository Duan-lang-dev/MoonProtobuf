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
