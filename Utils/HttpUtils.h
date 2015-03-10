//
//  HttpUtils.h
//  ExpatCircle
//
//  Created by Adam on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"

#define COMMON_PARAM @"<common_param><language_code>%@</language_code><user_id>%@</user_id><session_value>%@</session_value><plat>%@</plat><version>%@</version><driver_token>%@</driver_token><country_id>%lld</country_id></common_param>"

#define ITEM_LOAD_FILTER_PARAM @"<filter_param><city_id>%@</city_id><Tags>%@</Tags><country_id>%@</country_id><author_id>%@</author_id><group_id>%@</group_id><group_type>%@</group_type><favorite_by>%@</favorite_by></filter_param>"

#define SERVICE_ITEM_LOAD_FILTER_PARAME @"<filter_param><city_id>%@</city_id><Tags>%@</Tags><country_id>%@</country_id><category_id>%@</category_id><favorite_by>%@</favorite_by></filter_param>"

#define SERVICE_RECOMMENDED_ITEM_LOAD_FILTER_PARAM @"<filter_param><service_id>%@</service_id></filter_param>"

#define DISTANCE_FILTER_PARAM @"<distance_param><distance>%@</distance><latitude>%@</latitude><longitude>%@</longitude></distance_param>"

//order_type: 用于说明排序类别: 1:id排序; 2:最新评论时间排序; 3:签到数量排序; 4:赞数量排序; 5:指定国家用户赞数量排序
#define PAGE_PARAM @"<page_param><order_type>%@</order_type><start_index>%@</start_index><counts>%@</counts><country_id>%@</country_id></page_param>"

#define COMMENT_FILTER_PARAM @"<comments><comment_count>%@</comment_count><comment_by>%@</comment_by></comments>"

#define OTHER_PARAMS @"<special_param>%@</special_param>"

#define COMMENT_PAGE_PARAMS @"<page_param><start_index>%@</start_index><counts>%@</counts></page_param>"

#define ASSEMBED_COMMON_PARAMS [NSString stringWithFormat:COMMON_PARAM, [WXWSystemInfoManager instance].currentLanguageCode, [AppManager instance].userId, [AppManager instance].sessionToken, @"i", VERSION, [AppManager instance].deviceToken];


#define ASSEMBED_ITEM_FILTER_PARAMS(_CITY_ID, _TAGS, _COUNTRY_ID, _AUTHOR_ID, _GP_ID, _GP_TY, _FAVORITE_BY) [NSString stringWithFormat:ITEM_LOAD_FILTER_PARAM, _CITY_ID, _TAGS, _COUNTRY_ID, _AUTHOR_ID, _GP_ID, _GP_TY, _FAVORITE_BY]

#define ASSEMBED_SERVICE_ITEM_FILTER_PARAMS(_CITY_ID, _TAGS, _COUNTRY_ID, _CATEGORY_ID, _FAVORITE_BY) [NSString stringWithFormat:SERVICE_ITEM_LOAD_FILTER_PARAME, _CITY_ID, _TAGS, _COUNTRY_ID, _CATEGORY_ID, _FAVORITE_BY]

#define ASSEMBED_DISTANCE_FILTER_PARAM(_RADIUS,_LATIDUDE, _LONGITUDE) [NSString stringWithFormat:DISTANCE_FILTER_PARAM, _RADIUS, _LATIDUDE, _LONGITUDE]

#define ASSEMBED_PAGE_PARAM(_ORDER_TY, _START_IDX, _COUNT, _CO_ID) [NSString stringWithFormat:PAGE_PARAM, _ORDER_TY, _START_IDX, _COUNT, _CO_ID]

#define ASSEMBED_SERVICE_RECOMMENDED_ITEM_FILTER_PARAMS(_ITEM_ID) [NSString stringWithFormat:SERVICE_RECOMMENDED_ITEM_LOAD_FILTER_PARAM, _ITEM_ID]

#define ASSEMBED_COMMENT_FILTER_PARAM(_COUNT, _COMMENTER_ID) [NSString stringWithFormat:COMMENT_FILTER_PARAM, _COUNT, _COMMENTER_ID]

#define ASSEMBED_OTHER_PARAMS(_PARAMS) [NSString stringWithFormat:OTHER_PARAMS, _PARAMS]

@interface HttpUtils : NSObject {
  
}

+ (NSString *)itemLoadFilterParams:(NSString *)tags 
                          authorId:(long long)authorId 
                           groupId:(long long)groupId
                         groupType:(NSInteger)groupType 
                       favoritedBy:(long long)favoritedBy;

+ (NSString *)distanceFilterParams:(CGFloat)radius 
                          latitude:(double)latitude
                         longitude:(double)longitude;

+ (NSString *)pageParams:(SortType)orderType 
              startIndex:(NSInteger)startIndex
                   count:(NSInteger)count 
               countryId:(long long)countryId;

+ (NSString *)commentFilterParams:(NSInteger)count commenterId:(long long)commenterId;

#pragma mark - feed, news, qa item request
+ (NSString *)assembleRequestUrl:(NSString *)itemLoadFilterParams 
            distanceFilterParams:(NSString *)distanceFilterParams
                      pageParams:(NSString *)pageParams
             commentFilterParams:(NSString *)commentFilterParams;

+ (NSString *)assembleRequestUrl:(NSString *)itemLoadFilterParams 
            distanceFilterParams:(NSString *)distanceFilterParams
                      pageParams:(NSString *)pageParams
             commentFilterParams:(NSString *)commentFilterParams 
                        listType:(ItemListType)listType;

#pragma mark - user
+ (NSString *)assembleUserVerifyUrl:(NSString *)specifiedParams;

#pragma mark - composer place
+ (NSString *)assembleComposerPlaceUrl:(CGFloat)radius 
                              latitude:(double)latitude 
                             longitude:(double)longitude;

#pragma mark - comments 
+ (NSString *)assembleFetchCommentUrl:(NSString *)postId 
                           startIndex:(NSString *)startIndex 
                               counts:(NSString *)counts;

#pragma mark - venue album
+ (NSString *)assembleFetchVenueAlbumUrl:(NSString *)postId 
                              startIndex:(NSString *)startIndex 
                                  counts:(NSString *)counts;

#pragma mark - current city
+ (NSString *)assembleFetchCurrentCity:(double)latitude longitude:(double)longitude;

#pragma mark - country, tags, city list
+ (NSString *)assembleFetchBasicInfoUrl:(double)latitude longitude:(double)longitude;

#pragma mark - groups
+ (NSString *)assembleFetchGroupUrl:(NSInteger)groupType;

#pragma mark - nearby service 
+ (NSString *)assembleServiceItemRequestUrl:(NSString *)filterParams
                       distanceFilterParams:(NSString *)distanceFilterParams
                                 pageParams:(NSString *)pageParams;

+ (NSString *)assembleFetchServiceCategoryUrl;

+ (NSString *)assembleFetchNearbyItemDetailUrl:(NSString *)filterParam 
                                        itemId:(long long)itemId;

+ (NSString *)assembleFetchServiceItemDetailUrl:(NSString *)itemId;

+ (NSString *)assembleFetchRecommendedItemLikeUsersUrl:(long long)itemId;

+ (NSString *)assembleRecommendedItemLikeUrl:(long long)itemId 
                                  liktStatus:(NSInteger)likeStatus;

+ (NSString *)assembleServiceItemLikeUrl:(long long)itemId 
                              likeStatus:(NSInteger)likeStatus;

+ (NSString *)assembleServiceProviderLikeUrl:(long long)spId 
                                  likeStatus:(NSInteger)likeStatus;

+ (NSString *)assembleFetchServiceProviderDetailUrl:(long long)spId;

+ (NSString *)assembleFetchServiceItemLikeUsersUrl:(long long)itemId;

+ (NSString *)assembleFetchServiceProviderLikeUsersUrl:(long long)spId;

+ (NSString *)assembleFavoriteServiceItemUrl:(long long)itemId 
                                    favorite:(NSInteger)favorite;

+ (NSString *)assembleFetchServiceItemCommentUrl:(long long)itemId
                                      startIndex:(NSString *)startIndex 
                                          counts:(NSString *)counts;

+ (NSString *)assembleFetchServiceProviderCommentUrl:(long long)itemId
                                          startIndex:(NSString *)startIndex 
                                              counts:(NSString *)counts;

+ (NSString *)assembleFetchServiceItemAlbumUrl:(NSString *)itemId 
                                    startIndex:(NSString *)startIndex 
                                        counts:(NSString *)counts;

+ (NSString *)assembleFetchServiceProviderAlbumUrl:(NSString *)providerId 
                                        startIndex:(NSString *)startIndex 
                                            counts:(NSString *)counts;

#pragma mark - recommended item for nearby service
+ (NSString *)assembleFetchRecommendedItemUrl:(NSString *)filterParam 
                                serviceItemId:(long long)serviceItemId 
                                   startIndex:(NSInteger)startIndex
                                        count:(NSString *)count;

#pragma mark - post like
+ (NSString *)assemblePostLikeUrl:(long long)postId liktStatus:(NSInteger)likeStatus;

#pragma mark - favorite post and member
+ (NSString *)assembleFavoriteUrl:(long long)itemId 
                         itemType:(NSInteger)itemType
                         favorite:(NSInteger)favorite;

#pragma mark - like users
+ (NSString *)assembleFetchLikeUsersUrl:(long long)itemId;

#pragma mark - user info
+ (NSString *)assembleFetchUserInfoUrl:(long long)userId;

#pragma mark - post delete
+ (NSString *)assembleDeletePostUrl:(long long)postId;

#pragma mark - favorited member list
+ (NSString *)assembleFavoritedMembersUrl:(long long)favoritedBy;

#pragma mark - system message
+ (NSString *)assembleFetchSystemMessageUrl;

@end
