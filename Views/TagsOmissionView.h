//
//  TagsOmissionView.h
//  iAlumni
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;

@interface TagsOmissionView : UIView {

  WXWLabel *_nameLabel;
@private
  UIImageView *_icon;
  
  NSManagedObjectContext *_MOC;
}

@property (nonatomic, retain) WXWLabel *nameLabel;

- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC;
- (void)arrangeViews:(NSString *)names;
@end
