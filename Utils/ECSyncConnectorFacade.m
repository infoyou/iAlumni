//
//  ECSyncConnectorFacade.m
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECSyncConnectorFacade.h"
#import "CommonUtils.h"
#import "AppManager.h"

@implementation ECSyncConnectorFacade

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - upload log
- (NSMutableData *)assembleLogData:(NSDictionary *)dic 
                       logFileName:(NSString *)logFileName
                        logContent:(NSData *)logContent
                      originalData:(NSMutableData *)originalData {
    
    NSString *param = [CommonUtils convertParaToHttpBodyStr:dic];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\n", IALUMNI_FORM_BOUNDARY]];
    param = [param stringByAppendingString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attach\"; filename=\"%@\"\nContent-Type: application/octet-stream\n\n", 
                                            logFileName]];		
    
    [originalData appendData:[param dataUsingEncoding:NSUTF8StringEncoding 
                                 allowLossyConversion:YES]];
    
    [originalData appendData:logContent];
    
    // append footer
	NSString *footer = [NSString stringWithFormat:@"\n--%@--\n", IALUMNI_FORM_BOUNDARY];
	[originalData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:YES]];
    
    NSLog(@"params: %@", [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] autorelease]);
    return originalData;
}

- (NSData *)uploadLog:(NSString *)logContent logFileName:(NSString*)logFileName{
    NSDictionary *dic = nil;
    dic = @{@"action": @"error_upload",
           @"plat": @"i",
           @"type": @"iAlumni"};
    
    return [self syncPost:ERROR_LOG_UPLOAD_URL
                     data:[self assembleLogData:dic
                                    logFileName:logFileName
                                     logContent:[logContent dataUsingEncoding:NSUTF8StringEncoding]
                                   originalData:[NSMutableData data]]];
    /*
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"log_upload", @"action", 
           @"i", @"plat",
           VERSION, @"version",
           [AppManager instance].userId, @"user_id", 
           logFileName, @"attach",
           logContent, @"message", nil];
    
	return [self syncPost:ERROR_LOG_UPLOAD_URL paramDic:dic];
     */
}

- (NSData *)uploadLogData:(NSData *)data logFileName:(NSString*)logFileName {
  NSDictionary *dic = nil;
  dic = @{@"action": @"error_upload",
         @"plat": @"i",
         @"type": @"iAlumni"};
  
  return [self syncPost:ERROR_LOG_UPLOAD_URL
                   data:[self assembleLogData:dic
                                  logFileName:logFileName
                                   logContent:data
                                 originalData:[NSMutableData data]]];
  
}

- (NSData *)uploadLog:(NSString *)logContent {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"log_upload", 
         @"plat": @"i",
         @"version": VERSION,
         @"user_id": [AppManager instance].userId, 
         @"message": logContent};
  
  NSString *url = [CommonUtils assembleUrl:nil];
	return [self syncPost:url paramDic:dic];
}

@end
