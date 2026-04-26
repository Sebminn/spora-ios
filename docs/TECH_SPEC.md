# Spora — Техническое ТЗ

## 1. Стек и платформа

- **Платформа:** iOS, нативное приложение.
- **Язык:** Swift 5.9+.
- **UI-фреймворк:** SwiftUI (UIKit — только при необходимости интероп).
- **Минимальная версия iOS:** 17.0.
- **Целевые устройства:** iPhone (iPad — не поддерживается в MVP).
- **IDE:** Xcode 15+.
- **Менеджер зависимостей:** Swift Package Manager.
- **Архитектура:** MVVM + Coordinator (или NavigationStack-based навигация SwiftUI).

## 2. Внешние зависимости

В MVP стремимся к минимуму внешних зависимостей. Допустимо без них вообще.

- **UserNotifications** (системный фреймворк) — для локальных push-уведомлений.
- **SwiftData** — для локального хранения пользовательского расписания (iOS 17+).
- **Combine / Swift Concurrency (async/await)** — для асинхронных операций.

## 3. Архитектура

### 3.1. Слои

1. **Presentation (SwiftUI Views + ViewModels)** — экраны и состояние UI.
2. **Domain (Use cases / Services)** — бизнес-логика (планирование уведомлений, работа с расписанием).
3. **Data** — два источника:
   - **CatalogRepository** — статический каталог БАДов из бандла (JSON).
   - **ScheduleRepository** — пользовательское расписание (SwiftData).
4. **Infrastructure** — обёртки над системными API (UserNotifications).

### 3.2. Ключевые сервисы

- `NotificationService` — планирование, отмена и обновление локальных уведомлений через `UNUserNotificationCenter`.
- `ScheduleService` — CRUD пользовательского расписания, синхронизация с `NotificationService`.
- `CatalogService` — загрузка и доступ к каталогу БАДов.

## 4. Модель данных

### 4.1. Каталог БАДов (статический, в бандле)

Файл `catalog.json` в ресурсах приложения:

```json
[
  {
    "id": "reishi",
    "nameRu": "Рейши",
    "nameLat": "Ganoderma lucidum",
    "imageAsset": "reishi",
    "description": "...",
    "intake": {
      "dosage": "500 мг",
      "withFood": true,
      "preferredTime": ["morning", "evening"]
    },
    "contraindications": "...",
    "courseDays": 60
  }
]
```

Swift-модель:

```swift
struct Supplement: Codable, Identifiable {
    let id: String
    let nameRu: String
    let nameLat: String
    let imageAsset: String
    let description: String
    let intake: IntakeRecommendation
    let contraindications: String?
    let courseDays: Int?
}

struct IntakeRecommendation: Codable {
    let dosage: String
    let withFood: Bool
    let preferredTime: [PreferredTime]
}

enum PreferredTime: String, Codable {
    case morning, day, evening, night
}
```

### 4.2. Пользовательское расписание (локальная БД)

Сущность `UserSchedule` (SwiftData):

| Поле          | Тип                | Описание                                      |
|---------------|--------------------|-----------------------------------------------|
| id            | UUID               | Идентификатор записи расписания               |
| supplementId  | String             | id из каталога                                 |
| times         | [Date components]  | Список времён приёма (часы:минуты)             |
| weekdays      | Set\<Int\>         | Дни недели (1–7), пусто = все дни              |
| isEnabled     | Bool               | Активно ли расписание                          |
| createdAt     | Date               | Дата создания                                  |

Пример SwiftData-модели:

```swift
@Model
final class UserSchedule {
    @Attribute(.unique) var id: UUID
    var supplementId: String
    var timesData: Data        // сериализованный [DateComponents]
    var weekdays: [Int]
    var isEnabled: Bool
    var createdAt: Date
}
```

### 4.3. Глобальные настройки

Хранятся в `UserDefaults`:

- `notificationsEnabled: Bool` — общий тумблер.

> **Примечание.** Тихие часы вынесены за пределы MVP. Пользователи могут использовать системный режим Focus в iOS для глушения уведомлений в нужные интервалы.

## 5. Уведомления

### 5.1. Разрешение

- При первом запуске после онбординга — `UNUserNotificationCenter.requestAuthorization(options: [.alert, .sound, .badge])`.
- Если отказали — показываем мягкую подсказку в настройках с диплинком в системные настройки.

### 5.2. Планирование

- Для каждой записи `UserSchedule` создаётся набор `UNNotificationRequest`.
- Триггер: `UNCalendarNotificationTrigger` с `repeats: true`.
- На каждое сочетание (день недели × время) — отдельный request с уникальным identifier формата `schedule-<scheduleId>-<weekday>-<HHmm>`.
- Контент уведомления:
  - title: «Время принять {название БАДа}».
  - body: подсказка по приёму (например, «С едой» или «Натощак»).
  - userInfo: `["supplementId": "reishi"]` — для навигации по тапу.

### 5.3. Лимит iOS

- iOS позволяет максимум **64 локальных уведомления** в очереди одновременно.
- В MVP не должно быть проблемы (типичный пользователь — 2–5 БАДов × 1–3 времени × 7 дней = до ~100 — потенциально может быть превышение).
- **Решение:** использовать триггеры с `repeats: true` (один request на пару weekday+time даёт одну запись в очереди — не умножается на даты).

### 5.4. Обработка тапа

- Реализовать `UNUserNotificationCenterDelegate`.
- В `didReceive response` — извлечь `supplementId` и через координатор навигации открыть экран БАДа.

## 6. Экраны и навигация

### 6.1. Список экранов (MVP)

1. **Onboarding** (3–4 страницы) — только при первом запуске.
2. **Главная / «Мои БАДы»** — список добавленных БАДов с ближайшим приёмом.
3. **Каталог БАДов** — список всех БАДов из справочника.
4. **Карточка БАДа** — детальная информация + кнопка «Добавить в мой режим».
5. **Редактор расписания** — выбор времени и дней недели.
6. **Настройки** — общий тумблер уведомлений, ссылка на политику конфиденциальности.

### 6.2. Навигация

- TabView с двумя вкладками: «Мои БАДы», «Каталог».
- Шестерёнка настроек в правом верхнем углу.
- Переходы — через `NavigationStack`.

## 7. Структура проекта

```
Spora/
├── App/
│   └── SporaApp.swift
├── Features/
│   ├── Onboarding/
│   ├── MySupplements/
│   ├── Catalog/
│   ├── SupplementDetail/
│   ├── ScheduleEditor/
│   └── Settings/
├── Core/
│   ├── Models/
│   ├── Services/
│   │   ├── NotificationService.swift
│   │   ├── ScheduleService.swift
│   │   └── CatalogService.swift
│   ├── Persistence/
│   └── Navigation/
├── Resources/
│   ├── catalog.json
│   ├── Assets.xcassets
│   └── Localizable.strings
└── Tests/
```

## 8. Нефункциональные требования

- **Производительность:** холодный старт ≤ 2 с на iPhone 12.
- **Оффлайн:** приложение работает полностью без интернета.
- **Локализация:** только русский язык в MVP, но все строки — через `Localizable.strings` для будущей локализации.
- **Доступность:** поддержка Dynamic Type, VoiceOver-метки на основных контролах.
- **Тёмная тема:** поддержка системной тёмной темы.
- **Приватность:** приложение не собирает персональных данных, не имеет аналитики в MVP. В `Info.plist` — соответствующие декларации.

## 9. Тестирование

- **Unit-тесты:** `ScheduleService`, `NotificationService` (планирование/отмена), парсинг каталога.
- **UI-тесты:** базовые сценарии (добавить БАД, открыть карточку, изменить настройки) — на этапе предрелиза.
- **Ручное тестирование push-уведомлений:** на физическом устройстве (симулятор не всегда корректно отрабатывает реальные триггеры в фоне).

## 10. Релиз и распространение

- Распространение через App Store.
- Для распространения нужен Apple Developer Program (99 USD/год).
- TestFlight для бета-тестирования с покупателями основного продукта.
- Минимальная заявка на App Store Review требует:
  - иконку приложения;
  - скриншоты под все размеры iPhone;
  - описание и ключевые слова;
  - политику конфиденциальности (страница в интернете).

## 11. Зафиксированные решения

| # | Вопрос                          | Решение                                                                                                  |
|---|---------------------------------|----------------------------------------------------------------------------------------------------------|
| 1 | Объём каталога                  | 3–5 ключевых БАДов на старте; остальные — в обновлениях                                                  |
| 2 | Контент карточек                | Заглушки готовит исполнитель на основе общедоступной информации; владелец продукта переписывает позже    |
| 3 | Дизайн                          | Figma kit **MediMinder — PillReminderApp** by Sana Nassani (CC BY 4.0). Бренд-гайд — см. `docs/BRAND.md`. Атрибуция автора обязательна в разделе «О приложении» |
| 4 | Тихие часы                      | Из MVP исключены; пользователи используют системный Focus Mode iOS                                       |
| 5 | Минимальная версия iOS          | iOS 17.0 + SwiftData                                                                                     |
| 6 | Политика конфиденциальности     | Размещается на сайте основного продукта (URL подставляется перед сабмитом в App Store)                   |
