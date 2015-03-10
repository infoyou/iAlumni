//
//  EventSignUpViewController.h
//  iAlumni
//
//  Created by Adam on 13-2-6.
//
//

#import "BaseListViewController.h"
#import "QuestionViewController.h"

@class Event;

@interface EventSignUpViewController : QuestionViewController
{
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;

@end
