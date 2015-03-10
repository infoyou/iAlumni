//
//  ProjectSurveyViewController.h
//  iAlumni
//
//  Created by Adam on 13-3-7.
//
//

#import "QuestionViewController.h"

@class Event;

@interface ProjectSurveyViewController : QuestionViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;

@end
