//
//  ShakeResultViewController.m
//  iAlumni
//
//  Created by Adam on 12-10-27.
//
//

#import "ShakeResultViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@interface ShakeResultViewController ()

@end

@implementation ShakeResultViewController

#pragma mark - load data
- (void)loadAlumnus:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  _currentLoadTriggerType = triggerType;
  
  _loadForNewItem = forNew;
  
  
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}



@end
