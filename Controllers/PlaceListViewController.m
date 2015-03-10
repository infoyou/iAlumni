//
//  PlaceListViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlaceListViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "TextConstants.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "CoreDataUtils.h"
#import "PlaceCell.h"
#import "Place.h"

@implementation PlaceListViewController 

#pragma mark - refresh place list after location changed
- (void)refreshPlaceList:(NSNotification *)notification {
  [self refreshTable];
}

#pragma mark - lifecycle methods
/*
- (void)registerPlaceListChangeNotification {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(refreshPlaceList:)
                                               name:REFRESH_PLACE_LIST_NOTIFY
                                             object:nil];
}
 */

- (void)dealloc {
  /*
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:REFRESH_PLACE_LIST_NOTIFY 
                                                object:nil];
   */
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self refreshTable];
  
  [self checkListWhetherEmpty];
}

#pragma mark - override methods

- (void)configureMOCFetchConditions {
  self.entityName = @"Place";
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor];
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_fetchedRC.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"kPlaceCell";
  PlaceCell *cell = (PlaceCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
  }
  Place *place = [_fetchedRC objectAtIndexPath:indexPath];
  [cell drawPlace:place];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *selectedPlace = (Place *)[_fetchedRC objectAtIndexPath:indexPath];
  
  NSString *distance = [NSString stringWithFormat:@"%.01f %@", 
                        selectedPlace.distance.floatValue * 1000, 
                        LocaleStringForKey(NSMeterTitle, nil)];
  
  CGSize size = [distance sizeWithFont:FONT(13)
                     constrainedToSize:CGSizeMake(320, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
  
  size = [selectedPlace.placeName sizeWithFont:BOLD_FONT(14)
                             constrainedToSize:CGSizeMake(self.view.frame.size.width - 
                                                          size.width - MARGIN - MARGIN * 4, 
                                                          CGFLOAT_MAX) 
                                 lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat height = size.height + MARGIN * 4;

  if (height < 44.0f) {
    height = 44.0f;
  }
  return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  for (Place *place in _fetchedRC.fetchedObjects) {
    place.selected = @NO;
  }
  
  Place *selectedPlace = (Place *)[_fetchedRC objectAtIndexPath:indexPath];
  selectedPlace.selected = @YES;
  
  [WXWCoreDataUtils saveMOCChange:_MOC];
  
  [self.navigationController popViewControllerAnimated:YES];
}

@end
