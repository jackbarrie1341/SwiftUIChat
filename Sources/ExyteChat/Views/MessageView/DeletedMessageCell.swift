//
//  DeletedMessageCell.swift
//  ExyteChat — FocusGroup custom message type
//

import SwiftUI

struct DeletedMessageCell: View {

    @Environment(\.chatTheme) var theme

    let message: Message

    var body: some View {
        HStack {
            if message.user.isCurrentUser { Spacer() }
            Text("This message was deleted")
                .font(.caption)
                .italic()
                .foregroundColor(theme.colors.mainText.opacity(0.35))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            if !message.user.isCurrentUser { Spacer() }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 2)
    }
}
