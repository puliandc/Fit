//
//  DialogManager.swift
//  Fit
//
//  Created by Jason Lu on 15:10:00 10/14/2025.
//

import SwiftUI
import Combine

// MARK: - Dialog Manager
// 专门负责对话框状态管理，从NavigationManager中分离出来
class DialogManager: ObservableObject {
    @Published var presentedDialog: DialogType?

    init() {
        print("🎯 DialogManager initialized")
    }

    // MARK: - Dialog Methods
    func presentDialog(_ dialog: DialogType) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentedDialog = dialog
        }
    }

    func dismissDialog() {
        withAnimation(.easeInOut(duration: 0.2)) {
            presentedDialog = nil
        }
    }
}