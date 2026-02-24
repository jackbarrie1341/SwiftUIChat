//
//  SystemMessageCell.swift
//  ExyteChat — FocusGroup custom message type
//

import SwiftUI

struct SystemMessageCell: View {

    @Environment(\.chatTheme) var theme

    let message: Message

    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .font(.caption)
                .foregroundColor(theme.colors.mainText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.colors.mainText.opacity(0.06))
                )
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
