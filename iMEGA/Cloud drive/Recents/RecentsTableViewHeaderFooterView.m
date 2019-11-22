#import "RecentsTableViewHeaderFooterView.h"

@implementation RecentsTableViewHeaderFooterView 

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = UIColor.mnz_background;
    
    self.bottomSeparatorView.layer.borderColor = [UIColor mnz_separatorColorForTraitCollection:self.traitCollection].CGColor;
    self.bottomSeparatorView.layer.borderWidth = 0.5;
}

@end
