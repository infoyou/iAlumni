//
//  NameCardCandidatesViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "NameCardCandidatesViewController.h"
#import "NameCard.h"
#import "SelectablePeopleCell.h"
#import "ListSectionView.h"
#import "AlumniProfileViewController.h"
#import "UIImageButton.h"
#import "CoreDataUtils.h"
#import "ECColorfulButton.h"
#import "UIUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "NameCardExchangeResultView.h"
#import "XMLParser.h"
#import "AlumniListViewController.h"
#import "KnownAlumniListViewController.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIImageButton.h"

#define NAME_LIMITED_WIDTH    144.0f

#define PHOTO_WIDTH           56.0f

#define SECTION_VIEW_HEIGHT   16.0f

#define SELECT_BUTTON_WIDTH   50.0f
#define CONFIRM_BUTTON_WIDTH  150.0f
#define BUTTON_HEIGHT         30.0f

#define LOAD_INTERVAL         3.0f

@interface NameCardCandidatesViewController ()
@property (nonatomic, retain)NSArray *selectedAlumnus;
@end

@implementation NameCardCandidatesViewController

#pragma mark - user action

- (void)setAllNameCardsSelectionStatus:(BOOL)selected {
  self.selectedAlumnus = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                 entityName:@"NameCard"
                                                  predicate:nil];
  for (NameCard *nameCard in self.selectedAlumnus) {
    nameCard.selected = @(selected);
  }
  
  SAVE_MOC(_MOC);
  
  [_tableView reloadData];
  
  NSString *title = nil;
  if (selected) {
    title = [NSString stringWithFormat:@"%@(%d)", LocaleStringForKey(NSConfirmReceiveNameCardTitle, nil), self.selectedAlumnus.count];
  } else {
    title = [NSString stringWithFormat:@"%@(0)", LocaleStringForKey(NSConfirmReceiveNameCardTitle, nil)];
    
    self.selectedAlumnus = nil;
  }
  
  [_exchangeButton setTitle:title
                   forState:UIControlStateNormal];
}

- (void)selectAllCards:(id)sender {
  [self setAllNameCardsSelectionStatus:YES];
}

- (void)deselectAllCards:(id)sender {
  [self setAllNameCardsSelectionStatus:NO];
}

- (void)exchange:(id)sender {
  
  if (self.selectedAlumnus.count > 0) {
    
    NSMutableString *ids = [NSMutableString string];
    NSInteger i = 0;
    for (NameCard *nameCard in self.selectedAlumnus) {
      if (i == 0) {
        [ids appendString:nameCard.personId];
      } else {
        [ids appendString:[NSString stringWithFormat:@",%@", nameCard.personId]];
      }
      i++;
    }
    
    _currentType = FAVORITE_ALUMNI_TY;
    
    NSString *param = [NSString stringWithFormat:@"<favorites>%d</favorites><target_user_id>%@</target_user_id>", KNOWN_TY, ids];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
    
    [connFacade asyncGet:url showAlertMsg:YES];
    
  } else {
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSelectOneNameCardMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
  }
}

- (void)fetchSelectedAlumnus {
  self.selectedAlumnus = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                 entityName:@"NameCard"
                                                  predicate:[NSPredicate predicateWithFormat:@"(selected == 1)"]];
  [_exchangeButton setTitle:[NSString stringWithFormat:@"%@(%d)", LocaleStringForKey(NSConfirmReceiveNameCardTitle, nil), self.selectedAlumnus.count]
                   forState:UIControlStateNormal];
}

- (void)showExchangeResult {
  NameCardExchangeResultView *resultView = [[[NameCardExchangeResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)
                                                                                          MOC:_MOC
                                                                                       holder:self
                                                                                  closeAction:@selector(closeExchangeResult)
                                                                                 reviewAction:@selector(checkSavedNameCards)] autorelease];
  
  [self presentModalQuickView:resultView];
}

- (void)closeExchangeResult {
  [self dismissModalQuickView];
}

- (void)openKnownAlumnus {
  KnownAlumniListViewController *knownListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
  
  knownListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
  [self.navigationController pushViewController:knownListVC
                                       animated:YES];
}

- (void)checkSavedNameCards {
  
  [self dismissModalQuickView];
  
  [self performSelector:@selector(openKnownAlumnus)
             withObject:nil
             afterDelay:0.5f];
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
             forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_NAME_CARD_CANDIDATES_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude><distance_scope>10</distance_scope><time_scope>1000</time_scope><order_by_column>datetime</order_by_column><shake_where>%@</shake_where><shake_what>%@</shake_what><page>%d</page><page_size>%@</page_size><refresh_only>1</refresh_only><is_for_namecard>1</is_for_namecard>", [AppManager instance].longitude, [AppManager instance].latitude, [AppManager instance].defaultPlace, [AppManager instance].defaultThing, startIndex, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  
  BOOL showAlertMsg = YES;
  if (!_firstSearching && !_secondSearching) {
    // If user will trigger load first time, then no need to show alert message if load failed.
    // The alert message should be displayed for loading second time.
    showAlertMsg = NO;
  }
  [connFacade asyncGet:url showAlertMsg:showAlertMsg];
}

- (void)loadData {
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)reloadNameCards:(id)sender {
  
  // clear current list
  DELETE_OBJS_FROM_MOC(_MOC, @"NameCard", nil);
  self.fetchedRC = nil;
  [self fetchSelectedAlumnus];
  [_tableView reloadData];
  
  // reload list
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"NameCard";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";
}

- (BOOL)hasNameCardCount {
  return [WXWCoreDataUtils objectInMOC:_MOC
                      entityName:@"NameCard"
                          predicate:nil];
}


#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    DELETE_OBJS_FROM_MOC(_MOC, @"NameCard", nil);
    
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (void)dealloc {
  
  self.selectedAlumnus = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"NameCard", nil);
  
  [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [UIUtils closeActivityView];
}

- (void)addToolBar {
  
  UIView *toolbar = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                              self.view.frame.size.height - TOOLBAR_HEIGHT * 2,
                                                              self.view.frame.size.width,
                                                              TOOLBAR_HEIGHT)] autorelease];
  toolbar.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
  [self.view addSubview:toolbar];
  
  ECStandardButton *selectAllButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(MARGIN * 2, (TOOLBAR_HEIGHT - BUTTON_HEIGHT)/2.0f, SELECT_BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                        target:self
                                                                        action:@selector(selectAllCards:)
                                                                         title:LocaleStringForKey(NSSelectAllTitle, nil)
                                                                     tintColor:COLOR(241, 241, 241)
                                                                     titleFont:BOLD_FONT(13)
                                                                   borderColor:COLOR(185, 185, 185)] autorelease];
  [selectAllButton setTitleColor:DARK_TEXT_COLOR forState:UIControlStateNormal];
  [toolbar addSubview:selectAllButton];
  
  ECStandardButton *deselectAllButton = [[[ECStandardButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - MARGIN * 2 - SELECT_BUTTON_WIDTH, (TOOLBAR_HEIGHT - BUTTON_HEIGHT)/2.0f, SELECT_BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                          target:self
                                                                          action:@selector(deselectAllCards:)
                                                                           title:LocaleStringForKey(NSDeselectAllTitle, nil)
                                                                       tintColor:COLOR(241, 241, 241)
                                                                       titleFont:BOLD_FONT(13)
                                                                     borderColor:COLOR(185, 185, 185)] autorelease];
  [deselectAllButton setTitleColor:DARK_TEXT_COLOR forState:UIControlStateNormal];
  [toolbar addSubview:deselectAllButton];
  
  _exchangeButton = [[[ECColorfulButton alloc] initPlainButtonWithFrame:CGRectMake((self.view.frame.size.width - CONFIRM_BUTTON_WIDTH)/2.0f, (TOOLBAR_HEIGHT - BUTTON_HEIGHT)/2.0f, CONFIRM_BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                 target:self
                                                                 action:@selector(exchange:)
                                                                  title:[NSString stringWithFormat:@"%@(0)", LocaleStringForKey(NSConfirmReceiveNameCardTitle, nil)]
                                                              tintColor:COLOR(236, 123, 50)
                                                              titleFont:BOLD_FONT(18)
                                                            roundedType:HAS_ROUNDED] autorelease];   
  [toolbar addSubview:_exchangeButton];
}

- (void)addRefreshButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSRefreshTitle, nil)
                            target:self
                            action:@selector(reloadNameCards:)];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addToolBar];
  
  [self addRefreshButton];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case LOAD_NAME_CARD_CANDIDATES_TY:
    {
      if (!_firstSearching && !_secondSearching) {
        [UIUtils showActivityView:self.view
                             text:LocaleStringForKey(NSSearchNearbyAlumnusMsg, nil)];
        _firstSearching = YES;
      }

      break;
    }
      
    case FAVORITE_ALUMNI_TY:
    {
      [self showAsyncLoadingView:LocaleStringForKey(NSReceivingTitle, nil)
                blockCurrentView:YES];
      break;
    }
      
    default:
      break;
  }
    
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  
  switch (contentType) {
      
    case LOAD_NAME_CARD_CANDIDATES_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _autoLoaded = YES;
        
        if (_firstSearching) {
          
          _firstSearching = NO;
          
          _secondSearching = YES;
          
          [self performSelector:@selector(loadData)
                     withObject:nil
                     afterDelay:LOAD_INTERVAL];
        } else {
          
          if (_secondSearching) {
            _secondSearching = NO;
          }
          
          if ([self hasNameCardCount]) {
            [self refreshTable];
            
            [self fetchSelectedAlumnus];
          } else {
            [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSNoNameCardMsg, nil)
                                          msgType:INFO_TY
                               belowNavigationBar:YES];
          }
          
          [UIUtils closeActivityView];
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
    
    case FAVORITE_ALUMNI_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self showExchangeResult];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }

      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *message = nil;
  
  switch (contentType) {
    case LOAD_NAME_CARD_CANDIDATES_TY:
    {
      if (_firstSearching) {
        _firstSearching = NO;
        
        _secondSearching = YES;
        
        [self performSelector:@selector(loadData)
                   withObject:nil
                   afterDelay:LOAD_INTERVAL];
      } else {
        
        if (_secondSearching) {
          _secondSearching = NO;
        }
        [UIUtils closeActivityView];
        
        message = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
      }
      
      break;
    }
      
    case FAVORITE_ALUMNI_TY:
    {
      message = LocaleStringForKey(NSActionFaildMsg, nil);
      break;
    }
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = message;
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.fetchedRC.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC.sections objectAtIndex:section];
  
  if (section == self.fetchedRC.sections.count - 1) {
    return sectionInfo.numberOfObjects + 1;
  } else {
    return sectionInfo.numberOfObjects;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
  
  NSArray *alumniList = [sectionInfo objects];
  NSString *firstChar = nil;
  if (alumniList.count > 0) {
    NameCard *nameCard = (NameCard *)alumniList.lastObject;
    firstChar = nameCard.firstNamePinyinChar;
  }
  
  return [[[ListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                           title:firstChar] autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return [self drawFooterCell];
  }
  
  static NSString *kCellIdentifier = @"kUserCell";
  SelectablePeopleCell *cell = (SelectablePeopleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[SelectablePeopleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                 imageDisplayerDelegate:self
                                 imageClickableDelegate:self
                                                    MOC:_MOC] autorelease];
  }
  
  NameCard *nameCard = (NameCard *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:nameCard];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return PEOPLE_CELL_HEIGHT;
  }
  
  NameCard *nameCard = (NameCard *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
  CGSize size = [nameCard.name sizeWithFont:Arial_FONT(14)
                          constrainedToSize:constraint
                              lineBreakMode:NSLineBreakByTruncatingTail];
  
  CGFloat height = MARGIN + size.height + MARGIN;
  
  size = [nameCard.companyName sizeWithFont:FONT(13)
                          constrainedToSize:CGSizeMake(280 - MARGIN -
                                                       (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                        MARGIN * 2),
                                                       CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  
  height += size.height + MARGIN;
  
  if (height < PEOPLE_CELL_HEIGHT) {
    height = PEOPLE_CELL_HEIGHT;
  }
  
  return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  NameCard *nameCard = (NameCard *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  nameCard.selected = @(!nameCard.selected.boolValue);
  SAVE_MOC(_MOC);
  
  [self updateLastSelectedCell];
  
  [self fetchSelectedAlumnus];
}

@end
