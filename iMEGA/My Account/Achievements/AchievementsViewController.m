
#import "AchievementsViewController.h"

#import "NSDate+DateTools.h"

#import "Helper.h"
#import "MEGASdkManager.h"
#import "MEGA-Swift.h"
#import "NSString+MNZCategory.h"

#import "AchievementsDetailsViewController.h"
#import "AchievementsTableViewCell.h"
#import "InviteFriendsViewController.h"
#import "ReferralBonusesTableViewController.h"

@interface AchievementsViewController () <UITableViewDataSource, UITableViewDelegate, MEGARequestDelegate>

@property (weak, nonatomic) IBOutlet UIView *inviteYourFriendsView;
@property (weak, nonatomic) IBOutlet UILabel *inviteYourFriendsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteYourFriendsSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorImageView;

@property (weak, nonatomic) IBOutlet UIView *unlockedBonusesView;
@property (weak, nonatomic) IBOutlet UIView *unlockedBonusesTopSeparatorView;
@property (weak, nonatomic) IBOutlet UILabel *unlockedBonusesLabel;
@property (weak, nonatomic) IBOutlet UILabel *unlockedStorageQuotaLabel;
@property (weak, nonatomic) IBOutlet UILabel *storageQuotaLabel;
@property (weak, nonatomic) IBOutlet UIView *unlockedBonusesCentralSeparatorView;
@property (weak, nonatomic) IBOutlet UILabel *unlockedTransferQuotaLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferQuotaLabel;
@property (weak, nonatomic) IBOutlet UIView *unlockedBonusesBottomSeparatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MEGAAchievementsDetails *achievementsDetails;
@property (nonatomic) NSMutableArray *achievementsIndexesMutableArray;

@property (nonatomic, getter=haveReferralBonuses) BOOL referralBonuses;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;

@end

@implementation AchievementsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    
    self.numberFormatter = NSNumberFormatter.alloc.init;
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.locale = NSLocale.autoupdatingCurrentLocale;
    self.numberFormatter.maximumFractionDigits = 0;
    
    self.navigationItem.title = NSLocalizedString(@"achievementsTitle", @"Title of the Achievements section");
    
    self.inviteYourFriendsTitleLabel.text = NSLocalizedString(@"inviteYourFriends", @"Indicating text for when 'you invite your friends'");
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteYourFriendsTapped)];
    self.inviteYourFriendsView.gestureRecognizers = @[tapGestureRecognizer];
    self.disclosureIndicatorImageView.image = self.disclosureIndicatorImageView.image.imageFlippedForRightToLeftLayoutDirection;
    
    self.unlockedBonusesLabel.text = NSLocalizedString(@"unlockedBonuses", @"Header of block with achievements bonuses.");
    self.storageQuotaLabel.text = NSLocalizedString(@"storageQuota", @"A header/title of a section which contains information about used/available storage space on a user's cloud drive.");
    self.transferQuotaLabel.text = NSLocalizedString(@"Transfer Quota", @"Some text listed after the amount of transfer quota a user gets with a certain package. For example: '8 TB Transfer quota'.");
    
    [[MEGASdkManager sharedMEGASdk] getAccountAchievementsWithDelegate:self];
    
    if (self.enableCloseBarButton) { //For modal presentations
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"skipButton", @"Button title that skips the current action")
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(dismissViewController)];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
    
    [self updateAppearance];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [self updateAppearance];
            
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Private

- (void)updateAppearance {
    self.view.backgroundColor = UIColor.mnz_background;
    self.tableView.separatorColor = [UIColor mnz_separatorForTraitCollection:self.traitCollection];
    
    self.inviteYourFriendsView.backgroundColor = [UIColor mnz_secondaryBackgroundForTraitCollection:self.traitCollection];
    self.inviteYourFriendsTitleLabel.textColor = [UIColor mnz_subtitlesForTraitCollection:self.traitCollection];
    
    self.unlockedBonusesView.backgroundColor = [UIColor mnz_tertiaryBackground:self.traitCollection];
    
    self.unlockedBonusesCentralSeparatorView.backgroundColor = self.unlockedBonusesTopSeparatorView.backgroundColor = self.unlockedBonusesBottomSeparatorView.backgroundColor = [UIColor mnz_separatorForTraitCollection:self.traitCollection];
    self.unlockedStorageQuotaLabel.textColor = [UIColor mnz_blueForTraitCollection:self.traitCollection];
    self.unlockedTransferQuotaLabel.textColor = UIColor.systemGreenColor;
    
    self.storageQuotaLabel.textColor = self.transferQuotaLabel.textColor = [UIColor mnz_secondaryGrayForTraitCollection:self.traitCollection];
}

- (NSMutableAttributedString *)textForUnlockedBonuses:(long long)quota {
    NSString *stringFromByteCount;
    NSRange firstPartRange;
    NSRange secondPartRange;
    
    stringFromByteCount = [Helper memoryStyleStringFromByteCount:quota];

    NSArray *componentsSeparatedByStringArray = [stringFromByteCount componentsSeparatedByString:@" "];
    
    NSString *firstPartString = [NSString mnz_stringWithoutUnitOfComponents:componentsSeparatedByStringArray];
    NSNumber *number = [self.numberFormatter numberFromString:firstPartString];
    firstPartString = [self.numberFormatter stringFromNumber:number];
    
    if (firstPartString.length == 0) {
        firstPartString = [NSString mnz_stringWithoutUnitOfComponents:componentsSeparatedByStringArray];
    }
    
    firstPartString = [firstPartString stringByAppendingString:@" "];
    firstPartRange = [firstPartString rangeOfString:firstPartString];
    NSMutableAttributedString *firstPartMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:firstPartString];
    
    NSString *secondPartString = [NSString mnz_stringWithoutCountOfComponents:componentsSeparatedByStringArray];
    secondPartRange = [secondPartString rangeOfString:secondPartString];
    NSMutableAttributedString *secondPartMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:secondPartString];
    
    [firstPartMutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:32.0f] range:firstPartRange];
    
    [secondPartMutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f] range:secondPartRange];
    
    [firstPartMutableAttributedString appendAttributedString:secondPartMutableAttributedString];
    
    return firstPartMutableAttributedString;
}

- (void)setStorageAndTransferQuotaRewardsForCell:(AchievementsTableViewCell *)cell forIndex:(NSInteger)index {
    long long classStorageReward = 0;
    long long classTransferReward = 0;
    if (index == -1) {
        classStorageReward = self.achievementsDetails.currentStorageReferrals;
        classTransferReward = self.achievementsDetails.currentTransferReferrals;
    } else {
        NSInteger awardId = [self.achievementsDetails awardIdAtIndex:index];
        classStorageReward = [self.achievementsDetails rewardStorageByAwardId:awardId];
        classTransferReward = [self.achievementsDetails rewardTransferByAwardId:awardId];
    }
    
    cell.storageQuotaRewardView.backgroundColor = cell.storageQuotaRewardLabel.backgroundColor = ((classStorageReward == 0) ? [UIColor mnz_tertiaryGrayForTraitCollection:self.traitCollection] : [UIColor mnz_blueForTraitCollection:self.traitCollection]);
    cell.storageQuotaRewardLabel.text = (classStorageReward == 0) ? @"— GB" : [Helper memoryStyleStringFromByteCount:classStorageReward];
    
    cell.transferQuotaRewardView.backgroundColor = cell.transferQuotaRewardLabel.backgroundColor = ((classTransferReward == 0) ? [UIColor mnz_tertiaryGrayForTraitCollection:self.traitCollection] : UIColor.systemGreenColor);
    cell.transferQuotaRewardLabel.text = (classTransferReward == 0) ? @"— GB" : [Helper memoryStyleStringFromByteCount:classTransferReward];
}

- (void)pushAchievementsDetailsWithIndexPath:(NSIndexPath *)indexPath {
    AchievementsDetailsViewController *achievementsDetailsVC = [[UIStoryboard storyboardWithName:@"Achievements" bundle:nil] instantiateViewControllerWithIdentifier:@"AchievementsDetailsViewControllerID"];
    achievementsDetailsVC.achievementsDetails = self.achievementsDetails;
    NSUInteger numberOfStaticCells = self.haveReferralBonuses ? 1 : 0;
    NSNumber *index = [self.achievementsIndexesMutableArray objectAtIndex:(indexPath.row - numberOfStaticCells)];
    achievementsDetailsVC.index = index.unsignedIntegerValue;
    
    [self.navigationController pushViewController:achievementsDetailsVC animated:YES];
}

- (void)inviteYourFriendsTapped {
    InviteFriendsViewController *inviteFriendsViewController = [[UIStoryboard storyboardWithName:@"Achievements" bundle:nil] instantiateViewControllerWithIdentifier:@"InviteFriendsViewControllerID"];
    inviteFriendsViewController.inviteYourFriendsSubtitleString = self.inviteYourFriendsSubtitleLabel.text;
    
    [self.navigationController pushViewController:inviteFriendsViewController animated:YES];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfStaticCells = self.haveReferralBonuses ? 1 : 0;
    
    return numberOfStaticCells + self.achievementsIndexesMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if (indexPath.row == 0) {
        identifier = self.haveReferralBonuses ? @"AchievementsTableViewCellID" : @"AchievementsWithSubtitleTableViewCellID";
    } else {
        identifier = @"AchievementsWithSubtitleTableViewCellID";
    }
    
    AchievementsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (indexPath.row == 0 && self.haveReferralBonuses) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.titleLabel.text = NSLocalizedString(@"referralBonuses", @"achievement type");
        
        [self setStorageAndTransferQuotaRewardsForCell:cell forIndex:-1];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        NSUInteger numberOfStaticCells = self.haveReferralBonuses ? 1 : 0;
        NSNumber *index = [self.achievementsIndexesMutableArray objectAtIndex:(indexPath.row - numberOfStaticCells)];
        MEGAAchievement achievementClass = [self.achievementsDetails awardClassAtIndex:index.unsignedIntegerValue];
        
        [self setStorageAndTransferQuotaRewardsForCell:cell forIndex:index.integerValue];
        
        switch (achievementClass) {
            case MEGAAchievementWelcome: {
                cell.titleLabel.text = NSLocalizedString(@"registrationBonus", @"achievement type");
                break;
            }
                
            case MEGAAchievementDesktopInstall: {
                cell.titleLabel.text = NSLocalizedString(@"installMEGASync", @"");
                break;
            }
                
            case MEGAAchievementMobileInstall: {
                cell.titleLabel.text = NSLocalizedString(@"installOurMobileApp", @"");
                break;
            }
                
            case MEGAAchievementAddPhone: {
                cell.titleLabel.text = NSLocalizedString(@"Add Phone Number", nil);
                break;
            }
                
            default:
                break;
        }
        
        NSDate *awardExpirationdDate = [self.achievementsDetails awardExpirationAtIndex:index.unsignedIntegerValue];
        cell.subtitleLabel.text = (awardExpirationdDate.daysUntil == 0) ? NSLocalizedString(@"expired", @"Label to show that an error related with expiration occurs during a SDK operation.") : [NSLocalizedString(@"xDaysLeft", @"") stringByReplacingOccurrencesOfString:@"%1" withString:[NSString stringWithFormat:@"%zd", awardExpirationdDate.daysUntil]];
        cell.subtitleLabel.textColor = (awardExpirationdDate.daysUntil <= 15) ? [UIColor mnz_redForTraitCollection:(self.traitCollection)] : [UIColor mnz_subtitlesForTraitCollection:self.traitCollection];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            if (self.haveReferralBonuses) {
                ReferralBonusesTableViewController *referralBonusesTVC = [[UIStoryboard storyboardWithName:@"Achievements" bundle:nil] instantiateViewControllerWithIdentifier:@"ReferralBonusesTableViewControllerID"];
                referralBonusesTVC.achievementsDetails = self.achievementsDetails;
                [self.navigationController pushViewController:referralBonusesTVC animated:YES];
            } else {
                [self pushAchievementsDetailsWithIndexPath:indexPath];
            }
            break;
        }
            
        default: {
            [self pushAchievementsDetailsWithIndexPath:indexPath];
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MEGARequestDelegate

- (void)onRequestFinish:(MEGASdk *)api request:(MEGARequest *)request error:(MEGAError *)error {
    if (request.type == MEGARequestTypeGetAchievements) {
        if (error.type) {
            return;
        }
        
        self.achievementsDetails = request.megaAchievementsDetails;
        
        self.achievementsIndexesMutableArray = [[NSMutableArray alloc] init];
        NSUInteger awardsCount = self.achievementsDetails.awardsCount;
        for (NSUInteger i = 0; i < awardsCount; i++) {
            MEGAAchievement achievementClass = [self.achievementsDetails awardClassAtIndex:i];
            if (achievementClass == MEGAAchievementInvite) {
                self.referralBonuses = YES;
            } else {
                [self.achievementsIndexesMutableArray addObject:[NSNumber numberWithInteger:i]];
            }
        }
        
        NSString *inviteStorageString = [Helper memoryStyleStringFromByteCount:[self.achievementsDetails classStorageForClassId:MEGAAchievementInvite]];
        NSString *inviteTransferString = [Helper memoryStyleStringFromByteCount:[self.achievementsDetails classTransferForClassId:MEGAAchievementInvite]];
        NSString *inviteFriendsAndGetForEachReferral = NSLocalizedString(@"inviteFriendsAndGetForEachReferral", @"title of the introduction for the achievements screen");
        inviteFriendsAndGetForEachReferral = [inviteFriendsAndGetForEachReferral stringByReplacingOccurrencesOfString:@"%1$s" withString:inviteStorageString];
        inviteFriendsAndGetForEachReferral = [inviteFriendsAndGetForEachReferral stringByReplacingOccurrencesOfString:@"%2$s" withString:inviteTransferString];
        self.inviteYourFriendsSubtitleLabel.text = inviteFriendsAndGetForEachReferral;
        
        self.unlockedStorageQuotaLabel.attributedText = [self textForUnlockedBonuses:self.achievementsDetails.currentStorage];
        self.unlockedTransferQuotaLabel.attributedText = [self textForUnlockedBonuses:self.achievementsDetails.currentTransfer];
        
        [self.inviteYourFriendsSubtitleLabel sizeToFit];
        
        [self.tableView reloadData];
    }
}

@end
