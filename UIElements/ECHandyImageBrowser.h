//
//  ECHandyImageBrowser.h
//  iAlumni
//
//  Created by Adam on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWImageFetcherDelegate.h"


@interface ECHandyImageBrowser : UIView <WXWImageFetcherDelegate> {
@private
  NSString *_imageUrl;
  
  UIImageView *_imageView;
  UIView *_canvasView;
}

- (id)initWithFrame:(CGRect)frame
             imgUrl:(NSString *)imgUrl;

@end
