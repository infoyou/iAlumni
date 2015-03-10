//
//  ChaterBubbleCell.h
//  iAlumni
//
//  Created by Adam on 13-10-14.
//
//

#import "ECImageConsumerCell.h"
#import "CMPopTipView.h"

@class Post;
@class ChaterBubbleCell;

@protocol ChatterDelegate <NSObject>

- (void)openProfile:(NSString *)alumniId;
- (void)openPhotoWithImageUrl:(NSString *)imageUrl;
- (void)registerIndexPathForPopViewCell:(ChaterBubbleCell *)cell;

@end

@interface ChaterBubbleCell : ECImageConsumerCell <CMPopTipViewDelegate> {
  @private
  id<ChatterDelegate> _chatterDelegate;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    chatterDelegate:(id<ChatterDelegate>)chatterDelegate;


- (void)drawCellWithChatInfo:(Post *)chatInfo;

- (void)dismissAllPopTipViews;
@end
