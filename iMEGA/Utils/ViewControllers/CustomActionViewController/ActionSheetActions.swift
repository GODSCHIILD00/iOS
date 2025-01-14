import UIKit

class BaseAction: NSObject {
    var title: String?
    var detail: String?
    var accessoryView: UIView?
    var image: UIImage?
    var style: UIAlertAction.Style = .default
}

class ActionSheetAction: BaseAction {
    var actionHandler : () -> Void

    @objc init(title: String?, detail: String?, image: UIImage?, style: UIAlertAction.Style, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init()
        self.title = title
        self.detail = detail
        self.image = image
        self.style = style
    }
    
    @objc init(title: String?, detail: String?, accessoryView: UIView?, image: UIImage?, style: UIAlertAction.Style, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init()
        self.title = title
        self.detail = detail
        self.accessoryView = accessoryView
        self.image = image
        self.style = style
    }
}

class ActionSheetSwitchAction: ActionSheetAction {
    var switchView: UISwitch?
    
    @objc init(title: String?, detail: String?, switchView: UISwitch, image: UIImage?, style: UIAlertAction.Style, actionHandler: @escaping () -> Void) {
        super.init(title: title, detail: detail, image: image, style: style, actionHandler: actionHandler)
        self.switchView = switchView
    }
    
    @objc func change(state: Bool) {
        switchView?.isOn = state
    }
    
    @objc func switchStatus() -> Bool {
        return switchView?.isOn ?? false
    }
}

class NodeAction: BaseAction {
    var type: MegaNodeActionType

    private init(title: String?, detail: String?, image: UIImage?, type: MegaNodeActionType) {
        self.type = type
        super.init()
        self.title = title
        self.detail = detail
        self.image = image
    }
    
    private init(title: String?, detail: String?, accessoryView: UIView?, image: UIImage?, type: MegaNodeActionType) {
        self.type = type
        super.init()
        self.title = title
        self.detail = detail
        self.accessoryView = accessoryView
        self.image = image
    }
}

// MARK: - Node Actions Factory

extension NodeAction {
    class func shareAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("share", comment: "Button title which, if tapped, will trigger the action of sharing with the contact or contacts selected"), detail: nil, image: UIImage(named: "share"), type: .share)
    }
    
    class func shareFolderAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("shareFolder", comment: "Button title which, if tapped, will trigger the action of sharing with the contact or contacts selected, the folder you want inside your Cloud Drive"), detail: nil, image: UIImage(named: "shareFolder"), type: .shareFolder)
    }
    
    class func manageFolderAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Manage Share", comment: "Text indicating to the user the action that will be executed on tap."), detail: nil, image: UIImage(named: "shareFolder"), type: .manageShare)
    }
    
    class func downloadAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("download", comment: "Text to perform an action to save a file in offline section"), detail: nil, image: UIImage(named: "offline"), type: .download)
    }
    
    class func infoAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("info", comment: "A button label. The button allows the user to get more info of the current context."), detail: nil, image: UIImage(named: "info"), type: .info)
    }
    
    class func renameAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("rename", comment: "Title for the action that allows you to rename a file or folder"), detail: nil, image: UIImage(named: "rename"), type: .rename)
    }
    
    class func copyAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("copy", comment: "List option shown on the details of a file or folder"), detail: nil, image: UIImage(named: "copy"), type: .copy)
    }
    
    class func moveAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("move", comment: "Title for the action that allows you to move a file or folder"), detail: nil, image: UIImage(named: "move"), type: .move)
    }
    
    class func moveToRubbishBinAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("moveToTheRubbishBin", comment: "Title for the action that allows you to 'Move to the Rubbish Bin' files or folders"), detail: nil, image: UIImage(named: "rubbishBin"), type: .moveToRubbishBin)
    }
    
    class func removeAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("remove", comment: "Title for the action that allows to remove a file or folder"), detail: nil, image: UIImage(named: "rubbishBin"), type: .remove)
    }
    
    class func leaveSharingAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("leaveFolder", comment: "Button title of the action that allows to leave a shared folder"), detail: nil, image: UIImage(named: "leaveShare"), type: .leaveSharing)
    }
    
    class func getLinkAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("getLink", comment: "Title shown under the action that allows you to get a link to file or folder"), detail: nil, image: UIImage(named: "link"), type: .getLink)
    }
    
    class func retryAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("retry", comment: ""), detail: nil, image: UIImage(named: "link"), type: .retry)
    }
    
    class func manageLinkAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("manageLink", comment: "Item menu option upon right click on one or multiple files"), detail: nil, image: UIImage(named: "link"), type: .manageLink)
    }
    
    class func removeLinkAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("removeLink", comment: "Message shown when there is an active link that can be removed or disabled"), detail: nil, image: UIImage(named: "removeLink"), type: .removeLink)
    }
    
    class func removeSharingAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("removeSharing", comment: "Alert title shown on the Shared Items section when you want to remove 1 share"), detail: nil, image: UIImage(named: "removeShare"), type: .removeSharing)
    }
    
    class func viewInFolderAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("View in Folder", comment: "Button title which, if tapped, will trigger the action of opening a folder containg this file"), detail: nil, image: UIImage(named: "searchThin"), type: .viewInFolder)
    }
    
    class func clearAction() -> NodeAction {
        let action = NodeAction(title: NSLocalizedString("clear", comment: "Button title to clear something"), detail: nil, image: UIImage(named: "cancelTransfers"), type: .clear)
        action.style = .destructive
        return action
    }
    
    class func importAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Import to Cloud Drive", comment: "Button title that triggers the importing link action"), detail: nil, image: UIImage(named: "import"), type: .import)
    }
    
    class func revertVersionAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("revert", comment: "A button label which reverts a certain version of a file to be the current version of the selected file."), detail: nil, image: UIImage(named: "history"), type: .revertVersion)
    }
    
    class func removeVersionAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("delete", comment: "Text for a destructive action for some item. A node version for example."), detail: nil, image: UIImage(named: "delete"), type: .remove)
    }
    
    class func selectAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("select", comment: "Button that allows you to select a given folder"), detail: nil, image: UIImage(named: "select"), type: .select)
    }
    
    class func restoreAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("restore", comment: "Button title to perform a restore action. For example failed purchases or a node in the rubbish bin."), detail: nil, image: UIImage(named: "restore"), type: .restore)
    }
    
    class func saveToPhotosAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Save to Photos", comment: "A button label which allows the users save images/videos in the Photos app"), detail: nil, image: UIImage(named: "saveToPhotos"), type: .saveToPhotos)
    }
    
    class func sendToChatAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("sendToContact", comment: "Text for the action to send something to a contact through the chat."), detail: nil, image: UIImage(named: "sendMessage"), type: .sendToChat)
    }
    
    class func pdfPageViewAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Page View", comment: "Text shown when switching from thumbnail view to page view when previewing a document, for example a PDF."), detail: nil, image: UIImage(named: "pageView"), type: .pdfPageView)
    }
    
    class func pdfThumbnailViewAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Thumbnail View", comment: "Text shown for switching from list view to thumbnail view."), detail: nil, image: UIImage(named: "thumbnailsThin"), type: .pdfThumbnailView)
    }
    
    class func textEditorAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("edit", comment: "Text shown for switching from list view to thumbnail view."), detail: nil, image: UIImage(named: "edittext"), type: .editTextFile)
    }
    
    class func forwardAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("forward", comment: "Item of a menu to forward a message chat to another chatroom"), detail: nil, image: UIImage(named: "forwardToolbar"), type: .forward)
    }
    
    class func searchAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Search", comment: "Title of the Spotlight Search section"), detail: nil, image: UIImage(named: "search"), type: .search)
    }
    
    class func favouriteAction(isFavourite: Bool) -> NodeAction {
        return NodeAction(title: isFavourite ? NSLocalizedString("Remove Favourite", comment: "Context menu item. Allows user to delete file/folder from favourites") : NSLocalizedString("Favourite", comment: "Context menu item. Allows user to add file/folder to favourites"), detail: nil, image: isFavourite ? UIImage(named: "removeFavourite") : UIImage(named: "favourite"), type: .favourite)
    }
    
    class func labelAction(label: MEGANodeLabel) -> NodeAction {
        let labelString = MEGANode.string(for: label)
        let detailText = NSLocalizedString(labelString!, comment: "")
        let image = UIImage(named: labelString!)
        
        return NodeAction(title: NSLocalizedString("Label...", comment: "Context menu item which allows to mark folders with own color label"), detail: (label != .unknown ? detailText : nil), accessoryView: (label != .unknown ? UIImageView(image: image) : nil), image: UIImage(named: "label"), type: .label)
    }
    
    class func listAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("List View", comment: "Text shown for switching from thumbnail view to list view."), detail: nil, image: UIImage(named: "gridThin"), type: .list)
    }
    
    class func thumbnailAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("Thumbnail View", comment: "Text shown for switching from list view to thumbnail view."), detail: nil, image: UIImage(named: "thumbnailsThin"), type: .thumbnail)
    }
    
    class func sortAction() -> NodeAction {
        return NodeAction(title: NSLocalizedString("sortTitle", comment: "Section title of the 'Sort by'"), detail: nil, image: UIImage(named: "sort"), type: .sort)
    }
}
