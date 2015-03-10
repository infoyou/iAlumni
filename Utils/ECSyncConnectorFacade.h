//
//  ECSyncConnector.h
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECConnector.h"
#import "GlobalConstants.h"

@interface ECSyncConnectorFacade : ECConnector {


}

#pragma mark - upload log
- (NSData *)uploadLog:(NSString *)logContent logFileName:(NSString*)logFileName;
- (NSData *)uploadLogData:(NSData *)data logFileName:(NSString*)logFileName;
- (NSData *)uploadLog:(NSString *)logContent;

@end
