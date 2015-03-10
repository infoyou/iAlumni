//
//  ECFilterListDelegate.h
//  ExpatCircle
//
//  Created by Adam on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"

@protocol ECFilterListDelegate <NSObject>

@optional
#pragma mark - for feed filter/sort
- (void)showSortOptionList;
- (void)showFilterList;

#pragma mark - for favorited items
- (void)showFavoritedNews;
- (void)showFavoritedFeeds;
- (void)showFavoritedPeople;
- (void)showFavoritedQA;
- (void)showFavoritedVenue;

#pragma mark - Nearby
- (void)showDistanceList;
- (void)showTimeList;
- (void)showSortList;

#pragma mark - Video
- (void)showVideoTypeList;
- (void)showVideoSortList;

#pragma mark - invitation
- (void)showInvitedUsers;
- (void)showUninvitedUsers;

#pragma mark - nearby filter/sort
- (void)showNearbyFilterSortView;
- (void)searchNearbyWithFilter:(NearbyDistanceFilter)filterType 
                      sortType:(ServiceItemSortType)sortType
                      keywords:(NSString *)keywords;
- (void)filterSortNearbyItem;
- (void)showPreviousItems:(id)sender;
- (void)showNextItems:(id)sender;

#pragma mark - service item tips 
- (void)showServiceItemTips;

#pragma mark - active search function
- (void)activeSearchController;

@end
