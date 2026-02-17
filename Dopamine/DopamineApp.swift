import SwiftUI

@main
struct DopamineApp: App {
    @StateObject private var viewModel = HabitViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    /// Handles dopamine://open?scheme=X&fallback=Y deep links from the widget
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "dopamine",
              url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let schemeParam = components.queryItems?.first(where: { $0.name == "scheme" })?.value
        else { return }

        let fallback = components.queryItems?.first(where: { $0.name == "fallback" })?.value

        if let appURL = URL(string: schemeParam) {
            UIApplication.shared.open(appURL) { success in
                if !success, let fb = fallback, let fbURL = URL(string: fb) {
                    UIApplication.shared.open(fbURL)
                }
            }
        }
    }
}
