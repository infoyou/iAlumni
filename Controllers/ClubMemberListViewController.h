//
//  ClubMemberListViewController.h
//  iAlumni
//
//  Created by Adam on 13-7-22.
//
//

#import "AlumniListViewController.h"
#import "PlainTabView.h"

@class Club;

@interface ClubMemberListViewController : AlumniListViewController <TapSwitchDelegate> {
    
  @private
  BOOL _needDistinguishCharge;
  
  PlainTabView *_tabSwitchView;
  
  NSInteger _selectedIdex;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
