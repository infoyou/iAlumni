//
//  GroupScrollView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GroupScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeGroupButton.h"
#import "CoreDataUtils.h"
#import "HomeGroup.h"

#define ITEM_GP_BTN_SIDE_LENGTH   60.0f
#define ITEM_GP_BTN_WIDHT         78.0f

#define IMG_EDGE              UIEdgeInsetsMake(20.0, 12.0, 0.0, 12.0)
#define TITLE_EDGE            UIEdgeInsetsMake(35.0, -40.0, -10.0, 0.0)//UIEdgeInsetsMake(35.0, -30.0, -10.0, 10.0)

@interface GroupScrollView()
@property (nonatomic, retain) NSMutableArray *btns;
@property (nonatomic, retain) HomeGroupButton *lastSelectedButton;
@end

@implementation GroupScrollView

@synthesize btns = _btns;
@synthesize lastSelectedButton = _lastSelectedButton;

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC 
      switchHandler:(id)switchHandler 
       switchAction:(SEL)switchAction 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _MOC = MOC;
        _switchHandler = switchHandler;
        _switchAction = switchAction;
        _imageDisplayerDelegate = imageDisplayerDelegate;
        
        self.btns = [NSMutableArray array];
        
        self.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]] autorelease];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPath];
        [shadowPath moveToPoint:CGPointMake(0, self.bounds.size.height)];
        [shadowPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
        [shadowPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height + 2)];
        [shadowPath addLineToPoint:CGPointMake(0, self.bounds.size.height + 2)];
        [shadowPath addLineToPoint:CGPointMake(0, self.bounds.size.height)];
        
        self.layer.shadowPath = shadowPath.CGPath;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.layer.shadowOpacity = 0.9f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.masksToBounds = NO;
        
        _groupContiner = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                         self.bounds.size.width, 
                                                                         self.bounds.size.height)] autorelease];
        _groupContiner.backgroundColor = TRANSPARENT_COLOR;
        _groupContiner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _groupContiner.canCancelContentTouches = NO;
        _groupContiner.clipsToBounds = YES;
        _groupContiner.scrollEnabled = YES;
        _groupContiner.showsVerticalScrollIndicator = NO;
        _groupContiner.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:_groupContiner];
    }
    return self;
}

- (void)dealloc {
    
    self.btns = nil;
    self.lastSelectedButton = nil;
    
    [super dealloc];
}

#pragma mark - draw item group buttons
- (void)drawItemButtons {
    
    NSMutableArray *sortDescs = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"sortKey" ascending:YES] autorelease];
    [sortDescs addObject:descriptor];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId >= 0)", 
                              0, HOME_USAGE_TY];
    
    NSArray *itemGroups = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC 
                                                  entityName:@"HomeGroup"
                                                   predicate:predicate
                                                   sortDescs:sortDescs
                                               limitedNumber:0];
    
    NSInteger index = 0;
    CGFloat contentWidth = MARGIN * 2;
    for (HomeGroup *item in itemGroups) {
        
        CGFloat x = index * (ITEM_GP_BTN_WIDHT + MARGIN * 2) + MARGIN * 2;    
        contentWidth += ITEM_GP_BTN_WIDHT;
        contentWidth += MARGIN * 2;
        
        UIView *btnBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(x, MARGIN, ITEM_GP_BTN_WIDHT, ITEM_GP_BTN_SIDE_LENGTH)] autorelease];
        btnBackgroundView.backgroundColor = TRANSPARENT_COLOR;
        UIBezierPath *shadowPath = [UIBezierPath bezierPath];
        [shadowPath moveToPoint:CGPointMake(0, ITEM_GP_BTN_SIDE_LENGTH)];
        [shadowPath addLineToPoint:CGPointMake(ITEM_GP_BTN_WIDHT, ITEM_GP_BTN_SIDE_LENGTH)];
        [shadowPath addLineToPoint:CGPointMake(ITEM_GP_BTN_WIDHT, ITEM_GP_BTN_SIDE_LENGTH - 2)];
        [shadowPath addLineToPoint:CGPointMake(0, ITEM_GP_BTN_SIDE_LENGTH - 2)];
        [shadowPath addLineToPoint:CGPointMake(0, ITEM_GP_BTN_SIDE_LENGTH)];
        
        btnBackgroundView.layer.shadowPath = shadowPath.CGPath;
        btnBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
        btnBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        btnBackgroundView.layer.shadowOpacity = 0.9f;
        //btnBackgroundView.layer.masksToBounds = NO;
        
        [_groupContiner addSubview:btnBackgroundView];
        
        HomeGroupButton *button = [[[HomeGroupButton alloc] initWithFrame:CGRectMake(0, 0, ITEM_GP_BTN_WIDHT, ITEM_GP_BTN_SIDE_LENGTH)
                                                                   target:self
                                                                   action:@selector(selectNewButton:)
                                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                                    title:item.groupName
                                                               titleColor:COLOR(100,100,100) 
                                                         titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR 
                                                                titleFont:FONT(11)  
                                                          imageEdgeInsert:IMG_EDGE
                                                          titleEdgeInsert:TITLE_EDGE
                                                                itemGroup:item
                                                   imageDisplayerDelegate:_imageDisplayerDelegate] autorelease];
        [btnBackgroundView addSubview:button];
        
        if (index == 0) {
            self.lastSelectedButton = button;
        }
        
        [self.btns addObject:button];    
        index++;
    }
    
    _groupContiner.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

// the method used to reset the hightlight status for buttons, but it is not elegant, it need to
// be replaced by a better solution
- (void)selectNewButton:(id)sender {
    
    HomeGroupButton *selectedButton = (HomeGroupButton *)sender;
    if (self.lastSelectedButton.itemGroup.groupId.longLongValue == selectedButton.itemGroup.groupId.longLongValue) {
        // current selected button same as last selected, then no need to continue
        //    return;
    }
    
    selectedButton.highlighted = YES;
    
    self.lastSelectedButton.highlighted = NO;
    [self.lastSelectedButton setNeedsDisplay];
    
    self.lastSelectedButton = selectedButton;
    [_switchHandler performSelector:_switchAction withObject:selectedButton.itemGroup];
}

- (void)defaultSelectDummyAll {
    // default select all
    //HomeGroupButton *dummyAllButton = (HomeGroupButton *)[self.btns objectAtIndex:0];
    //self.lastSelectedButton = dummyAllButton;
    //dummyAllButton.highlighted = YES;
    //[dummyAllButton setNeedsDisplay];
    self.lastSelectedButton.highlighted = YES;
    [self.lastSelectedButton setNeedsDisplay];
    [_switchHandler performSelector:_switchAction withObject:self.lastSelectedButton.itemGroup];
}

@end
