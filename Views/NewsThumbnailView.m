//
//  NewsThumbnailView.m
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "NewsThumbnailView.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "News.h"
#import "CurrentItemTextView.h"

#define TITLE_BACKGROUND_HEIGHT 22.0f

#define MAX_ITEM_COUNT        5
#define TIMER_INTERVAL        5

#define TITLE_CONTENT_HEIGHT  50.0f

@interface NewsThumbnailView ()
@property (nonatomic, retain) NSArray *loadedNews;
@property (nonatomic, retain) NSTimer *scrollTimer;
@property (nonatomic, retain) CurrentItemTextView *contentView;
@end

@implementation NewsThumbnailView

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
           entrance:(id)entrance
             action:(SEL)action {
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:connectTriggerDelegate];
  
  if (self) {
    
    _entrance = entrance;
    _action = action;
    _MOC = MOC;
    
    self.backgroundColor = COLOR(36, 60, 101);
    
    self.contentView = [[[CurrentItemTextView alloc] initWithFrame:CGRectMake(0, (self.bounds.size.height - TITLE_CONTENT_HEIGHT)/2.0f, self.frame.size.width, TITLE_CONTENT_HEIGHT)] autorelease];
    [self addSubview:self.contentView];
    
  }
  return self;
}

- (void)dealloc {
  
  self.loadedNews = nil;
  
  if (self.scrollTimer != nil) {
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
  }
  
  self.contentView = nil;
  
  [super dealloc];
}

- (void)loadNewsImageWithUrl:(NSString *)imageUrl {
  
  if (imageUrl && imageUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:imageUrl] forceNew:NO];
  }
}

#pragma mark - load news
- (void)loadLatestNews {
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>5</page_size><news_type>%d</news_type>", 0, FOR_HOMEPAGE_NEWS_TY];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_NEWS_REPORT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_NEWS_REPORT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    [self triggerAutoScroll];
  }
  
  [super connectDone:result url:url contentType:contentType];
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

#pragma mark - arrange news

- (void)loadNews {
  if ([WXWCoreDataUtils objectInMOC:_MOC entityName:@"News" predicate:nil]) {
    
    [self triggerAutoScroll];
    
  } else {
    [self loadLatestNews];
  }
}

- (void)triggerAutoScroll {
  
  self.loadedNews = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC entityName:@"News" predicate:nil];
  if (self.loadedNews.count == 0) {
    return;
  }
  
  _currentIndex = 0;
  
  self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                      target:self
                                                    selector:@selector(autoScollShow)
                                                    userInfo:nil
                                                     repeats:YES];
  [self.scrollTimer fire];
  
}

- (void)autoScollShow {
  
  if (_currentIndex >= self.loadedNews.count) {
    _currentIndex = 0;
  } else if (_currentIndex >= MAX_ITEM_COUNT) {
    _currentIndex = 0;
  }
  
  if (self.loadedNews.count > 0) {
    News *news = (News *)[self.loadedNews objectAtIndex:_currentIndex];
    if (news != nil) {
      [self.contentView updateContent:news.title];
    }
  }
  
  _currentIndex++;
}

@end
