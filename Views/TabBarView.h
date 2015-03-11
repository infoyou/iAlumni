//
//  TabBarView.h
//  iAlumni
//
//  Created by Adam on 13-1-10.
//
//

#import <UIKit/UIKit.h>

@protocol TabDelegate <NSObject>
- (void)selectHomepage;
- (void)selectAlumni;
- (void)selectEvent;
- (void)selectBiz;
- (void)selectBizOpp;
- (void)selectMore;
- (void)selectPersonal;
- (void)selectSupplyDemand;
- (void)selectEventByHtml5;

@end


@interface TabBarView : UIView {
    
  @private
  UIView *_selectedIndicator;
  
  id<TabDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<TabDelegate>)delegate;

- (void)refreshBadges;

- (void)refreshItems;

- (void)switchTabHighlightStatus:(NSInteger)tag;

@end
