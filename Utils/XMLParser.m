//
//  XMLParser.m
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "XMLParser.h"
#import "UIUtils.h"
#import "NSDate+Reporting.h"
#import "TextConstants.h"
#import "CoreDataUtils.h"
#import "News.h"
#import "CommonUtils.h"
#import "Comment.h"
#import "AppManager.h"
#import "Tag.h"
#import "Place.h"
#import "Country.h"
#import "Member.h"
#import "Invitee.h"
#import "ItemGroup.h"
#import "ServiceItem.h"
#import "AlbumPhoto.h"
#import "Year.h"
#import "Messages.h"
#import "PointItem.h"
#import "Award.h"
#import "FavoritedServiceItem.h"
#import "FavoritedMember.h"
#import "iAlumniAppDelegate.h"
#import "WXWDebugLogOutput.h"
#import "TextConstants.h"
#import "EventSponsor.h"
#import "EventWinner.h"
#import "EventSignedUpAlumni.h"
#import "EventCheckinAlumni.h"
#import "CommonUtils.h"
#import "Event.h"
#import "EncryptUtil.h"
#import "ClassGroup.h"
#import "AppManager.h"
#import "Event.h"
#import "EventCity.h"
#import "Industry.h"
#import "Feedback.h"
#import "ClubDetail.h"
#import "ClubSimple.h"
#import "UIUtils.h"
#import "UserCountry.h"
#import "Alumni.h"
#import "Upcoming.h"
#import "Report.h"
#import "Club.h"
#import "Post.h"
#import "PostComment.h"
#import "AlumniDetail.h"
#import "Shake.h"
#import "Video.h"
#import "Chat.h"
#import "Distance.h"
#import "SharePost.h"
#import "PhoneNumber.h"
#import "RecommendedItem.h"
#import "ServiceItemSection.h"
#import "ServiceItemSectionParam.h"
#import "CouponItem.h"
#import "AD.h"
#import "FilterOption.h"
#import "SortOption.h"
#import "HomeGroup.h"
#import "LikedItemId.h"
#import "Liker.h"
#import "CheckedinMember.h"
#import "CheckedinItemId.h"
#import "AlumniFounder.h"
#import "Brand.h"
#import "EventTopic.h"
#import "Option.h"
#import "CoreTextMarkupParser.h"
#import "NSAttributedString+Encoding.h"
#import "News.h"
#import "PYMethod.h"
#import "NameCard.h"
#import "RecommendAlumni.h"
#import "ReferenceRelationship.h"
#import "AttractiveAlumni.h"
#import "KnownAlumni.h"
#import "JoinedGroup.h"
#import "Welfare.h"
#import "Sku.h"
#import "Store.h"
#import "Slogan.h"
#import "VideoPoster.h"

@implementation XMLParser

+ (void)traceErrorMessageForConnectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                          url:(NSString *)url
                                         code:(NSInteger)code
                                          doc:(CXMLDocument *)doc {
  
  if (connectorDelegate && code != HTTP_RESP_OK) {
    NSArray *respDescs = [doc nodesForXPath:@"//response/desc" error:nil];
    NSString *message = [respDescs.lastObject stringValue];
    message = [CommonUtils decodeAndReplacePlusForText:message];
    
    debugLog(@"error response description: %@ for url %@", message, url);
    [connectorDelegate traceParserXMLErrorMessage:message
                                              url:url];
  }
}


+ (BOOL)converStringToXML:(CXMLDocument **)doc contentStr:(NSString *)contentStr {
  NSError* error = nil;
  *doc = [[CXMLDocument alloc] initWithXMLString:contentStr
                                         options:0
                                           error:&error];
  if (error || nil == *doc) {
    debugLog(@"Parser xml failed: %@", [error domain]);
    [UIUtils alert:nil
           message:LocaleStringForKey(NSParserXmlErrMsg, nil)];
    return NO;
  }
  return YES;
}

+ (BOOL)parserResponseNode:(NSData *)xmlData
                       doc:(CXMLDocument **)doc
         connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                       url:(NSString *)url
                      type:(WebItemType)type {
  
  NSString *xmlStr = [[[NSString alloc] initWithData:xmlData
                                            encoding:NSUTF8StringEncoding] autorelease];
  if (EC_DEBUG) {
    NSLog(@"xml string: %@", xmlStr);
  }
  if (xmlStr == nil || [xmlStr isEqualToString:NULL_PARAM_VALUE] || xmlStr.length == 0) {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSParserXmlNullMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
    return NO;
  }
  
  NSRange resRange = [xmlStr rangeOfString:@"<response>"];
  NSInteger resCode = 0;
  
  NSString *contentStr = nil;
  
  if (resRange.length == 0) {
    resRange = [xmlStr rangeOfString:@"<contents>"];
    
    contentStr = xmlStr;
    
    if ([self converStringToXML:doc contentStr:contentStr]) {
      
      resCode = RESP_OK;
      
    } else {
      return NO;
    }
    
  } else {
    
    contentStr = [xmlStr substringFromIndex:resRange.location];
    
    if ([self converStringToXML:doc contentStr:contentStr]) {
      resCode = [[*doc nodesForXPath:@"//response/code" error:nil].lastObject stringValue].intValue;
    } else {
      return NO;
    }
    
  }
  
  if (resCode == APP_EXPIRED_CODE) {
    
    if ([AppManager instance].sso) {
      
      [[AppManager instance] beginSSOInitialicationProcess];
      
    } else {
      if (connectorDelegate) {
        [connectorDelegate registerSessionExpiredForUrl:url requestType:type];
      }
    }
    return NO;
  }
  
  [AppManager instance].sessionExpired = NO;
  
  [self traceErrorMessageForConnectorDelegate:connectorDelegate
                                          url:url
                                         code:resCode
                                          doc:*doc];
  
  return YES;
}

#pragma mark - user
+ (BOOL)handleUserVerify:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *userIds = [respDoc nodesForXPath:@"//response/user_id" error:nil];
    if (userIds.count > 0) {
      [AppManager instance].userId = [userIds.lastObject stringValue];
      [CommonUtils saveStringValueToLocal:[AppManager instance].userId key:USER_ID_LOCAL_KEY];
    }
    
    NSArray *usernames = [respDoc nodesForXPath:@"//response/user_name" error:nil];
    if (usernames.count > 0) {
      [AppManager instance].userName = [usernames.lastObject stringValue];
      [CommonUtils saveStringValueToLocal:[AppManager instance].userName key:USER_NAME_LOCAL_KEY];
    }
    
    NSArray *emails = [respDoc nodesForXPath:@"//response/email" error:nil];
    if (emails.count > 0) {
      [AppManager instance].email = [emails.lastObject stringValue];
      [CommonUtils saveStringValueToLocal:[AppManager instance].email key:USER_EMAIL_LOCAL_KEY];
    }
    
    NSArray *messages = [respDoc nodesForXPath:@"//response/message" error:nil];
    if (messages.count > 0) {
      [AppManager instance].systemMessage = [messages.lastObject stringValue];
    }
    
    NSArray *sessions = [respDoc nodesForXPath:@"//response/session_value" error:nil];
    if (sessions.count > 0) {
      [AppManager instance].sessionId = [sessions.lastObject stringValue];
    }
    
    NSArray *countryIds = [respDoc nodesForXPath:@"//response/country_id" error:nil];
    if (countryIds.count > 0) {
      [AppManager instance].countryId = [[countryIds.lastObject stringValue] longLongValue];
      [CommonUtils saveLongLongIntegerValueToLocal:[AppManager instance].countryId key:USER_COUNTRY_ID_LOCAL_KEY];
    }
    
    NSArray *countryNames = [respDoc nodesForXPath:@"//response/country_name" error:nil];
    if (countryNames.count > 0) {
      [AppManager instance].countryName = [countryNames.lastObject stringValue];
      [CommonUtils saveStringValueToLocal:[AppManager instance].countryName key:USER_COUNTRY_NAME_LOCAL_KEY];
    }
    
    NSArray *cityIds = [respDoc nodesForXPath:@"//response/city_id" error:nil];
    if (cityIds.count > 0) {
      [AppManager instance].cityId = [[cityIds.lastObject stringValue] longLongValue];
      [CommonUtils saveLongLongIntegerValueToLocal:[AppManager instance].cityId
                                               key:USER_CITY_ID_LOCAL_KEY];
    }
    
    NSArray *cityNames = [respDoc nodesForXPath:@"//response/city_name" error:nil];
    if (cityNames.count > 0) {
      [AppManager instance].cityName = [cityNames.lastObject stringValue];
      [CommonUtils saveStringValueToLocal:[AppManager instance].cityName
                                      key:USER_CITY_NAME_LOCAL_KEY];
    }
    
    NSArray *groups = [respDoc nodesForXPath:@"//response/default_groups/group" error:nil];
    for (CXMLElement *groupEl in groups) {
      NSArray *groupTypes = [groupEl elementsForName:@"group_type"];
      GroupType groupType = 0;
      if (groupTypes.count > 0) {
        groupType = [[groupTypes.lastObject stringValue] intValue];
      }
      
      NSArray *groupIds = [groupEl elementsForName:@"group_id"];
      long long groupId = 0ll;
      if (groupIds.count > 0) {
        groupId = [[groupIds.lastObject stringValue] longLongValue];
      }
      switch (groupType) {
        case FEEDS_GP_TY:
          [AppManager instance].feedGroupId = @(groupId);
          break;
          
        case QA_GP_TY:
          [AppManager instance].qaGroupId = @(groupId);
          break;
          
        default:
          break;
      }
    }
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)handleSessionReferencement:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    [AppManager instance].sessionId = [[respDoc nodesForXPath:@"//response/sessionId" error:nil].lastObject stringValue];
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load news
+ (BOOL)handleLoadFavoritedNews:(CXMLDocument *)respDoc
                            MOC:(NSManagedObjectContext *)MOC
                    favoritedBy:(long long)favoritedBy
          beCheckDetailedItemId:(long long)beCheckDetailedItemId {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *newsList = [respDoc nodesForXPath:@"//post" error:nil];
    
    [AppManager instance].loadedItemCount = 0;
    
    BOOL needRemovedUnfavoritedItem = YES;
    for (CXMLElement *newsEl in newsList) {
      //      FavoritedNews *news = (FavoritedNews *)[self parserNews:newsEl
      //                                                 forFavorited:YES
      //                                                          MOC:MOC
      //                                       showNewLoadedItemCount:NO];
      //      news.favoritedBy = [NSNumber numberWithLongLong:favoritedBy];
      //
      //      if (beCheckDetailedItemId == news.newsId.longLongValue) {
      //        needRemovedUnfavoritedItem = NO;
      //      }
    }
    
    if (needRemovedUnfavoritedItem) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(newsId == %lld)",beCheckDetailedItemId];
      DELETE_OBJS_FROM_MOC(MOC, @"FavoritedNews", predicate);
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

#pragma mark - load comment

+ (Comment *)parserLoadedComment:(CXMLElement *)commentEl
                             MOC:(NSManagedObjectContext *)MOC
                       commentId:(long long)commentId {
  
  Comment *comment = (Comment *)[NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                              inManagedObjectContext:MOC];
  comment.commentId = @(commentId);
  
  NSArray *parentIds = [commentEl elementsForName:@"post_id"];
  if ([parentIds count] > 0) {
    comment.parentId = @([[[parentIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *timestamps = [commentEl elementsForName:@"date"];
  if ([timestamps count] > 0) {
    NSTimeInterval timestamp = [[[timestamps lastObject] stringValue] doubleValue];
    comment.timestamp = @(timestamp);
    comment.date = [CommonUtils simpleFormatDate:[CommonUtils convertDateTimeFromUnixTS:timestamp]
                                  secondAccuracy:YES];
  }
  
  NSArray *authorIds = [commentEl elementsForName:@"user_id"];
  if ([authorIds count] > 0) {
    comment.authorId = @([[[authorIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *authorNames = [commentEl elementsForName:@"user_name"];
  if ([authorNames count] > 0) {
    comment.authorName = [CommonUtils decodeAndReplacePlusForText:[authorNames.lastObject stringValue]];
  }
  
  NSArray *authorTypes = [commentEl elementsForName:@"user_type"];
  if (authorTypes.count > 0) {
    comment.authorType = @([authorTypes.lastObject stringValue].intValue);
  }
  
  NSArray *contents = [commentEl elementsForName:@"message"];
  if ([contents count] > 0) {
    comment.content = [CommonUtils decodeAndReplacePlusForText:[contents.lastObject stringValue]];
  }
  
  NSArray *imageUrls = [commentEl elementsForName:@"original_pic"];
  if ([imageUrls count] > 0) {
    comment.imageUrl = [[imageUrls lastObject] stringValue];
    comment.imageAttached = @YES;
  } else {
    comment.imageAttached = @NO;
  }
  
  NSArray *thumbnailUrls = [commentEl elementsForName:@"thumbnail_pic"];
  if ([thumbnailUrls count] > 0) {
    comment.thumbnailUrl = [[thumbnailUrls lastObject] stringValue];
  }
  
  NSArray *authorPicUrls = [commentEl elementsForName:@"profile_image_url"];
  if ([authorPicUrls count] > 0) {
    comment.authorPicUrl = [[authorPicUrls lastObject] stringValue];
  }
  
  return comment;
}

+ (BOOL)handleLoadComments:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *commentList = [respDoc nodesForXPath:@"//comment" error:nil];
    
    for (CXMLElement *commentEl in commentList) {
      long long commentId = 0;
      
      NSArray *commentIds = [commentEl elementsForName:@"comments_id"];
      if ([commentIds count] > 0) {
        commentId = [[[commentIds lastObject] stringValue] longLongValue];
      }
      
      NSArray *authorPicUrls = [commentEl elementsForName:@"profile_image_url"];
      NSString *authorPicUrl = nil;
      if ([authorPicUrls count] > 0) {
        authorPicUrl = [authorPicUrls.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(commentId == %lld)", commentId];
      Comment *checkPoint = (Comment *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                 entityName:@"Comment"
                                                                  predicate:predicate];
      if (checkPoint) {
        checkPoint.authorPicUrl = authorPicUrl;
        continue;
      }
      
      [self parserLoadedComment:commentEl MOC:MOC commentId:commentId];
      
    }
    
    return [CommonUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

+ (BOOL)handleLoadFirstThreeComments:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    
    NSArray *commentList = [respDoc nodesForXPath:@"//comment" error:nil];
    for (CXMLElement *commentEl in commentList) {
      long long commentId = 0;
      
      NSArray *commentIds = [commentEl elementsForName:@"comments_id"];
      if ([commentIds count] > 0) {
        commentId = [[[commentIds lastObject] stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(commentId == %lld)", commentId];
      if ([WXWCoreDataUtils objectInMOC:MOC entityName:@"Comment" predicate:predicate]) {
        continue;
      }
      
      Comment *createdComment = [self parserLoadedComment:commentEl MOC:MOC commentId:commentId];
      [comments addObject:createdComment];
    }
    
    NSArray *sortedComments = [comments sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSInteger i = 3; i < sortedComments.count; i++) {
      [MOC deleteObject:sortedComments[i]];
    }
    
    RELEASE_OBJ(comments);
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

#pragma mark - load user profile

+ (void)parserPointsForMember:(CXMLElement *)memberEl
                     memberId:(long long)memberId
           currentTotalPoints:(NSInteger)currentTotalPoints
                          MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *creditLists = [memberEl elementsForName:@"credits"];
  if (creditLists.count > 0) {
    CXMLElement *creditListEl = (CXMLElement *)creditLists.lastObject;
    NSArray *credits = [creditListEl elementsForName:@"credit"];
    for (CXMLElement *creditEl in credits) {
      NSArray *types = [creditEl elementsForName:@"type_id"];
      NSInteger type = 0;
      if (types.count > 0) {
        type = [[types.lastObject stringValue] intValue];
      }
      
      NSArray *messages = [creditEl elementsForName:@"desc"];
      NSString *message = nil;
      if (messages.count > 0) {
        message = [CommonUtils decodeAndReplacePlusForText:[messages.lastObject stringValue]];
      }
      
      NSArray *details = [creditEl elementsForName:@"desc_detail"];
      NSString *detail = nil;
      if (details.count > 0) {
        detail = [CommonUtils decodeAndReplacePlusForText:[details.lastObject stringValue]];
      }
      
      NSArray *pointUnitValues = [creditEl elementsForName:@"score"];
      NSInteger pointUnitValue = 0;
      if (pointUnitValues.count > 0) {
        pointUnitValue = [[pointUnitValues.lastObject stringValue] intValue];
      }
      
      NSArray *pointTotals = [creditEl elementsForName:@"score_total"];
      NSInteger pointTotal = 0;
      if (pointTotals.count > 0) {
        pointTotal = [[pointTotals.lastObject stringValue] intValue];
      }
      
      NSArray *experienceUnitValues = [creditEl elementsForName:@"experience"];
      NSInteger experienceUnitValue = 0;
      if (experienceUnitValues.count > 0) {
        experienceUnitValue = [[experienceUnitValues.lastObject stringValue] intValue];
      }
      
      NSArray *experienceTotals = [creditEl elementsForName:@"experience_total"];
      NSInteger experienceTotal = 0;
      if (experienceTotals.count > 0) {
        experienceTotal = [[experienceTotals.lastObject stringValue] intValue];
      }
      
      NSArray *counts = [creditEl elementsForName:@"counts"];
      NSInteger count = 0;
      if (counts.count > 0) {
        count = [[counts.lastObject stringValue] intValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (memberId == %lld))", type, memberId];
      PointItem *checkPoint = (PointItem *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"PointItem" predicate:predicate];
      if (checkPoint) {
        checkPoint.message = message;
        checkPoint.detail = detail;
        checkPoint.pointUnitValue = @(pointUnitValue);
        checkPoint.experienceUnitValue = @(experienceUnitValue);
        checkPoint.count = @(count);
        checkPoint.pointTotal = @(pointTotal);
        checkPoint.experienceTotal = @(experienceTotal);
        continue;
      }
      
      PointItem *pointItem = (PointItem *)[NSEntityDescription insertNewObjectForEntityForName:@"PointItem"
                                                                        inManagedObjectContext:MOC];
      pointItem.type = @(type);
      pointItem.memberId = @(memberId);
      pointItem.message = message;
      pointItem.detail = detail;
      pointItem.pointUnitValue = @(pointUnitValue);
      pointItem.experienceUnitValue = @(experienceUnitValue);
      pointItem.count = @(count);
      pointItem.pointTotal = @(pointTotal);
      pointItem.experienceTotal = @(experienceTotal);
    }
    
    // create total points item
    NSPredicate *allItemPredicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (memberId == %lld))", TOTAL_PT_TY, memberId];
    PointItem *allPointItem = (PointItem *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                     entityName:@"PointItem"
                                                                      predicate:allItemPredicate];
    if (nil == allPointItem) {
      allPointItem = (PointItem *)[NSEntityDescription insertNewObjectForEntityForName:@"PointItem" inManagedObjectContext:MOC];
      allPointItem.type = @(TOTAL_PT_TY);
      allPointItem.memberId = @(memberId);
    }
    allPointItem.pointTotal = @(currentTotalPoints);
    allPointItem.message = [NSString stringWithFormat:LocaleStringForKey(NSTotalPointsTitle, nil), currentTotalPoints];
  }
}

+ (void)parserAwardsForMember:(CXMLElement *)memberEl
                     memberId:(long long)memberId
                          MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *creditLists = [memberEl elementsForName:@"awards"];
  if (creditLists.count > 0) {
    CXMLElement *creditListEl = (CXMLElement *)creditLists.lastObject;
    NSArray *credits = [creditListEl elementsForName:@"award"];
    NSInteger allItemsTotal = 0;
    for (CXMLElement *creditEl in credits) {
      NSArray *types = [creditEl elementsForName:@"type_id"];
      NSInteger type = 0;
      if (types.count > 0) {
        type = [[types.lastObject stringValue] intValue];
      }
      
      NSArray *messages = [creditEl elementsForName:@"desc"];
      NSString *message = nil;
      if (messages.count > 0) {
        message = [CommonUtils decodeAndReplacePlusForText:[messages.lastObject stringValue]];
      }
      
      NSArray *details = [creditEl elementsForName:@"desc_detail"];
      NSString *detail = nil;
      if (details.count > 0) {
        detail = [CommonUtils decodeAndReplacePlusForText:[details.lastObject stringValue]];
      }
      
      NSArray *pointUnitValues = [creditEl elementsForName:@"score"];
      NSInteger pointUnitValue = 0;
      if (pointUnitValues.count > 0) {
        pointUnitValue = [[pointUnitValues.lastObject stringValue] intValue];
      }
      
      NSArray *pointTotals = [creditEl elementsForName:@"score_total"];
      NSInteger pointTotal = 0;
      if (pointTotals.count > 0) {
        pointTotal = [[pointTotals.lastObject stringValue] intValue];
      }
      allItemsTotal += pointTotal;
      
      NSArray *experienceUnitValues = [creditEl elementsForName:@"experience"];
      NSInteger experienceUnitValue = 0;
      if (experienceUnitValues.count > 0) {
        experienceUnitValue = [[experienceUnitValues.lastObject stringValue] intValue];
      }
      
      NSArray *experienceTotals = [creditEl elementsForName:@"experience_total"];
      NSInteger experienceTotal = 0;
      if (experienceTotals.count > 0) {
        experienceTotal = [[experienceTotals.lastObject stringValue] intValue];
      }
      
      NSArray *counts = [creditEl elementsForName:@"counts"];
      NSInteger count = 0;
      if (counts.count > 0) {
        count = [[counts.lastObject stringValue] intValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (memberId == %lld))", type, memberId];
      Award *checkPoint = (Award *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Award" predicate:predicate];
      if (checkPoint) {
        checkPoint.message = message;
        checkPoint.detail = detail;
        checkPoint.pointUnitValue = @(pointUnitValue);
        checkPoint.experienceUnitValue = @(experienceUnitValue);
        checkPoint.count = @(count);
        checkPoint.pointTotal = @(pointTotal);
        checkPoint.experienceTotal = @(experienceTotal);
        continue;
      }
      
      Award *award = (Award *)[NSEntityDescription insertNewObjectForEntityForName:@"Award"
                                                            inManagedObjectContext:MOC];
      award.type = @(type);
      award.memberId = @(memberId);
      award.message = message;
      award.detail = detail;
      award.pointUnitValue = @(pointUnitValue);
      award.experienceUnitValue = @(experienceUnitValue);
      award.count = @(count);
      award.pointTotal = @(pointTotal);
      award.experienceTotal = @(experienceTotal);
    }
  }
}

+ (NSManagedObject *)parserUserElement:(CXMLElement *)memberEl
                                   MOC:(NSManagedObjectContext *)MOC
                          forFavorited:(BOOL)forFavorited {
  // get user id
  
  long long memberId = 0;
  NSArray *memberIds = [memberEl elementsForName:@"user_id"];
  if (memberIds.count > 0) {
    memberId = [[[memberIds lastObject] stringValue] longLongValue];
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(memberId == %lld)", memberId];
  NSManagedObject *checkPoint = nil;
  if (!forFavorited) {
    checkPoint = [WXWCoreDataUtils fetchObjectFromMOC:MOC
                                           entityName:@"Member"
                                            predicate:predicate];
  } else {
    checkPoint = [WXWCoreDataUtils fetchObjectFromMOC:MOC
                                           entityName:@"FavoritedMember"
                                            predicate:predicate];
  }
  
  NSManagedObject *member = nil;
  
  if (checkPoint) {
    member = checkPoint;
  } else {
    if (!forFavorited) {
      member = (Member *)[NSEntityDescription insertNewObjectForEntityForName:@"Member"
                                                       inManagedObjectContext:MOC];
    } else {
      member = (FavoritedMember *)[NSEntityDescription insertNewObjectForEntityForName:@"FavoritedMember"
                                                                inManagedObjectContext:MOC];
    }
  }
  
  ((Member *)member).memberId = @(memberId);
  
  ((Member *)member).likeItems = @NO;
  
  NSArray *favoriteds = [memberEl elementsForName:@"is_favorited"];
  if (favoriteds.count > 0) {
    BOOL favorited = [[favoriteds.lastObject stringValue] intValue] == 1 ? YES : NO;
    ((Member *)member).favorited = @(favorited);
  }
  
  NSArray *photoUrls = [memberEl elementsForName:@"profile_image_url"];
  if (photoUrls.count > 0) {
    ((Member *)member).photoUrl = [[photoUrls lastObject] stringValue];
  }
  
  NSArray *bigPhotoUrls = [memberEl elementsForName:@"profile_image_big_url"];
  if (bigPhotoUrls.count > 0) {
    ((Member *)member).bigPhotoUrl = [[bigPhotoUrls lastObject] stringValue];
  }
  
  NSArray *names = [memberEl elementsForName:@"user_name"];
  if (names.count > 0) {
    ((Member *)member).name = [CommonUtils replacePlusForText:[names.lastObject stringValue]];
  }
  
  NSArray *desc = [memberEl elementsForName:@"description"];
  if (desc.count > 0) {
    ((Member *)member).bio = [CommonUtils decodeAndReplacePlusForText:[desc.lastObject stringValue]];
  }
  
  NSArray *phones = [memberEl elementsForName:@"mobile_number"];
  if (phones.count > 0) {
    ((Member *)member).phoneNumber = [CommonUtils decodeForText:[phones.lastObject stringValue]];
    ((Member *)member).phoneNumber = [((Member *)member).phoneNumber stringByReplacingOccurrencesOfString:@" "
                                                                                               withString:NULL_PARAM_VALUE];
  }
  
  NSArray *emails = [memberEl elementsForName:@"email"];
  if (emails.count > 0) {
    ((Member *)member).email = [[emails lastObject] stringValue];
  }
  
  NSString *cityName = nil;
  switch ([WXWCommonUtils currentLanguage]) {
    case EN_TY:
    {
      NSArray *cityENNames = [memberEl elementsForName:@"city_en"];
      if (cityENNames.count > 0) {
        cityName = [CommonUtils decodeAndReplacePlusForText:[cityENNames.lastObject stringValue]];
      }
      break;
    }
      
    case ZH_HANS_TY:
    {
      NSArray *cityCNNames = [memberEl elementsForName:@"city_cn"];
      if (cityCNNames.count > 0) {
        cityName = [CommonUtils decodeAndReplacePlusForText:[cityCNNames.lastObject stringValue]];
      }
      break;
    }
      
    default:
      break;
  }
  ((Member *)member).cityName = cityName;
  
  NSArray *cityIds = [memberEl elementsForName:@"city_id"];
  if (cityIds.count > 0) {
    ((Member *)member).cityId = @([[[cityIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *countryIds = [memberEl elementsForName:@"country_id"];
  if (countryIds.count > 0) {
    ((Member *)member).countryId = @([[[countryIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *countryNames = [memberEl elementsForName:@"country"];
  if (countryNames.count > 0) {
    ((Member *)member).countryName = [[countryNames lastObject] stringValue];
  }
  
  NSArray *points = [memberEl elementsForName:@"score"];
  if (points.count > 0) {
    ((Member *)member).points = @([[[points lastObject] stringValue] intValue]);
  }
  
  NSArray *grades = [memberEl elementsForName:@"score_grade"];
  if (grades.count > 0) {
    ((Member *)member).grade = @([[grades.lastObject stringValue] intValue]);
  }
  
  NSArray *years = [memberEl elementsForName:@"living_years"];
  if (years.count > 0) {
    ((Member *)member).years = [years.lastObject stringValue];
  }
  
  NSArray *feedCounts = [memberEl elementsForName:@"feeds_count"];
  if (feedCounts.count > 0) {
    ((Member *)member).feedCount = @([[feedCounts.lastObject stringValue] intValue]);
  }
  
  NSArray *answerCounts = [memberEl elementsForName:@"answer_count"];
  if (answerCounts.count > 0) {
    ((Member *)member).answerCount = @([[answerCounts.lastObject stringValue] intValue]);
  }
  
  NSInteger favoritedItemCount = 0;
  NSArray *favoritedFeedCounts = [memberEl elementsForName:@"fav_feeds_count"];
  if (favoritedFeedCounts.count > 0) {
    favoritedItemCount += [[favoritedFeedCounts.lastObject stringValue] intValue];
  }
  
  NSArray *favoritedNewsCounts = [memberEl elementsForName:@"fav_news_count"];
  if (favoritedNewsCounts.count > 0) {
    favoritedItemCount += [[favoritedNewsCounts.lastObject stringValue] intValue];
  }
  
  NSArray *favoritedQuestionCounts = [memberEl elementsForName:@"fav_questions_count"];
  if (favoritedQuestionCounts.count > 0) {
    favoritedItemCount += [[favoritedQuestionCounts.lastObject stringValue] intValue];
  }
  
  NSArray *favoritedVenueCounts = [memberEl elementsForName:@"fav_shops_count"];
  if (favoritedVenueCounts.count > 0) {
    favoritedItemCount += [[favoritedVenueCounts.lastObject stringValue] intValue];
  }
  
  NSArray *favoritedMemberCounts = [memberEl elementsForName:@"person_count"];
  if (favoritedMemberCounts.count > 0) {
    favoritedItemCount += [[favoritedMemberCounts.lastObject stringValue] intValue];
  }
  
  ((Member *)member).favoriteCount = @(favoritedItemCount);
  
  [self parserPointsForMember:memberEl
                     memberId:memberId
           currentTotalPoints:((Member *)member).points.intValue
                          MOC:MOC];
  
  [self parserAwardsForMember:memberEl
                     memberId:memberId
                          MOC:MOC];
  
  return member;
}

+ (BOOL)handleLoadUserProfile:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *memberList = [respDoc nodesForXPath:@"//user_info" error:nil];
    
    for (CXMLElement *memberEl in memberList) {
      [self parserUserElement:memberEl MOC:MOC forFavorited:NO];
    }
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

#pragma mark - favorited user list
+ (BOOL)handleFavoritedUserList:(CXMLDocument *)respDoc
                            MOC:(NSManagedObjectContext *)MOC
                    favoritedBy:(long long)favoritedBy
          beCheckDetailedItemId:(long long)beCheckDetailedItemId {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *memberList = [respDoc nodesForXPath:@"//users/user" error:nil];
    
    BOOL needRemovedUnfavoritedItem = YES;
    for (CXMLElement *memberEl in memberList) {
      FavoritedMember *member = (FavoritedMember *)[self parserUserElement:memberEl
                                                                       MOC:MOC
                                                              forFavorited:YES];
      member.favoritedBy = @(favoritedBy);
      
      if (beCheckDetailedItemId == member.memberId.longLongValue) {
        needRemovedUnfavoritedItem = NO;
      }
    }
    
    if (needRemovedUnfavoritedItem) {
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(memberId == %lld)",beCheckDetailedItemId];
      DELETE_OBJS_FROM_MOC(MOC, @"FavoritedMember", predicate);
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

#pragma mark - favorite
+ (BOOL)handleFavoriteItem:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)parserLikeItem:(NSData *)xmlData
     hashedLikedItemId:(NSString *)hashedLikedItemId
    originalLikeStatus:(BOOL)originalLikeStatus
              memberId:(long long)memberId
                   MOC:(NSManagedObjectContext *)MOC
     connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                   url:(NSString *)url
                  type:(WebItemType)type {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
		return NO;
	}
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(memberId == %lld)", memberId];
    
    Liker *member = (Liker *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                       entityName:@"Liker"
                                                        predicate:predicate];
    if (member) {
      if (originalLikeStatus) {
        // user unlike this item
        predicate = [NSPredicate predicateWithFormat:@"((itemId == %@) AND (ANY likedBy.memberId ==%lld))",
                     hashedLikedItemId, memberId];
        LikedItemId *likedItemId = (LikedItemId *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                            entityName:@"LikedItemId"
                                                                             predicate:predicate];
        if (likedItemId) {
          
          // delete the LikedItemId object from to-many relationship of Member and MOC after
          // user executes the unlike action
          [member removeLikedItemIdsObject:likedItemId];
          [WXWCoreDataUtils deleteEntitiesFromMOC:MOC entities:@[likedItemId]];
        }
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

#pragma mark - check in for nearby service item

+ (CheckinResultType)parserCheckin:(NSData *)xmlData
                 connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                               url:(NSString *)url {
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:ITEM_CHECKIN_TY]) {
		return CHECKIN_FAILED_TY;
	}
  
  return [self parserResponseCode:doc];
}

#pragma mark - like
+ (BOOL)handleLikeItem:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - modify user icon
+ (BOOL)handleModifyUserIcon:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *respCodes = [respDoc nodesForXPath:@"//response/avatar_url"
                                          error:nil];
    [AppManager instance].userImgUrl = [respCodes.lastObject stringValue];
    
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - parser common response
+ (BOOL)handleCommonResponse:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load QA item
+ (void)parserQAItemComments:(CXMLElement *)qaItemEl
                         MOC:(NSManagedObjectContext *)MOC
                      itemId:(long long)itemId {
  NSArray *commentLists = [qaItemEl elementsForName:@"comment_list"];
  CXMLElement *commentList = (CXMLElement *)commentLists.lastObject;
  NSArray *comments = [commentList elementsForName:@"comment"];
  for (CXMLElement *commentEl in comments) {
    NSArray *commentIds = [commentEl elementsForName:@"comments_id"];
    long long commentId = 0ll;
    if (commentIds.count > 0) {
      commentId = [[commentIds.lastObject stringValue] longLongValue];
    }
    
    NSPredicate *commentPredicate = [NSPredicate predicateWithFormat:@"(commentId == %ld)", commentId];
    
    NSArray *profileImgUrls = [commentEl elementsForName:@"profile_image_url"];
    NSString *authorPicUrl = nil;
    if ([profileImgUrls count]) {
      authorPicUrl = [[profileImgUrls lastObject] stringValue];
    }
    
    Comment *checkPoint = (Comment *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                               entityName:@"Comment"
                                                                predicate:commentPredicate];
    
    if (checkPoint) {
      checkPoint.authorPicUrl = authorPicUrl;
      continue;
    }
    
    Comment *comment = (Comment *)[NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                                inManagedObjectContext:MOC];
    comment.commentId = @(commentId);
    
    comment.parentId = @(itemId);
    
    NSArray *commentMsgs = [commentEl elementsForName:@"message"];
    if (commentMsgs.count > 0) {
      comment.content = [CommonUtils decodeAndReplacePlusForText:[commentMsgs.lastObject stringValue]];
    }
    
    NSArray *commentTimestamps = [commentEl elementsForName:@"date"];
    if (commentTimestamps.count > 0) {
      NSTimeInterval timestamp = [[commentTimestamps.lastObject stringValue] doubleValue];
      comment.timestamp = @(timestamp);
      
      comment.date = [CommonUtils simpleFormatDate:[CommonUtils convertDateTimeFromUnixTS:timestamp]
                                    secondAccuracy:YES];
    }
    
    NSArray *authorIds = [commentEl elementsForName:@"user_id"];
    if ([authorIds count] > 0) {
      comment.authorId = @([[[authorIds lastObject] stringValue] longLongValue]);
    }
    
    NSArray *authorNames = [commentEl elementsForName:@"user_name"];
    if (authorNames.count > 0) {
      comment.authorName = [CommonUtils decodeAndReplacePlusForText:[authorNames.lastObject stringValue]];
    }
    
    NSArray *imageUrls = [commentEl elementsForName:@"original_pic"];
    if ([imageUrls count] > 0) {
      comment.imageUrl = [[imageUrls lastObject] stringValue];
      comment.imageAttached = @YES;
    } else {
      comment.imageAttached = @NO;
    }
    
    NSArray *thumbnailUrls = [commentEl elementsForName:@"thumbnail_pic"];
    if ([thumbnailUrls count] > 0) {
      comment.thumbnailUrl = [[thumbnailUrls lastObject] stringValue];
    }
    
    comment.authorPicUrl = authorPicUrl;
    
  }
}

#pragma mark - delete post
+ (BOOL)handleDeleteFeed:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - delete comment
+ (BOOL)handleDeleteComment:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - delete question
+ (BOOL)handleDeleteQuestion:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load likers
+ (void)resetAllLikerStatus:(NSManagedObjectContext *)MOC {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(likeItems == 1)"];
  NSArray *likers = [WXWCoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Member" predicate:predicate];
  for (Member *member in likers) {
    member.likeItems = @NO;
  }
  
  SAVE_MOC(MOC);
}

+ (void)assembleAlumniBaseInfo:(Member *)member
                      memberId:(long long)memberId
                      memberEl:(CXMLElement *)memberEl {
  
  member.memberId = @(memberId);
  member.personId = [NSString stringWithFormat:@"%lld", memberId];
  
  
  
  NSArray *names = [memberEl elementsForName:@"user_name"];
  if (names.count > 0) {
    member.name = [CommonUtils replacePlusForText:[names.lastObject stringValue]];
  }
  
  NSArray *types = [memberEl elementsForName:@"user_type"];
  if (types.count > 0) {
    member.userType = @([types.lastObject stringValue].intValue);
  }
  
  NSArray *classNames = [memberEl elementsForName:@"class_name"];
  if (classNames.count > 0) {
    member.groupClassName = [CommonUtils decodeAndReplacePlusForText:[classNames.lastObject stringValue]];
  }
  
  NSArray *bios = [memberEl elementsForName:@"description"];
  if (bios.count > 0) {
    member.bio = [CommonUtils decodeAndReplacePlusForText:[bios.lastObject stringValue]];
  }
  
  NSArray *photoUrls = [memberEl elementsForName:@"avatar"];
  if (photoUrls.count > 0) {
    member.photoUrl = [photoUrls.lastObject stringValue];
    member.bigPhotoUrl = [member.photoUrl stringByReplacingOccurrencesOfString:@"/thumbs1" withString:NULL_PARAM_VALUE];
  }
  
  NSArray *companyNames = [memberEl elementsForName:@"company_name"];
  if (companyNames.count > 0) {
    member.companyName = [CommonUtils decodeAndReplacePlusForText:[companyNames.lastObject stringValue]];
  }
  
}

+ (BOOL)handleLoadLikers:(CXMLDocument *)respDoc
                     MOC:(NSManagedObjectContext *)MOC
       hashedLikedItemId:(NSString *)hashedLikedItemId {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *likers = [respDoc nodesForXPath:@"//user" error:nil];
    for (CXMLElement *likerEl in likers) {
      NSArray *likerIds = [likerEl elementsForName:@"person_id"];
      long long likerId = 0;
      if (likerIds.count > 0) {
        likerId = [[[likerIds lastObject] stringValue] longLongValue];
      }
      
      /******* begin of check inverse relationship of LikedItemId object *******/
      NSPredicate *likedItemcheckPredicate = [NSPredicate predicateWithFormat:@"((itemId == %@) AND (likedBy.memberId == %lld))", hashedLikedItemId, likerId];
      LikedItemId *likedItemCheckPoint = (LikedItemId *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                                  entityName:@"LikedItemId"
                                                                                   predicate:likedItemcheckPredicate];
      LikedItemId *likedItemId = nil;
      if (nil == likedItemCheckPoint) {
        // if current LikedItemId object does not belong to any Member, then create a new one
        likedItemId = (LikedItemId *)[NSEntityDescription insertNewObjectForEntityForName:@"LikedItemId"
                                                                   inManagedObjectContext:MOC];
        likedItemId.itemId = hashedLikedItemId;
      }
      /******* end of check inverse relationship of LikedItemId object *******/
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(memberId == %lld)", likerId];
      Liker *checkPoint = (Liker *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Liker" predicate:predicate];
      
      if (checkPoint) {
        checkPoint.likeItems = @YES;
        if (nil == likedItemCheckPoint) {
          // add to-many relationship only when the LikeItemId is a new one
          [checkPoint addLikedItemIdsObject:likedItemId];
          likedItemId.likedBy = checkPoint;
        }
        continue;
      }
      
      Liker *liker = (Liker *)[NSEntityDescription insertNewObjectForEntityForName:@"Liker"
                                                            inManagedObjectContext:MOC];
      liker.likeItems = @YES;
      
      if (nil == likedItemCheckPoint) {
        // add to-many relationship only when the LikeItemId is a new one
        [liker addLikedItemIdsObject:likedItemId];
        likedItemId.likedBy = liker;
      }
      
      [self assembleAlumniBaseInfo:liker
                          memberId:likerId
                          memberEl:likerEl];
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

+ (BOOL)parserLikers:(NSData *)xmlData
                type:(WebItemType)type
   hashedLikedItemId:(NSString *)hashedLikedItemId
                 MOC:(NSManagedObjectContext *)MOC
   connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                 url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
		return NO;
	}
  
  switch (type) {
    case LOAD_LIKERS_TY:
    case LOAD_RECOMMENDED_ITEM_LIKERS_TY:
      return [self handleLoadLikers:doc
                                MOC:MOC
                  hashedLikedItemId:hashedLikedItemId];
      
      return YES;
    default:
      return NO;
  }
}

#pragma mark - parser checked in alumnus
+ (BOOL)handleLoadCheckedinAlumni:(CXMLDocument *)respDoc
                              MOC:(NSManagedObjectContext *)MOC
                     hashedItemId:(NSString *)hashedItemId {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *checkedinAlumnus = [respDoc nodesForXPath:@"//user" error:nil];
    for (CXMLElement *checkinAlumniEl in checkedinAlumnus) {
      NSArray *alumniIds = [checkinAlumniEl elementsForName:@"person_id"];
      long long alumniId = 0;
      if (alumniIds.count > 0) {
        alumniId = [[[alumniIds lastObject] stringValue] longLongValue];
      }
      
      /******* begin of check inverse relationship of CheckedinItemId object *******/
      NSPredicate *checkedinItemcheckPredicate = [NSPredicate predicateWithFormat:@"((itemId == %@) AND (checkedinBy.memberId == %lld))", hashedItemId, alumniId];
      CheckedinItemId *checkedinItemCheckPoint = (CheckedinItemId *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                                              entityName:@"CheckedinItemId"
                                                                                               predicate:checkedinItemcheckPredicate];
      CheckedinItemId *checkedinItemId = nil;
      if (nil == checkedinItemCheckPoint) {
        // if current CheckedinItemId object does not belong to any Member, then create a new one
        checkedinItemId = (CheckedinItemId *)[NSEntityDescription insertNewObjectForEntityForName:@"CheckedinItemId"
                                                                           inManagedObjectContext:MOC];
        checkedinItemId.itemId = hashedItemId;
      }
      /******* end of check inverse relationship of CheckedinItemId object *******/
      
      NSArray *latestCheckinTimestamps = [checkinAlumniEl elementsForName:@"date"];
      double timestamp = 0;
      if (latestCheckinTimestamps.count > 0) {
        timestamp = [[latestCheckinTimestamps.lastObject stringValue] doubleValue];
      }
      
      NSArray *totalCheckinCounts = [checkinAlumniEl elementsForName:@"checkin_count"];
      NSInteger checkinCount = 0;
      if (totalCheckinCounts.count > 0) {
        checkinCount = [[totalCheckinCounts.lastObject stringValue] intValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(memberId == %lld)", alumniId];
      CheckedinMember *checkPoint = (CheckedinMember *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                                 entityName:@"CheckedinMember"
                                                                                  predicate:predicate];
      
      if (checkPoint) {
        if (nil == checkedinItemCheckPoint) {
          // add to-many relationship only when the CheckedinItemId is a new one
          [checkPoint addCheckedinItemIdsObject:checkedinItemId];
          checkedinItemId.checkedinBy = checkPoint;
        }
        
        checkPoint.timestamp = @(timestamp);
        checkPoint.elapsedTime = [CommonUtils getElapsedTime:[CommonUtils convertDateTimeFromUnixTS:timestamp]];
        checkPoint.totalCount = @(checkinCount);
        continue;
      }
      
      CheckedinMember *checkedinMember = (CheckedinMember *)[NSEntityDescription insertNewObjectForEntityForName:@"CheckedinMember"
                                                                                          inManagedObjectContext:MOC];
      if (nil == checkedinItemCheckPoint) {
        // add to-many relationship only when the CheckedinItemId is a new one
        [checkedinMember addCheckedinItemIdsObject:checkedinItemId];
        checkedinItemId.checkedinBy = checkedinMember;
      }
      
      checkedinMember.timestamp = @(timestamp);
      checkedinMember.elapsedTime = [CommonUtils getElapsedTime:[CommonUtils convertDateTimeFromUnixTS:timestamp]];
      checkedinMember.totalCount = @(checkinCount);
      
      [self assembleAlumniBaseInfo:checkedinMember
                          memberId:alumniId
                          memberEl:checkinAlumniEl];
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

+ (BOOL)parserCheckedinAlumnus:(NSData *)xmlData
                  hashedItemId:(NSString *)hashedItemId
                           MOC:(NSManagedObjectContext *)MOC
             connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                           url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_CHECKEDIN_ALUMNUS_TY]) {
		return NO;
	}
  
  return [self handleLoadCheckedinAlumni:doc
                                     MOC:MOC
                            hashedItemId:hashedItemId];
}

#pragma mark - send invitation
+ (BOOL)handleInvitationSent:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - update user photo
+ (BOOL)handleUpdateUserPhoto:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - add photo for nearby item
+ (BOOL)handleAddPhotoForNearbyItem:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load album photos
+ (BOOL)handleLoadAlbumPhoto:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *photos = [respDoc nodesForXPath:@"//pictrue" error:nil];
    for (CXMLElement *photoEl in photos) {
      NSArray *thumbnailUrls = [photoEl elementsForName:@"thumbnail_pic"];
      NSString *thumbnailUrl = nil;
      if (thumbnailUrls.count > 0) {
        thumbnailUrl = [thumbnailUrls.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(thumbnailUrl == %@)", thumbnailUrl];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"AlbumPhoto"
                              predicate:predicate]) {
        continue;
      }
      
      AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"AlbumPhoto"
                                                                      inManagedObjectContext:MOC];
      photo.thumbnailUrl = thumbnailUrl;
      
      NSArray *imageUrls = [photoEl elementsForName:@"bmiddle_pic"];
      if (imageUrls.count > 0) {
        photo.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *authorIds = [photoEl elementsForName:@"author_id"];
      if (authorIds.count > 0) {
        photo.authorId = @([[authorIds.lastObject stringValue] longLongValue]);
      }
      
      NSArray *authorNames = [photoEl elementsForName:@"author_name"];
      if (authorNames.count > 0) {
        photo.authorName = [authorNames.lastObject stringValue];
      }
      
      NSArray *itemIds = [photoEl elementsForName:@"post_id"];
      if (itemIds.count > 0) {
        photo.itemId = @([[itemIds.lastObject stringValue] longLongValue]);
      }
      
      NSArray *timestamps = [photoEl elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0.0f;
      if (timestamps.count > 0) {
        timestamp = [[timestamps.lastObject stringValue] doubleValue];
        photo.timestamp = @(timestamp);
      }
      NSDate *date = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      photo.date = [CommonUtils simpleFormatDate:date secondAccuracy:YES];
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

#pragma mark - fetch current city
+ (BOOL)handleLoadCurrentCity:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *cityIds = [respDoc nodesForXPath:@"//city_id" error:nil];
    for (CXMLElement *el in cityIds) {
      long long cityId = [[el stringValue] longLongValue];
      
      [AppManager instance].cityId = cityId;
      
      [CommonUtils saveLongLongIntegerValueToLocal:cityId key:USER_CITY_ID_LOCAL_KEY];
    }
    
    NSArray *cityNames = [respDoc nodesForXPath:@"//city_name" error:nil];
    for (CXMLElement *el in cityNames) {
      NSString *cityName = [el stringValue];
      [AppManager instance].cityName = cityName;
      
      [CommonUtils saveStringValueToLocal:cityName key:USER_CITY_NAME_LOCAL_KEY];
    }
    
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load service category
+ (BOOL)handleLoadNearbyServiceCategory:(CXMLDocument *)respDoc
                                    MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *groupNodes = [respDoc nodesForXPath:@"//group"
                                           error:nil];
    
    NSInteger type = 0;
    for (CXMLElement *groupEl in groupNodes) {
      long long groupId = 0;
      NSArray *groupIds = [groupEl elementsForName:@"group_id"];
      if (groupIds.count > 0) {
        groupId = [[groupIds.lastObject stringValue] longLongValue];
        
        if (groupId == -99) {
          // ignore the 'Favorite Group'
          continue;
        }
      }
      
      NSArray *profileImgUrls = [groupEl elementsForName:@"profile_image_url"];
      NSString *picUrl = nil;
      if ([profileImgUrls count]) {
        picUrl = [[profileImgUrls lastObject] stringValue];
      }
      
      NSArray *sortKeys = [groupEl elementsForName:@"orders"];
      NSInteger sortKey = 0;
      if (sortKeys.count > 0) {
        sortKey = [[sortKeys.lastObject stringValue] intValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %lld", groupId];
      ItemGroup *checkPoint = (ItemGroup *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                     entityName:@"ItemGroup"
                                                                      predicate:predicate];
      if (checkPoint) {
        checkPoint.imageUrl = picUrl;
        checkPoint.sortKey = @(sortKey);
        continue;
      }
      
      ItemGroup *group = (ItemGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"ItemGroup"
                                                                    inManagedObjectContext:MOC];
      group.groupId = @(groupId);
      
      NSArray *groupNames = [groupEl elementsForName:@"group_name"];
      if (groupNames.count > 0) {
        group.groupName = [CommonUtils decodeAndReplacePlusForText:[groupNames.lastObject stringValue]];
      }
      
      NSArray *types = [groupEl elementsForName:@"group_type"];
      if (types.count > 0) {
        type = [[types.lastObject stringValue] intValue];
        group.type = @(type);
      }
      
      group.sortKey = @(sortKey);
      
      group.imageUrl = picUrl;
      
    }
    
    // create a dummy service category "All", which means display all category service for user
    NSPredicate *allPredicate = [NSPredicate predicateWithFormat:@"(groupId == %lld AND type == %d)",
                                 ALL_CATEGORY_GROUP_ID, type];
    if (![WXWCoreDataUtils objectInMOC:MOC entityName:@"ItemGroup" predicate:allPredicate]) {
      ItemGroup *dummyAll = (ItemGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"ItemGroup"
                                                                       inManagedObjectContext:MOC];
      dummyAll.groupId = @ALL_CATEGORY_GROUP_ID;
      dummyAll.type = @(type);
      dummyAll.groupName = LocaleStringForKey(NSAllTitle, nil);
      dummyAll.imageUrl = NEARYBY_ALL_CATEGORY_GORUP_IMG_URL;
      dummyAll.sortKey = @ALL_CATEGORY_GROUP_SORT_KEY;
    }
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

#pragma mark - handle nearby item

+ (BOOL)handleLoadNearbyItemDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *venues = [respDoc nodesForXPath:@"//posts/post" error:nil];
    for (CXMLElement *venueEl in venues) {
      NSArray *venueIds = [venueEl elementsForName:@"id"];
      long long venueId = 0ll;
      if (venueIds.count > 0) {
        venueId = [[venueIds.lastObject stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", venueId];
      ServiceItem *item = (ServiceItem *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                   entityName:@"ServiceItem"
                                                                    predicate:predicate];
      if (item) {
        NSArray *photoCounts = [venueEl elementsForName:@"photo_count"];
        if (photoCounts.count > 0) {
          item.photoCount = @([[photoCounts.lastObject stringValue] intValue]);
        }
        
        NSArray *likedByMes = [venueEl elementsForName:@"is_cool"];
        if (likedByMes.count > 0) {
          item.liked = ([[likedByMes.lastObject stringValue] intValue] == 1) ?
          @YES : @NO;
        } else {
          item.liked = @NO;
        }
      }
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

#pragma mark - check address book contact join status
+ (BOOL)handleCheckABContactsJoinStatus:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *userInfos = [respDoc nodesForXPath:@"//users/user_info" error:nil];
    for (CXMLElement *friendEl in userInfos) {
      
      NSArray *userIds = [friendEl elementsForName:@"user_id"];
      long long userId = 0ll;
      if (userIds.count > 0) {
        userId = [[userIds.lastObject stringValue] longLongValue];
      }
      
      NSArray *emails = [friendEl elementsForName:@"email"];
      NSString *email = nil;
      if (emails.count > 0) {
        email = [emails.lastObject stringValue];
      }
      
      NSString *cityName = nil;
      switch ([WXWCommonUtils currentLanguage]) {
        case EN_TY:
        {
          NSArray *cityENNames = [friendEl elementsForName:@"city_en"];
          if (cityENNames.count > 0) {
            cityName = [CommonUtils decodeAndReplacePlusForText:[cityENNames.lastObject stringValue]];
          }
          break;
        }
          
        case ZH_HANS_TY:
        {
          NSArray *cityCNNames = [friendEl elementsForName:@"city_cn"];
          if (cityCNNames.count > 0) {
            cityName = [CommonUtils decodeAndReplacePlusForText:[cityCNNames.lastObject stringValue]];
          }
          break;
        }
          
        default:
          break;
      }
      
      NSArray *years = [friendEl elementsForName:@"living_years"];
      NSString *yearCount = nil;
      if (years.count > 0) {
        yearCount = [years.lastObject stringValue];
      }
      
      NSArray *grades = [friendEl elementsForName:@"score_grade"];
      NSInteger grade = 0;
      if (grades.count > 0) {
        grade = [[grades.lastObject stringValue] intValue];
      }
      
      NSArray *usernames = [friendEl elementsForName:@"user_name"];
      NSString *userName = nil;
      if (usernames.count > 0) {
        userName = [CommonUtils decodeAndReplacePlusForText:[usernames.lastObject stringValue]];
      }
      
      NSArray *countries = [friendEl elementsForName:@"country"];
      NSString *countryName = nil;
      if (countries.count > 0) {
        countryName = [CommonUtils decodeAndReplacePlusForText:[countries.lastObject stringValue]];
      }
      
      NSArray *photoUrls = [friendEl elementsForName:@"profile_image_url"];
      NSString *photoUrl = nil;
      if (photoUrls.count > 0) {
        photoUrl = [photoUrls.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((email CONTAINS[c] %@) AND sourceType == %d)", email, ADDRESSBOOK_TY];
      Invitee *checkPoint = (Invitee *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Invitee" predicate:predicate];
      if (checkPoint) {
        checkPoint.userId = @(userId);
        checkPoint.cityName = cityName;
        checkPoint.years = yearCount;
        checkPoint.grade = @(grade);
        checkPoint.joined = @YES;
        checkPoint.userName = userName;
        checkPoint.countryName = countryName;
        checkPoint.photoUrl = photoUrl;
        continue;
      }
      
      Invitee *invitee = (Invitee *)[NSEntityDescription insertNewObjectForEntityForName:@"Invitee"
                                                                  inManagedObjectContext:MOC];
      invitee.userId = @(userId);
      invitee.cityName = cityName;
      invitee.years = yearCount;
      invitee.grade = @(grade);
      invitee.userName = userName;
      invitee.countryName = countryName;
      invitee.selected = @NO;
      invitee.joined = @YES;
      invitee.photoUrl = photoUrl;
      invitee.sourceType = @(ADDRESSBOOK_TY);
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

+ (NSManagedObject *)parserServiceItem:(CXMLElement *)itemEl
                          forFavorited:(BOOL)forFavorited
                                   MOC:(NSManagedObjectContext *)MOC
                          currentTotal:(NSInteger)currentTotal
                                 index:(NSInteger)index
              needUpdateTotalItemCount:(BOOL)needUpdateTotalItemCount {
  
  NSArray *itemIds = [itemEl elementsForName:@"service_id"];
  long long itemId = 0ll;
  if (itemIds.count > 0) {
    itemId = [[itemIds.lastObject stringValue] longLongValue];
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", itemId];
  NSManagedObject *checkPoint = nil;
  if (!forFavorited) {
    checkPoint = [WXWCoreDataUtils fetchObjectFromMOC:MOC
                                           entityName:@"ServiceItem"
                                            predicate:predicate];
  } else {
    checkPoint = [WXWCoreDataUtils fetchObjectFromMOC:MOC
                                           entityName:@"FavoritedServiceItem"
                                            predicate:predicate];
  }
  
  NSManagedObject *item = nil;
  if (nil == checkPoint) {
    if (!forFavorited) {
      item = (ServiceItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ServiceItem"
                                                          inManagedObjectContext:MOC];
      
    } else {
      item = (FavoritedServiceItem *)[NSEntityDescription insertNewObjectForEntityForName:@"FavoritedServiceItem"
                                                                   inManagedObjectContext:MOC];
      
    }
    ((ServiceItem *)item).itemId = @(itemId);
  } else {
    item = checkPoint;
  }
  
  if (item) {
    
    NSArray *brandIds = [itemEl elementsForName:@"channel_id"];
    if (brandIds.count > 0) {
      ((ServiceItem *)item).brandId = @([[brandIds.lastObject stringValue] longLongValue]);
    }
    
    NSArray *likedByMes = [itemEl elementsForName:@"is_like_by_current_user"];
    if (likedByMes.count > 0) {
      ((ServiceItem *)item).liked = ([[likedByMes.lastObject stringValue] intValue] == 1) ?
      @YES : @NO;
    } else {
      ((ServiceItem *)item).liked = @NO;
    }
    
    NSArray *sources = [itemEl elementsForName:@"source"];
    if (sources.count > 0) {
      ((ServiceItem *)item).source = [CommonUtils decodeAndReplacePlusForText:[sources.lastObject stringValue]];
    }
    
    NSArray *tags = [itemEl elementsForName:@"tags"];
    if (tags.count > 0) {
      ((ServiceItem *)item).tagNames = [tags.lastObject stringValue];
    }
    
    NSArray *serviceNames = [itemEl elementsForName:@"name"];
    if (serviceNames.count > 0)  {
      ((ServiceItem *)item).itemName = [CommonUtils decodeAndReplacePlusForText:[serviceNames.lastObject stringValue]];
    }
    
    NSArray *categoryIds = [itemEl elementsForName:@"category_id"];
    long long serviceCategoryId = 0ll;
    if (categoryIds.count > 0) {
      serviceCategoryId = [categoryIds.lastObject stringValue].longLongValue;
      ((ServiceItem *)item).categoryId = @(serviceCategoryId);
      
      if (nil == ((ServiceItem *)item).categoryName) {
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:@"(groupId == %lld)", serviceCategoryId];
        ItemGroup *category = (ItemGroup *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                     entityName:@"ItemGroup"
                                                                      predicate:categoryPredicate];
        ((ServiceItem *)item).categoryName = category.groupName;
      }
    }
    
    NSArray *headerParaNames = [itemEl elementsForName:@"head_param_name"];
    if (headerParaNames.count > 0) {
      ((ServiceItem *)item).headerParamName = [CommonUtils decodeAndReplacePlusForText:
                                               [headerParaNames.lastObject stringValue]];
    }
    
    NSArray *headerParamValues = [itemEl elementsForName:@"head_param_value"];
    if (headerParamValues.count > 0) {
      ((ServiceItem *)item).headerParamValue = [CommonUtils decodeAndReplacePlusForText:
                                                [headerParamValues.lastObject stringValue]];
    }
    
    NSArray *grades = [itemEl elementsForName:@"grade"];
    if (grades.count > 0) {
      ((ServiceItem *)item).grade = @([grades.lastObject stringValue].intValue);
    }
    
    // ---------- begin of update category item total count ----------
    if (needUpdateTotalItemCount && 0 == index) {
      NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"(groupId == %lld)", serviceCategoryId];
      ItemGroup *group = (ItemGroup *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                entityName:@"ItemGroup"
                                                                 predicate:groupPredicate];
      if (group) {
        if (group.itemTotal.intValue == 0 ||
            (group.itemTotal.intValue > 0 &&
             group.itemTotal.intValue != currentTotal
             /*group.itemTotal.intValue < currentTotal*/)) {
              // NOTE!!!:
              // server side MUST KEEP the total item count same always for the same loading
              // conditions, otherwise, if the latest total count more than the old loading
              // total count, then repeat loading will occur
              group.itemTotal = @(currentTotal);
            }
      }
    }
    // ---------- end of update category item total count ----------
    
    NSArray *bios = [itemEl elementsForName:@"desc"];
    if (bios.count > 0) {
      ((ServiceItem *)item).bio = [CommonUtils decodeAndReplacePlusForText:[bios.lastObject stringValue]];
    }
    
    NSArray *addresses = [itemEl elementsForName:@"address"];
    if (addresses.count > 0) {
      ((ServiceItem *)item).address = [CommonUtils decodeAndReplacePlusForText:[addresses.lastObject stringValue]];
    }
    
    NSArray *addressNative1s = [itemEl elementsForName:@"address_cn_part1"];
    if (addressNative1s.count > 0) {
      ((ServiceItem *)item).cnAddressPart1 = [CommonUtils decodeAndReplacePlusForText:[addressNative1s.lastObject stringValue]];
    }
    
    NSArray *addressNative2s = [itemEl elementsForName:@"address_cn_part2"];
    if (addressNative2s.count > 0) {
      ((ServiceItem *)item).cnAddressPart2 = [CommonUtils decodeAndReplacePlusForText:[addressNative2s.lastObject stringValue]];
    }
    
    NSArray *addressNative3s = [itemEl elementsForName:@"address_cn_part3"];
    if (addressNative3s.count > 0) {
      ((ServiceItem *)item).cnAddressPart3 = [CommonUtils decodeAndReplacePlusForText:[addressNative3s.lastObject stringValue]];
    }
    
    NSArray *cityIds = [itemEl elementsForName:@"city_id"];
    if (cityIds.count > 0) {
      ((ServiceItem *)item).cityId = @([cityIds.lastObject stringValue].longLongValue);
    }
    
    NSArray *cityNames = [itemEl elementsForName:@"city_name"];
    if (cityNames.count > 0) {
      ((ServiceItem *)item).cityName = [CommonUtils decodeAndReplacePlusForText:[cityNames.lastObject stringValue]];
    }
    
    NSArray *transits = [itemEl elementsForName:@"transport"];
    BOOL hasTransit = NO;
    if (transits.count > 0) {
      ((ServiceItem *)item).transit = [CommonUtils decodeAndReplacePlusForText:[transits.lastObject stringValue]];
      if (((ServiceItem *)item).transit && ((ServiceItem *)item).transit.length > 0) {
        hasTransit = YES;
      }
    }
    ((ServiceItem *)item).hasTransit = @(hasTransit);
    
    NSArray *latitudes = [itemEl elementsForName:@"latitude"];
    double latitude = 0;
    if (latitudes.count > 0) {
      latitude = [latitudes.lastObject stringValue].doubleValue;
      ((ServiceItem *)item).latitude = @(latitude);
    }
    
    NSArray *longitudes = [itemEl elementsForName:@"longitude"];
    double longitude = 0;
    if (longitudes.count > 0) {
      longitude = [longitudes.lastObject stringValue].doubleValue;
      ((ServiceItem *)item).longitude = @(longitude);
    }
    
    if (latitude == 0 && longitude == 0) {
      ((ServiceItem *)item).latlagAttached = @NO;
    } else {
      ((ServiceItem *)item).latlagAttached = @YES;
    }
    
    NSArray *distances = [itemEl elementsForName:@"distance"];
    CGFloat distance = 0.0f;
    if (distances.count > 0) {
      distance = [distances.lastObject stringValue].longLongValue;
      if (distance > 0) {
        ((ServiceItem *)item).distance = @(distance);
      }
    }
    
    NSArray *providerIds = [itemEl elementsForName:@"provider_id"];
    if (providerIds.count > 0) {
      ((ServiceItem *)item).providerId = @([providerIds.lastObject stringValue].longLongValue);
    }
    
    BOOL hasSP = NO;
    if (((ServiceItem *)item).providerId.longLongValue > 0) {
      hasSP = YES;
    }
    ((ServiceItem *)item).hasServiceProvider = @(hasSP);
    
    NSArray *providerNames = [itemEl elementsForName:@"provider_name"];
    if (providerNames.count > 0) {
      ((ServiceItem *)item).providerName = [providerNames.lastObject stringValue];
    }
    
    // parse telephones
    NSArray *telephoneLists = [itemEl elementsForName:@"telephones"];
    if (telephoneLists.count > 0) {
      CXMLElement *telephoneList = (CXMLElement *)telephoneLists.lastObject;
      NSArray *telephones = [telephoneList elementsForName:@"telephone"];
      NSInteger i = 0;
      
      NSMutableString *allTelephoneNumbers = [NSMutableString string];
      for (CXMLElement *telephoneEl in telephones) {
        
        i++;
        
        NSArray *numbers = [telephoneEl elementsForName:@"number"];
        NSString *number = [[numbers.lastObject stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        number = [number stringByReplacingOccurrencesOfString:@" "
                                                   withString:NULL_PARAM_VALUE];
        
        NSPredicate *phoneNumberPredicate = [NSPredicate predicateWithFormat:@"((number == %@) AND (item.itemId == %lld))",
                                             number, itemId];
        PhoneNumber *checkPoint = (PhoneNumber *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                           entityName:@"PhoneNumber"
                                                                            predicate:phoneNumberPredicate];
        if (checkPoint) {
          if (checkPoint.desc.length > 0) {
            if (1 == i) {
              [allTelephoneNumbers appendString:checkPoint.desc];
            } else {
              [allTelephoneNumbers appendString:[NSString stringWithFormat:@", %@", checkPoint.desc]];
            }
          }
          continue;
        }
        
        PhoneNumber *phoneNumber = (PhoneNumber *)[NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber"
                                                                                inManagedObjectContext:MOC];
        phoneNumber.number = number;
        
        NSArray *descs = [telephoneEl elementsForName:@"desc"];
        if (descs.count > 0) {
          phoneNumber.desc = [CommonUtils decodeAndReplacePlusForText:[descs.lastObject stringValue]];
        }
        
        [((ServiceItem *)item) addPhoneNumbersObject:phoneNumber];
        
        if (phoneNumber.desc) {
          if (1 == i) {
            [allTelephoneNumbers appendString:phoneNumber.desc];
          } else {
            [allTelephoneNumbers appendString:[NSString stringWithFormat:@", %@", phoneNumber.desc]];
          }
        }
      }
      ((ServiceItem *)item).phoneNumber = allTelephoneNumbers;
    }
    
    NSArray *urls = [itemEl elementsForName:@"website"];
    BOOL hasLink = NO;
    if (urls.count > 0) {
      ((ServiceItem *)item).link = [urls.lastObject stringValue];
      if (((ServiceItem *)item).link.length > 0) {
        hasLink = YES;
      }
    }
    ((ServiceItem *)item).hasLink = @(hasLink);
    
    NSArray *emails = [itemEl elementsForName:@"email"];
    BOOL hasEmail = NO;
    if (emails.count > 0) {
      ((ServiceItem *)item).email = [emails.lastObject stringValue];
      if (((ServiceItem *)item).email.length > 0) {
        hasEmail = YES;
      }
    }
    
    NSArray *likeCounts = [itemEl elementsForName:@"like_count"];
    if (likeCounts.count > 0) {
      ((ServiceItem *)item).likeCount = @([likeCounts.lastObject stringValue].intValue);
    }
    
    NSArray *photoCounts = [itemEl elementsForName:@"photo_count"];
    if (photoCounts.count > 0) {
      ((ServiceItem *)item).photoCount = @([photoCounts.lastObject stringValue].intValue);
    }
    
    NSArray *couponCounts = [itemEl elementsForName:@"coupon_count"];
    ((ServiceItem *)item).hasCoupon = @NO;
    if (couponCounts.count > 0) {
      if ([couponCounts.lastObject stringValue].intValue > 0) {
        ((ServiceItem *)item).hasCoupon = @YES;
      }
    }
    
    NSArray *favoriteds = [itemEl elementsForName:@"is_favorite_by_current_user"];
    if (favoriteds.count > 0) {
      ((ServiceItem *)item).favorited = [NSNumber numberWithBool:[favoriteds.lastObject stringValue].intValue == 1 ? YES : NO];
    }
    
    NSArray *commentCounts = [itemEl elementsForName:@"comment_count"];
    if (commentCounts.count > 0) {
      ((ServiceItem *)item).commentCount = @([commentCounts.lastObject stringValue].intValue);
    }
    
    NSArray *latestCommentContents = [itemEl elementsForName:@"latest_comment"];
    if (latestCommentContents.count > 0) {
      ((ServiceItem *)item).latestComment = [CommonUtils decodeAndReplacePlusForText:[latestCommentContents.lastObject stringValue]];
    }
    
    NSArray *latestCommenterIds = [itemEl elementsForName:@"latest_comment_by"];
    if (latestCommenterIds.count > 0) {
      ((ServiceItem *)item).latestCommenterId = @([latestCommentContents.lastObject stringValue].longLongValue);
    }
    
    NSArray *latestCommenterNames = [itemEl elementsForName:@"latest_comment_username"];
    if (latestCommenterNames.count > 0) {
      ((ServiceItem *)item).latestCommenterName = [CommonUtils decodeAndReplacePlusForText:[latestCommenterNames.lastObject stringValue]];
    }
    
    NSArray *latestCommenteTimestamps = [itemEl elementsForName:@"latest_comment_date"];
    double timestamp = 0;
    if (latestCommenteTimestamps.count > 0) {
      timestamp = [latestCommenteTimestamps.lastObject stringValue].doubleValue;
      ((ServiceItem *)item).lastCommentTimestamp = @(timestamp);
    }
    if (timestamp > 0) {
      ((ServiceItem *)item).latestCommentElapsedTime = [CommonUtils getElapsedTime:[CommonUtils convertDateTimeFromUnixTS:timestamp]];
    }
    
    NSArray *imgUrls = [itemEl elementsForName:@"profile_image_url"];
    if ([imgUrls count]) {
      ((ServiceItem *)item).imageUrl = [[imgUrls lastObject] stringValue];
      ((ServiceItem *)item).thumbnailUrl = [[imgUrls lastObject] stringValue];
      ((ServiceItem *)item).imageAttached = @YES;
    } else {
      ((ServiceItem *)item).imageAttached = @NO;
    }
    
    NSArray *couponTitles = [itemEl elementsForName:@"coupon_name"];
    if (couponTitles.count > 0) {
      ((ServiceItem *)item).couponInfo = [CommonUtils decodeAndReplacePlusForText:[couponTitles.lastObject stringValue]];
    }
    
    // parse coupons
    NSArray *couponLists = [itemEl elementsForName:@"coupons"];
    if (couponLists.count > 0) {
      
      CXMLElement *couponListEl = (CXMLElement *)couponLists.lastObject;
      NSArray *coupons = [couponListEl elementsForName:@"coupon"];
      for (CXMLElement *couponEl in coupons) {
        long long couponId = 0ll;
        NSArray *couponIds = [couponEl elementsForName:@"coupon_id"];
        if (couponIds.count > 0) {
          couponId = [couponIds.lastObject stringValue].longLongValue;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", couponId];
        if ([WXWCoreDataUtils objectInMOC:MOC entityName:@"CouponItem" predicate:predicate]) {
          continue;
        }
        
        CouponItem *couponItem = (CouponItem *)[NSEntityDescription insertNewObjectForEntityForName:@"CouponItem"
                                                                             inManagedObjectContext:MOC];
        couponItem.itemId = @(couponId);
        
        NSArray *couponNames = [couponEl elementsForName:@"coupon_name"];
        if (couponNames.count > 0) {
          couponItem.name = [CommonUtils decodeAndReplacePlusForText:[couponNames.lastObject stringValue]];
        }
        
        NSArray *couponBios = [couponEl elementsForName:@"desc"];
        if (couponBios.count > 0) {
          couponItem.desc = [CommonUtils decodeAndReplacePlusForText:[couponBios.lastObject stringValue]];
        }
        
        NSArray *couponValidities = [couponEl elementsForName:@"validity"];
        if (couponValidities.count > 0) {
          couponItem.validity = [CommonUtils decodeAndReplacePlusForText:[couponValidities.lastObject stringValue]];
        }
        
        NSArray *couponSources = [couponEl elementsForName:@"source"];
        if (couponSources.count > 0) {
          couponItem.source = [couponSources.lastObject stringValue];
        }
        
        NSArray *prps = [couponEl elementsForName:@"prp"];
        if (prps.count > 0) {
          couponItem.prp = [CommonUtils decodeAndReplacePlusForText:[prps.lastObject stringValue]];
        }
        
        NSArray *savings = [couponEl elementsForName:@"reduced_price"];
        if (savings.count > 0) {
          couponItem.reducedPrice = [CommonUtils decodeAndReplacePlusForText:[savings.lastObject stringValue]];
        }
        
        NSArray *couponPriceRanges = [couponEl elementsForName:@"price_range"];
        if (couponPriceRanges.count > 0) {
          couponItem.priceRange = [CommonUtils decodeAndReplacePlusForText:[couponPriceRanges.lastObject stringValue]];
        }
        
        NSArray *couponImageUrls = [couponEl elementsForName:@"profile_image_url"];
        if (couponImageUrls.count > 0) {
          couponItem.imageUrl = [couponImageUrls.lastObject stringValue];
        }
        
        NSArray *couponWebsites = [couponEl elementsForName:@"website"];
        if (couponWebsites.count > 0) {
          couponItem.website = [couponWebsites.lastObject stringValue];
        }
        
        NSArray *couponSortKeys = [couponEl elementsForName:@"sorts"];
        if (couponSortKeys.count > 0) {
          couponItem.sortKey = @([couponSortKeys.lastObject stringValue].intValue);
        }
        
        couponItem.serviceItemId = ((ServiceItem *)item).itemId;
        
        [((ServiceItem *)item) addCouponInfosObject:couponItem];
      }
    }
    
    // parse recommended items
    NSArray *recommendedItemLists = [itemEl elementsForName:@"recommend_items"];
    ((ServiceItem *)item).hasRecommendedItem = @NO;
    NSMutableString *recommendedItemNameText = [NSMutableString string];
    if (recommendedItemLists.count > 0) {
      ((ServiceItem *)item).hasRecommendedItem = @YES;
      
      CXMLElement *recommendedItemListEl = (CXMLElement *)recommendedItemLists.lastObject;
      NSArray *recommendedItems = [recommendedItemListEl elementsForName:@"recommend_item"];
      NSInteger index = 0;
      for (CXMLElement *recommendedItemEl in recommendedItems) {
        long long recommendedItemId = 0ll;
        
        NSArray *recommendedItemIds = [recommendedItemEl elementsForName:@"recommend_id"];
        if (recommendedItemIds.count > 0) {
          recommendedItemId = [recommendedItemIds.lastObject stringValue].longLongValue;
        }
        
        NSArray *recommendedItemLikeCounts = [recommendedItemEl elementsForName:@"like_count"];
        NSInteger recommendedItemLikeCount = 0;
        if (recommendedItemLikeCounts.count > 0) {
          recommendedItemLikeCount = [recommendedItemLikeCounts.lastObject stringValue].intValue;
        }
        
        // assemble recommended items name
        NSArray *recommendedItemEnNames = [recommendedItemEl elementsForName:@"name_en"];
        NSString *recommendedItemEnName = nil;
        if (recommendedItemEnNames.count > 0) {
          recommendedItemEnName = [CommonUtils decodeAndReplacePlusForText:[recommendedItemEnNames.lastObject stringValue]];
        }
        if (nil == recommendedItemEnName || 0 == recommendedItemEnName.length) {
          recommendedItemEnName = NULL_PARAM_VALUE;
        }
        
        if (0 != index) {
          [recommendedItemNameText appendFormat:@", %@", recommendedItemEnName];
        } else {
          [recommendedItemNameText appendString:recommendedItemEnName];
        }
        index++;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", recommendedItemId];
        if ([WXWCoreDataUtils objectInMOC:MOC entityName:@"RecommendedItem" predicate:predicate]) {
          continue;
        }
        
        RecommendedItem *recommendedItem = (RecommendedItem *)[NSEntityDescription insertNewObjectForEntityForName:@"RecommendedItem"
                                                                                            inManagedObjectContext:MOC];
        recommendedItem.itemId = @(recommendedItemId);
        recommendedItem.enName = recommendedItemEnName;
        recommendedItem.likeCount = @(recommendedItemLikeCount);
        
        NSArray *recommendedItemCNNames = [recommendedItemEl elementsForName:@"name"];
        if (recommendedItemCNNames.count > 0) {
          recommendedItem.cnName = [CommonUtils decodeAndReplacePlusForText:[recommendedItemCNNames.lastObject stringValue]];
        }
        
        NSArray *recommendedItemBios = [recommendedItemEl elementsForName:@"desc"];
        if (recommendedItemBios.count > 0) {
          recommendedItem.intro = [CommonUtils decodeAndReplacePlusForText:[recommendedItemBios.lastObject stringValue]];
        }
        
        [((ServiceItem *)item) addRecommendedItemsObject:recommendedItem];
      }
      
      ((ServiceItem *)item).recommendedItemNames = recommendedItemNameText;
    }
    
    // assemble sections
    NSArray *moduleLists = [itemEl elementsForName:@"modules"];
    if (moduleLists.count > 0) {
      
      CXMLElement *moduleListEl = (CXMLElement *)moduleLists.lastObject;
      NSArray *modules = [moduleListEl elementsForName:@"module"];
      for (CXMLElement *moduleEl in modules) {
        NSArray *sectionTypes = [moduleEl elementsForName:@"type"];
        NSString *sectionType = nil;
        if (sectionTypes.count > 0) {
          sectionType = [sectionTypes.lastObject stringValue];
        }
        
        NSArray *sortKeys = [moduleEl elementsForName:@"position"];
        NSInteger sortKey = 0;
        if (sortKeys.count > 0) {
          sortKey = [sortKeys.lastObject stringValue].intValue;
        }
        
        NSPredicate *modulePredicate = [NSPredicate predicateWithFormat:@"(sectionType == %@) AND (sortKey == %d)",
                                        sectionType, sortKey];
        if ([WXWCoreDataUtils objectInMOC:MOC
                               entityName:@"ServiceItemSection"
                                predicate:modulePredicate]) {
          continue;
        }
        
        ServiceItemSection *serviceItemSection = (ServiceItemSection *)[NSEntityDescription insertNewObjectForEntityForName:@"ServiceItemSection"
                                                                                                     inManagedObjectContext:MOC];
        serviceItemSection.sectionType = sectionType;
        serviceItemSection.sortKey = @(sortKey);
        
        // parse special params for item
        NSArray *hasSpecialParams = [moduleEl elementsForName:@"has_additional_param"];
        BOOL hasSpecialParam = NO;
        if (hasSpecialParams.count > 0) {
          hasSpecialParam = [hasSpecialParams.lastObject stringValue].intValue == 1 ? YES : NO;
          serviceItemSection.hasSpecialParams = @(hasSpecialParam);
        }
        if (hasSpecialParam) {
          NSArray *paramLists = [moduleEl elementsForName:@"params"];
          if (paramLists.count > 0) {
            CXMLElement *paramListEl = (CXMLElement *)paramLists.lastObject;
            NSArray *params = [paramListEl elementsForName:@"param"];
            for (CXMLElement *paramEl in params) {
              NSArray *paramNames = [paramEl elementsForName:@"name"];
              NSString *paramName = nil;
              if (paramNames.count > 0) {
                paramName = [paramNames.lastObject stringValue];
              }
              
              NSArray *paramSortKeys = [paramEl elementsForName:@"sorts"];
              NSInteger paramSortKey = 0;
              if (paramSortKeys.count > 0) {
                paramSortKey = [paramSortKeys.lastObject stringValue].intValue;
              }
              
              NSPredicate *paramPredicate = [NSPredicate predicateWithFormat:@"((name == %@) AND (sortKey == %d))",
                                             paramName, paramSortKey];
              if ([WXWCoreDataUtils objectInMOC:MOC
                                     entityName:@"ServiceItemSectionParam"
                                      predicate:paramPredicate]) {
                continue;
              }
              
              ServiceItemSectionParam *sectionParam = (ServiceItemSectionParam *)[NSEntityDescription insertNewObjectForEntityForName:@"ServiceItemSectionParam"
                                                                                                               inManagedObjectContext:MOC];
              sectionParam.name = paramName;
              sectionParam.sortKey = @(paramSortKey);
              
              NSArray *paramValues = [paramEl elementsForName:@"value"];
              if (paramValues.count > 0) {
                sectionParam.value = [CommonUtils decodeAndReplacePlusForText:[paramValues.lastObject stringValue]];
              }
              
              [serviceItemSection addSpecialParamsObject:sectionParam];
            }
          }
        }
        
        [self assembleServiceSectionDetailInfo:serviceItemSection
                                   sectionType:sectionType
                                         hasSP:hasSP
                                    hasTransit:hasTransit
                                      hasEmail:hasEmail
                                       hasLink:hasLink];
        
        [((ServiceItem *)item) addSectionsObject:serviceItemSection];
      }
    }
  }
  
  return item;
}

+ (void)assembleServiceSectionDetailInfo:(ServiceItemSection *)serviceItemSection
                             sectionType:(NSString *)sectionType
                                   hasSP:(BOOL)hasSP
                              hasTransit:(BOOL)hasTransit
                                hasEmail:(BOOL)hasEmail
                                 hasLink:(BOOL)hasLink {
  
  if ([sectionType isEqualToString:ITEM_INTRO_SEC]) {
    serviceItemSection.cellCount = @1;
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d", SI_INTRO_SEC_BIO_CELL];
    if (hasSP) {
      serviceItemSection.cellCount = @2;
      serviceItemSection.cellList = [NSString stringWithFormat:@"%@|1-%d",
                                     serviceItemSection.cellList, SI_INTRO_SEC_SP_CELL];
    }
  } else if ([sectionType isEqualToString:ITEM_ADDRESS_SEC]) {
    serviceItemSection.cellCount = @2;
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d",
                                   SI_MAP_SEC_ADDRESS_CELL];
    /*
     serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d|1-%d",
     SI_MAP_SEC_ADDRESS_CELL,
     SI_MAP_SEC_TAXI_CELL];
     */
    if (hasTransit) {
      serviceItemSection.cellCount = @3;
      serviceItemSection.cellList = [NSString stringWithFormat:@"%@|2-%d",
                                     serviceItemSection.cellList,
                                     SI_MAP_SEC_TRANSIT_CELL];
    }
  } else if ([sectionType isEqualToString:ITEM_BRANCH_SEC]) {
    serviceItemSection.cellCount = @1;
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d", SI_BRANCH_SEC_CELL];
  } else if ([sectionType isEqualToString:ITEM_CONTACT_SEC]) {
    
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d", SI_CONTACT_SEC_PHONE_CELL];
    if (hasEmail && hasLink) {
      
      serviceItemSection.cellCount = @3;
      serviceItemSection.cellList = [NSString stringWithFormat:@"%@|1-%d|2-%d",
                                     serviceItemSection.cellList,
                                     SI_CONTACT_SEC_WEB_CELL,
                                     SI_CONTACT_SEC_EMAIL_CELL];
      
    } else if (!hasLink && hasEmail) {
      
      serviceItemSection.cellCount = @2;
      serviceItemSection.cellList = [NSString stringWithFormat:@"%@|1-%d",
                                     serviceItemSection.cellList,
                                     SI_CONTACT_SEC_EMAIL_CELL];
      
    } else if (!hasEmail && hasLink) {
      
      serviceItemSection.cellCount = @2;
      serviceItemSection.cellList = [NSString stringWithFormat:@"%@|1-%d",
                                     serviceItemSection.cellList,
                                     SI_CONTACT_SEC_WEB_CELL];
      
    } else if (!hasLink && !hasEmail) {
      
      serviceItemSection.cellCount = @1;
      
    }
  } else if ([sectionType isEqualToString:ITEM_COMMENT_SEC]) {
    serviceItemSection.cellCount = @1;
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d", SI_COMMENT_SEC_CELL];
  } else if ([sectionType isEqualToString:ITEM_RECOMMENDED_ITEM_SEC]) {
    serviceItemSection.cellCount = @1;
    serviceItemSection.cellList = [NSString stringWithFormat:@"0-%d", SI_RECOMMENDED_SEC_CELL];
  }
  
}



+ (BOOL)handleLoadServiceItemDetail:(CXMLDocument *)respDoc
                                MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *items = [respDoc nodesForXPath:@"//service" error:nil];
    
    for (CXMLElement *itemEl in items) {
      [self parserServiceItem:itemEl
                 forFavorited:NO
                          MOC:MOC
                 currentTotal:0
                        index:0
     needUpdateTotalItemCount:NO];
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

+ (Comment *)assembleComment:(CXMLElement *)commentEl MOC:(NSManagedObjectContext *)MOC {
  long long commentId = 0;
  
  NSArray *commentIds = [commentEl elementsForName:@"comments_id"];
  if ([commentIds count] > 0) {
    commentId = [[[commentIds lastObject] stringValue] longLongValue];
  }
  
  NSArray *authorPicUrls = [commentEl elementsForName:@"avatar"];
  NSString *authorPicUrl = nil;
  if ([authorPicUrls count] > 0) {
    authorPicUrl = [authorPicUrls.lastObject stringValue];
  }
  
  NSArray *timestamps = [commentEl elementsForName:@"date"];
  NSTimeInterval timestamp = 0;
  if ([timestamps count] > 0) {
    timestamp = [[[timestamps lastObject] stringValue] doubleValue];
  }
  
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(commentId == %lld)", commentId];
  Comment *checkPoint = (Comment *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Comment"
                                                              predicate:predicate];
  if (checkPoint) {
    checkPoint.authorPicUrl = authorPicUrl;
    checkPoint.elapsedTime = [CommonUtils getElapsedTime:
                              [CommonUtils convertDateTimeFromUnixTS:checkPoint.timestamp.doubleValue]];
    return checkPoint;
  }
  
  Comment *comment = (Comment *)[NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                              inManagedObjectContext:MOC];
  comment.commentId = @(commentId);
  comment.authorPicUrl = authorPicUrl;
  comment.timestamp = @(timestamp);
  NSDate *date = [CommonUtils convertDateTimeFromUnixTS:timestamp];
  comment.date = [CommonUtils simpleFormatDate:date
                                secondAccuracy:YES];
  comment.elapsedTime = [CommonUtils getElapsedTime:date];
  
  NSArray *parentIds = [commentEl elementsForName:@"service_id"];
  if ([parentIds count] > 0) {
    comment.parentId = @([[[parentIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *authorIds = [commentEl elementsForName:@"user_id"];
  if ([authorIds count] > 0) {
    comment.authorId = @([[[authorIds lastObject] stringValue] longLongValue]);
  }
  
  NSArray *authorNames = [commentEl elementsForName:@"user_name"];
  if ([authorNames count] > 0) {
    comment.authorName = [CommonUtils decodeAndReplacePlusForText:[authorNames.lastObject stringValue]];
  }
  
  NSArray *authorTypes = [commentEl elementsForName:@"user_type"];
  if (authorTypes.count > 0) {
    comment.authorType = @([authorTypes.lastObject stringValue].intValue);
  }
  
  NSArray *contents = [commentEl elementsForName:@"message"];
  if ([contents count] > 0) {
    comment.content = [CommonUtils decodeAndReplacePlusForText:[contents.lastObject stringValue]];
  }
  
  NSArray *locations = [commentEl elementsForName:@"service_name"];
  if (locations.count > 0) {
    comment.locationName = [CommonUtils decodeAndReplacePlusForText:[locations.lastObject stringValue]]; // DEBUG
  }
  
  return comment;
}

+ (BOOL)handleLoadServiceItemComments:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *commentList = [respDoc nodesForXPath:@"//comment" error:nil];
    
    for (CXMLElement *commentEl in commentList) {
      [self assembleComment:commentEl MOC:MOC];
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleLoadBrandComments:(CXMLDocument *)respDoc
                            MOC:(NSManagedObjectContext *)MOC
                        brandId:(long long)brandId {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *commentList = [respDoc nodesForXPath:@"//comment" error:nil];
    
    for (CXMLElement *commentEl in commentList) {
      Comment *comment = [self assembleComment:commentEl MOC:MOC];
      comment.parentId = @(brandId);
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)parserLoadedServiceItem:(NSData *)xmlData
                            MOC:(NSManagedObjectContext *)MOC
              connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                            url:(NSString *)url {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_SERVICE_ITEM_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSArray *totals = [doc nodesForXPath:@"//all_counts"
                                   error:nil];
    NSInteger total = [[totals.lastObject stringValue] intValue];
    
    NSArray *itemNodes = [doc nodesForXPath:@"//service"
                                      error:nil];
    
    NSInteger index = 0;
    for (CXMLElement *itemEl in itemNodes) {
      
      [self parserServiceItem:itemEl
                 forFavorited:NO
                          MOC:MOC
                 currentTotal:total
                        index:index
     needUpdateTotalItemCount:YES];
      
      index++;
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)parserLoadedServiceItemForBrandId:(long long)brandId
                                  xmlData:(NSData *)xmlData
                                      MOC:(NSManagedObjectContext *)MOC
                        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                      url:(NSString *)url
                                itemCount:(NSNumber **)itemCount {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_SERVICE_ITEM_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSArray *totals = [doc nodesForXPath:@"//all_counts"
                                   error:nil];
    NSInteger total = [[totals.lastObject stringValue] intValue];
    
    *itemCount = @(total);
    
    NSArray *itemNodes = [doc nodesForXPath:@"//service"
                                      error:nil];
    
    NSInteger index = 0;
    for (CXMLElement *itemEl in itemNodes) {
      
      ServiceItem *item = (ServiceItem *)[self parserServiceItem:itemEl
                                                    forFavorited:NO
                                                             MOC:MOC
                                                    currentTotal:total
                                                           index:index
                                        needUpdateTotalItemCount:YES];
      index++;
      
      item.brandId = @(brandId);
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}



#pragma mar - user meta data

+ (void)parserRadiusFilterOptions:(NSManagedObjectContext *)MOC {
  
  NSString *radiusPlaceId = ALL_RADIUS_PLACE_ID;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", radiusPlaceId];
  Place *allRadiusPlace = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Place"
                                                              predicate:predicate];
  if (allRadiusPlace) {
    allRadiusPlace.placeName = LocaleStringForKey(NSAllTitle, nil);
  } else {
    allRadiusPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                            inManagedObjectContext:MOC];
    allRadiusPlace.placeId = radiusPlaceId;
    allRadiusPlace.placeName = LocaleStringForKey(NSAllTitle, nil);
    allRadiusPlace.placeType = @(RADIUS_PLACE_TY);
  }
  
  radiusPlaceId = WITHIN2KM_PLACE_ID;
  predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", radiusPlaceId];
  Place *within2kmPlace = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Place"
                                                              predicate:predicate];
  if (within2kmPlace) {
    within2kmPlace.placeName = LocaleStringForKey(NSWithin2kmTitle, nil);
  } else {
    within2kmPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                            inManagedObjectContext:MOC];
    within2kmPlace.placeId = radiusPlaceId;
    within2kmPlace.placeName = LocaleStringForKey(NSWithin2kmTitle, nil);
    within2kmPlace.distance = @2.0f;
    within2kmPlace.placeType = @(RADIUS_PLACE_TY);
  }
  
  radiusPlaceId = WITHIN5KM_PLACE_ID;
  predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", radiusPlaceId];
  Place *within5kmPlace = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Place"
                                                              predicate:predicate];
  if (within5kmPlace) {
    within5kmPlace.placeName = LocaleStringForKey(NSWithin5kmTitle, nil);
  } else {
    within5kmPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                            inManagedObjectContext:MOC];
    within5kmPlace.placeId = radiusPlaceId;
    within5kmPlace.placeName = LocaleStringForKey(NSWithin5kmTitle, nil);
    within5kmPlace.distance = @5.0f;
    within5kmPlace.placeType = @(RADIUS_PLACE_TY);
  }
  
  radiusPlaceId = WITHIN10KM_PLACE_ID;
  predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", radiusPlaceId];
  Place *within10kmPlace = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                              entityName:@"Place"
                                                               predicate:predicate];
  if (within10kmPlace) {
    within10kmPlace.placeName = LocaleStringForKey(NSWithin10kmTitle, nil);
  } else {
    within10kmPlace = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                             inManagedObjectContext:MOC];
    within10kmPlace.placeId = radiusPlaceId;
    within10kmPlace.placeName = LocaleStringForKey(NSWithin10kmTitle, nil);
    within10kmPlace.distance = @10.0f;
    within10kmPlace.placeType = @(RADIUS_PLACE_TY);
  }
}

#pragma mark - entry points

+ (BOOL)parserResponseXml:(NSData *)xmlData
                     type:(WebItemType)type
                      MOC:(NSManagedObjectContext *)MOC
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
		return NO;
	}
  
  BOOL ret = YES;
  
  switch (type) {
      
    case VERIFY_USER_TY:
      ret = [self handleUserVerify:doc MOC:MOC];
      break;
      
    case LOAD_SYS_MESSAGE_TY:
      ret = [self handleLoadSystemMessages:doc MOC:MOC];
      break;
      
    case REFRESH_SESSION_TY:
      ret = [self handleSessionReferencement:doc];
      break;
      
    case LOAD_COMMENT_TY:
      ret = [self handleLoadComments:doc MOC:MOC];
      break;
      
    case ITEM_FAVORITE_TY:
      ret = [self handleFavoriteItem:doc];
      break;
      
    case ITEM_LIKE_TY:
      ret = [self handleLikeItem:doc];
      break;
      
    case ADMIN_CHECK_IN_TY:
      ret = [self handleAdminCheckin:doc];
      break;
      
    case MODIFY_USER_ICON_TY:
      ret = [self handleModifyUserIcon:doc];
      break;
      
    case POST_FAVORITE_ACTION_TY:
    case POST_UNFAVORITE_ACTION_TY:
      ret = [self handleFavoriteItem:doc];
      break;
      
    case SEND_COMMENT_TY:
    case SEND_SERVICE_ITEM_COMMENT_TY:
    case SEND_BRAND_COMMENT_TY:
      
    case SEND_POST_TY:
    case SEND_EVENT_DISCUSS_TY:
    case SEND_SUPPLY_DEMAND_TY:
    case FAVORITE_WELFARE_TY:

    case SEND_QUESTION_TY:
      
    case SIGN_OUT_TY:
      ret = [self handleCommonResponse:doc];
      break;
          
    case DELETE_FEED_TY:
      ret = [self handleDeleteFeed:doc];
      break;
      
    case DELETE_COMMENT_TY:
      ret = [self handleDeleteComment:doc];
      break;
      
    case DELETE_QUESTION_TY:
      ret = [self handleDeleteQuestion:doc];
      break;
      /*
       case LOAD_LIKERS_TY:
       ret = [self handleLoadLikers:doc MOC:MOC];
       break;
       */
      
    case LOAD_USER_PROFILE_TY:
      ret = [self handleLoadUserProfile:doc MOC:MOC];
      break;
      
    case INVITE_BY_AB_PHONE_TY:
    case INVITE_BY_LINKEDIN_TY:
      ret = [self handleInvitationSent:doc];
      break;
      
    case UPDATE_USER_PHOTO_TY:
    case UPDATE_USER_CITY_TY:
    case UPDATE_USER_LIVING_YEARS_TY:
    case UPDATE_USERNAME_TY:
    case UPDATE_USER_NATIONALITY_TY:
      ret = [self handleUpdateUserPhoto:doc];
      break;
      
    case LOCATE_CURRENT_CITY_TY:
      ret = [self handleLoadCurrentCity:doc];
      break;
      
    case LOAD_NEARBY_ITEM_GROUP_TY:
      ret = [self handleLoadNearbyServiceCategory:doc MOC:MOC];
      break;
      
    case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
      ret = [self handleAddPhotoForNearbyItem:doc];
      break;
      
    case LOAD_ALBUM_PHOTO_TY:
      ret = [self handleLoadAlbumPhoto:doc MOC:MOC];
      break;
      
    case LOAD_NEARBY_ITEM_DETAIL_TY:
      ret = [self handleLoadNearbyItemDetail:doc MOC:MOC];
      break;
      
    case CHECK_ABCONTACTS_JOIN_STATUS_TY:
      ret = [self handleCheckABContactsJoinStatus:doc MOC:MOC];
      break;
      
    case FAVORITE_ALUMNI_TY:
      ret = [self handleFavoriteItem:doc];
      break;
      
    case LOAD_WITH_ME_LINK_TY:
      ret = [self handleWithMeConnection:doc
                                     MOC:MOC];
      break;
      
    case VIDEO_TY:
      ret = [self handleVideo:doc MOC:MOC];
      break;
      
    case SPONSOR_TY:
      ret = [self handleSponsor:doc MOC:MOC];
      break;
      
    case COUNTRY_TY:
      ret = [self handleFetchCountries:doc MOC:MOC];
      break;
      
    case INDUSTRY_TY:
      ret = [self handleFetchIndustries:doc MOC:MOC];
      break;
      
    case LOAD_BIZ_POST_TY:
    case CLUB_POST_LIST_TY:
    case POST_LIKE_ACTION_TY:
    case POST_UNLIKE_ACTION_TY:
    case LOAD_SUPPLY_DEMAND_ITEM_TY:
      ret = [self handleClubPost:doc MOC:MOC];
      break;
      
    case CLUB_DETAIL_SIMPLE_TY:
      ret = [self handleClubSimpleDetail:doc MOC:MOC];
      break;
      
    case POST_TAG_LIST_TY:
    case SUPPLY_DEMAND_TAG_TY:
      ret = [self handlePostTag:doc MOC:MOC];
      break;
      
    case POST_LIKE_USER_LIST_TY:
      ret = [self handleFetchAlumni:doc MOC:MOC itemType:ALUMNI_USER_TY];
      break;
      
    case SHAKE_USER_LIST_TY:
      ret = [self handleFetchAlumni:doc MOC:MOC itemType:FETCH_SHAKE_USER_TY];
      break;
      
    case CHAT_USER_LIST_TY:
      ret = [self handleFetchAlumni:doc MOC:MOC itemType:ALUMNI_USER_TY];
      break;
      
    case SHAKE_PLACE_THING_TY:
      ret = [self handleShakePlace2Thing:doc MOC:MOC];
      break;
      
      
    case LOAD_NEARBY_PLACE_LIST_TY:
      ret = [self handleNearbyPlace:doc MOC:MOC];
      break;
      
    case CHART_LIST_TY:
      ret = [self handleChatList:doc MOC:MOC];
      break;
      
    case VIDEO_FILTER_TY:
      ret = [self handleVideoFilter:doc MOC:MOC];
      break;
      
      // ------ begin of nearby service ------
    case LOAD_SERVICE_CATEGORY_TY:
      ret = [self handleLoadServiceCategory:doc MOC:MOC];
      break;
      
    case LOAD_SERVICE_ITEM_DETAIL_TY:
      ret = [self handleLoadServiceItemDetail:doc MOC:MOC];
      break;
      
    case LOAD_SERVICE_ITEM_COMMENT_TY:
      ret = [self handleLoadServiceItemComments:doc MOC:MOC];
      break;
      
    case LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY:
      ret = [self handleLoadServiceContentAlbumPhoto:doc MOC:MOC];
      break;
      
    case LOAD_RECOMMENDED_ITEM_TY:
      ret = [self handleLoadRecommendedItems:doc MOC:MOC];
      break;
      
    case LOAD_BRANDS_TY:
      ret = [self handleBrands:doc MOC:MOC];
      break;
      
    case LOAD_BRAND_DETAIL_TY:
      ret = [self handleBrandDetails:doc MOC:MOC];
      break;
      
    case CLASS_TY:
      ret = [self handleFetchClasses:doc MOC:MOC];
      break;
      
      // ------ end of nearby service ------
      
      // ------ begin of event ------
      
    case CLUBLIST_TY:
      ret = [self handleClub:doc MOC:MOC];
      break;
      
    case EVENT_POST_TY:
      ret = [self handleEventDiscussPost:doc MOC:MOC];
      break;
      
    case EVENTDETAIL_TY:
      ret = [self handleParserEventDetail:doc MOC:MOC];
      break;
      
    case EVENT_APPLY_QUESTIONS_TY:
    case STARTUP_BACK_QUESTIONS_TY:
      ret = [self handleParserEventApplyQuestions:doc MOC:MOC];
      break;
      
    case SURVEY_DATA_TY:
      ret = [self handleParserSurveyQuestions:doc MOC:MOC];
      break;
      
    case SUBMIT_OPTION_TY:
      ret = [self handleOptionSubmit:doc MOC:MOC];
      break;
      
    case LOAD_EVENT_AWARD_RESULT_TY:
      ret = [self handleEventAwardResult:doc MOC:MOC];
      break;
      
    case EVENTLIST_TY:
    case MY_EVENT_TY:
      ret = [self handleFetchEventList:doc MOC:MOC];
      break;
      
    case EVENT_CITY_LIST_TY:
      ret = [self handleFetchCitys:doc MOC:MOC];
      break;
      // ------ end of event ------
      
      // ------ begin of alumni network ------
    case CLUB_MANAGE_USER_TY:
    case CLUB_MANAGE_QUERY_USER_TY:
    case CHECKIN_USER_TY:
    case SIGNUP_USER_TY:
    case WINNER_USER_TY:
      ret = [self handleFetchAlumni:doc MOC:MOC itemType:ALUMNI_USER_TY];
      
      break;
      
    case ALUMNI_TY:
      ret = [self handleFetchAlumni:doc MOC:MOC itemType:ALUMNI_USER_TY];
      break;
      
    case LOAD_NAME_CARD_CANDIDATES_TY:
      ret = [self handleFetchNameCard:doc MOC:MOC];
      break;
      
    case LOAD_ALL_KNOWN_ALUMNUS_TY:
      ret = [self handleFetchSpecifyAlumni:doc
                                       MOC:MOC
                            alumniTypeName:@"RecommendAlumni"];
      break;
      
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
      ret = [self handleConnectAlumnusCount:doc];
      break;
      
    case LOAD_ATTRACTIVE_ALUMNUS_TY:
      ret = [self handleFetchSpecifyAlumni:doc
                                       MOC:MOC
                            alumniTypeName:@"AttractiveAlumni"];
      break;
      
    case LOAD_KNOWN_ALUMNUS_TY:
      ret = [self handleKnownAlumnus:doc MOC:MOC];
      break;
      
    case LOAD_PROJECT_BACKERS_TY:
      ret = [self handleFetchSpecifyAlumni:doc
                                       MOC:MOC
                            alumniTypeName:@"Alumni"];
      break;
      
    case SHARE_POST_LIST_TY:
      ret = [self handleSharePost:doc MOC:MOC];
      break;
      
    case LOAD_ALUMNI_NEWS_TY:
      ret = [self handleAlumniNews:doc MOC:MOC newsType:ALUMNI_NEWS_TY];
      break;
      
    case LOAD_BIZ_NEWS_TY:
      ret = [self handleAlumniNews:doc MOC:MOC newsType:BIZ_NEWS_TY];
      break;
      
    case LOAD_NEWS_REPORT_TY:
      ret = [self handleAlumniNews:doc MOC:MOC newsType:FOR_HOMEPAGE_NEWS_TY];
      break;
      
    case ALUMNI_QUERY_DETAIL_TY:
    case CLUB_USER_DETAIL_TY:
      ret = [self handleParserUserDetailInfo:doc MOC:MOC];
      break;
      // ------ end of alumni network ------
      
      // ------ begin of enter ------
    case LOAD_BIZ_GROUPS_TY:
      ret = [self handleBizGroups:doc MOC:MOC];
      break;
      
      // ------ end of alumni network ------
      
      // ------ begin of homepage ------
    case LOAD_HOMEPAGE_INFO:
      ret = [self handleHomepageInfo:doc MOC:MOC];
      break;
      // ------ end of homepage ------
      
      // ------ begin of video ------
    case LOAD_LATEST_VIDEO_TY:
      ret = [self handleLatestVideos:doc MOC:MOC];
      break;
      // ------ end of video ------
      
    case LOAD_RECOMMENDED_EVENT_TY:
      ret = [self handleRecommendedEvent:doc MOC:MOC];
      break;
      
      // ------ begin of payment ------
    case PAYMENT_RESULT_CHECK_TY:
      ret = [self checkPaymentResult:doc];
      break;
      // ------ end of payment ------
      
    case FETCH_FEEDBACK_MSG_TY:
      ret = [self handleFeedback:doc MOC:MOC];
      break;
      
    case CLUB_FLITER_TY:
      ret = [self handleClubFliter:doc MOC:MOC];
      break;
      
      // ---------- welfare ----------
    case WELFARE_LIST_TY:
      ret = [self handleWelfare:doc MOC:MOC];
      break;
      
    case WELFARE_DETAIL_TY:
      ret = [self handleWelfareDetail:doc MOC:MOC];
      break;
      
    case  LOAD_STORE_LIST_TY:
      ret = [self handleStoreList:doc MOC:MOC];
      break;
      
    case LOAD_STORE_DETAIL_TY:
      ret = [self handleStoreDetail:doc MOC:MOC];
      break;
      
    case LOAD_WELFARE_BRAND_DETAIL_TY:
      ret = [self handleWelfareBrandDetail:doc MOC:MOC];
      break;
      
    case DOWNLOAD_COUPON_TY:
      ret = [self parserResponseCode:doc] == RESP_OK ? YES : NO;
      break;
      
    case GET_DOWNLOADED_USER_TY:
      ret = [self handleCouponDownloadedUserList:doc MOC:MOC];
      break;
      
    default:
      ret = NO;
      break;
  }
  
  return ret;
}

+ (BOOL)parserFavoritedItems:(NSData *)xmlData
                        type:(WebItemType)type
                         MOC:(NSManagedObjectContext *)MOC
           connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                         url:(NSString *)url
                 favoritedBy:(long long)favoritedBy
       beCheckDetailedItemId:(long long)beCheckDetailedItemId {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
		return NO;
	}
  
  BOOL ret = YES;
  
  switch (type) {
    case LOAD_FAVORITED_NEWS_TY:
      ret = [self handleLoadFavoritedNews:doc
                                      MOC:MOC
                              favoritedBy:favoritedBy
                    beCheckDetailedItemId:beCheckDetailedItemId];
      break;
      
    case LOAD_FAVORITED_PEOPLE_TY:
      ret = [self handleFavoritedUserList:doc
                                      MOC:MOC
                              favoritedBy:favoritedBy
                    beCheckDetailedItemId:beCheckDetailedItemId];
      break;
      
    default:
      ret = NO;
      break;
  }
  return ret;
}


#pragma mark - years
+ (BOOL)loadYearsFromLocal:(NSManagedObjectContext *)MOC {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"years" ofType:@"xml"];
  
  NSData *data = [NSData dataWithContentsOfFile:path];
  
  NSString *xmlStr = [[[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding] autorelease];
  
  CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:xmlStr
                                                       options:0
                                                         error:nil] autorelease];
  NSArray *yearList = [doc nodesForXPath:@"//years/year" error:nil];
  for (CXMLElement *yearEl in yearList) {
    
    NSArray *ids = [yearEl elementsForName:@"id"];
    long long yearId = 0ll;
    if (ids.count > 0) {
      yearId = [[ids.lastObject stringValue] longLongValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(yearId == %lld)", yearId];
    Year *checkPoint = (Year *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                         entityName:@"Year"
                                                          predicate:predicate];
    if (checkPoint) {
      checkPoint.selected = @NO;
      continue;
    }
    
    Year *year = (Year *)[NSEntityDescription insertNewObjectForEntityForName:@"Year"
                                                       inManagedObjectContext:MOC];
    NSArray *years = [yearEl elementsForName:@"count"];
    if (years.count > 0) {
      year.count = [years.lastObject stringValue];
    }
    year.yearId = @(yearId);
    
    year.selected = @NO;
  }
  
  return [WXWCoreDataUtils saveMOCChange:MOC];
}

#pragma mark - fetch host
+ (BOOL)parserFetchHost:(NSData *)data {
  
  NSString *host = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  NSRange range = [host rangeOfString:@"\t"];
  if (0 == range.length) {
    
    [AppManager instance].networkStable = NO;
    debugLog(@"Get host name failed");
    
    [AppManager instance].host = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
    if ([AppManager instance].host && [AppManager instance].host.length > 0) {
      return YES;
    } else {
      // the tmpHost has no target host name
      return NO;
    }
  }
  
  [AppManager instance].host = [host substringWithRange:NSMakeRange(0, range.location)];
  [CommonUtils saveStringValueToLocal:[AppManager instance].host key:HOST_LOCAL_KEY];
  
  [AppManager instance].networkStable = YES;
  
  return YES;
}

#pragma mark - load place
+ (BOOL)handleLoadPlace:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC centerItemId:(long long)centerItemId {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *placeList = [respDoc nodesForXPath:@"//place" error:nil];
    
    for (CXMLElement *placeEl in placeList) {
      NSString *placeId = nil;
      NSArray *placeIds = [placeEl elementsForName:@"id"];
      if ([placeIds count] > 0) {
        placeId = [[placeIds lastObject] stringValue];
      }
      
      NSArray *distances = [placeEl elementsForName:@"distance"];
      CGFloat distance = 0.0;
      if ([distances count] > 0) {
        distance = [[[distances lastObject] stringValue] floatValue];
      }
      
      NSArray *names = [placeEl elementsForName:@"name"];
      NSString *placeName = nil;
      if ([names count] > 0) {
        placeName = [CommonUtils decodeAndReplacePlusForText:[names.lastObject stringValue]];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", placeId];
      Place *checkPoint = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Place" predicate:predicate];
      if (checkPoint) {
        checkPoint.distance = [NSNumber numberWithInt:distance];
        checkPoint.placeName = placeName;
        checkPoint.cityName = placeName;
        continue;
      }
      
      Place *place = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:MOC];
      place.placeId = placeId;
      place.centerItemId = @(centerItemId);
      place.cityId = @0LL;
      place.distance = @(distance);
      place.placeName = placeName;
      place.cityName = placeName;
      place.selected = @NO;
      place.placeType = @(NORMAL_PLACE_TY);
    }
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
    
  } else {
    return NO;
  }
}

+ (BOOL)parserResponseXml:(NSData *)xmlData
                     type:(WebItemType)type
                      MOC:(NSManagedObjectContext *)MOC
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url
             parentItemId:(long long)parentItemId {
  
  CXMLDocument *doc = nil;
  
  
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
    return NO;
  }
  
  BOOL ret = YES;
  
  switch (type) {
    case LOAD_PLACE_TY:
      ret = [self handleLoadPlace:doc MOC:MOC centerItemId:parentItemId];
      break;
      
    case LOAD_BRAND_ALUMNUS_TY:
      ret = [self handleAlumniFounders:doc MOC:MOC brandId:parentItemId];
      break;
      
    case LOAD_BRAND_COMMENT_TY:
      ret = [self handleLoadBrandComments:doc MOC:MOC brandId:parentItemId];
      break;
      
    default:
      break;
  }
  
  return ret;
  
}

#pragma mark - parser sync response
+ (BOOL)parserResponseNode:(NSData *)xmlData
                       doc:(CXMLDocument **)doc {
  NSString *xmlStr = [[[NSString alloc] initWithData:xmlData
                                            encoding:NSUTF8StringEncoding] autorelease];
  if (EC_DEBUG) {
    NSLog(@"xml string: %@", xmlStr);
  }
  if (xmlStr == nil || [xmlStr isEqualToString:NULL_PARAM_VALUE] || xmlStr.length == 0) {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSParserXmlNullMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
    return NO;
  }
  
  NSString *contentStr = nil;
  NSArray *respCodes = nil;
  NSArray *respDesc = nil;
  
  NSRange range = [xmlStr rangeOfString:@"<response>"];
  if (range.length == 0) {
    contentStr = [NSString stringWithString:xmlStr];
    
    NSError* error = nil;
    *doc = [[CXMLDocument alloc] initWithXMLString:contentStr
                                           options:0
                                             error:&error];
    if (error || !*doc) {
      debugLog(@"Parser xml for class post failed: %@", [error domain]);
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSParserXmlErrMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
      return NO;
    }
    
    respCodes = [*doc nodesForXPath:@"//contents/code" error:nil];
    respDesc = [*doc nodesForXPath:@"//contents/desc" error:nil];
    if (APP_EXPIRED_CODE == [[[respCodes lastObject] stringValue] intValue]) {
      return NO;
    }
  } else {
    contentStr = [xmlStr substringFromIndex:range.location];
    
    NSError* error = nil;
    *doc = [[CXMLDocument alloc] initWithXMLString:contentStr
                                           options:0
                                             error:&error];
    if (error || !*doc) {
      debugLog(@"Parser xml for class post failed: %@", [error domain]);
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSParserXmlErrMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
      return NO;
    }
    
    respCodes = [*doc nodesForXPath:@"//response/code" error:nil];
    respDesc = [*doc nodesForXPath:@"//response/desc" error:nil];
    
    if (APP_EXPIRED_CODE == [[[respCodes lastObject] stringValue] intValue] ) {
      return NO;
    }
  }
  
  // Session
  [AppManager instance].sessionExpired = NO;
  
  return YES;
}

+ (BOOL)parserSyncResponseXml:(NSData *)xmlData
                         type:(XmlParserItemType)type
                          MOC:(NSManagedObjectContext *)MOC {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return NO;
  }
  
  BOOL ret = YES;
  
  switch (type) {
      
    case LOGIN_SRC:
      ret = [self handleUserMsg:doc MOC:MOC];
      break;
      
    default:
      break;
  }
  
  RELEASE_OBJ(doc);
  
  return ret;
}

+ (NSInteger)parserResponseCode:(CXMLDocument *)respDoc {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  NSInteger code = 0;
  if (respCodes.count == 0) {
    code = RESP_OK;
  } else {
    code = [[respCodes.lastObject stringValue] intValue];
  }
  return code;
}

#pragma mark - User Msg
+ (BOOL)handleUserMsg:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *respCodes = [respDoc nodesForXPath:@"//contents/code" error:nil];
  NSArray *respDesc = [respDoc nodesForXPath:@"//contents/desc" error:nil];
  NSArray *helpUrls = [respDoc nodesForXPath:@"//contents/signinHelpUrl" error:nil];
  
  if (helpUrls.count > 0) {
    [AppManager instance].loginHelpUrl = [helpUrls.lastObject stringValue];
  }
  
  if (RESP_OK != [[[respCodes lastObject] stringValue] intValue]){
    [AppManager instance].errDesc = [[respDesc lastObject] stringValue];
    
    return NO;
  }
  
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  for (CXMLElement *el in alumniList) {
    
    NSArray *sessionIds = [el elementsForName:@"sessionId"];
    if ([sessionIds count] > 0) {
      [AppManager instance].sessionId = [[[sessionIds lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *personIds = [el elementsForName:@"personId"];
    if (personIds.count > 0) {
      [AppManager instance].personId = [[personIds lastObject] stringValue];
    }
    
    NSArray *userTypes = [el elementsForName:@"userType"];
    if ([userTypes count] > 0) {
      [AppManager instance].userType = [[userTypes lastObject] stringValue];
    }
    
    NSArray *userIds = [el elementsForName:@"userId"];
    if ([userIds count] > 0) {
      [AppManager instance].userId = [[[userIds lastObject] stringValue]lowercaseString];
      [CommonUtils saveStringValueToLocal:[AppManager instance].userId key:USER_ID_LOCAL_KEY];
    }
    
    NSArray *names = [el elementsForName:@"name"];
    if ([names count] > 0) {
      [AppManager instance].userName = [[[names lastObject] stringValue]lowercaseString];
    }
    
    NSArray *imageUrls = [el elementsForName:@"imageUrl"];
    if ([imageUrls count] > 0) {
      [AppManager instance].userImgUrl = [[imageUrls lastObject] stringValue];
    }
    
    NSArray *classNames = [el elementsForName:@"class"];
    if ([classNames count] > 0) {
      [AppManager instance].classGroupId = [[classNames lastObject] stringValue];
      [AppManager instance].className = [AppManager instance].classGroupId;
    }
    
    NSArray *emails = [el elementsForName:@"email"];
    if ([emails count] > 0) {
      [AppManager instance].email = [[emails lastObject] stringValue];
    }
    
    NSArray *hostTypes = [el elementsForName:@"host_type"];
    if ([hostTypes count] > 0) {
      [AppManager instance].classClubType = [[hostTypes lastObject] stringValue];
    }
    
    NSArray *hostIds = [el elementsForName:@"host_id"];
    if ([hostIds count] > 0) {
      [AppManager instance].classClubId = [[hostIds lastObject] stringValue];
    }
    
    NSArray *msgNums = [el elementsForName:@"all_new_pr_count"];
    if ([msgNums count] > 0) {      
      [CommonUtils updateNewDMNumber:[[msgNums lastObject] stringValue].intValue];
    }
    
    BOOL accessAvailable;
    NSArray *accessCheckInAvailables = [el elementsForName:@"is_alumni_manager"];
    if ([accessCheckInAvailables count] > 0) {
      
      accessAvailable = ([[[accessCheckInAvailables lastObject] stringValue] intValue] == 1) ? YES : NO;
      [AppManager instance].accessCheckInAvailable = accessAvailable;
    }
  }
  
  return YES;
}

#pragma mark - handle fetch system message
+ (BOOL)handleLoadSystemMessages:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *msgList = [respDoc nodesForXPath:@"//messages" error:nil];
  for (CXMLElement *el in msgList) {
    
    NSArray *msgIds = [el elementsForName:@"id"];
    NSString *msgId = nil;
    if ([msgIds count] > 0) {
      msgId = [[msgIds lastObject] stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId == %@)", msgId];
    Messages *isExist = (Messages *)[CommonUtils hasSameObjectAlready:MOC
                                                           entityName:@"Messages"
                                                         sortDescKeys:nil
                                                            predicate:predicate];
    if (isExist) {
      continue;
    }
    
    Messages *msg = [NSEntityDescription insertNewObjectForEntityForName:@"Messages"
                                                  inManagedObjectContext:MOC];
    msg.messageId = msgId;
    
    NSArray *messages = [el elementsForName:@"message"];
    if ([messages count] > 0) {
      msg.content = [[[messages lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *types = [el elementsForName:@"type"];
    if ([types count] > 0) {
      msg.type = @([[[types lastObject] stringValue] intValue]);
    }
    
    msg.quickViewed = @0;
  }
  
  
  if ([CommonUtils saveMOCChange:MOC]) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - fetch alumni list
+ (Alumni *)parserAlumniInfo:(CXMLElement *)el
                    personId:(NSString *)personId
                      alumni:(Alumni *)alumni
                         MOC:(NSManagedObjectContext *)MOC
                    itemType:(UserType)itemType
                       index:(int)index {
  
  alumni.personId = personId;
  
  NSArray *userTypes = [el elementsForName:@"user_type"];
  if ([userTypes count] > 0) {
    alumni.userType = [[userTypes lastObject] stringValue];
  }
  if (alumni.userType == nil) {
    alumni.userType = @"1";
  }
  
  alumni.containerType = @(itemType);
  
  NSArray *userIds = [el elementsForName:@"userId"];
  if ([userIds count] > 0) {
    alumni.userId = [[userIds lastObject] stringValue];
  }
  
  NSArray *tableInfos = [el elementsForName:@"table_info"];
  alumni.tableInfo = nil;
  if (tableInfos.count > 0) {
    alumni.tableInfo = [CommonUtils decodeAndReplacePlusForText:[tableInfos.lastObject stringValue]];
  }
  
  NSDate *mDate = nil;
  NSTimeInterval timestamp = 0;
  NSArray *times = [el elementsForName:@"times"];
  if ([times count] > 0) {
    timestamp = [[[times lastObject] stringValue] doubleValue];
    mDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
    alumni.time = [CommonUtils getElapsedTime:mDate];
  }
  
  NSArray *distances = [el elementsForName:@"distance"];
  if ([distances count] > 0) {
    alumni.distance = [[distances lastObject] stringValue];
  }
  
  NSInteger order = 0;
  NSArray *orders = [el elementsForName:@"orders"];
  if ([orders count] > 0) {
    order = [[[orders lastObject] stringValue] intValue];
    alumni.orderId = @(order);
  } else {
    alumni.orderId = @(index);
  }
  
  NSArray *companyCountryCs = [el elementsForName:@"companyCountryC"];
  if ([companyCountryCs count] > 0) {
    alumni.companyCountryC = [[companyCountryCs lastObject] stringValue];
  }
  
  NSArray *companyCountryEs = [el elementsForName:@"companyCountryE"];
  if ([companyCountryEs count] > 0) {
    alumni.companyCountryE = [[companyCountryEs lastObject] stringValue];
  }
  
  NSArray *isApproves = [el elementsForName:@"is_approve"];
  if ([isApproves count] > 0) {
    alumni.isApprove = [[isApproves lastObject] stringValue];
  }
  
  NSArray *companyProvinces = [el elementsForName:@"companyProvince"];
  if ([companyProvinces count] > 0) {
    alumni.companyProvince = [[companyProvinces lastObject] stringValue];
  }
  
  NSArray *companyCities = [el elementsForName:@"companyCity"];
  if ([companyCities count] > 0) {
    alumni.companyCity = [[companyCities lastObject] stringValue];
  }
  
  NSArray *jobTitles = [el elementsForName:@"jobTitle"];
  if ([jobTitles count] > 0) {
    alumni.jobTitle = [[jobTitles lastObject] stringValue];
  }
  
  NSArray *names = [el elementsForName:@"name"];
  if ([names count] > 0) {
    alumni.name = [[names lastObject] stringValue];
    if (alumni.name && alumni.name.length > 0) {
      alumni.firstNamePinyinChar = [PYMethod firstCharOfNamePinyin:alumni.name];
    } else {
      alumni.firstNamePinyinChar = @"#";
    }
  }
  
  NSArray *companyNames = [el elementsForName:@"companyName"];
  if ([companyNames count] > 0) {
    alumni.companyName = [[companyNames lastObject] stringValue];
  }
  if (alumni.companyName && alumni.companyName.length == 0) {
    alumni.companyName = NULL_PARAM_VALUE;
  }
  
  NSArray *imageUrls = [el elementsForName:@"imageUrl"];
  if ([imageUrls count] > 0) {
    alumni.imageUrl = [[imageUrls lastObject] stringValue];
  }
  if (alumni.imageUrl && alumni.imageUrl.length == 0) {
    alumni.imageUrl = NULL_PARAM_VALUE;
  }
  
  NSArray *classNames = [el elementsForName:@"class"];
  if ([classNames count] > 0) {
    alumni.classGroupName = [[classNames lastObject] stringValue];
  }
  
  NSArray *companyAddressCs = [el elementsForName:@"companyAddressC"];
  if ([companyAddressCs count] > 0) {
    alumni.companyAddressC = [[companyAddressCs lastObject] stringValue];
  }
  
  NSArray *companyAddressEs = [el elementsForName:@"companyAddressE"];
  if ([companyAddressEs count] > 0) {
    alumni.companyAddressE = [[companyAddressEs lastObject] stringValue];
  }
  
  NSArray *companyPhones = [el elementsForName:@"companyPhone"];
  if ([companyPhones count] > 0) {
    alumni.companyPhone = [[companyPhones lastObject] stringValue];
  }
  if (alumni.companyPhone == nil) {
    alumni.companyPhone = NULL_PARAM_VALUE;
  }
  
  NSArray *companyFaxs = [el elementsForName:@"companyFax"];
  if ([companyFaxs count] > 0) {
    alumni.companyFax = [[companyFaxs lastObject] stringValue];
  }
  
  NSArray *emails = [el elementsForName:@"email"];
  if ([emails count] > 0) {
    alumni.email = [[emails lastObject] stringValue];
  }
  if (alumni.email == nil) {
    alumni.email = NULL_PARAM_VALUE;
  }
  
  NSArray *phones = [el elementsForName:@"mobile"];
  if ([phones count] > 0) {
    alumni.phoneNumber = [[phones lastObject] stringValue];
  }
  if (nil == alumni.phoneNumber) {
    alumni.phoneNumber = NULL_PARAM_VALUE;
  }
  
  BOOL isCheck;
  NSArray *isChecks = [el elementsForName:@"is_check"];
  if ([isChecks count] > 0) {
    isCheck = ([[[isChecks lastObject] stringValue] intValue] == 1) ? YES : NO;
    alumni.isCheckIn = @(isCheck);
  }
  
  NSArray *plats = [el elementsForName:@"plat"];
  if ([plats count] > 0) {
    alumni.plat = [[plats lastObject] stringValue];
  }
  if (nil == alumni.email) {
    alumni.plat = NULL_PARAM_VALUE;
  }
  
  NSArray *versions = [el elementsForName:@"version"];
  if ([versions count] > 0) {
    alumni.version = [[versions lastObject] stringValue];
  }
  if (nil == alumni.version) {
    alumni.version = NULL_PARAM_VALUE;
  }
  
  NSArray *shakePlaces = [el elementsForName:@"shake_where"];
  if ([shakePlaces count] > 0) {
    alumni.shakePlace = [[shakePlaces lastObject] stringValue];
  }
  if (nil == alumni.shakePlace) {
    alumni.shakePlace = NULL_PARAM_VALUE;
  }
  
  NSArray *shakeThings = [el elementsForName:@"shake_what"];
  if ([shakeThings count] > 0) {
    alumni.shakeThing = [[shakeThings lastObject] stringValue];
  }
  if (nil == alumni.shakeThing) {
    alumni.shakeThing = NULL_PARAM_VALUE;
  }
  
  NSArray *lastMsg = [el elementsForName:@"last_message"];
  if ([lastMsg count] > 0) {
    alumni.lastMsg = [[lastMsg lastObject] stringValue];
  }
  if (nil == alumni.lastMsg) {
    alumni.lastMsg = NULL_PARAM_VALUE;
  }
  
  NSArray *notReadMsgCount = [el elementsForName:@"not_read_count"];
  if ([notReadMsgCount count] > 0) {
    order = [[[notReadMsgCount lastObject] stringValue] intValue];
    alumni.notReadMsgCount = @(order);
  }
  if (nil == alumni.notReadMsgCount) {
    alumni.notReadMsgCount = @0;
  }
  
  NSArray *isLastMessageFromSelf = [el elementsForName:@"is_last_message_from_self"];
  if ([isLastMessageFromSelf count] > 0) {
    order = [[[isLastMessageFromSelf lastObject] stringValue] intValue];
    alumni.isLastMessageFromSelf = @(order);
  }
  if (nil == alumni.isLastMessageFromSelf) {
    alumni.isLastMessageFromSelf = @0;
  }
  
  NSArray *latitudes = [el elementsForName:@"latitude"];
  if ([latitudes count] > 0) {
    alumni.latitude = [[latitudes lastObject] stringValue];
  }
  if (nil == alumni.latitude) {
    alumni.latitude = NULL_PARAM_VALUE;
  }
  
  NSArray *longitudes = [el elementsForName:@"longitude"];
  if ([longitudes count] > 0) {
    alumni.longitude = [[longitudes lastObject] stringValue];
  }
  if (nil == alumni.longitude) {
    alumni.longitude = NULL_PARAM_VALUE;
  }
  
  NSArray *memberLevels = [el elementsForName:@"member_level"];
  if ([memberLevels count] > 0) {
    alumni.memberLevel = [[memberLevels lastObject] stringValue];
  }
  if (nil == alumni.memberLevel) {
    alumni.memberLevel = NULL_PARAM_VALUE;
  }
  
  NSArray *hasApplieds = [el elementsForName:@"has_applied"];
  if ([hasApplieds count] > 0) {
    alumni.hasApplied = [[hasApplieds lastObject] stringValue];
  }
  if (nil == alumni.hasApplied) {
    alumni.hasApplied = @"0";
  }
  
  NSArray *feeToPays = [el elementsForName:@"fee_to_pay"];
  if ([feeToPays count] > 0) {
    alumni.feeToPay = [[feeToPays lastObject] stringValue];
  }
  if (nil == alumni.feeToPay) {
    alumni.feeToPay = NULL_PARAM_VALUE;
  }
  
  NSArray *feePaids = [el elementsForName:@"fee_paid"];
  if ([feePaids count] > 0) {
    alumni.feePaid = [[feePaids lastObject] stringValue];
  }
  if (nil == alumni.feePaid) {
    alumni.feePaid = NULL_PARAM_VALUE;
  }
  
  return alumni;
}

+ (BOOL)handleFetchNameCard:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  int alumniIndex = 0;
  for (CXMLElement *el in alumniList) {
    
    NSArray *personIds = [el elementsForName:@"personId"];
    NSString *personId = [[personIds lastObject] stringValue];
    if ([[AppManager instance].personId isEqualToString:personId]) {
      continue;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
    NameCard *nameCard = (NameCard *)[CommonUtils hasSameObjectAlready:MOC
                                                            entityName:@"NameCard"
                                                          sortDescKeys:nil
                                                             predicate:predicate];
    
    if (nil == nameCard) {
      nameCard = (NameCard *)[NSEntityDescription insertNewObjectForEntityForName:@"NameCard"
                                                           inManagedObjectContext:MOC];
    }
    
    [self parserAlumniInfo:el
                  personId:personId
                    alumni:nameCard
                       MOC:MOC
                  itemType:ALUMNI_USER_TY
                     index:alumniIndex];
    alumniIndex++;
  }
  return SAVE_MOC(MOC);
}

+ (Alumni *)prepareForAlumniParserWithElement:(CXMLElement *)el
                                          MOC:(NSManagedObjectContext *)MOC
                               alumniTypeName:(NSString *)alumniTypeName {
  
  NSArray *personIds = [el elementsForName:@"personId"];
  NSString *personId = [[personIds lastObject] stringValue];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
  id alumni = [CommonUtils hasSameObjectAlready:MOC
                                     entityName:alumniTypeName
                                   sortDescKeys:nil
                                      predicate:predicate];
  
  if (nil == alumni) {
    alumni = [NSEntityDescription insertNewObjectForEntityForName:alumniTypeName
                                           inManagedObjectContext:MOC];
  }
  
  ((Alumni *)alumni).personId = personId;

  return alumni;
}

+ (BOOL)handleKnownAlumnus:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  int alumniIndex = 0;
  for (CXMLElement *el in alumniList) {
    
    KnownAlumni *alumni = (KnownAlumni *)[self prepareForAlumniParserWithElement:el
                                                                             MOC:MOC
                                                                  alumniTypeName:@"KnownAlumni"];
    
    [self parserAlumniInfo:el
                  personId:((Alumni *)alumni).personId
                    alumni:(Alumni *)alumni
                       MOC:MOC
                  itemType:ALUMNI_USER_TY
                     index:alumniIndex];
    
    NSArray *classmates = [el elementsForName:@"classmate"];
    if (classmates.count > 0) {
      alumni.classmate = @([classmates.lastObject stringValue].intValue);
    } 

    alumniIndex++;
  }
  return SAVE_MOC(MOC);
}

+ (BOOL)handleFetchSpecifyAlumni:(CXMLDocument *)respDoc
                             MOC:(NSManagedObjectContext *)MOC
                  alumniTypeName:(NSString *)alumniTypeName {
  
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  int alumniIndex = 0;
  for (CXMLElement *el in alumniList) {
    
    id alumni = [self prepareForAlumniParserWithElement:el MOC:MOC alumniTypeName:alumniTypeName];
    
    [self parserAlumniInfo:el
                  personId:((Alumni *)alumni).personId
                    alumni:(Alumni *)alumni
                       MOC:MOC
                  itemType:ALUMNI_USER_TY
                     index:alumniIndex];
    alumniIndex++;
  }
  return SAVE_MOC(MOC);
}

+ (BOOL)handleAlumniNews:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC newsType:(NewsType)newsType {
  
  if (RESP_OK == [self parserResponseCode:respDoc]) {
    
    NSArray *newsList = [respDoc nodesForXPath:@"//news" error:nil];
    for (CXMLElement *newsEl in newsList) {
      NSArray *newsIds = [newsEl elementsForName:@"id"];
      long long newsId = 0ll;
      if ([newsIds count] > 0) {
        newsId = [newsIds.lastObject stringValue].longLongValue;
      }
      
      NSArray *createTimes = [newsEl elementsForName:@"date"];
      NSTimeInterval timestamp = 0;
      NSDate *date = [[[NSDate alloc] init] autorelease];
      if ([createTimes count] > 0) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        date = [dateFormatter dateFromString:[createTimes.lastObject stringValue]];
        timestamp = [CommonUtils convertToUnixTS:date];
      }
      
      NSInteger elapsedDayCount = [CommonUtils getElapsedDayCount:date];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(newsId == %lld)", newsId];
      
      News *news = (News *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                     entityName:@"News"
                                                      predicate:predicate];
      
      if (news) {
        news.timestamp = @(timestamp);
        news.date = [CommonUtils simpleFormatDate:date secondAccuracy:YES];
        news.dateSeparator = [CommonUtils simpleFormatDateWithYear:date secondAccuracy:NO];
        news.elapsedTime = [CommonUtils getElapsedTime:date];
        news.elapsedDayCount = @(elapsedDayCount);
        continue;
      }
      
      news = (News *)[NSEntityDescription insertNewObjectForEntityForName:@"News"
                                                   inManagedObjectContext:MOC];
      news.newsId = @(newsId);
      news.timestamp = @(timestamp);
      news.date = [CommonUtils simpleFormatDate:date secondAccuracy:YES];
      news.dateSeparator = [CommonUtils simpleFormatDateWithYear:date secondAccuracy:NO];
      news.elapsedTime = [CommonUtils getElapsedTime:date];
      news.elapsedDayCount = @(elapsedDayCount);
      
      NSArray *titles = [newsEl elementsForName:@"title"];
      if ([titles count] > 0) {
        news.title = [CommonUtils decodeAndReplacePlusForText:[titles.lastObject stringValue]];
      }
      
      NSArray *subTitles = [newsEl elementsForName:@"sub_title"];
      if ([subTitles count] > 0) {
        news.subTitle = [CommonUtils decodeAndReplacePlusForText:[subTitles.lastObject stringValue]];
      }
      
      NSArray *thumbnails = [newsEl elementsForName:@"image_url"];
      if ([thumbnails count]) {
        news.imageUrl = [[thumbnails lastObject] stringValue];
      }
      
      NSArray *urls = [newsEl elementsForName:@"content_url"];
      if ([urls count] > 0) {
        news.url = [CommonUtils decodeAndReplacePlusForText:[[urls lastObject] stringValue]];
      }
      
      news.type = @(newsType);
      
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

+ (BOOL)handleFetchAlumni:(CXMLDocument *)respDoc
                      MOC:(NSManagedObjectContext *)MOC
                 itemType:(UserType)itemType {
  
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  NSArray *winnerTypes = [respDoc nodesForXPath:@"//winner_type"
                                          error:nil];
  if (winnerTypes.count > 0) {
    [AppManager instance].shakeWinnerType = [winnerTypes.lastObject stringValue].intValue;
  }
  
  NSArray *winnerInfos = [respDoc nodesForXPath:@"//winner_text"
                                          error:nil];
  if (winnerInfos.count > 0) {
    [AppManager instance].shakeWinnerInfo = [CommonUtils decodeAndReplacePlusForText:[winnerInfos.lastObject stringValue]];
  }
  
  NSArray *msgNums = [respDoc nodesForXPath:@"//response/all_new_pr_count" error:nil];
  if ([msgNums count] > 0) {
    [CommonUtils updateNewDMNumber:[[msgNums lastObject] stringValue].intValue];
  } else {
    [CommonUtils updateNewDMNumber:0];
  }
  
  int alumniIndex = 0;
  for (CXMLElement *el in alumniList) {
    
    NSArray *loginStatus = [el elementsForName:@"loginStatus"];
    if ([loginStatus count] > 0) {
      if ([[[loginStatus lastObject] stringValue] isEqualToString:@"invalid"]) {
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
        [AppManager instance].needPrompt = NO;
        return NO;
      }
    }
    
    NSArray *queryLimit = [el elementsForName:@"queryLimit"];
    if ([queryLimit count] > 0) {
      if ([[[queryLimit lastObject] stringValue] isEqualToString:@"YES"]) {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSQueryLimitMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        return NO;
      }
    }
    
    NSArray *personIds = [el elementsForName:@"personId"];
    NSString *personId = [[personIds lastObject] stringValue];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
    Alumni *alumni = (Alumni *)[CommonUtils hasSameObjectAlready:MOC
                                                      entityName:@"Alumni"
                                                    sortDescKeys:nil
                                                       predicate:predicate];
    
    if (alumni) {
      alumni.containerType = [NSNumber numberWithInt:itemType];
    } else {
      alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni" inManagedObjectContext:MOC];
    }
    
    [self parserAlumniInfo:el
                  personId:personId
                    alumni:alumni
                       MOC:MOC
                  itemType:itemType
                     index:alumniIndex];
    alumniIndex++;
  }
  
  return SAVE_MOC(MOC);
}

#pragma mark - fetch event alumni detail info

+ (BOOL)handleParserUserDetailInfo:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  for (CXMLElement *el in alumniList) {
    NSArray *loginStatus = [el elementsForName:@"loginStatus"];
    if ([loginStatus count] > 0) {
      if ([[[loginStatus lastObject] stringValue] isEqualToString:@"invalid"]) {
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
        [AppManager instance].needPrompt = NO;
        return NO;
      }
    }
    
    NSArray *personIds = [el elementsForName:@"personId"];
    NSString *personId = nil;
    if (personIds.count > 0) {
      personId = [[personIds lastObject] stringValue];
    }
    
    NSArray *lastSignInTimes = [el elementsForName:@"lastSignInTime"];
    NSString *lastSignInTime = NULL_PARAM_VALUE;
    if (lastSignInTimes.count > 0) {
      lastSignInTime = [lastSignInTimes.lastObject stringValue];
    }
    
    NSArray *platInfos = [el elementsForName:@"platInfo"];
    NSString *platInfo = NULL_PARAM_VALUE;
    if (platInfos.count > 0) {
      platInfo = [platInfos.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
    Alumni *alumni = nil;
    alumni = (Alumni *)[CommonUtils hasSameObjectAlready:MOC
                                              entityName:@"Alumni"
                                            sortDescKeys:nil
                                               predicate:predicate];
    if (nil == alumni) {
      alumni = (Alumni*)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni" inManagedObjectContext:MOC];
    }
    
    alumni.personId = personId;
    
    alumni.lastSignInTime = lastSignInTime;
    alumni.platInfo = platInfo;
    
    NSArray *userIds = [el elementsForName:@"userId"];
    if ([userIds count] > 0) {
      alumni.userId = [[userIds lastObject] stringValue];
    }
    
    NSArray *names = [el elementsForName:@"name"];
    if ([names count] > 0) {
      alumni.name = [[names lastObject] stringValue];
    }
    
    NSArray *userTypes = [el elementsForName:@"user_type"];
    if ([userTypes count] > 0) {
      alumni.userType = [[userTypes lastObject] stringValue];
    }
    if (alumni.userType == nil) {
      alumni.userType = @"1";
    }
    
    NSArray *isAdmins = [el elementsForName:@"is_admin"];
    if ([isAdmins count] > 0) {
      alumni.isAdmin = [[isAdmins lastObject] stringValue];
    }
    if (alumni.isAdmin == nil) {
      alumni.isAdmin = NULL_PARAM_VALUE;
    }
    
    NSArray *isMembers = [el elementsForName:@"is_member"];
    if ([isMembers count] > 0) {
      alumni.isMember = [[isMembers lastObject] stringValue];
    }
    if (alumni.isMember == nil) {
      alumni.isMember = NULL_PARAM_VALUE;
    }
    
    NSArray *isApproves = [el elementsForName:@"is_approve"];
    if ([isApproves count] > 0) {
      alumni.isApprove = [[isApproves lastObject] stringValue];
    }
    if (alumni.isApprove == nil) {
      alumni.isApprove = NULL_PARAM_VALUE;
    }
    
    NSArray *friendsCounts = [el elementsForName:@"unless_connect_counts"];
    if (friendsCounts.count > 0) {
      alumni.allKnownAlumniCount = @([friendsCounts.lastObject stringValue].intValue);
    }
    
    NSArray *joinedGroupCounts = [el elementsForName:@"host_counts"];
    if (joinedGroupCounts.count > 0) {
      alumni.joinedGroupCount = @([joinedGroupCounts.lastObject stringValue].intValue);
    }
    
    NSArray *relationshipTypes = [el elementsForName:@"connect_level"];
    if (relationshipTypes.count > 0) {
      alumni.relationshipType = @([relationshipTypes.lastObject stringValue].intValue);
    }
    
    NSArray *companyCountryCs = [el elementsForName:@"companyCountryC"];
    if ([companyCountryCs count] > 0) {
      alumni.companyCountryC = [[companyCountryCs lastObject] stringValue];
    }
    
    NSArray *companyCountryEs = [el elementsForName:@"companyCountryE"];
    if ([companyCountryEs count] > 0) {
      alumni.companyCountryE = [[companyCountryEs lastObject] stringValue];
    }
    
    NSArray *companyProvinces = [el elementsForName:@"companyProvince"];
    if ([companyProvinces count] > 0) {
      alumni.companyProvince = [[companyProvinces lastObject] stringValue];
    }
    
    NSArray *companyCities = [el elementsForName:@"companyCity"];
    if ([companyCities count] > 0) {
      alumni.companyCity = [[companyCities lastObject] stringValue];
    }
    
    NSArray *jobTitles = [el elementsForName:@"jobTitle"];
    if ([jobTitles count] > 0) {
      alumni.jobTitle = [[jobTitles lastObject] stringValue];
    }
    
    NSArray *companyNames = [el elementsForName:@"companyName"];
    if ([companyNames count] > 0) {
      alumni.companyName = [[companyNames lastObject] stringValue];
    }
    
    NSArray *imageUrls = [el elementsForName:@"imageUrl"];
    if ([imageUrls count] > 0) {
      alumni.imageUrl = [[imageUrls lastObject] stringValue];
    }
    
    NSArray *classNames = [el elementsForName:@"class"];
    if ([classNames count] > 0) {
      alumni.classGroupName = [[classNames lastObject] stringValue];
    }
    
    NSArray *companyAddressCs = [el elementsForName:@"companyAddressC"];
    if ([companyAddressCs count] > 0) {
      alumni.companyAddressC = [[companyAddressCs lastObject] stringValue];
    }
    
    NSArray *companyAddressEs = [el elementsForName:@"companyAddressE"];
    if ([companyAddressEs count] > 0) {
      alumni.companyAddressE = [[companyAddressEs lastObject] stringValue];
    }
    
    NSArray *companyPhones = [el elementsForName:@"companyPhone"];
    if ([companyPhones count] > 0) {
      alumni.companyPhone = [[companyPhones lastObject] stringValue];
    }
    if (nil == alumni.companyPhone) {
      alumni.companyPhone = NULL_PARAM_VALUE;
    }
    
    NSArray *companyFaxs = [el elementsForName:@"companyFax"];
    if ([companyFaxs count] > 0) {
      alumni.companyFax = [[companyFaxs lastObject] stringValue];
    }
    
    NSArray *emails = [el elementsForName:@"email"];
    if ([emails count] > 0) {
      alumni.email = [[emails lastObject] stringValue];
    }
    if (nil == alumni.email) {
      alumni.email = NULL_PARAM_VALUE;
    }
    
    NSArray *phones = [el elementsForName:@"mobile"];
    if ([phones count] > 0) {
      alumni.phoneNumber = [[phones lastObject] stringValue];
    }
    if (nil == alumni.phoneNumber) {
      alumni.phoneNumber = NULL_PARAM_VALUE;
    }
    
    NSArray *weixins = [el elementsForName:@"weixin_account"];
    if ([weixins count] > 0) {
      alumni.weixin = [[weixins lastObject] stringValue];
    }
    if (nil == alumni.weixin) {
      alumni.weixin = NULL_PARAM_VALUE;
    }
    
    NSArray *sinas = [el elementsForName:@"sina_account"];
    if ([sinas count] > 0) {
      alumni.sina = [[sinas lastObject] stringValue];
    }
    if (nil == alumni.sina) {
      alumni.sina = NULL_PARAM_VALUE;
    }
    
    NSArray *linkedins = [el elementsForName:@"linkedin"];
    if ([linkedins count] > 0) {
      alumni.linkedin = [[linkedins lastObject] stringValue];
    }
    if (nil == alumni.linkedin) {
      alumni.linkedin = NULL_PARAM_VALUE;
    }
    
    NSArray *profiles = [el elementsForName:@"user_desc"];
    if ([profiles count] > 0) {
      alumni.profile = [[profiles lastObject] stringValue];
    }
    if (nil == alumni.profile) {
      alumni.profile = NULL_PARAM_VALUE;
    }
    
    BOOL isCheck;
    NSArray *isChecks = [el elementsForName:@"is_check"];
    if ([isChecks count] > 0) {
      isCheck = ([[[isChecks lastObject] stringValue] intValue] == 1) ? YES : NO;
      alumni.isCheckIn = @(isCheck);
    }
    
    alumni.containerType = @(EVENT_ALUMNI_LIST_TY);
  }
  
  return SAVE_MOC(MOC);
}

+ (BOOL)handleFetchUserDetailInfo:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *alumniList = [respDoc nodesForXPath:@"//content" error:nil];
  
  for (CXMLElement *el in alumniList) {
    NSArray *loginStatus = [el elementsForName:@"loginStatus"];
    if ([loginStatus count] > 0) {
      if ([[[loginStatus lastObject] stringValue] isEqualToString:@"invalid"]) {
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
        [AppManager instance].needPrompt = NO;
        return NO;
      }
    }
    
    NSArray *personIds = [el elementsForName:@"personId"];
    NSString *personId = nil;
    if (personIds.count > 0) {
      personId = [[personIds lastObject] stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
    AlumniDetail *alumniDetail = nil;
    alumniDetail = (AlumniDetail *)[CommonUtils hasSameObjectAlready:MOC
                                                          entityName:@"AlumniDetail"
                                                        sortDescKeys:nil
                                                           predicate:predicate];
    if (nil == alumniDetail) {
      alumniDetail = (AlumniDetail*)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniDetail" inManagedObjectContext:MOC];
    }
    
    
    alumniDetail.personId = personId;
    NSArray *userIds = [el elementsForName:@"userId"];
    if ([userIds count] > 0) {
      alumniDetail.userId = [[userIds lastObject] stringValue];
    }
    
    NSArray *names = [el elementsForName:@"name"];
    if ([names count] > 0) {
      alumniDetail.name = [[names lastObject] stringValue];
    }
    
    NSArray *userTypes = [el elementsForName:@"user_type"];
    if ([userTypes count] > 0) {
      alumniDetail.userType = [[userTypes lastObject] stringValue];
    }
    if (alumniDetail.userType == nil) {
      alumniDetail.userType = @"1";
    }
    
    NSArray *isAdmins = [el elementsForName:@"is_admin"];
    if ([isAdmins count] > 0) {
      alumniDetail.isAdmin = [[isAdmins lastObject] stringValue];
    }
    if (alumniDetail.isAdmin == nil) {
      alumniDetail.isAdmin = NULL_PARAM_VALUE;;
    }
    
    NSArray *isMembers = [el elementsForName:@"is_member"];
    if ([isMembers count] > 0) {
      alumniDetail.isMember = [[isMembers lastObject] stringValue];
    }
    if (alumniDetail.isMember == nil) {
      alumniDetail.isMember = NULL_PARAM_VALUE;;
    }
    
    NSArray *isApproves = [el elementsForName:@"is_approve"];
    if ([isApproves count] > 0) {
      alumniDetail.isApprove = [[isApproves lastObject] stringValue];
    }
    if (alumniDetail.isApprove == nil) {
      alumniDetail.isApprove = NULL_PARAM_VALUE;;
    }
    
    NSArray *companyCountryCs = [el elementsForName:@"companyCountryC"];
    if ([companyCountryCs count] > 0) {
      alumniDetail.companyCountryC = [[companyCountryCs lastObject] stringValue];
    }
    
    NSArray *companyCountryEs = [el elementsForName:@"companyCountryE"];
    if ([companyCountryEs count] > 0) {
      alumniDetail.companyCountryE = [[companyCountryEs lastObject] stringValue];
    }
    
    NSArray *companyProvinces = [el elementsForName:@"companyProvince"];
    if ([companyProvinces count] > 0) {
      alumniDetail.companyProvince = [[companyProvinces lastObject] stringValue];
    }
    
    NSArray *companyCities = [el elementsForName:@"companyCity"];
    if ([companyCities count] > 0) {
      alumniDetail.companyCity = [[companyCities lastObject] stringValue];
    }
    
    NSArray *jobTitles = [el elementsForName:@"jobTitle"];
    if ([jobTitles count] > 0) {
      alumniDetail.jobTitle = [[jobTitles lastObject] stringValue];
    }
    
    NSArray *companyNames = [el elementsForName:@"companyName"];
    if ([companyNames count] > 0) {
      alumniDetail.companyName = [[companyNames lastObject] stringValue];
    }
    
    NSArray *imageUrls = [el elementsForName:@"imageUrl"];
    if ([imageUrls count] > 0) {
      alumniDetail.imageUrl = [[imageUrls lastObject] stringValue];
    }
    
    NSArray *classNames = [el elementsForName:@"class"];
    if ([classNames count] > 0) {
      alumniDetail.classGroupName = [[classNames lastObject] stringValue];
    }
    
    NSArray *companyAddressCs = [el elementsForName:@"companyAddressC"];
    if ([companyAddressCs count] > 0) {
      alumniDetail.companyAddressC = [[companyAddressCs lastObject] stringValue];
    }
    
    NSArray *companyAddressEs = [el elementsForName:@"companyAddressE"];
    if ([companyAddressEs count] > 0) {
      alumniDetail.companyAddressE = [[companyAddressEs lastObject] stringValue];
    }
    
    NSArray *companyPhones = [el elementsForName:@"companyPhone"];
    if ([companyPhones count] > 0) {
      alumniDetail.companyPhone = [[companyPhones lastObject] stringValue];
    }
    if (nil == alumniDetail.companyPhone) {
      alumniDetail.companyPhone = NULL_PARAM_VALUE;
    }
    
    NSArray *companyFaxs = [el elementsForName:@"companyFax"];
    if ([companyFaxs count] > 0) {
      alumniDetail.companyFax = [[companyFaxs lastObject] stringValue];
    }
    
    NSArray *emails = [el elementsForName:@"email"];
    if ([emails count] > 0) {
      alumniDetail.email = [[emails lastObject] stringValue];
    }
    if (nil == alumniDetail.email) {
      alumniDetail.email = NULL_PARAM_VALUE;
    }
    
    NSArray *phones = [el elementsForName:@"mobile"];
    if ([phones count] > 0) {
      alumniDetail.phoneNumber = [[phones lastObject] stringValue];
    }
    if (nil == alumniDetail.phoneNumber) {
      alumniDetail.phoneNumber = NULL_PARAM_VALUE;
    }
    
    NSArray *weixins = [el elementsForName:@"weixin_account"];
    if ([weixins count] > 0) {
      alumniDetail.weixin = [[weixins lastObject] stringValue];
    }
    if (nil == alumniDetail.weixin) {
      alumniDetail.weixin = NULL_PARAM_VALUE;
    }
    
    NSArray *sinas = [el elementsForName:@"sina_account"];
    if ([sinas count] > 0) {
      alumniDetail.sina = [[sinas lastObject] stringValue];
    }
    if (nil == alumniDetail.sina) {
      alumniDetail.sina = NULL_PARAM_VALUE;
    }
    
    NSArray *linkedins = [el elementsForName:@"linkedin"];
    if ([linkedins count] > 0) {
      alumniDetail.linkedin = [[linkedins lastObject] stringValue];
    }
    if (nil == alumniDetail.linkedin) {
      alumniDetail.linkedin = NULL_PARAM_VALUE;
    }
    
    NSArray *profiles = [el elementsForName:@"user_desc"];
    if ([profiles count] > 0) {
      alumniDetail.profile = [[profiles lastObject] stringValue];
    }
    if (nil == alumniDetail.profile) {
      alumniDetail.profile = NULL_PARAM_VALUE;
    }
    
    BOOL isCheck;
    NSArray *isChecks = [el elementsForName:@"is_check"];
    if ([isChecks count] > 0) {
      isCheck = ([[[isChecks lastObject] stringValue] intValue] == 1) ? YES : NO;
      alumniDetail.isCheckIn = @(isCheck);
    }
    
    alumniDetail.containerType = @(EVENT_ALUMNI_LIST_TY);
  }
  
  return SAVE_MOC(MOC);
}

#pragma mark - handle welfare filter data
+ (ReturnCode)handleWelfareFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return ERR_CODE;
  }
  if (![AppManager instance].welfareTypeList) {
    [[AppManager instance].welfareTypeList removeAllObjects];
    [AppManager instance].welfareTypeList = nil;
  }
  
  [AppManager instance].welfareTypeList = [NSMutableArray array];
  
  int index = 0;
  
  NSArray *itemTypes = [doc nodesForXPath:@"//itemTypeList/itemType" error:nil];
  
  for (CXMLElement *el in itemTypes) {
    NSString *typeName = nil;
    NSString *typeId = nil;
    NSString *order = nil;
    
    NSArray *typeNames = [el elementsForName:@"itemTypeName"];
    if ([typeNames count] > 0) {
      typeName = [[[typeNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == typeName) {
      typeName = NULL_PARAM_VALUE;
    }
    
    NSArray *typeIds = [el elementsForName:@"itemTypeId"];
    if ([typeIds count] > 0) {
      typeId = [[typeIds lastObject] stringValue];
      if (typeId.length == 0) {
        typeId = NULL_PARAM_VALUE;
      }
    }
    
    NSArray *orderNames = [el elementsForName:@"displayIndex"];
    if ([orderNames count] > 0) {
      order = [[orderNames lastObject] stringValue];
    }
    if (nil == order) {
      order = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:typeId, typeName, order, @(UNSELECTED_TY), nil];
    [[AppManager instance].welfareTypeList insertObject:array atIndex:index++];
  }
  
  return RESP_OK;
}

#pragma mark - handle event filter data
+ (ReturnCode)handleGroupFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return ERR_CODE;
  }
  if (![AppManager instance].groupSortList) {
    [[AppManager instance].groupSortList removeAllObjects];
    [AppManager instance].groupSortList = nil;
  }
  
  [AppManager instance].groupSortList = [NSMutableArray array];
  
  [self handleClubData:doc];
  
  int index = 0;
  
  NSArray *orders = [doc nodesForXPath:@"//sort_types/sort_type" error:nil];
  
  for (CXMLElement *el in orders) {
    NSString *typeName = nil;
    NSString *typeId = nil;
    NSString *order = nil;
    
    NSArray *typeNames = [el elementsForName:@"type_name"];
    if ([typeNames count] > 0) {
      typeName = [[[typeNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == typeName) {
      typeName = NULL_PARAM_VALUE;
    }
    
    NSArray *typeIds = [el elementsForName:@"type_id"];
    if ([typeIds count] > 0) {
      typeId = [[typeIds lastObject] stringValue];
      if (typeId.length == 0) {
        typeId = NULL_PARAM_VALUE;
      }
    }
    
    NSArray *orderNames = [el elementsForName:@"orders"];
    if ([orderNames count] > 0) {
      order = [[orderNames lastObject] stringValue];
    }
    if (nil == order) {
      order = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:typeId, typeName, order, @(UNSELECTED_TY), nil];
    [[AppManager instance].groupSortList insertObject:array atIndex:index++];
  }
  
  [AppManager instance].loadedGroupFilterOK = YES;
  
  return RESP_OK;
}

+ (ReturnCode)handleEventFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return ERR_CODE;
  }
  
  if (![AppManager instance].eventTypeList) {
    [[AppManager instance].eventTypeList removeAllObjects];
    [AppManager instance].eventTypeList = nil;
  }
  if (![AppManager instance].eventCityList) {
    [[AppManager instance].eventCityList removeAllObjects];
    [AppManager instance].eventCityList = nil;
  }
  if (![AppManager instance].eventSortList) {
    [[AppManager instance].eventSortList removeAllObjects];
    [AppManager instance].eventSortList = nil;
  }
  
  [AppManager instance].eventTypeList = [NSMutableArray array];
  [AppManager instance].eventCityList = [NSMutableArray array];
  [AppManager instance].eventSortList = [NSMutableArray array];
  
  // Type
  int index = 0;
  NSArray *types = [doc nodesForXPath:@"//category_types/category_type" error:nil];
  
  for (CXMLElement *el in types) {
    NSString *typeName = nil;
    NSString *typeId = nil;
    NSString *order = nil;
    
    NSArray *typeNames = [el elementsForName:@"type_name"];
    if ([typeNames count] > 0) {
      typeName = [[[typeNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == typeName) {
      typeName = NULL_PARAM_VALUE;
    }
    
    NSArray *typeIds = [el elementsForName:@"type_id"];
    if ([typeIds count] > 0) {
      typeId = [[typeIds lastObject] stringValue];
      if (typeId.length == 0) {
        typeId = NULL_PARAM_VALUE;
      }
    }
    
    NSArray *orderNames = [el elementsForName:@"orders"];
    if ([orderNames count] > 0) {
      order = [[orderNames lastObject] stringValue];
    }
    if (nil == order) {
      order = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:typeId, typeName, order, @(UNSELECTED_TY), nil];
    [[AppManager instance].eventTypeList insertObject:array atIndex:index++];
  }
  
  // time
  index = 0;
  NSArray *citys = [doc nodesForXPath:@"//city_types/city_type" error:nil];
  
  for (CXMLElement *el in citys) {
    NSString *typeName = nil;
    NSString *typeId = nil;
    NSString *order = nil;
    
    NSArray *typeNames = [el elementsForName:@"type_name"];
    if ([typeNames count] > 0) {
      typeName = [[[typeNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == typeName) {
      typeName = NULL_PARAM_VALUE;
    }
    
    NSArray *typeIds = [el elementsForName:@"type_id"];
    if ([typeIds count] > 0) {
      typeId = [[typeIds lastObject] stringValue];
      if (typeId.length == 0) {
        typeId = NULL_PARAM_VALUE;
      }
    }
    
    NSArray *orderNames = [el elementsForName:@"orders"];
    if ([orderNames count] > 0) {
      order = [[orderNames lastObject] stringValue];
    }
    if (nil == order) {
      order = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:typeId, typeName, order, @(UNSELECTED_TY), nil];
    [[AppManager instance].eventCityList insertObject:array atIndex:index++];
  }
  
  // order
  index = 0;
  NSArray *orders = [doc nodesForXPath:@"//sort_types/sort_type" error:nil];
  
  for (CXMLElement *el in orders) {
    NSString *typeName = nil;
    NSString *typeId = nil;
    NSString *order = nil;
    
    NSArray *typeNames = [el elementsForName:@"type_name"];
    if ([typeNames count] > 0) {
      typeName = [[[typeNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == typeName) {
      typeName = NULL_PARAM_VALUE;
    }
    
    NSArray *typeIds = [el elementsForName:@"type_id"];
    if ([typeIds count] > 0) {
      typeId = [[typeIds lastObject] stringValue];
      if (typeId.length == 0) {
        typeId = NULL_PARAM_VALUE;
      }
    }
    
    NSArray *orderNames = [el elementsForName:@"orders"];
    if ([orderNames count] > 0) {
      order = [[orderNames lastObject] stringValue];
    }
    if (nil == order) {
      order = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:typeId, typeName, order, @(UNSELECTED_TY), nil];
    [[AppManager instance].eventSortList insertObject:array atIndex:index++];
  }
  
  [AppManager instance].loadedEventFilterOK = YES;
  
  return RESP_OK;
}

+ (BOOL)handleCouponDownloadedUserList:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == RESP_OK) {
   
    NSArray *userList = [respDoc nodesForXPath:@"//response/content/userList/user" error:nil];
    for (CXMLElement *el in userList) {
      NSArray *userIds = [el elementsForName:@"userId"];
      NSString *userId = nil;
      if (userIds.count > 0) {
        userId = [userIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@)", userId];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Alumni"
                              predicate:predicate]) {
        continue;
      }
      
      Alumni *alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni"
                                                               inManagedObjectContext:MOC];
      alumni.userId = userId;
      alumni.personId = userId;
      
      NSArray *usernames = [el elementsForName:@"userName"];
      if (usernames.count > 0) {
        alumni.name = [WXWCommonUtils decodeAndReplacePlusForText:[usernames.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [el elementsForName:@"imageURL"];
      if (imageUrls.count > 0) {
        alumni.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *companies = [el elementsForName:@"company"];
      if (companies.count > 0) {
        alumni.companyName = [WXWCommonUtils decodeAndReplacePlusForText:[companies.lastObject stringValue]];
      }
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - fetch class
+ (BOOL)handleFetchClasses:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *classList = [respDoc nodesForXPath:@"//content" error:nil];
  for (CXMLElement *el in classList) {
    
    ClassGroup *classGroup = (ClassGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"ClassGroup"
                                                                         inManagedObjectContext:MOC];
    NSArray *ids = [el elementsForName:@"id"];
    if ([ids count] > 0) {
      classGroup.classId = [[[ids lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *eCourses = [el elementsForName:@"ecourse"];
    if ([eCourses count] > 0) {
      classGroup.enCourse = [[[eCourses lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *cnCourses = [el elementsForName:@"ccourse"];
    if ([cnCourses count] > 0) {
      classGroup.cnCourse = [[[cnCourses lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *enNames = [el elementsForName:@"ename"];
    if ([enNames count] > 0) {
      classGroup.enName = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *cnNames = [el elementsForName:@"cname"];
    if ([cnNames count] > 0) {
      classGroup.cnName = [[[cnNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
  }
  
  if (SAVE_MOC(MOC)) {
    [AppManager instance].isLoadClassDataOK = YES;
    return YES;
  } else {
    [AppManager instance].isLoadClassDataOK = NO;
    return NO;
  }
  
  return YES;
}

#pragma mark - fetch industry
+ (BOOL)handleFetchIndustries:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *industries = [respDoc nodesForXPath:@"//content" error:nil];
  for (CXMLElement *el in industries) {
    Industry *industry = (Industry *)[NSEntityDescription insertNewObjectForEntityForName:@"Industry"
                                                                   inManagedObjectContext:MOC];
    NSArray *ids = [el elementsForName:@"id"];
    if ([ids count] > 0) {
      industry.industryId = [[[ids lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *enNames = [el elementsForName:@"ename"];
    if ([enNames count] > 0) {
      industry.enName = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *cnNames = [el elementsForName:@"cname"];
    if ([cnNames count] > 0) {
      industry.cnName = [[[cnNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
  }
  
  if (![WXWCoreDataUtils objectInMOC:MOC
                          entityName:@"Industry"
                           predicate:[NSPredicate predicateWithFormat:@"(industryId == %@)", INDUSTRY_ALL_ID]]) {
    Industry *allIndustry = (Industry *)[NSEntityDescription insertNewObjectForEntityForName:@"Industry"
                                                                      inManagedObjectContext:MOC];
    allIndustry.industryId = INDUSTRY_ALL_ID;
    allIndustry.cnName = INDUSTRY_ALL_CN_NAME;
    allIndustry.enName = INDUSTRY_ALL_EN_NAME;
  }
  
  
  if (SAVE_MOC(MOC)) {
    [AppManager instance].isLoadIndustryDataOK = YES;
    return YES;
  } else {
    [AppManager instance].isLoadIndustryDataOK = NO;
    return NO;
  }
  
  return YES;
}

#pragma mark - fetch country
+ (BOOL)handleFetchCountries:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *countries = [respDoc nodesForXPath:@"//content" error:nil];
  for (CXMLElement *el in countries) {
    UserCountry *country = (UserCountry *)[NSEntityDescription insertNewObjectForEntityForName:@"UserCountry"
                                                                        inManagedObjectContext:MOC];
    NSArray *ids = [el elementsForName:@"id"];
    if ([ids count] > 0) {
      country.countryId = [[ids lastObject] stringValue];
    }
    
    NSArray *enNames = [el elementsForName:@"ename"];
    if ([enNames count] > 0) {
      country.enName = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *cnNames = [el elementsForName:@"cname"];
    if ([cnNames count] > 0) {
      country.cnName = [[[cnNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *orders = [el elementsForName:@"displayNum"];
    if ([orders count] > 0) {
      country.order = @([[[[orders lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] intValue]);
    }
  }
  
  if ([CommonUtils saveMOCChange:MOC]) {
    [AppManager instance].isLoadCountryDataOK = YES;
    return YES;
  } else {
    [AppManager instance].isLoadCountryDataOK = NO;
    return NO;
  }
  
  return YES;
}

#pragma mark - fetch city
+ (BOOL)handleFetchCitys:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    NSArray *countries = [respDoc nodesForXPath:@"//city" error:nil];
    for (CXMLElement *el in countries) {
      EventCity *mCity = (EventCity *)[NSEntityDescription insertNewObjectForEntityForName:@"EventCity"
                                                                    inManagedObjectContext:MOC];
      NSArray *ids = [el elementsForName:@"id"];
      if ([ids count] > 0) {
        mCity.cityId = [[ids lastObject] stringValue];
      }
      
      NSArray *enNames = [el elementsForName:@"ename"];
      if ([enNames count] > 0) {
        mCity.enName = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *cnNames = [el elementsForName:@"cname"];
      if ([cnNames count] > 0) {
        mCity.cnName = [[[cnNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *orders = [el elementsForName:@"order"];
      if ([orders count] > 0) {
        mCity.order = @([[[orders lastObject] stringValue] intValue]);
      }
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      [AppManager instance].eventCityLoaded = YES;
      return YES;
    } else {
      [AppManager instance].eventCityLoaded = NO;
      return NO;
    }
    
  } else {
    return NO;
  }
}

#pragma mark - parser tag names
+ (NSString *)parserTagNamesFromTagIds:(NSString *)tagIds MOC:(NSManagedObjectContext *)MOC {
  if (nil == tagIds || 0 == tagIds.length) {
    return nil;
  }
  
  NSMutableString *tagIdListStr = [NSMutableString stringWithString:NULL_PARAM_VALUE];
  
  NSArray *ids = [tagIds componentsSeparatedByString:ITEM_TAG_ID_SEPARATOR];
  if (ids.count > 0) {
    
    NSInteger i = 0;
    for (NSString *itemId in ids) {
      
      i++;
      
      NSPredicate *tagIdPredicate = [NSPredicate predicateWithFormat:@"(tagId == %lld)", itemId.longLongValue];
      
      Tag *tag = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                  entityName:@"Tag"
                                                   predicate:tagIdPredicate];
      
      if (nil == tag.tagName || 0 == tag.tagName.length) {
        continue;
      }
      
      if (i < ids.count) {
        [tagIdListStr appendFormat:@"%@    ", tag.tagName];
      } else {
        [tagIdListStr appendString:tag.tagName];
      }
    }
  }
  
  return tagIdListStr;
}

#pragma mark - load Share Posts
+ (BOOL)handleSharePost:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC
{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    NSArray *posts = [respDoc nodesForXPath:@"//post" error:nil];
    for (CXMLElement *feedEl in posts) {
      
      long long postId = 0;
      NSArray *postIds = [feedEl elementsForName:@"id"];
      if ([postIds count] > 0) {
        postId = [[[postIds lastObject] stringValue] longLongValue];
      }
      
      NSInteger likeCount = 0;
      NSArray *likeCounts = [feedEl elementsForName:@"cool_count"];
      if ([likeCounts count] > 0) {
        likeCount = [[[likeCounts lastObject] stringValue] intValue];
      }
      
      NSInteger liked = 0;
      NSArray *itemLikes = [feedEl elementsForName:@"is_cool"];
      if ([itemLikes count] > 0) {
        liked = [[[itemLikes lastObject] stringValue] intValue];
      }
      
      NSInteger commentCount = 0;
      NSArray *commentCounts = [feedEl elementsForName:@"comment_count"];
      if ([commentCounts count] > 0) {
        commentCount = [[[commentCounts lastObject] stringValue] intValue];
      }
      
      NSInteger order = 0;
      NSArray *orders = [feedEl elementsForName:@"orders"];
      if ([orders count] > 0) {
        order = [[[orders lastObject] stringValue] intValue];
      }
      
      BOOL favorite = NO;
      NSArray *favorites = [feedEl elementsForName:@"is_fav"];
      if ([favorites count] > 0) {
        favorite = ([[[favorites lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      CGFloat distance = 0.0f;
      NSArray *distances = [feedEl elementsForName:@"distance"];
      if (distances.count > 0) {
        distance = [distances.lastObject stringValue].floatValue;
      }
      
      NSString *place = nil;
      NSArray *places = [feedEl elementsForName:@"place"];
      if (places.count > 0) {
        place = [CommonUtils decodeAndReplacePlusForText:[places.lastObject stringValue]];
      }
      
      BOOL hot = NO;
      NSArray *hots = [feedEl elementsForName:@"is_hot"];
      if ([hots count] > 0) {
        hot = ([[[hots lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      BOOL isHaveSurvey = NO;
      NSArray *haveSurvey = [feedEl elementsForName:@"is_hava_questionaire"];
      if ([haveSurvey count] > 0) {
        isHaveSurvey = ([[[haveSurvey lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      NSInteger userIsAnswered = -1;
      NSArray *userIsAnswereds = [feedEl elementsForName:@"user_is_answered"];
      if ([userIsAnswereds count] > 0) {
        userIsAnswered = [[[userIsAnswereds lastObject] stringValue] intValue];
      }
      
      NSString *surveyUrl = NULL_PARAM_VALUE;
      NSArray *surveyUrls = [feedEl elementsForName:@"questionaire_url"];
      if ([surveyUrls count] > 0) {
        surveyUrl = [[surveyUrls lastObject] stringValue];
      }
      
      NSString *surveyResultUrl = NULL_PARAM_VALUE;
      NSArray *surveyResultUrls = [feedEl elementsForName:@"lookup_questionaire_url"];
      if ([surveyResultUrls count] > 0) {
        surveyResultUrl = [[surveyResultUrls lastObject] stringValue];
      }
      
      NSDate *postDate = nil;
      NSArray *postDates = [feedEl elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0;
      if ([postDates count] > 0) {
        timestamp = [[[postDates lastObject] stringValue] doubleValue];
        postDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      }
      
      NSArray *lastCommentTime = [feedEl elementsForName:@"lastCommentTime"];
      NSTimeInterval lastCommentTimestamp = 0;
      if ([lastCommentTime count] > 0) {
        lastCommentTimestamp = [[[lastCommentTime lastObject] stringValue] doubleValue];
      }
      
      NSArray *profileImgUrls = [feedEl elementsForName:@"image_url"];
      NSString *authorPicUrl = nil;
      if ([profileImgUrls count]) {
        authorPicUrl = [[profileImgUrls lastObject] stringValue];
      }
      
      
      NSArray *tagIds = [feedEl elementsForName:@"tag_ids"];
      NSString *tagIdListStr = nil;
      NSString *tagNames = nil;
      if (tagIds.count > 0) {
        tagIdListStr = [tagIds.lastObject stringValue];
        tagNames = [self parserTagNamesFromTagIds:tagIdListStr MOC:MOC];
      }
      
      NSArray *deleteFlags = [feedEl elementsForName:@"is_delete_post"];
      BOOL couldBeDeleted = NO;
      if (deleteFlags.count > 0) {
        couldBeDeleted = ([deleteFlags.lastObject stringValue].intValue == 1) ? YES : NO;
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %lld)", postId];
      SharePost *checkPoint = nil;
      checkPoint = (SharePost *)[CommonUtils hasSameObjectAlready:MOC
                                                       entityName:@"SharePost"
                                                     sortDescKeys:nil
                                                        predicate:predicate];
      
      if (checkPoint) {
        checkPoint.order = @(order);
        checkPoint.commentCount = @(commentCount);
        checkPoint.likeCount = @(likeCount);
        checkPoint.liked = @(liked);
        checkPoint.elapsedTime = [CommonUtils getElapsedTime:postDate];
        checkPoint.hot = @(hot);
        checkPoint.lastCommentTimestamp = @(lastCommentTimestamp);
        checkPoint.authorPicUrl = authorPicUrl;
        checkPoint.favorited = @(favorite);
        checkPoint.tagIds = tagIdListStr;
        checkPoint.tagNames = tagNames;
        checkPoint.distance = @(distance);
        checkPoint.place = place;
        checkPoint.couldBeDeleted = @(couldBeDeleted);
        continue;
      }
      
      SharePost *post = nil;
      post = [NSEntityDescription insertNewObjectForEntityForName:@"SharePost"
                                           inManagedObjectContext:MOC];
      post.postId = @(postId);
      post.order = @(order);
      post.commentCount = @(commentCount);
      post.likeCount = @(likeCount);
      post.liked = @(liked);
      post.elapsedTime = [CommonUtils getElapsedTime:postDate];
      post.timestamp = @(timestamp);
      post.date = [CommonUtils simpleFormatDate:postDate secondAccuracy:YES];
      post.hot = @(hot);
      post.lastCommentTimestamp = @(lastCommentTimestamp);
      post.authorPicUrl = authorPicUrl;
      post.favorited = @(favorite);
      post.isHaveSurvey = @(isHaveSurvey);
      post.userIsAnswered = @(userIsAnswered);
      post.surveyUrl = surveyUrl;
      post.surveyResultUrl = surveyResultUrl;
      post.tagIds = tagIdListStr;
      post.tagNames = tagNames;
      post.distance = @(distance);
      post.place = place;
      post.couldBeDeleted = @(couldBeDeleted);
      
      NSArray *authorNames = [feedEl elementsForName:@"user_name"];
      if ([authorNames count]) {
        post.authorName = [CommonUtils replacePlusForText:[authorNames.lastObject stringValue]];
      }
      
      NSArray *authorIds = [feedEl elementsForName:@"user_id"];
      if ([authorIds count]) {
        post.authorId = [[authorIds lastObject] stringValue];
      }
      
      NSArray *authorTypes = [feedEl elementsForName:@"user_type"];
      if ([authorTypes count]) {
        post.authorType = [[authorTypes lastObject] stringValue];
      }
      
      NSArray *createdTimes = [feedEl elementsForName:@"create_time"];
      if ([createdTimes count]) {
        post.createdTime = [[createdTimes lastObject] stringValue];
      }
      
      NSArray *hasLocations = [feedEl elementsForName:@"has_location"];
      if ([hasLocations count]) {
        post.hasLocation = [[hasLocations lastObject] stringValue];
      }
      
      NSArray *isSmsInforms = [feedEl elementsForName:@"is_sms_inform"];
      if ([isSmsInforms count]) {
        post.isSmsInform = [[isSmsInforms lastObject] stringValue];
      }
      
      NSArray *imgUrls = [feedEl elementsForName:@"photo_url"];
      if ([imgUrls count]) {
        post.imageUrl = [[imgUrls lastObject] stringValue];
      }
      
      if (post.imageUrl && post.imageUrl.length>4) {
        post.thumbnailUrl = [[imgUrls lastObject] stringValue];
        post.imageAttached = @YES;
        NSArray *imageWidths = [feedEl elementsForName:@"photo_width"];
        if ([imageWidths count]) {
          post.originalImageWidth = [NSNumber numberWithInt:[[[imageWidths lastObject] stringValue] intValue]];
        }
        
        NSArray *imageHeights = [feedEl elementsForName:@"photo_height"];
        if ([imageHeights count]) {
          post.originalImageHeight = [NSNumber numberWithInt:[[[imageHeights lastObject] stringValue] intValue]];
        }
        
      } else {
        post.imageAttached = @NO;
      }
      
      NSArray *thumbnails = [feedEl elementsForName:@"photo_url"];
      if ([thumbnails count]) {
        post.imageUrl = [[thumbnails lastObject] stringValue];
      }
      
      NSArray *texts = [feedEl elementsForName:@"message"];
      if ([texts count]) {
        post.content = [CommonUtils decodeAndReplacePlusForText:[texts.lastObject stringValue]];
      }
      
      NSArray *latitudes = [feedEl elementsForName:@"latitude"];
      double latitude = 0;
      if ([latitudes count] > 0) {
        latitude = [[[latitudes lastObject] stringValue] doubleValue];
        post.latitude = @(latitude);
      } else {
        post.latitude = @0.0;
      }
      
      NSArray *longitudes = [feedEl elementsForName:@"longtitude"];
      double longitude = 0;
      if ([longitudes count] > 0) {
        longitude = [[[longitudes lastObject] stringValue] doubleValue];
        post.longitude = @(longitude);
      } else {
        post.longitude = @0.0;
      }
      
      if (latitude != 0 && longitude != 0) {
        post.locationAttached = @YES;
      } else {
        post.locationAttached = @NO;
      }
      
      NSArray *createAts = [feedEl elementsForName:@"plat_info"];
      if ([createAts count]) {
        post.createdAt = [[createAts lastObject] stringValue];
        NSArray *versions = [feedEl elementsForName:@"version"];
        if (versions.count > 0) {
          post.createdAt = [NSString stringWithFormat:@"%@ %@",
                            post.createdAt, [versions.lastObject stringValue]];
        }
      }
      
      NSArray *groupIds = [feedEl elementsForName:@"group_id"];
      if ([groupIds count]) {
        post.groupId = @([[[groupIds lastObject] stringValue] longLongValue]);
      }
      
      NSArray *groupNames = [feedEl elementsForName:@"group_name"];
      if ([groupNames count]) {
        post.groupName = [CommonUtils decodeAndReplacePlusForText:[groupNames.lastObject stringValue]];
      }
      
    }
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

#pragma mark - load event discuss post
+ (BOOL)handleEventDiscussPost:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC
{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    NSArray *posts = [respDoc nodesForXPath:@"//post" error:nil];
    for (CXMLElement *feedEl in posts) {
      
      long long postId = 0;
      NSArray *postIds = [feedEl elementsForName:@"id"];
      if ([postIds count] > 0) {
        postId = [[[postIds lastObject] stringValue] longLongValue];
      }
      
      NSInteger likeCount = 0;
      NSArray *likeCounts = [feedEl elementsForName:@"cool_count"];
      if ([likeCounts count] > 0) {
        likeCount = [[[likeCounts lastObject] stringValue] intValue];
      }
      
      NSInteger liked = 0;
      NSArray *itemLikes = [feedEl elementsForName:@"is_cool"];
      if ([itemLikes count] > 0) {
        liked = [[[itemLikes lastObject] stringValue] intValue];
      }
      
      NSInteger commentCount = 0;
      NSArray *commentCounts = [feedEl elementsForName:@"comment_count"];
      if ([commentCounts count] > 0) {
        commentCount = [[[commentCounts lastObject] stringValue] intValue];
      }
      
      NSInteger order = 0;
      NSArray *orders = [feedEl elementsForName:@"orders"];
      if ([orders count] > 0) {
        order = [[[orders lastObject] stringValue] intValue];
      }
      
      BOOL favorite = NO;
      NSArray *favorites = [feedEl elementsForName:@"is_fav"];
      if ([favorites count] > 0) {
        favorite = ([[[favorites lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      CGFloat distance = 0.0f;
      NSArray *distances = [feedEl elementsForName:@"distance"];
      if (distances.count > 0) {
        distance = [distances.lastObject stringValue].floatValue;
      }
      
      NSString *place = nil;
      NSArray *places = [feedEl elementsForName:@"place"];
      if (places.count > 0) {
        place = [CommonUtils decodeAndReplacePlusForText:[places.lastObject stringValue]];
      }
      
      BOOL hot = NO;
      NSArray *hots = [feedEl elementsForName:@"is_hot"];
      if ([hots count] > 0) {
        hot = ([[[hots lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      BOOL isHaveSurvey = NO;
      /*
       NSArray *haveSurvey = [feedEl elementsForName:@"is_hava_questionaire"];
       if ([haveSurvey count] > 0) {
       isHaveSurvey = ([[[haveSurvey lastObject] stringValue] intValue] == 1) ? YES : NO;
       }
       */
      
      NSInteger userIsAnswered = -1;
      NSArray *userIsAnswereds = [feedEl elementsForName:@"user_is_answered"];
      if ([userIsAnswereds count] > 0) {
        userIsAnswered = [[[userIsAnswereds lastObject] stringValue] intValue];
      }
      
      NSString *surveyUrl = NULL_PARAM_VALUE;
      NSArray *surveyUrls = [feedEl elementsForName:@"questionaire_url"];
      if ([surveyUrls count] > 0) {
        surveyUrl = [[surveyUrls lastObject] stringValue];
      }
      
      NSString *surveyResultUrl = NULL_PARAM_VALUE;
      NSArray *surveyResultUrls = [feedEl elementsForName:@"lookup_questionaire_url"];
      if ([surveyResultUrls count] > 0) {
        surveyResultUrl = [[surveyResultUrls lastObject] stringValue];
      }
      
      NSDate *postDate = nil;
      NSArray *postDates = [feedEl elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0;
      if ([postDates count] > 0) {
        timestamp = [[[postDates lastObject] stringValue] doubleValue];
        postDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      }
      
      NSArray *lastCommentTime = [feedEl elementsForName:@"lastCommentTime"];
      NSTimeInterval lastCommentTimestamp = 0;
      if ([lastCommentTime count] > 0) {
        lastCommentTimestamp = [[[lastCommentTime lastObject] stringValue] doubleValue];
      }
      
      NSArray *profileImgUrls = [feedEl elementsForName:@"image_url"];
      NSString *authorPicUrl = nil;
      if ([profileImgUrls count]) {
        authorPicUrl = [[profileImgUrls lastObject] stringValue];
      }
      
      NSArray *tagIds = [feedEl elementsForName:@"tag_ids"];
      NSString *tagIdListStr = nil;
      NSString *tagNames = nil;
      if (tagIds.count > 0) {
        tagIdListStr = [tagIds.lastObject stringValue];
        tagNames = [self parserTagNamesFromTagIds:tagIdListStr MOC:MOC];
      }
      
      NSArray *deleteFlags = [feedEl elementsForName:@"is_delete_post"];
      BOOL couldBeDeleted = NO;
      if (deleteFlags.count > 0) {
        couldBeDeleted = ([deleteFlags.lastObject stringValue].intValue == 1) ? YES : NO;
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %lld)", postId];
      Post *checkPoint = nil;
      checkPoint = (Post *)[CommonUtils hasSameObjectAlready:MOC
                                                  entityName:@"Post"
                                                sortDescKeys:nil
                                                   predicate:predicate];
      
      if (checkPoint) {
        checkPoint.order = @(order);
        checkPoint.commentCount = @(commentCount);
        checkPoint.likeCount = @(likeCount);
        checkPoint.liked = @(liked);
        checkPoint.elapsedTime = [CommonUtils getElapsedTime:postDate];
        checkPoint.hot = @(hot);
        checkPoint.lastCommentTimestamp = @(lastCommentTimestamp);
        checkPoint.authorPicUrl = authorPicUrl;
        checkPoint.favorited = @(favorite);
        checkPoint.tagIds = tagIdListStr;
        checkPoint.tagNames = tagNames;
        checkPoint.distance = @(distance);
        checkPoint.place = place;
        checkPoint.couldBeDeleted = @(couldBeDeleted);
        continue;
      }
      
      Post *post = nil;
      post = [NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                           inManagedObjectContext:MOC];
      post.postId = @(postId);
      post.order = @(order);
      post.commentCount = @(commentCount);
      post.likeCount = @(likeCount);
      post.liked = @(liked);
      post.elapsedTime = [CommonUtils getElapsedTime:postDate];
      post.timestamp = @(timestamp);
      post.date = [CommonUtils simpleFormatDate:postDate secondAccuracy:YES];
      post.hot = @(hot);
      post.lastCommentTimestamp = @(lastCommentTimestamp);
      post.authorPicUrl = authorPicUrl;
      post.favorited = @(favorite);
      post.isHaveSurvey = @(isHaveSurvey);
      post.userIsAnswered = @(userIsAnswered);
      post.surveyUrl = surveyUrl;
      post.surveyResultUrl = surveyResultUrl;
      post.tagIds = tagIdListStr;
      post.tagNames = tagNames;
      post.distance = @(distance);
      post.place = place;
      post.couldBeDeleted = @(couldBeDeleted);
      
      NSArray *authorNames = [feedEl elementsForName:@"user_name"];
      if ([authorNames count]) {
        post.authorName = [CommonUtils replacePlusForText:[authorNames.lastObject stringValue]];
      }
      
      NSArray *authorIds = [feedEl elementsForName:@"user_id"];
      if ([authorIds count]) {
        post.authorId = [[authorIds lastObject] stringValue];
      }
      
      NSArray *authorTypes = [feedEl elementsForName:@"user_type"];
      if ([authorTypes count]) {
        post.authorType = [[authorTypes lastObject] stringValue];
      }
      
      NSArray *createdTimes = [feedEl elementsForName:@"create_time"];
      if ([createdTimes count]) {
        post.createdTime = [[createdTimes lastObject] stringValue];
      }
      
      NSArray *hasLocations = [feedEl elementsForName:@"has_location"];
      if ([hasLocations count]) {
        post.hasLocation = [[hasLocations lastObject] stringValue];
      }
      
      NSArray *isSmsInforms = [feedEl elementsForName:@"is_sms_inform"];
      if ([isSmsInforms count]) {
        post.isSmsInform = [[isSmsInforms lastObject] stringValue];
      }
      
      NSArray *clubIds = [feedEl elementsForName:@"host_id"];
      if (clubIds.count > 0) {
        post.clubId = [clubIds.lastObject stringValue];
      }
      
      NSArray *imgUrls = [feedEl elementsForName:@"photo_url"];
      if ([imgUrls count]) {
        post.imageUrl = [[imgUrls lastObject] stringValue];
      }
      
      if (post.imageUrl && post.imageUrl.length>4) {
        post.thumbnailUrl = [[imgUrls lastObject] stringValue];
        post.imageAttached = @YES;
        NSArray *imageWidths = [feedEl elementsForName:@"photo_width"];
        if ([imageWidths count]) {
          post.originalImageWidth = [NSNumber numberWithInt:[[[imageWidths lastObject] stringValue] intValue]];
        }
        
        NSArray *imageHeights = [feedEl elementsForName:@"photo_height"];
        if ([imageHeights count]) {
          post.originalImageHeight = [NSNumber numberWithInt:[[[imageHeights lastObject] stringValue] intValue]];
        }
        
      } else {
        post.imageAttached = @NO;
      }
      
      NSArray *thumbnails = [feedEl elementsForName:@"photo_url"];
      if ([thumbnails count]) {
        post.imageUrl = [[thumbnails lastObject] stringValue];
      }
      
      NSArray *texts = [feedEl elementsForName:@"message"];
      if ([texts count]) {
        post.content = [CommonUtils decodeAndReplacePlusForText:[texts.lastObject stringValue]];
      }
      
      NSArray *latitudes = [feedEl elementsForName:@"latitude"];
      double latitude = 0;
      if ([latitudes count] > 0) {
        latitude = [[[latitudes lastObject] stringValue] doubleValue];
        post.latitude = @(latitude);
      } else {
        post.latitude = @0.0;
      }
      
      NSArray *longitudes = [feedEl elementsForName:@"longtitude"];
      double longitude = 0;
      if ([longitudes count] > 0) {
        longitude = [[[longitudes lastObject] stringValue] doubleValue];
        post.longitude = @(longitude);
      } else {
        post.longitude = @0.0;
      }
      
      if (latitude != 0 && longitude != 0) {
        post.locationAttached = @YES;
      } else {
        post.locationAttached = @NO;
      }
      
      NSArray *createAts = [feedEl elementsForName:@"plat_info"];
      if ([createAts count]) {
        post.createdAt = [[createAts lastObject] stringValue];
        NSArray *versions = [feedEl elementsForName:@"version"];
        if (versions.count > 0) {
          post.createdAt = [NSString stringWithFormat:@"%@ %@",
                            post.createdAt, [versions.lastObject stringValue]];
        }
      }
      
      NSArray *groupIds = [feedEl elementsForName:@"group_id"];
      if ([groupIds count]) {
        post.groupId = @([[[groupIds lastObject] stringValue] longLongValue]);
      }
      
      NSArray *groupNames = [feedEl elementsForName:@"group_name"];
      if ([groupNames count]) {
        post.groupName = [CommonUtils decodeAndReplacePlusForText:[groupNames.lastObject stringValue]];
      }
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - load posts
+ (BOOL)handleClubPost:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC
{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    int clubPostIndex = 0;
    if ([AppManager instance].isClubPostShow) {
      [AppManager instance].clubPostArray = [NSMutableArray array];
    }
    
    NSArray *posts = [respDoc nodesForXPath:@"//posts/post" error:nil];
    
    for (CXMLElement *feedEl in posts) {
      
      long long postId = 0;
      NSArray *postIds = [feedEl elementsForName:@"id"];
      if ([postIds count] > 0) {
        postId = [[[postIds lastObject] stringValue] longLongValue];
      }
      
      CGFloat distance = 0.0f;
      NSArray *distances = [feedEl elementsForName:@"distance"];
      if (distances.count > 0) {
        distance = [distances.lastObject stringValue].floatValue;
      }
      
      NSInteger likeCount = 0;
      NSArray *likeCounts = [feedEl elementsForName:@"cool_count"];
      if ([likeCounts count] > 0) {
        likeCount = [[[likeCounts lastObject] stringValue] intValue];
      }
      
      NSInteger liked = 0;
      NSArray *itemLikes = [feedEl elementsForName:@"is_cool"];
      if ([itemLikes count] > 0) {
        liked = [[[itemLikes lastObject] stringValue] intValue];
      }
      
      BOOL approved = NO;
      NSArray *approveStatus = [feedEl elementsForName:@"approved"];
      if (approveStatus.count > 0) {
        approved = [approveStatus.lastObject stringValue].intValue == 1 ? YES : NO;
      }
      
      NSInteger commentCount = 0;
      NSArray *commentCounts = [feedEl elementsForName:@"comment_count"];
      if ([commentCounts count] > 0) {
        commentCount = [[[commentCounts lastObject] stringValue] intValue];
      }
      
      NSInteger order = 0;
      NSArray *orders = [feedEl elementsForName:@"orders"];
      if ([orders count] > 0) {
        order = [[[orders lastObject] stringValue] intValue];
      }
      
      BOOL favorite = NO;
      NSArray *favorites = [feedEl elementsForName:@"is_fav"];
      if ([favorites count] > 0) {
        favorite = ([[[favorites lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      BOOL hot = NO;
      NSArray *hots = [feedEl elementsForName:@"is_hot"];
      if ([hots count] > 0) {
        hot = ([[[hots lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      BOOL isHaveSurvey = NO;
      NSArray *haveSurvey = [feedEl elementsForName:@"is_hava_questionaire"];
      if ([haveSurvey count] > 0) {
        isHaveSurvey = ([[[haveSurvey lastObject] stringValue] intValue] == 1) ? YES : NO;
      }
      
      NSInteger userIsAnswered = -1;
      NSArray *userIsAnswereds = [feedEl elementsForName:@"user_is_answered"];
      if ([userIsAnswereds count] > 0) {
        userIsAnswered = [[[userIsAnswereds lastObject] stringValue] intValue];
      }
      
      NSString *surveyUrl = NULL_PARAM_VALUE;
      NSArray *surveyUrls = [feedEl elementsForName:@"questionaire_url"];
      if ([surveyUrls count] > 0) {
        surveyUrl = [[surveyUrls lastObject] stringValue];
      }
      
      NSString *surveyResultUrl = NULL_PARAM_VALUE;
      NSArray *surveyResultUrls = [feedEl elementsForName:@"lookup_questionaire_url"];
      if ([surveyResultUrls count] > 0) {
        surveyResultUrl = [[surveyResultUrls lastObject] stringValue];
      }
      
      NSDate *postDate = nil;
      NSArray *postDates = [feedEl elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0;
      if ([postDates count] > 0) {
        timestamp = [[[postDates lastObject] stringValue] doubleValue];
        postDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      }
      
      NSArray *lastCommentTime = [feedEl elementsForName:@"lastCommentTime"];
      NSTimeInterval lastCommentTimestamp = 0;
      if ([lastCommentTime count] > 0) {
        lastCommentTimestamp = [[[lastCommentTime lastObject] stringValue] doubleValue];
      }
      
      NSArray *profileImgUrls = [feedEl elementsForName:@"image_url"];
      NSString *authorPicUrl = nil;
      if ([profileImgUrls count]) {
        authorPicUrl = [[profileImgUrls lastObject] stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %lld)", postId];
      Post *checkPoint = nil;
      checkPoint = (Post *)[CommonUtils hasSameObjectAlready:MOC
                                                  entityName:@"Post"
                                                sortDescKeys:nil
                                                   predicate:predicate];
      
      if (checkPoint) {
        checkPoint.order = @(order);
        checkPoint.commentCount = @(commentCount);
        checkPoint.likeCount = @(likeCount);
        checkPoint.liked = @(liked);
        checkPoint.elapsedTime = [CommonUtils getElapsedTime:postDate];
        checkPoint.hot = @(hot);
        checkPoint.lastCommentTimestamp = @(lastCommentTimestamp);
        checkPoint.authorPicUrl = authorPicUrl;
        checkPoint.favorited = @(favorite);
        checkPoint.distance = @(distance);
        checkPoint.approved = @(approved);
        continue;
      }
      
      Post *post = nil;
      post = [NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                           inManagedObjectContext:MOC];
      post.postId = @(postId);
      post.order = @(order);
      post.commentCount = @(commentCount);
      post.likeCount = @(likeCount);
      post.liked = @(liked);
      post.elapsedTime = [CommonUtils getElapsedTime:postDate];
      post.timestamp = @(timestamp);
      post.date = [CommonUtils simpleFormatDate:postDate secondAccuracy:YES];
      post.hot = @(hot);
      post.lastCommentTimestamp = @(lastCommentTimestamp);
      post.authorPicUrl = authorPicUrl;
      post.favorited = @(favorite);
      post.isHaveSurvey = @(isHaveSurvey);
      post.userIsAnswered = @(userIsAnswered);
      post.surveyUrl = surveyUrl;
      post.surveyResultUrl = surveyResultUrl;
      post.distance = @(distance);
      post.approved = @(approved);
      
      NSArray *authorNames = [feedEl elementsForName:@"user_name"];
      if ([authorNames count]) {
        post.authorName = [CommonUtils replacePlusForText:[authorNames.lastObject stringValue]];
      }
      
      NSArray *authorIds = [feedEl elementsForName:@"user_id"];
      if ([authorIds count]) {
        post.authorId = [[authorIds lastObject] stringValue];
      }
      
      NSArray *authorTypes = [feedEl elementsForName:@"user_type"];
      if ([authorTypes count]) {
        post.authorType = [[authorTypes lastObject] stringValue];
      }
      
      NSArray *createdTimes = [feedEl elementsForName:@"create_time"];
      if ([createdTimes count]) {
        post.createdTime = [[createdTimes lastObject] stringValue];
      }
      
      NSArray *hasLocations = [feedEl elementsForName:@"has_location"];
      if ([hasLocations count]) {
        post.hasLocation = [[hasLocations lastObject] stringValue];
      }
      
      NSArray *isSmsInforms = [feedEl elementsForName:@"is_sms_inform"];
      if ([isSmsInforms count]) {
        post.isSmsInform = [[isSmsInforms lastObject] stringValue];
      }
      
      NSArray *clubNames = [feedEl elementsForName:@"host_name"];
      if ([clubNames count]) {
        post.clubName = [[clubNames lastObject] stringValue];
      }
      
      NSArray *clubIds = [feedEl elementsForName:@"host_id"];
      if ([clubIds count]) {
        post.clubId = [[clubIds lastObject] stringValue];
      }
      
      NSArray *clubTypes = [feedEl elementsForName:@"host_type"];
      if ([clubTypes count]) {
        post.clubType = [[clubTypes lastObject] stringValue];
      }
      
      if ([AppManager instance].personId.longLongValue == post.authorId.longLongValue) {
        post.couldBeDeleted = @YES;
      } else {
        post.couldBeDeleted = @NO;
      }
      
      NSArray *imgUrls = [feedEl elementsForName:@"photo_url"];
      if ([imgUrls count]) {
        post.imageUrl = [[imgUrls lastObject] stringValue];
      }
      
      if (post.imageUrl && post.imageUrl.length>4) {
        post.thumbnailUrl = [[imgUrls lastObject] stringValue];
        post.imageAttached = @YES;
        NSArray *imageWidths = [feedEl elementsForName:@"photo_width"];
        if ([imageWidths count]) {
          post.originalImageWidth = [NSNumber numberWithInt:[[[imageWidths lastObject] stringValue] intValue]];
        }
        
        NSArray *imageHeights = [feedEl elementsForName:@"photo_height"];
        if ([imageHeights count]) {
          post.originalImageHeight = [NSNumber numberWithInt:[[[imageHeights lastObject] stringValue] intValue]];
        }
        
      } else {
        post.imageAttached = @NO;
      }
      
      NSArray *thumbnails = [feedEl elementsForName:@"bmiddle_pic"];
      if ([thumbnails count]) {
        post.imageUrl = [[thumbnails lastObject] stringValue];
      }
      
      NSArray *texts = [feedEl elementsForName:@"message"];
      if ([texts count]) {
        post.content = [CommonUtils decodeAndReplacePlusForText:[texts.lastObject stringValue]];
      }
      
      NSArray *latitudes = [feedEl elementsForName:@"latitude"];
      double latitude = 0;
      if ([latitudes count] > 0) {
        latitude = [[[latitudes lastObject] stringValue] doubleValue];
        post.latitude = @(latitude);
      } else {
        post.latitude = @0.0;
      }
      
      NSArray *longitudes = [feedEl elementsForName:@"longtitude"];
      double longitude = 0;
      if ([longitudes count] > 0) {
        longitude = [[[longitudes lastObject] stringValue] doubleValue];
        post.longitude = @(longitude);
      } else {
        post.longitude = @0.0;
      }
      
      if (latitude != 0 && longitude != 0) {
        post.locationAttached = @YES;
      } else {
        post.locationAttached = @NO;
      }
      
      NSArray *createAts = [feedEl elementsForName:@"plat_info"];
      if ([createAts count]) {
        post.createdAt = [[createAts lastObject] stringValue];
        NSArray *versions = [feedEl elementsForName:@"version"];
        if (versions.count > 0) {
          post.createdAt = [NSString stringWithFormat:@"%@ %@",
                            post.createdAt, [versions.lastObject stringValue]];
        }
      }
      
      NSArray *groupIds = [feedEl elementsForName:@"group_id"];
      if ([groupIds count]) {
        post.groupId = @([[[groupIds lastObject] stringValue] longLongValue]);
      }
      
      // parser tags
      NSArray *tags = [feedEl elementsForName:@"tags"];
      NSMutableString *tagIdsStr = [NSMutableString string];
      NSInteger i = 0;

      if (tags.count == 1) {
        CXMLElement *tagListEl = tags[0];
        NSArray *tagList = [tagListEl elementsForName:@"tag"];
        for (CXMLElement *tagEl in tagList) {
          NSArray *tagIds = [tagEl elementsForName:@"id"];
          if (tagIds.count > 0) {
            if (i == 0) {
              [tagIdsStr appendString:[tagIds.lastObject stringValue]];
            } else {
              [tagIdsStr appendString:STR_FORMAT(@",%@", [tagIds.lastObject stringValue])];
            }
          }
          i++;
        }
      }
      
      post.tagIds = tagIdsStr;
      post.tagNames = [self parserTagNamesFromTagIds:post.tagIds
                                                 MOC:MOC];

      NSArray *groupNames = [feedEl elementsForName:@"group_name"];
      if ([groupNames count]) {
        post.groupName = [CommonUtils decodeAndReplacePlusForText:[groupNames.lastObject stringValue]];
      }
      
      NSArray *supplyDemandTypes = [feedEl elementsForName:@"supply_demand"];
      if (supplyDemandTypes.count > 0) {
        post.postType = @([supplyDemandTypes.lastObject stringValue].intValue);
      }
      
      NSString *clubName = NULL_PARAM_VALUE;
      NSArray *hostNames = [feedEl elementsForName:@"host_name"];
      if ([hostNames count]) {
        clubName = [hostNames.lastObject stringValue];
      }
      
      if ([AppManager instance].isClubPostShow) {
        NSMutableArray *array = [[[NSMutableArray alloc] initWithObjects:post.authorPicUrl, clubName, post.authorName, post.content, [post.likeCount stringValue], [post.commentCount stringValue], nil] autorelease];
        [[AppManager instance].clubPostArray insertObject:array atIndex:clubPostIndex];
      }
      clubPostIndex++;
    }
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

#pragma mark - fetch Post Comments

+ (BOOL)parserPostComments:(NSData *)xmlData
                       MOC:(NSManagedObjectContext *)MOC
                    postId:(long long)postId
         connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                       url:(NSString *)url {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:COMMENT_LIST_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    NSArray *comments = [doc nodesForXPath:@"//comment" error:nil];
    for (CXMLElement *commentEl in comments) {
      long long commentId = 0;
      
      NSArray *commentIds = [commentEl elementsForName:@"id"];
      if ([commentIds count] > 0) {
        commentId = [[[commentIds lastObject] stringValue] longLongValue];
      }
      
      NSArray *deleteFlags = [commentEl elementsForName:@"is_delete_comment"];
      BOOL couldBeDeleted = NO;
      if (deleteFlags.count > 0) {
        couldBeDeleted = ([deleteFlags.lastObject stringValue].intValue == 1) ? YES : NO;
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(commentId == %lld)", commentId];
      PostComment *isExist = (PostComment *)[CommonUtils hasSameObjectAlready:MOC
                                                                   entityName:@"PostComment"
                                                                 sortDescKeys:nil
                                                                    predicate:predicate];
      if (isExist) {
        isExist.couldBeDeleted = @(couldBeDeleted);
        continue;
      }
      
      PostComment *comment = (PostComment*)[NSEntityDescription insertNewObjectForEntityForName:@"PostComment" inManagedObjectContext:MOC];
      
      comment.commentId = @(commentId);
      comment.couldBeDeleted = @(couldBeDeleted);
      comment.parentId = @(postId);
      
      NSArray *timestamps = [commentEl elementsForName:@"create_time"];
      if ([timestamps count] > 0) {
        NSTimeInterval timestamp = [[[timestamps lastObject] stringValue] doubleValue];
        comment.timestamp = @(timestamp);
        comment.date = [CommonUtils simpleFormatDate:[CommonUtils convertDateTimeFromUnixTS:timestamp]
                                      secondAccuracy:YES];
      }
      
      NSArray *authorIds = [commentEl elementsForName:@"user_id"];
      if ([authorIds count] > 0) {
        comment.authorId = [[authorIds lastObject] stringValue];
      }
      
      NSArray *authorNames = [commentEl elementsForName:@"user_name"];
      if ([authorNames count] > 0) {
        comment.authorName = [CommonUtils decodeAndReplacePlusForText:[authorNames.lastObject stringValue]];
      }
      
      NSArray *authorTypes = [commentEl elementsForName:@"user_type"];
      if ([authorTypes count] > 0) {
        comment.authorType = [CommonUtils decodeAndReplacePlusForText:[authorTypes.lastObject stringValue]];
      }
      
      NSArray *orders = [commentEl elementsForName:@"orders"];
      if ([orders count] > 0) {
        NSInteger order = [[[orders lastObject] stringValue] intValue];
        comment.showOrder = @(order);
      }
      
      NSArray *contents = [commentEl elementsForName:@"message"];
      if ([contents count] > 0) {
        comment.content = [CommonUtils decodeAndReplacePlusForText:[contents.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [commentEl elementsForName:@"photo_url"];
      if ([imageUrls count] > 0) {
        comment.imageUrl = [[imageUrls lastObject] stringValue];
      }
      
      if (comment.imageUrl && comment.imageUrl.length > 4) {
        comment.thumbnailUrl = [[imageUrls lastObject] stringValue];
        comment.imageAttached = @YES;
      } else {
        comment.imageAttached = @NO;
      }
      
      NSArray *thumbnailUrls = [commentEl elementsForName:@"original_pic"];
      if ([thumbnailUrls count] > 0) {
        comment.imageUrl = [[thumbnailUrls lastObject] stringValue];
      }
      
      NSArray *authorPicUrls = [commentEl elementsForName:@"image_url"];
      if ([authorPicUrls count] > 0) {
        comment.authorPicUrl = [[authorPicUrls lastObject] stringValue];
      }
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
    
  } else {
    return NO;
  }
}

#pragma mark - fetch Club Fliter
+ (BOOL)handleClubFliter:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    [self handleClubData:respDoc];
    return YES;
  }
  return NO;
}

#pragma mark - fetch Club
+ (Club *)parserGroupInfo:(CXMLElement *)el
                      MOC:(NSManagedObjectContext *)MOC
                    group:(Club *)group
                 existing:(BOOL)existing
      needParserCountInfo:(BOOL)needParserCountInfo {
  
  NSTimeInterval timestamp = 0;
  NSArray *times = [el elementsForName:@"last_post_time"];
  NSString *postTime = nil;
  if ([times count] > 0) {
    timestamp = [[[times lastObject] stringValue] doubleValue];
    if (timestamp > 0) {
      NSDate *mDate = nil;
      mDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      postTime = [CommonUtils getElapsedTime:mDate isOnlyShowDate:NO];
    }
  }
  
  NSArray *lastPostMessage = [el elementsForName:@"last_post_message"];
  NSString *postDesc = nil;
  if ([lastPostMessage count] > 0) {
    postDesc = [[lastPostMessage lastObject] stringValue];
  } else {
    postDesc = NULL_PARAM_VALUE;
  }
  
  NSArray *lastPostAuthor = [el elementsForName:@"last_post_author"];
  NSString *postAuthor = nil;
  if ([lastPostAuthor count] > 0) {
    postAuthor = [[lastPostAuthor lastObject] stringValue];
  } else {
    postAuthor = NULL_PARAM_VALUE;
  }
  
  NSArray *memberCounts = [el elementsForName:@"member_count"];
  int memberCount = 0;
  if ([memberCounts count] > 0) {
    memberCount = [[memberCounts.lastObject stringValue] intValue];
  }
  
  NSArray *logoFileCounts = [el elementsForName:@"logo_file"];
  NSString *logoFile = NULL_PARAM_VALUE;
  if ([logoFileCounts count] > 0) {
    logoFile = [logoFileCounts.lastObject stringValue];
  }
  
  int eventCount = 0;
  NSArray *eventCounts = [el elementsForName:@"event_count"];
  if ([eventCounts count] > 0) {
    eventCount = [[eventCounts.lastObject stringValue] intValue];
  }
  
  NSArray *postCounts = [el elementsForName:@"post_count"];
  NSString *postCount = NULL_PARAM_VALUE;
  if ([postCounts count] > 0) {
    postCount = [postCounts.lastObject stringValue];
  }
  
  NSArray *badgeNums = [el elementsForName:@"post_count_new"];
  NSString *badgeNum = NULL_PARAM_VALUE;
  if ([badgeNums count] > 0) {
    badgeNum = [badgeNums.lastObject stringValue];
  }
  
  /******** begin of prepare the decoded attributed string for performance issue *******
   *
   *  Because the table view scroll will be affected by the core text parser
   */
  
  if (needParserCountInfo) {
    NSString *baseInfo = [NSString stringWithFormat:@"<font face=\"%@\"><font size=\"11\"><font color=\"130-130-140\">%@: <font color=\"193-95-70\">%@  <font color=\"130-130-140\">%@: <font color=\"193-95-70\">%d  <font color=\"130-130-140\">%@: <font color=\"193-95-70\">%d",
                          SYS_FONT_NAME,
                          LocaleStringForKey(NSClubListPostTitle, nil),
                          postCount,
                          LocaleStringForKey(NSClubListEventTitle, nil),
                          eventCount,
                          LocaleStringForKey(NSClubListMemberTitle, nil),
                          memberCount];
    CoreTextMarkupParser *baseInfoParser = [[[CoreTextMarkupParser alloc] initWithLineBreakMode:kCTLineBreakByTruncatingTail] autorelease];
    NSAttributedString *attBaseInfo = [baseInfoParser attrStringFromMarkup:baseInfo];
    NSData *baseInfoData = [attBaseInfo convertToData];
    group.baseInfoData = baseInfoData;
  }
  
  NSData *postInfoData = nil;
  if (postAuthor.length > 0 && postDesc.length > 0) {
    NSString *postInfoContent = nil;
    NSAttributedString *attPostInfoContent = nil;
    postInfoContent = [NSString stringWithFormat:@"<font face=\"%@\"><font size=\"13\"><font color=\"98-87-87\">%@: <font color=\"130-130-140\">%@", SYS_FONT_NAME, postAuthor, postDesc];
    
    CoreTextMarkupParser *postInfoParser = [[[CoreTextMarkupParser alloc] initWithLineBreakMode:kCTLineBreakByTruncatingTail] autorelease];
    attPostInfoContent = [postInfoParser attrStringFromMarkup:postInfoContent];
    
    postInfoData = [attPostInfoContent convertToData];
  }
  
  group.postInfoContentData = postInfoData;
  
  /******** end of prepare the decoded attributed string for performance issue *******/
  
  group.postTime = postTime;
  group.postDesc = postDesc;
  group.postAuthor = postAuthor;
  group.member = @(memberCount);
  group.iconUrl = logoFile;
  group.postNum = postCount;
  group.activity = @(eventCount);
  group.badgeNum = badgeNum;
  
  if (existing) {
    return group;
  }
  
  NSArray *enNames = [el elementsForName:@"host_name"];
  if ([enNames count] > 0) {
    group.clubName = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  }
  
  NSArray *cnNames = [el elementsForName:@"type_id"];
  if ([cnNames count] > 0) {
    group.clubType = [[[cnNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  }
  
  NSArray *orders = [el elementsForName:@"orders"];
  if ([orders count] > 0) {
    NSInteger order = [[[orders lastObject] stringValue] intValue];
    group.showOrder = @(order);
  }
  
  NSArray *hostTypeValue = [el elementsForName:@"host_type_value"];
  if ([hostTypeValue count] > 0) {
    group.hostSupTypeValue = [[hostTypeValue lastObject] stringValue];
  }
  
  NSArray *hostSubTypeValue = [el elementsForName:@"host_sub_type_value"];
  if ([hostSubTypeValue count] > 0) {
    group.hostTypeValue = [[hostSubTypeValue lastObject] stringValue];
  }
  
  return group;
}

+ (BOOL)handleClub:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    if ([AppManager instance].needSaveMyClassNum) {
      NSArray *myClassNums = [respDoc nodesForXPath:@"//response/counts"
                                              error:nil];
      [AppManager instance].myClassNum = [[myClassNums lastObject] stringValue];
    }
    
    NSArray *groups = [respDoc nodesForXPath:@"//host" error:nil];
    for (CXMLElement *el in groups) {
      
      int groupId = 0;
      NSArray *ids = [el elementsForName:@"id"];
      if ([ids count] > 0) {
        groupId = [[[ids lastObject] stringValue] intValue];
      }
      
      BOOL existing = NO;
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d) AND (usageType == %d)", groupId, ORDINARY_USAGE_GP_TY];
      Club *group = (Club *)[CommonUtils hasSameObjectAlready:MOC
                                                   entityName:@"Club"
                                                 sortDescKeys:nil
                                                    predicate:predicate];
      if (group) {
        existing = YES;
      } else {
        group = (Club *)[NSEntityDescription insertNewObjectForEntityForName:@"Club"
                                                      inManagedObjectContext:MOC];
        group.clubId = @(groupId);
        group.usageType = @(ORDINARY_USAGE_GP_TY);
      }
      
      [self parserGroupInfo:el MOC:MOC group:group existing:existing needParserCountInfo:YES];
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

#pragma mark - load Club Simple Detail
+ (BOOL)handleClubSimpleDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC
{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *clubs = [respDoc nodesForXPath:@"//host" error:nil];
    for (CXMLElement *el in clubs) {
      
      // set events event
      NSString *eventDesc = NULL_PARAM_VALUE;
      NSArray *eventDescList = [respDoc nodesForXPath:@"//events/event" error:nil];
      
      for (int i = 0; i < [eventDescList count]; i++) {
        
        NSString *title = NULL_PARAM_VALUE;
        NSString *address = NULL_PARAM_VALUE;
        NSString *date = NULL_PARAM_VALUE;
        
        CXMLElement *el = (CXMLElement *)eventDescList[i];
        NSArray *titleArray = [el elementsForName:@"title"];
        if ([titleArray count]) {
          title = [[titleArray lastObject] stringValue];
        }
        
        NSArray *addressArray = [el elementsForName:@"address"];
        if ([addressArray count]) {
          address = [[addressArray lastObject] stringValue];
        }
        
        NSArray *dateArray = [el elementsForName:@"start_date"];
        if ([dateArray count]) {
          NSDate *mDate = [CommonUtils convertDateTimeFromUnixTS:[[[dateArray lastObject] stringValue] doubleValue]];
          date = [CommonUtils simpleFormatDate:mDate secondAccuracy:YES];
        }
        
        if ([NULL_PARAM_VALUE isEqualToString:eventDesc]) {
          eventDesc = [NSString stringWithFormat:@"%@|%@|%@",title,date,address];
        } else {
          eventDesc = [NSString stringWithFormat:@"%@$%@|%@|%@",eventDesc,title,date,address];
        }
      }
      
      int clubId = 0;
      NSArray *ids = [el elementsForName:@"id"];
      if ([ids count] > 0) {
        clubId = [[[ids lastObject] stringValue] intValue];
      }
      
      NSArray *allowSMS = [el elementsForName:@"allow_sms"];
      if (allowSMS.count > 0) {
        [AppManager instance].allowSendSMS = ([[allowSMS.lastObject stringValue] intValue] == 1 ? YES : NO);
      }
      
      NSArray *payTypes = [el elementsForName:@"paymentType"];
      NSInteger payType = 0;
      if (payTypes.count > 0) {
        payType = [payTypes.lastObject stringValue].intValue;
      }
      
      NSArray *memberCounts = [el elementsForName:@"member_count"];
      NSInteger memberCount = 0;
      if ([memberCounts count] > 0) {
        memberCount = [memberCounts.lastObject stringValue].intValue;
      }
      
      NSArray *eventCounts = [el elementsForName:@"event_count"];
      NSInteger eventCount = 0;
      if ([eventCounts count] > 0) {
        eventCount = [eventCounts.lastObject stringValue].intValue;
      }
      
      NSArray *memberStatus = [el elementsForName:@"member_status"];
      NSString *memberScope = nil;
      if (memberStatus.count > 0) {
        memberScope = [memberStatus.lastObject stringValue];
      }
      
      
      BOOL userPaid = NO;
      
      NSArray *payDates = [el elementsForName:@"lastPaidTime"];
      NSTimeInterval ts = 0;
      NSString *payDateStr = NULL_PARAM_VALUE;
      if (payDates.count > 0) {
        ts = [payDates.lastObject stringValue].doubleValue;
        if (ts > 0) {
          payDateStr = [CommonUtils simpleFormatDateWithYear:[CommonUtils convertDateTimeFromUnixTS:ts]
                                              secondAccuracy:NO];
          if (payDateStr.length > 0 && [@"1" isEqualToString:memberScope]) {
            userPaid = YES;
          }
        }
      }
      
      NSArray *orderIds = [el elementsForName:@"order_id"];
      NSString *orderId = nil;
      if (orderIds.count > 0) {
        orderId = [orderIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d)", clubId];
      ClubSimple *checkPoint = (ClubSimple *)[CommonUtils hasSameObjectAlready:MOC
                                                                    entityName:@"ClubSimple"
                                                                  sortDescKeys:nil
                                                                     predicate:predicate];
      if (checkPoint) {
        checkPoint.membercount = @(memberCount);
        
        checkPoint.eventcount = @(eventCount);
        
        checkPoint.ifmember = memberScope;
        
        checkPoint.userPaid = @(userPaid);
        
        checkPoint.userPayDate = payDateStr;
        
        checkPoint.payType = @(payType);
        
        checkPoint.orderId = orderId;
        
        continue;
      }
      
      ClubSimple *clubSimple = (ClubSimple *)[NSEntityDescription insertNewObjectForEntityForName:@"ClubSimple" inManagedObjectContext:MOC];
      
      clubSimple.clubId = @(clubId);
      
      NSArray *enNames = [el elementsForName:@"name"];
      if ([enNames count] > 0) {
        clubSimple.name = [[[enNames lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      clubSimple.membercount = @(memberCount);
      
      clubSimple.eventcount = @(eventCount);
      
      clubSimple.ifmember = memberScope;
      
      clubSimple.userPaid = @(userPaid);
      
      clubSimple.userPayDate = payDateStr;
      
      clubSimple.payType = @(payType);
      
      clubSimple.orderId = orderId;
      
      NSArray *isAdmins = [el elementsForName:@"is_admin"];
      if ([isAdmins count] > 0) {
        clubSimple.ifadmin = [[isAdmins lastObject] stringValue];
      }
      
      NSArray *notBeginEventCountArray = [el elementsForName:@"not_begin_event_count"];
      if ([notBeginEventCountArray count] > 0) {
        clubSimple.newEventNum = @([[[notBeginEventCountArray lastObject] stringValue] intValue]);
      } else {
        clubSimple.newEventNum = @0;
      }
      
      clubSimple.eventDesc = eventDesc;
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - fetch Event

+ (EventDateCategory)getEventDateCategoryByDatetime:(NSTimeInterval)timestamp {
  
  NSTimeInterval tomorrowMidnight = [CommonUtils convertToUnixTS:[NSDate midnightTomorrow]];
  
  NSTimeInterval todayMidnight = [CommonUtils convertToUnixTS:[NSDate midnightToday]];
  
  if (timestamp <= tomorrowMidnight && timestamp > todayMidnight) {
    return TODAY_CATEGORY_EVENT;
  } else {
    NSTimeInterval firstDayOfNextMonth = [CommonUtils convertToUnixTS:[NSDate firstDayOfNextMonth]];
    
    NSTimeInterval firstDayOfCurrentMonth = [CommonUtils convertToUnixTS:[NSDate firstDayOfCurrentMonth]];
    
    if (timestamp <= firstDayOfNextMonth && timestamp > firstDayOfCurrentMonth) {
      return THIS_MONTH_CATEGORY_EVENT;
    }
  }
  
  return OTHER_CATEGORY_EVENT;
}

+ (void)parserEvent:(NSArray *)eventList MOC:(NSManagedObjectContext *)MOC {
  for (CXMLElement *el in eventList) {
    
    NSArray *eventIds = [el elementsForName:@"id"];
    long long eventId = 0;
    if ([eventIds count] > 0) {
      eventId = [[[eventIds lastObject] stringValue] longLongValue];
    }
    
    NSArray *statusTypes = [el elementsForName:@"join_status_type"];
    NSInteger statusType = 0;
    if (statusTypes.count > 0) {
      statusType = [statusTypes.lastObject stringValue].intValue;
    }
    
    NSArray *statusTexts = [el elementsForName:@"join_status_text"];
    NSString *statusText = NULL_PARAM_VALUE;
    if (statusTexts.count > 0) {
      statusText = [statusTexts.lastObject stringValue];
    }
    
    NSArray *likeCounts = [el elementsForName:@"apply_count"];
    NSInteger signUpCount = 0;
    if ([likeCounts count] > 0) {
      signUpCount = [[[likeCounts lastObject] stringValue] intValue];
    }
    
    NSArray *checkinCounts = [el elementsForName:@"checkin_count"];
    NSInteger checkinCount = 0;
    if ([checkinCounts count] > 0) {
      checkinCount = [[[checkinCounts lastObject] stringValue] intValue];
    }
    
    NSArray *intervalDayCounts = [el elementsForName:@"interval_days"];
    NSInteger intervalDayCount = -1;
    if (intervalDayCounts.count > 0) {
      if (![NULL_PARAM_VALUE isEqualToString:[intervalDayCounts.lastObject stringValue]]) {
        intervalDayCount = [intervalDayCounts.lastObject stringValue].intValue;
      }
    }
    
    NSArray *orders = [el elementsForName:@"orders"];
    NSInteger order = 0;
    if ([orders count] > 0) {
      order = [[[orders lastObject] stringValue] intValue];
    }
    
    NSArray *screenTypes = [el elementsForName:@"screen_type"];
    NSInteger screenType = 0;
    if ([screenTypes count] > 0) {
      screenType = [[[screenTypes lastObject] stringValue] intValue];
    }
    
    NSString *hostName = NULL_PARAM_VALUE;
    NSArray *descs = [el elementsForName:@"host_name"];
    if ([descs count] > 0) {
      hostName = [[[descs lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *backerCounts = [el elementsForName:@"participation_count"];
    NSInteger backerCount = 0;
    if (backerCounts.count > 0) {
      backerCount = [backerCounts.lastObject stringValue].intValue
      ;    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(eventId == %lld)", eventId];
    Event *event = (Event *)[CommonUtils hasSameObjectAlready:MOC
                                                   entityName:@"Event"
                                                 sortDescKeys:nil
                                                    predicate:predicate];
    if (event) {
      event.checkinCount = @(checkinCount);
      event.signupCount = @(signUpCount);
      event.intervalDayCount = @(intervalDayCount);
      event.showOrder = @(order);
      event.screenType = @(screenType);
      event.hostName = hostName;
      event.backerCount = @(backerCount);
      event.actionType = @(statusType);
      event.actionStr = statusText;
      continue;
    } else {
      event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:MOC];
    }
    
    event.eventId = @(eventId);
    event.intervalDayCount = @(intervalDayCount);
    event.screenType = @(screenType);
    event.hostName = hostName;
    event.backerCount = @(backerCount);
    event.actionType = @(statusType);
    event.actionStr = statusText;
    
    if (eventId < 0ll) {
      event.fake = @(YES);
      event.intervalDayCount = @(FAKE_EVENT_INTERVAL_DAY);
    } else {
      event.fake = @(NO);
    }
    
    event.showOrder = @(order);
    
    NSArray *status = [el elementsForName:@"status"];
    if ([status count] > 0) {
      event.status = [[[status lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *titles = [el elementsForName:@"title"];
    if ([titles count] > 0) {
      event.title = [[[titles lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *citys = [el elementsForName:@"city_name"];
    if ([citys count] > 0) {
      event.city = [[[citys lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *urls = [el elementsForName:@"host_id"];
    if ([urls count] > 0) {
      event.hostId = [[urls lastObject] stringValue];
    }
    
    NSArray *imageUrls = [el elementsForName:@"image_url"];
    if (imageUrls.count > 0) {
      event.imageUrl = [imageUrls.lastObject stringValue];
    }
    
    NSArray *times = [el elementsForName:@"time"];
    if (times.count > 0) {
      event.timeStr = [times.lastObject stringValue];
    }
    
    NSArray *dates = [el elementsForName:@"timeInt"];
    if ([dates count] > 0) {
      NSString *datetimeStr = [[dates lastObject] stringValue];
      event.date = datetimeStr;
      
      event.dateCategory = [NSNumber numberWithInt:[self getEventDateCategoryByDatetime:datetimeStr.doubleValue]];
      
      NSDate *datetime = [CommonUtils convertDateTimeFromUnixTS:[datetimeStr doubleValue]];
      if ([WXWSystemInfoManager instance].currentLanguageCode == EN_TY) {
        event.monthWeekInfo = STR_FORMAT(@"%@ %@",
                                         [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime],
                                         [CommonUtils datetimeWithFormat:@"EEEE" datetime:datetime]);
      } else {
        event.monthWeekInfo = STR_FORMAT(@"%@月 %@",
                                         [CommonUtils datetimeWithFormat:@"MM" datetime:datetime],
                                         [CommonUtils datetimeWithFormat:@"EEEE" datetime:datetime]);
      }

      event.monthDayInfo = [CommonUtils datetimeWithFormat:@"dd" datetime:datetime];
    }
    
    event.signupCount = @(signUpCount);
    event.checkinCount = @(checkinCount);
    
  }
}

+ (BOOL)handleFetchEventList:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *eventList = [respDoc nodesForXPath:@"//event" error:nil];
    
    [self parserEvent:eventList MOC:MOC];
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleRecommendedEvent:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if (RESP_OK ==  [self parserResponseCode:respDoc]) {
    
    NSArray *entertainmentEventCounts = [respDoc nodesForXPath:@"//response/learning_tour_counts"
                                                         error:nil];
    if (entertainmentEventCounts.count > 0) {
      [AppManager instance].commingEntertainmentEventCount = [entertainmentEventCounts.lastObject stringValue].intValue;
    }
    
    NSArray *lectureEventCounts = [respDoc nodesForXPath:@"//response/academic_forum_counts"
                                                   error:nil];
    if (lectureEventCounts.count > 0) {
      [AppManager instance].commingLectureEventCount = [lectureEventCounts.lastObject stringValue].intValue;
    }
    
    NSArray *eventList = [respDoc nodesForXPath:@"//event" error:nil];
    
    [self parserEvent:eventList MOC:MOC];
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)parserEventSignedUpAlumnus:(CXMLDocument *)respDoc
                               MOC:(NSManagedObjectContext *)MOC
                           eventId:(long long)eventId {
  NSArray *signupList = [respDoc nodesForXPath:@"//apply_persons/person" error:nil];
  
  for (CXMLElement *el in signupList) {
    
    NSString *alumniId = nil;
    NSArray *ids = [el elementsForName:@"id"];
    if (ids.count > 0) {
      alumniId = [ids.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((personId == %@) && (eventId == %lld))", alumniId, eventId];
    
    if ([WXWCoreDataUtils objectInMOC:MOC
                           entityName:@"EventSignedUpAlumni"
                            predicate:predicate]) {
      continue;
    }
    
    EventSignedUpAlumni *signedUpAlumni = (EventSignedUpAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"EventSignedUpAlumni"
                                                                                               inManagedObjectContext:MOC];
    signedUpAlumni.personId = alumniId;
    
    NSArray *avatarUrls = [el elementsForName:@"thumbnail"];
    if (avatarUrls.count > 0) {
      signedUpAlumni.imageUrl = [avatarUrls.lastObject stringValue];
    }
    
    signedUpAlumni.eventId = @(eventId);
  }
  
  return SAVE_MOC(MOC);
}

+ (BOOL)parserEventCheckinAlumnus:(CXMLDocument *)respDoc
                              MOC:(NSManagedObjectContext *)MOC
                          eventId:(long long)eventId {
  
  NSArray *checkinList = [respDoc nodesForXPath:@"//checkin_persons/person" error:nil];
  for (CXMLElement *el in checkinList) {
    NSString *alumniId = nil;
    NSArray *ids = [el elementsForName:@"id"];
    if (ids.count > 0) {
      alumniId = [ids.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((personId == %@) && (eventId == %lld))", alumniId, eventId];
    
    if ([WXWCoreDataUtils objectInMOC:MOC
                           entityName:@"EventCheckinAlumni"
                            predicate:predicate]) {
      continue;
    }
    
    EventCheckinAlumni *alumni = (EventCheckinAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"EventCheckinAlumni"
                                                                                     inManagedObjectContext:MOC];
    alumni.personId = alumniId;
    
    NSArray *avatarUrls = [el elementsForName:@"thumbnail"];
    if (avatarUrls.count > 0) {
      alumni.imageUrl = [avatarUrls.lastObject stringValue];
    }
    
    alumni.eventId = @(eventId);
  }
  
  return SAVE_MOC(MOC);
}

+ (BOOL)parserEventWinners:(CXMLDocument *)respDoc
                       MOC:(NSManagedObjectContext *)MOC
                   eventId:(long long)eventId {
  
  NSArray *winnerList = [respDoc nodesForXPath:@"//winners/perso" error:nil];
  for (CXMLElement *el in winnerList) {
    
    NSString *alumniId = nil;
    NSArray *ids = [el elementsForName:@"id"];
    if (ids.count > 0) {
      alumniId = [ids.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((personId == %@) && (eventId == %lld))", alumniId, eventId];
    
    if ([WXWCoreDataUtils objectInMOC:MOC
                           entityName:@"EventWinner"
                            predicate:predicate]) {
      continue;
    }
    
    EventCheckinAlumni *alumni = (EventCheckinAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"EventWinner"
                                                                                     inManagedObjectContext:MOC];
    
    alumni.personId = alumniId;
    
    NSArray *avatarUrls = [el elementsForName:@"thumbnail"];
    if (avatarUrls.count > 0) {
      alumni.imageUrl = [avatarUrls.lastObject stringValue];
    }
    
    alumni.eventId = @(eventId);
  }
  
  return SAVE_MOC(MOC);
}

+ (BOOL)parserSponsors:(CXMLDocument *)respDoc
                   MOC:(NSManagedObjectContext *)MOC
               eventId:(long long)eventId {
  
  NSArray *sponsorList = [respDoc nodesForXPath:@"//sponsors/sponsor" error:nil];
  for (CXMLElement *el in sponsorList) {
    long long sponsorId = 0ll;
    NSArray *ids = [el elementsForName:@"id"];
    if (ids.count > 0) {
      sponsorId = [[ids.lastObject stringValue] longLongValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sponsor == %lld) && (eventId == %lld))", sponsorId, eventId];
    
    if ([WXWCoreDataUtils objectInMOC:MOC
                           entityName:@"EventSponsor"
                            predicate:predicate]) {
      continue;
    }
    
    EventSponsor *sponsor = (EventSponsor *)[NSEntityDescription insertNewObjectForEntityForName:@"EventSponsor"
                                                                          inManagedObjectContext:MOC];
    sponsor.sponsorId = @(sponsorId);
    sponsor.eventId = @(eventId);
    
    NSArray *avatarUrls = [el elementsForName:@"thumbnail"];
    if (avatarUrls.count > 0) {
      sponsor.avatarUrl = [avatarUrls.lastObject stringValue];
    }
    
    NSArray *nameArray = [el elementsForName:@"name"];
    if ([nameArray count]) {
      sponsor.name = [CommonUtils decodeAndReplacePlusForText:[[nameArray lastObject] stringValue]];
    }
    
    NSArray *urlArray = [el elementsForName:@"url"];
    if ([urlArray count]) {
      sponsor.url = [[urlArray lastObject] stringValue];
    }
    
    NSArray *prizeArray = [el elementsForName:@"prize"];
    if ([prizeArray count]) {
      sponsor.fee = [[prizeArray lastObject] stringValue];
    }
  }
  
  return SAVE_MOC(MOC);
}

+ (BOOL)handleParserEventApplyQuestions:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  return [self handleParserQuestions:respDoc MOC:MOC];
}

+ (BOOL)handleParserSurveyQuestions:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  return [self handleParserQuestions:respDoc MOC:MOC];
}

+ (BOOL)handleParserQuestions:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    int totalCount = 0;
    int dropDownIndex = 0;
    // mobile
    NSArray *mobiles = [respDoc nodesForXPath:@"//response/mobile"
                                        error:nil];
    NSString *userMobile = [[mobiles lastObject] stringValue];
    if (userMobile && ![NULL_PARAM_VALUE isEqualToString:userMobile] && userMobile.length>1) {
      [AppManager instance].userMobile = userMobile;
    } else {
      [AppManager instance].userMobile = NULL_PARAM_VALUE;
    }
    
    // email
    NSArray *emails = [respDoc nodesForXPath:@"//response/email"
                                       error:nil];
    NSString *email = [[emails lastObject] stringValue];
    if (email && ![NULL_PARAM_VALUE isEqualToString:email] && email.length>1) {
      [AppManager instance].email = email;
    } else {
      [AppManager instance].email = NULL_PARAM_VALUE;
    }
    
    // count
    NSArray *counts = [respDoc nodesForXPath:@"//response/question_counts"
                                       error:nil];
    NSString *countStr = [[counts lastObject] stringValue];
    if (countStr && ![NULL_PARAM_VALUE isEqualToString:countStr] && countStr.length>0) {
      totalCount = [countStr intValue];
    }
    
    if (totalCount > 0) {
      [AppManager instance].questionsList = [NSMutableArray array];
      [AppManager instance].questionsOptionsList = [NSMutableArray array];
      [AppManager instance].questionDictMutable = [NSMutableDictionary dictionaryWithCapacity:totalCount];
    } else {
      return YES;
    }
    
    // quest detail info
    NSArray *questList = [respDoc nodesForXPath:@"//questions/question" error:nil];
    for (int questIndex = 0; questIndex < [questList count]; questIndex++) {
      
      NSString *idStr = NULL_PARAM_VALUE;
      NSString *nameStr = NULL_PARAM_VALUE;
      NSString *typeStr = NULL_PARAM_VALUE;
      NSString *valueStr = NULL_PARAM_VALUE;
      NSString *isReQuiredStr = NULL_PARAM_VALUE;
      NSString *sortStr = NULL_PARAM_VALUE;
      
      CXMLElement *el = (CXMLElement *)questList[questIndex];
      NSArray *idArray = [el elementsForName:@"question_id"];
      if ([idArray count]) {
        idStr = [[idArray lastObject] stringValue];
      }
      
      NSArray *sortArray = [el elementsForName:@"sorts"];
      if ([sortArray count]) {
        sortStr = [[sortArray lastObject] stringValue];
      }
      
      NSArray *nameArray = [el elementsForName:@"question_name"];
      if ([nameArray count]) {
        nameStr = [NSString stringWithFormat:@"%@. %@", sortStr, [[nameArray lastObject] stringValue]];
      }
      if (nil == nameStr) {
        nameStr = NULL_PARAM_VALUE;
      }
      
      NSArray *typeArray = [el elementsForName:@"type"];
      if ([typeArray count]) {
        typeStr = [[typeArray lastObject] stringValue];
      }
      if (nil == typeStr) {
        typeStr = NULL_PARAM_VALUE;
      }
      
      NSArray *valueArray = [el elementsForName:@"question_value"];
      if ([valueArray count]) {
        valueStr = [[valueArray lastObject] stringValue];
      }
      if (nil == valueStr) {
        valueStr = NULL_PARAM_VALUE;
      }
      
      NSArray *isRequiredArray = [el elementsForName:@"is_required"];
      if ([isRequiredArray count]) {
        isReQuiredStr = [[isRequiredArray lastObject] stringValue];
      }
      if (nil == isReQuiredStr) {
        isReQuiredStr = NULL_PARAM_VALUE;
      }
      
      NSMutableArray *questionArray = [NSMutableArray arrayWithObjects:idStr, typeStr, nameStr, valueStr, isReQuiredStr, sortStr, nil];
      [[AppManager instance].questionsList insertObject:questionArray atIndex:questIndex];
      
      if ([typeStr intValue] == DEFINE_TYPE_DROPDOWN) {
        [[AppManager instance].questionDictMutable setObject:[NSString stringWithFormat:@"%d", dropDownIndex] forKey:[NSString stringWithFormat:@"%d", questIndex]];
        
        // quest option info
        NSString *contentStr = [el XMLString];
        CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:contentStr
                                                             options:0
                                                               error:nil] autorelease];
        NSArray *questOptionList = [doc nodesForXPath:@"//options/option" error:nil];
        NSMutableArray *optionTotalArray = [NSMutableArray array];
        for (int optionIndex = 0; optionIndex < [questOptionList count]; optionIndex++) {
          NSString *optionIdStr = NULL_PARAM_VALUE;
          NSString *optionNameStr = NULL_PARAM_VALUE;
          
          CXMLElement *el = (CXMLElement *)questOptionList[optionIndex];
          NSArray *optionIdArray = [el elementsForName:@"option_id"];
          if ([optionIdArray count]) {
            optionIdStr = [[optionIdArray lastObject] stringValue];
          }
          
          NSArray *optionNameArray = [el elementsForName:@"option_name"];
          if ([optionNameArray count]) {
            optionNameStr = [[optionNameArray lastObject] stringValue];
          }
          if (nil == optionNameStr) {
            optionNameStr = NULL_PARAM_VALUE;
          }
          
          NSMutableArray *optionArray = [NSMutableArray arrayWithObjects:optionIdStr, optionNameStr, nil];
          [optionTotalArray insertObject:optionArray atIndex:optionIndex];
        }
        
        [[AppManager instance].questionsOptionsList insertObject:optionTotalArray atIndex:dropDownIndex];
        dropDownIndex++;
      }
    }
    
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)handleParserEventDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    // sku info
    NSString *skuMsg = nil;
    NSArray *skuList = [respDoc nodesForXPath:@"//skus/sku" error:nil];
    
    for (CXMLElement *el in skuList) {
      
      NSString *skusIdStr = NULL_PARAM_VALUE;
      NSString *skuNameStr = NULL_PARAM_VALUE;
      NSString *skusPriceStr = NULL_PARAM_VALUE;
      NSString *allowMultipleStr = NULL_PARAM_VALUE;
      
      NSArray *skuIds = [el elementsForName:@"sku_id"];
      if ([skuIds count] > 0) {
        skusIdStr = [[skuIds lastObject] stringValue];
      }
      
      NSArray *skuNames = [el elementsForName:@"sku_name"];
      if ([skuNames count] > 0) {
        skuNameStr = [[skuNames lastObject] stringValue];
      }
      
      NSArray *salesPrices = [el elementsForName:@"sales_price"];
      if ([salesPrices count] > 0) {
        skusPriceStr = [[salesPrices lastObject] stringValue];
      }
      
      NSArray *allowMultiples = [el elementsForName:@"allow_multiple"];
      if ([allowMultiples count] > 0) {
        allowMultipleStr = [[allowMultiples lastObject] stringValue];
      }
      
      if (!skuMsg) {
        skuMsg = SKU_MSG(skusIdStr, skuNameStr, skusPriceStr, allowMultipleStr);
      } else {
        skuMsg = APPEND_SKU_MSG(skuMsg, skusIdStr, skuNameStr, skusPriceStr, allowMultipleStr);
      }
    }
    
    NSArray *isAdmins = [respDoc nodesForXPath:@"//response/is_admin"
                                         error:nil];
    NSString *isAdmin = [[isAdmins lastObject] stringValue];
    if (isAdmin && [isAdmin isEqualToString:@"1"]) {
      [AppManager instance].clubAdmin = YES;
    } else {
      [AppManager instance].clubAdmin = NO;
    }
    
    NSArray *actionTypes = [respDoc nodesForXPath:@"//response/button_type"
                                            error:nil];
    NSString *actionType = [[actionTypes lastObject] stringValue];
    
    NSArray *actionStrs = [respDoc nodesForXPath:@"//response/button_text"
                                           error:nil];
    NSString *actionStr = [WXWCommonUtils decodeAndReplacePlusForText:[[actionStrs lastObject] stringValue]];
    
    // set signup info
    NSString *signupMsg = nil;
    NSArray *signupList = [respDoc nodesForXPath:@"//apply_persons/person" error:nil];
    for (int i = 0; i < [signupList count]; i++) {
      NSString *ids;
      NSString *imgUrl = nil;
      CXMLElement *el = (CXMLElement *)signupList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        ids = [[idArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"thumbnail"];
      if ([urlArray count]) {
        imgUrl = [[urlArray lastObject] stringValue];
      }
      if (nil == imgUrl) {
        imgUrl = NULL_PARAM_VALUE;
      }
      
      if (!signupMsg) {
        signupMsg = [NSString stringWithFormat:@"%@|%@",ids,imgUrl];
      }else{
        signupMsg = [NSString stringWithFormat:@"%@$%@|%@",signupMsg,ids,imgUrl];
      }
    }
    
    // set checkin info
    NSString *checkinMsg = nil;
    NSArray *checkinList = [respDoc nodesForXPath:@"//checkin_persons/person" error:nil];
    for (int i = 0; i < [checkinList count]; i++) {
      NSString *ids;
      NSString *imgUrl = nil;
      CXMLElement *el = (CXMLElement *)checkinList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        ids = [[idArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"thumbnail"];
      if ([urlArray count]) {
        imgUrl = [[urlArray lastObject] stringValue];
      }
      if (nil == imgUrl) {
        imgUrl = NULL_PARAM_VALUE;
      }
      
      if (!checkinMsg) {
        checkinMsg = [NSString stringWithFormat:@"%@|%@",ids,imgUrl];
      }else{
        checkinMsg = [NSString stringWithFormat:@"%@$%@|%@",checkinMsg,ids,imgUrl];
      }
    }
    
    // set winner info
    NSString *winnerMsg = nil;
    NSArray *winnerList = [respDoc nodesForXPath:@"//winners/person" error:nil];
    for (int i = 0; i < [winnerList count]; i++) {
      NSString *ids;
      NSString *imgUrl = nil;
      CXMLElement *el = (CXMLElement *)winnerList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        ids = [[idArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"thumbnail"];
      if ([urlArray count]) {
        imgUrl = [[urlArray lastObject] stringValue];
      }
      if (nil == imgUrl) {
        imgUrl = NULL_PARAM_VALUE;
      }
      
      if (!winnerMsg) {
        winnerMsg = [NSString stringWithFormat:@"%@|%@",ids,imgUrl];
      }else{
        winnerMsg = [NSString stringWithFormat:@"%@$%@|%@",winnerMsg,ids,imgUrl];
      }
    }
    
    // set sponsor info
    NSString *sponsorMsg = nil;
    NSArray *sponsorList = [respDoc nodesForXPath:@"//sponsors/sponsor" error:nil];
    
    for (int i = 0; i < [sponsorList count]; i++) {
      NSString *ids = NULL_PARAM_VALUE;
      NSString *name = NULL_PARAM_VALUE;
      NSString *imgUrl = NULL_PARAM_VALUE;
      NSString *url = NULL_PARAM_VALUE;
      NSString *prize = NULL_PARAM_VALUE;
      
      CXMLElement *el = (CXMLElement *)sponsorList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        ids = [[idArray lastObject] stringValue];
      }
      
      NSArray *imgUrlArray = [el elementsForName:@"thumbnail"];
      if ([imgUrlArray count]) {
        imgUrl = [[imgUrlArray lastObject] stringValue];
        imgUrl = [imgUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      }
      
      NSArray *nameArray = [el elementsForName:@"name"];
      if ([nameArray count]) {
        name = [[nameArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"url"];
      if ([urlArray count]) {
        url = [[urlArray lastObject] stringValue];
      }
      
      NSArray *prizeArray = [el elementsForName:@"prize"];
      if ([prizeArray count]) {
        prize = [[prizeArray lastObject] stringValue];
      }
      
      if (!sponsorMsg) {
        sponsorMsg = [NSString stringWithFormat:@"%@|%@|%@|%@|%@",ids,name,imgUrl,url,prize];
      }else{
        sponsorMsg = [NSString stringWithFormat:@"%@$%@|%@|%@|%@|%@",sponsorMsg,ids,name,imgUrl,url,prize];
      }
    }
    
    // parser order id
    NSArray *orderIds = [respDoc nodesForXPath:@"//response/order_id" error:nil];
    NSString *orderId = nil;
    if (orderIds.count > 0) {
      orderId = [orderIds.lastObject stringValue];
    }
    
    // parser whether has award info
    NSArray *awards = [respDoc nodesForXPath:@"//response/award" error:nil];
    BOOL hasAward = YES;
    if (awards.count > 0) {
      if ([awards.lastObject stringValue].intValue == 0) {
        hasAward = NO;
      }
    }
    
    // event detail
    NSArray *eventList = [respDoc nodesForXPath:@"//event" error:nil];
    for (CXMLElement *el in eventList) {
      
      NSArray *eventIds = [el elementsForName:@"id"];
      long long eventId = 0;
      if ([eventIds count] > 0) {
        eventId = [[[eventIds lastObject] stringValue] longLongValue];
      }
      
      Event *event = (Event *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                        entityName:@"Event"
                                                         predicate:[NSPredicate predicateWithFormat:@"(eventId == %lld)", eventId]];
      if (nil == event) {
        event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                       inManagedObjectContext:MOC];
        event.eventId = @(eventId);
        
        if (eventId < 0ll) {
          event.fake = @(YES);
        } else {
          event.fake = @(NO);
        }
      }
      
      event.orderId = orderId;
      event.hasAward = @(hasAward);
      
      NSArray *titles = [el elementsForName:@"title"];
      if ([titles count] > 0) {
        event.title = [[[titles lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *types = [el elementsForName:@"screen_type"];
      if (types.count > 0) {
        event.screenType = @([types.lastObject stringValue].intValue);
      }
      
      NSArray *dates = [el elementsForName:@"date"];
      if ([dates count] > 0) {
        event.time = [[dates lastObject] stringValue];
      }
      if (nil == event.time) {
        event.time = NULL_PARAM_VALUE;
      }
      
      NSArray *times = [el elementsForName:@"time"];
      if ([times count] > 0) {
        event.timeStr = [[times lastObject] stringValue];
      }
      if (nil == event.timeStr) {
        event.timeStr = NULL_PARAM_VALUE;
      }
      
      NSArray *hostName = [el elementsForName:@"host_name"];
      if ([hostName count] > 0) {
        event.hostName = [[[hostName lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *hostId = [el elementsForName:@"host_id"];
      if ([hostId count] > 0) {
        event.hostId = [[hostId lastObject] stringValue];
      }
      
      NSArray *hostType = [el elementsForName:@"host_type"];
      if ([hostType count] > 0) {
        event.hostType = [[hostType lastObject] stringValue];
      }
      
      NSArray *imageUrls = [el elementsForName:@"image_url"];
      if (imageUrls.count > 0) {
        event.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *hostImg = [el elementsForName:@"host_thumbnail"];
      if ([hostImg count] > 0) {
        event.hostImg = [[hostImg lastObject] stringValue];
      }
      
      NSArray *singUps = [el elementsForName:@"apply_count"];
      if ([singUps count] > 0) {
        event.signupCount = @([[[singUps lastObject] stringValue] intValue]);
      }
      
      NSArray *checkins = [el elementsForName:@"checkin_count"];
      if ([checkins count] > 0) {
        event.checkinCount = @([[[checkins lastObject] stringValue] intValue]);
      }
      
      NSArray *commentins = [el elementsForName:@"comment_count"];
      if ([commentins count] > 0) {
        event.commentCount = @([[[commentins lastObject] stringValue] intValue]);
      }
      
      NSArray *winnerins = [el elementsForName:@"winner_count"];
      if ([winnerins count] > 0) {
        event.winnerCount = @([[[winnerins lastObject] stringValue] intValue]);
      }
      
      NSArray *backerCounts = [el elementsForName:@"participation_count"];
      if (backerCounts.count > 0) {
        event.backerCount = @([backerCounts.lastObject stringValue].intValue);
      }
      
      NSArray *backeds = [el elementsForName:@"is_participationtd"];
      if (backeds.count > 0) {
        NSInteger flag = [backeds.lastObject stringValue].intValue;
        event.backed = flag == 1 ? @(YES) : @(NO);
      }
      
      NSArray *editables = [el elementsForName:@"participation_is_write"];
      if (editables.count > 0) {
        NSInteger flag = [editables.lastObject stringValue].intValue;
        event.surveyEditable = flag == 1 ? @(YES) : @(NO);
      }
      
      NSArray *descs = [el elementsForName:@"desc"];
      if ([descs count] > 0) {
        event.desc = [[descs lastObject] stringValue];
      }
      
      NSArray *latitude = [el elementsForName:@"latitude"];
      if ([latitude count] > 0) {
        event.latitude = [[[latitude lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *longitude = [el elementsForName:@"longitude"];
      if ([longitude count] > 0) {
        event.longitude = [[[longitude lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *tel = [el elementsForName:@"contact_phone"];
      if ([tel count] > 0) {
        event.tel = [[[tel lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == event.tel) {
        event.tel = NULL_PARAM_VALUE;
      }
      
      NSArray *address = [el elementsForName:@"address"];
      if ([address count] > 0) {
        event.address = [[[address lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == event.address) {
        event.address = NULL_PARAM_VALUE;
      }
      
      NSArray *contact = [el elementsForName:@"contact"];
      if ([contact count] > 0) {
        event.contact = [[[contact lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == event.contact) {
        event.contact = NULL_PARAM_VALUE;
      }
      
      NSArray *payOrderIds = [el elementsForName:@"order_id"];
      if ([payOrderIds count] > 0) {
        event.payOrderId = [[payOrderIds lastObject] stringValue];
      }
      
      NSArray *chargeItemNames = [el elementsForName:@"chargeItemName"];
      if ([chargeItemNames count] > 0) {
        event.orderTitle = [[chargeItemNames lastObject] stringValue];
      }
      
      if (skuMsg == nil) {
        event.skuMsg = NULL_PARAM_VALUE;
      } else {
        event.skuMsg = skuMsg;
      }
      
      event.signupMsg = winnerMsg;
      event.checkinMsg = checkinMsg;
      event.sponsorMsg = sponsorMsg;
      event.winnerMsg = winnerMsg;
      event.actionType = @([actionType intValue]);
      event.actionStr = actionStr;
      
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

+ (BOOL)handleOptionSubmit:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if (RESP_OK == [self parserResponseCode:respDoc]) {
    return YES;
  } else {
    return NO;
  }
}

+ (BOOL)handleEventAwardResult:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if (RESP_OK == [self parserResponseCode:respDoc]) {
    
    NSArray *results = [respDoc nodesForXPath:@"//response/type" error:nil];
    if (results.count > 0) {
      [AppManager instance].shakeWinnerType = [results.lastObject stringValue].intValue;
    }
    
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - handle event vote
+ (BOOL)parserEventTopics:(NSData *)xmlData
                  eventId:(long long)eventId
                      MOC:(NSManagedObjectContext *)MOC
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_EVENT_TOPICS_TY]) {
		return NO;
	}
  
  if (RESP_OK == [self parserResponseCode:doc]) {
    
    NSArray *events = [doc nodesForXPath:@"//response/pools/pool" error:nil];
    for (CXMLElement *el in events) {
      
      NSArray *topicIds = [el elementsForName:@"id"];
      long long topicId = 0ll;
      if (topicIds.count > 0) {
        topicId = [[topicIds.lastObject stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((topicId == %lld) AND (eventId == %lld))", topicId, eventId];
      
      EventTopic *topic = (EventTopic *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                  entityName:@"EventTopic"
                                                                   predicate:predicate];
      
      if (nil == topic) {
        topic = (EventTopic *)[NSEntityDescription insertNewObjectForEntityForName:@"EventTopic"
                                                            inManagedObjectContext:MOC];
      }
      
      topic.topicId = @(topicId);
      
      topic.eventId = @(eventId);
      
      NSArray *orderIds = [el elementsForName:@"number"];
      if (orderIds.count > 0) {
        topic.sequenceNumber = @([[orderIds.lastObject stringValue] intValue]);
      }
      
      NSArray *status = [el elementsForName:@"status"];
      if (status.count > 0) {
        topic.status = @([[status.lastObject stringValue] intValue]);
      }
      
      NSArray *submits = [el elementsForName:@"submit_status"];
      if (submits.count) {
        topic.voted = [NSNumber numberWithBool:([[submits.lastObject stringValue] intValue] == 1 ? YES : NO)];
      }
      
      NSArray *contents = [el elementsForName:@"title"];
      if (contents.count > 0) {
        topic.content = [CommonUtils decodeAndReplacePlusForText:[contents.lastObject stringValue]];
      }
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

+ (BOOL)parserTopicOptions:(NSData *)xmlData
                     topic:(EventTopic *)topic
                       MOC:(NSManagedObjectContext *)MOC
         connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                       url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_EVENT_OPTIONS_TY]) {
		return NO;
	}
  
  if (RESP_OK == [self parserResponseCode:doc]) {
    
    NSArray *submits = [doc nodesForXPath:@"//response/pool/submit_status" error:nil];
    if (submits.count) {
      topic.voted = [NSNumber numberWithBool:([[submits.lastObject stringValue] intValue] == 1 ? YES : NO)];
    }
    
    NSArray *options = [doc nodesForXPath:@"//response/items/item" error:nil];
    for (CXMLElement *el in options) {
      
      NSArray *optionIds = [el elementsForName:@"id"];
      long long optionId = 0ll;
      if (optionIds.count > 0) {
        optionId = [[optionIds.lastObject stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((topicId == %@) AND (optionId == %lld))", topic.topicId, optionId];
      Option *option = (Option *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                           entityName:@"Option"
                                                            predicate:predicate];
      if (nil == option) {
        option = (Option *)[NSEntityDescription insertNewObjectForEntityForName:@"Option"
                                                         inManagedObjectContext:MOC];
      }
      
      option.topicId = topic.topicId;
      option.optionId = @(optionId);
      
      NSArray *contents = [el elementsForName:@"title"];
      if (contents.count > 0) {
        option.content = [CommonUtils decodeAndReplacePlusForText:[contents.lastObject stringValue]];
      }
      
      NSArray *orderIds = [el elementsForName:@"sorts"];
      if (orderIds.count > 0) {
        option.orderId = @([[orderIds.lastObject stringValue] intValue]);
      }
      
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - handle event check in

+ (void)handleAlumniInfo:(CXMLElement *)el alumni:(Alumni *)alumni {
  NSArray *avatarUrls = [el elementsForName:@"imageUrl"];
  if (avatarUrls.count > 0) {
    alumni.imageUrl = [avatarUrls.lastObject stringValue];
  }
  
  NSArray *names = [el elementsForName:@"name"];
  if (names.count > 0) {
    
    alumni.name = [CommonUtils decodeAndReplacePlusForText:[names.lastObject stringValue]];
  }
  
  NSArray *classes = [el elementsForName:@"class"];
  if (classes.count > 0) {
    alumni.classGroupName = [CommonUtils decodeAndReplacePlusForText:[classes.lastObject stringValue]];
  }
  
  NSArray *companyNames = [el elementsForName:@"companyName"];
  if (companyNames.count > 0) {
    alumni.companyName = [CommonUtils decodeAndReplacePlusForText:[companyNames.lastObject stringValue]];
  }
  
  NSArray *userTypes = [el elementsForName:@"user_type"];
  if ([userTypes count] > 0) {
    alumni.userType = [[userTypes lastObject] stringValue];
  } else {
    alumni.userType = @"1";
  }
  
  BOOL isCheck;
  NSArray *isChecks = [el elementsForName:@"is_check"];
  if ([isChecks count] > 0) {
    isCheck = ([[[isChecks lastObject] stringValue] intValue] == 1) ? YES : NO;
    alumni.isCheckIn = @(isCheck);
  }
  
  NSArray *times = [el elementsForName:@"times"];
  if ([times count] > 0) {
    NSTimeInterval timestamp = [[[times lastObject] stringValue] doubleValue];
    alumni.time = [CommonUtils getElapsedTime:[CommonUtils convertDateTimeFromUnixTS:timestamp]];
  }
}

+ (BOOL)handleEventCheckinAlumnus:(CXMLDocument *)respDoc
                              MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *eventIds = [respDoc nodesForXPath:@"//event_id" error:nil];
  long long eventId = [[eventIds.lastObject stringValue] longLongValue];
  
  NSArray *alumniElementList = [respDoc nodesForXPath:@"//content" error:nil];
  for (CXMLElement *el in alumniElementList) {
    NSString *alumniId = nil;
    NSArray *ids = [el elementsForName:@"personId"];
    if (ids.count > 0) {
      alumniId = [ids.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((personId == %@) && (eventId == %lld))",
                              alumniId, eventId];
    
    EventCheckinAlumni *alumni = (EventCheckinAlumni *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                                 entityName:@"EventCheckinAlumni"
                                                                                  predicate:predicate];
    if (nil == alumni) {
      alumni = (EventCheckinAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"EventCheckinAlumni"
                                                                   inManagedObjectContext:MOC];
    }
    
    alumni.personId = alumniId;
    
    alumni.eventId = @(eventId);
    
    [self handleAlumniInfo:el alumni:alumni];
  }
  return SAVE_MOC(MOC);
}

+ (BOOL)handleEventSignedUpAlumnus:(CXMLDocument *)respDoc
                               MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *eventIds = [respDoc nodesForXPath:@"//event_id" error:nil];
  long long eventId = [[eventIds.lastObject stringValue] longLongValue];
  
  NSArray *alumniElementList = [respDoc nodesForXPath:@"//content" error:nil];
  
  NSInteger i = 0;
  
  for (CXMLElement *el in alumniElementList) {
    NSString *alumniId = nil;
    NSArray *ids = [el elementsForName:@"personId"];
    if (ids.count > 0) {
      alumniId = [ids.lastObject stringValue];
    }
    
    NSLog(@"index: %d", i++);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((personId == %@) && (eventId == %lld))",
                              alumniId, eventId];
    
    EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                                   entityName:@"EventSignedUpAlumni"
                                                                                    predicate:predicate];
    if (nil == alumni) {
      alumni = (EventSignedUpAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"EventSignedUpAlumni"
                                                                    inManagedObjectContext:MOC];
    }
    
    alumni.personId = alumniId;
    
    alumni.eventId = @(eventId);
    
    [self handleAlumniInfo:el alumni:alumni];
  }
  return SAVE_MOC(MOC);
}

+ (BOOL)parserEventStuff:(NSData *)xmlData
                itemType:(WebItemType)itemType
                   event:(Event *)event
                     MOC:(NSManagedObjectContext *)MOC
       connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                     url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:itemType]) {
		return NO;
	}
  
  BOOL ret = YES;
  switch (itemType) {
    case CHECKIN_USER_TY:
      ret = [self handleEventCheckinAlumnus:doc MOC:MOC];
      break;
      
    case SIGNUP_USER_TY:
      ret = [self handleEventSignedUpAlumnus:doc MOC:MOC];
      break;
      
    case EVENT_POST_TY:
      ret = [self handleEventDiscussPost:doc MOC:MOC];
      break;
      
    default:
      break;
  }
  
  NSArray *checkinConfirmedResults = [doc nodesForXPath:@"//response/is_checkin"
                                                  error:nil];
  if (checkinConfirmedResults.count > 0) {
    if ([[checkinConfirmedResults.lastObject stringValue] intValue] == 1) {
      event.checkinResultType = @(CHECKIN_OK_TY);
      
      SAVE_MOC(MOC);
    }
  }
  
  return ret;
}

+ (BOOL)handleAdminCheckin:(CXMLDocument *)respDoc {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *tableInfos = [respDoc nodesForXPath:@"//response/table_info"
                                           error:nil];
    
    [AppManager instance].adminCheckinTableInfo = nil;
    if (tableInfos.count > 0) {
      [AppManager instance].adminCheckinTableInfo = [CommonUtils decodeAndReplacePlusForText:[tableInfos.lastObject stringValue]];
    }
    
    NSArray *respMobile = [respDoc nodesForXPath:@"//response/mobile" error:nil];
    NSArray *respEmail = [respDoc nodesForXPath:@"//response/email" error:nil];
    NSArray *respWeibo = [respDoc nodesForXPath:@"//response/sina_username" error:nil];
    if ([respMobile count]) {
      [AppManager instance].eventAlumniMobile = [[respMobile lastObject] stringValue];
    } else {
      [AppManager instance].eventAlumniMobile = NULL_PARAM_VALUE;
    }
    
    if ([respWeibo count]) {
      [AppManager instance].eventAlumniWeibo = [[respWeibo lastObject] stringValue];
    } else {
      [AppManager instance].eventAlumniWeibo = NULL_PARAM_VALUE;
    }
    
    if ([respEmail count]) {
      [AppManager instance].eventAlumniEmail = [[respEmail lastObject] stringValue];
    } else {
      [AppManager instance].eventAlumniEmail = NULL_PARAM_VALUE;
    }
    
    
    return YES;
  } else {
    return NO;
  }
}

+ (CheckinResultType)parserEventCheckinResult:(NSData *)xmlData
                                        event:(Event *)event
                                          MOC:(NSManagedObjectContext *)MOC
                            connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                          url:(NSString *)url {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:CHECKIN_TY]) {
		return CHECKIN_FAILED_TY;
	}
  
  CheckinResultType checkinRes = [self parserResponseCode:doc];
  
  NSArray *checkinCodes = [doc nodesForXPath:@"//response/checkin_code"
                                       error:nil];
  if (checkinCodes.count > 0) {
    event.checkinNumber = @([[checkinCodes.lastObject stringValue] longLongValue]);
  }
  
  NSArray *membershipScopes = [doc nodesForXPath:@"//response/member_level"
                                           error:nil];
  if (membershipScopes.count > 0) {
    event.membershipScope = [CommonUtils decodeAndReplacePlusForText:[membershipScopes.lastObject stringValue]];
  }
  
  NSArray *fees = [doc nodesForXPath:@"//response/fee_to_pay"
                               error:nil];
  if (fees.count > 0) {
    event.fee = @([[fees.lastObject stringValue] floatValue]);
  }
  
  NSArray *paidFees = [doc nodesForXPath:@"//response/fee_paid"
                                   error:nil];
  if (paidFees.count > 0) {
    event.actualPaid = @([[paidFees.lastObject stringValue] floatValue]);
  }
  
  NSArray *signedUps = [doc nodesForXPath:@"//response/has_applied"
                                    error:nil];
  if (signedUps.count > 0) {
    NSInteger flag = [[signedUps.lastObject stringValue] intValue];
    event.hasSignedUp = [NSNumber numberWithBool:(flag == 1 ? YES : NO)];
  }
  
  NSArray *tableInfos = [doc nodesForXPath:@"//response/table_info"
                                     error:nil];
  event.tableInfo = nil;
  if (tableInfos.count > 0) {
    event.tableInfo = [CommonUtils decodeAndReplacePlusForText:[tableInfos.lastObject stringValue]];
  }
  
  /*
   NSArray *needSignedUps = [doc nodesForXPath:@"//response/need_signup" error:nil];
   if (needSignedUps.count > 0) {
   NSInteger flag = [[needSignedUps.lastObject stringValue] intValue];
   event.needSignUp = [NSNumber numberWithBool:(flag == 1 ? YES : NO)];
   }
   */
  NSArray *checkedinCounts = [doc nodesForXPath:@"//response/checkin_count"
                                          error:nil];
  if (checkedinCounts.count > 0) {
    event.checkinCount = @([[checkedinCounts.lastObject stringValue] intValue]);
  }
  
  // classify the result
  CheckinResultType toBeReturnedRes = checkinRes;
  if (checkinRes == CHECKIN_NEED_CONFIRM_TY) {
    
    if (event.actualPaid.floatValue < event.fee.floatValue) {
      
      // not pay the fee yet
      toBeReturnedRes = CHECKIN_NO_REG_FEE_TY;
    } else {
      
      // user has signed up (has paid fee or no need to pay fee), then wait
      // admin to confirm check in
      toBeReturnedRes = CHECKIN_NEED_CONFIRM_TY;
    }
    
    /*
     if (!event.hasSignedUp.boolValue) {
     
     // not sign up yet
     toBeReturnedRes = CHECKIN_NOT_SIGNUP_TY;
     } else {
     if (event.actualPaid.floatValue < event.fee.floatValue) {
     
     // not pay the fee yet
     toBeReturnedRes = CHECKIN_NO_REG_FEE_TY;
     } else {
     
     // user has signed up (has paid fee or no need to pay fee), then wait
     // admin to confirm check in
     toBeReturnedRes = CHECKIN_NEED_CONFIRM_TY;
     }
     }
     */
  }
  
  /*
   // no need to registration
   if (!event.needSignUp.boolValue) {
   event.requirementType = [NSNumber numberWithInt:NO_NEED_REG_EVENT_TY];
   } else {
   if (event.fee.floatValue > 0) {
   // this event requires registration and fee
   event.requirementType = [NSNumber numberWithInt:NEED_REG_NONFREE_EVENT_TY];
   } else {
   // this event requires registration, no need fee
   event.requirementType = [NSNumber numberWithInt:NEED_REG_FREE_EVENT_TY];
   }
   }
   */
  if (event.fee.floatValue > 0) {
    event.requirementType = @(NEED_FEE_EVENT_TY);
  } else {
    event.requirementType = @(FREE_EVENT_TY);
  }
  
  event.checkinResultType = [NSNumber numberWithInt:toBeReturnedRes];
  
  SAVE_MOC(MOC);
  
  return toBeReturnedRes;
}

#pragma mark - fetch Post Tag
+ (BOOL)handlePostTag:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC{
  
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    NSArray *tagList = [respDoc nodesForXPath:@"//content/tags/tag" error:nil];
    for (int i = 0; i < [tagList count]; i++) {
      NSString *name = nil;
      int tagId = 0;
      int order = 0;
      int typeId = 0;
      int part = 0;
      long long groupId = 0ll;
      
      CXMLElement *el = (CXMLElement *)tagList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        tagId = [[[idArray lastObject] stringValue] intValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"name"];
      if ([urlArray count]) {
        
        name = [[urlArray lastObject] stringValue];
      }
      if (nil == name) {
        name = NULL_PARAM_VALUE;
      }
      
      NSArray *sorts = [el elementsForName:@"sort"];
      if ([sorts count]) {
        order = [[[sorts lastObject] stringValue] intValue];
      }
      
      NSArray *types = [el elementsForName:@"type_id"];
      if ([types count]) {
        typeId = [[[types lastObject] stringValue] intValue];
      }
      
      NSArray *parts = [el elementsForName:@"part"];
      if ([parts count]) {
        part = [[[parts lastObject] stringValue] intValue];
      }
      
      NSArray *groupIds = [el elementsForName:@"item_id"];
      if (groupIds.count > 0) {
        groupId = [groupIds.lastObject stringValue].longLongValue;
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagId == %d)", tagId];
      Tag *checkPoint = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Tag" predicate:predicate];
      if (checkPoint) {
        checkPoint.tagName = name;
        checkPoint.order = @(order);
        checkPoint.part = @(part);
        checkPoint.typeId = @(typeId);
        checkPoint.groupId = @(groupId);
        continue;
      }
      
      Tag *tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:MOC];
      tag.tagId = [NSNumber numberWithLongLong:tagId];
      tag.tagName = name;
      //tag.type = [NSNumber numberWithInt:SHARE_TY];
      tag.typeId = @(typeId);
      tag.order = @(order);
      tag.selected = @(NO);
      tag.part = @(part);
      tag.groupId = @(groupId);
    }
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
  
}

#pragma mark - fetch Shake Place & Thing
+ (BOOL)handleShakePlace2Thing:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    /*
     // default Place & thing
     NSString *defaultPlace = nil;
     NSString *defaultThing = nil;
     NSArray *places = [respDoc nodesForXPath:@"//place_default" error:nil];
     if ([places count] > 0) {
     defaultPlace = [[places lastObject] stringValue];
     }
     NSArray *things = [respDoc nodesForXPath:@"//thing_default" error:nil];
     if ([things count] > 0) {
     defaultThing = [[things lastObject] stringValue];
     }
     */
    
    // place
    NSArray *addressList = [respDoc nodesForXPath:@"//places/place" error:nil];
    for (int i = 0; i < [addressList count]; i++) {
      NSString *ids = nil;
      NSString *name = nil;
      //NSString *address = nil;
      float distance = 0.0f;
      
      CXMLElement *el = (CXMLElement *)addressList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        ids = [[idArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"name"];
      if ([urlArray count]) {
        name = [[urlArray lastObject] stringValue];
      }
      if (nil == name) {
        name = NULL_PARAM_VALUE;
      }
      /*
       NSArray *addresses = [el elementsForName:@"vicinity"];
       if ([addresses count]) {
       address = [[addresses lastObject] stringValue];
       }
       if (nil == address) {
       address = NULL_PARAM_VALUE;
       }
       */
      
      NSArray *distances = [el elementsForName:@"distance"];
      if (distances.count > 0) {
        distance = [[distances.lastObject stringValue] floatValue];
      }else {
        distance = 0l;
      }
      
      int tagId = i;
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( (mark == %@) AND (type == %d) )", ids, PLACE_TY];
      Tag *checkPoint = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Tag" predicate:predicate];
      if (checkPoint) {
        continue;
      }
      
      Tag *tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:MOC];
      tag.tagId = [NSNumber numberWithLongLong:tagId];
      tag.tagName = name;
      tag.mark = ids;
      tag.distance = @(distance);
      tag.type = @(PLACE_TY);
      tag.order = @(i);
      tag.selected = @NO;
    }
    
    // things
    NSArray *thingList = [respDoc nodesForXPath:@"//things/thing" error:nil];
    for (int i = 0; i < [thingList count]; i++) {
      NSString *name = nil;
      
      CXMLElement *el = (CXMLElement *)thingList[i];
      NSArray *urlArray = [el elementsForName:@"name"];
      if ([urlArray count]) {
        name = [[urlArray lastObject] stringValue];
      }
      if (nil == name) {
        name = NULL_PARAM_VALUE;
      }
      
      int tagId = i;
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( (tagId == %d) AND (type == %d) )", tagId, THING_TY];
      Tag *checkPoint = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC entityName:@"Tag" predicate:predicate];
      if (checkPoint) {
        checkPoint.tagName = name;
        checkPoint.order = @(i);
        continue;
      }
      
      Tag *tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:MOC];
      tag.tagId = [NSNumber numberWithLongLong:tagId];
      tag.tagName = name;
      tag.type = @(THING_TY);
      tag.order = @(i);
      tag.selected = @NO;
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

#pragma mark - brand related info
+ (BOOL)handleBrands:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *brands = [respDoc nodesForXPath:@"//channels/channel" error:nil];
    for (CXMLElement *el in brands) {
      
      NSArray *brandIds = [el elementsForName:@"id"];
      long long brandId = 0ll;
      if (brandIds.count > 0) {
        brandId = [[brandIds.lastObject stringValue] longLongValue];
      }
      
      NSArray *couponInfos = [el elementsForName:@"surprise_desc"];
      NSString *couponInfo = nil;
      if (couponInfos.count > 0) {
        couponInfo = [CommonUtils decodeAndReplacePlusForText:[couponInfos.lastObject stringValue]];
      }
      
      NSArray *distances = [el elementsForName:@"distance"];
      CGFloat distance = 0.0f;
      if (distances.count > 0) {
        distance = [[distances.lastObject stringValue] floatValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(brandId == %lld)", brandId];
      Brand *checkPoint = (Brand *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Brand"
                                                              predicate:predicate];
      if (checkPoint) {
        checkPoint.couponInfo = couponInfo;
        checkPoint.nearestDistance = @(distance);
        continue;
      }
      
      Brand *brand = (Brand *)[NSEntityDescription insertNewObjectForEntityForName:@"Brand"
                                                            inManagedObjectContext:MOC];
      brand.brandId = @(brandId);
      brand.nearestDistance = @(distance);
      brand.couponInfo = couponInfo;
      
      NSArray *names = [el elementsForName:@"name"];
      if (names.count > 0) {
        brand.name = [CommonUtils decodeAndReplacePlusForText:[names.lastObject stringValue]];
      }
      
      NSArray *categories = [el elementsForName:@"category"];
      if (categories.count > 0) {
        brand.tags = [CommonUtils decodeAndReplacePlusForText:[categories.lastObject stringValue]];
      }
      
      NSArray *commentCounts = [el elementsForName:@"comment_count"];
      if (commentCounts.count > 0) {
        brand.commentCount = @([[commentCounts.lastObject stringValue] intValue]);
      }
      
      NSArray *avatarUrls = [el elementsForName:@"profile_image_url"];
      if (avatarUrls.count > 0) {
        brand.avatarUrl = [avatarUrls.lastObject stringValue];
      }
      
      NSArray *companyTypes = [el elementsForName:@"company_type"];
      if (companyTypes.count > 0) {
        brand.companyType = [companyTypes.lastObject stringValue];
      }
      
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleBrandDetails:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *brands = [respDoc nodesForXPath:@"//channel" error:nil];
    
    NSArray *totals = [respDoc nodesForXPath:@"//all_counts"
                                       error:nil];
    NSInteger total = [[totals.lastObject stringValue] intValue];
    
    for (CXMLElement *el in brands) {
      NSArray *brandIds = [el elementsForName:@"id"];
      long long brandId = 0ll;
      if (brandIds.count > 0) {
        brandId = [[brandIds.lastObject stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(brandId == %lld)", brandId];
      Brand *brand = (Brand *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                        entityName:@"Brand"
                                                         predicate:predicate];
      
      if (nil == brand) {
        brand = (Brand *)[NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:MOC];
      }
      
      if (brand) {
        
        brand.itemTotal = @(total);
        
        brand.brandId = @(brandId);
        
        NSArray *names = [el elementsForName:@"name"];
        if (names.count > 0) {
          brand.name = [CommonUtils decodeAndReplacePlusForText:[names.lastObject stringValue]];
        }
        
        NSArray *categories = [el elementsForName:@"category"];
        if (categories.count > 0) {
          brand.tags = [CommonUtils decodeAndReplacePlusForText:[categories.lastObject stringValue]];
        }
        
        NSArray *commentCounts = [el elementsForName:@"comment_count"];
        if (commentCounts.count > 0) {
          brand.commentCount = @([[commentCounts.lastObject stringValue] intValue]);
        }
        
        NSArray *avatarUrls = [el elementsForName:@"profile_image_url"];
        if (avatarUrls.count > 0) {
          brand.avatarUrl = [avatarUrls.lastObject stringValue];
        }
        
        NSArray *companyTypes = [el elementsForName:@"company_type"];
        if (companyTypes.count > 0) {
          brand.companyType = [companyTypes.lastObject stringValue];
        }
        
        NSArray *descs = [el elementsForName:@"desc"];
        if (descs.count > 0) {
          brand.bio = [CommonUtils decodeAndReplacePlusForText:[descs.lastObject stringValue]];
        }
        
        NSArray *conponInfos = [el elementsForName:@"surprise_desc"];
        if (conponInfos.count > 0) {
          brand.couponInfo = [CommonUtils decodeAndReplacePlusForText:[conponInfos.lastObject stringValue]];
        }
        
        NSArray *commonCounts = [el elementsForName:@"comment_count"];
        if (commonCounts.count > 0) {
          brand.commentCount = @([[commonCounts.lastObject stringValue] intValue]);
        }
        
        NSArray *latestCommentors = [el elementsForName:@"latest_comment_user"];
        if (latestCommentors.count > 0) {
          brand.latestCommenterName = [CommonUtils decodeAndReplacePlusForText:[latestCommentors.lastObject stringValue]];
        }
        
        NSArray *latestCommentTimeStamps = [el elementsForName:@"latest_comment_date"];
        if (latestCommentTimeStamps.count > 0) {
          
          double timestamp = [[latestCommentTimeStamps.lastObject stringValue] doubleValue];
          
          brand.latestCommentTimestamp = @(timestamp);
          
          if (timestamp > 0) {
            brand.latestCommentElapsedTime = [CommonUtils getElapsedTime:[CommonUtils convertDateTimeFromUnixTS:timestamp]];
          }
        }
        
        NSArray *latestCommentContents = [el elementsForName:@"latest_comment"];
        if (latestCommentContents.count > 0) {
          brand.latestComment = [CommonUtils decodeAndReplacePlusForText:[latestCommentContents.lastObject stringValue]];
        }
        
        NSArray *latestCommentBranchNames = [el elementsForName:@"comment_service_name"];
        if (latestCommentBranchNames.count > 0) {
          brand.latestCommentBranchName = [CommonUtils decodeAndReplacePlusForText:[latestCommentBranchNames.lastObject stringValue]];
        }
        
        NSArray *branches = [respDoc nodesForXPath:@"//service"
                                             error:nil];
        NSInteger index = 0;
        for (CXMLElement *branchEl in branches) {
          
          ServiceItem *branch = (ServiceItem *)[self parserServiceItem:branchEl
                                                          forFavorited:NO
                                                                   MOC:MOC
                                                          currentTotal:total
                                                                 index:index
                                              needUpdateTotalItemCount:YES];
          
          branch.brandId = @(brandId);
          
          index++;
        }
        
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
  
}

+ (BOOL)handleAlumniFounders:(CXMLDocument *)respDoc
                         MOC:(NSManagedObjectContext *)MOC
                     brandId:(long long)brandId {
  
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *alumnus = [respDoc nodesForXPath:@"//users/user" error:nil];
    for (CXMLElement *el in alumnus) {
      NSArray *personIds = [el elementsForName:@"person_id"];
      NSString *personId = nil;
      if (personIds.count > 0) {
        personId = [personIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", personId];
      AlumniFounder *checkPoint = (AlumniFounder *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                             entityName:@"AlumniFounder"
                                                                              predicate:predicate];
      if (checkPoint) {
        continue;
      }
      
      AlumniFounder *founder = (AlumniFounder *)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniFounder"
                                                                              inManagedObjectContext:MOC];
      founder.personId = personId;
      founder.brandId = @(brandId);
      
      NSArray *usernames = [el elementsForName:@"user_name"];
      if (usernames.count > 0) {
        founder.name = [CommonUtils decodeAndReplacePlusForText:[usernames.lastObject stringValue]];
      }
      
      NSArray *userTypes = [el elementsForName:@"user_type"];
      if (userTypes.count > 0) {
        founder.userType = [userTypes.lastObject stringValue];
      }
      
      NSArray *companyNames = [el elementsForName:@"company_name"];
      if (companyNames.count > 0) {
        founder.companyName = [CommonUtils decodeAndReplacePlusForText:[companyNames.lastObject stringValue]];
      }
      
      NSArray *classNames = [el elementsForName:@"class_name"];
      if (classNames.count > 0) {
        founder.classGroupName = [CommonUtils decodeAndReplacePlusForText:[classNames.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [el elementsForName:@"avatar"];
      if (imageUrls.count > 0) {
        founder.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *titles = [el elementsForName:@"description"];
      if (titles.count > 0) {
        founder.title = [CommonUtils decodeAndReplacePlusForText:[titles.lastObject stringValue]];
      }
    }
    
    SAVE_MOC(MOC);
    
    return YES;
  } else {
    return NO;
  }
  
  
}

#pragma mark - load nearby place list
+ (BOOL)handleNearbyPlace:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC{
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    // place
    NSArray *addressList = [respDoc nodesForXPath:@"//places/place" error:nil];
    for (int i = 0; i < [addressList count]; i++) {
      NSString *placeId = nil;
      NSString *name = nil;
      //NSString *address = nil;
      CGFloat distance = 0.0f;
      
      CXMLElement *el = (CXMLElement *)addressList[i];
      NSArray *idArray = [el elementsForName:@"id"];
      if ([idArray count]) {
        placeId = [[idArray lastObject] stringValue];
      }
      
      NSArray *urlArray = [el elementsForName:@"name"];
      if ([urlArray count]) {
        
        name = [CommonUtils decodeAndReplacePlusForText:[[urlArray lastObject] stringValue]];
      }
      if (nil == name) {
        name = NULL_PARAM_VALUE;
      }
      /*
       NSArray *addresses = [el elementsForName:@"vicinity"];
       if ([addresses count]) {
       address = [[addresses lastObject] stringValue];
       }
       if (nil == address) {
       address = NULL_PARAM_VALUE;
       }
       */
      
      NSArray *distances = [el elementsForName:@"distance"];
      if (distances.count > 0) {
        distance = [[distances.lastObject stringValue] floatValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", placeId];
      Place *checkPoint = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                             entityName:@"Place"
                                                              predicate:predicate];
      if (checkPoint) {
        checkPoint.placeName = name;
        checkPoint.distance = @(distance);
        continue;
      }
      
      Place *place = (Place *)[NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                                            inManagedObjectContext:MOC];
      place.placeId = placeId;
      place.placeName = name;
      place.distance = @(distance);
      place.selected = @NO;
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

#pragma mark - fetch sponsor
+ (BOOL)handleSponsor:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    // sku info
    NSString *skuMsg = nil;
    NSArray *skuList = [respDoc nodesForXPath:@"//skus/sku" error:nil];
    
    NSString *skusIdStr = NULL_PARAM_VALUE;
    NSString *skuNameStr = NULL_PARAM_VALUE;
    NSString *skusPriceStr = NULL_PARAM_VALUE;
    NSString *allowMultipleStr = NULL_PARAM_VALUE;

    for (CXMLElement *el in skuList) {
      
      skusIdStr = NULL_PARAM_VALUE;
      skuNameStr = NULL_PARAM_VALUE;
      skusPriceStr = NULL_PARAM_VALUE;
      allowMultipleStr = NULL_PARAM_VALUE;
      
      NSArray *skuIds = [el elementsForName:@"sku_id"];
      if ([skuIds count] > 0) {
        skusIdStr = [[skuIds lastObject] stringValue];
      }
      
      NSArray *skuNames = [el elementsForName:@"sku_name"];
      if ([skuNames count] > 0) {
        skuNameStr = [[skuNames lastObject] stringValue];
      }
      
      NSArray *salesPrices = [el elementsForName:@"sales_price"];
      if ([salesPrices count] > 0) {
        skusPriceStr = [[salesPrices lastObject] stringValue];
      }
      
      NSArray *allowMultiples = [el elementsForName:@"allow_multiple"];
      if ([allowMultiples count] > 0) {
        allowMultipleStr = [[allowMultiples lastObject] stringValue];
      }
      
      if (!skuMsg) {
        skuMsg = [NSString stringWithFormat:@"%@#%@#%@#%@#",skusIdStr,skuNameStr,skusPriceStr,allowMultipleStr];
      } else {
        skuMsg = [NSString stringWithFormat:@"%@$%@#%@#%@#%@#",skuMsg,skusIdStr,skuNameStr,skusPriceStr,allowMultipleStr];
      }
    }
    
    NSArray *eventList = [respDoc nodesForXPath:@"//host" error:nil];
    for (CXMLElement *el in eventList) {
      
      NSArray *eventIds = [el elementsForName:@"id"];
      long long eventId = 0;
      if ([eventIds count] > 0) {
        eventId = [[[eventIds lastObject] stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sponsorId == %lld)", eventId];
      ClubDetail *checkPoint = (ClubDetail *)[CommonUtils hasSameObjectAlready:MOC
                                                                    entityName:@"ClubDetail"
                                                                  sortDescKeys:nil
                                                                     predicate:predicate];
      if (checkPoint) {
        checkPoint.skuPrice = @(skusPriceStr.floatValue);
        continue;
      }
      
      ClubDetail *club = (ClubDetail *)[NSEntityDescription insertNewObjectForEntityForName:@"ClubDetail" inManagedObjectContext:MOC];
      club.sponsorId = @(eventId);
      club.skuPrice = @(skusPriceStr.floatValue);
      
      NSArray *name = [el elementsForName:@"name"];
      if ([name count] > 0) {
        club.name = [[name lastObject] stringValue];
      }
      
      NSArray *payOrderIds = [el elementsForName:@"order_id"];
      if ([payOrderIds count] > 0) {
        club.payOrderId = [[payOrderIds lastObject] stringValue];
      }
      
      NSArray *chargeItemNames = [el elementsForName:@"chargeItemName"];
      if ([chargeItemNames count] > 0) {
        club.orderTitle = [[chargeItemNames lastObject] stringValue];
      }
      
      NSArray *detailDescUrl = [el elementsForName:@"detail_desc_url"];
      if ([detailDescUrl count] > 0) {
        club.detailDescUrl = [[detailDescUrl lastObject] stringValue];
      }
      
      if (skuMsg == nil) {
        club.skuMsg = NULL_PARAM_VALUE;
      } else {
        club.skuMsg = skuMsg;
      }
      
      NSArray *thumbnail = [el elementsForName:@"avatar_url"];
      if ([thumbnail count] > 0) {
        club.imgUrl = [[thumbnail lastObject] stringValue];
      }
      
      // desc
      NSArray *desc = [el elementsForName:@"desc"];
      if ([desc count] > 0) {
        club.desc = [[[desc lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == club.desc) {
        club.desc = NULL_PARAM_VALUE;
      }
      
      // change
      NSArray *change = [el elementsForName:@"fee_desc"];
      if ([change count] > 0) {
        club.change = [[change lastObject] stringValue];
      }
      if (nil == club.change || club.change.length < 2) {
        club.change = NULL_PARAM_VALUE;
      }
      
      // change
      NSArray *feesValue = [el elementsForName:@"fees_value"];
      float feesFloatValue = 0.0f;
      
      if ([feesValue count] > 0) {
        feesFloatValue = [[[feesValue lastObject] stringValue] floatValue];
      }
      
      int feesIntValue = feesFloatValue*100;
      
      club.feesValue = @(feesIntValue);
      
      // payment status
      NSArray *paymentStatus = [el elementsForName:@"payment_status"];
      if ([paymentStatus count] > 0) {
        club.paymentStatus = @([[[paymentStatus lastObject] stringValue] intValue]);
      }
      //            club.paymentStatus = @(5);
      
      NSArray *memberShipInfos = [el elementsForName:@"membership_info"];
      if ([memberShipInfos count] > 0) {
        club.memberShipInfo = [[memberShipInfos lastObject] stringValue];
      }
      if (club.memberShipInfo == nil) {
        club.memberShipInfo = NULL_PARAM_VALUE;
      }
      
      NSArray *createTime = [el elementsForName:@"create_time"];
      if ([createTime count] > 0) {
        club.createTime = [[createTime lastObject] stringValue];
      }
      if (nil == club.createTime || [club.createTime isEqualToString:@"null"]) {
        club.createTime = NULL_PARAM_VALUE;
      }
      
      NSArray *email = [el elementsForName:@"email"];
      if ([email count] > 0) {
        club.email = [[email lastObject] stringValue];
      }
      if (nil == club.email) {
        club.email = NULL_PARAM_VALUE;
      }
      
      NSArray *hostTypeValue = [el elementsForName:@"host_type_value"];
      if ([hostTypeValue count] > 0) {
        club.hostSupTypeValue = [[hostTypeValue lastObject] stringValue];
      }
      
      NSArray *hostSubTypeValue = [el elementsForName:@"host_sub_type_value"];
      if ([hostSubTypeValue count] > 0) {
        club.hostTypeValue = [[hostSubTypeValue lastObject] stringValue];
      }
      
      NSArray *weibo = [el elementsForName:@"weibo"];
      if ([weibo count] > 0) {
        club.weibo = [[weibo lastObject] stringValue];
      }
      
      NSArray *webUrl = [el elementsForName:@"website"];
      if ([webUrl count] > 0) {
        club.webUrl = [[webUrl lastObject] stringValue];
      }
      if (nil == club.webUrl) {
        club.webUrl = NULL_PARAM_VALUE;
      }
      
      NSArray *phoneNumber = [el elementsForName:@"phone_number"];
      if ([phoneNumber count] > 0) {
        club.tel = [[phoneNumber lastObject] stringValue];
      }
      if (nil == club.tel) {
        club.tel = NULL_PARAM_VALUE;
      }
      
      NSArray *isRead = [el elementsForName:@"is_read"];
      if ([isRead count] > 0) {
        club.isRead = [[isRead lastObject] stringValue];
      }
      
      NSArray *isWrite = [el elementsForName:@"is_writer"];
      if ([isWrite count] > 0) {
        club.isWrite = [[isWrite lastObject] stringValue];
      }
      
      NSArray *adminCodes = [el elementsForName:@"ifAdmin"];
      if ([adminCodes count] > 0) {
        club.ifadmin = [[adminCodes lastObject] stringValue];
      }
      
      NSArray *memberCodes = [el elementsForName:@"ifMember"];
      if ([memberCodes count] > 0) {
        club.ifmember = [[memberCodes lastObject] stringValue];
      }
      
      NSArray *memberCountCodes = [el elementsForName:@"memberCount"];
      if ([memberCountCodes count] > 0) {
        club.membercount = @([[[memberCountCodes lastObject] stringValue] intValue]);
      }
      
      NSArray *eventCountCodes = [el elementsForName:@"eventCount"];
      if ([eventCountCodes count] > 0) {
        club.eventcount = @([[[eventCountCodes lastObject] stringValue] intValue]);
      }
      
      NSArray *newPostCounts = [el elementsForName:@"newPostCount"];
      if ([newPostCounts count] > 0) {
        club.newPostCount = [[newPostCounts lastObject] stringValue];
      }
    }
    
    if ([CommonUtils saveMOCChange:MOC]) {
      return YES;
    } else {
      return NO;
    }
    
  } else {
    return NO;
  }
}

#pragma mark - Soft msg
+ (ReturnCode)handleSoftMsg:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return ERR_CODE;
  }
  
  if (![AppManager instance].distanceList) {
    [[AppManager instance].distanceList removeAllObjects];
    [AppManager instance].distanceList = nil;
  }
  if (![AppManager instance].timeList) {
    [[AppManager instance].timeList removeAllObjects];
    [AppManager instance].timeList = nil;
  }
  if (![AppManager instance].sortList) {
    [[AppManager instance].sortList removeAllObjects];
    [AppManager instance].sortList = nil;
  }
  
  [AppManager instance].distanceList = [NSMutableArray array];
  [AppManager instance].timeList = [NSMutableArray array];
  [AppManager instance].sortList = [NSMutableArray array];
  
  NSArray *respCodes = [doc nodesForXPath:@"//response/code" error:nil];
  NSArray *respDesc = [doc nodesForXPath:@"//response/message" error:nil];
  NSArray *respUrl = [doc nodesForXPath:@"//response/url" error:nil];
  NSArray *respTel = [doc nodesForXPath:@"//response/telephone" error:nil];
  NSArray *recommend = [doc nodesForXPath:@"//response/recommend" error:nil];
  
  NSArray *questionTitles = [doc nodesForXPath:@"//response/questionaire/text" error:nil];
  if (questionTitles.count > 0) {
    [AppManager instance].questionSubTitle = [WXWCommonUtils decodeAndReplacePlusForText:[questionTitles.lastObject stringValue]];
  }
  
  NSArray *questionIds = [doc nodesForXPath:@"//response/questionaire/id"
                                      error:nil];
  if (questionIds.count > 0) {
    [AppManager instance].questionId = [questionIds.lastObject stringValue].longLongValue;
  }
  
  NSArray *distances = [doc nodesForXPath:@"//distances/distance" error:nil];
  int index = 0;
  
  // distance
  DELETE_OBJS_FROM_MOC(MOC, @"Distance", nil);
  DELETE_OBJS_FROM_MOC(MOC, @"FilterOption", nil);
  
  for (CXMLElement *el in distances) {
    NSString *distanceName = nil;
    NSString *distanceValue = nil;
    CGFloat distanceFloat = 0.0f;
    
    NSArray *distanceNames = [el elementsForName:@"distance_name"];
    if ([distanceNames count] > 0) {
      distanceName = [[[distanceNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == distanceName) {
      distanceName = NULL_PARAM_VALUE;
    }
    
    NSArray *distanceValues = [el elementsForName:@"distance_value"];
    if ([distanceValues count] > 0) {
      distanceValue = [[distanceValues lastObject] stringValue];
      if (distanceValue.length == 0) {
        distanceValue = NULL_PARAM_VALUE;
        distanceFloat = ALL_LOCATION_RADIUS;
      } else {
        distanceFloat = distanceValue.floatValue;
      }
    }
    if (nil == distanceValue) {
      distanceValue = NULL_PARAM_VALUE;
      distanceFloat = ALL_LOCATION_RADIUS;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:distanceValue, distanceName, nil];
    [[AppManager instance].distanceList insertObject:array atIndex:index++];
    
    Distance *distance = [NSEntityDescription insertNewObjectForEntityForName:@"Distance"
                                                       inManagedObjectContext:MOC];
    distance.desc = distanceName;
    distance.valueString = distanceValue;
    distance.valueFloat = @(distanceFloat);
    distance.selected = @NO;
    
    FilterOption *filterOption = (FilterOption *)[NSEntityDescription insertNewObjectForEntityForName:@"FilterOption"
                                                                               inManagedObjectContext:MOC];
    filterOption.desc = distanceName;
    filterOption.valueString = distanceValue;
    
    BOOL selected = NO;
    if (distanceFloat == 0.0f) {
      filterOption.valueFloat = @CGFLOAT_MAX;
      selected = YES;
    } else {
      filterOption.valueFloat = @(distanceFloat);
    }
    
    filterOption.selected = @(selected);
    filterOption.type = @(DISTANCE_FILTER_TY);
  }
  SAVE_MOC(MOC);
  
  // time
  index = 0;
  NSArray *times = [doc nodesForXPath:@"//times/time" error:nil];
  for (CXMLElement *el in times) {
    
    NSString *timeName = nil;
    NSString *timeValue = nil;
    
    NSArray *distanceNames = [el elementsForName:@"time_name"];
    if ([distanceNames count] > 0) {
      timeName = [[[distanceNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == timeName) {
      timeName = NULL_PARAM_VALUE;
    }
    
    NSArray *distanceValues = [el elementsForName:@"time_value"];
    if ([distanceValues count] > 0) {
      timeValue = [[distanceValues lastObject] stringValue];
    }
    if (nil == timeValue) {
      timeValue = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [[[NSMutableArray alloc] initWithObjects:timeValue, timeName, nil] autorelease];
    [[AppManager instance].timeList insertObject:array atIndex:index++];
    
    FilterOption *filterOption = (FilterOption *)[NSEntityDescription insertNewObjectForEntityForName:@"FilterOption"
                                                                               inManagedObjectContext:MOC];
    filterOption.desc = timeName;
    filterOption.valueString = timeValue;
    BOOL selected = NO;
    if (0.0f == timeValue.floatValue) {
      filterOption.valueFloat = @CGFLOAT_MAX;
      selected = YES;
    } else {
      filterOption.valueFloat = @(timeValue.floatValue);
    }
    
    filterOption.selected = @(selected);
    filterOption.type = @(TIME_FILTER_TY);
  }
  
  // order
  DELETE_OBJS_FROM_MOC(MOC, @"SortOption", nil);
  index = 0;
  NSArray *orders = [doc nodesForXPath:@"//order_by_columns/orderByColumn" error:nil];
  for (CXMLElement *el in orders) {
    
    NSString *orderName = nil;
    NSString *orderValue = nil;
    
    NSArray *orderNames = [el elementsForName:@"column_name"];
    if ([orderNames count] > 0) {
      orderName = [[[orderNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == orderName) {
      orderName = NULL_PARAM_VALUE;
    }
    
    NSArray *orderValues = [el elementsForName:@"column_value"];
    if ([orderValues count] > 0) {
      orderValue = [[orderValues lastObject] stringValue];
    }
    if (nil == orderValue) {
      orderValue = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:orderValue,orderName, nil];
    [[AppManager instance].sortList insertObject:array atIndex:index++];
    
    // create corresponding data object in MOC
    SortOption *sortOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                         inManagedObjectContext:MOC];
    sortOption.optionName = orderName;
    sortOption.optionValue = orderValue;
    BOOL selected = NO;
    if ([NEARBY_PEOPLE_SORTBY_TIME_TY isEqualToString:orderValue]) {
      selected = YES;
    }
    sortOption.selected = @(selected);
    sortOption.usageType = @(PEOPLE_ITEM_TY);
  }
  SAVE_MOC(MOC);
  
  // prepare post sort options
  [CoreDataUtils preparePostSortOptions:MOC];
  
  //prepare venue sort options
  [CoreDataUtils prepareVenueSortOptions:MOC];
  
  if (RESP_OK != [[[respCodes lastObject] stringValue] intValue]){
    [AppManager instance].softUrl = [[respUrl lastObject] stringValue];
    [AppManager instance].softDesc = [[respDesc lastObject] stringValue];
    return SOFT_UPDATE_CODE;
  } else {
    [AppManager instance].serviceTel = [[respTel lastObject] stringValue];
    //        [AppManager instance].serviceContact = [[respContactName lastObject] stringValue];
    //        [AppManager instance].serviceEmail = [[respEmail lastObject] stringValue];
    [AppManager instance].recommend = [[recommend lastObject] stringValue];
    return RESP_OK;
  }
}

#pragma mark - common handle result
+ (ReturnCode)handleCommonResult:(NSData *)xmlData showFlag:(BOOL)showFlag {
  
  CXMLDocument *doc = nil;
  if (![self parserResponseNode:xmlData
                            doc:&doc]) {
    return NO;
  }
  
  NSArray *respCodes = [doc nodesForXPath:@"//response/code" error:nil];
  NSArray *respDesc = [doc nodesForXPath:@"//response/desc" error:nil];
  NSArray *respMobile = [doc nodesForXPath:@"//response/mobile" error:nil];
  NSArray *respEmail = [doc nodesForXPath:@"//response/email" error:nil];
  NSArray *respWeibo = [doc nodesForXPath:@"//response/sina_username" error:nil];
  
  if (RESP_OK != [[[respCodes lastObject] stringValue] intValue]){
    [UIUtils showNotificationOnTopWithMsg:[[respDesc lastObject] stringValue]
                                  msgType:INFO_TY
                       belowNavigationBar:YES];
    
    return ERR_CODE;
    
  } else {
    if (showFlag) {
      [UIUtils showNotificationOnTopWithMsg:[[respDesc lastObject] stringValue]
                                    msgType:SUCCESS_TY
                         belowNavigationBar:YES];
      
    }else {
      if ([respMobile count]) {
        [AppManager instance].eventAlumniMobile = [[respMobile lastObject] stringValue];
      } else {
        [AppManager instance].eventAlumniMobile = NULL_PARAM_VALUE;
      }
      
      if ([respWeibo count]) {
        [AppManager instance].eventAlumniWeibo = [[respWeibo lastObject] stringValue];
      } else {
        [AppManager instance].eventAlumniWeibo = NULL_PARAM_VALUE;
      }
      
      if ([respEmail count]) {
        [AppManager instance].eventAlumniEmail = [[respEmail lastObject] stringValue];
      } else {
        [AppManager instance].eventAlumniEmail = NULL_PARAM_VALUE;
      }
    }
    
    return RESP_OK;
  }
}

#pragma mark - fetch welfare

+ (BOOL)handleWelfareDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *itemIds = [respDoc nodesForXPath:@"//response/content/itemId" error:nil];
    NSString *itemId = nil;
    if (itemIds.count > 0) {
      itemId = [itemIds.lastObject stringValue];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %@)", itemId];
    Welfare *welfare = (Welfare *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                            entityName:@"Welfare"
                                                             predicate:predicate];
    if (welfare == nil) {
      welfare = (Welfare *)[NSEntityDescription insertNewObjectForEntityForName:@"Welfare"
                                                         inManagedObjectContext:MOC];
    }
    
    welfare.itemId = itemId;
    
    NSArray *buyTypes = [respDoc nodesForXPath:@"//response/content/buyType" error:nil];
    if (buyTypes.count > 0) {
      welfare.buyType = @([[buyTypes.lastObject stringValue] intValue]);
    }
        
    NSArray *buyTypeDescs = [respDoc nodesForXPath:@"//response/content/buyTypeDesc" error:nil];
    if (buyTypeDescs.count > 0) {
      welfare.buyTypeDesc = [CommonUtils decodeAndReplacePlusForText:[buyTypeDescs.lastObject stringValue]];
    }
    
    NSArray *salesPersonCounts = [respDoc nodesForXPath:@"//response/content/salesPersonCount" error:nil];
    if (salesPersonCounts.count > 0) {
      welfare.salesPersonCount = @([[salesPersonCounts.lastObject stringValue] intValue]);
    }
    
    
    NSArray *downloadPersonCounts = [respDoc nodesForXPath:@"//response/content/downloadPersonCount" error:nil];
    if (downloadPersonCounts.count > 0) {
      welfare.downloadPersonCount = @([[downloadPersonCounts.lastObject stringValue] intValue]);
    }
    
    NSArray *overCounts = [respDoc nodesForXPath:@"//response/content/overCount" error:nil];
    if (overCounts.count > 0) {
      welfare.overCount = @([[overCounts.lastObject stringValue] intValue]);
    }
    
    NSArray *useInfos = [respDoc nodesForXPath:@"//response/content/useInfo" error:nil];
    if (useInfos.count > 0) {
      welfare.useInfo = [CommonUtils decodeAndReplacePlusForText:[useInfos.lastObject stringValue]];
    }
    
    NSArray *tels = [respDoc nodesForXPath:@"//response/content/tel" error:nil];
    if (tels.count > 0) {
      welfare.tel = [tels.lastObject stringValue];
    }
    
    NSArray *endTimes = [respDoc nodesForXPath:@"//response/content/endTime" error:nil];
    if (endTimes.count > 0) {
      welfare.endTime = [endTimes.lastObject stringValue];
    }
    
    NSArray *couponUrls = [respDoc nodesForXPath:@"//response/content/couponURL" error:nil];
    if (couponUrls.count > 0) {
      welfare.couponUrl = [couponUrls.lastObject stringValue];
    }
    
    NSArray *offersTipsList = [respDoc nodesForXPath:@"//response/content/offersTips" error:nil];
    if (offersTipsList.count > 0) {
      welfare.offersTips = [CommonUtils decodeAndReplacePlusForText:[offersTipsList.lastObject stringValue]];
    }
    
    NSArray *favoritedStatus = [respDoc nodesForXPath:@"//response/content/isKeep" error:nil];
    if (favoritedStatus.count > 0) {
      welfare.favorited = [[favoritedStatus.lastObject stringValue] intValue] == 1 ? @(YES) : @(NO);
    }
    
    
    NSArray *imageList = [respDoc nodesForXPath:@"//response/content/imageList/image" error:nil];
    for (CXMLElement *el in imageList) {
      NSArray *imageUrls = [el elementsForName:@"imageURL"];
      NSString *url = nil;
      if (imageUrls.count > 0) {
        url = [imageUrls.lastObject stringValue];
      }
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(imageUrl == %@)", url];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"AlbumPhoto"
                              predicate:predicate]) {
        continue;
      }
      AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"AlbumPhoto"
                                                                      inManagedObjectContext:MOC];
      photo.imageUrl = url;
      [welfare addImageListObject:photo];
      
    }
    /*
     predicate = [NSPredicate predicateWithFormat:@"(imageUrl == %@)", @"http://alumniapp.ceibs.edu:8080/ceibs_test/FileUploadServlet/upfiles/1346491720179.jpg"];
     if (![WXWCoreDataUtils objectInMOC:MOC
     entityName:@"AlbumPhoto"
     predicate:predicate]) {
     AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"AlbumPhoto"
     inManagedObjectContext:MOC];
     
     photo.imageUrl = @"http://alumniapp.ceibs.edu:8080/ceibs_test/FileUploadServlet/upfiles/1346491720179.jpg";
     [welfare addImageListObject:photo];
     }
     */
    
    NSArray *skuList = [respDoc nodesForXPath:@"//response/content/skuList/sku" error:nil];
    for (CXMLElement *el in skuList) {
      NSArray *skuIds = [el elementsForName:@"skuId"];
      NSString *skuId = nil;
      if (skuIds.count > 0) {
        skuId = [skuIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(skuId == %@)", skuId];
      if ([WXWCoreDataUtils objectInMOC:MOC entityName:@"Sku" predicate:predicate]) {
        continue;
      }
      
      Sku *sku = (Sku *)[NSEntityDescription insertNewObjectForEntityForName:@"Sku"
                                                      inManagedObjectContext:MOC];
      sku.skuId = skuId;
      
      NSArray *prop1s = [el elementsForName:@"skuProp1"];
      if (prop1s.count > 0) {
        sku.skuProp1 = [CommonUtils decodeAndReplacePlusForText:[prop1s.lastObject stringValue]];
      }
      
      NSArray *prices = [el elementsForName:@"price"];
      if (prices.count > 0) {
        sku.price = @([[prices.lastObject stringValue] floatValue]);
      }
      
      NSArray *salesPrices = [el elementsForName:@"salesPrice"];
      if (salesPrices.count > 0) {
        sku.salesPrice = @([[salesPrices.lastObject stringValue] floatValue]);
      }
      
      NSArray *discountRates = [el elementsForName:@"discountRate"];
      if (discountRates.count > 0) {
        sku.discountRate = @([[discountRates.lastObject stringValue] floatValue]);
      }
      
      NSArray *integrals = [el elementsForName:@"integral"];
      if (integrals.count > 0) {
        sku.integral = @([[integrals.lastObject stringValue] intValue]);
      }
      
      NSArray *allowMultiples = [el elementsForName:@"allowMultiple"];
      if (allowMultiples.count > 0) {
        sku.allowMultiple = @([[allowMultiples.lastObject stringValue] intValue]);
      }
      
      [welfare addSkuListObject:sku];
    }
    
    NSArray *salesUserList = [respDoc nodesForXPath:@"//response/content/salesUserList/salesUser" error:nil];
    for (CXMLElement *el in salesUserList) {
      NSArray *userIds = [el elementsForName:@"userId"];
      NSString *userId = nil;
      if (userIds.count > 0) {
        userId = [userIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@)", userId];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Alumni"
                              predicate:predicate]) {
        continue;
      }
      
      Alumni *user = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni"
                                                             inManagedObjectContext:MOC];
      user.userId = userId;
      
      NSArray *imageUrls = [el elementsForName:@"imageURL"];
      if (imageUrls.count > 0) {
        user.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      [welfare addSalesUserListObject:user];
    }
    
    NSArray *storeIds = [respDoc nodesForXPath:@"//response/content/storeInfo/storeId"
                                         error:nil];
    if (storeIds.count > 0) {
      welfare.storeId = [storeIds.lastObject stringValue];
    }
    
    NSArray *storeNames = [respDoc nodesForXPath:@"//response/content/storeInfo/storeName"
                                           error:nil];
    if (storeNames.count > 0) {
      welfare.storeName = [storeNames.lastObject stringValue];
    }
    
    NSArray *storeAddress = [respDoc nodesForXPath:@"//response/content/storeInfo/address"
                                             error:nil];
    if (storeAddress.count > 0) {
      welfare.storeAddress = [CommonUtils decodeAndReplacePlusForText:[storeAddress.lastObject stringValue]];
    }
    
    NSArray *storeImageUrls = [respDoc nodesForXPath:@"//response/content/storeInfo/imageURL"
                                               error:nil];
    if (storeImageUrls.count > 0) {
      welfare.storeImageUrl = [storeImageUrls.lastObject stringValue];
    }
    
    NSArray *storeCounts = [respDoc nodesForXPath:@"//response/content/storeInfo/storeCount"
                                            error:nil];
    if (storeCounts.count > 0) {
      welfare.storeCount = @([[storeCounts.lastObject stringValue] intValue]);
    }
    
    NSArray *brandIds = [respDoc nodesForXPath:@"//response/content/brandInfo/brandId"
                                         error:nil];
    if (brandIds.count > 0) {
      welfare.brandId = [brandIds.lastObject stringValue];
    }
    
    NSArray *brandLogoUrls = [respDoc nodesForXPath:@"//response/content/brandInfo/brandLogoURL"
                                              error:nil];
    if (brandLogoUrls.count > 0) {
      welfare.brandLogoUrl = [brandLogoUrls.lastObject stringValue];
    }
    
    NSArray *brandNames = [respDoc nodesForXPath:@"//response/content/brandInfo/brandName"
                                           error:nil];
    if (brandNames.count > 0) {
      welfare.brandName = [CommonUtils decodeAndReplacePlusForText:[brandNames.lastObject stringValue]];
    }
    
    NSArray *brandEngNames = [respDoc nodesForXPath:@"//response/content/brandInfo/brandEngName"
                                              error:nil];
    if (brandEngNames.count > 0) {
      welfare.brandEngName = [CommonUtils decodeAndReplacePlusForText:[brandEngNames.lastObject stringValue]];
    }
    
    SAVE_MOC(MOC);
    
    return YES;
    
  } else {
    return NO;
  }
}

+ (BOOL)handleWelfare:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *videos = [respDoc nodesForXPath:@"//itemList/item" error:nil];
    for (CXMLElement *el in videos) {
      NSArray *ids = [el elementsForName:@"itemId"];
      NSString *itemId = [ids.lastObject stringValue];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %@)", itemId];
      Welfare *isExist = (Welfare *)[CommonUtils hasSameObjectAlready:MOC
                                                           entityName:@"Welfare"
                                                         sortDescKeys:nil
                                                            predicate:predicate];
      if (isExist) {
        continue;
      }
      
      Welfare *welfare = (Welfare *)[NSEntityDescription insertNewObjectForEntityForName:@"Welfare"
                                                                  inManagedObjectContext:MOC];
      
      welfare.itemId = itemId;
      
      NSArray *itemNames = [el elementsForName:@"itemName"];
      if ([itemNames count] > 0) {
        welfare.itemName = [WXWCommonUtils decodeAndReplacePlusForText:[itemNames.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [el elementsForName:@"imageUrl"];
      if ([imageUrls count] > 0) {
        welfare.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *discountRates = [el elementsForName:@"discountRate"];
      if ([discountRates count] > 0) {
        welfare.discountRate = [discountRates.lastObject stringValue];
      }
      
      NSArray *pTypeCodes = [el elementsForName:@"pTypeCode"];
      if ([pTypeCodes count] > 0) {
        welfare.pTypeCode = [pTypeCodes.lastObject stringValue];
      }
      
      NSArray *pTypeIds = [el elementsForName:@"pTypeId"];
      if ([pTypeIds count] > 0) {
        welfare.pTypeId = [pTypeIds.lastObject stringValue];
      }
      
      NSArray *prices = [el elementsForName:@"price"];
      if ([prices count] > 0) {
        welfare.price = [prices.lastObject stringValue];
      }
      
      NSArray *salesPrices = [el elementsForName:@"salesPrice"];
      if ([salesPrices count] > 0) {
        welfare.salesPrice = [salesPrices.lastObject stringValue];
      }
      
      NSArray *orders = [el elementsForName:@"displayIndex"];
      if ([orders count] > 0) {
        welfare.order = @([[[orders lastObject] stringValue] intValue]);
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleWelfareBrandDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *brands = [respDoc nodesForXPath:@"//response/content" error:nil];
    if (brands.count > 0) {
      CXMLElement *el = brands.lastObject;
      NSArray *brandIds = [el elementsForName:@"brandId"];
      NSString *brandId = nil;
      if (brandIds.count > 0) {
        brandId = [brandIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(brandId == %@)", brandId];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Brand"
                              predicate:predicate]) {
        return YES;
      }
      
      Brand *brand = (Brand *)[NSEntityDescription insertNewObjectForEntityForName:@"Brand"
                                                            inManagedObjectContext:MOC];
      brand.brandId = brandId;
      
      NSArray *brandNames = [el elementsForName:@"brandName"];
      if (brandNames.count > 0) {
        brand.name = [WXWCommonUtils decodeAndReplacePlusForText:[brandNames.lastObject stringValue]];
      }
      
      NSArray *brandEngNames = [el elementsForName:@"brandEngName"];
      if (brandEngNames.count > 0) {
        brand.engName = [WXWCommonUtils decodeAndReplacePlusForText:[brandEngNames.lastObject stringValue]];
      }
      
      NSArray *brandDescs = [el elementsForName:@"brandDesc"];
      if (brandDescs.count > 0) {
        brand.bio = [WXWCommonUtils decodeAndReplacePlusForText:[brandDescs.lastObject stringValue]];
      }
      
      NSArray *brandLogoUrls = [el elementsForName:@"brandLogoURL"];
      if (brandLogoUrls.count > 0) {
        brand.avatarUrl = [brandLogoUrls.lastObject stringValue];
      }
      
      NSArray *tels = [el elementsForName:@"tel"];
      if (tels.count > 0) {
        brand.tel = [tels.lastObject stringValue];
      }
      
      NSArray *alumnusList = [respDoc nodesForXPath:@"//response/content/brandAlumnusList/brandAlumnus" error:nil];
      for (CXMLElement *alumniEl in alumnusList) {
        NSArray *userIds = [alumniEl elementsForName:@"userId"];
        NSString *userId = nil;
        if (userIds.count > 0) {
          userId = [userIds.lastObject stringValue];
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId == %@)", userId];
        if ([WXWCoreDataUtils objectInMOC:MOC
                               entityName:@"Alumni"
                                predicate:predicate]) {
          continue;
        }
        
        Alumni *alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni"
                                                                 inManagedObjectContext:MOC];
        alumni.userId = userId;
        
        NSArray *userNames = [alumniEl elementsForName:@"userName"];
        if (userNames.count > 0) {
          alumni.name = [WXWCommonUtils decodeAndReplacePlusForText:[userNames.lastObject stringValue]];
        }
        
        NSArray *jobTitles = [alumniEl elementsForName:@"jobTitle"];
        if (jobTitles.count > 0) {
          alumni.jobTitle = [WXWCommonUtils decodeAndReplacePlusForText:[jobTitles.lastObject stringValue]];
        }
        
        NSArray *imageUrls = [alumniEl elementsForName:@"imageURL"];
        if (imageUrls.count > 0) {
          alumni.imageUrl = [imageUrls.lastObject stringValue];
        }
        
        NSArray *classNames = [alumniEl elementsForName:@"classTitle"];
        if (classNames.count > 0) {
          alumni.classGroupName = [CommonUtils decodeAndReplacePlusForText:[classNames.lastObject stringValue]];
        }
        
        [brand addBrandAlumnusObject:alumni];
      }

    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  
  }
}

+ (NSString *)parserOrderIdWithData:(NSData *)data
                  connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                url:(NSString *)url
                               type:(WebItemType)type {
  
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:data
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:type]) {
		return nil;
	}

  if ([self parserResponseCode:doc] == RESP_OK) {
    
    NSMutableString *orderInfo = [NSMutableString string];
    NSArray *orderCodes = [doc nodesForXPath:@"//response/content/orderCode" error:nil];
    if (orderCodes.count > 0) {
      [orderInfo appendString:[orderCodes.lastObject stringValue]];
    }
    
    NSArray *orderIds = [doc nodesForXPath:@"//response/content/orderId" error:nil];
    if (orderIds.count > 0) {
      [orderInfo appendString:@"#"];
      [orderInfo appendString:[orderIds.lastObject stringValue]];
    }
    
    return orderInfo;
  } else {
    return nil;
  }
}

#pragma mark - fetch video
+ (BOOL)handleVideo:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  return [self parserVideos:respDoc MOC:MOC];
}

#pragma mark - fetch feedback
+ (BOOL)handleFeedback:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  [CommonUtils unLoadObject:MOC predicate:nil entityName:@"Feedback"];
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    // set sample info
    NSString *sampleMsg = nil;
    NSArray *sampleList = [respDoc nodesForXPath:@"//samples/sample" error:nil];
    int sampleSize = [sampleList count];
    for (int i = 0; i < sampleSize; i++) {
      NSString *sampleName;
      CXMLElement *el = (CXMLElement *)sampleList[i];
      sampleName = [el stringValue];
      
      if (!sampleMsg) {
        sampleMsg = [NSString stringWithFormat:@"%@",sampleName];
      }else{
        sampleMsg = [NSString stringWithFormat:@"%@|%@",sampleMsg,sampleName];
      }
    }
    
    // feedback detail
    Feedback *feedback = nil;
    feedback = (Feedback *)[NSEntityDescription insertNewObjectForEntityForName:@"Feedback" inManagedObjectContext:MOC];
    
    NSArray *tel = [respDoc nodesForXPath:@"//response/phone"
                                    error:nil];
    if ([tel count] > 0) {
      feedback.tel = [[[tel lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *email = [respDoc nodesForXPath:@"//response/email"
                                      error:nil];
    if ([email count] > 0) {
      feedback.email = [[[email lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    feedback.sampleMsg = sampleMsg;
  }
  
  if ([CommonUtils saveMOCChange:MOC]) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - welfare store

+ (void)parserStoreContent:(CXMLElement *)el imageList:(NSArray *)imageList MOC:(NSManagedObjectContext *)MOC {
  
  NSArray *storeIds = [el elementsForName:@"storeId"];
  NSString *storeId = nil;
  if (storeIds.count > 0) {
    storeId = [storeIds.lastObject stringValue];
  }
  
  NSArray *distances = [el elementsForName:@"distance"];
  CGFloat distance = 0.0f;
  if (distances.count > 0) {
    distance = [[distances.lastObject stringValue] floatValue];
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(storeId == %@)", storeId];
  
  Store *store = (Store *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                    entityName:@"Store"
                                                     predicate:predicate];
  if (store) {
    store.distance = @(distance);
  } else {
    store = (Store *)[NSEntityDescription insertNewObjectForEntityForName:@"Store"
                                                   inManagedObjectContext:MOC];
  }
  
  store.storeId = storeId;
  store.distance = @(distance);
  
  NSArray *addressList = [el elementsForName:@"address"];
  if (addressList.count > 0) {
    store.address = [WXWCommonUtils decodeAndReplacePlusForText:[addressList.lastObject stringValue]];
  }
  
  NSArray *displayIndexList = [el elementsForName:@"displayIndex"];
  if (displayIndexList.count > 0) {
    store.displayIndex = @([[displayIndexList.lastObject stringValue] intValue]);
  }
  
  NSArray *imageUrls = [el elementsForName:@"imageURL"];
  if (imageUrls.count > 0) {
    store.imageUrl = [imageUrls.lastObject stringValue];
  }
  
  NSArray *storeNames = [el elementsForName:@"storeName"];
  if (storeNames.count > 0) {
    store.storeName = [WXWCommonUtils decodeAndReplacePlusForText:[storeNames.lastObject stringValue]];
  }
  
  NSArray *tels = [el elementsForName:@"tel"];
  if (tels.count > 0) {
    store.tel = [tels.lastObject stringValue];
  }
  
  NSArray *brandIds = [el elementsForName:@"brandId"];
  if (brandIds.count > 0) {
    store.brandId = [brandIds.lastObject stringValue];
  }
  
  NSArray *brandNames = [el elementsForName:@"brandName"];
  if (brandNames.count > 0) {
    store.brandName = [WXWCommonUtils decodeAndReplacePlusForText:[brandNames.lastObject stringValue]];
  }
  
  NSArray *brandEngNames = [el elementsForName:@"brandEngName"];
  if (brandEngNames.count > 0) {
    store.brandEngName = [brandEngNames.lastObject stringValue];
  }
  
  NSArray *latitudes = [el elementsForName:@"latitude"];
  if (latitudes.count > 0) {
    store.latitude = @([[latitudes.lastObject stringValue] doubleValue]);
  }
  
  NSArray *longitudes = [el elementsForName:@"longitude"];
  if (longitudes.count > 0) {
    store.longitude = @([[longitudes.lastObject stringValue] doubleValue]);
  }
  
  if (imageList.count > 0) {
    
    for (CXMLElement *imageEl in imageList) {
      NSArray *imageUrls = [imageEl elementsForName:@"imageURL"];
      NSString *imageUrl = nil;
      if (imageUrls.count > 0) {
        imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(imageUrl == %@)", imageUrl];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"AlbumPhoto"
                              predicate:predicate]) {
        continue;
      }
      
      AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"AlbumPhoto"
                                                                      inManagedObjectContext:MOC];
      photo.imageUrl = imageUrl;
      
      [store addImageListObject:photo];
    }
  }
}

+ (BOOL)handleStoreDetail:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *elList = [respDoc nodesForXPath:@"//response/content" error:nil];
    if (elList.count> 0) {
      
      NSArray *imageList = [respDoc nodesForXPath:@"//response/content/imageList/image" error:nil];
      
      [self parserStoreContent:[elList objectAtIndex:0]
                     imageList:imageList
                           MOC:MOC];
    }
    
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleStoreList:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *storeList = [respDoc nodesForXPath:@"//storeList/store" error:nil];
    for (CXMLElement *el in storeList) {
      
      [self parserStoreContent:el imageList:nil MOC:MOC];
      
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

#pragma mark - load chart list

+ (BOOL)parserDMMessageWithxmlData:(NSData *)xmlData
                               MOC:(NSManagedObjectContext *)MOC
                 connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                               url:(NSString *)url
                            alumni:(Alumni *)alumni {
 
  CXMLDocument *doc = nil;
	
	if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:CHART_LIST_TY]) {
		return NO;
	}

  return [self handleDMChatList:doc MOC:MOC alumni:alumni];
}

+ (BOOL)handleDMChatList:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC alumni:(Alumni *)alumni {
  
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *newsList = [respDoc nodesForXPath:@"//prs/pr" error:nil];
    for (CXMLElement *el in newsList) {
      
      NSArray *chartIds = [el elementsForName:@"id"];
      long long chartId = 0;
      if ([chartIds count] > 0) {
        chartId = [[[chartIds lastObject] stringValue] longLongValue];
      }
      
      NSDate *postDate = nil;
      NSArray *postDates = [el elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0;
      if ([postDates count] > 0) {
        timestamp = [[[postDates lastObject] stringValue] doubleValue];
        postDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %lld)", chartId];
      
      Post *chat = (Post *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                     entityName:@"Post"
                                                      predicate:predicate];
      if (chat) {
        chat.elapsedTime = [CommonUtils getElapsedTime:postDate];
        continue;
      }

      chat = (Post *)[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:MOC];
      chat.postId = @(chartId);
      chat.elapsedTime = [CommonUtils getElapsedTime:postDate];
      
      NSArray *msgs = [el elementsForName:@"message"];
      if ([msgs count] > 0) {
        chat.content = [CommonUtils decodeAndReplacePlusForText:[msgs.lastObject stringValue]];
      }
      
      NSArray *isWrites = [el elementsForName:@"is_current_user_write"];
      if ([isWrites count] > 0) {
        NSInteger flag = [[isWrites.lastObject stringValue] intValue];
        if (flag == 1) {
          chat.authorId = [AppManager instance].personId;
          chat.authorPicUrl = [AppManager instance].userImgUrl;
        } else {
          chat.authorId = alumni.personId;
          chat.authorPicUrl = alumni.imageUrl;
        }

      }
    }
  }

  return SAVE_MOC(MOC);
}

+ (BOOL)handleChatList:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  NSArray *respCodes = [respDoc nodesForXPath:@"//response/code"
                                        error:nil];
  
  if (RESP_OK == [[[respCodes lastObject] stringValue] intValue]) {
    
    NSArray *newsList = [respDoc nodesForXPath:@"//prs/pr" error:nil];
    for (CXMLElement *el in newsList) {
      
      NSArray *chartIds = [el elementsForName:@"id"];
      long long chartId = 0;
      if ([chartIds count] > 0) {
        chartId = [[[chartIds lastObject] stringValue] longLongValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(chartId == %lld)", chartId];
      Chat *isExist = (Chat*)[CommonUtils hasSameObjectAlready:MOC
                                                    entityName:@"Chat"
                                                  sortDescKeys:nil
                                                     predicate:predicate];
      if (isExist) {
        continue;
      }
      
      Chat *chart = (Chat*)[NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:MOC];
      chart.chartId = @(chartId);
      
      NSArray *dates = [el elementsForName:@"create_time"];
      if ([dates count] > 0) {
        chart.createTime = [[dates lastObject] stringValue];
      }
      
      NSArray *readTimes = [el elementsForName:@"read_time"];
      if ([readTimes count] > 0) {
        chart.readTime = [[readTimes lastObject] stringValue];
      }
      
      NSArray *msgs = [el elementsForName:@"message"];
      if ([msgs count] > 0) {
        chart.msg = [[[msgs lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      
      NSArray *isWrites = [el elementsForName:@"is_current_user_write"];
      if ([isWrites count] > 0) {
        BOOL isWrite = [[isWrites.lastObject stringValue] intValue] == 1 ? YES : NO;
        chart.isWrite = @(isWrite);
      }
      
      NSArray *status = [el elementsForName:@"status"];
      if ([status count] > 0) {
        chart.status = @([[[status lastObject] stringValue] intValue]);
      }
      
      NSArray *orders = [el elementsForName:@"orders"];
      if ([orders count] > 0) {
        chart.orders = @([[[orders lastObject] stringValue] longLongValue]);
      }
    }
  }
  
  if ([CommonUtils saveMOCChange:MOC]) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark - load home page item group
+ (BOOL)handleHomeGroup:(NSManagedObjectContext *)MOC
{
  
  /*
   [CommonUtils doDelete:MOC entityName:@"HomeGroup"];
   
   NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:LocaleStringForKey(NSVideoTitle, nil), LocaleStringForKey(NSShakeTitle, nil), LocaleStringForKey(NSShareSoftTitle, nil), LocaleStringForKey(NSSurveyTitle, nil), nil];
   NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"video.png", @"shake.png", @"shareApp.png", @"survey.png", nil];
   
   int size = [nameArray count];
   for (int i=0; i<size; i++) {
   HomeGroup *group = (HomeGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeGroup"
   inManagedObjectContext:MOC];
   group.groupId = [NSNumber numberWithInt:i];
   group.groupName = [nameArray objectAtIndex:i];
   group.type = [NSNumber numberWithInt:0];
   group.sortKey = [NSNumber numberWithInt:i];
   group.imageUrl = [imgArray objectAtIndex:i];
   }
   
   if ([CommonUtils saveMOCChange:MOC]) {
   [AppManager instance].isLoadHomeGroupDataOK = YES;
   return YES;
   } else {
   [AppManager instance].isLoadHomeGroupDataOK = NO;
   return NO;
   }
   */
  
  [CommonUtils doDelete:MOC entityName:@"HomeGroup"];
  
  NSMutableArray *nameArray = [NSMutableArray arrayWithObjects:LocaleStringForKey(NSNearbyTitle, nil), LocaleStringForKey(NSShakeNameCardTitle, nil), LocaleStringForKey(NSVideoTitle, nil),  LocaleStringForKey(NSShareSoftTitle, nil), LocaleStringForKey(NSSurveyTitle, nil), nil];
  
  NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"shake.png", @"shakeNameCard.png", @"video.png", @"shareApp.png", @"survey.png", nil];
  
  int size = [nameArray count];
  
  for (int i=0; i<size; i++) {
    
    HomeGroup *group = (HomeGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"HomeGroup"
                                                                  inManagedObjectContext:MOC];
    
    group.groupId = @(i);
    group.groupName = nameArray[i];
    group.type = @0;
    group.sortKey = @(i);
    group.imageUrl = imgArray[i];
  }
  
  if (SAVE_MOC(MOC)) {
    [AppManager instance].isLoadHomeGroupDataOK = YES;
    return YES;
  } else {
    [AppManager instance].isLoadHomeGroupDataOK = NO;
    return NO;
  }
  
}

#pragma mark - load service category
+ (BOOL)handleLoadServiceCategory:(CXMLDocument *)respDoc
                              MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *groupNodes = [respDoc nodesForXPath:@"//category"
                                           error:nil];
    
    for (CXMLElement *groupEl in groupNodes) {
      long long groupId = 0;
      NSArray *groupIds = [groupEl elementsForName:@"category_id"];
      if (groupIds.count > 0) {
        groupId = [[groupIds.lastObject stringValue] longLongValue];
        
        if (groupId == -99) {
          // ignore the 'Favorite Group'
          continue;
        }
      }
      
      NSArray *profileImgUrls = [groupEl elementsForName:@"profile_image_url"];
      NSString *picUrl = nil;
      if ([profileImgUrls count]) {
        picUrl = [[profileImgUrls lastObject] stringValue];
      }
      
      NSArray *sortKeys = [groupEl elementsForName:@"sorts"];
      NSInteger sortKey = 0;
      if (sortKeys.count > 0) {
        sortKey = [[sortKeys.lastObject stringValue] intValue];
      }
      
      NSArray *tipTitles = [groupEl elementsForName:@"tips"];
      NSString *tipTitle = nil;
      if (tipTitles.count > 0) {
        tipTitle = [CommonUtils decodeAndReplacePlusForText:[tipTitles.lastObject stringValue]];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupId == %lld", groupId];
      ItemGroup *checkPoint = (ItemGroup *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                     entityName:@"ItemGroup"
                                                                      predicate:predicate];
      if (checkPoint) {
        checkPoint.imageUrl = picUrl;
        checkPoint.sortKey = @(sortKey);
        checkPoint.firstTipsTitle = tipTitle;
        continue;
      }
      
      ItemGroup *group = (ItemGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"ItemGroup"
                                                                    inManagedObjectContext:MOC];
      group.groupId = @(groupId);
      group.sortKey = @(sortKey);
      group.usageType = @(SERVICE_USAGE_TY);
      group.imageUrl = picUrl;
      group.firstTipsTitle = tipTitle;
      
      NSArray *groupNames = [groupEl elementsForName:@"name"];
      if (groupNames.count > 0) {
        group.groupName = [CommonUtils decodeAndReplacePlusForText:[groupNames.lastObject stringValue]];
      }
    }
    
    ////// begin of DEBUG ///////
    DELETE_OBJS_FROM_MOC(MOC, @"ItemGroup", ([NSPredicate predicateWithFormat:@"((groupId == %lld) AND (usageType == %d))", PEOPLE_CATEGORY_ID, SERVICE_USAGE_TY]));
    ItemGroup *group = (ItemGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"ItemGroup"
                                                                  inManagedObjectContext:MOC];
    group.groupId = [NSNumber numberWithLongLong:PEOPLE_CATEGORY_ID];
    group.sortKey = @10;
    group.usageType = @(SERVICE_USAGE_TY);
    group.groupName = LocaleStringForKey(NSNearbyAlumnusTitle, nil);
    ////// end of DEBUG ///////
    
    return [WXWCoreDataUtils saveMOCChange:MOC];
  } else {
    return NO;
  }
}

#pragma mark - load service item and provider
+ (BOOL)handleLoadServiceContentAlbumPhoto:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    NSArray *photos = [respDoc nodesForXPath:@"//photo" error:nil];
    for (CXMLElement *photoEl in photos) {
      NSArray *thumbnailUrls = [photoEl elementsForName:@"thumbnail_pic"];
      NSString *thumbnailUrl = nil;
      if (thumbnailUrls.count > 0) {
        thumbnailUrl = [thumbnailUrls.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(thumbnailUrl == %@)", thumbnailUrl];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"AlbumPhoto"
                              predicate:predicate]) {
        continue;
      }
      
      AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription insertNewObjectForEntityForName:@"AlbumPhoto"
                                                                      inManagedObjectContext:MOC];
      photo.thumbnailUrl = thumbnailUrl;
      
      NSArray *titles = [photoEl elementsForName:@"title"];
      if (titles.count > 0) {
        photo.caption = [CommonUtils decodeAndReplacePlusForText:[titles.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [photoEl elementsForName:@"bmiddle_pic"];
      if (imageUrls.count > 0) {
        photo.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *authorIds = [photoEl elementsForName:@"author_id"];
      if (authorIds.count > 0) {
        photo.authorId = @([[authorIds.lastObject stringValue] longLongValue]);
      }
      
      NSArray *authorNames = [photoEl elementsForName:@"author_name"];
      if (authorNames.count > 0) {
        photo.authorName = [authorNames.lastObject stringValue];
      }
      
      NSArray *itemIds = [photoEl elementsForName:@"item_id"];
      if (itemIds.count > 0) {
        photo.itemId = @([[itemIds.lastObject stringValue] longLongValue]);
      }
      
      NSArray *timestamps = [photoEl elementsForName:@"create_time"];
      NSTimeInterval timestamp = 0.0f;
      if (timestamps.count > 0) {
        timestamp = [[timestamps.lastObject stringValue] doubleValue];
        photo.timestamp = @(timestamp);
      }
      NSDate *date = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      photo.date = [CommonUtils simpleFormatDate:date secondAccuracy:YES];
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - recommended items for nearby service
+ (BOOL)handleLoadRecommendedItems:(CXMLDocument *)respDoc
                               MOC:(NSManagedObjectContext *)MOC {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *items = [respDoc nodesForXPath:@"//items/item" error:nil];
    for (CXMLElement *itemEl in items) {
      NSArray *itemIds = [itemEl elementsForName:@"item_id"];
      long long itemId = 0ll;
      if (itemIds.count > 0) {
        itemId = [itemIds.lastObject stringValue].longLongValue;
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", itemId];
      RecommendedItem *item = (RecommendedItem *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                           entityName:@"RecommendedItem"
                                                                            predicate:predicate];
      if (nil == item) {
        item = (RecommendedItem *)[NSEntityDescription insertNewObjectForEntityForName:@"RecommendedItem"
                                                                inManagedObjectContext:MOC];
      }
      
      item.itemId = @(itemId);
      
      NSArray *serviceItemIds = [itemEl elementsForName:@"service_id"];
      if (serviceItemIds) {
        item.serviceItemId = @([serviceItemIds.lastObject stringValue].longLongValue);
      }
      
      predicate = [NSPredicate predicateWithFormat:@"(itemId == %@)", item.serviceItemId];
      ServiceItem *serviceItem = (ServiceItem *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                                          entityName:@"ServiceItem"
                                                                           predicate:predicate];
      if (serviceItem) {
        item.serviceItem = serviceItem;
      }
      
      NSArray *enNames = [itemEl elementsForName:@"name_en"];
      if (enNames.count > 0) {
        item.enName = [CommonUtils decodeAndReplacePlusForText:[enNames.lastObject stringValue]];
      }
      
      NSArray *cnNames = [itemEl elementsForName:@"name"];
      if (cnNames.count > 0) {
        item.cnName = [CommonUtils decodeAndReplacePlusForText:[cnNames.lastObject stringValue]];
      }
      
      NSArray *bios = [itemEl elementsForName:@"desc"];
      if (bios.count > 0) {
        item.intro = [CommonUtils decodeAndReplacePlusForText:[bios.lastObject stringValue]];
      }
      
      NSArray *likeCounts = [itemEl elementsForName:@"like_count"];
      if (likeCounts.count > 0) {
        item.likeCount = @([likeCounts.lastObject stringValue].intValue);
      }
      
      NSArray *likedStatus = [itemEl elementsForName:@"is_like_by_current_user"];
      if (likedStatus.count > 0) {
        item.liked = [NSNumber numberWithBool:([likedStatus.lastObject stringValue].intValue == 1 ? YES : NO)];
      }
      
      NSArray *imageUrls = [itemEl elementsForName:@"image"];
      if (imageUrls.count > 0) {
        item.imageUrl = [imageUrls.lastObject stringValue];
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}


#pragma mark - alumni network
+ (BOOL)handleWithMeConnection:(CXMLDocument *)respDoc
                           MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    // TODO
    
    return SAVE_MOC(MOC);
  } else {
    
    return NO;
  }
}

+ (BOOL)parserRecommendAlumnusForEndAlumniId:(long long)endAlumniId
                                     xmlData:(NSData *)xmlData
                                         MOC:(NSManagedObjectContext *)MOC
                           connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                         url:(NSString *)url {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_ALL_KNOWN_ALUMNUS_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSArray *alumniList = [doc nodesForXPath:@"//content" error:nil];
    
    int alumniIndex = 0;
    for (CXMLElement *el in alumniList) {
      
      NSArray *personIds = [el elementsForName:@"personId"];
      NSString *referenceId = [[personIds lastObject] stringValue];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", referenceId];
      RecommendAlumni *alumni = (RecommendAlumni *)[CommonUtils hasSameObjectAlready:MOC
                                                                          entityName:@"RecommendAlumni"
                                                                        sortDescKeys:nil
                                                                           predicate:predicate];
      
      if (nil == alumni) {
        alumni = (RecommendAlumni *)[NSEntityDescription insertNewObjectForEntityForName:@"RecommendAlumni"
                                                                  inManagedObjectContext:MOC];
      }
      
      [self parserAlumniInfo:el
                    personId:referenceId
                      alumni:alumni
                         MOC:MOC
                    itemType:ALUMNI_USER_TY
                       index:alumniIndex];
      
      NSPredicate *linkPredicate = [NSPredicate predicateWithFormat:@"(startAlumniId == %@) AND (endAlumniId == %lld) AND (referenceId == %@)", [AppManager instance].personId, endAlumniId, referenceId];
      
      ReferenceRelationship *link = (ReferenceRelationship *)[WXWCoreDataUtils objectCountsFromMOC:MOC
                                                                                        entityName:@"ReferenceRelationship"
                                                                                         predicate:linkPredicate];
      if (nil == link) {
        link = (ReferenceRelationship *)[NSEntityDescription insertNewObjectForEntityForName:@"ReferenceRelationship"
                                                                      inManagedObjectContext:MOC];
        link.startAlumniId = @([AppManager instance].personId.longLongValue);
        link.endAlumniId = @(endAlumniId);
        link.referenceId = @(referenceId.longLongValue);
        
        [alumni addLinksObject:link];
      }
      
      alumniIndex++;
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

+ (BOOL)handleConnectAlumnusCount:(CXMLDocument *)respDoc {
  if ([self parserResponseCode:respDoc] == HTTP_RESP_OK) {
    
    NSArray *attractiveList = [respDoc nodesForXPath:@"//response/want_konw_counts" error:nil];
    if (attractiveList.count > 0) {
      [AppManager instance].wantToKnowAlumnusCount = @([attractiveList.lastObject stringValue].intValue);
    }
    
    NSArray *knownList = [respDoc nodesForXPath:@"//response/already_konw_counts" error:nil];
    if (knownList.count > 0) {
      [AppManager instance].knownAlumnusCount = @([knownList.lastObject stringValue].intValue);
    }
    
    return YES;
    
  } else {
    return NO;
  }
}

+ (void)handleGroupInforForAlumniId:(long long)alumniId
                             groups:(NSArray *)groups
                                MOC:(NSManagedObjectContext *)MOC
                needParserCountInfo:(BOOL)needParserCountInfo {
  for (CXMLElement *el in groups) {
    
    int groupId = 0;
    NSArray *ids = [el elementsForName:@"id"];
    if ([ids count] > 0) {
      groupId = [[[ids lastObject] stringValue] intValue];
    }
    
    BOOL existing = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d) AND (alumniId == %lld)",
                              groupId, alumniId];
    JoinedGroup *group = (JoinedGroup *)[CommonUtils hasSameObjectAlready:MOC
                                                               entityName:@"JoinedGroup"
                                                             sortDescKeys:nil
                                                                predicate:predicate];
    if (group) {
      existing = YES;
    } else {
      group = (JoinedGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"JoinedGroup"
                                                           inManagedObjectContext:MOC];
      group.clubId = @(groupId);
      group.alumniId = @(alumniId);
    }
    
    [self parserGroupInfo:el MOC:MOC group:group existing:existing needParserCountInfo:needParserCountInfo];
  }
  
}

+ (BOOL)parserJoinedGroupForAlumniId:(long long)alumniId
                             xmlData:(NSData *)xmlData
                                 MOC:(NSManagedObjectContext *)MOC
                   connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                 url:(NSString *)url {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:LOAD_JOINED_GROUPS_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSArray *groups = [doc nodesForXPath:@"//host" error:nil];
    [self handleGroupInforForAlumniId:alumniId groups:groups MOC:MOC needParserCountInfo:YES];
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)parseMemberForGroupId:(long long)groupId
                      xmlData:(NSData *)xmlData
                          MOC:(NSManagedObjectContext *)MOC
            connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                          url:(NSString *)url {
  
  CXMLDocument *doc = nil;
  
  if (![self parserResponseNode:xmlData
                            doc:&doc
              connectorDelegate:connectorDelegate
                            url:url
                           type:CLUB_MANAGE_USER_TY]) {
    return NO;
  }
  
  if ([self parserResponseCode:doc] == HTTP_RESP_OK) {
    
    NSArray *alumniList = [doc nodesForXPath:@"//content" error:nil];
    
    NSInteger alumniIndex = 0;
    
    for (CXMLElement *el in alumniList) {
      
      NSArray *loginStatus = [el elementsForName:@"loginStatus"];
      if ([loginStatus count] > 0) {
        if ([[[loginStatus lastObject] stringValue] isEqualToString:@"invalid"]) {
          [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
          [AppManager instance].needPrompt = NO;
          return NO;
        }
      }
      
      NSArray *personIds = [el elementsForName:@"personId"];
      NSString *personId = [[personIds lastObject] stringValue];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@) AND (groupId == %lld)",
                                personId, groupId];
      Alumni *alumni = (Alumni *)[CommonUtils hasSameObjectAlready:MOC
                                                        entityName:@"Alumni"
                                                      sortDescKeys:nil
                                                         predicate:predicate];
      
      if (alumni) {
        alumni.containerType = [NSNumber numberWithInt:ALUMNI_USER_TY];
      } else {
        alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni" inManagedObjectContext:MOC];
      }
      
      [self parserAlumniInfo:el
                    personId:personId
                      alumni:alumni
                         MOC:MOC
                    itemType:ALUMNI_USER_TY
                       index:alumniIndex];
      
      alumni.groupId = @(groupId);
      
      alumniIndex++;
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

#pragma mark - enterprise

+ (Club *)parserBizGroupInfo:(CXMLElement *)el
                       group:(Club *)group
                         MOC:(NSManagedObjectContext *)MOC
                    existing:(BOOL)existing {
  
  NSArray *lastPostAuthor = [el elementsForName:@"last_post_author"];
  NSString *postAuthor = NULL_PARAM_VALUE;
  if ([lastPostAuthor count] > 0) {
    postAuthor = [[lastPostAuthor lastObject] stringValue];
  }
  
  NSArray *lastPostMessage = [el elementsForName:@"last_post_message"];
  NSString *postDesc = NULL_PARAM_VALUE;
  if ([lastPostMessage count] > 0) {
    postDesc = [[lastPostMessage lastObject] stringValue];
  }
  
  NSTimeInterval timestamp = 0;
  NSArray *times = [el elementsForName:@"last_post_time"];
  NSString *postTime = nil;
  if ([times count] > 0) {
    timestamp = [[[times lastObject] stringValue] doubleValue];
    if (timestamp > 0) {
      NSDate *mDate = nil;
      mDate = [CommonUtils convertDateTimeFromUnixTS:timestamp];
      postTime = [CommonUtils getElapsedTime:mDate];
    }
  }
  
  NSArray *allowPosts = [el elementsForName:@"allow_post"];
  BOOL allowPost = YES;
  if (allowPosts.count > 0) {
    NSInteger allowFlag = 1;
    allowFlag = [allowPosts.lastObject stringValue].intValue;
    if (allowFlag == 0) {
      allowPost = NO;
    }
  }
  
  NSArray *forbidPostReasons = [el elementsForName:@"authority_msg"];
  NSString *forbidPostreason = nil;
  if (forbidPostReasons.count > 0) {
    forbidPostreason = [WXWCommonUtils decodeAndReplacePlusForText:[forbidPostReasons.lastObject stringValue]];
  }
  
  NSArray *allowJoins = [el elementsForName:@"allow_join"];
  BOOL allowJoin = YES;
  if (allowJoins.count > 0) {
    NSInteger allowFlag = 1;
    allowFlag = [allowJoins.lastObject stringValue].intValue;
    if (allowFlag == 0) {
      allowJoin = NO;
    }
  }
  
  /*
   NSArray *forbidJoinReasons = [el elementsForName:@"join_msg"];
   NSString *forbidJoinreason = nil;
   if (forbidJoinReasons.count > 0) {
   forbidJoinreason = [WXWCommonUtils decodeAndReplacePlusForText:[forbidJoinReasons.lastObject stringValue]];
   }
   */
  
  NSArray *allowQuits = [el elementsForName:@"allow_quit"];
  BOOL allowQuit = YES;
  if (allowQuits.count > 0) {
    NSInteger allowFlag = 1;
    allowFlag = [allowQuits.lastObject stringValue].intValue;
    if (allowFlag == 0) {
      allowQuit = NO;
    }
  }
  
  /*
   NSArray *forbidQuitReasons = [el elementsForName:@"quit_msg"];
   NSString *forbidQuitreason = nil;
   if (forbidQuitReasons.count > 0) {
   forbidQuitreason = [WXWCommonUtils decodeAndReplacePlusForText:[forbidQuitReasons.lastObject stringValue]];
   }
   */
  
  group.postTime = postTime;
  group.postDesc = postDesc;
  group.postAuthor = postAuthor;
  group.allowPost = @(allowPost);
  group.forbidPostReason = forbidPostreason;
  //group.allowJoin = @(allowJoin);
  //group.forbidJoinReason = forbidJoinreason;
  //group.allowQuit = @(allowQuit);
  //group.forbidQuitReason = forbidQuitreason;
  
  NSData *postInfoData = nil;
  if (postAuthor.length > 0 && postDesc.length > 0) {
    NSString *postInfoContent = nil;
    NSAttributedString *attPostInfoContent = nil;
    postInfoContent = [NSString stringWithFormat:@"<font face=\"%@\"><font size=\"13\"><font color=\"98-87-87\">%@: <font color=\"130-130-140\">%@", SYS_FONT_NAME, postAuthor, postDesc];
    
    CoreTextMarkupParser *postInfoParser = [[[CoreTextMarkupParser alloc] initWithLineBreakMode:kCTLineBreakByTruncatingTail] autorelease];
    attPostInfoContent = [postInfoParser attrStringFromMarkup:postInfoContent];
    
    postInfoData = [attPostInfoContent convertToData];
  }
  
  group.postInfoContentData = postInfoData;
  
  if (existing) {
    return group;
  }
  
  NSArray *names = [el elementsForName:@"group_name"];
  if (names.count > 0) {
    group.clubName = [CommonUtils decodeAndReplacePlusForText:[names.lastObject stringValue]];
  }
  
  NSArray *types = [el elementsForName:@"type_id"];
  if ([types count] > 0) {
    group.clubType = [[[types lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  }
  
  NSArray *orders = [el elementsForName:@"orders"];
  if ([orders count] > 0) {
    NSInteger order = [[[orders lastObject] stringValue] intValue];
    group.showOrder = @(order);
  }
  
  NSArray *iconUrls = [el elementsForName:@"image_url"];
  if (iconUrls.count > 0) {
    group.iconUrl = [iconUrls.lastObject stringValue];
  }
  
  return group;
}

+ (BOOL)handleBizGroups:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    // parser biz groups
    NSArray *bizGroups = [respDoc nodesForXPath:@"//bizs/group" error:nil];
    if (0 == bizGroups.count) {
      debugLog(@"no biz discussion group loaded");
    }
    for (CXMLElement *el in bizGroups) {
      
      int groupId = 0;
      NSArray *ids = [el elementsForName:@"group_id"];
      if ([ids count] > 0) {
        groupId = [[[ids lastObject] stringValue] intValue];
      }
      
      BOOL existing = NO;
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d) AND (usageType == %d)", groupId, BIZ_DISCUSS_USAGE_GP_TY];
      Club *bizGroup = (Club *)[CommonUtils hasSameObjectAlready:MOC
                                                      entityName:@"Club"
                                                    sortDescKeys:nil
                                                       predicate:predicate];
      if (bizGroup) {
        existing = YES;
      } else {
        bizGroup = (Club *)[NSEntityDescription insertNewObjectForEntityForName:@"Club"
                                                         inManagedObjectContext:MOC];
        bizGroup.clubId = @(groupId);
        bizGroup.usageType = @(BIZ_DISCUSS_USAGE_GP_TY);
      }
      
      [self parserBizGroupInfo:el group:bizGroup MOC:MOC existing:existing];
    }
    
    
    // parser club groups
    NSArray *clubGroups = [respDoc nodesForXPath:@"//hosts/group" error:nil];
    if (0 == clubGroups.count) {
      debugLog(@"no club group loaded");
    }
    for (CXMLElement *el in clubGroups) {
      
      int groupId = 0;
      NSArray *ids = [el elementsForName:@"group_id"];
      if ([ids count] > 0) {
        groupId = [[[ids lastObject] stringValue] intValue];
      }
      
      BOOL existing = NO;
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d) AND (alumniId == %lld) AND (usageType == %d)",
                                groupId, [AppManager instance].personId.longLongValue, BIZ_JOINED_USAGE_GP_TY];
      JoinedGroup *joinedGroup = (JoinedGroup *)[CommonUtils hasSameObjectAlready:MOC
                                                                       entityName:@"JoinedGroup"
                                                                     sortDescKeys:nil
                                                                        predicate:predicate];
      if (joinedGroup) {
        existing = YES;
      } else {
        joinedGroup = (JoinedGroup *)[NSEntityDescription insertNewObjectForEntityForName:@"JoinedGroup"
                                                                   inManagedObjectContext:MOC];
        joinedGroup.clubId = @(groupId);
        joinedGroup.alumniId = @([AppManager instance].personId.longLongValue);
        joinedGroup.usageType = @(BIZ_JOINED_USAGE_GP_TY);
      }
      
      [self parserBizGroupInfo:el group:joinedGroup MOC:MOC existing:existing];
    }
    
    // parser popular groups
    NSArray *popularGroups = [respDoc nodesForXPath:@"//hot_hosts/group" error:nil];
    if (0 == popularGroups.count) {
      debugLog(@"no popular group loaded");
    }
    for (CXMLElement *el in popularGroups) {
      int groupId = 0;
      
      NSArray *ids = [el elementsForName:@"group_id"];
      if ([ids count] > 0) {
        groupId = [[[ids lastObject] stringValue] intValue];
      }
      
      BOOL existing = NO;
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %d) AND (usageType == %d)", groupId, BIZ_POPULAR_USAGE_GP_TY];
      Club *popularGroup = (Club *)[CommonUtils hasSameObjectAlready:MOC
                                                          entityName:@"Club"
                                                        sortDescKeys:nil
                                                           predicate:predicate];
      if (popularGroup) {
        existing = YES;
      } else {
        popularGroup = (Club *)[NSEntityDescription insertNewObjectForEntityForName:@"Club"
                                                             inManagedObjectContext:MOC];
        popularGroup.clubId = @(groupId);
        popularGroup.usageType = @(BIZ_POPULAR_USAGE_GP_TY);
      }
      
      [self parserBizGroupInfo:el group:popularGroup MOC:MOC existing:existing];
      
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - homepage
+ (BOOL)handleHomepageInfo:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  if ([XMLParser parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *comingEventCounts = [respDoc nodesForXPath:@"//response/unplayed_event_counts" error:nil];
    if (comingEventCounts.count > 0) {
      [AppManager instance].comingEventCount = [comingEventCounts.lastObject stringValue].intValue;
    }
    
    NSArray *enterpriseSolutionNames = [respDoc nodesForXPath:@"//response/enterprise_solution_title" error:nil];
    if (enterpriseSolutionNames.count > 0) {
      NSString *name = [CommonUtils decodeAndReplacePlusForText:[enterpriseSolutionNames.lastObject stringValue]];
      [CommonUtils saveStringValueToLocal:name
                                      key:ENTERPRISE_SOLUTION_NAME_LOCAL_KEY];
    }
    
    NSArray *hasNewSolutions = [respDoc nodesForXPath:@"//response/has_new_enterprise_solution" error:nil];
    if (hasNewSolutions.count > 0) {
      NSInteger flag = [hasNewSolutions.lastObject stringValue].intValue;
      [AppManager instance].hasNewEnterpriseSolution = (flag == 1 ? YES : NO);
    }
    
    // parser slogan list
    NSArray *sloganList = [respDoc nodesForXPath:@"//slogans/slogan" error:nil];
    for (CXMLElement *el in sloganList) {
      NSArray *sloganIds = [el elementsForName:@"id"];
      NSString *sloganId = NULL_PARAM_VALUE;
      if (sloganIds.count > 0) {
        sloganId = [sloganIds.lastObject stringValue];
      }
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sloganId == %@)", sloganId];
      if ([WXWCoreDataUtils objectInMOC:MOC entityName:@"Slogan" predicate:predicate]) {
        continue;
      }
      
      Slogan *slogan = (Slogan *)[NSEntityDescription insertNewObjectForEntityForName:@"Slogan"
                                                               inManagedObjectContext:MOC];
      slogan.sloganId = sloganId;
      
      NSArray *sloganContents = [el elementsForName:@"content"];
      if (sloganContents.count > 0) {
        slogan.content = [WXWCommonUtils decodeAndReplacePlusForText:[sloganContents.lastObject stringValue]];
      }
    }
    
    // parser news
    NSArray *newsList = [respDoc nodesForXPath:@"//newsList/news"
                                         error:nil];
    for (CXMLElement *el in newsList) {
      NSArray *newsIds = [el elementsForName:@"id"];
      long long newsId = [[newsIds.lastObject stringValue] longLongValue];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"News"
                              predicate:[NSPredicate predicateWithFormat:@"(newsId == %lld)", newsIds]]) {
        continue;
      }
      
      News *news = (News *)[NSEntityDescription insertNewObjectForEntityForName:@"News"
                                                         inManagedObjectContext:MOC];
      news.newsId = @(newsId);
      
      NSArray *contentUrls = [el elementsForName:@"contentUrl"];
      if (contentUrls.count > 0) {
        news.url = [contentUrls.lastObject stringValue];
      }
      
      NSArray *titles = [el elementsForName:@"title"];
      if (titles.count > 0) {
        news.title = [WXWCommonUtils decodeAndReplacePlusForText:[titles.lastObject stringValue]];
      }
      
      NSArray *imageUrls = [el elementsForName:@"bmiddle_pic"];
      if (imageUrls.count > 0) {
        news.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      news.type = @(FOR_HOMEPAGE_NEWS_TY);
    }
    
    // parser group payment
    NSArray *groupItemCounts = [respDoc nodesForXPath:@"//response/host_order_counts"
                                                error:nil];
    [AppManager instance].groupPaymentItemCount = [groupItemCounts.lastObject stringValue].intValue;
    
    if ([AppManager instance].groupPaymentItemCount > 0) {
      
      NSString *baseInfo = [NSString stringWithFormat:@"<font face=\"%@\"><font size=\"12\"><font color=\"255-255-255\">%@<font size=\"16\"><font color=\"251-217-67\"> %d <font size=\"12\"><font color=\"255-255-255\">%@",
                            SYS_FONT_NAME,
                            LocaleStringForKey(NSYouHaveMsg, nil),
                            [AppManager instance].groupPaymentItemCount,
                            LocaleStringForKey(NSGroupPaymentMsg, nil)];
      CoreTextMarkupParser *baseInfoParser = [[[CoreTextMarkupParser alloc] initWithLineBreakMode:kCTLineBreakByWordWrapping] autorelease];
      NSAttributedString *attBaseInfo = [baseInfoParser attrStringFromMarkup:baseInfo];
      [AppManager instance].groupPaymentContent = [attBaseInfo convertToData];
    }
    
    NSArray *groupItems = [respDoc nodesForXPath:@"//host_orders/order" error:nil];
    for (CXMLElement *el in groupItems) {
      NSArray *messageIds = [el elementsForName:@"order_id"];
      NSString *messageId = nil;
      if (messageIds.count > 0) {
        messageId = [messageIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId == %@) AND (type == %d)", messageId, GROUP_PAYMENT_MSG_TY];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Messages"
                              predicate:predicate]) {
        continue;
      }
      
      Messages *message = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:MOC];
      message.messageId = messageId;
      message.type = @(GROUP_PAYMENT_MSG_TY);
      message.paymentDone = @(NO);
      
      NSArray *descs = [el elementsForName:@"order_desc"];
      if (descs.count > 0) {
        message.content = [WXWCommonUtils decodeAndReplacePlusForText:[descs.lastObject stringValue]];
      }
      
      NSArray *urls = [el elementsForName:@"content_url"];
      if (urls.count > 0) {
        message.url = [urls.lastObject stringValue];
      }
      
    }
    
    // parser event payment
    NSArray *eventItemCounts = [respDoc nodesForXPath:@"//response/event_order_counts"
                                                error:nil];
    
    [AppManager instance].eventPaymentItemCount = [eventItemCounts.lastObject stringValue].intValue;
    if ([AppManager instance].eventPaymentItemCount > 0) {
      NSString *baseInfo = [NSString stringWithFormat:@"<font face=\"%@\"><font size=\"12\"><font color=\"255-255-255\">%@<font size=\"16\"><font color=\"251-217-67\"> %d <font size=\"12\"><font color=\"255-255-255\">%@",
                            SYS_FONT_NAME,
                            LocaleStringForKey(NSYouHaveMsg, nil),
                            [AppManager instance].eventPaymentItemCount,
                            LocaleStringForKey(NSEventPaymentMsg, nil)];
      CoreTextMarkupParser *baseInfoParser = [[[CoreTextMarkupParser alloc] initWithLineBreakMode:kCTLineBreakByWordWrapping] autorelease];
      NSAttributedString *attBaseInfo = [baseInfoParser attrStringFromMarkup:baseInfo];
      [AppManager instance].eventPaymentContent = [attBaseInfo convertToData];
    }
    
    NSArray *eventItems = [respDoc nodesForXPath:@"//event_orders/order" error:nil];
    for (CXMLElement *el in eventItems) {
      NSArray *messageIds = [el elementsForName:@"order_id"];
      NSString *messageId = nil;
      if (messageIds.count > 0) {
        messageId = [messageIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId == %@) AND (type == %d)", messageId, EVENT_PAYMENT_MSG_TY];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Messages"
                              predicate:predicate]) {
        continue;
      }
      
      Messages *message = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:MOC];
      message.messageId = messageId;
      message.type = @(EVENT_PAYMENT_MSG_TY);
      message.paymentDone = @(NO);
      
      NSArray *descs = [el elementsForName:@"order_desc"];
      if (descs.count > 0) {
        message.content = [WXWCommonUtils decodeAndReplacePlusForText:[descs.lastObject stringValue]];
      }
      
      NSArray *urls = [el elementsForName:@"content_url"];
      if (urls.count > 0) {
        message.url = [urls.lastObject stringValue];
      }
      
    }
    
    // parse app advertising message
    NSArray *advMessages = [respDoc nodesForXPath:@"//response/messages/message" error:nil];
    for (CXMLElement *el in advMessages) {
      NSArray *messageIds = [el elementsForName:@"message_id"];
      NSString *messageId = nil;
      if (messageIds.count > 0) {
        messageId = [messageIds.lastObject stringValue];
      }
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId == %@) AND (type == %d)", messageId, SYSTEM_MSG_TY];
      if ([WXWCoreDataUtils objectInMOC:MOC
                             entityName:@"Messages"
                              predicate:predicate]) {
        continue;
      }
      
      Messages *message = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:MOC];
      message.messageId = messageId;
      message.type = @(SYSTEM_MSG_TY);
      
      NSArray *descs = [el elementsForName:@"message_text"];
      if (descs.count > 0) {
        message.content = [WXWCommonUtils decodeAndReplacePlusForText:[descs.lastObject stringValue]];
      }
      
      NSArray *urls = [el elementsForName:@"content_url"];
      if (urls.count > 0) {
        message.url = [urls.lastObject stringValue];
      }
      
    }
    
    return SAVE_MOC(MOC);
    
  } else {
    return NO;
  }
}

#pragma mark - video

+ (BOOL)parserVideos:(CXMLDocument *)respDoc
                 MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *videos = [respDoc nodesForXPath:@"//videos/video" error:nil];
    for (CXMLElement *el in videos) {
      NSArray *ids = [el elementsForName:@"id"];
      int videoId = [[ids.lastObject stringValue] intValue];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(videoId == %d)", videoId];
      Video *isExist = (Video *)[CommonUtils hasSameObjectAlready:MOC
                                                       entityName:@"Video"
                                                     sortDescKeys:nil
                                                        predicate:predicate];
      if (isExist) {
        continue;
      }
      
      Video *video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:@"Video"
                                                            inManagedObjectContext:MOC];
      
      video.videoId = @(videoId);
      
      NSArray *videoNames = [el elementsForName:@"title"];
      if ([videoNames count] > 0) {
        video.videoName = [WXWCommonUtils decodeAndReplacePlusForText:[videoNames.lastObject stringValue]];
      }
      
      NSArray *videoUrls = [el elementsForName:@"video_url"];
      if ([videoUrls count] > 0) {
        video.videoUrl = [videoUrls.lastObject stringValue];
      }
      
      NSArray *imageUrls = [el elementsForName:@"image_url"];
      if ([imageUrls count] > 0) {
        video.imageUrl = [imageUrls.lastObject stringValue];
      }
      
      NSArray *playTimes = [el elementsForName:@"duration"];
      if ([playTimes count] > 0) {
        video.duration = [playTimes.lastObject stringValue];
      }
      
      NSArray *createDates = [el elementsForName:@"create_date"];
      if ([createDates count] > 0) {
        video.createDate = [WXWCommonUtils decodeAndReplacePlusForText:[createDates.lastObject stringValue]];
      }
      
      NSArray *popularitys = [el elementsForName:@"popularity"];
      if ([popularitys count] > 0) {
        video.popularity = [popularitys.lastObject stringValue];
      }
      
      NSArray *orders = [el elementsForName:@"orders"];
      if ([orders count] > 0) {
        video.order = @([[[orders lastObject] stringValue] intValue]);
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleLatestVideos:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC {
  
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    NSArray *videos = [respDoc nodesForXPath:@"//videos/video" error:nil];
    for (CXMLElement *el in videos) {
      NSArray *ids = [el elementsForName:@"id"];
      int videoId = [[ids.lastObject stringValue] intValue];
      
      NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(videoId == %d)", videoId];
      VideoPoster *isExist = (VideoPoster *)[CommonUtils hasSameObjectAlready:MOC
                                                       entityName:@"VideoPoster"
                                                     sortDescKeys:nil
                                                        predicate:predicate];
      if (isExist) {
        continue;
      }
      
      VideoPoster *video = (VideoPoster *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoPoster"
                                                            inManagedObjectContext:MOC];
      
      video.videoId = @(videoId);
      
      NSArray *videoNames = [el elementsForName:@"title"];
      if ([videoNames count] > 0) {
        video.videoName = [WXWCommonUtils decodeAndReplacePlusForText:[videoNames.lastObject stringValue]];
      }
      
      
      NSArray *imageUrls = [el elementsForName:@"image_url"];
      if ([imageUrls count] > 0) {
        video.imageUrl = [imageUrls.lastObject stringValue];
      }
            
      NSArray *orders = [el elementsForName:@"orders"];
      if ([orders count] > 0) {
        video.order = @([[[orders lastObject] stringValue] intValue]);
      }
    }
    
    return SAVE_MOC(MOC);
  } else {
    return NO;
  }
}

+ (BOOL)handleVideoFilter:(CXMLDocument *)respDoc MOC:(NSManagedObjectContext *)MOC
{
  if ([self parserResponseCode:respDoc] == RESP_OK) {
    
    if (![AppManager instance].videoTypeList) {
      [[AppManager instance].videoTypeList removeAllObjects];
      [AppManager instance].videoTypeList = nil;
    }
    
    if (![AppManager instance].videoSortList) {
      [[AppManager instance].videoSortList removeAllObjects];
      [AppManager instance].videoSortList = nil;
    }
    
    [AppManager instance].videoTypeList = [NSMutableArray array];
    [AppManager instance].videoSortList = [NSMutableArray array];
    
    int index = 0;
    NSArray *videoTypes = [respDoc nodesForXPath:@"//video_types/video_type" error:nil];
    for (CXMLElement *el in videoTypes) {
      NSString *columnName = nil;
      NSString *columnValue = nil;
      
      NSArray *columnNames = [el elementsForName:@"type_name"];
      if ([columnNames count] > 0) {
        columnName = [[[columnNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == columnName) {
        columnName = NULL_PARAM_VALUE;
      }
      
      NSArray *columnValues = [el elementsForName:@"value"];
      if ([columnValues count] > 0) {
        columnValue = [[[columnValues lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == columnValue) {
        columnValue = NULL_PARAM_VALUE;
      }
      
      NSMutableArray *array = [NSMutableArray arrayWithObjects:columnValue,columnName, nil];
      [[AppManager instance].videoTypeList insertObject:array atIndex:index++];
    }
    
    index = 0;
    NSArray *orders = [respDoc nodesForXPath:@"//order_by_columns/order_by_column" error:nil];
    for (CXMLElement *el in orders) {
      NSString *columnName = nil;
      NSString *columnValue = nil;
      
      NSArray *columnNames = [el elementsForName:@"column_name"];
      if ([columnNames count] > 0) {
        columnName = [[[columnNames lastObject] stringValue]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == columnName) {
        columnName = NULL_PARAM_VALUE;
      }
      
      NSArray *columnValues = [el elementsForName:@"value"];
      if ([columnValues count] > 0) {
        columnValue = [[[columnValues lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      }
      if (nil == columnValue) {
        columnValue = NULL_PARAM_VALUE;
      }
      
      NSMutableArray *array = [NSMutableArray arrayWithObjects:columnValue,columnName, nil];
      [[AppManager instance].videoSortList insertObject:array atIndex:index++];
    }
    
    [AppManager instance].isLoadVedioFilterOk = YES;
    return YES;
  } else {
    [AppManager instance].isLoadVedioFilterOk = NO;
    return NO;
  }
}

#pragma mark - payment
+ (BOOL)checkPaymentResult:(CXMLDocument *)respDoc {
  if (RESP_OK == [self parserResponseCode:respDoc]) {
    return YES;
  } else {
    return NO;
  }
}

+ (void)handleClubData:(CXMLDocument *)respDoc
{
  if (![AppManager instance].supClubFilterList) {
    [[AppManager instance].supClubFilterList removeAllObjects];
    [AppManager instance].supClubFilterList = nil;
  }
  if (![AppManager instance].clubFilterList) {
    [[AppManager instance].clubFilterList removeAllObjects];
    [AppManager instance].clubFilterList = nil;
  }
  
  [AppManager instance].supClubFilterList = [NSMutableArray array];
  [AppManager instance].clubFilterList = [NSMutableArray array];
  
  int index = 0;
  NSArray *clubTypes = [respDoc nodesForXPath:@"//host_type" error:nil];
  for (CXMLElement *el in clubTypes) {
    
    NSString *typeId = nil;
    NSString *value = nil;
    NSString *name = nil;
    //NSString *order = nil;
    
    NSArray *ids = [el elementsForName:@"type_id"];
    if ([ids count] > 0) {
      typeId = [[ids lastObject] stringValue];
    }
    if (nil == typeId) {
      typeId = NULL_PARAM_VALUE;
    }
    
    NSArray *names = [el elementsForName:@"type_name"];
    if ([names count] > 0) {
      name = [[[names lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == name) {
      name = NULL_PARAM_VALUE;
    }
    
    NSArray *types = [el elementsForName:@"type_value"];
    if ([types count] > 0) {
      value = [[[types lastObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if (nil == value) {
      value = NULL_PARAM_VALUE;
    }
    
    NSMutableArray *supArray = [NSMutableArray arrayWithObjects:value, name, typeId, @(UNSELECTED_TY), nil];
    [[AppManager instance].supClubFilterList insertObject:supArray atIndex:index];
    
    NSArray *hostSubTypes = [el elementsForName:@"host_sub_types"];
    if ([hostSubTypes count] > 0) {
      NSString *contentStr = [el XMLString];
      CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:contentStr
                                                           options:0
                                                             error:nil] autorelease];
      // sub host
      NSArray *subTypeList = [doc nodesForXPath:@"//host_sub_types/host_sub_type" error:nil];
      
      int subTypes = [subTypeList count];
      
      int subIndex = 0;
      NSMutableArray *clubArray = [NSMutableArray array];
      
      if (subTypes > 0) {
        
        for (int i = 0; i < [subTypeList count]; i++) {
          NSString *subId = nil;
          NSString *subName = nil;
          NSString *subValue = nil;
          CXMLElement *el = (CXMLElement *)subTypeList[i];
          NSArray *idArray = [el elementsForName:@"sub_type_id"];
          if ([idArray count]) {
            subId = [[idArray lastObject] stringValue];
          }
          if (nil == subId) {
            subId = NULL_PARAM_VALUE;
          }
          
          NSArray *subNames = [el elementsForName:@"sub_type_name"];
          if ([subNames count]) {
            subName = [[subNames lastObject] stringValue];
          }
          if (nil == subName) {
            subName = NULL_PARAM_VALUE;
          }
          
          NSArray *subTypeVals = [el elementsForName:@"sub_type_value"];
          if ([subTypeVals count]) {
            subValue = [[subTypeVals lastObject] stringValue];
          }
          if (nil == subValue) {
            subValue = NULL_PARAM_VALUE;
          }
          
          NSMutableArray *clubDetailArray = [NSMutableArray arrayWithObjects:subValue, subName,  subId, @(UNSELECTED_TY),nil];
          
          [clubArray insertObject:clubDetailArray atIndex:subIndex++];
        }
        [[AppManager instance].clubFilterList insertObject:clubArray atIndex:index];
      }else {
        NSMutableArray *clubDetailArray = [NSMutableArray arrayWithObjects:NULL_PARAM_VALUE, NULL_PARAM_VALUE,  NULL_PARAM_VALUE, @(UNSELECTED_TY), nil];
        [clubArray insertObject:clubDetailArray atIndex:subIndex++];
        [[AppManager instance].clubFilterList insertObject:clubArray atIndex:index];
      }
    }
    
    index++;
  }
}

@end
