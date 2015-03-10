//
//  MessageListViewController.h
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "UPOMP.h"

@class Message;

@interface MessageListViewController : BaseListViewController <UPOMPDelegate>{
  
@private
  UPOMP *cpView;
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     messageTypes:(NSArray *)messageTypes;

@end
