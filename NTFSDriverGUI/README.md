# NTFS Driver GUI

SwiftUI приложение для управления NTFS дисками на macOS.

## Требования

- macOS 12.0+
- Xcode 14.0+
- macFUSE (устанавливается через install.sh)

## Сборка

```bash
cd NTFSDriverGUI
swift build
```

## Запуск

```bash
swift run NTFSDriverGUI
```

## Архитектура

- **SidebarView** - список дисков
- **DiskDetailView** - информация и управление
- **DiskManager** - бизнес-логика работы с дисками
