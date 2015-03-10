//
//  CurrentItemTextView.h
//  iAlumni
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWLabel.h"
#import "GlobalConstants.h"

@interface CurrentItemTextView : UIView {
  @private
  WXWLabel *_contentLabel;
}

- (void)updateContent:(NSString *)content;

@end
