import Foundation

struct Disk: Identifiable {
    let id = UUID()
    let device: String
    let name: String
    let size: String
    let fileSystem: String
    let isMounted: Bool
    let mountPoint: String?
    let isNTFS: Bool
}

class DiskManager: ObservableObject {
    @Published var disks: [Disk] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fuseInstalled = false
    @Published var ntfs3gInstalled = false
    
    init() {
        checkPrerequisites()
    }
    
    func checkPrerequisites() {
        fuseInstalled = checkFUSEInstalled()
        ntfs3gInstalled = checkNTFS3GInstalled()
    }
    
    func checkFUSEInstalled() -> Bool {
        // Проверка macFUSE
        let fm = FileManager.default
        return fm.fileExists(atPath: "/Library/Frameworks/macFUSE.framework") ||
               fm.fileExists(atPath: "/usr/local/include/fuse") ||
               fm.fileExists(atPath: "/opt/homebrew/include/fuse")
    }
    
    func checkNTFS3GInstalled() -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: "/usr/local/bin/ntfs-3g") ||
               fm.fileExists(atPath: "/opt/homebrew/bin/ntfs-3g")
    }
    
    func refreshDisks() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchedDisks = self.fetchDisks()
            DispatchQueue.main.async {
                self.disks = fetchedDisks
                self.isLoading = false
            }
        }
    }
    
    private func fetchDisks() -> [Disk] {
        var result: [Disk] = []
        
        let task = Process()
        task.launchPath = "/usr/sbin/diskutil"
        task.arguments = ["list", "-json"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let allDisks = json["AllDisksAndPartitions"] as? [[String: Any]] {
                
                for disk in allDisks {
                    if let partitions = disk["Partitions"] as? [[String: Any]] {
                        for part in partitions {
                            let device = part["DeviceIdentifier"] as? String ?? ""
                            let name = part["VolumeName"] as? String ?? "Untitled"
                            let size = part["Size"] as? Int64 ?? 0
                            let fs = part["Content"] as? String ?? "Unknown"
                            let mountPoint = part["MountPoint"] as? String
                            
                            let isNTFS = fs.contains("NTFS") || fs.contains("Windows")
                            
                            result.append(Disk(
                                device: device,
                                name: name,
                                size: formatSize(size),
                                fileSystem: fs,
                                isMounted: mountPoint != nil,
                                mountPoint: mountPoint,
                                isNTFS: isNTFS
                            ))
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        return result
    }
    
    func mountNTFS(device: String) -> Bool {
        guard fuseInstalled, ntfs3gInstalled else {
            errorMessage = "macFUSE или ntfs-3g не установлены"
            return false
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/sudo"
        task.arguments = [
            "/usr/local/bin/ntfs-3g",
            "/dev/\(device)",
            "/Volumes/NTFS_\(device)",
            "-o", "local,allow_other,auto_xattr"
        ]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func unmount(device: String) -> Bool {
        let task = Process()
        task.launchPath = "/usr/sbin/diskutil"
        task.arguments = ["unmount", "/dev/\(device)"]
        
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    private func formatSize(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1024 / 1024 / 1024
        if gb >= 1000 {
            return String(format: "%.1f TB", gb / 1000)
        }
        return String(format: "%.1f GB", gb)
    }
}
