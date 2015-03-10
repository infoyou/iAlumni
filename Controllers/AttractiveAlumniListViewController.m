//
//  AttractiveAlumniListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "AttractiveAlumniListViewController.h"
#import "AttractiveAlumni.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface AttractiveAlumniListViewController ()

@end

@implementation AttractiveAlumniListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_ATTRACTIVE_ALUMNUS_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>100</page_size>", startIndex];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"AttractiveAlumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";
}

#pragma mark - lifecycle methods
- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    _autoLoaded = YES;
    
    [self refreshTable];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}
@end
