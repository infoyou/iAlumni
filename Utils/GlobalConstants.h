//
//  GlobalConstants.h
//  iAlumni
//
//  Created by Adam on 12-5-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - publish info
#define APP_NAME                    @"iAlumni"
#define PLATFORM                    @"iPhone"
#define VERSION                     @"1.6.2"

// 0,不需要; 1,需要
#define IS_NEED_3RD_LOGIN           0
#define SINGLE_LOGIN_APP_NAME       @"ceibsicampus"

#define OTA_IDNT              @"com.weixun.ceibsiCampus"
#define APP_STORE_IDNT        @"com.wx.ceibsiCampus"

#define WX_API_KEY            @"wx7e4f969fc25925b3"

#define UMENG_ANALYS_APP_KEY        @"500e7bf35270154fb2000057"

typedef enum {
  WECHAT_OK_CODE = 0,
  WECHAT_BACK_CODE = -2,
} WeChatReturnCodeType;

#pragma mark - DB
#define DBFile                      @"iAlumni.sqlite"
#define DB_NAME                     @"IAlumniDB"
#define kDEFAULT_DATE_TIME_FORMAT   (@"yyyy-MM-dd HH:mm:ss")

#define IPHONE_SIMULATOR			@"iPhone Simulator"
#define SIMULATION_LATITUDE         @"31.2887"
#define SIMULATION_LONGITUDE        @"121.517"

#define LOG_DATE_SEPARATOR          @"_"
#define LOG_DEBUG_SEPARATOR         @"#"
#define EMAIL_SEPARATOR             @"，"
#define ERROR_LOG_PREFIX            @"ERROR"
#define CRASH_LOG_PREFIX            @"CRASH"
#define ZIP_SUFFIX                  @".zip"
#define LOG_SUFFIX                  @".log"
#define CRASH_SUFFIX                @".crash"
#define INIT_ZOOM_LEVEL             13
#define INIT_EMBED_ZOOM_LEVEL       0.008

#define MINIMUM_SCROLL_FRACTION       0.2f
#define MAXIMUM_SCROLL_FRACTION       0.9f
#define	KEYBOARD_ANIMATION_DURATION   0.3f
#define LANDSCAPE_KEYBOARD_HEIGHT     192.0f
#define PORTRAIT_KEYBOARD_HEIGHT      216.0f

#define FADE_IN_DURATION            0.5f
#define FADE_OUT_DURATION           1.0f

#pragma mark - UIAlertView
#define ShowAlertWithOneButton(Delegate,TITLE,MSG,But) [[[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:Delegate \
cancelButtonTitle:But \
otherButtonTitles:nil] autorelease] show]

#define ShowAlertWithTwoButton(Delegate,TITLE,MSG,But1,But2) [[[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:Delegate \
cancelButtonTitle:But1 \
otherButtonTitles:But2, nil] autorelease] show]

#pragma mark - UIBarButtonItem
#define BAR_BUTTON(TITLE, STYLE, TARGET, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:STYLE target:TARGET action:SELECTOR] autorelease]

#define BAR_SYS_BUTTON(ButtonSystemItem, TARGET, SELECTOR)  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ButtonSystemItem target:TARGET action:SELECTOR] autorelease]

#define BAR_IMG_BUTTON(IMG, STYLE, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMG style:STYLE target:TARGET action:SELECTOR] autorelease]

#define TAB_BAR_IMG_BUTTON(TITLE, IMG, TAG) [[[UITabBarItem alloc] initWithTitle:TITLE image:IMG tag:TAG] autorelease]

#pragma mark - app properties
#define LOG                         @"log"

#define TOOLBAR_HEIGHT              44.0f
#define VIEW_TITLE_BAR_COLOR        COLOR(185, 19, 26)
#define CELL_TOP_COLOR              COLOR(240, 240, 240)
#define CELL_BOTTOM_COLOR           COLOR(232, 233, 232)
#define CELL_SELECTED_COLOR         COLOR(102, 102, 102)
#define CELL_BACKGROUND_COLOR       COLOR(218, 218, 218)
#define PROFILE_DETAIL_TEXT_COLOR   COLOR(52, 52, 52)
#define TEXT_SHADOW_COLOR           [UIColor whiteColor]
#define GREEN_BLOCK_COLOR           COLOR(163, 200, 37)
#define YELLOW_BLOCK_COLOR          COLOR(246, 195, 55)


#define LIST_WIDTH                  320.0f//477

#define TEXT_HEADER                 @"<html><body><p style=\"font-family:sans-serif;\"><font size=\"2\" face=\"verdana\">"
#define TEXT_FOOTER                 @"</font></p></body></html>"
#define REQ_XML_HEADER              @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
#define REQ_CTNT_TAG_HEADER         @"<content>"
#define REQ_CTNT_TAG_END            @"</content>"
#define REQ_LOCALE_TAG_HEADER       @"<locale>"
#define REQ_LOCALE_TAG_END          @"</locale>"
#define HTTP_PRIFIX                 @"http"
#define HTTPS_PRIFIX                @"https"

#pragma mark - WeChat integration
#define MAX_WECHAT_ATTACHED_IMG_SIZE    30 * 1024
#define MAX_WECHAT_MAX_DESC_CHAR_COUNT  32
#define MAX_WECHAT_MAX_TITLE_CHAR_COUNT 60

#pragma mark - order stuff
#define SKU_MSG(__SKUID__,__SKUNAME__,__SKUPRICE__,__ALLOWMULTIPLE__) \
STR_FORMAT(@"%@#%@#%@#%@#", __SKUID__,__SKUNAME__,__SKUPRICE__,__ALLOWMULTIPLE__)

#define APPEND_SKU_MSG(__SKUMSG__,__SKUID__,__SKUNAME__,__SKUPRICE__,__ALLOWMULTIPLE__) \
STR_FORMAT(@"%@$%@#%@#%@#%@#", __SKUMSG__,__SKUID__,__SKUNAME__,__SKUPRICE__,__ALLOWMULTIPLE__)

#pragma mark - news list
#define NEWS_LIST_CELL_HEIGHT           85.0f
#define EVENT_LIST_CELL_HEIGHT          96.f
#define USER_LIST_CELL_HEIGHT             75.0f
#define USER_LIST_CELL_WITH_TABLE_HEIGHT  90.0f
#define POST_LIST_CELL_HEIGHT			70.0f
#define CLUB_LIST_CELL_HEIGHT           72.0f
#define VIDEO_LIST_CELL_HEIGHT          100.0f

#define CELL_CONTENT_PORTRAIT_WIDTH     280.0f

#define DATETIME_WIDTH                  70.0f
#define DATETIME_HEIGHT                 70.0f

#define ALUMNUS_MENU_WIDTH              200.0f
#define PHOTO_MARGIN                    3.0f
#define USERLIST_PHOTO_WIDTH            51.0f //80.0f
#define USERLIST_PHOTO_HEIGHT           60.0f //95.0f

#define EVENT_USER_PHOTO_WIDTH          46.3f
#define EVENT_USER_PHOTO_HEIGHT         55.0f

#define POSTLIST_PHOTO_WIDTH			51.0f
#define POSTLIST_PHOTO_HEIGHT           60.0f

#define POST_DETAIL_PHOTO_WIDTH         43.0f
#define POST_DETAIL_PHOTO_HEIGHT        51.0f

#define POST_COMMENT_PHOTO_WIDTH		36.2f
#define POST_COMMENT_PHOTO_HEIGHT       43.0f

#define CHART_PHOTO_WIDTH               51.f
#define CHART_PHOTO_HEIGHT              60.f

#define POST_LIKE_PHOTO_WIDTH           40.0f
#define POST_LIKE_PHOTO_HEIGHT          47.5f

#define POSTLIST_CELL_BASE_INFO_HEIGHT  16.0f

#define USERDETAIL_PHOTO_WIDTH          74.0f
#define USERDETAIL_PHOTO_HEIGHT         78.0f

#define CLUB_MEMBER_POST_PHOTO_WIDTH    42.5f
#define CLUB_MEMBER_POST_PHOTO_HEIGHT   50.0f

#define WINNER_HEADER_HEIGHT            45.0f

#define MALE                        @"Male"
#define FEMALE                      @"Female"

#pragma mark - Define Pay Type
#define PAY_GROUP_FEES              @"1"
#define PAY_EVENT_FEES              @"2"
#define PAY_WELFARE_FEES            @"3"

#pragma mark - Define UI Type

typedef enum {
  DEFINE_TYPE_TEXT = 1, // TEXT
  DEFINE_TYPE_AREA,     // TEXT AREA
  DEFINE_TYPE_DROPDOWN, // DROP DOWN
} DefineUIType;

typedef enum {
  ACADEMIC_EVENT_TY,
  LOHHAS_EVENT_TY,
  STARTUP_PROJECT_TY = 4,
} EventType;

typedef enum {
  EVENT_TAB_IDX,
  GROUP_TAB_IDX
} EventGroupTabIndex;

#pragma mark - known alumnus
typedef enum {
  OTHER_CLASS_ALUMNUS_TY,
  SAME_CLASS_ALUMNUS_TY,
} KnownAlumnusType;

#pragma mark - call phone
typedef enum {
	CALL_ACTION_SHEET_IDX,
	CANCEL_ACTION_SHEET_IDX,
} CallPhoneActionSheetType;

#pragma mark - pay
typedef enum {
	ALIPAY_ACTION_SHEET_IDX,
  UNIONPAY_ACTION_SHEET_IDX,
	CANCEL_PAY_ACTION_SHEET_IDX,
} PayActionSheetType;

typedef enum {
	PHOTO_ACTION_SHEET_IDX,
  LIBRARY_ACTION_SHEET_IDX,
	CANCEL_PHOTO_SHEET_IDX,
} TakePhotoActionSheetType;

typedef enum {
	CHAT_SHEET_IDX,
	DETAIL_SHEET_IDX,
  CANCEL_SHEET_IDX,
} UserListActionSheetType;

typedef enum {
  ALUMNI_QUERY_LIST_TY,
  EVENT_ALUMNI_LIST_TY,
} AlumniListContainerType;

#pragma mark - http response code
typedef enum {
  ERR_CODE = -1,
  RESP_OK = 200,
  APP_EXPIRED_CODE = 206,
  SOFT_UPDATE_CODE = 220,
} ReturnCode;

typedef enum {
  WRITE_COMMENT_ITEM_TY,
  WRITE_ANSWER_ITEM_TY,
} WriteItemType;

typedef enum {
  SCROLL_STILL_TY,
  SCROLL_DOWN_TY,
  SCROLL_UP_TY,
} ScrollDirectionType;

typedef enum {
  ALL_ALUMNI_GP_TY = 100, // dummy type, should be removed if needed
  HOTNEWS_GP_TY = 1,
  QA_GP_TY = 2,
  NEARBY_GP_TY = 3,
  FEEDS_GP_TY = 5,
} GroupType;

typedef enum {
  NONE_TY = 0,
  LOGIN_TY = 1,
  
  SIGN_OUT_TY,
  
  REFRESH_SESSION_TY,
  
  LOAD_SYS_MESSAGE_TY,
  
  ALUMNI_REPORT_TY,
  ALUMNI_UPCOMING_TY,
  LOAD_NEWS_REPORT_TY,
  
  FETCH_HOST_TY,
  VERIFY_USER_TY,
  MODIFY_USER_ICON_TY,
  LOAD_USER_INFO_FROM_LINKEDIN_TY,
  CONFIRM_BIND_LINKEDIN_TY,
  //LOAD_IMAGE_TY,
  LOAD_NEWS_TY,
  LOAD_COMMENT_TY,
  LOAD_QA_WITH_ANSWER_TY,
  ITEM_LIKE_TY,
  ITEM_CHECKIN_TY,
  ITEM_FAVORITE_TY,
  SEND_POST_TY,
  SEND_SHARE_TY,
  SEND_QUESTION_TY,
  LOCATE_CURRENT_CITY_TY,
  LOAD_PLACE_TY,
  LOAD_COUNTRY_TY,
  LOAD_LIVING_YEAR_TY,
  LOAD_QA_TY,
  DELETE_FEED_TY,
  DELETE_COMMENT_TY,
  DELETE_QUESTION_TY,
  LOAD_LIKERS_TY,
  LOAD_CHECKEDIN_ALUMNUS_TY,
  LOAD_USER_PROFILE_TY,
  LOAD_FAVORITED_NEWS_TY,
  LOAD_FAVORITED_PEOPLE_TY,
  LOAD_FAVORITED_QA_TY,
  LOAD_FAVORITED_NEARBY_ITEM_TY,
  LOAD_SNS_FRIENDS_TY,
  INVITE_BY_AB_PHONE_TY,
  INVITE_BY_LINKEDIN_TY,
  UPDATE_USERNAME_TY,
  UPDATE_USER_PHOTO_TY,
  UPDATE_USER_CITY_TY,
  UPDATE_USER_NATIONALITY_TY,
  UPDATE_USER_LIVING_YEARS_TY,
  CHECK_ABCONTACTS_JOIN_STATUS_TY,
  LOAD_NEARBY_ITEM_GROUP_TY,
  LOAD_NEARBY_ITEM_TY,
  LOAD_NEARBY_ITEM_PHOTO_TY,
  LOAD_ALBUM_PHOTO_TY,
  LOAD_NEARBY_ITEM_DETAIL_TY,
  
  GET_HOST_TY,
  CHECK_VERSION_TY,
  EVENTLIST_TY,
  EVENT_FLITER_TY,
  EVENTDETAIL_TY,
  EXIT_EVENT_TY,
  STARTUP_LIST_TY,
  ALUMNI_QUERY_TY,
  CLASS_TY,
  EVENT_CITY_LIST_TY,
  COUNTRY_TY,
  INDUSTRY_TY,
  GENDER_TY,
  ALUMNI_TY,
  IMAGE_TY,
  SIGNUP_TY,
  CHECKIN_TY,
  EVENT_CHECK_IN_UPDATE_TY,
  ADMIN_CHECK_IN_TY,
  EVENT_ADMIN_CHECK_SMS_TY,
  SIGNUP_USER_TY,
  CHECKIN_USER_TY,
  WINNER_USER_TY,
  MODIFY_EMAIL_TY,
  MODIFY_MOBILE_TY,
  CLUB_JOIN_TY,
  CLUB_QUIT_TY,
  CLUB_APPROVE_TY,
  CLUB_MANAGE_USER_TY,
  CLUB_POST_LIST_TY,
  SHARE_POST_LIST_TY,
  POST_TAG_LIST_TY,
  POST_LIKE_ACTION_TY,
  POST_UNLIKE_ACTION_TY,
  POST_LIKE_USER_LIST_TY,
  POST_FAVORITE_ACTION_TY,
  POST_UNFAVORITE_ACTION_TY,
  POST_FAVORITE_USERS_TY,
  COMMENT_LIST_TY,
  SEND_COMMENT_TY,
  CLUB_MANAGE_QUERY_USER_TY,
  CLUB_USER_DETAIL_TY,
  ALUMNI_QUERY_DETAIL_TY,
  SPONSOR_TY,
  CLUB_DETAIL_SIMPLE_TY,
  EVENT_ALUMNI_DETAIL_TY,
  FETCH_FEEDBACK_MSG_TY,
  FETCH_FEEDBACK_SUBMIT_TY,
  CLUBLIST_TY,
  CLUB_FLITER_TY,
  GROUP_FILTER_TY,
  EVENT_FILTER_TY,
  SHAKE_PLACE_THING_TY,
  SHAKE_USER_LIST_TY,
  CHART_LIST_TY,
  CHAT_USER_LIST_TY,
  CHAT_SUBMIT_TY,
  VIDEO_TY,
  VIDEO_FILTER_TY,
  VIDEO_CLICK_TY,
  LOAD_NEARBY_PLACE_LIST_TY, //////// new added /////
  LOAD_SERVICE_ITEM_TY,
  LOAD_SERVICE_CATEGORY_TY,
  LOAD_SERVICE_PROVIDER_ALBUM_PHOTO_TY,
  LOAD_SERVICE_PROVIDER_DETAIL_TY,
  ADD_PHOTO_FOR_SERVICE_ITEM_TY,
  SEND_SERVICE_ITEM_COMMENT_TY,
  LOAD_SERVICE_ITEM_COMMENT_TY,
  ADD_PHOTO_FOR_SERVICE_PROVIDER_TY,
  SEND_SERVICE_PROVIDER_COMMENT_TY,
  LOAD_SERVICE_ITEM_DETAIL_TY,
  LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY,
  LOAD_RECOMMENDED_ITEM_LIKERS_TY,
  LOAD_RECOMMENDED_ITEM_TY,
  LOAD_SERVICE_PROVIDER_COMMENT_TY,
  RECOMMENDED_ITEM_LIKE_TY,
  LOAD_BRANDS_TY,
  LOAD_BRAND_DETAIL_TY,
  LOAD_BRAND_COMMENT_TY,
  SEND_BRAND_COMMENT_TY,
  LOAD_BRAND_ALUMNUS_TY,
  
  EVENT_POST_TY,
  SEND_EVENT_DISCUSS_TY,
  LOAD_EVENT_TOPICS_TY,
  LOAD_EVENT_OPTIONS_TY,
  SUBMIT_OPTION_TY,
  LOAD_WINNER_AWARDS_TY,
  
  BACK_ALUMNI_SEARCH_TY,
  BACK_ALUMNI_ACTIVITY_TY,
  BACK_ALUMNI_CHECKIN_TY,
  
  // alumni network
  LOAD_WITH_ME_LINK_TY,
  LOAD_ALL_KNOWN_ALUMNUS_TY,
  FAVORITE_ALUMNI_TY,
  FAVORITE_ALUMNI_LINK_TY,
  LOAD_FAVORITE_ALUMNI_TY,
  LOAD_NAME_CARD_CANDIDATES_TY,
  SEARCH_NAME_CARD_TY,
  LOAD_CONNECTED_ALUMNUS_COUNT_TY,
  LOAD_ATTRACTIVE_ALUMNUS_TY,
  LOAD_KNOWN_ALUMNUS_TY,
  LOAD_JOINED_GROUPS_TY,
  LOAD_ALUMNI_NEWS_TY,
  LOAD_BIZ_NEWS_TY,
  
  // biz coop
  LOAD_BIZ_GROUPS_TY,
  LOAD_BIZ_POST_TY,
  SEND_BIZ_POST_TY,
  
  // load homepage info
  LOAD_HOMEPAGE_INFO,
  
  // video
  LOAD_LATEST_VIDEO_TY,
  
  // event
  LOAD_RECOMMENDED_EVENT_TY,
  
  // my event
  MY_EVENT_TY,
  LOAD_EVENT_AWARD_RESULT_TY,
  
  // event question
  EVENT_APPLY_QUESTIONS_TY,
  SENT_QUESTIONS_RESULT_TY,
  EVENT_SIGNUP_TY,
  
  SURVEY_DATA_TY,
  
  // pay
  PAY_DATA_TY,
  
  PAYMENT_RESULT_CHECK_TY,
  
  // startup project
  STARTUP_BACK_QUESTIONS_TY,
  STARTUP_BACK_TY,
  LOAD_PROJECT_BACKERS_TY,
  
  // supply demand
  LOAD_SUPPLY_DEMAND_ITEM_TY,
  SEND_SUPPLY_DEMAND_TY,
  SUPPLY_DEMAND_TAG_TY,
  
  // welfare
  WELFARE_TYPE_TY,
  WELFARE_LIST_TY,
  WELFARE_DETAIL_TY,
  LOAD_STORE_LIST_TY,
  LOAD_STORE_DETAIL_TY,
  LOAD_WELFARE_BRAND_DETAIL_TY,
  DOWNLOAD_COUPON_TY,
  GET_DOWNLOADED_USER_TY,
  SET_ORDER_INFO_TY,
  SET_ORDER_PAYMENT_TY,
  WELFARE_APP_PAYMENT_TY,
  FAVORITE_WELFARE_TY,
  
  // donate
  DONATE_TY,
  
  // enterprise
  ENTERPRISE_SOLUTION_TY,
  
} WebItemType;


#pragma mark - xml parser source type
typedef enum {
  LOGIN_SRC,
  
} XmlParserItemType;

typedef enum {
  TRANSPARENT_BTN_COLOR_TY = 1,
  RED_BTN_COLOR_TY,
  ORANGE_BTN_COLOR_TY,
  GRAY_BTN_COLOR_TY,
  LIGHT_GRAY_BTN_COLOR_TY,
  TINY_GRAY_BTN_COLOR_TY,
  DEEP_GRAY_BTN_COLOR_TY,
  BLUE_BTN_COLOR_TY,
  BLACK_BTN_COLOR_TY,
  WHITE_BTN_COLOR_TY,
} ButtonColorType;

typedef enum {
  SHADOW_BOTTOM = 1,
} ShadowDirectionType;

typedef enum {
  NO_ROUNDED,
  HAS_ROUNDED,
  OVAL_ROUNDED,
} ButtonRoundedType;

typedef enum {
	TRIGGERED_BY_SCROLL,
  TRIGGERED_BY_AUTOLOAD,
	TRIGGERED_BY_SORT,
} LoadTriggerType;

typedef enum {
  SORT_BY_ID_TY = 1,
  SORT_BY_COMMENT_COUNT_TY,
  SORT_BY_PRAISE_COUNT_TY,
  SORT_BY_COMMENT_TIME_TY,
  SORT_BY_CHECKIN_COUNT_TY,
  SORT_BY_MY_CO_LIKE_TY,
  SORT_BY_DISTANCE_TY,
} SortType;

typedef enum {
  SI_SORT_BY_DISTANCE_TY = 1,
  SI_SORT_BY_MY_CO_LIKE_TY = 2,
  SI_SORT_BY_COMMENT_COUNT_TY = 3,
  SI_SORT_BY_LIKE_COUNT_TY = 4,
} ServiceItemSortType;

typedef enum {
  NEWS_TY = 1,
  FEED_TY,
  QA_TY,
  COMMENT_TY,
} ItemType;

typedef enum {
	LOCATE_CURRENT_PLACE,
	LOCATE_CURRENT_CITY,
} LocateActionType;

typedef enum {
	PHOTO_BTN,
	CLOSE_BTN,
	CALL_BTN,
  BIRTHDATE_BTN,
} ActionSheetOwnerType;

typedef enum {
  TAG_TY,
  SHARING_FILTER_TY,
} ItemPropertyType;

typedef enum {
  SOLID_LINE_TY,
  ANGLE_LINE_TY,
  DASH_LINE_TY,
} SeparatorType;

typedef enum {
  ME_TY,
  OTHER_USER_TY,
  COMPANY_TY,
} ProfileType;

typedef enum {
  TWITTER_TY,
  FACEBOOK_TY,
  LINKEDIN_TY,
  ADDRESSBOOK_TY,
} UserSnsType;

typedef enum {
  ONE_STAR_LEVEL,
  TWO_STARS_LEVEL,
  THREE_STARS_LEVEL,
  FOUR_STARS_LEVEL,
  FIVE_STARS_LEVEL,
} UserGradeLevel;

typedef enum {
  POST_ITEM_LIST_TY = 1,
  VENUE_ITEM_LIST_TY,
  SENT_ITEM_LIST_TY,  // in user profile, list all user sents feeds
  ALL_ITEM_LIST_TY,   // normal feed list
} ItemListType;

typedef enum {
  CLUB_MY_POST_SHOW,
  CLUB_ALL_POST_SHOW,
} ClubPostShowType;

typedef enum {
  CLUB_SELF_VIEW,
  CLUB_POST_VIEW,
  CLUB_ALL_ALUMNUS_VIEW,
} ClubViewType;

typedef enum {
  CLUB_SELF_LIST_VIEW,
  CLUB_LIST_BY_POST_TIME,
  CLUB_LIST_BY_NAME,
} ClubListViewType;

typedef enum {
  PHONE_NUMBER_TY,
  EMAIL_TY,
  PHONE_NUMBER_EMAIL_TY,
} ContactModeType;

typedef enum {
  SORTBY_DISTANCE = 2,
  SORTBY_COMMON_RATE = 3,
  SORTBY_MY_CO_RATE = 8,
  SORTBY_COMMENTS = 5,
} NearbyItemSortType;

typedef enum {
  DISTANCE_FILTER_TY = 1,
  TIME_FILTER_TY = 2,
} FilterOptionType;

typedef enum {
  UNSELECTED_TY = 0,
  SELECTED_TY = 1,
} SelectedStatusType;

typedef enum {
  VENUE_ITEM_TY = 1,
  PEOPLE_ITEM_TY,
  POST_ITEM_TY,
} NearbyItemType;

typedef enum {
  ENTIRE_CITY = 0,
  NEARBY_2_KM = 2,
  NEARBY_5_KM = 5,
  NEARBY_10_KM = 10,
} NearbyDistanceFilter;

typedef enum {
  BEGIN_SP_LIST_TY,
  END_SP_LIST_TY,
  MIDDLE_SP_LIST_TY,
} NearbySPListIndexPositionType;

typedef enum {
  SP_MAP_INFO_TY,
  SP_INTRO_INFO_TY,
  SP_TAXI_INFO_TY,
  SP_TRANSIT_INFO_TY,
  SP_PHONE_INFO_TY,
  SP_WEBSITE_INFO_TY,
  SP_EMAIL_INFO_TY,
} ServiceProviderInfoType;

typedef enum {
  ITEM_INTRO_INFO_TY,
  ITEM_MAP_INFO_TY,
  ITEM_TAXI_INFO_TY,
  ITEM_PHONE_INFO_TY,
  ITEM_WEBSITE_INFO_TY,
} ItemInfoType;

typedef enum {
  NORMAL_SIGNUP_TY,
  CONFIRM_SIGNUP_TY,
} SignUpViewType;

typedef enum {
  LEFT_DIR_TY,
  RIGHT_DIR_TY,
} OvalSideDirectionType;

typedef enum {
  HANDY_PHOTO_TAKER_TY,
  POST_COMPOSER_TY,
  SERVICE_ITEM_PHOTO_TY,
  SERVICE_PROVIDER_PHOTO_TY,
  USER_AVATAR_TY,
  SERVICE_ITEM_AVATAR_TY,
} PhotoTakerType;

// wap page type
typedef enum {
  LINKED_BIND_WAP_TY,
  QUESTIONNAIRE_WAP_TY,
} WapType;

// user connects with third party sns result
typedef enum {
  CONNECT_FAILED_TY = -1,
  CONNECT_EXISTING_USER_TY = 200,
  CONNECT_NEW_USER_TY = 401,
} UserConnectThirdPartyResultType;

// user binds check result type
typedef enum {
  BIND_FAILED_TY = -1,
  BIND_SUCCESS_TY = 200,
  EMAIL_EXISTING_TY = 401,
  EMAIL_NEED_BIND_TY = 403, // old logic, this type of resule be considered same as 401 presently
} UserBindResultType;

// domain name type
typedef enum {
  LINKEDIN_DOMAIN_TY = 1,
  GMAIL_DOMAIN_TY,
  AWARD_DOMAIN_TY,
} DomainType;

// place type
typedef enum {
  CITY_PLACE_TY,
  NORMAL_PLACE_TY,
  RADIUS_PLACE_TY,
} PlaceType;

typedef enum {
  FAVORITE_MEMBER_TY = 1,
  FAVORITE_POST_TY = 2,
} FavoriteItemType;

typedef enum {
  UPDATE_AVAILABLE_SYS_MSG_TY = 0,
  NEW_FEATHURE_TY = 1,
  AWARD_SYS_MSG_TY = 2,
  NEW_SERVICE_MSG_TY = 3,
  USER_UPGRADE_MSG_TY = 4,
  
  EVENT_PAYMENT_MSG_TY,
  GROUP_PAYMENT_MSG_TY,
  SYSTEM_MSG_TY,
} SystemMessageType;

typedef enum {
  FOR_HOMEPAGE_NEWS_TY = 1,
  ALUMNI_NEWS_TY,
  BIZ_NEWS_TY,
} NewsType;

typedef enum {
  TOTAL_PT_TY = 0,
  SIGNUP_DONE_PT_TY,
  SENT_INVT_PT_TY,
  INVT_INVALID_PT_TY,
  PRIME_INVITOR_PT_TY,
  NONPRIME_INVITOR_PT_TY,
  POST_BE_LIKE_PT_TY,
  POST_BE_FAVORITED_PT_TY,
} PointType;

typedef enum {
  ALUMNI_USER_TY = 1,
	//CLUB_USER_TY = 2,
  NONALUMNI_USER_TY = 2,
  
  FETCH_SHAKE_USER_TY,
} UserType;

typedef enum {
  // ----- NEW SERVICE CATEGORY -----
  COUPON_CATEGORY_ID = 6ll,
  ACTIVITY_CATEGORY_ID = 2ll,
  PRO_CATEGORY_ID = 5ll,
  FOOD_DELIVERY_CATEGORY_ID = 1ll,
  RESTAURANT_CATEGORY_ID = 4ll,
  NIGHTLIFE_CATEGORY_ID = 3ll,
  JOBS_CATEGORY_ID = 7ll,
  OTHERS_CATEGORY_ID = 8ll,
  PEOPLE_CATEGORY_ID = 10ll,
} ServiceCategoryId;

typedef enum {
  SHARE_TAG_TY = 5,
  GROUP_TAG_TY = 3,
} TagCategoryType;

typedef enum {
  SHARE_TY = 100,
  THING_TY = 200,
  PLACE_TY = 300,
} TagType;

typedef enum {
  TAG_FILTER_TY,
  FAVORITE_FILTER_TY,
  DISTANTCE_FILTER_TY,
} SharingFilterType;

typedef enum {
  ONE_TY = 1,
  TWO_TY = 2,
}TagShowType;

typedef enum {
  NONE_SELECTED_TY = 0,
  ALL_CATEGORY_TY = 1,
  FAVORITED_CATEGORY_TY = 2,
}ItemFavoriteCategory;

typedef enum {
  SUPPLY_POST_TY = 1,
  DEMAND_POST_TY = 2,
  DISCUSS_POST_TY = 3,
  SHARE_POST_TY = 5,
  EVENT_DISCUSS_POST_TY = 4,
  BIZ_POST_TY = 6,
  SUPPLY_DEMAND_COMBINE_TY = 7,
} PostType;

typedef enum {
  SUPPLY_ITEM_TY = SUPPLY_POST_TY,
  DEMAND_ITEM_TY = DEMAND_POST_TY
} SupplyDemandItemType;

typedef enum {
  SPECIAL_GROUP_LIST_POST_TY = 1, // specified group post list
  JOINED_GROUP_LIST_POST_TY,      // current user joined groups post list
  ALL_GROUP_LIST_POST_TY,         // all groups post list
} PostListType;

typedef enum {
  HOME_USAGE_TY,
  SERVICE_USAGE_TY,
} UIButtonGroupUsageType;

typedef enum {
  CHECKIN_NONE_TY = -1,
  CHECKIN_FAILED_TY = 1,
  CHECKIN_OK_TY = 200,
  CHECKIN_DUPLICATE_ERR_TY = 210,
  CHECKIN_FARAWAY_TY = 211,
  CHECKIN_EVENT_OVERDUE_TY = 212,
  CHECKIN_EVENT_NOT_BEGIN_TY = 213,
  CHECKIN_NEED_CONFIRM_TY = 214,
  //CHECKIN_NOT_SIGNUP_TY,
  CHECKIN_NO_REG_FEE_TY,
} CheckinResultType;

typedef enum {
  ALUMNI_ENTERPRISE_TY,
  NON_ALUMNI_ENTERPRISE_TY,
} AlumniCompanyType;

typedef enum {
  NEED_FEE_EVENT_TY,
  FREE_EVENT_TY,
} EventRequirementType;

typedef enum {
  EVENT_APPEAR_ALUMNUS_TY,
  EVENT_DISCUSS_TY,
} EventLiveActionType;

typedef enum {
  VOTE_CLOSED_TY,
  VOTE_IN_PROCESS_TY,
} VoteStatusType;

typedef enum {
  OTHER_CATEGORY_EVENT = 0,
  TODAY_CATEGORY_EVENT = 1,
  THIS_MONTH_CATEGORY_EVENT,
} EventDateCategory;

typedef enum {
  INIT_VALUE_WINNER_TY = -1,
  NO_USER_WINNER_TY = 0,
  CURRENT_USER_WINNER_TY = 1,
  OTHER_USER_WINNER_TY = 2,
} WinnerType;

typedef enum {
  MEMBER_USER_TY,
  WANT_TO_KNOW_USER_TY,
  RECOMMEND_USER_TY,
  KNOWN_USER_TY,
} UserListType;

typedef enum {
  ORDINARY_FRIEND_TY,
  WANT_TO_KNOW_TY,
  MAYBE_KNOWN_TY,
  KNOWN_TY,
} AlumniRelationshipType;

typedef enum {
  BIZ_DISCUSS_USAGE_GP_TY,
  BIZ_JOINED_USAGE_GP_TY,
  BIZ_POPULAR_USAGE_GP_TY,
  ORDINARY_USAGE_GP_TY,
} GroupUsageType;

typedef enum {
  GREENT_ITEM_TY,
  YELLOW_ITEM_TY,
} AlumniEntranceItemColorType;

typedef enum {
  BIZ_1_PAGE_IDX = 0,
  BIZ_2_PAGE_IDX,
} BizCoopPageIndex;

typedef enum {
  NONE_SHARED_TY,
  SHARED_EVENT_TY,
  SHARED_BRAND_TY,
  SHARED_VIDEO_TY,
  SHARED_WELFARE_TY,
} SharedItemType;

typedef enum {
  FREE_PAY_TY,
  NEED_FEE_PAY_TY,
  RENEWALS_PAY_TY,
} GroupPayType;

typedef enum {
  NONE_PUSH_TY = 0,
  
  DM_MSG_PUSH_TY = 1,
  NEW_POST_PUSH_TY = 2,
  
  NEW_SUPPLY_DEMAND_PUSH_TY = 3,
  
  NEW_EVENT_PUSH_TY = 4,
  REMIND_EVENT_PUSH_TY = 6,
  
  NEW_WELFARE_PUSH_TY = 5,
} PushMessageType;

typedef enum {
  WELFARE_PAYMENT_TY,
  GROUP_PAYMENT_TY,
  EVENT_PAYMENT_TY,
} PaymentItemType;

typedef enum {
  ALL_WF_TY,
  HOTEL_WF_TY,
  LEISURE_WF_TY,
  LIFE_WF_TY,
  TRAVEL_WF_TY,
  FOOD_WF_TY,
  FAVORITE_WF_TY
} WelfareIndustryType;

typedef enum {
  NORMAL_TRIGGER_TY,
  SHARE_ITEM_TRIGGER_TY,
  PUSH_TRIGGER_TY,
} AppOpenTriggerType;

#pragma mark - system
#define IOS5_1  5.1f
#define IOS4_2  4.2f
#define EC_STATIC_INLINE	static inline
#define HAS_CAMERA        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
#define APP_STORE_URL               @"http://itunes.apple.com/us/app/ialumni/id543840943?ls=1&mt=8"
#define APP_INNER_DOWNLOAD_URL      @"http://weixun.co/ialumni"
#define WECHAT_ITUNES_URL           @"https://itunes.apple.com/app/id414478124?mt=8&ls=1"
#define CONFIGURABLE_DOWNLOAD_URL   @"%@event?action=page_load&page_name=alumni_app_download&locale=%@&channel=%d"

#pragma mark - language
#define LANG_CN_TY  @"zh"   //zh-Hans
#define LANG_EN_TY  @"en"

#pragma mark - object handle
#define RELEASE_OBJ(__POINTER) { if (__POINTER) { [__POINTER release]; __POINTER = nil; }}
#define AUTO_RELEASED_CTREFOBJ(CTValue)  ((void*)[(id)(CTValue) autorelease])

#pragma mark - common stuff
#define ITEM_LOAD_COUNT   @"20"
#define STR_FORMAT(args...)         [NSString stringWithFormat:args]
#define INT_TO_STRING(_INT_VALUE)   STR_FORMAT(@"%d", _INT_VALUE)
#define LLINT_TO_STRING(_LLINT_VALUE)   [NSString stringWithFormat:@"%lld", _LLINT_VALUE]
#define FLOAT_TO_STRING(_FLOAT_VALUE)   [NSString stringWithFormat:@"%f", _FLOAT_VALUE]
#define DOUBLE_TO_STRING(_DOUBLE_VALUE) [NSString stringWithFormat:@"%f", _DOUBLE_VALUE]
#define LOCDATA_TO_STRING(_DOUBLE_VALUE) [NSString stringWithFormat:@"%.8f", _DOUBLE_VALUE]
#define RADIANS( degrees )			( degrees * M_PI / 180 )

#pragma mark - TableView properties
#define PLAIN_TABLE_NO_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH     266.0f
#define PLAIN_TABLE_NO_IMAGE_ACCESS_NONE_WIDTH                300.0f
#define GROUPED_TABLE_NO_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH   216.0f
#define GROUPED_TABLE_NO_TITLE_IMAGE_ACCESS_NONE_WIDTH        270.0f

#define PLAIN_TABLE_WITH_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH   232.0f
#define PLAIN_TABLE_WITH_IMAGE_ACCESS_NONE_WIDTH              246.0f
#define GROUPED_TABLE_WITH_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH 232.0f
#define GROUPED_TABLE_WITH_TITLE_IMAGE_ACCESS_NONE_WIDTH      236.0f

#define HEADER_CELL_TITLE_FONT    BOLD_FONT(13)
#define COMMON_CELL_TITLE_FONT    BOLD_FONT(14)
#define COMMON_CELL_CONTENT_FONT  BOLD_FONT(13)
#define COMMON_CELL_SUBTITLE_FONT BOLD_FONT(12)
#define DEFAULT_CELL_HEIGHT             44.0f
#define PEOPLE_CELL_HEIGHT              90.0f
#define DEFAULT_HEADER_CELL_HEIGHT      20.0f
#define CELL_TITLE_IMAGE_SIDE_LENGTH    24.0f
#define GROUPED_CELL_CORNER_RADIUS      4.0f
#define DARK_CELL_COLOR                 COLOR(219, 219, 219)
#define CELL_COLOR                      COLOR(239, 239, 239)
#define LIGHT_CELL_COLOR                COLOR(245, 245, 245)
#define SERVICE_ITEM_CELL_COLOR         COLOR(247.0f, 247.0f, 247.0f)
#define HIGHLIGHT_TEXT_CELL_COLOR       COLOR(240.0f, 240.0f, 240.0f)
#define CELL_BORDER_COLOR               COLOR(224, 224, 224)
#define CELL_TITLE_COLOR COLOR(30.0f, 30.0f, 30.0f)
#define GROUP_STYLE_CELL_CORNER_RADIUS  10.0f

#define TABLE_ACCESSOR_ARROW_WIDTH      9.0f
#define TABLE_ACCESSOR_ARROW_HEIGHT     14.0f

/*
 typedef enum {
 LinePositionTop = 0,
 LinePositionBottom,
 } LinePosition;
 */

#pragma mark - UI constants
//#define BOLD_ITALIC_FONT(aSize)     [UIFont fontWithName:@"Arial-BoldItalicMT" size:aSize];
#define ITALIC_FONT(aSize)          [UIFont fontWithName:@"Arial-ItalicMT" size:aSize]
#define Arial_FONT(aSize)           [UIFont fontWithName:@"Arial" size:aSize]
#define TIMESNEWROM_ITALIC(aSize)   [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:aSize]
#define TIMESNEWROM_BOLD_ITALIC(aSize)   [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:aSize]
#define BOLD_HK_FONT(aSize)         [UIFont fontWithName:@"HiraKakuProN-W6" size:aSize]
#define HK_FONT(aSize)              [UIFont fontWithName:@"HiraKakuProN-W3" size:aSize]


#define COLOR(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGB_SEPARATOR   @"-"
#define RGB_COMPONENT_COUNT 3
#define COLOR_ALPHA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define COLOR_HSB(h, s, b, fact) [UIColor colorWithHue:(h/360.0) saturation:(s/100.0) brightness:((b/100.0)*fact) alpha:1.0]
#define SAFECOLOR(color) MIN(255,MAX(0,color))

#define FADE_IN_DURATION            0.5f
#define FADE_OUT_DURATION           1.0f

#define MARGIN                      5.0f

#define WELFARE_CELL_MARGIN         MARGIN * 3

#define LEFT_TOOLBAR_HEIGHT             85.0f
#define HOMEPAGE_TAB_HEIGHT             40.0f //48.0f
#define TABLE_BACKGROUND_COLOR          COLOR(240,248,255)

#define SEPARATOR_LINE_COLOR            COLOR(158,161,168)

#define TITLESTYLE_COLOR                COLOR(180,18,21)
#define SUBTITLESTYLE_COLOR             COLOR(161,167,170)
#define BACKGROUND_COLOR                COLOR(239, 239, 239)//COLOR(229,229,231)

#define RED_BTN_BORDER_COLOR            COLOR(205,50,6)
#define RED_BTN_TITLE_COLOR             COLOR(238,92,66)
#define RED_BTN_TITLE_SHADOW_COLOR      [UIColor whiteColor]
#define RED_BTN_TOP_COLOR               COLOR(255,250,205)
#define RED_BTN_BOTTOM_COLOR            COLOR(255,193,37)

#define ORANGE_BTN_BORDER_COLOR         COLOR(205,50,6)
#define ORANGE_BTN_TITLE_COLOR          [UIColor whiteColor]
#define ORANGE_BTN_TITLE_SHADOW_COLOR   [UIColor blackColor]
#define ORANGE_BTN_TOP_COLOR            COLOR(255,250,205)
#define ORANGE_BTN_BOTTOM_COLOR         COLOR(255,193,37)

#define BLUE_BTN_BORDER_COLOR           COLOR(16,78,139)
#define BLUE_BTN_TITLE_COLOR            [UIColor whiteColor]
#define BLUE_BTN_TITLE_SHADOW_COLOR     [UIColor blackColor]
#define BLUE_BTN_TOP_COLOR              COLOR(209,238,238)
#define BLUE_BTN_BOTTOM_COLOR           COLOR(79,148,205)

#define GRAY_BTN_BORDER_COLOR           [UIColor darkGrayColor]
#define GRAY_BTN_TITLE_COLOR            [UIColor darkGrayColor]
#define GRAY_BTN_TITLE_SHADOW_COLOR     [UIColor whiteColor]
#define GRAY_BTN_TOP_COLOR              [UIColor whiteColor]
#define GRAY_BTN_BOTTOM_COLOR           [UIColor lightGrayColor]

#define DARK_GRAY_BTN_TOP_COLOR         COLOR(77, 78, 80)
#define DARK_GRAY_BTN_BOTTOM_COLOR      COLOR(25, 25, 25)

#define DEEP_GRAY_BTN_BORDER_COLOR            COLOR(213,213,213)

#define LIGHT_GRAY_BTN_BORDER_COLOR           COLOR(186,186,186)
#define LIGHT_GRAY_BTN_TITLE_COLOR            COLOR(106,106,106)
#define LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR     COLOR(255,255,255)
#define LIGHT_GRAY_BTN_TOP_COLOR              COLOR(240,240,240)
#define LIGHT_GRAY_BTN_BOTTOM_COLOR           COLOR(211,211,212)

#define BLACK_BTN_BORDER_COLOR                COLOR(116,116,116)
#define BLACK_BTN_TITLE_COLOR                 [UIColor whiteColor]
#define BLACK_BTN_TITLE_SHADOW_COLOR          [UIColor blackColor]

#define ZERO_EDGE                       UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)

#define BASE_INFO_COLOR                 COLOR(130, 130, 140)
#define MAIN_LABEL_COLOR                COLOR(131, 131, 133)
#define PROFILE_TITLE_COLOR             COLOR(123, 124, 126)
#define PROFILE_VALUE_COLOR             COLOR(135, 26, 24)
#define ORANGE_COLOR                    COLOR(233, 80, 55)
#define CELL_BASE_INFO_HEIGHT           16.0f
#define PHOTO_SIDE_LENGTH               40.0f
#define IMAGE_SIDE_LENGTH               70.0f

#define PHOTO_LONG_LEN_IPHONE   180//280
#define PHOTO_SHORT_LEN_IPHONE	135//210
#define	PHOTO_LONG_LEN_1G3G     600
#define PHOTO_SHORT_LEN_1G3G    450
#define	PHOTO_LONG_LEN_3GS      640
#define PHOTO_SHORT_LEN_3GS     480
#define	PHOTO_LONG_LEN_4G       680
#define PHOTO_SHORT_LEN_4G      510
#define	PHOTO_LONG_LEN_5G       800
#define PHOTO_SHORT_LEN_5G      450



#define POST_IMG_LONG_SIDE      80.0f
#define POST_IMG_SHORT_SIDE     60.0f

#define FRONT_PHOTO_LONG_LEN    640.0f
#define FRONT_PHOTO_SHORT_LEN   480.0f

#define ITEM_PROPERTY_CELL_HEIGHT       40.0f

#define IMG_LONG_LEN_IPHONE        180.0f//280
#define IMG_SHORT_LEN_IPHONE       135.0f//210

#define FEED_IMG_LONG_LEN_IPHONE   240.0f
#define FEED_IMG_SHORT_LEN_IPHONE  180.0f

#define KEYBOARD_GAP                    20.0f

#define HOME_PAGE_BTN_WIDTH   105.0f
#define HOME_PAGE_BTN_HEIGHT  110.0f
#define SEPARATOR_THICKNESS   2.0f

#define DARK_TEXT_COLOR  COLOR(98, 87, 87)

#define NUMBER_BADGE_TOP_COLOR    COLOR(231,50,47)
#define NUMBER_BADGE_BOTTOM_COLOR COLOR(231,50,47)
#define NUMBER_BADGE_HEIGHT       20.0f

#pragma mark - notification names
#define WEB_CONTENT_LOADED_NOTIFY       @"WEB_CONTENT_LOADED_NOTIFY"
#define WEB_CONTENT_HEIGHT_KEY          @"WEB_CONTENT_HEIGHT_KEY"
#define IMAGE_LOADED_NOTIFY             @"IMAGE_LOADED_NOTIFY"
#define NEWS_IMAGE_INFO_KEY             @"NEWS_IMAGE_INFO_KEY"
#define NEWS_IMAGE_ORIENTATION_KEY      @"NEWS_IMAGE_ORIENTATION_KEY"
#define IMAGE_HEIGHT_KEY                @"IMAGE_HEIGHT_KEY"
#define TEXT_CONTENT_HEIGHT_KEY         @"TEXT_CONTENT_HEIGHT_KEY"
#define TEXT_CONTENT_LOADED_NOTIFY      @"TEXT_CONTENT_LOADED_NOTIFY"
#define CLEAR_HANDY_IMAGE_BROWSER_NOTIF @"CLEAR_HANDY_IMAGE_BROWSER_NOTIF"
#define FEED_DELETED_NOTIFY             @"FEED_DELETED_NOTIFY"
#define QUESTION_DELETED_NOTIFY         @"QUESTION_DELETED_NOTIFY"
#define UPDATE_NEWS_LIST_NOTIFY         @"UPDATE_NEWS_LIST_NOTIFY"
#define TRACE_REVIEWING_NEWS_NOTIFY     @"TRACE_REVIEWING_NEWS_NOTIFY"
#define REVIEWING_NEWS_KEY              @"REVIEWING_NEWS_KEY"
#define CONN_CANCELL_NOTIFY             @"CONN_CANCELL_NOTIFY"
#define REFRESH_NEARBY_NOTIFY           @"REFRESH_NEARBY_NOTIFY"

#define DISPLAY_LIKE_ALBUM_NOTIFY       @"DISPLAY_LIKE_ALBUM_NOTIFY"
#define HIDE_LIKE_ALBUM_NOTIFY          @"HIDE_LIKE_ALBUM_NOTIFY"

#define EMBEDDED_COMMENT_LOADED_NOTIFY  @"EMBEDDED_COMMENT_LOADED_NOTIFY"
#define EMBEDDED_COMMENT_LOADED_INDEXPATH_KEY @"EMBEDDED_COMMENT_LOADED_INDEXPATH_KEY"

#define NO_ALUMNI_NEWS_NOTIFY           @"NO_ALUMNI_NEWS_NOTIFY"

#define DM_PUSH_EVENT_NOTIFY            @"DM_PUSH_EVENT_NOTIFY"
#define DM_PUSH_RECEIVED_NOTIFY         @"DM_PUSH_RECEIVED_NOTIFY"
#define DM_SENDER_ID_KEY                @"DM_SENDER_ID_KEY"
#define DM_MESSAGE_BODY_KEY             @"DM_MESSAGE_BODY_KEY"
#define DM_REFRESH_IN_PERSONAL_VIEW_KEY @"DM_REFRESH_IN_PERSONAL_VIEW_KEY"
#define DM_REFRESH_IN_CHAT_ALUMNUS_KEY  @"DM_REFRESH_IN_CHAT_ALUMNUS_KEY"

#pragma mark - local user default storage
#define USER_ID_LOCAL_KEY               @"USER_ID_LOCAL_KEY"
#define USER_NAME_LOCAL_KEY             @"USER_NAME_LOCAL_KEY"
#define USER_EMAIL_LOCAL_KEY            @"USER_EMAIL_LOCAL_KEY"
#define USER_ACCESS_TOKEN_LOCAL_KEY     @"USER_ACCESS_TOKEN_LOCAL_KEY"
#define SYSTEM_LANGUAGE_LOCAL_KEY       @"SYSTEM_LANGUAGE_LOCAL_KEY"
#define USER_CITY_ID_LOCAL_KEY          @"USER_CITY_ID_LOCAL_KEY"
#define USER_CITY_NAME_LOCAL_KEY        @"USER_CITY_NAME_LOCAL_KEY"
#define USER_COUNTRY_ID_LOCAL_KEY       @"USER_COUNTRY_ID_LOCAL_KEY"
#define USER_COUNTRY_NAME_LOCAL_KEY     @"USER_COUNTRY_NAME_LOCAL_KEY"
#define FONT_SIZE_LOCAL_KEY             @"FONT_SIZE_LOCAL_KEY"
#define HOST_LOCAL_KEY                  @"HOST_LOCAL_KEY"
#define HOMEPAGE_HANDY_NOTIFY_LOCAL_KEY @"HOMEPAGE_HANDY_NOTIFY_LOCAL_KEY"
#define NEWS_FAV_HANDY_NOTIFY_LOCAL_KEY @"NEWS_FAV_HANDY_NOTIFY_LOCAL_KEY"
#define SWIPE_HANDY_NOTIFY_LOCAL_KEY    @"SWIPE_HANDY_NOTIFY_LOCAL_KEY"
#define LOADING_NOTIFY_LOCAL_KEY        @"LOADING_NOTIFY_LOCAL_KEY"
#define ENTERPRISE_SOLUTION_NAME_LOCAL_KEY @"ENTERPRISE_SOLUTION_NAME_LOCAL_KEY"

#pragma mark - images
// image
#define PNG_POSTFIX                   @"png"
#define JPG_POSTFIX                   @"jpg"
#define GIF_POSTFIX                   @"gif"
#define WEBVIEW_IMG_URL               @"//image"
#define LOADING_IMG_HEIGHT            36.0f
#define ADD_PHOTO_BUTTON_SIDE_LENGTH  216.0f
#define APPLE_SCHEME                  @"applewebdata"
#define WEBVIEW_IMG_URL               @"//image"
#define SELECTED_IMG                  [UIImage imageNamed:@"selected.png"]
#define UNSELECTED_IMG                [UIImage imageNamed:@"unselected.png"]
#define RADIO_IMG                     [UIImage imageNamed:@"radioButton.png"]
#define RADIO_BUTTON_IMG              [UIImage imageNamed:@"radioButton.png"]
#define NO_IMAGE_FLAG                 @"no_image_url_"

#pragma mark - place/city
#define OTHER_CITY_ID             @"1"
#define ALL_RADIUS_PLACE_ID       @"0000"
#define WITHIN2KM_PLACE_ID        @"0001"
#define WITHIN5KM_PLACE_ID        @"0002"
#define WITHIN10KM_PLACE_ID       @"0003"
#define ALL_LOCATION_RADIUS       0.0f

#pragma mark - group
#define ALL_SCOPE_GP_ID           0

#pragma mark - country
#define CO_ALL_ID                 0ll
#define PLACE_ALL_ID              0ll

#pragma mark - industry
#define INDUSTRY_ALL_ID           @"A:AA"
#define INDUSTRY_ALL_CN_NAME      @"全部"
#define INDUSTRY_ALL_EN_NAME      @"All"

#pragma mark - tag
#define CENTER_ITEM_ID            0ll
#define TAG_ALL_ID                0ll
#define ITEM_TAG_ID_SEPARATOR     @","

#pragma mark - comment
#define COMMENT_AUTHOR_HEIGHT               20.0f
#define COMMENT_WITH_IMG_CELL_MIN_HEIGHT    106.0f
#define COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT 60.0f


#pragma mark - take photo
#define EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT     70.0f


#pragma mark - hot news
#define NEWS_CEL_HEIGHT             106.0f

// table refreshment
#define HEADER_TRIGGER_OFFSET           65.0f
#define FOOTER_TRIGGER_OFFSET_IPHONE	330.0f
#define FOOTER_TRIGGER_OFFSET_IPAD		854.0f
#define NEWS_DETAIL_CONTENT_WIDTH     300.0f

#pragma mark - qaItem
#define FEED_CELL_HEIGHT            70.0f
#define FEED_DETAIL_CONTENT_WIDTH   250.0f
#define EMBED_MAP_WIDTH             250.0f
#define EMBED_MAP_HEIGHT            90.0f
#define LIKE_PEOPLE_ALBUM_HEIGHT    60.0f

#define MAX_DISPLAYED_COMMENT_COUNT 3

#define TOOL_TITLE_HEIGHT           40.0f

#pragma mark - service content
#define ALL_CATEGORY_GROUP_ID         0ll
#define ALL_CATEGORY_GROUP_SORT_KEY   0

#define NEARYBY_ALL_CATEGORY_GORUP_IMG_URL   @"NEARBY_ALL_CATEOGRY"
#define ALBUM_ROW_PHOTO_COUNT         3

#define ITEM_COUPON_SEC            @"COUPON_SEC"
#define ITEM_RECOMMENDED_ITEM_SEC  @"RECOMMENDED_ITEM_SEC"
#define ITEM_CONTACT_SEC           @"CONTACT_SEC"
#define ITEM_ADDRESS_SEC           @"ADDRESS_SEC"
#define ITEM_INTRO_SEC             @"INTRO_SEC"
#define ITEM_COMMENT_SEC           @"COMMENT_SEC"
#define ITEM_SPECIAL_SEC           @"SPECIAL_SEC"
#define ITEM_BRANCH_SEC            @"BRANCH_SEC"

enum {
  SI_INTRO_SEC_BIO_CELL = 1,
  SI_INTRO_SEC_SP_CELL,
  
  SI_RECOMMENDED_SEC_CELL,
  
  SI_COMMENT_SEC_CELL,
  
  SI_MAP_SEC_ADDRESS_CELL,
  SI_MAP_SEC_TAXI_CELL,
  SI_MAP_SEC_TRANSIT_CELL,
  
  SI_CONTACT_SEC_PHONE_CELL,
  SI_CONTACT_SEC_WEB_CELL,
  SI_CONTACT_SEC_EMAIL_CELL,
  
  SI_BRANCH_SEC_CELL,
};

#define PHOTO_ONE_CELL_HEIGHT            112.f

#pragma mark - nearby
#define ALL_CATEGORY_GROUP_ID         0ll
#define ALL_CATEGORY_GROUP_SORT_KEY   0

#define NEARYBY_ALL_CATEGORY_GORUP_IMG_URL   @"NEARBY_ALL_CATEOGRY"
#define ALBUM_ROW_PHOTO_COUNT        3

#define NEARBY_PEOPLE_SORTBY_DISTANCE_TY  @"distance"
#define NEARBY_PEOPLE_SORTBY_TIME_TY      @"datetime"

#pragma mark - user profile
#define USER_PROF_BUTTONS_BACKGROUND_HEIGHT   90.0f
#define AUTHOR_AREA_HEIGHT                    55.0f

#define BUTTON_TEXT_VIEW_HEIGHT               90.0f

#define SEPARATE_FLAG             @"#==#"

#define SNS_LINKEDIN_TY           @"linkedin"

#pragma mark - event stuff

#define PAYMENT_RESPCODE_START_SEPARATOR  @"<respCode>"
#define PAYMENT_RESPCODE_END_SEPARATOR  @"</respCode>"

#pragma mark - payment stuff
#define EVENT_PAYMENT_SUFFIX    @"#Event/Detail"
#define GROUP_PAYMENT_SUFFIX    @"#Group/Detail"
#define WELFARE_PAYMENT_SUFFIX  @"#welfare/payment"

typedef enum {
  ENTRANCE_TAG,
  //ALUMNI_TAG,
  BIZ_TAG,
  EVENT_TAG,
  MORE_TAG,
} EventEntranceItemTagType;

typedef enum {
  NOT_SHOW_CHANGE_AREA_TY = -1,   // 只显示加入与退出，不显示费用信息
  NOT_JOIN_WECHAT_BTN_TY = 1,		// 未加入，显示协会费用信息，无缴费按钮
	NOT_PAY_WECHAT_BTN_TY = 2,		// 已加入，但未缴费，显示协会费用信息和“马上缴费”按钮；
	NEED_RENEW_WECHAT_BTN_TY = 3,  	// 已加入，已缴费，显示协会费用信息和已缴费状态、会员资格过期时间，和“马上续费”按钮
	PAID_WECHAT_BTN_TY = 4,			// 已加入，已经缴费，显示协会费用信息和已缴费状态、会员资格过期时间
  EXPIRED_WECHAT_BTN_TY = 5,      // 已加入，已过期，显示协会费用信息和“马上续费”按钮；
	JOINED_FREE_GROUP_BTN_TY = 6, 	// 已加入了一个免费群组
} MEMBER_PAY_STATE;

typedef enum {
  EXPIRED_BTN_TY = -1,
  SIGNUP_BTN_TY = 1,
  PAYMENT_BTN_TY,
  CHECKIN_BTN_TY,
  EXIT_EVENT_BTN_TY = 5,
} EventActionButtonType;

typedef enum {
  EXHIBITION_WF_TY, // 商品展示
  COUPON_WF_TY,     // 优惠
  BUY_WF_TY,        // 团购
} WelfareCategoryType;

typedef enum {
  ORDER_WF_SALES_TY = 1,
  BUY_WF_SALES_TY = 2,
  SOLD_OUT_WF_SALES_TY = 3,
} WelfareItemSalesStatusType;

#pragma mark - from xml data type
typedef enum {
  DATA_ID = 0,
  DATA_TYPE,
  DATA_NAME,
  DATA_VALUE,
  DATA_ISREQUIRED,
  DATA_SORT,
} FromXMLDataType;

#define EVENT_ID_FLAG          @"event_id||"
#define SHARED_ITEM_KV_SEPARATOR        @"||"
#define EVENT_TYPE_FLAG           @"event_type||"
#define BRAND_ID_FLAG             @"brand_id||"
#define VIDEO_ID_FLAG             @"video_id||"
#define WELFARE_ID_FLAG           @"welfare_id||"
#define EVENT_FIELD_SEPARATOR     @"^^"
#define FAKE_EVENT_INTERVAL_DAY   -1
#define FULL_WIDTH_COMMA          @","
#define HALF_WIDTH_COMMA          @"，"

#pragma mark - activity view
#define ACTIVITY_BACKGROUND_WIDTH   120.0f
#define ACTIVITY_BACKGROUND_HEIGHT	120.0f
#define LOADING_LABEL_WIDTH         100.0f
#define LOADING_LABEL_HEIGHT        40.0f
#define	ACTIVITY_DURA_TIME          0.3f

#pragma mark - pick view
#define PICKER_ROW_HEIGHT           40.0f
#define iOriginalSelIndexVal        -1

#define PickerOne 0
#define PickerTwo 1

#pragma mark - core data
#define COREDATA_SQLITE_FILE        @"ECCoreData"
#define SELECTED_PREDICATE          [NSPredicate predicateWithFormat:@"(selected == 1)"]

#pragma mark - network
#define HOST_TYPE                   6
#define HTTP_RESP_OK                200
#define IALUMNI_FORM_BOUNDARY       @"IALUMNI_iOS"
#define POST                        @"POST"
#define GET                         @"GET"
#define FORM_AUTH_VALUE             @"application/x-www-form-urlencoded"
#define HTTP_HEADER_FIELD           @"Content-Type"
#define HTTP_HEADER_LEN             @"Content-Length"
#define PHONE_CONTROLLER            @"/phone_controller"
#define HTTP_PRIFIX                 @"http"
#define HTTPS_PRIFIX                @"https"
#define TEL_PRIFIX                  @"tel"

#define ENCODE_URL(_UNENCODED_URL)  (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)_UNENCODED_URL, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8)

#define LINKEDIN_DONE_URL           @"action=sign_finish"
#define BIND_REFUSED_URL            @"oauth_problem=user_refused"
#define REDIRECT_URL                @"redirect_url="

#define SELF_CLASS_TYPE             @"3"

#define NEWS_H5_URL                 @"http://wx.xiehuibang.cn/HtmlApps/html/public/newsZone/pubNewsList.html?customerId=e8d493df47b94b3681a198c622c179f3"
#define DONATION_H5_URL             @"http://wx.xiehuibang.cn/HtmlApps/html/public/fundraisingZone/pubFundHome.html?customerId=e53b02c247c74be7b734fc08fd2ae049"
#define EVENT_H5_URL                @"http://wx.xiehuibang.cn:9004/HtmlApps/html/public/activityZone/eventList.html?customerId=e8d493df47b94b3681a198c622c179f3"
#define HOME_EVENT_H5_URL           @"http://wx.xiehuibang.cn:9004/HtmlApps/html/public/recruitZone/PubJobRecruitment.html?customerId=e53b02c247c74be7b734fc08fd2ae049"

#pragma mark - Global URL
#define HOST_URL                    @"http://alumniapp.ceibs.edu:8080/ceibs"
#define GET_HOST_URL                @"http://weixun.co/ceibs_url.php"
//#define HOST_URL                    @"http://alumniapp.ceibs.edu:8080/ceibs_test/"
//#define GET_HOST_URL                @"http://weixun.co/ceibs_url_test.php"
#define ERROR_LOG_UPLOAD_URL        @"http://www.weixun.co/error_upload.php"
#define SYSTEM_MSG_URL              @"/phone_controller?action=get_system_messages"

#define NO_PAGE_URL                 @"/wap/no_page.jsp"
#define ICON_IMAGE_URL              @"http://www.jitmarketing.cn/cn/ceibs/ios/Icon.png"

#pragma mark - Login
#define RESET_PSWD_URL              @"/phone_controller?action=get_reset_pwd"
#define LOGIN_HELP_URL              @"/wap/signin_help_list.jsp"
#define ALUMNI_LOGIN_REQ_URL        @"/phone_controller?action=signin_ceibs"
#define REFRESH_SESSION_REQ_URL     @"/phone_controller?action=get_new_sessionId"
#define ALUMNI_CHECK_ROLE_REQ_URL   @"http://interact.ceibs.edu/AlumniMobileWebService/checkAlumniRole.do"
#define WECHAT_PUBLIC_NO_URL        @"http://weixin.qq.com/r/EXU6NX3Eg0P8h2xWnyA1"

#pragma mark - Report & UpComing
#define ALUMNI_NEWS_PAST_REQ_URL    @"/phone_controller?action=ceibs_activity_report"
#define ALUMNI_EVENT_Future_REQ_URL @"/phone_controller?action=ceibs_activity_notice"

#define DONATE_URL                  @"/phone_controller?action=donate"

#pragma mark - Event
#define ALUMNI_EVENT_REQ_URL        @"/phone_controller?action=event_list_v2"
#define EVENT_CITY_LIST_URL         @"/phone_controller?action=event_city_list"
#define EVENT_FLITER_URL            @"/phone_controller?action=event_host_type_list"
#define CLUB_LIST_URL               @"/phone_controller?action=host_list_v2"
#define EXIT_EVENT_URL              @"/phone_controller?action=exit_event"
#define EVENT_DETAIL_URL            @"/phone_controller?action=event_detail"
#define EVENT_CHECKIN_URL           @"/phone_controller?action=event_checkin_list"
#define EVENT_APPLY_URL             @"/phone_controller?action=event_apply_list"
#define EVENT_SPONSOR_URL           @"/phone_controller?action=event_host_detail"
#define CLUB_DETAIL_SIMPLE_URL      @"/phone_controller?action=host_detail_simple"
#define EVENT_WINNER_URL            @"/phone_controller?action=event_winner_list"
#define EVENT_CHECK_IN_URL          @"/phone_controller?action=checkin2"
#define EVENT_CHECK_IN_UPDATE_URL   @"/phone_controller?action=checkin_update_wapuser"
#define EVENT_ADMIN_CHECK_IN_URL    @"/phone_controller?action=admin_checkin2"
#define EVENT_ADMIN_CHECK_SMS_URL   @"/phone_controller?action=version_download_sms_inform"
#define MODIFY_MOBILE_URL           @"/phone_controller?action=update_ceibsuser_mobile"
#define MODIFY_EMAIL_URL            @"/phone_controller?action=update_ceibsuser_email"
#define EVENT_DISCUSS_POST_URL      @"/phone_controller?action=post_list"
#define EVENT_TOPIC_LIST_URL        @"/phone_controller?action=pool_list"
#define TOPIC_OPTION_LIST_URL       @"/phone_controller?action=pool_detail"
#define SUBMIT_OPTION_URL           @"/phone_controller?action=pool_submit"

#define SUPPLY_DEMAND_LIST_URL      @"/phone_controller?action=supply_demand_list"
#define SUPPLY_DEMAND_TAG_LIST_URL  @"/phone_controller?action=post_tag_list_v2"

#define EVENT_CHECKIN_USERS_SHOW_URL @"http://alumniapp.ceibs.edu:8080/ceibs_test/wap/check_person_foripd.jsp?user_id=qronghao.e08sh2&sessionId=2012071416590162643&locale=zh&event_id=10028"

#pragma mark - Query
#define ALUMNI_QUERY_REQ_URL        @"/phone_controller?action=query_ceibs_user_30astrict"
#define ALUMNI_CLASS_REQ_URL        @"http://interact.ceibs.edu/AlumniMobileWebService/getClassesForAlumni.do"
#define ALUMNI_NATION_REQ_URL       @"http://interact.ceibs.edu/AlumniMobileWebService/getNationsForAlumni.do"
#define ALUMNI_INDUSTRY_REQ_URL     @"http://interact.ceibs.edu/AlumniMobileWebService/getIndustriesForAlumni.do"

#define ALUMNI_DETAIL_REQ_URL       @"http://interact.ceibs.edu/AlumniMobileWebService/getAlumniDetailInfo.do"
#define ALUMNI_DETAIL_URL           @"/phone_controller?action=alumnus_detail"

#define ALUMNI_DETAIL_REQ_TEMP_URL  @"/phone_controller?action=query_user_info"

#define SOFT_VERSION_CHECK_URL      @"/phone_controller?action=message_get"

#define SIGN_OUT_URL                @"/phone_controller?action=sign_out"

#define EVENT_SHARE_URL             @"/event?action=page_load&page_name=file_list"
#define EVENT_DESC_URL              @"/event?action=page_load&page_name=wap_active_detail"

#define COOPRATION_SAMPLE_URL       @"http://www.weixun.co/coopration_sample.php?"
#define SURVEY_URL                  @"/event?action=page_load&page_name=xindian_survey&appKey=1e381acda355d88126bac8f5cf37145e&appSecret=10bfb91be8a83b10ba4095bec0105f38"
#define VIDEO_URL                   @"/phone_controller?action=get_videos"
#define VIDEO_FILTER_URL            @"/phone_controller?action=get_video_filters_sort_option"
#define VIDEO_CLICK_URL             @"/phone_controller?action=update_video_clicks"

#define DELETE_SHARE_POST_URL       @"/phone_controller?action=event_delete_post"
#define DELETE_COMMENT_URL          @"/phone_controller?action=event_delete_comment"

#define GROUP_FILTER_URL           @"/phone_controller?action=group_sort_filter_list"
#define EVENT_FILTER_URL           @"/phone_controller?action=event_sort_filter_list"

#pragma mark - ClubDetail
#define SPONSOR_JOIN_URL            @"/event?action=page_load&page_name=host_join"
#define EVENT_SERVICE_PLAN_URL      @"/event?action=host_service_plan"
#define EVENT_CONSTITUTION_URL      @"/event?action=host_articles"
#define EVENT_COUNCIL_LIST_URL      @"/event?action=host_council"

#pragma mark - Club
#define CLUB_FLITER_URL             @"/phone_controller?action=host_type_list"
#define CLUB_JOIN_URL               @"/phone_controller?action=host_join"
#define CLUB_QUIT_URL               @"/phone_controller?action=host_exit"
#define CLUB_APPROVE_URL            @"/phone_controller?action=host_approve"
#define CLUB_USER_DETAIL_URL        @"/phone_controller?action=member_alumnus_detail"
#define CLUB_MANAGE_USER_URL        @"/phone_controller?action=host_member_list"
#define CLUB_MANAGE_QUERY_USER_URL  @"/phone_controller?action=query_ceibs_user"
#define CLUB_POST_LIST_URL          @"/phone_controller?action=post_list"
#define POST_URL                    @"/FileUploadServlet"
#define POST_TAG_LIST_URL           @"/phone_controller?action=post_tag_list"
#define POST_FAVORITE_ACTION_URL    @"/phone_controller?action=post_fav"
#define POST_UNFAVORITE_ACTION_URL  @"/phone_controller?action=post_fav_cancel"
#define POST_LIKE_USERS_LIST_URL    @"/phone_controller?action=post_cool_list"
#define POST_LIKE_ACTION_URL        @"/phone_controller?action=post_cool"
#define POST_UNLIKE_ACTION_URL      @"/phone_controller?action=post_cool_cancel"
#define SEND_COMMENT_URL            @"/event/uploadfile_testc.jsp"
#define COMMENT_LIST_URL            @"/phone_controller?action=post_comment_list"

#pragma mark - Feedback
#define SOFT_FEEDBACK_MSG_URL       @"/phone_controller?action=feedback_message"
#define SOFT_FEEDBACK_SUBMIT_URL    @"/phone_controller?action=feed_back"

#pragma mark - enterprise
#define BIZ_GROUP_URL               @"/phone_controller?action=business_discuss_list"

#pragma mark - Shake
#define SHAKE_USER_LIST_URL         @"/phone_controller?action=shake_it_off"
#define SHAKE_PLACE_THING_URL       @"/phone_controller?action=shake_where_what_list"
#define CHART_LIST_URL              @"/phone_controller?action=pr_message_list"
#define CHART_USER_LIST_URL         @"/phone_controller?action=pr_person_list"
#define CHART_SUBMIT_URL            @"/phone_controller?action=submit_pr"
#define LOAD_WINNER_AWARDS_URL      NULL_PARAM_VALUE

#pragma mark - share
#define NEARBY_PLACE_LIST_URL       @"/phone_controller?action=place_list"

#pragma mark - ad
#define AD_URL                      @"/phone_controller?action=ceibs_ad_list"

#pragma mark - profile
#define PROFILE_BASE_URL            @"/event?action=page_load&page_name=ceibs_personal_basic_information"

#define PROFILE_HOME_URL            @"/event?action=page_load&page_name=ceibs_home_contact"

#define PROFILE_COMPANY_URL         @"/event?action=page_load&page_name=ceibs_company_contact"

#define PROFILE_ACCOUNT_URL         @"/event?action=page_load&page_name=ceibs_more_accounts"

#pragma mark - nearby items
#define SERVICE_CATEGORY_URL        @"/phone_controller?action=service_category_list"
#define SERVICE_ITEM_URL            @"/phone_controller?action=service_list"
#define SERVICE_ITEM_DETAIL_URL     @"/phone_controller?action=service_single_get"
#define SERVICE_ITEM_COMMENT_URL    @"/phone_controller?action=service_comment_list"
#define SERVICE_ITEM_LIKERS_URL     @"/phone_controller?action=service_like_list"
#define SERVICE_ITEM_PHOTO_URL      @"/phone_controller?action=service_photo_list"
#define SERVICE_RECOMMENDED_ITEM_URL @"/phone_controller?action=service_recommend_item_list"
#define RECOMMENDED_ITEM_LIKERS_URL @"/phone_controller?action=service_recommend_item_like_list"
#define SERVICE_ITEM_FAVORITE_URL   @"/phone_controller?action=service_favorite_submit"
#define SERVICE_ITEM_LIKE_URL       @"/phone_controller?action=service_like_submit"
#define RECOMMENDED_ITEM_LIKE_URL   @"/phone_controller?action=service_recommend_item_like_submit"
#define SERVICE_ITEM_CHECKEDIN_URL  @"/phone_controller?action=service_checkin_list"
#define SERVICE_ITEM_CHECKIN_URL    @"/phone_controller?action=service_checkin_submit"
#define BRANDS_URL                  @"/phone_controller?action=service_channel_list"
#define BRAND_ALUMNUS_URL           @"/phone_controller?action=service_channel_alumni_list"
#define BRAND_DETAIL_URL            @"/phone_controller?action=service_channel_detail"

#pragma mark - back alumni check
#define BACK_ALUMNI_SEARCH_URL      @"/phone_controller?action=query_ceibs_alumni_reunions"
#define BACK_ALUMNI_ACTIVITY_URL    @"/phone_controller?action=ceibs_alumni_reunions_detail"
#define BACK_ALUMNI_CHECKIN_URL     @"/phone_controller?action=ceibs_alumni_reunions_check"

#pragma mark - alumni relationship
#define WITH_ME_LINK_URL            @"/phone_controller?action=fetch_with_me_connection"
#define ALL_KNOWN_ALUMNUS_URL       @"/phone_controller?action=unless_connect_list"
#define FAVORITE_ALUMNI_URL         @"/phone_controller?action=favorites_status_switching"
#define CONNECTED_ALUMNUS_COUNT_URL @"/phone_controller?action=konw_counts"
#define ATTRACTIVE_ALUMNUS_URL      @"/phone_controller?action=want_konw_person_list"
#define KNOWN_ALUMNUS_URL           @"/phone_controller?action=already_konw_person_list"
#define ALUMNI_NEWS_URL             @"/phone_controller?action=get_wx_news"

#pragma mark - homepage
#define HOMEPAGE_INFO_URL           @"/phone_controller?action=get_app_info"

#pragma mark - event
#define RECOMMENDED_EVENT_URL       @"/phone_controller?action=get_recommend_event"
#define EVENT_AWARD_URL             @"/phone_controller?action=event_shake_prize"

#pragma mark - my event
#define MY_EVENT_URL                @"/phone_controller?action=get_event"

#pragma mark - event apply questions url
#define EVENT_APPLY_QUESTIONS_URL   @"/phone_controller?action=apply_questions"
#define SENT_QUESTIONS_RESULT_URL   @"/phone_controller?action=questionaire_submit"
#define EVENT_SIGNUP_URL            @"/phone_controller?action=apply_questions_submit"

#pragma mark - startup project url
#define STARTUP_BACK_QUESTIONS_URL   @"/phone_controller?action=participation_questions"
#define STARTUP_BACK_SIGNUP_URL      @"/phone_controller?action=participation_questions_submit"
#define LOAD_PROJECT_BACKERS_URL     @"/phone_controller?action=event_participation_list"

#pragma mark - welfare url
#define WELFARE_TYPE_URL    @"/welfare?action=getItemTypeList&plat=iphone"
#define WELFARE_LIST_URL    @"/welfare?action=getItemList&plat=iphone"
#define WELFARE_DETAIL_URL  @"/welfare?action=getItemDetail&plat=iphone"
#define WELFARE_STORE_LIST_URL  @"/welfare?action=getStoreListByItem&plat=iphone"
#define WELFARE_STORE_DETAIL_URL  @"/welfare?action=getStoreDetail&plat=iphone"
#define WELFARE_BRAND_DETAIL_URL  @"/welfare?action=getBrandDetail&plat=iphone"
#define DOWNLOAD_COUPON_URL  @"/welfare?action=setDownloadItem&plat=iphone"
#define DOWNLOADED_USER_URL  @"/welfare?action=getDownloadUsersByItem&plat=iphone"
#define SET_ORDER_PAYMENT_URL @"/welfare?action=setOrderPayment&plat=iphone"
#define SET_ORDER_INFO_URL @"/welfare?action=setOrderInfo&plat=iphone"
#define FAVORITE_WELFARE_URL @"/welfare?action=setItemKeep&plat=iphone"

#define PUBLIS_WELFARE_URL  @"welfare"

#pragma mark - enterprise
#define ENTERPRISE_SOLUTION_URL   @"/phone_controller?action=open_biz_solution"

#pragma mark - pay
#define PAY_DATA_URL                @"/phone_controller?action=online_payment_by_app"
#define WELFARE_APP_PAY_URL         @"/phone_controller?action=sku_payment_by_app"
//@"http://t.bypay.cn/wapGateWay/wap.order!plusMerPay.ac"

#pragma mark - survey
#define SURVEY_DATA_URL             @"/phone_controller?action=questionaire_detail"

@interface GlobalConstants : NSObject {
  
}

@end
