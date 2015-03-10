//
//  AsyncImageView.m
//  CEIBS
//
//  Created by Adam on 11-10-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "GlobalConstants.h"

@implementation AsyncImageView

@synthesize delegate = _delegate;
@synthesize _type;

- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	[connection release];
    //    connection = nil;
	[data release]; 
    //    data = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)loadImageFromURL:(NSURL*)url {
	if (connection != nil) { 
        [connection release]; 
    } 
	if (data != nil) { 
        [data release]; 
    }
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:NETWORK_TIMEOUT];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data == nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048]; 
    }
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    RELEASE_OBJ(connection);
    
	if ([[self subviews] count]>0) {
		[[self subviews][0] removeFromSuperview];
	}
    
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
//	imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    imageView.layer.cornerRadius = 6.0f;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.borderColor = [UIColor grayColor].CGColor;
	[self addSubview:imageView];
    
	imageView.frame = self.bounds;
    
	[imageView setNeedsLayout];
	[self setNeedsLayout];
    
	[data release];
	data = nil;
    
    if (self.delegate) {
        [self.delegate setImage:[self image] aType:_type];
    }
}

- (UIImage*) image {
    if ([self subviews] && [[self subviews] count]>0) {
        UIImageView* iv = [self subviews][0];
        return [iv image];
    }else{
        return nil;
    }
}

@end
