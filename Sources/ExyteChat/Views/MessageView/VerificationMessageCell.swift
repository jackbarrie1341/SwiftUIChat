//
//  VerificationMessageCell.swift
//  ExyteChat — FocusGroup custom message type
//

import SwiftUI

public struct VerificationMessageCell: View {

    @Environment(\.chatTheme) var theme

    let message: Message
    let isCurrentUser: Bool
    let avatarSize: CGFloat
    let onVerify: (() async -> Void)?
    let onPhotoTap: (() -> Void)?

    @State private var isVerifying = false

    private var textColor: Color {
        isCurrentUser ? .white : theme.colors.mainText
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if !isCurrentUser {
                avatarView
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.user.name)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(theme.colors.mainTint)
                        .padding(.horizontal, 4)
                }

                cardContent
            }
            .padding(isCurrentUser ? .leading : .trailing, 60)

            if isCurrentUser {
                Spacer(minLength: 0)
            }
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
            // Photo
            if let photoURL = message.attachments.first?.full {
                CachedAsyncImage(url: photoURL, cacheKey: message.attachments.first?.fullCacheKey) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 200)
                            .clipped()
                    case .empty:
                        Rectangle()
                            .fill(textColor.opacity(0.05))
                            .frame(height: 160)
                            .overlay { ProgressView() }
                    default:
                        Rectangle()
                            .fill(textColor.opacity(0.05))
                            .frame(height: 160)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(textColor.opacity(0.3))
                            }
                    }
                }
                .onTapGesture { onPhotoTap?() }
            }

            VStack(alignment: .leading, spacing: 6) {
                // Habit name
                if let habitName = message.habitName {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 10))
                        Text(habitName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(textColor.opacity(0.7))
                }

                // Caption text
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.subheadline)
                        .foregroundColor(textColor)
                }

                // Status / action
                if message.isVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Verified\(message.verifierName.map { " by \($0)" } ?? "")")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else if !isCurrentUser, let onVerify {
                    Button {
                        guard !isVerifying else { return }
                        isVerifying = true
                        Task {
                            await onVerify()
                            isVerifying = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if isVerifying {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 12))
                            }
                            Text("Verify")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.colors.sendButtonBackground)
                        .cornerRadius(8)
                    }
                    .disabled(isVerifying)
                } else if isCurrentUser {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text("Awaiting verification")
                            .font(.caption)
                    }
                    .foregroundColor(textColor.opacity(0.5))
                }

                // Time
                Text(message.time)
                    .font(.system(size: 10))
                    .foregroundColor(textColor.opacity(0.4))
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isCurrentUser ? theme.colors.messageMyBG : theme.colors.messageFriendBG)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
