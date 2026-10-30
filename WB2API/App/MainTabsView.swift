import SwiftUI

enum AppTab: Hashable {
    case overview, accounts, tasks, data, more
}

struct MainTabsView: View {
    @Environment(\.appTheme) private var theme

    @State private var selection: AppTab = .overview
    @State private var toast: Toast?

    var body: some View {
        // iOS 16: 没有 iOS 18 的 Tab(value:) 构造器和 tabBarMinimizeBehavior，
        // 用传统 TabView + tabItem + tag。
        TabView(selection: $selection) {
            OverviewView()
                .tabItem { Label("概览", systemImage: "gauge.with.dots.needle.50percent") }
                .tag(AppTab.overview)
            AccountsView()
                .tabItem { Label("账号", systemImage: "person.2.fill") }
                .tag(AppTab.accounts)
            TasksView()
                .tabItem { Label("任务", systemImage: "checklist") }
                .tag(AppTab.tasks)
            DataView()
                .tabItem { Label("数据", systemImage: "chart.bar.xaxis") }
                .tag(AppTab.data)
            MoreView()
                .tabItem { Label("更多", systemImage: "ellipsis") }
                .tag(AppTab.more)
        }
        .tint(theme.primary)
        .toast($toast)
    }
}
