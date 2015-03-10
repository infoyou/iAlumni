//
//  StorePhotoCell.h
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "ECImageConsumerCell.h"


@interface StorePhotoCell : ECImageConsumerCell <UIScrollViewDelegate> {
  @private
  
  UIScrollView *_wallView;
  
  NSInteger _currentPageIndex;
  
  UIView *_boardView;
  
  UIButton *_leftButton;
  UIButton *_rightButton;
}

- (void)updateImageList:(NSArray *)imageList;

@end
