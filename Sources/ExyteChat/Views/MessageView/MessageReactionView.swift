//
//  MessageView+Reaction.swift
//  Chat
//

import SwiftUI

struct GroupedReaction: Hashable, Identifiable {
    var id: String { emoji }
    let emoji: String
    let count: Int
    let containsCurrentUser: Bool
    let latestDate: Date
    let isSending: Bool
    let hasError: Bool
}

extension MessageView {

    @ViewBuilder
    func reactionsView(_ message: Message, maxReactions: Int = 5) -> some View {
        let preparedReactions = prepareReactions(message: message, maxReactions: maxReactions)
        let overflowCount = preparedReactions.overflowCount
        let overflowBubbleText = "+\(overflowCount)"

        HStack(spacing: 4) {
            if !message.user.isCurrentUser {
                overflowBubbleView(
                    needsOverflowBubble: preparedReactions.needsOverflowBubble,
                    text: overflowBubbleText,
                    containsReactionFromCurrentUser: preparedReactions.overflowContainsCurrentUser
                )
            }

            ForEach(Array(preparedReactions.groups.enumerated()), id: \.element) { index, group in
                ReactionBubble(group: group, font: Font(font))
                    .transition(.scaleAndFade)
                    .zIndex(message.user.isCurrentUser ? Double(preparedReactions.groups.count - index) : Double(index + 1))
                    .sizeGetter($bubbleSize)
            }

            if message.user.isCurrentUser {
                overflowBubbleView(
                    needsOverflowBubble: preparedReactions.needsOverflowBubble,
                    text: overflowBubbleText,
                    containsReactionFromCurrentUser: preparedReactions.overflowContainsCurrentUser
                )
            }
        }
        .offset(
            x: message.user.isCurrentUser ? -(bubbleSize.height / 2) : (bubbleSize.height / 2),
            y: 0
        )
    }

    @ViewBuilder
    func overflowBubbleView(needsOverflowBubble: Bool, text: String, containsReactionFromCurrentUser: Bool) -> some View {
        if needsOverflowBubble {
            ReactionBubble(
                group: GroupedReaction(
                    emoji: text,
                    count: 1,
                    containsCurrentUser: containsReactionFromCurrentUser,
                    latestDate: .now,
                    isSending: false,
                    hasError: false
                ),
                font: .footnote.weight(.light)
            )
            .padding(message.user.isCurrentUser ? .trailing : .leading, -3)
        }
    }

    struct PreparedReactions {
        let groups: [GroupedReaction]
        let needsOverflowBubble: Bool
        let overflowContainsCurrentUser: Bool
        let overflowCount: Int
    }

    private func prepareReactions(message: Message, maxReactions: Int) -> PreparedReactions {
        guard maxReactions > 1, !message.reactions.isEmpty else {
            return .init(groups: [], needsOverflowBubble: false, overflowContainsCurrentUser: false, overflowCount: 0)
        }

        // group reactions by emoji
        var groupsByEmoji: [String: [Reaction]] = [:]
        for reaction in message.reactions {
            let key = reaction.emoji ?? "?"
            groupsByEmoji[key, default: []].append(reaction)
        }

        // build grouped reactions sorted by most recent reaction date
        var groups: [GroupedReaction] = groupsByEmoji.map { emoji, reactions in
            let latestDate = reactions.map(\.createdAt).max() ?? .distantPast
            let containsCurrentUser = reactions.contains { $0.user.isCurrentUser }
            let isSending = reactions.contains { $0.status == .sending }
            let hasError = reactions.contains {
                if case .error = $0.status { return true }
                return false
            }
            return GroupedReaction(
                emoji: emoji,
                count: reactions.count,
                containsCurrentUser: containsCurrentUser,
                latestDate: latestDate,
                isSending: isSending,
                hasError: hasError
            )
        }
        groups.sort { $0.latestDate > $1.latestDate }

        let needsOverflowBubble = groups.count > maxReactions
        var overflowContainsCurrentUser = false
        var overflowCount = 0

        if needsOverflowBubble {
            let overflowGroups = groups[min(groups.count, maxReactions - 1)...]
            overflowContainsCurrentUser = overflowGroups.contains { $0.containsCurrentUser }
            overflowCount = overflowGroups.reduce(0) { $0 + $1.count }
            groups = Array(groups.prefix(maxReactions - 1))
        }

        return .init(
            groups: message.user.isCurrentUser ? groups : groups.reversed(),
            needsOverflowBubble: needsOverflowBubble,
            overflowContainsCurrentUser: overflowContainsCurrentUser,
            overflowCount: overflowCount
        )
    }
}

struct ReactionBubble: View {

    @Environment(\.chatTheme) var theme

    let group: GroupedReaction
    let font: Font

    @State private var phase = 0.0

    var fillColor: Color {
        if group.hasError {
            return .red
        }
        return group.containsCurrentUser ? theme.colors.messageMyBG : theme.colors.messageFriendBG
    }

    var opacity: Double {
        if group.isSending || group.hasError {
            return 0.7
        }
        return 1.0
    }

    var body: some View {
        Text(group.count > 1 ? "\(group.emoji) \(group.count)" : group.emoji)
            .font(font)
            .opacity(opacity)
            .padding(.horizontal, group.count > 1 ? 8 : 6)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    Capsule()
                        .fill(fillColor)
                    if group.isSending {
                        Capsule()
                            .stroke(style: .init(lineWidth: 2, lineCap: .round, dash: [100, 50], dashPhase: phase))
                            .fill(theme.colors.messageFriendBG)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
                                    phase -= 150
                                }
                            }
                    } else {
                        Capsule()
                            .stroke(style: .init(lineWidth: 2))
                            .fill(theme.colors.mainBG)
                    }
                }
            )
    }
}
