//
//  ShakeAlumniViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-1.
//
//

#import "ShakeAlumniViewController.h"
#import "WXWLabel.h"
#import "ECColorfulButton.h"
#import "ShakeForNameCardViewController.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface ShakeAlumniViewController ()

@end

@implementation ShakeAlumniViewController

#pragma mark - load data
- (void)loadPlacesAndThings
{
  [CommonUtils doDelete:_MOC entityName:@"Tag"];
  [CommonUtils doDelete:_MOC entityName:@"Place"];
  _currentType = SHAKE_PLACE_THING_TY;
  NSString *param = [NSString stringWithFormat:@"<latitude>%f</latitude><longitude>%f</longitude>",
                     [AppManager instance].latitude,
                     [AppManager instance].longitude];
  
  NSMutableString *requestParam = [NSMutableString stringWithString:param];
  if (!_getLocationSuccess) {
    [requestParam appendString:@"<not_shake>1</not_shake>"];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - user action
- (void)switchToNameCard:(id)sender {
  ShakeForNameCardViewController *shakeForNameCardVC = [[[ShakeForNameCardViewController alloc] initWithMOC:_MOC] autorelease];
  
  shakeForNameCardVC.title = LocaleStringForKey(NSShakeTitle, nil);
  
  [self.navigationController pushViewController:shakeForNameCardVC animated:YES];
}

#pragma mark - lifecycle methods
- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(100, 100, 200, 20) textColor:BASE_INFO_COLOR shadowColor:TEXT_SHADOW_COLOR] autorelease];
  titleLabel.backgroundColor = TRANSPARENT_COLOR;
  titleLabel.text = LocaleStringForKey(NSShakeNoteTitle, nil);
  [self.view addSubview:titleLabel];
  
  UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  switchButton.frame = CGRectMake(100, 200, 200, 50);
  [switchButton setTitle:LocaleStringForKey(NSShakeForNameCardTitle, nil)
                forState:UIControlStateNormal];
  [switchButton addTarget:self
                   action:@selector(switchToNameCard:)
         forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:switchButton];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  [UIUtils showActivityView:self.view
                       text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  [UIUtils closeActivityView];
  switch (contentType) {
      
    case SHAKE_PLACE_THING_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        //[self showPlacesAndThings];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      _processing = NO;
    }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [UIUtils closeActivityView];
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  [UIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  _getLocationSuccess = YES;
  
  [self loadPlacesAndThings];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  _getLocationSuccess = NO;
}

@end
