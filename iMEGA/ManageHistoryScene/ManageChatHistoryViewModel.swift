
import Foundation

enum ManageHistoryAction: ActionType {
    case historyRetentionValue
    case configHistoryRetentionSwitch(Bool)
    case historyRetentionSwitchValueChanged(Bool)
    case selectHistoryRetentionValue(Int)
    
    case showOrHideCustomHistoryRetentionCell(Bool)
    case showOrHideHistoryRetentionPicker(Bool)
    case historyRetentionCustomLabel(UInt)
    case saveHistoryRetentionPickerValue(Int, Int)
    case historyRetentionFooter
    
    case showClearChatHistoryAlert
    case clearChatHistoryFooter
    case clearChatHistoryConfirmed
}

final class ManageChatHistoryViewModel: ViewModelType {
    enum Command: CommandType {
        case startLoading
        case finishLoading
        
        case configHistoryRetentionSection(HistoryRetentionOption, UInt)
        case historyRetentionSwitch(Bool)
        case showHistoryRetentionActionSheet
        
        case showOrHideCustomHistoryRetentionCell(Bool)
        case showOrHideHistoryRetentionPicker(Bool)
        case configHistoryRetentionPicker(UInt)
        case updateHistoryRetentionCustomLabel(String)
        case enableDisableSaveButton(Bool)
        case showOrHideSaveButton(Bool)
        case updateHistoryRetentionFooter(String)
        
        case showClearChatHistoryAlert
        case updateClearChatHistoryFooter(String)
        
        case showResult(ResultCommand)
        
        enum ResultCommand: Equatable {
            case success(String)
            case content(UIImage, String)
            case error(String)
        }
    }
    
    //MARK: - Private properties
    //MARK: UI Layer
    private let router: ManageChatHistoryViewRouter
    
    //MARK: Domain Layer
    private let manageChatHistoryUseCase: ManageChatHistoryUseCase
    
    private let chatId: ChatId
    private var historyRetentionValue: UInt = 0
    
    private var historyRetentionOption = HistoryRetentionOption.disabled
    private var historyRetentionOptionSelected = HistoryRetentionOption.disabled
    
    //MARK: - Internal properties
    
    var invokeCommand: ((Command) -> Void)?
    
    // MARK: - Init
    
    init(router: ManageChatHistoryViewRouter,
         manageChatHistoryUseCase: ManageChatHistoryUseCase,
         chatId: ChatId) {
        self.router = router
        self.manageChatHistoryUseCase = manageChatHistoryUseCase
        self.chatId = chatId
    }
    
    // MARK: - Private
    
    private func historyRetentionPickerValueToUInt(_ unitsRow: Int, _ measurementsRow: Int) -> UInt {
        let hoursDaysWeeksMonthsOrYearValue = unitsRow + 1
        let secondsInYear = Int(truncatingIfNeeded: secondsInAYear)
        let measurement = [secondsInAHour, secondsInADay, secondsInAWeek, secondsInAMonth_30, secondsInYear][measurementsRow]
        let historyRetentionValue = hoursDaysWeeksMonthsOrYearValue * measurement
        
        return UInt(truncatingIfNeeded: historyRetentionValue)
    }
    
    private func setHistoryRetentionOption(_ historyRetentionValue: Int) {
        historyRetentionOptionSelected = HistoryRetentionOption(rawValue: historyRetentionValue) ?? HistoryRetentionOption(rawValue: 0)!
        
        switch historyRetentionValue {
        case HistoryRetentionOption.oneDay.rawValue:
            setHistoryRetention(UInt(secondsInADay))
        
        case HistoryRetentionOption.oneWeek.rawValue:
            setHistoryRetention(UInt(secondsInAWeek))
            
        case HistoryRetentionOption.oneMonth.rawValue:
            setHistoryRetention(UInt(secondsInAMonth_30))
            
        case HistoryRetentionOption.custom.rawValue:
            self.invokeCommand?(Command.showOrHideCustomHistoryRetentionCell(false))
            self.invokeCommand?(Command.showOrHideSaveButton(false))
            self.invokeCommand?(Command.enableDisableSaveButton(true))
            
            self.invokeCommand?(Command.showOrHideHistoryRetentionPicker(false))
            
        default: break
        }
    }
    
    private func setHistoryRetention(_ historyRetentionValue: UInt) {
        if historyRetentionValue == self.historyRetentionValue {
            if historyRetentionOptionSelected == .custom {
                self.invokeCommand?(.enableDisableSaveButton(false))
                self.invokeCommand?(.showOrHideSaveButton(true))
                
                self.invokeCommand?(.showOrHideHistoryRetentionPicker(true))
            }
            
            return
        } else {
            manageChatHistoryUseCase.historyRetentionUseCase.setChatRetentionTime(for: chatId, period: historyRetentionValue) { [weak self] in
                switch $0 {
                case .success(let period):
                    self?.historyRetentionValue = period
                    self?.historyRetentionOption = self!.historyRetentionOptionSelected
                    
                    self?.updateHistoryRetentionFooter()
                    
                    self?.invokeCommand?(.configHistoryRetentionSection(self!.historyRetentionOption, self!.historyRetentionValue))
                    
                    self!.historyRetentionOptionSelected = .disabled
                    
                case .failure(_): break
                    
                }
            }
        }
    }
    
    private func historyRetentionOption(value: UInt) -> HistoryRetentionOption {
        let historyRetentionOption: HistoryRetentionOption
        if value <= 0 {
            historyRetentionOption = .disabled
        } else if value == secondsInADay {
            historyRetentionOption = .oneDay
        } else if value == secondsInAWeek {
            historyRetentionOption = .oneWeek
        } else if value == secondsInAMonth_30 {
            historyRetentionOption = .oneMonth
        } else {
            historyRetentionOption = .custom
        }
        
        return historyRetentionOption
    }
    
    private func updateHistoryRetentionFooter() {
        var footer: String
        switch historyRetentionOption {
        case .disabled:
            footer = NSLocalizedString("Automatically delete messages older than a certain amount of time", comment: "Text show under the setting 'History Retention' to explain what will happen if enabled")
            
        case .oneDay:
            footer = NSLocalizedString("Automatically delete messages older than one day", comment: "Text show under the setting 'History Retention' to explain that it is configured to '1 day'")
            
        case .oneWeek:
            footer = NSLocalizedString("Automatically delete messages older than one week", comment: "Text show under the setting 'History Retention' to explain that it is configured to '1 week'")
            
        case .oneMonth:
            footer = NSLocalizedString("Automatically delete messages older than one month", comment: "Text show under the setting 'History Retention' to explain that it is configured to '1 month'")
            
        case .custom:
            let string = NSLocalizedString("Automatically delete messages older than %1", comment: "Text show under the setting 'History Retention' to explain what is the custom value configured. This value is represented by '%1'. The possible values go from 1 hour, to days, weeks or months, up to 1 year.")
            footer = string.replacingOccurrences(of: "%1", with: NSString.mnz_hoursDaysWeeksMonthsOrYear(from: historyRetentionValue))
        }
        
        self.invokeCommand?(.updateHistoryRetentionFooter(footer))
    }
    
    private func updateClearChatHistoryFooter() {
        let footer = NSLocalizedString("Delete all messages and files shared in this conversation from both parties. This action is irreversible", comment: "Text show under the setting 'Clear Chat History' to explain what will happen if used")
        
        self.invokeCommand?(.updateClearChatHistoryFooter(footer))
    }
    
    // MARK: - Dispatch actions
    
    func dispatch(_ action: ManageHistoryAction) {
        switch action {
            
        case .historyRetentionValue:
            manageChatHistoryUseCase.retentionValueUseCase.chatRetentionTime(for: chatId) { [weak self] in
                switch $0 {
                case .success(let currentHistoryRetentionValue):
                    self?.historyRetentionValue = currentHistoryRetentionValue
                    self?.historyRetentionOption = self!.historyRetentionOption(value: currentHistoryRetentionValue)
                    self?.invokeCommand?(.configHistoryRetentionSection(self!.historyRetentionOption, currentHistoryRetentionValue))
                    
                    self?.updateHistoryRetentionFooter()
                    
                case .failure(_): break
                }
            }
            
        case .configHistoryRetentionSwitch(let on):
            self.invokeCommand?(Command.historyRetentionSwitch(on))
            
        case .historyRetentionSwitchValueChanged(let isOn):
            if isOn {
                self.invokeCommand?(Command.showHistoryRetentionActionSheet)
            } else {
                self.historyRetentionOptionSelected = .disabled
                setHistoryRetention(UInt(HistoryRetentionOption.disabled.rawValue))
                
                self.invokeCommand?(Command.configHistoryRetentionSection(.disabled, UInt(HistoryRetentionOption.disabled.rawValue)))
            }
            
        case .selectHistoryRetentionValue(let historyRetentionOption):
            setHistoryRetentionOption(historyRetentionOption)
            
        case .showOrHideCustomHistoryRetentionCell(let showOrHide):
            self.invokeCommand?(Command.showOrHideCustomHistoryRetentionCell(showOrHide))
            
        case .showOrHideHistoryRetentionPicker(let isHidden):
            //Since this action is dispatched only from the 'didSelectRowAt' from the VC, the picker has to be to be configured to its current value
            self.invokeCommand?(Command.configHistoryRetentionPicker(self.historyRetentionValue))
            
            self.invokeCommand?(Command.showOrHideHistoryRetentionPicker(isHidden))
            
        case .saveHistoryRetentionPickerValue(let unitsRow, let measurementRow):
            self.historyRetentionOptionSelected = .custom
            let historyRetentionValue = historyRetentionPickerValueToUInt(unitsRow, measurementRow)
            setHistoryRetention(historyRetentionValue)
            
            if historyRetentionValue != self.historyRetentionValue {
                self.updateHistoryRetentionFooter()
                self.invokeCommand?(.enableDisableSaveButton(false))
                self.invokeCommand?(.showOrHideSaveButton(true))
            }
            
        case .historyRetentionCustomLabel(let historyRetentionValue):
            self.invokeCommand?(.updateHistoryRetentionCustomLabel(NSString.mnz_hoursDaysWeeksMonthsOrYear(from: historyRetentionValue)))
        
        case .historyRetentionFooter:
            updateHistoryRetentionFooter()
            
        case .showClearChatHistoryAlert:
            self.invokeCommand?(Command.showClearChatHistoryAlert)
        
        case .clearChatHistoryConfirmed:
            manageChatHistoryUseCase.clearChatHistoryUseCase.clearChatHistory(for: chatId) { [weak self] in
                switch $0 {
                case .success(_):
                    self?.invokeCommand?(.showResult(.content(UIImage.init(named: "clearChatHistory")! , NSLocalizedString("Chat History has Been Cleared", comment: "Message show when the history of a chat has been successfully deleted."))))
                    
                case .failure(_):
                    self?.invokeCommand?(.showResult(.error(NSLocalizedString("An error has occurred. The chat history has not been successfully cleared", comment: "Message show when the history of a chat hasn’t been successfully deleted"))))
                }
            }
            
        case .clearChatHistoryFooter:
            updateClearChatHistoryFooter()
        }
    }
}
