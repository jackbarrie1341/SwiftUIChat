//
//  ChatMessageView.swift
//  
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI

struct ChatMessageView<MessageContent: View>: View {

    typealias MessageBuilderClosure = ChatView<MessageContent, EmptyView, DefaultMessageMenuAction>.MessageBuilderClosure

    @ObservedObject var viewModel: ChatViewModel

    var messageBuilder: MessageBuilderClosure?

    let row: MessageRow
    let chatType: ChatType
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let messageStyler: (String) -> AttributedString
    let shouldShowLinkPreview: (URL) -> Bool
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool
    let messageLinkPreviewLimit: Int
    let messageFont: UIFont

    // Closures for FocusGroup custom actions
    var onVerify: ((String) async -> Void)?
    var onPhotoTap: ((Message) -> Void)?

    var body: some View {
        Group {
            // Handle deleted messages first
            if row.message.isDeleted {
                DeletedMessageCell(message: row.message)
            }
            // Handle custom message types (FocusGroup)
            else if row.message.messageType == .system {
                SystemMessageCell(message: row.message)
            }
            else if row.message.messageType == .verification {
                VerificationMessageCell(
                    message: row.message,
                    isCurrentUser: row.message.user.isCurrentUser,
                    avatarSize: avatarSize,
                    onVerify: row.message.completionId != nil ? {
                        await onVerify?(row.message.completionId!)
                    } : nil,
                    onPhotoTap: { onPhotoTap?(row.message) }
                )
            }
            else if row.message.messageType == .checkin {
                CheckinMessageCell(
                    message: row.message,
                    avatarSize: avatarSize
                )
            }
            // Custom message builder (user-provided)
            else if let messageBuilder = messageBuilder {
                messageBuilder(
                    row.message,
                    row.positionInUserGroup,
                    row.positionInMessagesSection,
                    row.commentsPosition,
                    { viewModel.messageMenuRow = row },
                    viewModel.messageMenuAction()) { attachment in
                        self.viewModel.presentAttachmentFullScreen(attachment)
                    }
            }
            // Default message view
            else {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInUserGroup: row.positionInUserGroup,
                    positionInMessagesSection: row.positionInMessagesSection,
                    chatType: chatType,
                    avatarSize: avatarSize,
                    tapAvatarClosure: tapAvatarClosure,
                    messageStyler: messageStyler,
                    shouldShowLinkPreview: shouldShowLinkPreview,
                    isDisplayingMessageMenu: isDisplayingMessageMenu,
                    showMessageTimeView: showMessageTimeView,
                    messageLinkPreviewLimit: messageLinkPreviewLimit,
                    font: messageFont)
            }
        }
        .id(row.message.id)
    }
}
