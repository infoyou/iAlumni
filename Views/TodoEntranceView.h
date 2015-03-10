//
//  TodoEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;
@class CoreTextView;

@interface TodoEntranceView : UIView {
  @private
  
  id _entrance;
  
  SEL _action;
  
  UIImageView *_imageView;
  
  CoreTextView *_groupMsgView;
  CoreTextView *_eventMsgView;
  
  WXWLabel *_emptyMsgLabel;
}

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action;

//- (void)arrangeMessages;
//
//- (void)stopPlay;
//
//- (void)play;

@end
