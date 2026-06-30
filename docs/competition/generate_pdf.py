"""Generate MoonProtobuf proposal PDF — compact minimalist tech style, single page."""
from fpdf import FPDF
import os

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
DARK = (75, 75, 75)
GRAY = (140, 140, 140)
LIGHT = (210, 210, 210)


class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", "", chinese_font)
        self.add_font("F", "B", chinese_font)
        self.L = 14
        self.R = 14
        self.CW = 210 - self.L - self.R

    def header(self):
        pass

    def footer(self):
        pass

    def hr(self):
        self.set_draw_color(*LIGHT)
        self.set_line_width(0.2)
        y = self.get_y() + 0.5
        self.line(self.L, y, 210 - self.R, y)
        self.ln(1.5)

    def sec(self, num, title):
        self.set_font("F", "B", 9.5)
        self.set_text_color(*BLACK)
        self.cell(0, 5, f"// {num}. {title}", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(*BLACK)
        self.set_line_width(0.8)
        self.line(self.L, self.get_y() + 0.5, self.L + 14, self.get_y() + 0.5)
        self.ln(2)

    def body(self, text):
        self.set_font("F", "", 7.2)
        self.set_text_color(*DARK)
        self.set_x(self.L + 2)
        self.multi_cell(self.CW - 2, 3.6, text, align="L")

    def kv(self, key, value):
        self.set_font("F", "B", 7.2)
        self.set_text_color(*BLACK)
        self.set_x(self.L + 2)
        self.cell(17, 4, key)
        self.set_font("F", "", 7.2)
        self.set_text_color(*DARK)
        self.cell(0, 4, value, new_x="LMARGIN", new_y="NEXT")

    def bullet(self, text):
        self.set_font("F", "", 7)
        self.set_text_color(*DARK)
        self.set_x(self.L + 5)
        self.cell(2.5, 3.8, "-")
        self.cell(0, 3.8, text, new_x="LMARGIN", new_y="NEXT")

    def badge(self, text):
        self.set_font("F", "B", 7.2)
        self.set_text_color(*DARK)
        self.set_x(self.L + 2)
        self.cell(0, 4.2, f">> {text}", new_x="LMARGIN", new_y="NEXT")

    def table(self, headers, rows, widths):
        # header
        self.set_fill_color(245, 245, 245)
        self.set_font("F", "B", 6.8)
        self.set_text_color(*BLACK)
        row_h = 4.5
        self.set_x(self.L + 2)
        for cell, w in zip(headers, widths):
            self.cell(w, row_h, cell, fill=True)
        self.ln(row_h)
        # rows
        for row in rows:
            is_total = row[0] == "合计"
            if is_total:
                self.set_font("F", "B", 6.8)
                self.set_draw_color(*BLACK)
                self.set_line_width(0.3)
                y = self.get_y()
                self.line(self.L + 2, y, self.L + 2 + sum(widths), y)
            else:
                self.set_font("F", "", 6.8)
            self.set_text_color(*BLACK)
            self.set_x(self.L + 2)
            row_h = 4.2
            for cell, w in zip(row, widths):
                self.cell(w, row_h, cell)
            self.ln(row_h)


pdf = PDF()
pdf.set_auto_page_break(auto=False)
pdf.set_left_margin(pdf.L)
pdf.set_right_margin(pdf.R)
pdf.add_page()

# === HEADER ===
pdf.set_font("F", "B", 17)
pdf.set_text_color(*BLACK)
pdf.cell(0, 7, "MoonProtobuf", align="L", new_x="LMARGIN", new_y="NEXT")

pdf.set_font("F", "", 7.2)
pdf.set_text_color(*GRAY)
pdf.cell(0, 4, "Protocol Buffers Wire Format Encoder / Decoder for MoonBit", new_x="LMARGIN",
         new_y="NEXT")

pdf.set_draw_color(*BLACK)
pdf.set_line_width(1.2)
pdf.line(pdf.L, pdf.get_y() + 2.5, 210 - pdf.R, pdf.get_y() + 2.5)
pdf.ln(4)

pdf.set_font("F", "", 6.8)
pdf.set_text_color(*GRAY)
pdf.cell(0, 3.5, "2026 MoonBit 国产开源生态竞赛（个人赛）  |  MIT License", new_x="LMARGIN",
         new_y="NEXT")
pdf.ln(2)

# === 01 基本信息 ===
pdf.sec("01", "基本信息")
pdf.kv("项目", "MoonProtobuf — Protocol Buffers 运行时编码解码库")
pdf.kv("仓库", "GitHub: github.com/Duan-lang-dev/MoonProtobuf  |  GitLink: gitlink.org.cn/Duan525/moonproto")
pdf.kv("方向", "MoonBit 基础库 / 序列化协议基础设施  |  原创实现（基于 Protobuf 公开规范）")
pdf.hr()

# === 02 项目简介 ===
pdf.sec("02", "项目简介")
pdf.body(
    "MoonProtobuf 是一个纯 MoonBit 实现的 Protocol Buffers 运行时编码解码库，"
    "完整实现 protobuf wire format 规范。涵盖 varint/zigzag 编解码、四种 wire type 读写、"
    "Builder 模式 Encoder（20 个方法）、位置追踪 Decoder（19 个方法 + skip_field）、"
    "packed repeated 字段编解码，以及 .proto 文件解析器（proto3 语法）。"
    "全部纯 MoonBit 实现，零外部依赖，跨平台 Native/Wasm/JS 可运行，"
    "填补 MoonBit 生态中 protobuf 序列化基础设施空白。"
)
pdf.hr()

# === 03 核心模块 ===
pdf.sec("03", "核心模块")

pdf.badge("底层 — Varint / Wire（166 行）")
for item in [
    "ULEB128 varint 编解码（0 ~ 2^64-1），含 decode_varint / decode_sint32 / decode_sint64 互补 API",
    "Zigzag 32/64 有符号映射，小绝对值负数仅占 1 字节",
    "4 种 wire type 读写（Varint 0 / Fixed64 1 / LEN 2 / Fixed32 5），均带负数 pos 边界检查",
]:
    pdf.bullet(item)

pdf.badge("中层 — Encoder / Decoder（420 行）")
for item in [
    "Encoder：20 个方法覆盖全部标量类型 + string / bytes / message，Builder 模式链式调用",
    "Decoder：19 个方法，read_tag 驱动循环、按 field_number 分发、skip_field 跳过未知、read_message 嵌套解码，含负长度溢出防护",
]:
    pdf.bullet(item)

pdf.badge("上层 — Packed Repeated / Proto Parser（555 行）")
for item in [
    "Packed：5 编码 + 3 解码函数，支持 varint / fixed32 / fixed64 / float / double 及空数组",
    "Proto Parser：proto3 完整语法，message / enum / 嵌套类型 / 字段标签，全部标量类型 + 自定义类型引用",
]:
    pdf.bullet(item)
pdf.hr()

# === 04 差异化 ===
pdf.sec("04", "差异化价值")

pdf.table(
    ["维度", "MoonBit 生态现状", "MoonProtobuf"],
    [
        ("Protobuf 实现", "空白", "完整 wire format"),
        ("Varint 编码", "仅 LEB128 encode", "完整 encode + decode"),
        ("Zigzag", "无", "32/64 位映射"),
        ("编码 / 解码 API", "无", "Builder + 位置追踪"),
        ("Packed repeated", "无", "5 编码 + 3 解码"),
        ("Proto 文件解析", "无", "proto3 message/enum/嵌套"),
    ],
    [40, 58, 78],
)
pdf.ln(1)
pdf.body(
    "MoonBit 生态首个 protobuf 运行时库，实现与 Go / Rust / Java / Python 等主流语言 protobuf 实现的跨语言数据交换。"
)
pdf.hr()

# === 05 规模 ===
pdf.sec("05", "项目规模")

pdf.table(
    ["模块", "源码", "测试", "数"],
    [
        ("varint", "87", "111", "16"),
        ("wire", "79", "76", "11"),
        ("encoder", "132", "83", "11"),
        ("decoder", "288", "156", "14"),
        ("packed", "95", "109", "6"),
        ("proto_parser", "460", "121", "8"),
        ("入口 / 集成测试", "13", "406", "8"),
        ("CLI", "62", "—", "—"),
        ("合计", "1,216", "1,062", "80"),
    ],
    [54, 28, 28, 20],
)

pdf.ln(1.5)
pdf.body(
    "总计 2,279 行 MoonBit 代码，80 个测试全部通过，22 次有效提交。"
    "CI 已配置（check + test + build），GitHub + GitLink 双仓库已推送，MIT 许可证。"
)
pdf.hr()

# === 06 场景 ===
pdf.sec("06", "适用场景")
for item in [
    "微服务通信 — 高效二进制序列化，适合 MoonBit 服务间 RPC",
    "数据持久化 — 紧凑二进制存储格式",
    "配置序列化 — 强类型且向前兼容的配置存储方案",
    "嵌入式 / IoT — 低带宽场景下的高效编码",
    "基础设施 — 补全 MoonBit 生态序列化协议支持",
    "跨语言交换 — 与 Go / Rust / Java / Python 等 protobuf 实现互操作",
]:
    pdf.bullet(item)

# === End line ===
pdf.ln(2)
pdf.set_draw_color(*BLACK)
pdf.set_line_width(1.2)
pdf.line(pdf.L, pdf.get_y(), 210 - pdf.R, pdf.get_y())
pdf.ln(2)
pdf.set_font("F", "", 6.5)
pdf.set_text_color(*GRAY)
pdf.cell(0, 3.5, "MoonProtobuf  |  Duan525  |  2026", align="R")

output_path = os.path.join(os.path.dirname(__file__), "MoonProtobuf项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
