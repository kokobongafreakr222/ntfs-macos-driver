#!/usr/bin/env python3
"""
NTFS Driver for macOS - CLI
Альтернатива Paragon NTFS
"""

import argparse
import subprocess
import sys
import os
import json
from pathlib import Path
from typing import Optional, List, Tuple

# Константы
VERSION = "1.0.0"
FUSE_PATH = "/usr/local/bin"
NTFS3G_PATH = "/usr/local/bin/ntfs-3g"

class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    END = '\033[0m'

class NTFSManager:
    """Управление NTFS дисками"""
    
    def __init__(self):
        self.check_prerequisites()
    
    def check_prerequisites(self) -> bool:
        """Проверка наличия зависимостей"""
        required = ["diskutil", "mount", "umount"]
        missing = []
        
        for cmd in required:
            if not self._command_exists(cmd):
                missing.append(cmd)
        
        if missing:
            print(f"{Colors.RED}❌ Отсутствуют системные команды: {', '.join(missing)}{Colors.END}")
            return False
        
        # Проверка macFUSE
        if not os.path.exists("/Library/Frameworks/macFUSE.framework"):
            print(f"{Colors.YELLOW}⚠️  macFUSE не установлен. Установите: brew install --cask macfuse{Colors.END}")
            return False
        
        # Проверка ntfs-3g
        if not os.path.exists(NTFS3G_PATH):
            print(f"{Colors.YELLOW}⚠️  ntfs-3g не установлен. Установите: brew install ntfs-3g{Colors.END}")
            return False
        
        return True
    
    def _command_exists(self, cmd: str) -> bool:
        """Проверка существования команды"""
        result = subprocess.run(["which", cmd], capture_output=True)
        return result.returncode == 0
    
    def list_disks(self) -> List[dict]:
        """Получение списка дисков"""
        try:
            result = subprocess.run(
                ["diskutil", "list", "-json"],
                capture_output=True,
                text=True
            )
            data = json.loads(result.stdout)
            
            disks = []
            for disk in data.get("AllDisksAndPartitions", []):
                disk_info = {
                    "device": disk.get("DeviceIdentifier"),
                    "size": disk.get("Size", 0),
                    "partitions": []
                }
                
                for part in disk.get("Partitions", []):
                    part_info = {
                        "device": part.get("DeviceIdentifier"),
                        "filesystem": part.get("Content", "Unknown"),
                        "size": part.get("Size", 0),
                        "mounted": part.get("MountPoint") is not None,
                        "mount_point": part.get("MountPoint"),
                        "volume_name": part.get("VolumeName", "Untitled")
                    }
                    disk_info["partitions"].append(part_info)
                
                disks.append(disk_info)
            
            return disks
        except Exception as e:
            print(f"{Colors.RED}❌ Ошибка получения списка дисков: {e}{Colors.END}")
            return []
    
    def is_ntfs(self, device: str) -> bool:
        """Проверка, является ли раздел NTFS"""
        try:
            result = subprocess.run(
                ["diskutil", "info", device],
                capture_output=True,
                text=True
            )
            return "Windows_NTFS" in result.stdout or "NTFS" in result.stdout
        except:
            return False
    
    def mount_ntfs(self, device: str, mount_point: Optional[str] = None) -> bool:
        """Монтирование NTFS диска с поддержкой записи"""
        try:
            # Проверка существования устройства
            if not os.path.exists(f"/dev/{device}"):
                print(f"{Colors.RED}❌ Устройство /dev/{device} не найдено{Colors.END}")
                return False
            
            # Проверка, смонтирован ли уже
            result = subprocess.run(
                ["diskutil", "info", device],
                capture_output=True,
                text=True
            )
            
            if "Mount Point" in result.stdout and "not mounted" not in result.stdout.lower():
                print(f"{Colors.YELLOW}⚠️  Диск уже смонтирован. Сначала размонтируйте.{Colors.END}")
                return False
            
            # Создание точки монтирования
            if mount_point is None:
                mount_point = f"/Volumes/NTFS_{device.replace('/', '_')}"
            
            os.makedirs(mount_point, exist_ok=True)
            
            # Размонтирование macOS-ного read-only монтирования (если есть)
            subprocess.run(
                ["sudo", "umount", f"/dev/{device}"],
                capture_output=True
            )
            
            # Монтирование через ntfs-3g
            print(f"{Colors.BLUE}🔌 Монтирование /dev/{device} → {mount_point}{Colors.END}")
            
            result = subprocess.run(
                ["sudo", NTFS3G_PATH, f"/dev/{device}", mount_point, "-o", "local,allow_other,auto_xattr"],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                print(f"{Colors.GREEN}✅ Диск смонтирован: {mount_point}{Colors.END}")
                print(f"{Colors.GREEN}📝 Чтение и ЗАПИСЬ доступны!{Colors.END}")
                return True
            else:
                print(f"{Colors.RED}❌ Ошибка монтирования: {result.stderr}{Colors.END}")
                return False
                
        except Exception as e:
            print(f"{Colors.RED}❌ Ошибка: {e}{Colors.END}")
            return False
    
    def unmount(self, device: str) -> bool:
        """Размонтирование диска"""
        try:
            print(f"{Colors.BLUE}🔌 Размонтирование /dev/{device}{Colors.END}")
            
            result = subprocess.run(
                ["sudo", "umount", f"/dev/{device}"],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                print(f"{Colors.GREEN}✅ Диск размонтирован{Colors.END}")
                return True
            else:
                # Попробуем diskutil
                result2 = subprocess.run(
                    ["diskutil", "unmount", f"/dev/{device}"],
                    capture_output=True,
                    text=True
                )
                if result2.returncode == 0:
                    print(f"{Colors.GREEN}✅ Диск размонтирован{Colors.END}")
                    return True
                else:
                    print(f"{Colors.RED}❌ Ошибка размонтирования{Colors.END}")
                    return False
        except Exception as e:
            print(f"{Colors.RED}❌ Ошибка: {e}{Colors.END}")
            return False
    
    def format_ntfs(self, device: str, label: str = "Untitled") -> bool:
        """Форматирование диска в NTFS"""
        try:
            print(f"{Colors.YELLOW}⚠️  ВНИМАНИЕ! Все данные на /dev/{device} будут уничтожены!{Colors.END}")
            confirm = input("Продолжить? (yes/no): ")
            
            if confirm.lower() != "yes":
                print("❌ Отменено")
                return False
            
            result = subprocess.run(
                ["sudo", "/usr/local/bin/mkntfs", "-f", "-L", label, f"/dev/{device}"],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                print(f"{Colors.GREEN}✅ Диск отформатирован в NTFS{Colors.END}")
                return True
            else:
                print(f"{Colors.RED}❌ Ошибка форматирования: {result.stderr}{Colors.END}")
                return False
        except Exception as e:
            print(f"{Colors.RED}❌ Ошибка: {e}{Colors.END}")
            return False

def print_disks(disks: List[dict]):
    """Красивый вывод списка дисков"""
    print(f"\n{Colors.BLUE}💾 Доступные диски:{Colors.END}\n")
    
    for disk in disks:
        print(f"Disk: {disk['device']} ({disk['size'] / 1024 / 1024 / 1024:.1f} GB)")
        
        for part in disk['partitions']:
            fs_color = Colors.GREEN if part['filesystem'] == 'Windows_NTFS' else Colors.YELLOW
            mount_status = f"📂 {part['mount_point']}" if part['mounted'] else "📦 Не смонтирован"
            
            print(f"  └─ {part['device']} | {fs_color}{part['filesystem']}{Colors.END} | {mount_status}")
            if part['volume_name']:
                print(f"     Название: {part['volume_name']}")
        print()

def main():
    parser = argparse.ArgumentParser(
        description=f"NTFS Driver for macOS v{VERSION} - Альтернатива Paragon NTFS",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Примеры использования:
  %(prog)s list                    # Показать все диски
  %(prog)s mount disk2s1           # Монтировать NTFS диск
  %(prog)s unmount disk2s1         # Размонтировать диск
  %(prog)s format disk2 MyDisk     # Форматировать в NTFS
        """
    )
    
    parser.add_argument("--version", action="version", version=f"%(prog)s {VERSION}")
    
    subparsers = parser.add_subparsers(dest="command", help="Команды")
    
    # List
    list_parser = subparsers.add_parser("list", help="Показать список дисков")
    
    # Mount
    mount_parser = subparsers.add_parser("mount", help="Монтировать NTFS диск")
    mount_parser.add_argument("device", help="Устройство (например: disk2s1)")
    mount_parser.add_argument("--path", help="Точка монтирования (опционально)")
    
    # Unmount
    unmount_parser = subparsers.add_parser("unmount", help="Размонтировать диск")
    unmount_parser.add_argument("device", help="Устройство (например: disk2s1)")
    
    # Format
    format_parser = subparsers.add_parser("format", help="Форматировать в NTFS")
    format_parser.add_argument("device", help="Устройство (например: disk2)")
    format_parser.add_argument("--label", default="Untitled", help="Метка диска")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    manager = NTFSManager()
    
    if args.command == "list":
        disks = manager.list_disks()
        print_disks(disks)
    
    elif args.command == "mount":
        success = manager.mount_ntfs(args.device, args.path)
        sys.exit(0 if success else 1)
    
    elif args.command == "unmount":
        success = manager.unmount(args.device)
        sys.exit(0 if success else 1)
    
    elif args.command == "format":
        success = manager.format_ntfs(args.device, args.label)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
