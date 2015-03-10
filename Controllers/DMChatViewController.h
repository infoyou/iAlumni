//
//  DMChatViewController.h
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "ChatMessageListViewController.h"

@class Alumni;

@interface DMChatViewController : ChatMessageListViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC alumni:(Alumni *)alumni;

@end
