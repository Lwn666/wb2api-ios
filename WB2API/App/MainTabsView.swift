import SwiftUI

enum AppTab: Hashable {
    case overview, accounts, tasks, data, more

    var title: String {
        switch self {
        case .overview: return "概览"
        case .accounts: return "账号"
        case .tasks: return "任务"
        case .data: return "数据"
        case .more: return "更多"
        }
    }

    var icon: String {
        switch self {
        case .overview: return "speedometer"
        case .accounts: return "person.2.fill"
        case .tasks: return "checklist"
        case .data: return "chart.bar.xaxis"
        case .more: return "ellipsis"
        }
    }

    static let all: [AppTab] = [.overview, .accounts, .tasks, .data, .more]
}

struct MainTabsView: View {
    @Environment(\.appTheme) private var theme

    @State private var selection: AppTab = .overview
    @State private var toast: Toast?

    init() {
        // iOS 16 没有 iOS 26 的浮动 Liquid Glass TabBar：
        // 隐掉系统 TabBar（在 iOS 16 上只能渲染成整条白底），改用自绘玻璃胶囊。
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                OverviewView()
                    .tabItem { Label(AppTab.overview.title, systemImage: AppTab.overview.icon) }
                    .tag(AppTab.overview)
                AccountsView()
                    .tabItem { Label(AppTab.accounts.title, systemImage: AppTab.accounts.icon) }
                    .tag(AppTab.accounts)
                TasksView()
                    .tabItem { Label(AppTab.tasks.title, systemImage: AppTab.tasks.icon) }
                    .tag(AppTab.tasks)
                DataView()
                    .tabItem { Label(AppTab.data.title, systemImage: AppTab.data.icon) }
                    .tag(AppTab.data)
                MoreView()
                    .tabItem { Label(AppTab.more.title, systemImage: AppTab.more.icon) }
                    .tag(AppTab.more)
            }
            .tint(theme.primary)
            // 悬浮栏覆盖在内容之上，留出底部空白，避免最后一张卡片被压住
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: Metrics.tabBarClearance)
            }

            GlassTabBar(selection: $selection)
                .padding(.horizontal, Metrics.m)
                .padding(.bottom, Metrics.s)
        }
        .toast($toast)
    }
}

/// iOS 16 上的 Liquid Glass 近似：超薄材质 + 上缘高光 + 内阴影 + 柔和外阴影。
/// 真正的折射/边缘色散由 iOS 26 的 WindowServer 合成，iOS 16 无法复现；
/// 这里用多层叠加把「浮动胶囊玻璃」的观感做到接近。
struct GlassTabBar: View {
    @Environment(\.appTheme) private var theme

    @Binding var selection: AppTab
    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.all, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 4)
        .background(glassBackground)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: selection)
    }

    // MARK: - 单个标签

    private func item(_ tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                    .frame(height: 22)
                Text(tab.title)
                    .font(.system(size: 10.5, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? AnyShapeStyle(theme.primary) : AnyShapeStyle(Color.primary.opacity(0.72)))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(Color.primary.opacity(0.075))
                        .overlay(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.6)
                        )
                        .matchedGeometryEffect(id: "selection", in: indicator)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    // MARK: - 玻璃底

    private var glassBackground: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            // 上缘高光 + 下缘暗边：模拟玻璃的边缘折射
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.85), location: 0.00),
                                .init(color: Color.white.opacity(0.28), location: 0.16),
                                .init(color: Color.white.opacity(0.06), location: 0.55),
                                .init(color: Color.black.opacity(0.10), location: 1.00)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.9
                    )
            )
            // 内侧一圈极淡的阴影，让玻璃看起来有厚度
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 2.5)
                    .blur(radius: 2)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
    }
}
