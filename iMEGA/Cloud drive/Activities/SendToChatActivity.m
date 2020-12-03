
#import "SendToChatActivity.h"

#import "MEGANavigationController.h"
#import "SendToViewController.h"

@interface SendToChatActivity ()

@property (strong, nonatomic) NSArray *nodes;
@property (strong, nonatomic) NSString *text;

@end

@implementation SendToChatActivity

- (instancetype)initWithNodes:(NSArray *)nodesArray {
    self = [super init];
    if (self) {
        _nodes = nodesArray;
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _text = text;
    }
    
    return self;
}

- (NSString *)activityType {
    return MEGAUIActivityTypeSendToChat;
}

- (NSString *)activityTitle {
    return NSLocalizedString(@"sendToContact", @"");
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"activity_sendToContact"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (UIViewController *)activityViewController {
    MEGANavigationController *navigationController = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"SendToNavigationControllerID"];
    SendToViewController *sendToViewController = navigationController.viewControllers.firstObject;
    if (self.text) {
        sendToViewController.text = self.text;
        sendToViewController.sendMode = SendModeShareActivity;
    } else if (self.nodes) {
        sendToViewController.nodes = self.nodes;
        sendToViewController.sendMode = SendModeCloud;
    }
    
    return navigationController;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

@end
