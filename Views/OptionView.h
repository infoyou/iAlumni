//
//  OptionView.h
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "EventVoteDelegate.h"

@class WXWLabel;
@class Option;

@interface OptionView : UIView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  id<EventVoteDelegate> _delegate;
  
  WXWLabel *_contentLabel;
  
  UIImageView *_selectedIcon;
  
  Option *_option;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<EventVoteDelegate>)delegate;

- (void)drawViewWithFrame:(CGRect)frame option:(Option *)option color:(UIColor*)color;

@end
