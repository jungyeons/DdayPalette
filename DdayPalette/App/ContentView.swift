import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject private var store: CountdownStore
    @State private var selection: SidebarItem = .all
    @State private var searchText = ""
    @State private var editingEvent: CountdownEvent?
    @State private var isAddingEvent = false

    private var visibleEvents: [CountdownEvent] {
        let filtered: [CountdownEvent]
        switch selection {
        case .all:
            filtered = store.events
        case .upcoming:
            filtered = store.events.filter { $0.daysRemaining() >= 0 }
        case .favorites:
            filtered = store.events.filter(\.isFavorite)
        case .past:
            filtered = store.events.filter { $0.daysRemaining() < 0 }
        }

        guard !searchText.isEmpty else { return filtered.sortedForDisplay() }
        return filtered
            .filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.notes.localizedCaseInsensitiveContains(searchText) }
            .sortedForDisplay()
    }

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                Label(item.title, systemImage: item.symbol)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 210, ideal: 240)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        isAddingEvent = true
                    } label: {
                        Label("D-day 만들기", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)

                    Text("\(store.events.count)개의 기록")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        } detail: {
            VStack(spacing: 0) {
                toolbar
                if visibleEvents.isEmpty {
                    ContentUnavailableView("기록이 없습니다", systemImage: "calendar.badge.plus", description: Text("오른쪽 위 + 버튼으로 자격증 시험일을 추가하세요."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260, maximum: 360), spacing: 20)], spacing: 20) {
                            ForEach(visibleEvents) { event in
                                EventCardView(event: event) {
                                    editingEvent = event
                                } toggleFavorite: {
                                    store.toggleFavorite(event)
                                    WidgetCenter.shared.reloadAllTimelines()
                                } delete: {
                                    store.delete(event)
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "검색")
        .sheet(isPresented: $isAddingEvent) {
            EventEditorView(event: nil) { event in
                store.upsert(event)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .sheet(item: $editingEvent) { event in
            EventEditorView(event: event) { updated in
                store.upsert(updated)
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    private var toolbar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(selection.title)
                    .font(.system(size: 30, weight: .bold))
                Text("자격증 시험일을 색상 카드와 데스크탑 위젯으로 관리합니다.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                isAddingEvent = true
            } label: {
                Label("추가", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: [.command])
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(.bar)
    }
}

private enum SidebarItem: String, CaseIterable, Identifiable {
    case all
    case upcoming
    case favorites
    case past

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "전체"
        case .upcoming: "다가오는 시험"
        case .favorites: "중요"
        case .past: "지난 기록"
        }
    }

    var symbol: String {
        switch self {
        case .all: "tray.full.fill"
        case .upcoming: "calendar"
        case .favorites: "heart.fill"
        case .past: "clock.arrow.circlepath"
        }
    }
}
