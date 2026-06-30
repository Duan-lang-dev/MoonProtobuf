/// MoonProto CLI — encode/decode demo.

fn main {
  println("MoonProto — Protobuf Wire Format Demo")
  println("=======================================")
  println("")

  println("Encoding Person { name: \"Alice\", age: 30, active: true }")
  let enc = @moonproto.Encoder::new()
  let enc = enc.encode_string(1U, "Alice")
    .encode_int32(2U, 30)
    .encode_bool(3U, true)
  let bytes = enc.to_bytes()
  println("Encoded (hex): \{to_hex(bytes)}")
  println("Encoded length: \{bytes.length()} bytes")
  println("")

  println("Decoding...")
  let dec = @moonproto.Decoder::new(bytes)
  while dec.read_tag() is Some((fnum, wt)) {
    match fnum {
      1U => {
        if dec.read_string() is Some(val) {
          println("  Field 1 (string): \"\{val}\"")
        }
      }
      2U => {
        if dec.read_int32() is Some(val) {
          println("  Field 2 (int32): \{val}")
        }
      }
      3U => {
        if dec.read_bool() is Some(val) {
          println("  Field 3 (bool): \{val}")
        }
      }
      _ => dec.skip_field(wt) |> ignore
    }
  }
  println("")
  println("Done!")
}

fn to_hex(bytes : Bytes) -> String {
  let mut s = ""
  for i in 0..<bytes.length() {
    s = s + "\\x" + hex_byte(bytes[i])
  }
  s
}

fn hex_byte(byte : Byte) -> String {
  hex_nibble((byte.to_int() >> 4) & 0x0F) + hex_nibble(byte.to_int() & 0x0F)
}

fn hex_nibble(v : Int) -> String {
  if v < 10 {
    Int::unsafe_to_char(v + 48).to_string()
  } else {
    Int::unsafe_to_char(v + 87).to_string()
  }
}
