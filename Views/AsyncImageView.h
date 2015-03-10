//
//  AsyncImageView.h
//  CEIBS
//
//  Created by Adam on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol AsyncImageDelegate
- (void)setImage:(UIImage*)image aType:(NSUInteger)aType;
@end

@interface AsyncImageView : UIView {

    NSURLConnection* connection;
    NSMutableData* data;
    
    NSObject<AsyncImageDelegate>* _delegate;
    
//    NSUInteger _type;
}

@property (nonatomic, retain) NSObject<AsyncImageDelegate>* delegate;
@property (nonatomic) NSUInteger _type;

- (void)loadImageFromURL:(NSURL*)url;
- (UIImage*) image;

@end
