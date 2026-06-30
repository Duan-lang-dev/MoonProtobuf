# MoonProto 项目申报书

## 基本信息

| 项目 | 内容 |
|------|------|
| **项目名称** | MoonProto：Protocol Buffers 运行时编码解码库 |
| **GitHub 仓库** | https://github.com/Duan-lang-dev/MoonProtobuf |
| **GitLink 仓库** | https://gitlink.org.cn/Duan525/moonproto |
| **项目方向** | MoonBit 基础库 / 序列化协议基础设施 |
| **是否为移植项目** | 否（原创实现，基于 Protobuf wire format 公开规范，参考 Go protowire、Rust prost 实现模式） |
| **许可证** | MIT |

## 项目简介

MoonProto 是一个**纯 MoonBit 实现**的 Protocol Buffers 运行时编码解码库，支持完整的 protobuf wire format。项目面向需要在 MoonBit 生态中进行高效二进制序列化的开发者，提供 varint/zigzag 编解码、四种 wire type（Varint/Fixed64/Length-delimited/Fixed32）的读写、Builder 模式高级 Encoder、位置追踪高级 Decoder、packed repeated 字段以及简单的 .proto 文件解析器。

MoonBit 生态中尚无可用的 protobuf 运行时库。Protobuf 作为 Google 内部及业界广泛使用的序列化协议，其 wire format 的高效性（varint 压缩、tag-value 可扩展性）使其成为微服务通信和数据持久化的首选方案。本项目填补这一生态空白。

## 核心功能范围

### 低级编码层

- **Varint 编解码**：ULEB128 变长整数编码（encode_varint / decode_varint），完整支持 0 到 2^64-1 范围
- **Zigzag 编解码**：有符号整数映射（encode_zigzag32/64, decode_zigzag32/64），使小绝对值负数仅占用 1 字节
- **Tag 编解码**：tag = (field_number << 3) | wire_type，支持 make_tag / split_tag
- **Wire Type 读写**：四种 wire type 的编码和边界检查解码

### 高级编码层

- **Encoder（Builder 模式）**：20 个方法覆盖全部标量类型（int32/64, uint32/64, sint32/64, fixed32/64, sfixed32/64, float, double, bool, string, bytes）、嵌套消息、方法链式调用
- **Decoder（位置追踪）**：19 个方法逐字段读取，read_tag 驱动循环、skip_field 跳过未知字段、read_message 嵌套解码
- **Packed Repeated**：5 个编码函数 + 3 个解码函数，支持高效数组序列化

### Proto 文件解析器（460 行）

- 支持 proto3 语法：message / enum / 字段定义
- 解析标签类型（optional / required / repeated）
- 解析全部标量类型及自定义 Message/Enum 引用
- 支持嵌套 message 和嵌套 enum

### 工程质量

- 80 个单元测试全部通过
- GitHub Actions CI 持续集成（check + test + build）
- 完整 README、15 次有效提交

## 差异化价值

| 对比维度 | 无现有竞品 | MoonProto |
|---------|-----------|-----------|
| Wire format 实现 | MoonBit 生态空白 | **完整实现全部 wire types** |
| 编码 API | — | **Builder 模式，方法链式调用** |
| 解码 API | — | **位置追踪，按字段号分发** |
| Packed repeated | — | **完整支持** |
| Proto 文件解析 | — | **支持 message/enum/嵌套类型** |
| 平台支持 | — | **纯 MoonBit，Native/Wasm/JS 通用** |
| 外部依赖 | — | **仅依赖 core/encoding/utf8** |

MoonProto 在 MoonBit 生态中无直接竞品，填补了 protobuf 序列化基础设施的空白。

## 项目规模

| 模块 | 源码行 | 测试行 | 测试数 |
|------|--------|--------|--------|
| varint | 87 | 111 | 16 |
| wire | 79 | 76 | 11 |
| encoder | 132 | 83 | 11 |
| decoder | 288 | 156 | 14 |
| packed | 95 | 109 | 6 |
| proto_parser | 460 | 121 | 8 |
| moonproto (入口+trait) | 13 | 406 | 8 |
| CLI / 其他 | 62 | — | — |
| 文档（README/CI/Config） | — | — | — |
| **合计** | **1,216** | **1,062** | **80** |

项目总计约 **2,279 行**（源码 1,216 行 + 测试 1,062 行），80 个测试全部通过，15 次有效提交。

## 实现计划

1. **已完成**：varint/zigzag 编解码、wire type 读写、tag 编解码
2. **已完成**：高级 Encoder API（20 个方法）、高级 Decoder API（19 个方法 + skip_field）
3. **已完成**：packed repeated 字段支持（5 编码 + 3 解码）
4. **已完成**：.proto 文件解析器、Message trait、集成测试
5. **已完成**：CLI Demo、CI 配置、完整文档

## 适用场景

- **微服务通信**：高效二进制序列化，适合 MoonBit 服务间 RPC
- **数据持久化**：紧凑的二进制存储格式
- **配置文件序列化**：强类型、向前兼容的配置存储
- **嵌入式/IoT 场景**：低带宽场景下的高效编码
- **MoonBit 生态基础设施**：为标准库补充序列化协议支持
- **跨语言数据交换**：与 Go/Rust/Java/Python 等语言的 protobuf 实现互操作
