import UIKit

extension ChatViewController {
    func checkIfChatHasActiveCall() {
        if chatRoom.ownPrivilege == .standard || chatRoom.ownPrivilege == .moderator {
            if (MEGASdkManager.sharedMEGAChatSdk().hasCall(inChatRoom: chatRoom.chatId)),
                MEGAReachabilityManager.isReachable() {
                let call = MEGASdkManager.sharedMEGAChatSdk().chatCall(forChatId: chatRoom.chatId)
                if !chatRoom.isGroup && call?.status == .destroyed {
                    return
                }
                if MEGASdkManager.sharedMEGAChatSdk().chatCalls(withState: .inProgress)?.size == 1 && call?.status != .inProgress {
                    self.hideTopBannerButton()
                } else {
                    if call?.status == .inProgress {
                        configureTopBannerButtonForInProgressCall(call!)
                    } else if call?.status == .userNoPresent
                                || call?.status == .requestSent
                                || call?.status == .ringIn {
                        configureTopBannerButtonForActiveCall(call!)
                    } else if call?.status == .reconnecting {
                        setTopBannerButton(title: NSLocalizedString("Reconnecting...", comment: "Title shown when the user lost the connection in a call, and the app will try to reconnect the user again."), color: UIColor.systemOrange)
                        showTopBannerButton()
                    }
                }
            } else {
                hideTopBannerButton()
            }
        }
    }

    private func setTopBannerButton(title: String, color: UIColor) {
        topBannerButton.backgroundColor = color
        topBannerButton.setTitle(title, for: .normal)
    }

    private func showTopBannerButton() {
        if topBannerButton.isHidden {
            topBannerButton.isHidden = false
            view.layoutIfNeeded()

            topBannerButtonTopConstraint?.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    private func hideTopBannerButton() {
        if !topBannerButton.isHidden {
            view.layoutIfNeeded()

            topBannerButtonTopConstraint?.constant = -44
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { finished in
                if finished {
                    self.topBannerButton.isHidden = true
                }
            }
        }
    }

    private func initTimerForCall(_ call: MEGAChatCall) {
        initDuration = TimeInterval(call.duration)
        if let initDuration = initDuration, !(timer?.isValid ?? false) {
            let startTime = Date().timeIntervalSince1970
            let time = Date().timeIntervalSince1970 - startTime + initDuration

            setTopBannerButton(title: String(format: NSLocalizedString("Touch to return to call %@", comment: "Message shown in a chat room for a group call in progress displaying the duration of the call"), NSString.mnz_string(fromTimeInterval: time)), color: UIColor.mnz_turquoise(for: traitCollection))
            timer = Timer(timeInterval: 1, repeats: true, block: { _ in
                if self.chatCall?.status == .reconnecting {
                    return
                }
                let time = Date().timeIntervalSince1970 - startTime + initDuration

                self.setTopBannerButton(title: String(format: NSLocalizedString("Touch to return to call %@", comment: "Message shown in a chat room for a group call in progress displaying the duration of the call"), NSString.mnz_string(fromTimeInterval: time)), color: UIColor.mnz_turquoise(for: self.traitCollection))
            })
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }
    }

    private func configureTopBannerButtonForInProgressCall(_ call: MEGAChatCall) {
        if chatCall?.status == .reconnecting {
            setTopBannerButton(title: NSLocalizedString("You are back!", comment: "Title shown when the user reconnect in a call."), color: UIColor.mnz_turquoise(for: traitCollection))
        }
        initTimerForCall(call)
        showTopBannerButton()
    }

    private func configureTopBannerButtonForActiveCall(_: MEGAChatCall) {
        let title = chatRoom.isGroup ? NSLocalizedString("There is an active group call. Tap to join.", comment: "Message shown in a chat room when there is an active group call") : NSLocalizedString("Tap to return to call", comment: "Message shown in a chat room for a one on one call")
        setTopBannerButton(title: title, color: UIColor.mnz_turquoise(for: traitCollection))
        showTopBannerButton()
    }

    @objc func joinActiveCall() {
        DevicePermissionsHelper.audioPermissionModal(true, forIncomingCall: false) { granted in
            if granted {
                self.timer?.invalidate()
                self.openCallViewWithVideo(videoCall: false)
            } else {
                DevicePermissionsHelper.alertAudioPermission(forIncomingCall: false)
            }
        }
    }
}

extension ChatViewController: MEGAChatCallDelegate {
    func onChatCallUpdate(_: MEGAChatSdk!, call: MEGAChatCall!) {
        if call.chatId != chatRoom.chatId {
            return
        }
        switch call.status {
        case .userNoPresent, .requestSent:
            configureTopBannerButtonForActiveCall(call)
            configureNavigationBar()
        case .inProgress:
            configureTopBannerButtonForInProgressCall(call)
        case .reconnecting:
            setTopBannerButton(title: NSLocalizedString("Reconnecting...", comment: "Title shown when the user lost the connection in a call, and the app will try to reconnect the user again."), color: UIColor.systemOrange)
        case .destroyed:
            timer?.invalidate()
            configureNavigationBar()
            hideTopBannerButton()
        default:
            return
        }
        chatCall = call
    }
}
