//
//  BrandInfoCell.h
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import <UIKit/UIKit.h>
#import "FlatTableCell.h"

@class WelfareCellBoardView;
@class WXWLabel;
@class Brand;

@interface BrandInfoCell : FlatTableCell <UIWebViewDelegate> {
  @private
  
  Brand *_brand;
  
  WelfareCellBoardView *_boardView;
  
  CGFloat _textLimitedWidth;
  
  UIWebView *_contentWebView;
  WXWLabel *_titleLabel;
  WXWLabel *_nameLabel;
  WXWLabel *_callLabel;
  WXWLabel *_telLabel;
  
  BOOL _textContentLoaded;
  
  CGFloat _textContentHeight;
}

- (void)drawCellWithBrand:(Brand *)brand height:(CGFloat)height;

@end
