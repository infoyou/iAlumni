//
//  ItemListSectionView.h
//  iAlumni
//
//  Created by Adam on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface ItemListSectionView : UIView {
  WXWLabel *_titleLabel;
}

@property (nonatomic, retain) WXWLabel *titleLabel;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
