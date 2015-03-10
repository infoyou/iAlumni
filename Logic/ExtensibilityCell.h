
#import <UIKit/UIKit.h>

@interface ExtensibilityCell : UITableViewCell {
  @private
  
  BOOL _rotated;
}


@property (nonatomic, retain)IBOutlet UILabel *titleLabel;
@property (nonatomic, retain)IBOutlet UILabel *selectedLabel;
@property (nonatomic, retain)IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain)IBOutlet UIImageView *dotIcon;

- (void)changeArrowWithUp:(BOOL)up;
- (void)drawCell;

@end
