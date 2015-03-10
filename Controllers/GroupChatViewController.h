//
//  GroupChatViewController.h
//  iAlumni
//
//  Created by Adam on 13-10-14.
//
//

#import "WXWRootViewController.h"
#import "ChatMessageListViewController.h"


@class Club;

@interface GroupChatViewController : ChatMessageListViewController {

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
