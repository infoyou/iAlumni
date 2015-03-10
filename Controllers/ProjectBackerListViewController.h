//
//  ProjectBackerListViewController.h
//  iAlumni
//
//  Created by Adam on 13-3-7.
//
//

#import "AlumniListViewController.h"

@interface ProjectBackerListViewController : AlumniListViewController {
  @private
  
  long long _eventId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

@end
