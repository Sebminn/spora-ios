# Spora

iOS-приложение для напоминаний о приёме грибных БАДов. Бесплатное, дополнение к основному продукту.

См. также:
- [docs/PRD.md](docs/PRD.md) — продуктовое ТЗ
- [docs/TECH_SPEC.md](docs/TECH_SPEC.md) — техническое ТЗ
- [docs/BRAND.md](docs/BRAND.md) — бренд-гайд

## Стек

- Swift 5.9, SwiftUI
- iOS 17.0+
- SwiftData (локальное хранилище)
- UserNotifications (локальные пуши)

## Структура

```
Spora/
├── App/                  точка входа и корневой экран
├── Core/
│   ├── DesignSystem/     палитра, шрифты, spacing/radii
│   ├── Models/           Supplement, UserSchedule
│   └── Services/         Catalog, Notification, Schedule
├── Features/             экраны (Onboarding, MySupplements, Catalog, …)
└── Resources/            catalog.json, Info.plist
```

## Сборка проекта (на macOS)

`.xcodeproj` не закоммичен в репозиторий — он генерируется из `project.yml` через [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
xcodegen
open Spora.xcodeproj
```

## Шрифты

В `Spora/Resources/Fonts/` нужно положить (скачать с [Google Fonts](https://fonts.google.com)):

- `Onest-Regular.ttf`, `Onest-SemiBold.ttf`, `Onest-Bold.ttf`
- `Fraunces-SemiBold.ttf`

Если шрифты не подключены, дизайн-система автоматически использует системный SF Pro как fallback (см. [Font+Spora.swift](Spora/Core/DesignSystem/Font+Spora.swift)).

## Что работает в текущем скелете

- Каркас навигации: Onboarding → TabView (Мои БАДы / Каталог).
- Экран каталога с тремя БАДами (Чага, Львиная грива, Кордицепс).
- Карточка БАДа с описанием, инструкцией, противопоказаниями.
- Редактор расписания (время + дни недели), сохранение в SwiftData.
- Локальные уведомления `UNCalendarNotificationTrigger` с `repeats: true`.
- Настройки с тумблером уведомлений и атрибуцией дизайна.

## Что не сделано (намеренно, см. PRD §6)

- Курсы приёма с циклами, дневник самочувствия, статистика.
- Виджеты, Apple Watch, Apple Health.
- Тихие часы (используется системный Focus Mode iOS).
- Иллюстрации БАДов — пока SF Symbol `leaf.fill` как заглушка.

## Атрибуция

Дизайн на основе [MediMinder UI Kit](https://www.figma.com/community/file/1373636997429151322/mediminder-pillreminderapp) by **Sana Nassani**, лицензия CC BY 4.0.
