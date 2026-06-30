// Tests for the .proto file parser.

test "parse simple message" {
  let proto = "\n    syntax = \"proto3\";\n    message Person {\n      string name = 1;\n      int32 age = 2;\n      bool active = 3;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((messages, enums)) {
    assert_eq(messages.length(), 1)
    assert_eq(enums.length(), 0)
    let msg = messages[0]
    assert_eq(msg.name, "Person")
    assert_eq(msg.fields.length(), 3)
    assert_eq(msg.fields[0].name, "name")
    assert_eq(msg.fields[0].number, 1U)
    assert_eq(msg.fields[1].name, "age")
    assert_eq(msg.fields[1].number, 2U)
    assert_eq(msg.fields[2].name, "active")
    assert_eq(msg.fields[2].number, 3U)
  } else {
    assert_eq(1, 0)
  }
}

test "parse message with repeated field" {
  let proto = "\n    syntax = \"proto3\";\n    message List {\n      repeated int32 values = 1;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((messages, _)) {
    assert_eq(messages.length(), 1)
    assert_eq(messages[0].fields.length(), 1)
    if messages[0].fields[0].label is FieldLabel::Repeated { () } else { assert_eq(1, 0) }
    assert_eq(messages[0].fields[0].name, "values")
  } else {
    assert_eq(1, 0)
  }
}

test "parse enum" {
  let proto = "\n    syntax = \"proto3\";\n    enum Color {\n      RED = 0;\n      GREEN = 1;\n      BLUE = 2;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((_, enums)) {
    assert_eq(enums.length(), 1)
    assert_eq(enums[0].name, "Color")
    assert_eq(enums[0].values.length(), 3)
    assert_eq(enums[0].values[0].name, "RED")
    assert_eq(enums[0].values[0].number, 0)
    assert_eq(enums[0].values[1].name, "GREEN")
    assert_eq(enums[0].values[1].number, 1)
    assert_eq(enums[0].values[2].name, "BLUE")
    assert_eq(enums[0].values[2].number, 2)
  } else {
    assert_eq(1, 0)
  }
}

test "parse nested message" {
  let proto = "\n    syntax = \"proto3\";\n    message Outer {\n      int32 id = 1;\n      message Inner {\n        string value = 1;\n      }\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((messages, _)) {
    let outer = messages[0]
    assert_eq(outer.name, "Outer")
    assert_eq(outer.fields.length(), 1)
    assert_eq(outer.fields[0].name, "id")
    assert_eq(outer.nested_messages.length(), 1)
    assert_eq(outer.nested_messages[0].name, "Inner")
    assert_eq(outer.nested_messages[0].fields.length(), 1)
    assert_eq(outer.nested_messages[0].fields[0].name, "value")
  } else {
    assert_eq(1, 0)
  }
}

test "parse empty input" {
  let result = parse_proto("")
  if result is Some((messages, enums)) {
    assert_eq(messages.length(), 0)
    assert_eq(enums.length(), 0)
  } else {
    assert_eq(1, 0)
  }
}

test "parse multiple top-level messages" {
  let proto = "\n    syntax = \"proto3\";\n    message A {\n      int32 x = 1;\n    }\n    message B {\n      string y = 1;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((messages, _)) {
    assert_eq(messages.length(), 2)
    assert_eq(messages[0].name, "A")
    assert_eq(messages[1].name, "B")
  } else {
    assert_eq(1, 0)
  }
}

test "parse enum with negative values" {
  let proto = "\n    syntax = \"proto3\";\n    enum Status {\n      UNKNOWN = -1;\n      OK = 0;\n      ERROR = 1;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((_, enums)) {
    assert_eq(enums[0].values[0].number, -1)
    assert_eq(enums[0].values[1].number, 0)
    assert_eq(enums[0].values[2].number, 1)
  } else {
    assert_eq(1, 0)
  }
}

test "parse message type field" {
  let proto = "\n    syntax = \"proto3\";\n    message Container {\n      MyMessage msg = 1;\n    }\n  "
  let result = parse_proto(proto)
  if result is Some((messages, _)) {
    let field = messages[0].fields[0]
    assert_eq(field.name, "msg")
    assert_eq(field.number, 1U)
    // Custom message type should be parsed as FieldType::Message
    if field.field_type is FieldType::Message(type_name) {
      assert_eq(type_name, "MyMessage")
    } else {
      assert_eq(1, 0)
    }
  } else {
    assert_eq(1, 0)
  }
}
