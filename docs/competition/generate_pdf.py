"""Generate MoonProtobuf proposal PDF — minimalist tech style."""
from fpdf import FPDF
import os

# Find Chinese font
chinese_font = None
for fp in [
    "C:/Windows/Fonts/msyh.ttc",
    "C:/Windows/Fonts/msyhbd.ttc",
    "C:/Windows/Fonts/simsun.ttc",
    "C:/Windows/Fonts/simhei.ttf",
]:
    if os.path.exists(fp):
        chinese_font = fp
        break
if not chinese_font:
    print("ERROR: No Chinese font found!")
    exit(1)

BLACK = (30, 30, 30)
DARK = (80, 80, 80)
GRAY = (140, 140, 140)
LIGHT = (220, 220, 220)
WHITE = (255, 255, 255)
ACCENT = (60, 60, 60)


class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", "", chinese_font)
        self.add_font("F", "B", chinese_font)
        self.left = 15
        self.right = 15
        self.content_w = 210 - self.left - self.right

    def header(self):
        pass

    def footer(self):
        self.set_y(-15)
        self.set_font("F", "", 6.5)
        self.set_text_color(*GRAY)
        self.cell(0, 8, f"{self.page_no()}", align="C")

    def hr(self):
        self.set_draw_color(*LIGHT)
        self.set_line_width(0.3)
        y = self.get_y() + 1
        self.line(self.left, y, 210 - self.right, y)
        self.ln(3)

    def section(self, num, title):
        self.ln(4)
        self.set_font("F", "B", 11)
        self.set_text_color(*BLACK)
        self.cell(0, 6, f"// {num}. {title}", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(*BLACK)
        self.set_line_width(1.2)
        self.line(self.left, self.get_y() + 1, self.left + 18, self.get_y() + 1)
        self.ln(4)

    def body(self, text):
        self.set_font("F", "", 8.5)
        self.set_text_color(*DARK)
        self.set_x(self.left + 2)
        self.multi_cell(self.content_w - 2, 4.5, text, align="L")

    def kv(self, key, value):
        self.set_font("F", "B", 8.5)
        self.set_text_color(*BLACK)
        self.set_x(self.left + 2)
        self.cell(20, 5, key)
        self.set_font("F", "", 8.5)
        self.set_text_color(*DARK)
        self.cell(0, 5, value, new_x="LMARGIN", new_y="NEXT")

    def bullet(self, text):
        self.set_font("F", "", 8.5)
        self.set_text_color(*DARK)
        self.set_x(self.left + 6)
        self.cell(3, 4.5, "-")
        self.cell(0, 4.5, text, new_x="LMARGIN", new_y="NEXT")

    def badge(self, text):
        self.set_font("F", "B", 8)
        self.set_text_color(*DARK)
        self.set_x(self.left + 2)
        self.cell(0, 5, f">> {text}", new_x="LMARGIN", new_y="NEXT")

    def table(self, headers, rows, widths):
        # Header
        self.set_fill_color(245, 245, 245)
        self.set_font("F", "B", 7.5)
        self.set_text_color(*BLACK)
        h = 5.5
        self.set_x(self.left + 2)
        for cell, w in zip(headers, widths):
            self.cell(w, h, cell, fill=True)
        self.ln(h)
        # Rows
        for row in rows:
            is_total = row[0] == "合计"
            if is_total:
                self.set_font("F", "B", 7.5)
                self.set_draw_color(*BLACK)
                self.set_line_width(0.4)
                y = self.get_y()
                self.line(self.left + 2, y, self.left + 2 + sum(widths), y)
            else:
                self.set_font("F", "", 7.5)
            self.set_text_color(*BLACK)
            self.set_x(self.left + 2)
            for cell, w in zip(row, widths):
                self.cell(w, 5.2, cell)
            self.ln(5.2)


pdf = PDF()
pdf.set_auto_page_break(auto=True, margin=18)
pdf.set_left_margin(pdf.left)
pdf.set_right_margin(pdf.right)
pdf.add_page()

# === HEADER ===
pdf.set_font("F", "B", 20)
pdf.set_text_color(*BLACK)
pdf.cell(0, 9, "MoonProtobuf", align="L", new_x="LMARGIN", new_y="NEXT")

pdf.set_font("F", "", 8.5)
pdf.set_text_color(*GRAY)
pdf.cell(0, 5, "Protocol Buffers Wire Format Encoder / Decoder for MoonBit", new_x="LMARGIN",
         new_y="NEXT")

pdf.set_draw_color(*BLACK)
pdf.set_line_width(1.5)
pdf.line(pdf.left, pdf.get_y() + 3, 210 - pdf.right, pdf.get_y() + 3)
pdf.ln(6)

pdf.set_font("F", "", 7.5)
pdf.set_text_color(*GRAY)
pdf.cell(0, 4, "2026 MoonBit 国产开源生态竞赛（个人赛）  |  MIT License", new_x="LMARGIN",
         new_y="NEXT")
pdf.ln(4)

# === 一、基本信息 ===
pdf.section("01", "基本信息")
pdf.kv("项目", "MoonProtobuf — Protocol Buffers 运行时编码解码库")
pdf.kv("GitHub", "https://github.com/Duan-lang-dev/MoonProtobuf")
pdf.kv("GitLink", "https://gitlink.org.cn/Duan525/moonproto")
pdf.kv("方向", "MoonBit 基础库 / 序列化协议基础设施")
pdf.kv("类型", "原创实现（基于 Protobuf wire format 公开规范）")
pdf.hr()

# === 二、项目简介 ===
pdf.section("02", "项目简介")
pdf.body(
    "MoonProtobuf 是一个纯 MoonBit 实现的 Protocol Buffers 运行时编码解码库，"
    "完整实现 protobuf wire format 规范。涵盖 varint/zigzag 编解码、四种 wire type 读写、"
    "Builder 模式 Encoder、位置追踪 Decoder、packed repeated 字段以及 .proto 文件解析器。"
    "全部纯 MoonBit 实现，零外部依赖（仅 core/encoding/utf8），跨平台 Native/Wasm/JS 可运行。"
    "填补了 MoonBit 生态中 protobuf 序列化基础设施的空白。"
)
pdf.hr()

# === 三、核心模块 ===
pdf.section("03", "核心模块")

pdf.badge("底层 — Varint & Wire")
for item in [
    "ULEB128 varint 编解码（0 ~ 2^64-1），含 decode_varint/decode_sint32/decode_sint64",
    "Zigzag 32/64 有符号映射，小绝对值负数仅占 1 字节",
    "Tag = (field_number << 3) | wire_type，make_tag / split_tag 编解码",
    "4 种 wire type 读写（Varint 0 / Fixed64 1 / Length-delimited 2 / Fixed32 5），均带边界检查",
]:
    pdf.bullet(item)

pdf.badge("中层 — Encoder & Decoder")
for item in [
    "Encoder（20 个方法）：全部标量类型 + string / bytes / message，Builder 模式链式调用",
    "Decoder（19 个方法）：read_tag 驱动循环，按 field_number 分发，skip_field 跳过未知字段",
    "read_message 返回独立嵌套 Decoder，支持任意深度嵌套",
    "负长度溢出防护、负数 pos 边界检查",
]:
    pdf.bullet(item)

pdf.badge("上层 — Packed & Proto Parser")
for item in [
    "Packed repeated：5 编码 + 3 解码，支持 varint / fixed32 / fixed64 / float / double 及空数组",
    "Proto Parser（460 行）：proto3 语法，message / enum / 嵌套类型 / 字段标签，全部标量类型",
]:
    pdf.bullet(item)
pdf.hr()

# === 四、差异化 ===
pdf.section("04", "差异化价值")

pdf.table(
    ["维度", "MoonBit 生态现状", "MoonProtobuf"],
    [
        ("Protobuf 实现", "空白", "完整 wire format 实现"),
        ("Varint 编码", "仅 LEB128 encode", "完整 encode + decode API"),
        ("Zigzag 编码", "无", "有符号整数 zigzag 映射"),
        ("编码 API", "无", "Builder 模式 20 个方法"),
        ("解码 API", "无", "位置追踪 19 个方法 + skip"),
        ("Packed repeated", "无", "5 编码 + 3 解码函数"),
        ("Proto 文件解析", "无", "proto3 message/enum/嵌套"),
    ],
    [40, 65, 75],
)
pdf.ln(2)
pdf.body(
    "MoonProtobuf 在 MoonBit 生态中无直接竞品，填补了 protobuf 序列化基础设施空白。"
    "Protobuf wire format 是业界最广泛使用的二进制序列化协议，"
    "本项目使 MoonBit 能够与 Go / Rust / Java / Python 等主流语言的 protobuf 实现进行跨语言数据交换。"
)
pdf.hr()

# === 五、规模 ===
pdf.section("05", "项目规模")

pdf.table(
    ["模块", "源码", "测试", "测试数"],
    [
        ("varint", "87", "111", "16"),
        ("wire", "79", "76", "11"),
        ("encoder", "132", "83", "11"),
        ("decoder", "288", "156", "14"),
        ("packed", "95", "109", "6"),
        ("proto_parser", "460", "121", "8"),
        ("moonproto (入口)", "13", "406", "8"),
        ("CLI", "62", "—", "—"),
        ("合计", "1,216", "1,062", "80"),
    ],
    [56, 30, 30, 30],
)

pdf.ln(3)
pdf.body(
    "总计 2,279 行 MoonBit 代码，80 个测试全部通过，20 次有效提交。"
    "CI 已配置（check + test + build），GitHub + GitLink 双仓库已推送。"
    "MIT 许可证，README 完整文档，CLI Demo 可运行。"
)
pdf.hr()

# === 六、场景 ===
pdf.section("06", "适用场景")
for item in [
    "微服务通信 — 高效二进制序列化，适合 MoonBit 服务间 RPC",
    "数据持久化 — 紧凑二进制存储格式",
    "配置序列化 — 强类型且向前兼容的配置存储方案",
    "嵌入式 / IoT — 低带宽场景下的高效编码",
    "基础设施 — 补全 MoonBit 生态序列化协议支持",
    "跨语言交换 — 与 Go / Rust / Java / Python protobuf 实现互操作",
]:
    pdf.bullet(item)

# === End ===
pdf.ln(6)
pdf.set_draw_color(*BLACK)
pdf.set_line_width(1.5)
pdf.line(pdf.left, pdf.get_y(), 210 - pdf.right, pdf.get_y())
pdf.ln(3)
pdf.set_font("F", "", 7)
pdf.set_text_color(*GRAY)
pdf.cell(0, 4, "MoonProtobuf  |  Duan525  |  2026", align="R")

output_path = os.path.join(os.path.dirname(__file__), "MoonProtobuf项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
