import SwiftUI

struct ContentView: View {
    @StateObject private var diskManager = DiskManager()
    @State private var selectedDisk: Disk?
    @State private var showingInstallAlert = false
    
    var body: some View {
        NavigationView {
            SidebarView(diskManager: diskManager, selectedDisk: $selectedDisk)
                .frame(minWidth: 280)
            
            if let disk = selectedDisk {
                DiskDetailView(disk: disk, diskManager: diskManager)
            } else {
                EmptyStateView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { diskManager.refreshDisks() }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(diskManager.isLoading)
            }
            
            ToolbarItem {
                Button(action: checkPrerequisites) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .alert("Требуется установка", isPresented: $showingInstallAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Для работы с NTFS необходимо установить macFUSE и ntfs-3g. См. инструкцию в README.")
        }
        .onAppear {
            diskManager.refreshDisks()
            checkPrerequisites()
        }
    }
    
    private func checkPrerequisites() {
        if !diskManager.checkFUSEInstalled() {
            showingInstallAlert = true
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "externaldrive.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Выберите NTFS диск")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Для работы требуется:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("macFUSE", systemImage: "checkmark.circle")
                    Label("ntfs-3g", systemImage: "checkmark.circle")
                }
                .font(.caption)
            }
            .padding(.top, 10)
        }
    }
}

struct StatusBadge: View {
    let isMounted: Bool
    let isNTFS: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isMounted ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
            
            Text(isMounted ? "Смонтирован" : "Не смонтирован")
                .font(.caption)
                .fontWeight(.medium)
            
            if isNTFS {
                Text("NTFS")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}
