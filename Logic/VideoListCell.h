//
//  VideoListCell.h
//  iAlumni
//
//  Created by Adam on 13-1-9.
//
//

#import "BaseUITableViewCell.h"
#import "ECImageConsumerCell.h"
#import "ECClickableElementDelegate.h"

@class Video;

@interface VideoListCell : ECImageConsumerCell//BaseUITableViewCell
{
  UILabel *titleLabel;
  UILabel *dateLabel;
  UILabel *timeLabel;
  
  UIImageView *imageView;
  UIImageView *markImageView;
  UIImageView *playImageView;
  
  NSString *imageUrl;

}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *markImageView;
@property (nonatomic, retain) UIImageView *playImageView;

@property (nonatomic, copy) NSString *imageUrl;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawVideo:(Video *)video;

@end
