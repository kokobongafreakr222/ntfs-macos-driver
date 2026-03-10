import SwiftUI

struct DiskDetailView: View {
    let disk: Disk
    @ObservedObject var diskManager: DiskManager
    @State private var isMounting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(disk.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        Label(disk.device, systemImage: "number")
                        Label(disk.size, systemImage: "externaldrive")
                        Label(disk.fileSystem, systemImage: "doc.text")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Status
            HStack {
                StatusBadge(isMounted: disk.isMounted, isNTFS: disk.isNTFS)
                Spacer()
            }
            
            // Info
            if let mountPoint = disk.mountPoint {
                InfoRow(title: "Точка монтирования", value: mountPoint)
            }
            
            InfoRow(title: "Файловая система", value: disk.fileSystem)
            InfoRow(title: "Размер", value: disk.size)
            
            Spacer()
            
            // Action buttons
            if disk.isNTFS {
                HStack(spacing: 16) {
                    if disk.isMounted {
                        Button(action: unmountDisk) {
                            Label("Размонтировать", systemImage: "eject")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(isMounting)
                    } else {
                        Button(action: mountDisk) {
                            Label(isMounting ? "Монтирование..." : "Монтировать с записью", 
                                  systemImage: "mount")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(isMounting)
                    }
                }
                .frame(height: 44)
            } else {
                Text("Этот диск не требует NTFS драйвера")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Внимание", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func mountDisk() {
        isMounting = true
        DispatchQueue.global(qos: .userInitiated).async {
            let success = diskManager.mountNTFS(device: disk.device)
            DispatchQueue.main.async {
                isMounting = false
                if success {
                    alertMessage = "Диск успешно смонтирован с поддержкой записи!"
                    diskManager.refreshDisks()
                } else {
                    alertMessage = "Ошибка монтирования. Проверьте, что macFUSE и ntfs-3g установлены."
                }
                showAlert = true
            }
        }
    }
    
    private func unmountDisk() {
        isMounting = true
        DispatchQueue.global(qos: .userInitiated).async {
            let success = diskManager.unmount(device: disk.device)
            DispatchQueue.main.async {
                isMounting = false
                if success {
                    alertMessage = "Диск размонтирован"
                    diskManager.refreshDisks()
                } else {
                    alertMessage = "Ошибка размонтирования"
                }
                showAlert = true
            }
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
