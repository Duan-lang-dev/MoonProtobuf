"""Generate MoonProtobuf proposal PDF — one-page compact style."""
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


class PDF(FPDF):
    def __init__(self):
        super().__init__()
        self.add_font("F", "", chinese_font)
        self.add_font("F", "B", chinese_font)

    def header(self):
        pass

    def footer(self):
        pass

    def title_line(self):
        self.set_fill_color(27, 67, 50)
        self.rect(self.l_margin, self.get_y(), self.w - self.l_margin - self.r_margin, 2,
                   style="F")
        self.ln(4)
        self.set_font("F", "B", 16)
        self.set_text_color(27, 67, 50)
        self.cell(0, 7, "MoonProtobuf 项目申报书", align="C", new_x="LMARGIN", new_y="NEXT")
        self.set_font("F", "", 8)
        self.set_text_color(130, 120, 105)
        self.cell(0, 5, "2026 MoonBit 国产开源生态竞赛（个人赛）", align="C", new_x="LMARGIN",
                  new_y="NEXT")
        self.ln(2)

    def sec(self, num, title):
        self.ln(1)
        self.set_font("F", "B", 10)
        self.set_text_color(27, 67, 50)
        self.cell(0, 5, f"{num}、{title}", new_x="LMARGIN", new_y="NEXT")
        self.set_draw_color(27, 67, 50)
        self.set_line_width(0.2)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(1.5)

    def body(self, text):
        self.set_font("F", "", 7.5)
        self.set_text_color(55, 55, 55)
        self.multi_cell(0, 3.8, text, align="L")

    def bullet(self, text):
        self.set_font("F", "", 7)
        self.set_text_color(65, 65, 65)
        self.cell(3, 3.6, "")
        self.cell(0, 3.6, "- " + text, new_x="LMARGIN", new_y="NEXT")

    def info(self, label, value):
        self.set_font("F", "B", 7.5)
        self.set_text_color(60, 60, 60)
        self.cell(28, 4.2, label + "：")
        self.set_font("F", "", 7.5)
        self.set_text_color(50, 50, 50)
        self.cell(0, 4.2, value, new_x="LMARGIN", new_y="NEXT")

    def sub(self, title):
        self.set_font("F", "B", 8)
        self.set_text_color(27, 67, 50)
        self.cell(0, 4.5, title, new_x="LMARGIN", new_y="NEXT")

    def t_header(self, cells, widths):
        self.set_fill_color(27, 67, 50)
        self.set_text_color(255, 255, 255)
        self.set_font("F", "B", 7)
        h = 5
        for cell, w in zip(cells, widths):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="F")
            self.cell(w, h, " " + cell)
        self.ln(h)

    def t_row(self, cells, widths, bold=False):
        if bold:
            self.set_fill_color(248, 245, 236)
            self.set_font("F", "B", 7)
        else:
            self.set_fill_color(255, 255, 255)
            self.set_font("F", "", 7)
        self.set_text_color(50, 50, 50)
        h = 4.8
        for cell, w in zip(cells, widths):
            x = self.get_x()
            self.rect(x, self.get_y(), w, h, style="DF")
            self.cell(w, h, " " + cell)
        self.ln(h)


pdf = PDF()
pdf.set_auto_page_break(auto=False)
pdf.add_page()

pdf.title_line()

# ===== 一 =====
pdf.sec("一", "基本信息")
pdf.info("项目名称",
         "MoonProtobuf：Protocol Buffers 运行时编码解码库（Varint/Zigzag/Wire Types/Encoder/Decoder/Packed/Proto Parser）")
pdf.info("GitHub", "https://github.com/Duan-lang-dev/MoonProtobuf")
pdf.info("GitLink", "https://gitlink.org.cn/Duan525/moonproto")
pdf.info("项目方向", "MoonBit 基础库 / 序列化协议基础设施")
pdf.info("移植说明", "原创实现，基于 Protobuf wire format 公开规范，参考 Go protowire、Rust prost 实现模式")
pdf.info("许可证", "MIT")

# ===== 二 =====
pdf.sec("二", "项目简介")
pdf.body(
    "MoonProtobuf 是一个纯 MoonBit 实现的 Protocol Buffers 运行时编码解码库，支持完整的 protobuf wire format。"
    "项目面向需要在 MoonBit 生态中进行高效二进制序列化的开发者，提供 varint/zigzag 编解码、四种 wire type、"
    "Builder 模式高级 Encoder、位置追踪高级 Decoder、packed repeated 字段以及 .proto 文件解析器。"
    "MoonBit 生态中尚无可用的 protobuf 运行时库，本项目填补这一空白。"
    "全部纯 MoonBit 实现，零外部依赖（仅 core/encoding/utf8），跨平台 Native/Wasm/JS 可运行。"
)

# ===== 三 =====
pdf.sec("三", "核心模块")

pdf.sub("Varint & Wire 层（166行） | Encoder & Decoder（420行） | Packed Repeated（95行） | Proto Parser（460行）")
for item in [
    "Varint: ULEB128 编解码（0~2^64-1），Zigzag 32/64 有符号映射，sint32/sint64 组合编解码，含 decode_sint 互补 API",
    "Wire: tag 编解码（make_tag/split_tag），4 种 wire type 读写（Varint/Fixed64/Length-delimited/Fixed32），负数 pos 边界检查",
    "Encoder: 20 个方法（int32/64, uint32/64, sint32/64, fixed32/64, sfixed32/64, float, double, bool, string, bytes, message），Builder 链式调用",
    "Decoder: 19 个方法（read_tag 驱动循环，按字段号分发，skip_field 跳过未知字段，read_message 嵌套解码），负长度溢出防护",
    "Packed: 5 编码函数（packed_varint/fixed32/fixed64/float/double），3 解码函数，空数组支持",
    "Proto Parser: proto3 语法，message/enum/嵌套类型/字段标签解析，全部标量类型 + 自定义 Message/Enum 引用",
]:
    pdf.bullet(item)

# ===== 四 =====
pdf.sec("四", "差异化价值")

pdf.body("MoonProtobuf vs 生态现状：")
pdf.t_header(["维度", "MoonBit 现有", "MoonProtobuf"], [46, 50, 50])
for row in [
    ("Protobuf 实现", "不存在", "完整 wire format 实现"),
    ("Varint/Zigzag", "仅 LEB128（buffer 包）", "完整 protobuf varint + 解码 API"),
    ("编码 API", "无", "Builder 模式，方法链式调用"),
    ("解码 API", "无", "位置追踪，字段分发 + 跳过"),
    ("Packed Repeated", "无", "5 编码 + 3 解码"),
    ("Proto 解析", "无", "message/enum/嵌套类型"),
    ("平台支持", "—", "纯 MoonBit，Native/Wasm/JS"),
]:
    pdf.t_row(row, [46, 50, 50])

pdf.body(
    "MoonProtobuf 在 MoonBit 生态中无直接竞品，填补了 protobuf 序列化基础设施的空白。"
    "protobuf wire format 是 Google 内部及业界最广泛使用的二进制序列化协议，"
    "MoonProtobuf 的实现使 MoonBit 项目能够与 Go/Rust/Java/Python 等语言的 protobuf 实现进行跨语言数据交换。"
)

# ===== 五 =====
pdf.sec("五", "项目规模与进度")

pdf.t_header(["模块", "源码行", "测试行", "测试数"], [50, 24, 24, 24])
for row in [
    ("varint", "87", "111", "16"),
    ("wire", "79", "76", "11"),
    ("encoder", "132", "83", "11"),
    ("decoder", "288", "156", "14"),
    ("packed", "95", "109", "6"),
    ("proto_parser", "460", "121", "8"),
    ("moonproto (入口+集成)", "13", "406", "8"),
    ("CLI / 其他", "62", "-", "-"),
    ("合计", "1,216", "1,062", "80"),
]:
    pdf.t_row(row, [50, 24, 24, 24], bold=(row[0] == "合计"))
pdf.ln(1)

pdf.body(
    "总计 2,279 行，80 测试全通过，20 次有效提交，CI 已配置。"
    "已完成全部 7 个模块实现、完整测试套件、项目文档、.proto 文件解析器。"
    "GitHub + GitLink 双仓库已推送。"
)

# ===== 六 =====
pdf.sec("六", "适用场景")
pdf.body(
    "微服务通信（高效二进制序列化，适合 MoonBit 服务间 RPC）| "
    "数据持久化（紧凑的二进制存储格式）| "
    "配置文件序列化（强类型、向前兼容）| "
    "嵌入式/IoT 场景（低带宽高效编码）| "
    "MoonBit 生态基础设施（补全序列化协议支持）| "
    "跨语言数据交换（与 Go/Rust/Java/Python 等 protobuf 实现互操作）"
)

output_path = os.path.join(os.path.dirname(__file__), "MoonProtobuf项目申报书.pdf")
pdf.output(output_path)
print(f"Done: {output_path}")
