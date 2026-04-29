import WidgetKit
import SwiftUI

struct DdayEntry: TimelineEntry {
    let date: Date
    let events: [CountdownEvent]
}

struct DdayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DdayEntry {
        DdayEntry(date: .now, events: CountdownStore.loadForWidget())
    }

    func getSnapshot(in context: Context, completion: @escaping (DdayEntry) -> Void) {
        completion(DdayEntry(date: .now, events: CountdownStore.loadForWidget()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DdayEntry>) -> Void) {
        let entry = DdayEntry(date: .now, events: CountdownStore.loadForWidget())
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct DdayPaletteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DdayEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidget(event: entry.events.first)
        case .systemMedium:
            ListWidget(events: Array(entry.events.prefix(3)), compact: true)
        default:
            ListWidget(events: Array(entry.events.prefix(6)), compact: false)
        }
    }
}

private struct SmallWidget: View {
    let event: CountdownEvent?

    var body: some View {
        if let event {
            ZStack(alignment: .topTrailing) {
                event.color
                Circle()
                    .fill(.white)
                    .frame(width: 58, height: 58)
                    .overlay {
                        Image(systemName: event.icon)
                            .font(.system(size: 27, weight: .bold))
                            .foregroundStyle(event.color)
                    }
                    .padding(16)

                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    Text(event.title)
                        .font(.system(size: 22, weight: .black))
                        .lineLimit(2)
                    Text(event.relativeText())
                        .font(.system(size: 22, weight: .black))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
            }
            .containerBackground(event.color, for: .widget)
        } else {
            ContentUnavailableView("D-day 없음", systemImage: "calendar.badge.plus")
                .containerBackground(.background, for: .widget)
        }
    }
}

private struct ListWidget: View {
    let events: [CountdownEvent]
    let compact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 10) {
            HStack {
                Text("D-day")
                    .font(.headline.bold())
                Spacer()
                Text("\(events.count)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(.secondary.opacity(0.15)))
            }

            if events.isEmpty {
                Spacer()
                Label("앱에서 시험일을 추가하세요", systemImage: "plus.circle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(events) { event in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(event.color)
                            .frame(width: compact ? 9 : 12)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.system(size: compact ? 14 : 16, weight: .bold))
                                .lineLimit(1)
                            Text(event.targetDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                        Text(event.relativeText())
                            .font(.system(size: compact ? 15 : 18, weight: .black))
                            .foregroundStyle(event.color)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(height: compact ? 42 : 48)
                }
                Spacer(minLength: 0)
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

struct DdayPaletteWidget: Widget {
    let kind = "DdayPaletteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DdayProvider()) { entry in
            DdayPaletteWidgetView(entry: entry)
        }
        .configurationDisplayName("Dday Palette")
        .description("자격증 시험일까지 남은 날짜를 색상 카드로 보여줍니다.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
