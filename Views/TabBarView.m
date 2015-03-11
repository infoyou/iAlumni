//
//  TabBarView.m
//  iAlumni
//
//  Created by Adam on 13-1-10.
//
//

#import "TabBarView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "TabBarItem.h"
#import "AppManager.h"

#define TAB_WIDTH       79.25f//63.0f

#define SELECTED_INDICATOR_HEIGHT 3.0f

#define TAB_COUNT       4//5

#define SEPARATOR_WIDTH 1.0f


@interface TabBarView()
@property (nonatomic, retain) NSMutableArray *tabItemList;
@end

@implementation TabBarView

#pragma mark - selection action

- (void)refreshBadges {
    for (TabBarItem *item in self.tabItemList) {
        NSInteger numberBadge = 0;
        BOOL showNewFlag = NO;
        switch (item.tag) {
            case ENTRANCE_TAG:
            {
                break;
            }
                /*
                 case ALUMNI_TAG:
                 {
                 numberBadge = [AppManager instance].msgNumber.intValue;
                 
                 break;
                 }
                 */
                
            case EVENT_TAG:
            {
                //numberBadge = [AppManager instance].comingEventCount;
                break;
            }
                
            case BIZ_TAG:
            {
                break;
            }
                
            case MORE_TAG:
            {
                numberBadge = [AppManager instance].msgNumber.intValue;
                showNewFlag = [AppManager instance].hasNewEnterpriseSolution;
                break;
            }
                
            default:
                break;
        }
        
        [item setNumberBadgeWithCount:numberBadge showNewFlag:showNewFlag];
    }
}

- (BOOL)tagSelected:(NSInteger)tag item:(TabBarItem *)item {
    return tag == item.tag ? YES : NO;
}

- (void)doSwitchAction:(NSInteger)tag {
    switch (tag) {
        case ENTRANCE_TAG:
        {
            [_delegate selectHomepage];
            break;
        }
            /*
             case ALUMNI_TAG:
             {
             [_delegate selectAlumni];
             break;
             }
             */
            
        case BIZ_TAG:
        {
            //      [_delegate selectBizOpp];
            [_delegate selectSupplyDemand];
            break;
        }
            
        case EVENT_TAG:
        {
            //      [_delegate selectEvent];
            [_delegate selectEventByHtml5];
            break;
        }
            
            
        case MORE_TAG:
        {
            //[_delegate selectMore];
            [_delegate selectPersonal];
            break;
        }
            
        default:
            break;
    }
}

- (void)switchTabHighlightStatus:(NSInteger)tag {
    CGFloat x = (TAB_WIDTH + SEPARATOR_WIDTH) * tag;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         
                         CGFloat width = TAB_WIDTH;
                         
                         if (tag == MORE_TAG) {
                             width += 1.0f;
                         }
                         _selectedIndicator.frame = CGRectMake(x,
                                                               _selectedIndicator.frame.origin.y,
                                                               width,
                                                               _selectedIndicator.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         for (TabBarItem *item in self.tabItemList) {
                             NSString *imageName = nil;
                             NSInteger numberBadge = 0;
                             BOOL showNewFlag = NO;
                             switch (item.tag) {
                                 case ENTRANCE_TAG:
                                 {
                                     if ([self tagSelected:tag item:item]) {
                                         imageName = @"homeSelected.png";
                                     } else {
                                         imageName = @"homeUnselected.png";
                                     }
                                     
                                     break;
                                 }
                                     /*
                                      case ALUMNI_TAG:
                                      {
                                      if ([self tagSelected:tag item:item]) {
                                      imageName = @"alumniSelected.png";
                                      } else {
                                      imageName = @"alumniUnselected.png";
                                      }
                                      
                                      numberBadge = [AppManager instance].msgNumber.intValue;
                                      
                                      break;
                                      }
                                      */
                                 case EVENT_TAG:
                                 {
                                     if ([self tagSelected:tag item:item]) {
                                         imageName = @"eventSelected.png";
                                     } else {
                                         imageName = @"eventUnselected.png";
                                     }
                                     
                                     //numberBadge = [AppManager instance].comingEventCount;
                                     break;
                                 }
                                     
                                 case BIZ_TAG:
                                 {
                                     if ([self tagSelected:tag item:item]) {
                                         imageName = @"bizSelected.png";
                                     } else {
                                         imageName = @"bizUnselected.png";
                                     }
                                     
                                     break;
                                 }
                                     
                                 case MORE_TAG:
                                 {
                                     if ([self tagSelected:tag item:item]) {
                                         imageName = @"selectedMe.png";
                                     } else {
                                         imageName = @"unselectedMe.png";
                                     }
                                     
                                     numberBadge = [AppManager instance].msgNumber.intValue;
                                     showNewFlag = [AppManager instance].hasNewEnterpriseSolution;
                                     break;
                                 }
                                     
                                 default:
                                     break;
                             }
                             
                             if ([self tagSelected:tag item:item]) {
                                 [item setTitleColorForHighlight:YES];
                             } else {
                                 [item setTitleColorForHighlight:NO];
                             }
                             
                             [item setImage:[UIImage imageNamed:imageName]];
                             
                             [item setNumberBadgeWithCount:numberBadge showNewFlag:showNewFlag];
                         }
                         
                     }];
    
}

- (void)selectTag:(NSNumber *)tag {
    
    if (nil == _delegate) {
        return;
    }
    
    [self doSwitchAction:tag.intValue];
    
    [self switchTabHighlightStatus:tag.intValue];
}

#pragma mark - customize tab bar item

- (void)setTabItem:(TabBarItem *)item index:(NSInteger)index forInit:(BOOL)forInit{
    
    NSString *title = nil;
    NSString *imageName = nil;
    NSInteger numberBadge = 0;
    BOOL showNewFlag = NO;
    
    switch (index) {
        case ENTRANCE_TAG:
        {
            title = LocaleStringForKey(NSHomepageTitle, nil);
            if (forInit) {
                imageName = @"homeSelected.png";
                [item setTitleColorForHighlight:YES];
            } else {
                imageName = @"homeUnselected.png";
                [item setTitleColorForHighlight:NO];
            }
            
            
            break;
        }
            /*
             case ALUMNI_TAG:
             {
             title = LocaleStringForKey(NSAlumniTitle, nil);
             imageName = @"alumniUnselected.png";
             numberBadge = [AppManager instance].msgNumber.intValue;
             break;
             }
             */
        case EVENT_TAG:
        {
            title = LocaleStringForKey(NSGroupEventTitle, nil);
            imageName = @"eventUnselected.png";
            //numberBadge = [AppManager instance].comingEventCount;
            break;
        }
            
        case BIZ_TAG:
        {
            title = LocaleStringForKey(NSBizCoopTitle, nil);
            imageName = @"bizUnselected.png";
            break;
        }
            
        case MORE_TAG:
        {
            title = LocaleStringForKey(NSMeTitle, nil);
            imageName = @"unselectedMe.png";
            numberBadge = [AppManager instance].msgNumber.intValue;
            showNewFlag = [AppManager instance].hasNewEnterpriseSolution;
            break;
        }
            
        default:
            break;
    }
    
    [item setTitle:title image:[UIImage imageNamed:imageName]];
    
    [item setNumberBadgeWithCount:numberBadge showNewFlag:showNewFlag];
}

- (void)refreshItems {
    for (int i = 0; i < TAB_COUNT; i++) {
        TabBarItem *item = self.tabItemList[i];
        
        [self setTabItem:item index:i forInit:NO];
    }
}

- (void)initTabs {
    
    self.tabItemList = [NSMutableArray array];
    
    for (int i = 0; i < TAB_COUNT; i++) {
        CGFloat x = (TAB_WIDTH + SEPARATOR_WIDTH) * i;
        
        CGFloat width = TAB_WIDTH;
        if (i == TAB_COUNT - 1) {
            width += 1.0f;
        }
        TabBarItem *item = [[[TabBarItem alloc] initWithFrame:CGRectMake(x, 0, width, HOMEPAGE_TAB_HEIGHT)
                                                     delegate:self
                                              selectionAction:@selector(selectTag:)
                                                          tag:i] autorelease];
        
        [self setTabItem:item index:i forInit:YES];
        
        [self addSubview:item];
        
        [self.tabItemList addObject:item];
    }
}

#pragma mark - lifecycle methods

- (void)addShadow {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowRadius = 1.0f;
    self.layer.shadowOpacity = 0.7f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.masksToBounds = NO;
}

- (void)initSelectedIndicator {
    _selectedIndicator = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   TAB_WIDTH,
                                                                   SELECTED_INDICATOR_HEIGHT)] autorelease];
    _selectedIndicator.backgroundColor = NAVIGATION_BAR_COLOR;
    
    [self addSubview:_selectedIndicator];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<TabDelegate>)delegate;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _delegate = delegate;
        
        self.backgroundColor = COLOR(178, 178, 178);
        
        [self addShadow];
        
        [self initTabs];
        
        [self initSelectedIndicator];
    }
    
    return self;
}

- (void)dealloc {
    
    self.tabItemList = nil;
    
    [super dealloc];
}

@end
