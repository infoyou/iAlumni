//
//  ClubDetailViewController.h
//  iAlumni
//
//  Created by Adam on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "ClubDetail.h"

@class BaseListViewController;
@class Club;

@interface ClubDetailViewController : WXWRootViewController <MKMapViewDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource, AsyncImageDelegate, UIGestureRecognizerDelegate>
{
  BOOL _autoLoaded;
  CGRect _frame;
  UIPopoverController *_popoverView;
  BOOL _needReload;
  
  CGFloat _imageX;
  CGFloat _labelX;
  
  BaseListViewController *_parentListVC;
}


- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
       parentListVC:(BaseListViewController *)parentListVC;

- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell;
- (void)fetchItems;
- (void)setImage:(UIImage*)image aType:(NSUInteger)aType;
- (void)loadSponsorDetail;

- (void)gotoUrl:(NSString*)url aTitle:(NSString*)title;
- (void)goCallPhone;
//- (void)goClubUserList;

@end
