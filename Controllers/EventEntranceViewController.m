//
//  EventEntranceViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-14.
//
//

#import "EventEntranceViewController.h"
#import "EventWallContainerView.h"
#import "LectureEventEntranceView.h"
#import "EntertainmentEventEntranceView.h"
#import "MyEventEntranceView.h"
#import "EventListViewController.h"
#import "Event.h"
#import "AppManager.h"
#import "EventDetailViewController.h"
#import "MyEventListViewController.h"
#import "StartupListViewController.h"
#import "StartupProjectViewController.h"

#define VIDEO_35INCH_HEIGHT   150.0f
#define VIDEO_40INCH_HEIGHT   238.0f

#define GRID_WIDTH            145.0f
#define MEDIUM_GRID_HEIGHT    97.5f
#define SMALL_GRID_HEIGHT     80.5f

@interface EventEntranceViewController ()

@end


@implementation EventEntranceViewController

#pragma mark - update badge

- (void)updateComingLectureCount {
  [_lectureEventEntranceView setNumberBadgeWithCount:[AppManager instance].commingLectureEventCount];
}

- (void)updateComingEntertainmentCount {
  [_entertainmentEventEntranceView setNumberBadgeWithCount:[AppManager instance].commingEntertainmentEventCount];
}

- (void)updateComingEventCount {
  [self updateComingLectureCount];
  [self updateComingEntertainmentCount];
}

- (void)updateCountBadge {
  
  [AppManager instance].comingEventCount = [AppManager instance].commingLectureEventCount + [AppManager instance].commingEntertainmentEventCount;
  
  if (_parentVC && _refreshBadgesAction) {
    [_parentVC performSelector:_refreshBadgesAction];
  }
}


- (void)clearComingLectureCount {
  [AppManager instance].commingLectureEventCount = 0;
  [_lectureEventEntranceView setNumberBadgeWithCount:0];
  
  [self updateCountBadge];
}

- (void)clearComingEntertainmentCount {
  [AppManager instance].commingEntertainmentEventCount = 0;
  [_entertainmentEventEntranceView setNumberBadgeWithCount:0];
  
  [self updateCountBadge];
}

#pragma mark - user actions
- (void)openLatestEvent:(Event *)event {
  if (event.fake.boolValue) {
    return;
  }
  
  [AppManager instance].isClub2Event = NO;
  
  [AppManager instance].eventId = [event.eventId stringValue];
  EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                eventId:event.eventId.longLongValue
                                                                           parentListVC:nil] autorelease];
  detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:detailVC animated:YES];
  }
}

- (void)openLectureEvents:(id)sender {
  
  [_eventWallContainerView stopPlay];
  
  EventListViewController *videoListVC = [[[EventListViewController alloc] initWithMOC:_MOC parentVC:self tabIndex:EVENT_TAB_IDX] autorelease];
  videoListVC.title = LocaleStringForKey(NSEventTitle, nil);
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:videoListVC animated:YES];
  }
  
  [self clearComingLectureCount];
}

- (void)openEntertainmentEvents:(id)sender {
  
  [_eventWallContainerView stopPlay];
  
  /*
   EventListViewController *videoListVC = [[[EventListViewController alloc] initWithMOC:_MOC parentVC:self tabIndex:LOHHAS_EVENT_TY] autorelease];
   videoListVC.title = LocaleStringForKey(NSEventTitle, nil);
   */
  
  StartupListViewController *startupListVC = [[[StartupListViewController alloc] initWithMOC:_MOC] autorelease];
  
  startupListVC.title = LocaleStringForKey(NSStartupTitle, nil);
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:startupListVC animated:YES];
  }
  
  [self clearComingEntertainmentCount];
}

- (void)openMyEvents:(id)sender {
  [_eventWallContainerView stopPlay];
  
  MyEventListViewController *videoListVC = [[[MyEventListViewController alloc] initWithMOC:_MOC parentVC:nil tabIndex:ACADEMIC_EVENT_TY] autorelease];
  videoListVC.title = LocaleStringForKey(NSMyEventMsg, nil);
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:videoListVC animated:YES];
  }
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC
refreshBadgesAction:(SEL)refreshBadgesAction {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    _viewHeight = viewHeight;
    
    _parentVC = parentVC;
    
    _noNeedBackButton = YES;
    
    _refreshBadgesAction = refreshBadgesAction;
  }
  return self;
}

- (void)dealloc {
  
  // stop event wall scroll view loading
  [[NSNotificationCenter defaultCenter] postNotificationName:CONN_CANCELL_NOTIFY
                                                      object:self
                                                    userInfo:nil];
  
  [super dealloc];
}

- (void)addEventContainer {
  
  CGFloat height = 0.0f;
  /*
   if ([WXWCommonUtils screenHeightIs4Inch]) {
   height = VIDEO_40INCH_HEIGHT;
   } else {
   height = VIDEO_35INCH_HEIGHT;
   }
   */
  height = VIDEO_35INCH_HEIGHT;
  
  _eventWallContainerView = [[[EventWallContainerView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2,
                                                                                      self.view.frame.size.width -
                                                                                      MARGIN * 4, height)
                                                    imageDisplayerDelegate:self
                                                    connectTriggerDelegate:self
                                                                       MOC:self.MOC
                                                                  entrance:self
                                                                    action:@selector(openLatestEvent:)
                                                        refreshBadgeAction:@selector(updateComingEventCount)] autorelease];
  [self.view addSubview:_eventWallContainerView];
}

- (void)addLectureEventEntranceView {
  _lectureEventEntranceView = [[[LectureEventEntranceView alloc] initWithFrame:CGRectMake(MARGIN * 2, _eventWallContainerView.frame.origin.y + _eventWallContainerView.frame.size.height + MARGIN * 2, GRID_WIDTH, SMALL_GRID_HEIGHT)
                                                                     entrancce:self
                                                                        action:@selector(openLectureEvents:)] autorelease];
  [self.view addSubview:_lectureEventEntranceView];
}

- (void)addEntertainmentEventEntranceView {
  _entertainmentEventEntranceView = [[[EntertainmentEventEntranceView alloc] initWithFrame:CGRectMake(_lectureEventEntranceView.frame.origin.x + _lectureEventEntranceView.frame.size.width + MARGIN * 2, _lectureEventEntranceView.frame.origin.y, GRID_WIDTH, SMALL_GRID_HEIGHT)
                                                                                 entrancce:self
                                                                                    action:@selector(openEntertainmentEvents:)] autorelease];
  [self.view addSubview:_entertainmentEventEntranceView];
}

- (void)addMyEventEntranceView {
  _myEventEntranceView = [[[MyEventEntranceView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                                _lectureEventEntranceView.frame.origin.y + _lectureEventEntranceView.frame.size.height + MARGIN * 2, self.view.frame.size.width - MARGIN * 4, MEDIUM_GRID_HEIGHT)
                                                           entrancce:self
                                                              action:@selector(openMyEvents:)] autorelease];
  [self.view addSubview:_myEventEntranceView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  
  self.view.frame = CGRectMake(0,
                               0,
                               self.view.frame.size.width,
                               _viewHeight);
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  // following order cannot change
  // step 1
  [self addEventContainer];
  
  // step 2
  [self addLectureEventEntranceView];
  
  // step 3
  [self addEntertainmentEventEntranceView];
  
  // step 4
  [self addMyEventEntranceView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [_eventWallContainerView loadLatestEvents];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - ScrollAutoPlayerDelegate methods
- (void)play {
  if (_eventWallContainerView) {
    [_eventWallContainerView play];
  }
  
}

- (void)stopPlay {
  if (_eventWallContainerView) {
    [_eventWallContainerView stopPlay];
  }
}

#pragma mark - open shared event

- (void)openSharedEventById:(long long)eventId eventType:(int)eventType {
  
  [AppManager instance].isClub2Event = NO;
  
  [AppManager instance].eventId = [NSString stringWithFormat:@"%lld", eventId];
  
  UIViewController *detailVC = nil;
  
  if (eventType == STARTUP_PROJECT_TY) {
    
    detailVC = [[[StartupProjectViewController alloc] initWithMOC:_MOC
                                                          eventId:eventId] autorelease];
    detailVC.title = LocaleStringForKey(NSStartupProjectTitle, nil);
    
  } else {
    detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                       eventId:eventId
                                                  parentListVC:nil] autorelease];
    detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);
  }
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:detailVC animated:YES];
  }
  
}

@end
