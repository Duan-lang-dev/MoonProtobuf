// MoonProto: Protocol Buffers wire format encoding/decoding for MoonBit.
// Reference: https://protobuf.dev/programming-guides/encoding/

/// Wire type constants for protobuf encoding.
pub const WIRE_VARINT : UInt = 0
pub const WIRE_FIXED64 : UInt = 1
pub const WIRE_LENGTH_DELIMITED : UInt = 2
pub const WIRE_FIXED32 : UInt = 5

/// Types implementing `Message` can encode themselves as protobuf messages.
pub trait Message {
  encode(Self, Encoder) -> Unit
}
