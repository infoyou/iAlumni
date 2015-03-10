//
//  ECTextView.h
//  iAlumni
//
//  Created by Adam on 11-11-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECTextView : UITextView {
  NSString *placeholder;
  UIColor	*placeholderColor;
  UILabel *label;
}

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (id)initWithFrame:(CGRect)frame;
-(void)textChanged:(NSNotification*)notification;
@end
