import SwiftUI

/// iOS 16 平替：SwiftUI.ContentUnavailableView 是 iOS 17+，iOS 16 下不存在。
/// 本文件提供同名用法的兼容视图，调用点已由 ContentUnavailableView 统一改名为 EmptyStateView，
/// 覆盖仓库里实际用到的三种形式：
///  1. EmptyStateView { Label } description: { Text } [actions: { ... }]
///  2. EmptyStateView("标题", systemImage: "...", description: Text("..."))
///  3. EmptyStateView.search / EmptyStateView.search(text:)
/// 外观为居中图标 + 标题 + 说明 + 可选按钮，功能与原空态一致，只是没有系统空态的精确排版。
struct EmptyStateView<Label: View, Description: View, Actions: View>: View {
    private let label: Label
    private let description: Description
    private let actions: Actions

    init(@ViewBuilder label: () -> Label, @ViewBuilder description: () -> Description, @ViewBuilder actions: () -> Actions) {
        self.label = label()
        self.description = description()
        self.actions = actions()
    }

    init(@ViewBuilder label: () -> Label, @ViewBuilder description: () -> Description) where Actions == EmptyView {
        self.label = label()
        self.description = description()
        self.actions = EmptyView()
    }

    init(_ title: String, systemImage: String, description: Text) where Label == Label<Text, Image>, Description == Text, Actions == EmptyView {
        self.label = Label(title, systemImage: systemImage)
        self.description = description
        self.actions = EmptyView()
    }

    var body: some View {
        VStack(spacing: Metrics.s) {
            label
                .font(.title2.bold())
                .foregroundStyle(.primary)
            description
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            actions
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Metrics.m)
    }
}

extension EmptyStateView where Label == Label<Text, Image>, Description == Text, Actions == EmptyView {
    static func search(text: String) -> EmptyStateView<Label<Text, Image>, Text, EmptyView> {
        EmptyStateView("没有搜索结果", systemImage: "magnifyingglass", description: Text("没有找到 “\(text)” 的结果"))
    }

    static var search: EmptyStateView<Label<Text, Image>, Text, EmptyView> {
        EmptyStateView("没有搜索结果", systemImage: "magnifyingglass", description: Text("换个关键词试试"))
    }
}
