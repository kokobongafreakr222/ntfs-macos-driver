import SwiftUI

struct ContentView: View {
    @StateObject private var diskManager = DiskManager()
    @State private var selectedDisk: Disk?
    
    var body: some View {
        NavigationView {
            SidebarView(diskManager: diskManager, selectedDisk: $selectedDisk)
                .frame(minWidth: 250)
            
            if let disk = selectedDisk {
                DiskDetailView(disk: disk, diskManager: diskManager)
            } else {
                EmptyStateView()
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: { diskManager.refreshDisks() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(diskManager.isLoading)
            }
        }
        .onAppear {
            diskManager.refreshDisks()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "externaldrive")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Выберите диск")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("NTFS диски будут показаны с поддержкой записи")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
