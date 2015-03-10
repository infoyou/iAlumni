//
//  ECConnectorDelegate.h
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GlobalConstants.h"

@protocol ECConnectorDelegate <NSObject>

@optional
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType;

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType;

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType
closeAsyncLoadingView:(BOOL)closeAsyncLoadingView;

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType;

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url 
          contentType:(NSInteger)contentType;

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url;

- (void)parserConnectionError:(NSError *)error;
@end
