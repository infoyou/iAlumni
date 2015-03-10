//
//  AllScopeGroupHeaderView.h
//  iAlumni
//
//  Created by Adam on 12-10-8.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ClubManagementDelegate.h"

@class WXWLabel;

@interface AllScopeGroupHeaderView : UIView {
  @private
  
  id<ClubManagementDelegate> _delegate;
  
  WXWLabel *_titleLabel;
  
  GroupType _groupType;
  
  UIImageView *_textBackgroundView;
}

- (id)initWithFrame:(CGRect)frame
          groupType:(GroupType)groupType
           delegate:(id<ClubManagementDelegate>)delegate;

@end
