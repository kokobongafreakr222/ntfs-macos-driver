import SwiftUI

struct SidebarView: View {
    @ObservedObject var diskManager: DiskManager
    @Binding var selectedDisk: Disk?
    
    var body: some View {
        List(selection: $selectedDisk) {
            Section(header: Text("NTFS Диски")) {
                ForEach(diskManager.disks.filter { $0.isNTFS }) { disk in
                    DiskRowView(disk: disk)
                        .tag(disk)
                }
            }
            
            Section(header: Text("Другие диски")) {
                ForEach(diskManager.disks.filter { !$0.isNTFS }) { disk in
                    DiskRowView(disk: disk)
                        .tag(disk)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Диски")
    }
}

struct DiskRowView: View {
    let disk: Disk
    
    var body: some View {
        HStack {
            Image(systemName: iconForFilesystem(disk.fileSystem))
                .foregroundColor(colorForFilesystem(disk.fileSystem))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(disk.name)
                    .font(.headline)
                Text("\(disk.device) • \(disk.size)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if disk.isMounted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            if disk.isNTFS {
                Text("NTFS")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
    
    func iconForFilesystem(_ fs: String) -> String {
        if fs.contains("NTFS") { return "externaldrive.fill" }
        if fs.contains("FAT") { return "externaldrive" }
        if fs.contains("APFS") { return "internaldrive" }
        return "externaldrive"
    }
    
    func colorForFilesystem(_ fs: String) -> Color {
        if fs.contains("NTFS") { return .blue }
        if fs.contains("FAT") { return .green }
        return .gray
    }
}
