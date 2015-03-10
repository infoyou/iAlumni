//
//  HttpUtils.m
//  ExpatCircle
//
//  Created by Adam on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "HttpUtils.h"

@implementation HttpUtils

+ (NSString *)commonParams {
  /*
  NSString *languageCode = [WXWSystemInfoManager instance].currentLanguageCode;
  if ([AppManager instance].switchTargetLanguageCode 
      && [AppManager instance].switchTargetLanguageCode.length > 0) {
    // maybe user load meta data for language switch action, so the language code should be the target language
    languageCode = [AppManager instance].switchTargetLanguageCode;
  }
  */
  return [NSString stringWithFormat:COMMON_PARAM, 
          [AppManager instance].currentLanguage, 
          [AppManager instance].userId, 
          NULL_PARAM_VALUE, 
          @"i", 
          VERSION, 
          [AppManager instance].deviceToken,
          [AppManager instance].countryId];
}

+ (NSString *)itemLoadFilterParams:(NSString *)tags 
                          authorId:(long long)authorId 
                           groupId:(long long)groupId
                         groupType:(NSInteger)groupType 
                       favoritedBy:(long long)favoritedBy {
  
  return [NSString stringWithFormat:ITEM_LOAD_FILTER_PARAM, 
          LLINT_TO_STRING([AppManager instance].cityId),
          tags, 
          LLINT_TO_STRING([AppManager instance].countryId),
          LLINT_TO_STRING(authorId),
          LLINT_TO_STRING(groupId),
          INT_TO_STRING(groupType),
          LLINT_TO_STRING(favoritedBy)];
}

+ (NSString *)distanceFilterParams:(CGFloat)radius 
                          latitude:(double)latitude
                         longitude:(double)longitude {
  return [NSString stringWithFormat:DISTANCE_FILTER_PARAM, 
          [NSString stringWithFormat:@"%f", radius], 
          [NSString stringWithFormat:@"%.8f", latitude],
          [NSString stringWithFormat:@"%.8f", longitude]];
}

+ (NSString *)pageParams:(SortType)orderType 
              startIndex:(NSInteger)startIndex
                   count:(NSInteger)count 
               countryId:(long long)countryId {
  return [NSString stringWithFormat:PAGE_PARAM,
          INT_TO_STRING(orderType),
          INT_TO_STRING(startIndex),
          INT_TO_STRING(count),
          LLINT_TO_STRING(countryId)];
}

+ (NSString *)commentFilterParams:(NSInteger)count commenterId:(long long)commenterId {
  return [NSString stringWithFormat:COMMENT_FILTER_PARAM,
          INT_TO_STRING(count),
          LLINT_TO_STRING(commenterId)];
}

+ (NSString *)otherParams:(NSString *)params {
  return [NSString stringWithFormat:OTHER_PARAMS, params];
}

#pragma mark - feed, news, qa item request

+ (NSString *)assembleRequestUrl:(NSString *)itemLoadFilterParams 
            distanceFilterParams:(NSString *)distanceFilterParams
                      pageParams:(NSString *)pageParams
             commentFilterParams:(NSString *)commentFilterParams {
  
  return [NSString stringWithFormat:@"<params>%@%@%@%@%@</params>", 
          [self commonParams],
          itemLoadFilterParams,
          distanceFilterParams,
          pageParams,
          commentFilterParams];
}

+ (NSString *)assembleRequestUrl:(NSString *)itemLoadFilterParams 
            distanceFilterParams:(NSString *)distanceFilterParams
                      pageParams:(NSString *)pageParams
             commentFilterParams:(NSString *)commentFilterParams 
                        listType:(ItemListType)listType {
  
  return [NSString stringWithFormat:@"<params>%@%@%@%@%@%@</params>", 
          [self commonParams],
          itemLoadFilterParams,
          distanceFilterParams,
          pageParams,
          commentFilterParams,
          [self otherParams:[NSString stringWithFormat:@"<list_type>%@</list_type>", INT_TO_STRING(listType)]]];

}


#pragma mark - user

+ (NSString *)assembleUserVerifyUrl:(NSString *)specifiedParams {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:specifiedParams]];
}

#pragma mark - composer place
+ (NSString *)assembleComposerPlaceUrl:(CGFloat)radius 
                              latitude:(double)latitude 
                             longitude:(double)longitude {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self distanceFilterParams:radius
                            latitude:latitude
                           longitude:longitude]];
}

#pragma mark - comments 
+ (NSString *)commentPageParam:(NSString *)startIndex counts:(NSString *)counts {
  return [NSString stringWithFormat:@"<page_param><start_index>%@</start_index><counts>%@</counts></page_param>", startIndex, counts];
}

+ (NSString *)assembleFetchCommentUrl:(NSString *)postId 
                           startIndex:(NSString *)startIndex 
                               counts:(NSString *)counts {
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commentPageParam:startIndex counts:counts],
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id>", postId]]];
}

#pragma mark - venue album
+ (NSString *)assembleFetchVenueAlbumUrl:(NSString *)postId 
                              startIndex:(NSString *)startIndex 
                                  counts:(NSString *)counts {
  
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commentPageParam:startIndex counts:counts],
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id>", postId]]];  
}

#pragma mark - current city
+ (NSString *)assembleFetchCurrentCity:(double)latitude longitude:(double)longitude {
  
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams], [NSString stringWithFormat:DISTANCE_FILTER_PARAM, 
                                NULL_PARAM_VALUE, 
                                LOCDATA_TO_STRING(latitude),
                                LOCDATA_TO_STRING(longitude)]];
  
}

#pragma mark - country, tags, city list
+ (NSString *)assembleFetchBasicInfoUrl:(double)latitude longitude:(double)longitude {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams], [NSString stringWithFormat:DISTANCE_FILTER_PARAM, 
                                NULL_PARAM_VALUE, 
                                LOCDATA_TO_STRING(latitude),
                                LOCDATA_TO_STRING(longitude)]];
}

#pragma mark - groups
+ (NSString *)assembleFetchGroupUrl:(NSInteger)groupType {
  
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<group_type_filter>%@</group_type_filter>",
                             INT_TO_STRING(groupType)]]];
}

#pragma mark - nearby service 
+ (NSString *)assembleServiceItemRequestUrl:(NSString *)filterParams
                       distanceFilterParams:(NSString *)distanceFilterParams
                                 pageParams:(NSString *)pageParams {
  
  return [NSString stringWithFormat:@"<params>%@%@%@%@</params>", 
          [self commonParams],
          filterParams,
          distanceFilterParams,
          pageParams];
}

+ (NSString *)assembleFetchServiceCategoryUrl {
  return [NSString stringWithFormat:@"<params>%@</params>", [self commonParams]];
}

+ (NSString *)assembleFetchNearbyItemDetailUrl:(NSString *)filterParam itemId:(long long)itemId {
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commonParams],
          filterParam, 
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id>", LLINT_TO_STRING(itemId)]]];
}

+ (NSString *)assembleFetchServiceItemDetailUrl:(NSString *)itemId {
  
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id><latitude>%f</latitude><longitude>%f</longitude>", 
                             itemId,
                             [AppManager instance].latitude,
                             [AppManager instance].longitude]]];
}

+ (NSString *)assembleFetchRecommendedItemLikeUsersUrl:(long long)itemId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_item_id>%@</service_item_id>", 
                             LLINT_TO_STRING(itemId)]]];
}

+ (NSString *)assembleRecommendedItemLikeUrl:(long long)itemId 
                                  liktStatus:(NSInteger)likeStatus {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_recommend_item_id>%@</service_recommend_item_id><like_status>%@</like_status>", LLINT_TO_STRING(itemId), INT_TO_STRING(likeStatus)]]];
}

+ (NSString *)assembleServiceItemLikeUrl:(long long)itemId likeStatus:(NSInteger)likeStatus {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id><like_status>%@</like_status>", LLINT_TO_STRING(itemId), INT_TO_STRING(likeStatus)]]];
}

+ (NSString *)assembleServiceProviderLikeUrl:(long long)spId likeStatus:(NSInteger)likeStatus {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_provider_id>%@</service_provider_id><like_status>%@</like_status>", LLINT_TO_STRING(spId), INT_TO_STRING(likeStatus)]]];
}

+ (NSString *)assembleFetchServiceProviderDetailUrl:(long long)spId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_provider_id>%@</service_provider_id>", LLINT_TO_STRING(spId)]]];
  
}

+ (NSString *)assembleFetchServiceItemLikeUsersUrl:(long long)itemId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id>", 
                             LLINT_TO_STRING(itemId)]]];
}

+ (NSString *)assembleFetchServiceProviderLikeUsersUrl:(long long)spId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_provider_id>%@</service_provider_id>", 
                             LLINT_TO_STRING(spId)]]];
}

+ (NSString *)assembleFavoriteServiceItemUrl:(long long)itemId 
                                    favorite:(NSInteger)favorite {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id><favorite_status>%@</favorite_status>", 
                             LLINT_TO_STRING(itemId),
                             INT_TO_STRING(favorite)]]];
}

+ (NSString *)assembleFetchServiceItemCommentUrl:(long long)itemId
                                      startIndex:(NSString *)startIndex 
                                          counts:(NSString *)counts {
  return [NSString stringWithFormat:@"<params>%@%@%@</params>", 
          [self commonParams],
          [self commentPageParam:startIndex counts:counts],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id>", 
                             LLINT_TO_STRING(itemId)]]];
}

+ (NSString *)assembleFetchServiceProviderCommentUrl:(long long)itemId
                                          startIndex:(NSString *)startIndex 
                                              counts:(NSString *)counts {
  return [NSString stringWithFormat:@"<params>%@%@%@</params>", 
          [self commonParams],
          [self commentPageParam:startIndex counts:counts],
          [self otherParams:[NSString stringWithFormat:@"<service_provider_id>%@</service_provider_id>", 
                             LLINT_TO_STRING(itemId)]]];
}

+ (NSString *)assembleFetchServiceItemAlbumUrl:(NSString *)itemId 
                                    startIndex:(NSString *)startIndex 
                                        counts:(NSString *)counts {
  
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commentPageParam:startIndex counts:counts],
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_id>%@</service_id>", itemId]]];  
}

+ (NSString *)assembleFetchServiceProviderAlbumUrl:(NSString *)providerId 
                                        startIndex:(NSString *)startIndex 
                                            counts:(NSString *)counts {
  
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commentPageParam:startIndex counts:counts],
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<service_provider_id>%@</service_provider_id>", 
                             providerId]]];  
}

#pragma mark - recommended item for nearby service
+ (NSString *)assembleFetchRecommendedItemUrl:(NSString *)filterParam 
                                serviceItemId:(long long)serviceItemId 
                                   startIndex:(NSInteger)startIndex
                                        count:(NSString *)count {
  return [NSString stringWithFormat:@"<params>%@%@%@</params>",
          [self commonParams],
          ASSEMBED_SERVICE_RECOMMENDED_ITEM_FILTER_PARAMS(LLINT_TO_STRING(serviceItemId)),
          [self commentPageParam:INT_TO_STRING(startIndex) counts:count]];
}

#pragma mark - post like
+ (NSString *)assemblePostLikeUrl:(long long)postId liktStatus:(NSInteger)likeStatus {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id><like_status>%@</like_status>", LLINT_TO_STRING(postId), INT_TO_STRING(likeStatus)]]];
}

#pragma mark - favorite post and member
+ (NSString *)assembleFavoriteUrl:(long long)itemId 
                         itemType:(NSInteger)itemType
                         favorite:(NSInteger)favorite {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<item_id>%@</item_id><item_type>%@</item_type><to_favorite>%@</to_favorite>", 
                             LLINT_TO_STRING(itemId),
                             INT_TO_STRING(itemType),
                             INT_TO_STRING(favorite)]]];
}

#pragma mark - like users
+ (NSString *)assembleFetchLikeUsersUrl:(long long)itemId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id>", 
                             LLINT_TO_STRING(itemId)]]];
}

#pragma mark - user info
+ (NSString *)assembleFetchUserInfoUrl:(long long)userId {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<target_user_id>%@</target_user_id>", LLINT_TO_STRING(userId)]]];
}

#pragma mark - post delete
+ (NSString *)assembleDeletePostUrl:(long long)postId {
  return [NSString stringWithFormat:@"<params>%@%@</params>", 
          [self commonParams],
          [self otherParams:[NSString stringWithFormat:@"<post_id>%@</post_id>", LLINT_TO_STRING(postId)]]];
}

#pragma mark - favorited member list
+ (NSString *)assembleFavoritedMembersUrl:(long long)favoritedBy {
  return [NSString stringWithFormat:@"<params>%@%@</params>",
          [self commonParams], 
          [self otherParams:[NSString stringWithFormat:@"<favorite_by>%@</favorite_by>", LLINT_TO_STRING(favoritedBy)]]];
}

#pragma mark - system message
+ (NSString *)assembleFetchSystemMessageUrl {
  return [NSString stringWithFormat:@"<params>%@</params>", [self commonParams]];
}

@end
