//
//  ECAsyncConnectorFacade.m
//  iAlumni
//
//  Created by ; on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "GlobalConstants.h"
#import "CommonUtils.h"
#import "Club.h"

@implementation ECAsyncConnectorFacade

#pragma mark - fetch host
- (void)fetchHost:(NSString *)url {
  // not show alert message avoid the warning be displayed in startup view
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - user
- (void)verifyUser:(NSString *)url showAlertMsg:(BOOL)showAlertMsg {
  [self asyncGet:url showAlertMsg:showAlertMsg];
}

- (void)fetchUserProfile:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

- (void)fetchUserInfoFromLinkedin:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

- (void)confirmBindLinkedin:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load image
- (void)fetchImage:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - hot news
- (void)fetchNews:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load comment
- (void)fetchComments:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - like action
- (void)likeItem:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - check in action
- (void)checkin:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - favorite action
- (void)favoriteItem:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - upload post
/*
- (NSMutableData *)assembleContentData:(NSDictionary *)dic
                                 photo:(UIImage *)photo
                          originalData:(NSMutableData *)originalData {
  NSString *param = [CommonUtils convertParaToHttpBodyStr:dic];
  
  if (nil != photo) {
    // format the pic as parameter
		param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\r\n", IALUMNI_FORM_BOUNDARY]];
		param = [param stringByAppendingString:@"Content-Disposition:form-data; name=\"attach\"; filename=\"pic.jpg\"; Content-Type:application/octet-stream\r\n\r\n"];
  }
  
  [originalData appendData:[param dataUsingEncoding:NSUTF8StringEncoding
                               allowLossyConversion:YES]];
  
  if (nil != photo) {
    // add pic data into parameter
		NSData *jpgPic = UIImageJPEGRepresentation(photo, 0.8);
		[originalData appendData:jpgPic];
  }
  
  // append footer
	NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", IALUMNI_FORM_BOUNDARY];
	[originalData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding
                                allowLossyConversion:YES]];
  
  if (EC_DEBUG) {
    NSLog(@"params: %@", [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] autorelease]);
  }
  return originalData;
}
*/
- (void)uploadItem:(NSString*)url dic:(NSDictionary *)dic photo:(UIImage *)photo {
  
  NSMutableData *contentData = [NSMutableData data];
  
  [self post:url
        data:[self assembleContentData:dic
                                 photo:photo
                          originalData:contentData]];
}

- (void)uploadItem:(NSDictionary *)dic photo:(UIImage *)photo {
  
  NSMutableData *contentData = [NSMutableData data];
  
  [self post:[CommonUtils assembleUrl:nil]
        data:[self assembleContentData:dic
                                 photo:photo
                          originalData:contentData]];
  
}

- (void)uploadItem:(NSDictionary *)dic photo:(UIImage *)photo snsType:(DomainType)snsType {
  
  NSMutableData *contentData = [NSMutableData data];
  
  [self post:[CommonUtils assembleurlWithType:LINKEDIN_DOMAIN_TY]
        data:[self assembleContentData:dic
                                 photo:photo
                          originalData:contentData]];
}

- (void)sendPost:(NSString *)content
         groupId:(NSString *)groupId
          tagIds:(NSString *)tagIds
         placeId:(NSString *)placeId
       placeName:(NSString *)placeName
          cityId:(long long)cityId
           photo:(UIImage *)photo {
  
  NSDictionary *dic = nil;
  if ([AppManager instance].latitude == 0 && [AppManager instance].longitude == 0) {
    dic = @{@"action": @"submit_post",
           @"plat": PLATFORM,
           @"session": [AppManager instance].sessionId,
           @"version": VERSION,
           @"user_id": [AppManager instance].personId,
           @"group_id": groupId,
           @"text": content,
           @"city_id": LLINT_TO_STRING([AppManager instance].cityId),
           @"is_suggest": @"0",
           @"locationType": SELF_CLASS_TYPE,
           @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
           @"tag_ids": tagIds};
    
  } else {
    
    if (nil != placeId && placeId.length > 0 && nil != placeName && placeName.length > 0) {
      // user selects a specified nearby place
      dic = @{@"action": @"submit_post",
             @"plat": PLATFORM,
             @"session": [AppManager instance].sessionId,
             @"version": VERSION,
             @"user_id": [AppManager instance].userId,
             @"group_id": groupId,
             @"city_id": LLINT_TO_STRING([AppManager instance].cityId),
             @"is_suggest": @"0",
             @"locationType": SELF_CLASS_TYPE,
             @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
             @"tag_ids": tagIds,
             @"text": content,
             @"place_id": placeId,
             @"place_address": placeName,
             @"lat": DOUBLE_TO_STRING([AppManager instance].latitude),
             @"long": DOUBLE_TO_STRING([AppManager instance].longitude)};
      
    } else {
      // although location detected, user does not select a specified nearby place
      dic = @{@"action": @"submit_post",
             @"plat": PLATFORM,
             @"session": [AppManager instance].sessionId,
             @"version": VERSION,
             @"user_id": [AppManager instance].userId,
             @"group_id": groupId,
             @"city_id": LLINT_TO_STRING([AppManager instance].cityId),
             @"is_suggest": @"0",
             @"locationType": SELF_CLASS_TYPE,
             @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
             @"tag_ids": tagIds,
             @"text": content};
    }
    
  }
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];
}

#pragma mark - upload post
- (void)sendPostForGroup:(Club *)group
                   content:(NSString *)content
                   photo:(UIImage *)photo {
  /*
  NSString *hostType = NULL_PARAM_VALUE;
  if (group.hostTypeValue && group.hostTypeValue.length > 0) {
    hostType = group.hostTypeValue;
  }
  */
  NSString *groupId = [NSString stringWithFormat:@"%@", group.clubId];
  
  NSDictionary *dic = @{@"action": @"submit_post",
  @"plat": PLATFORM,
  @"type_id": group.clubType,
  @"item_id": groupId,
  @"session": [AppManager instance].sessionId,
  @"version": VERSION,
  @"user_id": [AppManager instance].personId,
  @"user_name": [AppManager instance].userName,
  @"user_type": [AppManager instance].userType,
  @"host_id": groupId,
  @"message": content,
  @"latitude": NULL_PARAM_VALUE,
  @"longitude": NULL_PARAM_VALUE};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];
}

- (void)sendSupplyDemandWithContent:(NSString *)content
                               tags:(NSString *)tags
                               type:(SupplyDemandItemType)type
                              photo:(UIImage *)photo {
  
  NSDictionary *dic = @{@"action": @"submit_post",
                        @"plat": PLATFORM,
                        @"type_id": STR_FORMAT(@"%d", SUPPLY_DEMAND_COMBINE_TY),
                        @"supply_demand":STR_FORMAT(@"%d", type),
                        @"item_id": NULL_PARAM_VALUE,
                        @"session": [AppManager instance].sessionId,
                        @"version": VERSION,
                        @"user_id": [AppManager instance].personId,
                        @"user_name": [AppManager instance].userName,
                        @"user_type": [AppManager instance].userType,
                        @"host_id": NULL_PARAM_VALUE,
                        @"message": content,
                        @"tag_ids":tags,                        
                        @"latitude": NULL_PARAM_VALUE,
                        @"longitude": NULL_PARAM_VALUE};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];

}

- (void)sendPost:(NSString *)content
           photo:(UIImage *)photo
          hasSms:(NSString *)hasSms
{
  
  NSDictionary *dic = @{@"action": @"submit_post",
                       @"plat": PLATFORM,
                       @"type_id": NULL_PARAM_VALUE,
                       @"item_id": NULL_PARAM_VALUE,
                       @"is_sms_inform": hasSms,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].personId,
                       @"user_name": [AppManager instance].userName,
                       @"user_type": [AppManager instance].userType,
                       @"host_id": [AppManager instance].clubId,
                       @"host_type": [AppManager instance].hostTypeValue,
                       @"message": content,
                       @"latitude": NULL_PARAM_VALUE,
                       @"longitude": NULL_PARAM_VALUE};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];
}

- (void)sendEventDiscuss:(NSString *)content
                   photo:(UIImage *)photo
                  hasSMS:(NSString *)hasSMS
                 eventId:(NSString *)eventId {
  
  NSDictionary *dic = @{@"action": @"submit_post",
                       @"plat": PLATFORM,
                       @"type_id": [NSString stringWithFormat:@"%d", EVENT_DISCUSS_POST_TY],
                       @"item_id": eventId,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"is_sms_inform": hasSMS,
                       @"user_id": [AppManager instance].personId,
                       @"user_name": [AppManager instance].userName,
                       @"user_type": [AppManager instance].userType,
                       @"message": content};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];
}

- (void)sendChat:(NSString *)content{
  
  NSDictionary *dic = @{@"ReqContent": content};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, CHART_SUBMIT_URL]
               dic:dic
             photo:nil];
}

#pragma mark - upload share
- (void)sendPost:(NSString *)content
          tagIds:(NSString *)tagIds
       placeName:(NSString *)placeName
           photo:(UIImage *)photo
        postType:(PostType)postType
         groupId:(NSString *)groupId
{
  
  NSDictionary *dic = nil;

  if ([AppManager instance].latitude == 0 && [AppManager instance].longitude == 0) {
    dic = @{@"action": @"submit_post",
           @"plat": PLATFORM,
           @"item_id": groupId,
           @"host_id": groupId,
           @"tag_ids": tagIds,
           @"type_id": INT_TO_STRING(postType),
           @"session": [AppManager instance].sessionId,
           @"version": VERSION,
           @"user_id": [AppManager instance].personId,
           @"user_name": [AppManager instance].userName,
           @"user_type": [AppManager instance].userType,
           @"message": content};
    
  } else {
    
    if (placeName.length > 0) {
      
      dic = @{@"action": @"submit_post",
             @"plat": PLATFORM,
             @"item_id": groupId,
             @"host_id": groupId,
             @"place": placeName,
             @"tag_ids": tagIds,
             @"type_id": INT_TO_STRING(postType),
             @"session": [AppManager instance].sessionId,
             @"version": VERSION,
             @"user_id": [AppManager instance].personId,
             @"user_name": [AppManager instance].userName,
             @"user_type": [AppManager instance].userType,
             @"message": content,
             @"latitude": DOUBLE_TO_STRING([AppManager instance].latitude),
             @"longitude": DOUBLE_TO_STRING([AppManager instance].longitude)};
    } else {
      
      dic = @{@"action": @"submit_post",
             @"plat": PLATFORM,
             @"item_id": groupId,
             @"host_id": groupId,
             @"tag_ids": tagIds,
             @"type_id": INT_TO_STRING(postType),
             @"session": [AppManager instance].sessionId,
             @"version": VERSION,
             @"user_id": [AppManager instance].personId,
             @"user_name": [AppManager instance].userName,
             @"user_type": [AppManager instance].userType,
             @"message": content};
    }
  }
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",
                    [AppManager instance].hostUrl,
                    POST_URL]
               dic:dic
             photo:photo];
}

#pragma mark - upload comment
- (void)sendComment:(NSString *)content
     originalItemId:(NSString *)originalItemId
              photo:(UIImage *)photo {
  
  if (nil == originalItemId || [originalItemId length] == 0) {
    return;
  }
  
  NSString *clubId = [AppManager instance].clubId;
  if (nil == clubId) {
    clubId = NULL_PARAM_VALUE;
  }
  
  NSString *clubType = [AppManager instance].hostTypeValue;
  if (nil == clubType) {
    clubType = NULL_PARAM_VALUE;
  }
  
  NSDictionary *dic = nil;
  dic = @{@"action": @"submit_post_comment",
         @"plat": PLATFORM,
         @"type_id": NULL_PARAM_VALUE,
         @"post_id": originalItemId,
         @"session": [AppManager instance].sessionId,
         @"version": VERSION,
         @"user_id": [AppManager instance].personId,
         @"user_name": [AppManager instance].userName,
         @"user_type": [AppManager instance].userType,
         @"host_id": clubId,
         @"host_type": clubType,
         @"message": content,
         @"latitude": DOUBLE_TO_STRING([AppManager instance].latitude),
         @"longitude": DOUBLE_TO_STRING([AppManager instance].longitude)};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - publish welfare
- (void)publishWelfare:(NSString *)contact
    tel:(NSString *)tel
    email:(NSString *)email
    weiXinCode:(NSString *)weiXinCode
    brandName:(NSString *)brandName
    enterpriseService:(NSString *)enterpriseService
    storeScale:(NSString *)storeScale
    preferentialDesc:(NSString *)preferentialDesc
{
        
    NSDictionary *dic = nil;
    dic = @{
            @"ReqContent" : [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><content><plat>%@</plat><locale>%@</locale><version>%@</version><person_id>%@</person_id><user_id>%@</user_id><user_name>%@</user_name><user_type>%@</user_type><session_id>%@</session_id><contact>%@</contact><tel>%@</tel><email>%@</email><weiXinCode>%@</weiXinCode><brandName>%@</brandName><enterpriseService>%@</enterpriseService><storeScale>%@</storeScale><preferentialDesc>%@</preferentialDesc></content>", PLATFORM, [WXWSystemInfoManager instance].currentLanguageDesc, VERSION, [AppManager instance].personId, [AppManager instance].userId, [AppManager instance].userName, [AppManager instance].userType,[AppManager instance].sessionId, contact, tel, email, weiXinCode, brandName, enterpriseService, storeScale, preferentialDesc],
            @"action": @"setSupplyWelfare",
            @"plat": PLATFORM,
};
    
    NSString *postUrl = [NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, PUBLIS_WELFARE_URL];
    [self uploadItem:postUrl dic:dic photo:nil];
}

#pragma mark - modify User Icon
- (void)modifyUserIcon:(UIImage *)photo {
  
  NSDictionary *dic = @{@"action": @"submit_wap_user_avatar",
                       @"plat": PLATFORM,
                       @"locale": [WXWSystemInfoManager instance].currentLanguageDesc,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"person_id": [AppManager instance].personId,
                       @"user_name": [AppManager instance].userName,
                       @"user_type": [AppManager instance].userType};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - upload brand, service item, provider comment
- (void)sendServiceItemComment:(NSString *)content
                        itemId:(NSString *)itemId
                       brandId:(NSString *)brandId {
  
  if (nil == itemId || [itemId length] == 0) {
    return;
  }
  
  NSDictionary *dic = @{@"action": @"service_comment_submit",
                       @"plat": PLATFORM,
                       @"version": VERSION,
                       @"user_name": [AppManager instance].userName,
                       @"person_id": [AppManager instance].personId,
                       @"service_id": itemId,
                       @"channel_id": brandId,
                       @"message": content,
                       @"locale": [WXWSystemInfoManager instance].currentLanguageDesc};
  [self uploadItem:dic photo:nil];
}

- (void)sendBrandComment:(NSString *)content
                 brandId:(NSString *)brandId {
  
  if (nil == brandId || [brandId length] == 0) {
    return;
  }
  
  NSDictionary *dic = @{@"action": @"service_comment_submit",
                       @"plat": PLATFORM,
                       @"version": VERSION,
                       @"user_name": [AppManager instance].userName,
                       @"person_id": [AppManager instance].personId,
                       @"channel_id": brandId,
                       @"message": content,
                       @"locale": [WXWSystemInfoManager instance].currentLanguageDesc};
  [self uploadItem:dic photo:nil];
}

- (void)sendServiceProviderComment:(NSString *)content
                        providerId:(NSString *)providerId {
  
  if (nil == providerId || providerId.length == 0) {
    return;
  }
  
  NSDictionary *dic = @{@"action": @"service_provider_comment_submit",
                       @"plat": PLATFORM,
                       @"session": NULL_PARAM_VALUE,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"service_provider_id": providerId,
                       @"message": content,
                       @"locale": [WXWSystemInfoManager instance].currentLanguageDesc};
  [self uploadItem:dic photo:nil];
}

#pragma mark - check address book contacts join status
- (void)checkABContactsJoinStatus:(NSString *)emails {
  NSDictionary *dic = @{@"action": @"user_exist_check_email",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"emails": emails,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc};
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - load place
- (void)fetchPlaces:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load country
- (void)fetchCountries:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - fetch current city
- (void)fetchCurrentCity:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load feeds
- (void)fetchFeeds:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - load questions
- (void)fetchQuestions:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

#pragma mark - delete feed
- (void)deleteFeeds:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - delete comment
- (void)deleteComment:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - delete question
- (void)deleteQuestion:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load liker list
- (void)fetchLikers:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load checked in alumnus
- (void)fetchCheckedinAlumnus:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load sns friends
- (void)fetchSNSFriends:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - invite address book friends
- (void)inviteByAddressbookPhoneNumbers:(NSString *)phoneNumbers {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"invite_friends",
         @"plat": PLATFORM,
         @"version": VERSION,
         @"user_id": [AppManager instance].userId,
         @"mobile": phoneNumbers};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

- (void)inviteByAddressbookEmails:(NSString *)emails {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"invite_friends",
         @"plat": PLATFORM,
         @"version": VERSION,
         @"user_id": [AppManager instance].userId,
         @"email": emails};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

- (void)inviteByAddressbookEmails:(NSString *)emails phoneNumbers:(NSString *)phoneNumbers {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"invite_friends",
         @"plat": PLATFORM,
         @"version": VERSION,
         @"user_id": [AppManager instance].userId,
         @"email": emails,
         @"mobile": phoneNumbers};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - invite linkedin friends
- (void)inviteLinkedinFriends:(NSString *)userIds {
  NSDictionary *dic = nil;
  
  dic = @{@"action": @"user_message",
         @"plat": PLATFORM,
         @"version": VERSION,
         @"user_id": [AppManager instance].userId,
         @"linkedinid": userIds};
  
  [self uploadItem:dic photo:nil snsType:LINKEDIN_DOMAIN_TY];
}

#pragma mark - update user's nationality
- (void)updateUserNationality:(long long)countryId {
  NSDictionary *dic = @{@"action": @"user_info_update",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
                       @"country_id": LLINT_TO_STRING(countryId)};
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update user's photo
- (void)updateUserPhoto:(UIImage *)photo {
  NSDictionary *dic = @{@"action": @"user_info_update",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:photo];
}

#pragma mark - update years of user living China
- (void)updateUserLivingYears:(NSString *)years {
  NSDictionary *dic = @{@"action": @"user_info_update",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
                       @"living_years": years};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update user's city
- (void)updateUserLivingCity:(long long)cityId {
  NSDictionary *dic = @{@"action": @"user_info_update",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
                       @"city_id": LLINT_TO_STRING(cityId)};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - update userName
- (void)updateUserUsername:(NSString *)userName {
  NSDictionary *dic = @{@"action": @"user_info_update",
                       @"plat": PLATFORM,
                       @"session": [AppManager instance].sessionId,
                       @"version": VERSION,
                       @"user_id": [AppManager instance].userId,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc,
                       @"user_name": userName};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL] dic:dic photo:nil];
}

#pragma mark - add photo for service item and provider
- (void)addPhotoForServiceItem:(UIImage *)photo
                        itemId:(long long)itemId
                       caption:(NSString *)caption {
  NSDictionary *dic = @{@"action": @"service_photo_submit",
                       @"plat": PLATFORM,
                       @"session": NULL_PARAM_VALUE,
                       @"person_id": [AppManager instance].personId,
                       @"version": VERSION,
                       @"service_id": [NSString stringWithFormat:@"%lld", itemId],
                       @"message": caption,
                       @"locale": [WXWSystemInfoManager instance].currentLanguageDesc};
  
  [self uploadItem:[NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, POST_URL]
               dic:dic
             photo:photo];
}

- (void)addPhotoForServiceProvider:(UIImage *)photo
                        providerId:(long long)providerId
                           caption:(NSString *)caption {
  
  NSDictionary *dic = @{@"action": @"service_provider_photo_submit",
                       @"plat": PLATFORM,
                       @"session": NULL_PARAM_VALUE,
                       @"user_id": [AppManager instance].userId,
                       @"version": VERSION,
                       @"service_provider_id": LLINT_TO_STRING(providerId),
                       @"message": caption,
                       @"lang": [WXWSystemInfoManager instance].currentLanguageDesc};
  
  [self uploadItem:dic photo:photo];
}

#pragma mark - upload question result
- (void)sendQuestionResult:(NSString *)content url:(NSString *)url
{
    
    NSDictionary *dic = nil;
    dic = @{@"question_values": content};
    
    [self uploadItem:url
                 dic:dic
               photo:nil];
}

#pragma mark - load nearby groups
- (void)fetchNearbyGroups:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - recommended items for nearby service
- (void)fetchRecommendedItems:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load nearby items
- (void)fetchNearbyItems:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load album photo
- (void)fetchAlbumPhoto:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load user meta data
- (void)fetchUserMetaData:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - load nearby item detail
- (void)fetchNearbyItemDetail:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - get & show
- (void)fetchGets:(NSString *)url {
  [self asyncGet:url showAlertMsg:YES];
}

#pragma mark - get whithout alert
- (void)fetchGetsWithoutAlert:(NSString *)url {
  [self asyncGet:url showAlertMsg:NO];
}

@end
