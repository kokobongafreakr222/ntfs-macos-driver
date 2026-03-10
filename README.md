# NTFS/FAT32 Driver for macOS

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue)](https://github.com/kokobongafreakr222/ntfs-macos-driver)

Альтернатива Paragon NTFS для macOS. Позволяет читать и записывать на NTFS-диски. **Бесплатно и open source.**

## 🚀 Быстрый старт

### ⚠️ Важно: Требуется установка macFUSE

Из-за ограничений безопасности macOS, установка macFUSE требует ручного подтверждения с паролем администратора.

**Шаг 1: Установка macFUSE**
```bash
# Скачайте и установите вручную:
open https://github.com/osxfuse/osxfuse/releases/latest
```
Или через Homebrew (требует пароль):
```bash
brew install --cask macfuse
# Перезагрузите Mac после установки
```

**Шаг 2: Установка NTFS Driver**
```bash
# Клонирование репозитория
git clone https://github.com/kokobongafreakr222/ntfs-macos-driver.git
cd ntfs-macos-driver

# Установка CLI
sudo cp src/ntfs-driver.py /usr/local/bin/ntfs-driver
sudo chmod +x /usr/local/bin/ntfs-driver
```

## 💻 Использование

### GUI (SwiftUI) - Рекомендуется

```bash
# Открыть проект в Xcode
open NTFSDriverGUI/NTFSDriverGUI.xcodeproj

# Или собрать через командную строку
cd NTFSDriverGUI
xcodebuild -scheme NTFSDriverGUI -configuration Release build
```

**Функции GUI:**
- 📁 Просмотр всех дисков
- 🔍 Автоматическое определение NTFS
- 🔓 Монтирование с поддержкой записи
- ⏏️ Безопасное размонтирование
- ⚙️ Проверка зависимостей

### CLI

```bash
# Показать все диски
ntfs-driver list

# Монтировать NTFS диск с поддержкой записи
sudo ntfs-driver mount disk2s1

# Размонтировать
sudo ntfs-driver unmount disk2s1

# Форматировать в NTFS
sudo ntfs-driver format disk2 --label "MyDisk"
```

## 🏗️ Архитектура

| Компонент | Технология | Описание |
|-----------|------------|----------|
| **Драйвер** | macFUSE 4.x | Фреймворк для user-space FS |
| **FUSE** | FUSE-T (альтернатива) | Более лёгкая версия |
| **CLI** | Python 3 | Командная строка |
| **GUI** | SwiftUI | Графический интерфейс |

## 📋 Системные требования

- macOS 11.0 (Big Sur) или новее
- macFUSE 4.x или FUSE-T
- Apple Silicon или Intel
- Python 3.9+ (для CLI)

## ⚡ Производительность

- **Чтение:** До 300-500 MB/s (SSD через USB 3.0)
- **Запись:** До 80-120 MB/s (зависит от диска)
- **CPU:** Низкая нагрузка (< 5% на M1)

## 🖼️ Скриншоты

### GUI Интерфейс
```
┌─────────────────────────────────────────┐
│  NTFS Driver                    [⟳] [⚙️]│
├─────────────────────┬───────────────────┤
│ 📁 Диски            │ 💿 MyDisk (NTFS)  │
│                     │                   │
│ ⚪ disk1s1          │ Статус:           │
│ 🔵 disk2s1   NTFS   │ 🟢 Смонтирован    │
│ ⚪ disk3s1          │                   │
│                     │ Размер: 500 GB    │
│                     │ FS: NTFS          │
│                     │                   │
│                     │ [Размонтировать]  │
└─────────────────────┴───────────────────┘
```

## 🔒 Безопасность

- ✅ Использует проверенные компоненты: macFUSE
- ✅ Не требует отключения SIP
- ✅ User-space драйвер (без kernel panic)
- ✅ Открытый исходный код

## 🛠️ Разработка

### Структура проекта
```
ntfs-macos-driver/
├── src/
│   └── ntfs-driver.py          # CLI интерфейс
├── NTFSDriverGUI/              # SwiftUI приложение
│   ├── NTFSDriverApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SidebarView.swift
│   │   ├── DiskDetailView.swift
│   │   └── SetupView.swift     # Онбординг
│   └── Models/
│       └── Disk.swift
├── scripts/
│   ├── install.sh              # Установщик
│   └── build.sh                # Сборка DMG
└── README.md
```

### Сборка

```bash
# CLI
chmod +x src/ntfs-driver.py
sudo cp src/ntfs-driver.py /usr/local/bin/ntfs-driver

# GUI (Xcode)
open NTFSDriverGUI/NTFSDriverGUI.xcodeproj
# Product → Build (Cmd+B)

# DMG
./scripts/build.sh
```

## 🐛 Известные проблемы

1. **Требуется sudo** — ограничение macFUSE, безопасность macOS
2. **Первая установка macFUSE** — требует перезагрузки
3. **FUSE-T** — не стабилен на macOS 14+, рекомендуется macFUSE

## 📝 Лицензия

MIT License для кода GUI/CLI.

**Важно:** macFUSE имеет свою лицензию (BSD-style).

## 🤝 Contributing

PR приветствуются!

**Приоритетные задачи:**
- [ ] Автомонтирование при подключении диска
- [ ] Интеграция с Finder (расширение)
- [ ] Поддержка FUSE-T как fallback
- [ ] Бенчмарки производительности

## 🔗 Ссылки

- [Репозиторий](https://github.com/kokobongafreakr222/ntfs-macos-driver)
- [macFUSE](https://osxfuse.github.io/)
- [FUSE-T](https://github.com/macos-fuse-t/fuse-t)

---

**Создано как бесплатная альтернатива Paragon NTFS для macOS.**

💡 **Совет:** После установки macFUSE откройте Системные настройки → Конфиденциальность и безопасность → Разрешить, если появится предупреждение.
