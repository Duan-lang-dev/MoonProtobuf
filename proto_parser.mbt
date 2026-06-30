// Simple .proto file parser for proto3 syntax.
// Supports: message, enum, field definitions, nested types.

/// Represents a protobuf field type.
pub enum FieldType {
  Int32
  Int64
  Uint32
  Uint64
  Sint32
  Sint64
  Fixed32
  Fixed64
  Sfixed32
  Sfixed64
  Float
  Double
  Bool
  String
  Bytes
  Message(String)
  Enum(String)
} derive(Debug, Eq)

/// Represents a field label.
pub enum FieldLabel {
  Optional
  Required
  Repeated
} derive(Debug, Eq)

/// Represents a single field in a message.
pub struct ProtoField {
  name : String
  number : UInt
  field_type : FieldType
  label : FieldLabel
}

/// Represents an enum value.
pub struct ProtoEnumValue {
  name : String
  number : Int
}

/// Represents an enum definition.
pub struct ProtoEnum {
  name : String
  values : Array[ProtoEnumValue]
}

/// Represents a message definition.
pub struct ProtoMessage {
  name : String
  fields : Array[ProtoField]
  nested_messages : Array[ProtoMessage]
  nested_enums : Array[ProtoEnum]
}

/// Parse a .proto file content string into messages and enums.
pub fn parse_proto(content : String) -> (Array[ProtoMessage], Array[ProtoEnum])? {
  let messages : Array[ProtoMessage] = []
  let enums : Array[ProtoEnum] = []
  let lines = split_lines(content)

  let mut i = 0
  while i < lines.length() {
    let line = trim_line(lines[i])
    if line == "" || is_comment(line) || is_top_level_decl(line) {
      i = i + 1
      continue
    }
    if starts_with(line, "message ") {
      let result = parse_message(lines, i)
      match result {
        None => return None
        Some((msg, next_i)) => {
          messages.push(msg)
          i = next_i
        }
      }
    } else if starts_with(line, "enum ") {
      let result = parse_enum(lines, i)
      match result {
        None => return None
        Some((e, next_i)) => {
          enums.push(e)
          i = next_i
        }
      }
    } else {
      i = i + 1
    }
  }

  Some((messages, enums))
}

// --- String helpers ---

fn starts_with(s : String, prefix : String) -> Bool {
  if s.length() < prefix.length() {
    return false
  }
  s[:prefix.length()] == prefix
}

fn ends_with(s : String, suffix : String) -> Bool {
  if s.length() < suffix.length() {
    return false
  }
  s[s.length() - suffix.length():] == suffix
}

fn find_str(s : String, substr : String) -> Int {
  if substr.length() == 0 {
    return 0
  }
  if s.length() < substr.length() {
    return -1
  }
  let end = s.length() - substr.length() + 1
  for i in 0..<end {
    if s[i:i + substr.length()] == substr {
      return i
    }
  }
  -1
}

fn is_comment(line : String) -> Bool {
  let t = trim_left(line)
  starts_with(t, "//") || starts_with(t, "/*")
}

fn is_top_level_decl(line : String) -> Bool {
  let t = trim_left(line)
  starts_with(t, "syntax ") || starts_with(t, "package ") ||
  starts_with(t, "import ") || starts_with(t, "option ")
}

fn trim_line(line : String) -> String {
  let mut s = line
  let comment_pos = find_str(s, "//")
  if comment_pos >= 0 {
    s = s[:comment_pos].to_owned()
  }
  trim(s)
}

fn trim(s : String) -> String {
  trim_right(trim_left(s))
}

fn trim_left(s : String) -> String {
  let mut start = 0
  while start < s.length() && is_whitespace_char(s, start) {
    start = start + 1
  }
  if start >= s.length() {
    return ""
  }
  s[start:].to_owned()
}

fn trim_right(s : String) -> String {
  let mut end = s.length()
  while end > 0 && is_whitespace_char(s, end - 1) {
    end = end - 1
  }
  if end <= 0 {
    return ""
  }
  s[:end].to_owned()
}

fn is_whitespace_char(s : String, idx : Int) -> Bool {
  let c = s[idx]
  c == ' ' || c == '\t' || c == '\r' || c == '\n'
}

fn split_lines(content : String) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  for i in 0..<content.length() {
    if content[i] == '\n' {
      result.push(content[start:i].to_owned())
      start = i + 1
    }
  }
  if start < content.length() {
    result.push(content[start:].to_owned())
  }
  result
}

// --- Parser functions ---

fn parse_message(lines : Array[String], start : Int) -> (ProtoMessage, Int)? {
  let header = trim_line(lines[start])
  if !starts_with(header, "message ") {
    return None
  }
  // "message " is 8 chars
  let rest = header[8:].to_owned()
  let mut msg_name = trim(rest)
  if ends_with(msg_name, "{") {
    msg_name = trim(msg_name[:msg_name.length() - 1].to_owned())
  }

  let mut i = start
  if !ends_with(header, "{") {
    i = i + 1
    while i < lines.length() && trim_line(lines[i]) != "{" {
      i = i + 1
    }
    if i >= lines.length() {
      return None
    }
  }

  i = i + 1 // skip opening brace
  let fields : Array[ProtoField] = []
  let nested_msgs : Array[ProtoMessage] = []
  let nested_enums : Array[ProtoEnum] = []

  while i < lines.length() {
    let line = trim_line(lines[i])
    if line == "" || is_comment(line) {
      i = i + 1
      continue
    }
    if line == "}" {
      i = i + 1
      break
    }
    if starts_with(line, "message ") {
      let result = parse_message(lines, i)
      match result {
        None => return None
        Some((nested, next_i)) => {
          nested_msgs.push(nested)
          i = next_i
        }
      }
    } else if starts_with(line, "enum ") {
      let result = parse_enum(lines, i)
      match result {
        None => return None
        Some((e, next_i)) => {
          nested_enums.push(e)
          i = next_i
        }
      }
    } else if find_str(line, "=") >= 0 {
      let field = parse_field(line)
      match field {
        None => { i = i + 1 }
        Some(f) => {
          fields.push(f)
          i = i + 1
        }
      }
    } else {
      i = i + 1
    }
  }

  Some(({ name: msg_name, fields, nested_messages: nested_msgs, nested_enums }, i))
}

fn parse_enum(lines : Array[String], start : Int) -> (ProtoEnum, Int)? {
  let header = trim_line(lines[start])
  // "enum " is 5 chars
  let rest = header[5:].to_owned()
  let mut enum_name = trim(rest)
  if ends_with(enum_name, "{") {
    enum_name = trim(enum_name[:enum_name.length() - 1].to_owned())
  }

  let mut i = start
  if !ends_with(header, "{") {
    i = i + 1
    while i < lines.length() && trim_line(lines[i]) != "{" {
      i = i + 1
    }
    if i >= lines.length() {
      return None
    }
  }

  i = i + 1
  let values : Array[ProtoEnumValue] = []

  while i < lines.length() {
    let line = trim_line(lines[i])
    if line == "" || is_comment(line) {
      i = i + 1
      continue
    }
    if line == "}" {
      i = i + 1
      break
    }
    // Parse: NAME = NUMBER;
    let eq_pos = find_str(line, "=")
    if eq_pos >= 0 {
      let val_name = trim(line[:eq_pos].to_owned())
      let after_eq = trim(line[eq_pos + 1:].to_owned())
      // Remove trailing semicolon
      let mut num_str = after_eq
      if ends_with(num_str, ";") {
        num_str = num_str[:num_str.length() - 1].to_owned()
      }
      num_str = trim(num_str)
      let val_num = parse_int(num_str)
      match val_num {
        None => { i = i + 1 }
        Some(n) => {
          values.push({ name: val_name, number: n })
          i = i + 1
        }
      }
    } else {
      i = i + 1
    }
  }

  Some(({ name: enum_name, values }, i))
}

fn parse_field(line : String) -> ProtoField? {
  // Extract words from the line
  let words = split_words(line)
  let mut idx = 0

  if words.length() < 3 {
    return None
  }

  // Determine label
  let mut label = FieldLabel::Optional
  let first = words[0]
  if first == "repeated" {
    label = FieldLabel::Repeated
    idx = 1
  } else if first == "required" {
    label = FieldLabel::Required
    idx = 1
  } else if first == "optional" {
    idx = 1
  }

  // After label, we need: type, name, =, number
  if idx + 3 >= words.length() {
    return None
  }

  let type_str = words[idx]
  let name = words[idx + 1]
  // words[idx + 2] should be "="
  if words[idx + 2] != "=" {
    return None
  }
  let num_str = words[idx + 3]

  let number = parse_uint(num_str)
  match number {
    None => None
    Some(n) => {
      let ftype = parse_field_type(type_str)
      match ftype {
        None => None
        Some(ft) => Some({ name, number: n, field_type: ft, label })
      }
    }
  }
}

fn split_words(line : String) -> Array[String] {
  let words : Array[String] = []
  let mut start = -1
  for i in 0..<line.length() {
    let c = line[i]
    if c == ' ' || c == '\t' || c == ';' || c == '=' {
      if start >= 0 {
        words.push(line[start:i].to_owned())
        start = -1
      }
      if c == '=' {
        words.push("=")
      }
    } else if start < 0 {
      start = i
    }
  }
  if start >= 0 {
    words.push(line[start:].to_owned())
  }
  words
}

fn parse_field_type(s : String) -> FieldType? {
  match s {
    "int32" => Some(FieldType::Int32)
    "int64" => Some(FieldType::Int64)
    "uint32" => Some(FieldType::Uint32)
    "uint64" => Some(FieldType::Uint64)
    "sint32" => Some(FieldType::Sint32)
    "sint64" => Some(FieldType::Sint64)
    "fixed32" => Some(FieldType::Fixed32)
    "fixed64" => Some(FieldType::Fixed64)
    "sfixed32" => Some(FieldType::Sfixed32)
    "sfixed64" => Some(FieldType::Sfixed64)
    "float" => Some(FieldType::Float)
    "double" => Some(FieldType::Double)
    "bool" => Some(FieldType::Bool)
    "string" => Some(FieldType::String)
    "bytes" => Some(FieldType::Bytes)
    _ => Some(FieldType::Message(s))
  }
}

fn parse_int(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let mut result = 0
  let mut neg = false
  let mut start = 0
  if s[0] == '-' {
    neg = true
    start = 1
  }
  for i in start..<s.length() {
    let ch = s[i]
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - 48)
    } else {
      break
    }
  }
  Some(if neg { -result } else { result })
}

fn parse_uint(s : String) -> UInt? {
  if s.length() == 0 {
    return None
  }
  let mut result : UInt = 0
  for i in 0..<s.length() {
    let ch = s[i]
    if ch >= '0' && ch <= '9' {
      result = result * 10 + (ch.to_int() - 48).reinterpret_as_uint()
    } else {
      break
    }
  }
  Some(result)
}
