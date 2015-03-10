//
//  DownloadedUserListViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-22.
//
//

#import "AlumniListViewController.h"

@interface DownloadedUserListViewController : AlumniListViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC itemId:(NSString *)itemId;

@end
