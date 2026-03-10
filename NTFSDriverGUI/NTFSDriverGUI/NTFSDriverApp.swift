import SwiftUI

@main
struct NTFSDriverApp: App {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @State private var showingSetup = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showingSetup) {
                    SetupView(isPresented: $showingSetup)
                }
                .onAppear {
                    if !hasCompletedSetup {
                        showingSetup = true
                    }
                }
                .onChange(of: showingSetup) { newValue in
                    if !newValue {
                        hasCompletedSetup = true
                    }
                }
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .help) {
                Button("Руководство по установке") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/kokobongafreakr222/ntfs-macos-driver#readme")!)
                }
                Button("Проверить зависимости") {
                    NotificationCenter.default.post(name: .checkPrerequisites, object: nil)
                }
            }
        }
    }
}

extension Notification.Name {
    static let checkPrerequisites = Notification.Name("checkPrerequisites")
}
