
NS_ASSUME_NONNULL_BEGIN

@interface MEGANode (MNZCategory) <UITextFieldDelegate>

@property (nonatomic, readonly) MEGANode *parent;

- (void)navigateToParentAndPresent;
- (void)mnz_openNodeInNavigationController:(UINavigationController *_Nullable)navigationController folderLink:(BOOL)isFolderLink fileLink:(NSString *_Nullable)fileLink;
- (UIViewController *)mnz_viewControllerForNodeInFolderLink:(BOOL)isFolderLink fileLink:(NSString *)fileLink inViewController:(UIViewController *_Nullable)viewController;
- (UIViewController *)mnz_viewControllerForNodeInFolderLink:(BOOL)isFolderLink fileLink:(NSString *)fileLink;

- (void)mnz_generateThumbnailForVideoAtPath:(NSURL *)path;

#pragma mark - Actions

- (BOOL)mnz_downloadNode;
- (BOOL)mnz_downloadNodeWithApi:(MEGASdk *)api;
- (BOOL)mnz_downloadNodeTopPriority;
- (void)mnz_labelActionSheetInViewController:(UIViewController *)viewController;
- (void)mnz_renameNodeInViewController:(UIViewController *)viewController;
- (void)mnz_renameNodeInViewController:(UIViewController *)viewController completion:(void(^)(MEGARequest *request))completion;
- (void)mnz_askToMoveToTheRubbishBinInViewController:(UIViewController *)viewController;
- (void)mnz_moveToTheRubbishBinWithCompletion:(void (^)(void))completion;
- (void)mnz_removeInViewController:(UIViewController *)viewController;
- (void)mnz_leaveSharingInViewController:(UIViewController *)viewController;
- (void)mnz_removeSharing;
- (void)mnz_copyToGalleryFromTemporaryPath:(NSString *)path;
- (void)mnz_restore;
- (void)mnz_removeLink;
- (void)mnz_saveToPhotosWithApi:(MEGASdk *)api;
- (void)mnz_sendToChatInViewController:(UIViewController *)viewController;
- (void)mnz_moveInViewController:(UIViewController *)viewController;
- (void)mnz_copyInViewController:(UIViewController *)viewController;

#pragma mark - File links

- (void)mnz_fileLinkDownloadFromViewController:(UIViewController *)viewController isFolderLink:(BOOL)isFolderLink;
- (void)mnz_fileLinkImportFromViewController:(UIViewController *)viewController isFolderLink:(BOOL)isFolderLink;

#pragma mark - Utils

- (MEGANode *)mnz_firstbornInShareOrOutShareParentNode;
- (NSMutableArray *)mnz_parentTreeArray;
- (NSString *)mnz_fileType;
- (BOOL)mnz_isRestorable;
- (BOOL)mnz_isPlayable;
- (NSString *)mnz_voiceCachePath;
- (NSAttributedString *)mnz_attributedTakenDownNameWithHeight:(CGFloat)height;

#pragma mark - Shares

- (nonnull NSMutableArray <MEGAShare *> *)outShares;

#pragma mark - Versions

- (NSInteger)mnz_numberOfVersions;
- (NSArray<MEGANode *> *)mnz_versions;
- (long long)mnz_versionsSize;

@end

NS_ASSUME_NONNULL_END
