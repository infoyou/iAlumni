//
//  XMLParser.h
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "CXMLElement.h"
#import "CXMLDocument.h"
#import "Event.h"

@class Event;
@class EventTopic;
@class Alumni;

@interface XMLParser : NSObject {
  
}

+ (BOOL)parserResponseXml:(NSData *)xmlData
                     type:(WebItemType)type 
                      MOC:(NSManagedObjectContext *)MOC
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url;

+ (BOOL)parserResponseXml:(NSData *)xmlData
                     type:(WebItemType)type 
                      MOC:(NSManagedObjectContext *)MOC 
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url
             parentItemId:(long long)parentItemId;

#pragma mark - parser favorited items
+ (BOOL)parserFavoritedItems:(NSData *)xmlData
                        type:(WebItemType)type 
                         MOC:(NSManagedObjectContext *)MOC 
           connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                         url:(NSString *)url
                 favoritedBy:(long long)favoritedBy
       beCheckDetailedItemId:(long long)beCheckDetailedItemId;

#pragma mark - years
+ (BOOL)loadYearsFromLocal:(NSManagedObjectContext *)MOC;

#pragma mark - fetch host
+ (BOOL)parserFetchHost:(NSData *)data;

#pragma mark - handle service item
+ (BOOL)parserLoadedServiceItem:(NSData *)xmlData
                            MOC:(NSManagedObjectContext *)MOC 
              connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                            url:(NSString *)url;

+ (BOOL)parserLoadedServiceItemForBrandId:(long long)brandId
                                  xmlData:(NSData *)xmlData
                                      MOC:(NSManagedObjectContext *)MOC
                        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                      url:(NSString *)url
                                itemCount:(NSNumber **)itemCount;

#pragma mark - fetch Post Comments

+ (BOOL)parserPostComments:(NSData *)xmlData
                       MOC:(NSManagedObjectContext *)MOC
                    postId:(long long)postId
         connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                       url:(NSString *)url;

#pragma mark - handle load likers for item
+ (BOOL)parserLikers:(NSData *)xmlData
                type:(WebItemType)type
   hashedLikedItemId:(NSString *)hashedLikedItemId
                 MOC:(NSManagedObjectContext *)MOC 
   connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate 
                 url:(NSString *)url;

#pragma mark - handle item like action
+ (BOOL)parserLikeItem:(NSData *)xmlData
     hashedLikedItemId:(NSString *)hashedLikedItemId
    originalLikeStatus:(BOOL)originalLikeStatus
              memberId:(long long)memberId
                   MOC:(NSManagedObjectContext *)MOC 
     connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate 
                   url:(NSString *)url
                  type:(WebItemType)type;

#pragma mark - handle event check in
+ (BOOL)parserEventStuff:(NSData *)xmlData
                itemType:(WebItemType)itemType
             event:(Event *)event
                     MOC:(NSManagedObjectContext *)MOC
       connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                     url:(NSString *)url;

+ (CheckinResultType)parserEventCheckinResult:(NSData *)xmlData
                                  event:(Event *)event
                                          MOC:(NSManagedObjectContext *)MOC
                            connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                          url:(NSString *)url;

#pragma mark - handle event vote
+ (BOOL)parserEventTopics:(NSData *)xmlData
                  eventId:(long long)eventId
                      MOC:(NSManagedObjectContext *)MOC
        connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                      url:(NSString *)url;

+ (BOOL)parserTopicOptions:(NSData *)xmlData
                     topic:(EventTopic *)topic
                       MOC:(NSManagedObjectContext *)MOC
         connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                       url:(NSString *)url;

#pragma mark - check in for nearby service item
+ (CheckinResultType)parserCheckin:(NSData *)xmlData
                 connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                               url:(NSString *)url;

+ (BOOL)parserCheckedinAlumnus:(NSData *)xmlData
                  hashedItemId:(NSString *)hashedItemId
                           MOC:(NSManagedObjectContext *)MOC
             connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                           url:(NSString *)url;

#pragma mark - parser sync response
+ (BOOL)parserSyncResponseXml:(NSData *)xmlData
                         type:(XmlParserItemType)type 
                          MOC:(NSManagedObjectContext *)MOC;

+ (ReturnCode)handleSoftMsg:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC;
+ (ReturnCode)handleCommonResult:(NSData *)xmlData showFlag:(BOOL)showFlag;
+ (BOOL)handleHomeGroup:(NSManagedObjectContext *)MOC;

+ (NSInteger)parserResponseCode:(CXMLDocument *)respDoc;

#pragma mark - alumni network
+ (BOOL)parserRecommendAlumnusForEndAlumniId:(long long)endAlumniId
                                     xmlData:(NSData *)xmlData
                                         MOC:(NSManagedObjectContext *)MOC
                           connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                         url:(NSString *)url;

+ (BOOL)parserJoinedGroupForAlumniId:(long long)alumniId
                             xmlData:(NSData *)xmlData
                                 MOC:(NSManagedObjectContext *)MOC
                   connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                 url:(NSString *)url;

+ (BOOL)parseMemberForGroupId:(long long)groupId
                      xmlData:(NSData *)xmlData
                          MOC:(NSManagedObjectContext *)MOC
            connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                          url:(NSString *)url;

+ (ReturnCode)handleEventFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC;
+ (ReturnCode)handleGroupFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC;

#pragma mark - handle welfare filter data
+ (ReturnCode)handleWelfareFilterData:(NSData *)xmlData MOC:(NSManagedObjectContext *)MOC;

#pragma mark - order stuff
+ (NSString *)parserOrderIdWithData:(NSData *)data
                  connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                                url:(NSString *)url
                               type:(WebItemType)type;

#pragma mark - direct message 
+ (BOOL)parserDMMessageWithxmlData:(NSData *)xmlData
                               MOC:(NSManagedObjectContext *)MOC
                 connectorDelegate:(id<WXWConnectorDelegate>)connectorDelegate
                               url:(NSString *)url
                            alumni:(Alumni *)alumni;
@end
