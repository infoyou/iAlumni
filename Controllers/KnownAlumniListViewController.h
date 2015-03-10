//
//  KnownAlumniListViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "AlumniListViewController.h"
#import "PlainTabView.h"

@interface KnownAlumniListViewController : AlumniListViewController <TapSwitchDelegate> {
  @private
  
  PlainTabView *_tabSwitchView;
  
  KnownAlumnusType _tabType;
}

@end
