import SwiftUI

// MARK: - 颜色

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r = Double((value & 0xFF0000) >> 16) / 255
        let g = Double((value & 0x00FF00) >> 8) / 255
        let b = Double(value & 0x0000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    init(light: String, dark: String) {
        self.init(uiColor: UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }
}

// MARK: - 间距 / 圆角

enum Metrics {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let minTap: CGFloat = 44

    static let radiusS: CGFloat = 10
    static let radiusM: CGFloat = 16
    static let radiusL: CGFloat = 22
    static let radiusXL: CGFloat = 28

    /// 悬浮 Tab 栏下方的滚动留白，避免最后一张卡片被盖住。
    static let tabBarClearance: CGFloat = 96
}

// MARK: - 字体（只用系统文本样式，Dynamic Type 自动生效）

extension Font {
    /// 大号数字：等宽，避免跳动
    static func metric(_ style: Font.TextStyle = .largeTitle) -> Font {
        .system(style, design: .rounded).monospacedDigit().bold()
    }

    static func metricSmall() -> Font {
        .system(.title2, design: .rounded).monospacedDigit().bold()
    }

    /// 小标签：系统 caption + 轻字距
    static var tag: Font { .caption.weight(.medium) }
}

// MARK: - 卡片容器（iOS 16 平替：原 iOS 26 Liquid Glass，iOS 16 用 Material + 细边框）

extension View {
    /// 常规卡片：用于内容分组。iOS 16 无 glassEffect，用 Material + 细边框平替。
    func glassCard(padding: CGFloat = Metrics.m, cornerRadius: CGFloat = Metrics.radiusL) -> some View {
        self
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primary.opacity(0.08), lineWidth: 1))
    }

    /// 可交互卡片（按钮组、控件）。
    func glassInteractive(cornerRadius: CGFloat = Metrics.radiusM) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primary.opacity(0.08), lineWidth: 1))
    }
}
