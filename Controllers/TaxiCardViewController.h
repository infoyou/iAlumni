//
//  TaxiCardViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWRootViewController.h"

@interface TaxiCardViewController : WXWRootViewController {
  
  @private
  
  NSString *_part1;
  NSString *_part2;
  NSString *_part3;
  NSString *_name;
  
  double _latitude;
  double _longitude;
}


- (id)initWithAddressPart1:(NSString *)part1
                     part2:(NSString *)part2
                     part3:(NSString *)part3 
                      name:(NSString *)name 
                    holder:(id)holder   
          backToHomeAction:(SEL)backToHomeAction
                  latitude:(double)latitude
                 longitude:(double)longitude;


@end
