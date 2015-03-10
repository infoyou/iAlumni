//
//  GroupFormListCell.m
//  iAlumni
//
//  Created by Adam on 13-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GroupFormListCell.h"
#import "Post.h"

#define FONT_SIZE       15.0f

@interface GroupFormListCell()
@property (nonatomic, retain) id currentPopTipViewTarget;
@property (nonatomic, retain) UIImageView *selfImgView;
@property (nonatomic, retain) UIButton *selfImageButton;
@property (nonatomic, retain) UIImageView *targetImgView;
@property (nonatomic, retain) UIButton *targetImageButton;
@property (nonatomic, retain) Post *post;

@property (nonatomic, copy) NSString *selfImgUrl;
@property (nonatomic, copy) NSString *targetImgUrl;

@end

@implementation GroupFormListCell
@synthesize currentPopTipViewTarget;
@synthesize parentView;

#pragma mark - init view
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _delegate = imageClickableDelegate;
    }
    return self;
}

- (void)dealloc {
    
    self.selfImgUrl = nil;
    self.targetImgUrl = nil;
    self.targetImageButton = nil;
    self.selfImageButton = nil;
    self.targetImgView = nil;
    self.selfImgView = nil;
    
    self.post = nil;
    
    [super dealloc];
}

#pragma mark - open profile
- (void)openSelfProfile:(id)sender {
    
    if (_delegate) {
        [_delegate openProfile:[AppManager instance].personId userType:[AppManager instance].userType];
    }
}

- (void)openTargetProfile:(id)sender {
    
    if (_delegate) {
        [_delegate openProfile:self.post.authorId userType:@"1"/*self.alumni.userType*/];
    }
}

#pragma mark - draw view
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)drawUserIcon {
    NSMutableArray *urls = [NSMutableArray array];
    
    if (self.selfImgUrl && self.selfImgUrl.length > 0) {
        [urls addObject:self.selfImgUrl];
    }
    
    if (self.targetImgUrl && self.targetImgUrl.length > 0) {
        [urls addObject:self.targetImgUrl];
    }

    [self fetchImage:urls forceNew:NO];
}

- (void)drawPost:(Post*)post {
    
    self.post = post;
    BOOL isWrite = NO;
    self.targetImgUrl = post.authorPicUrl;
    
    if ([post.authorId isEqualToString:[AppManager instance].personId]) {
        self.selfImgUrl = post.authorPicUrl;
        self.targetImgUrl = NULL_PARAM_VALUE;
        isWrite = YES;
    } else {
        self.targetImgUrl = post.authorPicUrl;
        self.selfImgUrl = NULL_PARAM_VALUE;
        isWrite = NO;
    }
    
    // Initialization code
    
    popView = [[UIView alloc] initWithFrame:CGRectZero];
	popView.backgroundColor = TRANSPARENT_COLOR;
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH/2, 14);
    dateLabel.font = FONT(FONT_SIZE-5.0f);
    dateLabel.backgroundColor = TRANSPARENT_COLOR;
    dateLabel.text = [CommonUtils simpleFormatDate:[CommonUtils convertDateTimeFromUnixTS:[post.createdTime longLongValue]] secondAccuracy:YES];
    [self.contentView addSubview:dateLabel];
    
    // Text
    bubbleLabel = [[UILabel alloc] init];
	bubbleLabel.text = post.content;
	bubbleLabel.font = FONT(FONT_SIZE);
    
    CGSize size = [bubbleLabel.text sizeWithFont:bubbleLabel.font constrainedToSize:CGSizeMake(180.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
    
	bubbleLabel.frame = CGRectMake(25.0f, 25.0f, size.width+5, size.height+6);
	bubbleLabel.backgroundColor = TRANSPARENT_COLOR;
	bubbleLabel.numberOfLines = 0;
	bubbleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    // bubble Image
    
    UIImage *bubbleImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:isWrite ? @"bubble0" : @"bubble1" ofType:@"png"]];
	bubbleImageView = [[UIImageView alloc] initWithImage:[bubbleImg stretchableImageWithLeftCapWidth:50 topCapHeight:35]];
	bubbleImageView.frame = CGRectMake(0.0f, 8.0f, size.width+40.f, size.height+26.0f);
    
    //    popView.backgroundColor = [UIColor blueColor];
    
	if(isWrite) {
        
        self.selfImgView = [[[UIImageView alloc] init] autorelease];
        self.selfImgView.frame = CGRectMake(265.0f, MARGIN*3, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        self.selfImgView.contentMode = UIViewContentModeScaleAspectFill;
        self.selfImgView.backgroundColor = COLOR(234, 234, 234);
        self.selfImgView.layer.cornerRadius = 6.0f;
        self.selfImgView.layer.masksToBounds = YES;
        self.selfImgView.backgroundColor = TRANSPARENT_COLOR;
        self.selfImgView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.selfImgView];
        
        // self Img Button
        self.selfImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selfImageButton.layer.cornerRadius = 6.0f;
        self.selfImageButton.layer.masksToBounds = YES;
        self.selfImageButton.layer.borderWidth = 1.0f;
        self.selfImageButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.selfImageButton.showsTouchWhenHighlighted = YES;
        [self.selfImageButton addTarget:self action:@selector(openSelfProfile:) forControlEvents:UIControlEventTouchUpInside];
        self.selfImageButton.frame = CGRectMake(265.0f, MARGIN*3, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        [self.selfImgView addSubview:self.selfImageButton];
        
		popView.frame = CGRectMake(220.0f-size.width, MARGIN*2, size.width+40.f, size.height+30.0f);
        
        bubbleLabel.frame = CGRectMake(15.0f, 15.0f, size.width+5, size.height+6);
	} else {
        
        self.targetImgView = [[[UIImageView alloc] init] autorelease];
        self.targetImgView.frame = CGRectMake(MARGIN, MARGIN*3, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        self.targetImgView.contentMode = UIViewContentModeScaleAspectFill;
        self.targetImgView.backgroundColor = COLOR(234, 234, 234);
        self.targetImgView.layer.cornerRadius = 6.0f;
        self.targetImgView.layer.masksToBounds = YES;
        self.targetImgView.backgroundColor = TRANSPARENT_COLOR;
        self.targetImgView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.targetImgView];
        
        // target Img Button
        self.targetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.targetImageButton.layer.cornerRadius = 6.0f;
        self.targetImageButton.layer.masksToBounds = YES;
        self.targetImageButton.layer.borderWidth = 1.0f;
        self.targetImageButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.targetImageButton.showsTouchWhenHighlighted = YES;
        [self.targetImageButton addTarget:self action:@selector(openTargetProfile:) forControlEvents:UIControlEventTouchUpInside];
        self.targetImageButton.frame = CGRectMake(0, 0, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        [self.targetImgView addSubview:self.targetImageButton];
        
		popView.frame = CGRectMake(2*MARGIN+CHART_PHOTO_WIDTH, MARGIN*2, size.width+40.f, size.height+30.0f);
        
        bubbleLabel.frame = CGRectMake(20.0f, 15.0f, size.width+5, size.height+6);
    }
    
	[popView addSubview:bubbleImageView];
	[bubbleImageView release];
	[popView addSubview:bubbleLabel];
    
    [self.contentView addSubview:popView];
    
    // copy
    _popViewBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _popViewBut.layer.cornerRadius = 6.0f;
    _popViewBut.layer.masksToBounds = YES;
    [_popViewBut addTarget:self action:@selector(doPopView:) forControlEvents:UIControlEventTouchUpInside];
    _popViewBut.frame = popView.frame;
//    [self.contentView addSubview:_popViewBut];
    
    [self drawUserIcon];
}

- (void)dismissAllPopTipViews {
	while ([[AppManager instance].visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = ([AppManager instance].visiblePopTipViews)[0];
		[[AppManager instance].visiblePopTipViews removeObjectAtIndex:0];
		[popTipView dismissAnimated:YES];
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self dismissAllPopTipViews];
    [_delegate hideKeyboard];
}

- (void)doPopView:(id)sender {
    [self dismissAllPopTipViews];
    
    if (sender == currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	} else {
        CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:@"Copy"];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor blackColor];
        popTipView.textColor = [UIColor whiteColor];
        popTipView.animation = arc4random() % 2;
        [popTipView presentPointingAtView:bubbleLabel inView:parentView animated:YES];
        [[AppManager instance].visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
    
}

#pragma mark - CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    NSLog(@"bubbleLabel text is %@", bubbleLabel.text);
    [AppManager instance].chartContent = bubbleLabel.text;
    [[AppManager instance].visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:bubbleLabel.text];
}

#pragma mark - arrange photos
- (void)setMyAvatar:(UIImage *)image {
    [self.selfImageButton setImage:[CommonUtils cutMiddlePartImage:image
                                                             width:self.selfImageButton.frame.size.width
                                                            height:self.selfImageButton.frame.size.height]
                          forState:UIControlStateNormal];
}

- (void)setOtherSideAvatar:(UIImage *)image {
    [self.targetImageButton setImage:[CommonUtils cutMiddlePartImage:image
                                                               width:self.targetImageButton.frame.size.width
                                                              height:self.targetImageButton.frame.size.height]
                            forState:UIControlStateNormal];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        if ([url isEqualToString:self.selfImgUrl]) {
            self.selfImgView.image = [UIImage imageNamed:@"defaultUser.png"];
        } else if ([url isEqualToString:self.targetImgUrl]) {
            self.targetImgView.image = [UIImage imageNamed:@"defaultUser.png"];
        }
    }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        if ([url isEqualToString:self.selfImgUrl]) {
            self.selfImgView.image = image;
        } else if ([url isEqualToString:self.targetImgUrl]) {
            self.targetImgView.image = image;
        }
    }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        if ([url isEqualToString:self.selfImgUrl]) {
            self.selfImgView.image = image;
        } else if ([url isEqualToString:self.targetImgUrl]) {
            self.targetImgView.image = image;
        }
    }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
    
}

@end
