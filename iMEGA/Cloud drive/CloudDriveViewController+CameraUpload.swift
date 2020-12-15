
extension CloudDriveViewController {
    @IBAction func deleteAction(sender: UIBarButtonItem) {
        guard let selectedNodes = selectedNodesArray as? [MEGANode] else {
            return
        }
        
        switch displayMode {
        case .cloudDrive:
            checkIfCameraUploadPromptIsNeeded { [weak self] shouldPrompt in
                DispatchQueue.main.async {
                    if shouldPrompt {
                        self?.promptCameraUploadFolderDeletion {
                            self?.deleteSelectedNodes()
                        }
                    } else {
                        self?.deleteSelectedNodes()
                    }
                }
            }
        case .rubbishBin:
            confirmDeleteActionFiles(selectedNodes.contentCounts().fileCount,
                                     andFolders: selectedNodes.contentCounts().folderCount)
        default: break
        }
    }
    
    @objc func moveToRubbishBin(for node: MEGANode) {
        guard let rubbish = MEGASdkManager.sharedMEGASdk().rubbishNode else {
            self.dismiss(animated: true)
            return
        }
        
        CameraUploadNodeAccess.shared.loadNode { [weak self] (cuNode, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let cuNode = cuNode else {
                    node.mnz_askToMoveToTheRubbishBin(in: self)
                    return
                }
                
                if cuNode.isDescendant(of: node, in: MEGASdkManager.sharedMEGASdk()) {
                    self.promptCameraUploadFolderDeletion {
                        let delegate = MEGAMoveRequestDelegate(toMoveToTheRubbishBinWithFiles: 0, folders: 1) {
                            self.dismiss(animated: true)
                        }
                        MEGASdkManager.sharedMEGASdk().move(node, newParent: rubbish, delegate: delegate)
                    }
                } else {
                    node.mnz_askToMoveToTheRubbishBin(in: self)
                }
            }
        }
    }
    
    private func deleteSelectedNodes() {
        guard let selectedNodes = selectedNodesArray as? [MEGANode],
              let rubbish = MEGASdkManager.sharedMEGASdk().rubbishNode else {
            return
        }
        
        let delegate = MEGAMoveRequestDelegate(toMoveToTheRubbishBinWithFiles: selectedNodes.contentCounts().fileCount,
                                               folders: selectedNodes.contentCounts().folderCount) {
            self.setEditMode(false)
        }
        
        for node in selectedNodes {
            MEGASdkManager.sharedMEGASdk().move(node, newParent: rubbish, delegate: delegate)
        }
    }
    
    private func checkIfCameraUploadPromptIsNeeded(completion: @escaping (Bool) -> Void) {
        guard let selectedNodes = selectedNodesArray as? [MEGANode],
              CameraUploadManager.isCameraUploadEnabled else {
            completion(false)
            return
        }
        
        CameraUploadNodeAccess.shared.loadNode { node, error in
            guard let cuNode = node else { return }
            
            let isSelected = selectedNodes.contains {
                cuNode.isDescendant(of: $0, in: MEGASdkManager.sharedMEGASdk())
            }
            
            completion(isSelected)
        }
    }
    
    private func promptCameraUploadFolderDeletion(deleteHandler: @escaping () -> Void, cancelHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: NSLocalizedString("moveToTheRubbishBin", comment: ""),
                                      message: NSLocalizedString("Are you sure you want to move Camera Uploads folder to Rubbish Bin? If so, a new folder will be auto-generated for Camera Uploads.", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(.init(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { _ in
            cancelHandler?()
        })
        
        alert.addAction(.init(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            deleteHandler()
        })
        
        self.present(alert, animated: true)
    }
}
