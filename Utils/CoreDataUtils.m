//
//  CoreDataUtils.m
//  iAlumni
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CoreDataUtils.h"
#import "WXWDebugLogOutput.h"
#import "Report.h"
#import "Upcoming.h"
#import "Event.h"
#import "Tag.h"
#import "SortOption.h"
#import "Place.h"
#import "ComposerTag.h"
#import "ComposerPlace.h"
#import "Country.h"
#import "Post.h"
#import "Invitee.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "Distance.h"


#define MAX_SAVED_RECORD_COUNT      50

@implementation CoreDataUtils

#pragma mark - hot news
+ (void)clearOldItems:(NSManagedObjectContext *)MOC itemType:(ItemType)itemType {
  @autoreleasepool {
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    NSString *objName = nil;
    switch (itemType) {
      case NEWS_TY:
        objName = @"News";
        break;
        
      case FEED_TY:
        objName = @"Post";
        break;
        
      case QA_TY:
        objName = @"QAItem";
        break;
        
      default:
        break;
    }
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:objName
                                        inManagedObjectContext:MOC]];
    
    NSMutableArray *descriptors = [[[NSMutableArray alloc] init] autorelease];
    NSSortDescriptor *dateSortDesc = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
    [descriptors addObject:dateSortDesc];
    fetchRequest.sortDescriptors = descriptors;
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
    NSArray *result = [MOC executeFetchRequest:fetchRequest error:&error];
    if ([result count] > MAX_SAVED_RECORD_COUNT) {
      
      Report *lastNews = nil;
      Upcoming *lastPost = nil;
      Event *lastQAItem = nil;
      NSManagedObject *lastObj = result[(MAX_SAVED_RECORD_COUNT - 1)];
      switch (itemType) {
        case NEWS_TY:
          lastNews = (Report *)lastObj;
          break;
          
        case FEED_TY:
          lastPost = (Upcoming *)lastObj;
          break;
          
        case QA_TY:
          lastQAItem = (Event *)lastObj;
          break;
          
        default:
          break;
      }
      
      if (lastObj) {
        
        NSFetchRequest *deleteFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        deleteFetchRequest.entity = [NSEntityDescription entityForName:objName inManagedObjectContext:MOC];
        switch (itemType) {
          case NEWS_TY:
            deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastNews.date];
            break;
            
          case FEED_TY:
            deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastPost.date];
            break;
            
          case QA_TY:
            deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastQAItem.date];
            break;
            
          default:
            break;
        }
        
        deleteFetchRequest.includesPropertyValues = NO;
        
        error = nil;
        NSArray *toBeDeleteObjs = [MOC executeFetchRequest:deleteFetchRequest error:&error];
        for (id obj in toBeDeleteObjs) {
          long long objId = 0;
          switch (itemType) {
            case NEWS_TY:
              objId = ((Report *)lastObj).newsId.longLongValue;
              break;
              
            case FEED_TY:
              objId = ((Upcoming *)lastObj).eventId.longLongValue;
              break;
              
            case QA_TY:
              objId = ((Event *)lastObj).eventId.longLongValue;
              break;
              
            default:
              break;
          }
          
          NSPredicate *deleteCommentPredicate = [NSPredicate predicateWithFormat:@"(parentId == %lld)", objId];
          [WXWCoreDataUtils deleteEntitiesFromMOC:MOC entityName:@"Comment" predicate:deleteCommentPredicate];
          
          [MOC deleteObject:obj];
        }
        [WXWCoreDataUtils saveMOCChange:MOC];
      }
    }  
  }
}

#pragma mark - tag
+ (void)resetTags:(NSManagedObjectContext *)MOC clearAll:(BOOL)clearAll {
  NSArray *tags = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Tag" predicate:nil];
  if (clearAll) {
    for (Tag *tag in tags) {
      tag.selected = @NO;
    }
    
  } else {
    for (Tag *tag in tags) {
      if (tag.tagId.longLongValue == TAG_ALL_ID) {
        tag.selected = @YES;
      } else {
        tag.selected = @NO;
      }
    }
  }
  
  [WXWCoreDataUtils saveMOCChange:MOC];
}

+ (void)createComposerTagsForGroupId:(NSString *)groupId
                                 MOC:(NSManagedObjectContext *)MOC {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", groupId];
  
  NSArray *tags = [WXWCoreDataUtils fetchObjectsFromMOC:MOC
                                 entityName:@"Tag"
                                  predicate:predicate];
  for (Tag *tag in tags) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagId == %@)", tag.tagId];
    ComposerTag *checkPoint = (ComposerTag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"ComposerTag" predicate:predicate];
    if (checkPoint) {
      checkPoint.selected = @NO;
      checkPoint.tagName = tag.tagName;
      checkPoint.order = tag.order;
      continue;
    }
    
    ComposerTag *composerTag = (ComposerTag *)[NSEntityDescription insertNewObjectForEntityForName:@"ComposerTag" 
                                                                            inManagedObjectContext:MOC];
    composerTag.tagId = tag.tagId;
    composerTag.tagName = tag.tagName;
    composerTag.type = tag.type;
    composerTag.order = tag.order;
    composerTag.selected = @NO;
  }
  [WXWCoreDataUtils saveMOCChange:MOC];
}

#pragma mark - sort options
+ (void)prepareVenueSortOptions:(NSManagedObjectContext *)MOC {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SI_SORT_BY_DISTANCE_TY, VENUE_ITEM_TY];
  SortOption *checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                entityName:@"SortOption"
                                                                 predicate:predicate];
  
  NSString *name = LocaleStringForKey(NSSortByDistanceTitle, nil);
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *distanceOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                               inManagedObjectContext:MOC];
    distanceOption.optionId = @(SI_SORT_BY_DISTANCE_TY);
    distanceOption.optionName = name;
    distanceOption.selected = @YES;
    distanceOption.usageType = @(VENUE_ITEM_TY);
  }

  /*
  checkPoint = nil;
  name = LocaleStringForKey(NSSortByMyCountryRateTitle, nil);
  predicate = [NSPredicate predicateWithFormat:@"(optionId == %d)", SI_SORT_BY_MY_CO_LIKE_TY];
  checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"SortOption"
                                                     predicate:predicate];
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *myCountryOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                             inManagedObjectContext:MOC];
    myCountryOption.optionId = [NSNumber numberWithInt:SI_SORT_BY_MY_CO_LIKE_TY];
    myCountryOption.optionName = name;
    myCountryOption.selected = [NSNumber numberWithBool:NO];
    myCountryOption.usageType = [NSNumber numberWithInt:VENUE_ITEM_TY];
  }
  */
  
  checkPoint = nil;
  name = LocaleStringForKey(NSSortByCommonRateTitle, nil);
  predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))",
               SI_SORT_BY_LIKE_COUNT_TY, VENUE_ITEM_TY];
  checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"SortOption"
                                                     predicate:predicate];
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *likeCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                             inManagedObjectContext:MOC];
    likeCountOption.optionId = @(SI_SORT_BY_LIKE_COUNT_TY);
    likeCountOption.optionName = name;
    likeCountOption.selected = @NO;
    likeCountOption.usageType = @(VENUE_ITEM_TY);
  }

  checkPoint = nil;
  name = LocaleStringForKey(NSSortByCommentTitle, nil);
  predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SI_SORT_BY_COMMENT_COUNT_TY, VENUE_ITEM_TY];
  checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"SortOption"
                                                     predicate:predicate];
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *commentCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                             inManagedObjectContext:MOC];
    commentCountOption.optionId = @(SI_SORT_BY_COMMENT_COUNT_TY);
    commentCountOption.optionName = name;
    commentCountOption.selected = @NO;
    commentCountOption.usageType = @(VENUE_ITEM_TY);
  }

  SAVE_MOC(MOC);
}

+ (void)preparePostSortOptions:(NSManagedObjectContext *)MOC {  
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_ID_TY, POST_ITEM_TY];
  SortOption *checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                entityName:@"SortOption" 
                                                                 predicate:predicate];
  NSString *name = LocaleStringForKey(NSSortByCreateTimeTitle, nil);
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *createTimeOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption" 
                                                                               inManagedObjectContext:MOC];
    createTimeOption.optionId = @(SORT_BY_ID_TY);
    createTimeOption.optionName = name;
    createTimeOption.selected = @YES;
    createTimeOption.usageType = @(POST_ITEM_TY);
  }
  
  checkPoint = nil;
  predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_PRAISE_COUNT_TY, POST_ITEM_TY];
  checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"SortOption" 
                                                     predicate:predicate];
  name = LocaleStringForKey(NSSortByPraiseTitle, nil);
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *praiseCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption" 
                                                                                inManagedObjectContext:MOC];
    praiseCountOption.optionId = @(SORT_BY_PRAISE_COUNT_TY);
    praiseCountOption.optionName = name;
    praiseCountOption.selected = @NO;
    praiseCountOption.usageType = @(POST_ITEM_TY);
  }
  
  checkPoint = nil;
  predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_COMMENT_COUNT_TY, POST_ITEM_TY];
  checkPoint = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"SortOption" 
                                                     predicate:predicate];
  name = LocaleStringForKey(NSSortByCommentCountTitle, nil);
  if (checkPoint) {
    checkPoint.optionName = name;
  } else {
    SortOption *commentCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption" 
                                                                                 inManagedObjectContext:MOC];
    commentCountOption.optionId = @(SORT_BY_COMMENT_COUNT_TY);
    commentCountOption.optionName = name;
    commentCountOption.selected = @NO;
    commentCountOption.usageType = @(POST_ITEM_TY);
  }
  
  [WXWCoreDataUtils saveMOCChange:MOC];
  
}

+ (void)resetSortOptions:(NSManagedObjectContext *)MOC {
  NSArray *options = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"SortOption" predicate:nil];
  for (SortOption *option in options) {
    if (option.optionId.intValue == SORT_BY_ID_TY) {
      option.selected = @YES;
    } else {
      option.selected = @NO;
    }
  }
  [WXWCoreDataUtils saveMOCChange:MOC];
}

#pragma mark - place
+ (void)resetPlaces:(NSManagedObjectContext *)MOC {
  NSArray *places = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Place" predicate:nil];
  for (Place *place in places) {
    place.selected = @NO;
  }
  [WXWCoreDataUtils saveMOCChange:MOC];
}

+ (void)resetDistance:(NSManagedObjectContext *)MOC {
  NSArray *distances = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Distance" predicate:nil];
  for (Distance *distance in distances) {
    if (distance.valueFloat.floatValue == ALL_LOCATION_RADIUS) {
      distance.selected = @YES;
    } else {
      distance.selected = @NO;
    }
  }
  SAVE_MOC(MOC);
}

+ (void)resetComposerPlaces:(NSManagedObjectContext *)MOC {
  NSArray *places = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"ComposerPlace" predicate:nil];
  for (ComposerPlace *place in places) {
    place.selected = @NO;
  }
  [WXWCoreDataUtils saveMOCChange:MOC];  
}

+ (void)createComposerPlaces:(NSManagedObjectContext *)MOC {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeType == %d)", NORMAL_PLACE_TY];
  
  NSArray *places = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Place" predicate:predicate];
  for (Place *place in places) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", place.placeId];
    ComposerPlace *checkPoint = (ComposerPlace *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"ComposerPlace" predicate:predicate];
    if (checkPoint) {
      checkPoint.selected = @NO;
      continue;
    }
    
    ComposerPlace *composerPlace = (ComposerPlace *)[NSEntityDescription insertNewObjectForEntityForName:@"ComposerPlace"
                                                                                  inManagedObjectContext:MOC];
    composerPlace.placeId = place.placeId;
    composerPlace.cityName = place.cityName;
    composerPlace.placeName = place.placeName;        
    composerPlace.cityId = place.cityId;
    composerPlace.selected = @NO;
    composerPlace.centerItemId = place.centerItemId;
    composerPlace.distance = place.distance;
  }
  [WXWCoreDataUtils saveMOCChange:MOC];
}

#pragma mark - country
+ (void)resetCountries:(NSManagedObjectContext *)MOC {
  
  Country *country = (Country *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Country" predicate:SELECTED_PREDICATE];
  if (country) {
    country.selected = @NO;
  }
  
  [WXWCoreDataUtils saveMOCChange:MOC];
}

+ (void)resetCountryAllObjectName:(NSManagedObjectContext *)MOC {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(countryId == %lld)", CO_ALL_ID];
  Country *all = (Country *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Country" predicate:predicate];
  if (all) {
    all.selected = @YES;
    all.name = LocaleStringForKey(NSAllTitle, nil);
  }
}

#pragma mark - assemble email from address book
+ (void)resetSelectedInvitee:(NSManagedObjectContext *)MOC snsType:(UserSnsType)snsType {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sourceType == %d)", snsType];
  NSArray *invitees = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Invitee" predicate:predicate];
  for (Invitee *invitee in invitees) {
    invitee.selected = @NO;
  }
  
  SAVE_MOC(MOC);
}

@end
