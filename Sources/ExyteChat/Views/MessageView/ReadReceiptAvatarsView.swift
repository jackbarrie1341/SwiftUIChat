//
//  ReadReceiptAvatarsView.swift
//  ExyteChat — FocusGroup read receipts (Instagram group chat style)
//

import SwiftUI

/// Shows small user avatars below the last message each user has read.
public struct ReadReceiptAvatarsView: View {

    let readers: [User]  // Users who have read up to this message

    public init(readers: [User]) {
        self.readers = readers
    }

    public var body: some View {
        if !readers.isEmpty {
            HStack(spacing: -4) {
                ForEach(readers, id: \.id) { user in
                    if let url = user.avatarURL {
                        CachedAsyncImage(url: url, cacheKey: user.avatarCacheKey) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                        }
                        .frame(width: 16, height: 16)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    } else {
                        Text(String(user.name.prefix(1)).uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Color.gray))
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
            }
            .padding(.top, 2)
        }
    }
}
