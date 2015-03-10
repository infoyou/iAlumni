#import <UIKit/UIKit.h>

@interface FixedCell : UITableViewCell

@property (nonatomic, retain)IBOutlet UILabel *titleLabel;
@property (nonatomic, retain)IBOutlet UIImageView *dotIcon;
- (void)drawCell;

@end

