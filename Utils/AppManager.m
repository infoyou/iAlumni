//
//  AppManager.m
//  iAlumni
//
//  Created by Adam on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppManager.h"
#import "iAlumniAppDelegate.h"
#import "WXWDBConnection.h"
#import "WXWImageCache.h"
#import "WXWLocationManager.h"
#import "WXWSyncConnectorFacade.h"
#import "WXWAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "CoreDataUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "SortOption.h"
#import "TextConstants.h"
#import "Place.h"
#import "UIUtils.h"
#import "WXApi.h"
#import "EncryptUtil.h"
#import "WXWUIUtils.h"

#define LOCATION_REFRESH_INTERVAL     60 * 5

@interface AppManager()

@property (nonatomic, assign, readwrite) BOOL sso;  // single sign on

@property (nonatomic, retain) UIView *sessionExpiredView;
@property (nonatomic, assign) WebItemType sessionExpiredActionType;
@property (nonatomic, copy) NSString *sharedWelfareId;

- (void)getCurrentLocationInfo;
- (void)locateUserCurrentCity;
- (void)getLocationIfNecessary;
- (BOOL)userAlreadySignedIn;

@end

@implementation AppManager

@synthesize isLogin;
@synthesize prepareForLogin;

@synthesize eventUrl;
@synthesize version;
@synthesize system;
@synthesize deviceToken;
@synthesize softName;
@synthesize device;
@synthesize releaseChannelType;
@synthesize isNewVersion;

@synthesize msgNumber;
@synthesize sessionId;
@synthesize hostUrl;
@synthesize softDesc;
@synthesize softUrl;
@synthesize errCode;
@synthesize errDesc;
@synthesize loginHelpUrl;
@synthesize serviceTel;
@synthesize needPrompt;

@synthesize isLoadClassDataOK;
@synthesize isLoadCountryDataOK;
@synthesize isLoadIndustryDataOK;
@synthesize isLoadHomeGroupDataOK;
@synthesize isLoadADDataOK;
@synthesize isLoadVedioFilterOk;

@synthesize loadedEventFilterOK;
@synthesize loadedGroupFilterOK;

@synthesize recommend;
@synthesize classGroupId;
@synthesize className;

@synthesize userType;
@synthesize userId = _userId;
@synthesize personId;
@synthesize passwd;
@synthesize userName = _userName;
@synthesize userMobile = _userMobile;
@synthesize userImgUrl;
@synthesize email = _email;
@synthesize photoUrl = _photoUrl;
@synthesize accessToken = _accessToken;
@synthesize systemMessage = _systemMessage;

@synthesize isLanguageChange = _isLanguageChange;
@synthesize currentLanguageCode = _currentLanguageCode;
@synthesize currentLanguageDesc = _currentLanguageDesc;
@synthesize currentLanguage = _switchTargetLanguageCode;

@synthesize networkStable = _networkStable;
@synthesize host = _host;
@synthesize imageCache = _imageCache;
@synthesize loadedItemCount = _loadedItemCount;
@synthesize locationFetched = _locationFetched;
@synthesize hasLogoff = _hasLogoff;
//@synthesize latitude = _latitude;
//@synthesize longitude = _longitude;
@synthesize cityId = _cityId;
@synthesize cityName = _cityName;
@synthesize MOC = _MOC;
@synthesize countryId = _countryId;
@synthesize countryName = _countryName;
@synthesize feedGroupId = _feedGroupId;
@synthesize qaGroupId = _qaGroupId;
@synthesize unreadMessageReceived = _unreadMessageReceived;
@synthesize messageAutoLoaded = _messageAutoLoaded;
@synthesize fontSizeType = _fontSizeType;

@synthesize clubAdmin;
@synthesize isAdminCheckIn;
@synthesize classClubId;
@synthesize classClubType;
@synthesize eventId;
@synthesize clubId;
@synthesize clubName;
@synthesize clubType;
@synthesize clubSupType;
@synthesize hostSupTypeValue;
@synthesize hostTypeValue;
@synthesize isNeedReLoadUserList;
@synthesize isNeedReLoadClubDetail;
@synthesize isNeedReLoadEventDetail;
@synthesize isNeedReLoadUserDetail;
@synthesize isAddUserList;
@synthesize isClub2Event;
@synthesize isAlumniCheckIn;
@synthesize isQueryAlumni2CheckIn;

@synthesize isClubPostShow;
@synthesize isLoadClubPostOK;
@synthesize clubPostArray;
@synthesize clubSimpleDetailArray;

@synthesize eventAlumniMobile;
@synthesize eventAlumniWeibo;
@synthesize eventAlumniEmail;
@synthesize supClubFilterList;
@synthesize clubFilterList;
@synthesize baseDataArray;
@synthesize questionsList;
@synthesize questionsOptionsList;
@synthesize questionDictMutable;
@synthesize myClassNum;
@synthesize needSaveMyClassNum;
@synthesize supClubTypeValue;
@synthesize clubKeyWord;

@synthesize eventCityLoaded;
@synthesize clubFliterLoaded;
@synthesize isNeedClubManage;
@synthesize isEventAdminCheckManage;

@synthesize supClassFilterList;
@synthesize classFilterList;
@synthesize classFliterLoaded;

@synthesize distanceList;
@synthesize timeList;
@synthesize sortList;

@synthesize eventTypeList;
@synthesize eventCityList;
@synthesize eventSortList;

@synthesize groupTypeList;
@synthesize groupSortList;

@synthesize videoTypeList;
@synthesize videoSortList;

@synthesize welfareTypeList;

@synthesize pickerSel0IndexList;
@synthesize pickerSel1IndexList;

@synthesize hasSetingedPlace2Thing;
@synthesize defaultPlace;
@synthesize defaultDistance;
@synthesize defaultThing;
@synthesize shakeLocationHistory;

@synthesize visiblePopTipViews;
@synthesize chartContent;

@synthesize isPostDetail;

@synthesize adminCheckinTableInfo;

@synthesize shakeWinnerType;
@synthesize shakeWinnerInfo;

// event
@synthesize allowSendSMS = _allowSendSMS;

// back alumni
@synthesize accessCheckInAvailable;
@synthesize backAlumniActivityMsg;
@synthesize backAlumniActivityType;
@synthesize backAlumniEventMsg;

// filter
@synthesize filterSupIndex;
@synthesize filterIndex;

@synthesize searchKeyWords;

// pay
@synthesize selSkuCount;

static AppManager *shareInstance = nil;

+ (AppManager *)instance {
    @synchronized(self) {
        if (nil == shareInstance) {
            shareInstance = [[self alloc] init];
        }
    }
    
    return shareInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (nil == shareInstance) {
            shareInstance = [super allocWithZone:zone];
            return shareInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (oneway void)release {
}

- (unsigned)retainCount {
    return UINT_MAX;
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - prepare necessary data

- (void)prepareForNecessaryData {
    
    [self getLocationIfNecessary];
}

- (void)getHostUrl {
    
    [AppManager instance].hostUrl = [self getHostStrFromLocal];
    
    @autoreleasepool {
        
        dispatch_queue_t queue = dispatch_queue_create("com.weixun.getHostBlock", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^(void){
            
            WXWSyncConnectorFacade *conn = [[[WXWSyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:GET_HOST_TY] autorelease];
            NSData *data = [conn syncGet:GET_HOST_URL];
            
            NSString *hostStr = [[[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding] autorelease];
            if ([hostStr hasPrefix:@"http://"]) {
                [AppManager instance].hostUrl = hostStr;
                [CommonUtils saveStringValueToLocal:hostStr key:HOST_LOCAL_KEY];
            }
            
        });
        
        dispatch_release(queue);
    }
}

- (void)beginInitializationProcess {
    
    [self getHostUrl];
    
    [self checkSoftVersion];
}

- (void)beginSSOInitialicationProcess {
    self.sso = YES;
    
    [self beginInitializationProcess];
}

#pragma mark - language switch
- (void)userMetaDataLoaded {
    
    if (_settingDelegate) {
        [_settingDelegate languageSwitchDone];
        _settingDelegate = nil;
    }
    
    _reloadDataForLanguageSwitch = NO;
}

- (void)reloadForLanguageSwitch:(id<ECAppSettingDelegate>)settingDelegate {
    
    _settingDelegate = settingDelegate;
    _reloadDataForLanguageSwitch = YES;
    
    [self userMetaDataLoaded];
}

#pragma mark - locate current city where user stays
- (void)handleLocateFailedForCurrentCity {
    
    // CoreLocation locate failed, then assign the local storage firstly,
    self.cityId = [CommonUtils fetchLonglongIntegerValueFromLocal:USER_CITY_ID_LOCAL_KEY];
    self.cityName = [CommonUtils fetchStringValueFromLocal:USER_CITY_NAME_LOCAL_KEY];
    
    if (nil == self.cityName || self.cityName.length == 0) {
        // no local storage for current city, then assign the "Other City" to current user
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cityId == %lld AND placeId == %@)", OTHER_CITY_ID.longLongValue, OTHER_CITY_ID];
        Place *otherCity = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:self.MOC entityName:@"Place" predicate:predicate];
        self.cityId = otherCity.cityId.longLongValue;
        self.cityName = otherCity.cityName;
        
        [CommonUtils saveLongLongIntegerValueToLocal:self.cityId key:USER_CITY_ID_LOCAL_KEY];
        [CommonUtils saveStringValueToLocal:self.cityName key:USER_CITY_NAME_LOCAL_KEY];
    }
}

- (void)locateUserCurrentCity {
    if (self.latitude == 0.0 && self.longitude == 0.0f) {
        [self handleLocateFailedForCurrentCity];
        
    } else {
        // fetch current city according to latest latitude and longitude
        NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:NONE_TY];
        
        ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:LOCATE_CURRENT_CITY_TY] autorelease];
        
        [connFacade fetchCurrentCity:url];
    }
}

#pragma mark - prepare app
- (void)prepareHost {
    
    NSString *url = [NSString stringWithFormat:@"http://www.weixun.co/host_get.php?host_type=%d", HOST_TYPE];
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:FETCH_HOST_TY] autorelease];
    [connFacade fetchHost:url];
}

- (void)verifyUser {
    
    _existingUser = [self userAlreadySignedIn];
    
    if (_existingUser) {
        // verify the user's validity with server
        NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:NONE_TY];
        
        ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:VERIFY_USER_TY] autorelease];
        [connFacade verifyUser:url showAlertMsg:NO];
        
    } else {
        if (_appDelegate && _verifyFinishAction) {
            [_appDelegate performSelector:_verifyFinishAction withObject:@NO];
        }
    }
}

- (void)prepareApp:(id)appDelegate verifyFinishAction:(SEL)verifyFinishAction {
    
    _appDelegate = appDelegate;
    _verifyFinishAction = verifyFinishAction;
    
    [self prepareHost];
    
}

- (void)enterHomePage:(NSNumber *)flag {
    
    if (_appDelegate && _verifyFinishAction) {
        [_appDelegate performSelector:_verifyFinishAction withObject:flag];
    }
}

#pragma mark - user
- (BOOL)userAlreadySignedIn {
    
    BOOL ret = YES;
    
    if (0 == [[AppManager instance] getUserIdFromLocal].length) {
        return NO;
    }
    
    if (0 == [[AppManager instance] getPasswordFromLocal].length) {
        return NO;
    }
    
    return ret;
}

- (BOOL)allNecessaryUserInfoFetched {
    
    if (self.countryId > 0 &&
        self.countryName &&
        self.countryName.length > 0 &&
        self.cityId > 0 &&
        self.cityName &&
        self.cityName.length > 0 &&
        self.email &&
        self.email.length > 0 &&
        self.userId &&
        self.userId.length > 0 &&
        self.userName &&
        self.userName.length > 0) {
        
        return YES;
    } else {
        return NO;
    }
}

- (void)relocationForAppActivate {
    [self getCurrentLocationInfo];
}

- (void)getCurrentLocationInfo {
    
    // fetch current geographic info
    WXWLocationManager *locationManager = [[WXWLocationManager alloc] initWithDelegate:self
                                                                          showAlertMsg:NO];
    [locationManager getCurrentLocation];
    
}

- (void)getLocationIfNecessary {
    if (![AppManager instance].locationFetched) {
        //    [self getCurrentLocationInfo];
    } else {
        // fetch user current city info
        //    [self locateUserCurrentCity];
    }
}

- (void)startLocationTimer {
    if (nil == _locationTimer) {
        _locationTimer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_REFRESH_INTERVAL
                                                          target:self
                                                        selector:@selector(getCurrentLocationInfo)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)initUser {
    
    //    [AppManager instance].sessionId = @"2012070309591827606";
    [AppManager instance].sessionId = NULL_PARAM_VALUE;
    [AppManager instance].personId = @"238869";
    [AppManager instance].userType = @"1";
    [AppManager instance].userId = @"zying.e09sh5";
    [AppManager instance].userName = @"游客";
    [AppManager instance].classGroupId = @"EMBA09SH5";
    [AppManager instance].className = @"EMBA09SH5";
    [AppManager instance].classClubType = SELF_CLASS_TYPE;
    [AppManager instance].classClubId = @"137";
    
    if (![self getLoginStatusFromLocal]) {
        [AppManager instance].isLogin = NO;
    } else {
        [AppManager instance].isLogin = YES;
    }
    
    // init DB
    //    [WXWDBConnection prepareBizDB];
    
    // prepare necessary data
    [self prepareForNecessaryData];
    
    //    [self startLocationTimer];
}

#pragma mark - sign out
- (void)clearUserInfoForSignOut {
    [CommonUtils removeLocalInfoValueForKey:USER_ID_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_NAME_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_COUNTRY_NAME_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_COUNTRY_ID_LOCAL_KEY];
    
    self.userId = nil;
    self.userName = nil;
    self.countryId = 0ll;
    self.countryName = nil;
    self.sessionId = nil;
}

#pragma mark - image management
- (WXWImageCache *)imageCache {
    if (nil == _imageCache) {
        _imageCache = [[WXWImageCache alloc] init];
    }
    return _imageCache;
}

- (void)clearImageCacheForHandleMemoryWarning {
    // clear image cache
    [[[AppManager instance] imageCache] didReceiveMemoryWarning];
}

- (void)fetchImage:(NSString*)url
            caller:(id<WXWImageFetcherDelegate>)caller
          forceNew:(BOOL)forceNew {
    [[[AppManager instance] imageCache] fetchImage:url
                                            caller:caller
                                          forceNew:forceNew];
}

- (void)cancelPendingImageLoadProcess:(NSMutableDictionary *)urlDic {
    [[[AppManager instance] imageCache] cancelPendingImageLoadProcess:urlDic];
}

- (void)clearCallerFromCache:(NSString *)url {
    [[[AppManager instance] imageCache] clearCallerFromCache:url];
}

- (void)clearAllCachedImages {
    [[[AppManager instance] imageCache] clearAllCachedImages];
}

- (void)clearAllCachedAndLocalImages {
    [[[AppManager instance] imageCache] clearAllCachedAndLocalImages];
}

- (UIImage *)getImage:(NSString*)anUrl {
    return [[[AppManager instance] imageCache] getImage:anUrl];
}

- (void)saveImageIntoCache:(NSString *)url image:(UIImage *)image {
    [[[AppManager instance] imageCache] saveImageIntoCache:url image:image];
}

- (void)removeDelegate:(id)delegate forUrl:(NSString *)key {
    [[[AppManager instance] imageCache] removeDelegate:delegate
                                                forUrl:key];
}

#pragma mark - view controller navigation
- (void)backToHomepage {
    [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
}

#pragma mark - WXWLocationFetcherDelegate methods

- (void)locationManagerDidUpdateLocation:(WXWLocationManager *)manager
                                location:(CLLocation *)location {
    return;
}

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager location:(CLLocation *)location {
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    [manager autorelease];
    
    // if current location update triggered by user active app, then the nearby service venues
    // should be refreshed if user stay at the nearby service venues list before deactive app
    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NEARBY_NOTIFY
                                                        object:nil
                                                      userInfo:nil];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
    
    [manager autorelease];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
    
    [manager autorelease];
}

#pragma mark - open share items
- (void)openSharedItem {
    
    switch (_sharedItemType) {
        case SHARED_EVENT_TY:
            [self doOpenSharedEvent];
            break;
            
        case SHARED_BRAND_TY:
            [self doOpenSharedBrand];
            break;
            
        case SHARED_VIDEO_TY:
            [self doOpenSharedVideo];
            break;
            
        case SHARED_WELFARE_TY:
            [self doOpenSharedWelfare];
            break;
            
        case NONE_SHARED_TY:
            [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
            break;
            
        default:
            break;
    }
}

#pragma mark - open push messages
- (void)openPushedMessageItem {
    
    [(iAlumniAppDelegate *)APP_DELEGATE prepareHomepageForOpenPushMessage];
}

#pragma mark - local storage management
- (BOOL)getLoginStatusFromLocal {
    if  (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginEd"]]) {
        return NO;
    } else {
        return YES;
    }
    return NO;
}

- (NSString *)getEmailFromLocal {
    return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
}

- (NSString *)getPasswordFromLocal {
    NSString *backVal = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    if (backVal == nil) {
        return @"jit@mark";
    } else {
        return backVal;
    }
}

- (NSString *)getUserIdFromLocal {
    NSString *backVal = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (backVal == nil) {
        return @"qronghao.e08sh2";
    } else {
        return backVal;
    }
    return nil;
}

- (NSString *)getUsernameFromLocal {
    NSData *usernameData = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (usernameData && usernameData.length > 0) {
        return [[[NSString alloc] initWithData:usernameData encoding:NSUTF8StringEncoding] autorelease];
    } else {
        return nil;
    }
}

- (NSString *)getHostStrFromLocal {
    
    NSString *url = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
    
    if (nil == url || url.length == 0) {
        url = HOST_URL;
    }
    
    return url;
    
}

- (void)saveUserInfoIntoLocal {
    [[NSUserDefaults standardUserDefaults] setObject:[self.userName dataUsingEncoding:NSUTF8StringEncoding]
                                              forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwd forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostUrl forKey:@"host"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - language set
+ (void)setEN{
    [AppManager instance].currentLanguageCode = EN_TY;
    [AppManager instance].currentLanguageDesc = LANG_EN_TY;
    [AppManager instance].currentLanguage = @"English";
}

+ (void)setCN{
    [AppManager instance].currentLanguageCode = ZH_HANS_TY;
    [AppManager instance].currentLanguageDesc = LANG_CN_TY;
    [AppManager instance].currentLanguage = @"中文";
}

/*
 - (void)getHostUrl
 {
 
 //    Normal
 NSString *url = GET_HOST_URL;
 
 ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
 interactionContentType:GET_HOST_TY] autorelease];
 [connFacade fetchGets:url];
 
 }
 */

- (void)checkSoftVersion
{
    
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:CHECK_VERSION_TY];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:CHECK_VERSION_TY] autorelease];
    [connFacade fetchGets:url];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    
    if (contentType == REFRESH_SESSION_TY && self.sessionExpiredView) {
        [WXWUIUtils showActivityView:self.sessionExpiredView text:LocaleStringForKey(NSLoadingTitle, nil)];
    }
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType
{
    
    switch (contentType) {
        case GET_HOST_TY:
        {
            NSString *hostStr = [[[NSString alloc] initWithData:result
                                                       encoding:NSUTF8StringEncoding] autorelease];
            if ([hostStr hasPrefix:@"http://"]) {
                [AppManager instance].hostUrl = hostStr;
                
                [CommonUtils saveStringValueToLocal:hostStr key:HOST_LOCAL_KEY];
                
            }else{
                
                [AppManager instance].hostUrl = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
            }
            
            [self checkSoftVersion];
            break;
        }
            
        case CHECK_VERSION_TY:
        {
            ReturnCode ret = [XMLParser handleSoftMsg:result MOC:_MOC];
            switch (ret) {
                case RESP_OK:
                {
                    
                    if (self.sso) {
                        
                        [self autoSSO];
                        
                    } else {
                        [self autoLoginWithUserId:[[AppManager instance] getUserIdFromLocal]
                                         password:[[AppManager instance] getPasswordFromLocal]];
                    }
                    break;
                }
                    
                case SOFT_UPDATE_CODE:
                {
                    [AppManager instance].isNewVersion = YES;
                    [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
                    break;
                }
                    
                case ERR_CODE:
                {
                    if ([AppManager instance].sso) {
                        [(iAlumniAppDelegate *)APP_DELEGATE openSignInHelp];
                    } else {
                        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
                    }
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case LOGIN_TY:
        {
            NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
            if ([XMLParser parserSyncResponseXml:decryptedData type:LOGIN_SRC MOC:_MOC]) {
                
                switch (self.appOpenTriggerType) {
                    case SHARE_ITEM_TRIGGER_TY:
                        [self openSharedItem];
                        break;
                        
                    case PUSH_TRIGGER_TY:
                        [self openPushedMessageItem];
                        break;
                        
                    default:
                        [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
                        break;
                }
                
            } else {
                if ([AppManager instance].sso) {
                    [(iAlumniAppDelegate *)APP_DELEGATE openSignInHelp];
                } else {
                    [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
                }
            }
            break;
        }
            
        case REFRESH_SESSION_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:self.MOC
                           connectorDelegate:self
                                         url:url]) {
                
                NSNumber *actionType = @(self.sessionExpiredActionType);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:REDO_REQUEST_NOTIFY
                                                                    object:nil
                                                                  userInfo:@{SESSION_EXPIRED_VIEW_KEY:self.sessionExpiredView, SESSION_EXPIRED_TYPE_KEY:actionType, SESSION_ID_KEY:[AppManager instance].sessionId}];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSRefreshSessionFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            
            [WXWUIUtils closeActivityView];
            break;
        }
        default:
            break;
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    
    if (contentType == REFRESH_SESSION_TY) {
        [WXWUIUtils closeActivityView];
    }
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
    switch (contentType) {
            /*
             case GET_HOST_TY:
             {
             [AppManager instance].hostUrl = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
             
             if ([AppManager instance].sso) {
             [(iAlumniAppDelegate *)APP_DELEGATE openSignInHelp];
             } else {
             [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
             }
             
             break;
             }
             */
        case LOGIN_TY:
        {
            if (error) {
                [AppManager instance].errDesc = error.localizedDescription;
            }
            
            if ([AppManager instance].sso) {
                [(iAlumniAppDelegate *)APP_DELEGATE openSignInHelp];
            } else {
                [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
            }
            
            break;
        }
            
        case CHECK_VERSION_TY:
        {
            if ([AppManager instance].sso) {
                [(iAlumniAppDelegate *)APP_DELEGATE openSignInHelp];
            } else {
                [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
            }
            
            break;
        }
            
        case REFRESH_SESSION_TY:
        {
            [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSRefreshSessionFailedMsg, nil)
                                             msgType:ERROR_TY
                                  belowNavigationBar:YES];
            [WXWUIUtils closeActivityView];
            break;
        }
        default:
            break;
    }
}

- (void)saveShowAlertFlag:(BOOL)flag {
    _showAlert = flag;
}

#pragma mark - handle open shared event
- (void)parserEventInfo:(NSString *)info {
    if (info.length > 0) {
        
        if ([info rangeOfString:EVENT_ID_FLAG].length > 0) {
            NSArray *list = [info componentsSeparatedByString:EVENT_FIELD_SEPARATOR];
            if (list.count == 2) {
                NSString *eventIds = list[0];
                NSString *eventTypes = list[1];
                
                // parser event id
                if (eventIds.length > 0) {
                    NSArray *idContents = [eventIds componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
                    if (idContents.count == 2) {
                        _sharedEventId = ((NSString *)idContents[1]).longLongValue;
                    }
                }
                
                if (eventTypes.length > 0) {
                    NSArray *typeContents = [eventTypes componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
                    if (typeContents.count == 2) {
                        _sharedEventType = ((NSString *)typeContents[1]).intValue;
                    }
                }
            }
        }
    }
}

- (NSString *)parserItemIdStr:(NSString *)info {
    if (info.length > 0) {
        NSArray *list = [info componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
        if (list.count == 2) {
            return (NSString *)list[1];
        }
    }
    return nil;
}

- (long long)parserItemId:(NSString *)info {
    if (info.length > 0) {
        return [self parserItemIdStr:info].longLongValue;
    }
    
    return 0ll;
}

- (SharedItemType)parserSharedItem:(NSString *)extInfo {
    if (0 == extInfo.length || nil == extInfo) {
        return NONE_SHARED_TY;
    }
    
    if ([extInfo rangeOfString:EVENT_ID_FLAG].length > 0) {
        return SHARED_EVENT_TY;
    } else if ([extInfo rangeOfString:BRAND_ID_FLAG].length > 0) {
        return SHARED_BRAND_TY;
    } else if ([extInfo rangeOfString:VIDEO_ID_FLAG].length > 0) {
        return SHARED_VIDEO_TY;
    } else if ([extInfo rangeOfString:WELFARE_ID_FLAG].length > 0) {
        return SHARED_WELFARE_TY;
    }
    
    return NONE_SHARED_TY;
}

- (void)doOpenSharedEvent {
    [((iAlumniAppDelegate*)APP_DELEGATE) openSharedEventById:_sharedEventId eventType:_sharedEventType];
}

- (void)doOpenSharedBrand {
    [((iAlumniAppDelegate*)APP_DELEGATE) openSharedBrandById:_sharedBrandId];
}

- (void)doOpenSharedVideo {
    [((iAlumniAppDelegate*)APP_DELEGATE) openSharedVideoById:_sharedVideoId];
}

- (void)doOpenSharedWelfare {
    [((iAlumniAppDelegate*)APP_DELEGATE) openSharedWelfareById:self.sharedWelfareId];
}

- (void)openHomepage {
    if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground) {
        
        [((iAlumniAppDelegate*)APP_DELEGATE) openHomePageAfterClearAllViewControllers];
    }
}

- (void)openSharedEvent:(NSString *)extInfo {
    [self parserEventInfo:extInfo];
    
    if (_sharedEventId > 0ll) {
        
        // open shared event step by step
        
        //_startUpByOpenSharedEvent = YES;
        _sharedItemType = SHARED_EVENT_TY;
        
        // 1. if app is running currently, then open shared event directly when
        // app enter to foreground;
        // 2. if app is not running, the shared event will be opened after
        // initialization process finished
        
        if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedEvent];
        }
        
    } else {
        // open app frome shared post in WeChat
        [self openHomepage];
    }
}

- (void)openSharedBrand:(NSString *)extInfo {
    _sharedBrandId = [self parserItemId:extInfo];
    
    if (_sharedBrandId > 0ll) {
        
        _sharedItemType = SHARED_BRAND_TY;
        
        if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedBrand];
        }
        
    } else {
        // open app frome shared post in WeChat
        [self openHomepage];
    }
}

- (void)openSharedVideo:(NSString *)extInfo {
    _sharedVideoId = [self parserItemId:extInfo];
    
    if (_sharedVideoId > 0ll) {
        _sharedItemType = SHARED_VIDEO_TY;
        
        if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedVideo];
        }
        
    } else {
        [self openHomepage];
    }
}

- (void)openSharedWelfare:(NSString *)extInfo {
    
    self.sharedWelfareId = [self parserItemIdStr:extInfo];
    if (self.sharedWelfareId.length > 0) {
        _sharedItemType = SHARED_WELFARE_TY;
        
        if (((iAlumniAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedWelfare];
        }
    } else {
        [self openHomepage];
    }
}

- (void)openAppFromWeChatByMessage:(WXMediaMessage *)message {
    WXAppExtendObject *object = message.mediaObject;
    
    if (object) {
        switch ([self parserSharedItem:object.extInfo]) {
            case SHARED_EVENT_TY:
                [self openSharedEvent:object.extInfo];
                break;
                
            case SHARED_BRAND_TY:
                [self openSharedBrand:object.extInfo];
                break;
                
            case SHARED_VIDEO_TY:
                [self openSharedVideo:object.extInfo];
                break;
                
            case SHARED_WELFARE_TY:
                [self openSharedWelfare:object.extInfo];
                break;
                
            case NONE_SHARED_TY:
                [self openHomepage];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - auto login
- (void)autoLoginWithUserId:(NSString *)userId password:(NSString *)password {
    
    NSString *param = [NSString stringWithFormat:@"username=%@&password=%@",
                       [userId lowercaseString],
                       [CommonUtils stringByURLEncodingStringParameter:password]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@&%@&locale=%@&plat=%@&version=%@&device_token=%@&channel=%d",
                     [AppManager instance].hostUrl,
                     ALUMNI_LOGIN_REQ_URL,
                     param,
                     [WXWSystemInfoManager instance].currentLanguageDesc,
                     PLATFORM,
                     VERSION,
                     [AppManager instance].deviceToken,
                     [AppManager instance].releaseChannelType];
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:LOGIN_TY] autorelease];
    [connFacade fetchGets:url];
}

- (void)autoSSO {
    
    NSString *url = STR_FORMAT(@"%@phone_controller?action=signin_ceibs2&username=%@&sessionId=%@&locale=zh&plat=iPhone&version=%@&device_token=%@&channel=%d", [AppManager instance].hostUrl, [AppManager instance].userId, [AppManager instance].sessionId, VERSION, [AppManager instance].deviceToken, [AppManager instance].releaseChannelType);
    
    ECAsyncConnectorFacade *connector = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                   interactionContentType:LOGIN_TY] autorelease];
    [connector fetchGets:url];
}

#pragma mark - refresh session
- (void)refreshSessionForView:(UIView *)view
                   actionType:(WebItemType)actionType {
    
    self.sessionExpiredView = view;
    self.sessionExpiredActionType = actionType;
    
    NSString *url = STR_FORMAT(@"%@%@&username=%@&password=%@&locale=%@", [AppManager instance].hostUrl, REFRESH_SESSION_REQ_URL, [[AppManager instance] getUserIdFromLocal], [[AppManager instance] getPasswordFromLocal], [AppManager instance].currentLanguageDesc);
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:REFRESH_SESSION_TY] autorelease];
    [connFacade fetchGets:url];
}

- (void)initParam
{
    [AppManager instance].isLoadClassDataOK = NO;
    [AppManager instance].isLoadIndustryDataOK = NO;
    [AppManager instance].isLoadCountryDataOK = NO;
    [AppManager instance].isLoadHomeGroupDataOK = NO;
    [AppManager instance].isLoadVedioFilterOk = NO;
    
    [AppManager instance].loadedEventFilterOK = NO;
    [AppManager instance].loadedGroupFilterOK = NO;
}

@end
