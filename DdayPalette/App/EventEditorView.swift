import SwiftUI

struct EventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: CountdownEvent
    let onSave: (CountdownEvent) -> Void

    init(event: CountdownEvent?, onSave: @escaping (CountdownEvent) -> Void) {
        _draft = State(initialValue: event ?? CountdownEvent(title: "", targetDate: Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now))
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text(draft.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000") ? "D-day 만들기" : "D-day 편집")
                .font(.largeTitle.bold())
                .hidden()
                .frame(height: 0)

            HStack(alignment: .top, spacing: 22) {
                preview

                Form {
                    TextField("시험명", text: $draft.title)
                    DatePicker("시험일", selection: $draft.targetDate, displayedComponents: .date)
                    Picker("아이콘", selection: $draft.icon) {
                        ForEach(CountdownPalette.symbols, id: \.self) { symbol in
                            Label(symbol, systemImage: symbol).tag(symbol)
                        }
                    }
                    Toggle("중요 표시", isOn: $draft.isFavorite)

                    Section("색상") {
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(34), spacing: 10), count: 8), spacing: 10) {
                            ForEach(CountdownPalette.colors, id: \.hex) { item in
                                Button {
                                    draft.colorHex = item.hex
                                } label: {
                                    Circle()
                                        .fill(Color(hex: item.hex))
                                        .frame(width: 30, height: 30)
                                        .overlay {
                                            if draft.colorHex == item.hex {
                                                Image(systemName: "checkmark")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                }
                                .buttonStyle(.plain)
                                .help(item.name)
                            }
                        }
                    }

                    TextField("메모", text: $draft.notes, axis: .vertical)
                        .lineLimit(3...5)
                }
                .formStyle(.grouped)
                .frame(width: 390)
            }

            HStack {
                Spacer()
                Button("취소") { dismiss() }
                Button("저장") {
                    var event = draft
                    if event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        event.title = "새 자격증"
                    }
                    onSave(event)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 720)
    }

    private var preview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("미리보기")
                .font(.headline)
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(draft.color)
                Circle()
                    .fill(.white)
                    .frame(width: 76, height: 76)
                    .overlay {
                        Image(systemName: draft.icon)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(draft.color)
                    }
                    .padding(22)

                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    Text(draft.title.isEmpty ? "한능검" : draft.title)
                        .font(.system(size: 31, weight: .black))
                        .lineLimit(2)
                    Text(draft.relativeText())
                        .font(.system(size: 31, weight: .black))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(28)
            }
            .frame(width: 250, height: 250)
        }
    }
}
