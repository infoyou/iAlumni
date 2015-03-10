//
//  CouponViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-25.
//
//

#import "CouponViewController.h"
#import "AlumniCouponTitleCell.h"
#import "AlumniCouponInfoCell.h"
#import "VerticalLayoutItemInfoCell.h"
#import "Brand.h"

#define DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH  280.0f

#define CELL_COUNT 4

#define COUPON_TITLE_CELL_HEIGHT  44.0f

enum {
  COUPON_SEC_TITLE_CELL = 0,
  COUPON_SEC_INFO_CELL,
  COUPON_SEC_SHOW_CELL,
  COUPON_SEC_TIPS_CELL,
};

@interface CouponViewController ()
@property (nonatomic, retain) Brand *brand;
@end

@implementation CouponViewController

@synthesize brand = _brand;

- (id)initWithMOC:(NSManagedObjectContext *)MOC brand:(Brand *)brand {
  
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    self.brand = brand;
  }
  
  return self;
}

- (void)dealloc {
  
  self.brand = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = CELL_COLOR;
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  [_tableView reloadData];
}

- (void)viewDidUnload{
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (VerticalLayoutItemInfoCell *)drawShadowVerticalInfoCell:(NSString *)title
                                                  subTitle:(NSString *)subTitle
                                                   content:(NSString *)content
                                            cellIdentifier:(NSString *)cellIdentifier
                                                    height:(CGFloat)height
                                                 clickable:(BOOL)clickable {
  
  VerticalLayoutItemInfoCell *cell = (VerticalLayoutItemInfoCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[VerticalLayoutItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier] autorelease];
  }
  [cell drawShadowInfoCell:title
                  subTitle:subTitle
                   content:content
                cellHeight:height
                 clickable:clickable];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.accessoryType = UITableViewCellAccessoryNone;

  return cell;
}

- (CGFloat)tipsCellHeight:(NSString *)content {
  CGSize size = [LocaleStringForKey(NSCouponTipsMsg, nil) sizeWithFont:BOLD_FONT(14)
                                                  constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH,
                                                                               CGFLOAT_MAX)
                                                      lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  
  if (content && content.length > 0) {
    size = [content sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
  }
  
  return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return CELL_COUNT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case COUPON_SEC_TITLE_CELL:
    case COUPON_SEC_SHOW_CELL:
      return COUPON_TITLE_CELL_HEIGHT;
      
    case COUPON_SEC_INFO_CELL:
    {
      CGSize size = [self.brand.couponInfo sizeWithFont:FONT(13)
                                      constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                          lineBreakMode:NSLineBreakByWordWrapping];
      return size.height + MARGIN * 4;
    }
      
    case COUPON_SEC_TIPS_CELL:
    {
      
      return [self tipsCellHeight:LocaleStringForKey(NSCouponTip_1Msg, nil)];
    }
      
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case COUPON_SEC_TITLE_CELL:
    {
      static NSString *kCellIdentifier = @"CouponTitleCell";
      
      AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier] autorelease];
      }
      [cell drawCell:LocaleStringForKey(NSIalumniCouponTitle, nil)
            subTitle:nil
                font:BOLD_FONT(14)
           textColor:CELL_TITLE_COLOR
       textAlignment:UITextAlignmentRight
          cellHeight:COUPON_TITLE_CELL_HEIGHT
    showBottomShadow:NO];
      return cell;
      
    }
      
    case COUPON_SEC_INFO_CELL:
    {
      static NSString *kCellIdentifier = @"CouponInfoCell";
      
      AlumniCouponInfoCell *cell = (AlumniCouponInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:kCellIdentifier] autorelease];
      }
      
      [cell drawCell:self.brand.couponInfo];
      return cell;
    }
      
    case COUPON_SEC_SHOW_CELL:
    {
      static NSString *kCellIdentifier = @"CouponShowCell";
      AlumniCouponTitleCell *cell = (AlumniCouponTitleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[AlumniCouponTitleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier] autorelease];
        cell.backgroundColor = HIGHLIGHT_TEXT_CELL_COLOR;
      }
      
      [cell drawCell:LocaleStringForKey(NSShowForUseCouponTitle, nil)
            subTitle:nil
                font:BOLD_FONT(12)
           textColor:BASE_INFO_COLOR
       textAlignment:UITextAlignmentCenter
          cellHeight:COUPON_TITLE_CELL_HEIGHT
    showBottomShadow:NO];
      
      return cell;
    }
      
    case COUPON_SEC_TIPS_CELL:
    {
      static NSString *kCellIdentifier = @"CouponTipsCell";
      
      return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSCouponTipsMsg, nil)
                                     subTitle:nil
                                      content:LocaleStringForKey(NSCouponTip_1Msg, nil)
                               cellIdentifier:kCellIdentifier
                                       height:[self tipsCellHeight:LocaleStringForKey(NSCouponTip_1Msg, nil)]
                                    clickable:YES];

    }
      
    default:
      return nil;
  }
}

@end
