//
//  CheckinMessageCell.swift
//  ExyteChat — FocusGroup custom message type
//

import SwiftUI

public struct CheckinMessageCell: View {

    @Environment(\.chatTheme) var theme

    let message: Message
    let avatarSize: CGFloat

    public var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                // Username above the card
                Text(message.user.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(theme.colors.mainTint)
                    .padding(.horizontal, 4)

                cardContent
            }
            .padding(.trailing, 60)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let url = message.user.avatarURL {
            CachedAsyncImage(url: url, cacheKey: message.user.avatarCacheKey) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Circle().fill(theme.colors.mainText.opacity(0.1))
                }
            }
            .frame(width: avatarSize, height: avatarSize)
            .clipShape(Circle())
            .padding(.trailing, 8)
        } else {
            AvatarNameView(name: message.user.name, avatarSize: avatarSize)
                .padding(.trailing, 8)
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: "Day X - Check In" + time
            HStack {
                if let dayNumber = message.dayNumber {
                    Text("Day \(dayNumber) - Check In")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.mainText)
                } else {
                    Text("Check In")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.mainText)
                }

                Spacer()

                Text(message.time)
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.mainText.opacity(0.4))
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Divider()
                .background(theme.colors.mainText.opacity(0.08))

            // Habit lines
            if let lines = message.checkinLines {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        HStack(spacing: 8) {
                            Image(systemName: line.completed ? "checkmark.circle.fill" : "xmark.circle")
                                .font(.system(size: 14))
                                .foregroundColor(line.completed ? .green : theme.colors.mainText.opacity(0.3))

                            Text(line.habitName)
                                .font(.caption)
                                .foregroundColor(theme.colors.mainText)

                            if let value = line.value {
                                Spacer()
                                Text(value)
                                    .font(.caption2)
                                    .foregroundColor(theme.colors.mainText.opacity(0.5))
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            } else if !message.text.isEmpty {
                // Fallback: show raw text
                Text(message.text)
                    .font(.caption)
                    .foregroundColor(theme.colors.mainText)
                    .padding(12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.colors.messageFriendBG)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
