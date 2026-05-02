import SwiftUI

struct EventCardView: View {
    let event: CountdownEvent
    let edit: () -> Void
    let addWidget: () -> Void
    let toggleFavorite: () -> Void
    let delete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(event.color)
                    .frame(height: 64)
                Button(action: toggleFavorite) {
                    Image(systemName: event.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(event.color)
                        .frame(width: 58, height: 58)
                        .background(Circle().fill(.white))
                }
                .buttonStyle(.plain)
                .offset(x: -16, y: 18)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: event.icon)
                        .font(.title2)
                        .foregroundStyle(event.color)
                    Spacer()
                    Text(event.targetDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(event.title)
                    .font(.system(size: 23, weight: .bold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(event.relativeText())
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(event.color)

                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack {
                    Button("편집", action: edit)
                    Button("위젯 추가", action: addWidget)
                    Spacer()
                    Button(role: .destructive, action: delete) {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }
}
