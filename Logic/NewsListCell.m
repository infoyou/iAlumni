//
//  NewsListCell.m
//  iAlumni
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NewsListCell.h"
#import "Upcoming.h"
#import "Report.h"

#define SEPARATOR_WIDTH   1.0f
#define SEPARATOR_HEIGHT  97.0f

#define WEEK_WIDTH        40.0f
#define WEEK_HEIGHT       20.0f

#define DAY_WIDTH         50.0f
#define DAY_HEIGHT        30.0f

#define MONTH_WIDTH       80.0f
#define MONTH_HEIGHT      14.0f

#define TITLE_HEIGHT      20.0f

#define SHORT_DESC_HEIGHT 80.0f

#define INDICATOR_TOP     25.0f
#define INDICATOR_WIDTH   16.0f
#define INDICATOR_HEIGHT  16.0f

#define FONT_SIZE         14.0f

@implementation NewsListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, NEWS_LIST_CELL_HEIGHT/2 - DATETIME_HEIGHT/2, DATETIME_WIDTH, DATETIME_HEIGHT)] autorelease];
        backgroundView.backgroundColor = TRANSPARENT_COLOR;
        backgroundView.layer.cornerRadius = 8.0f;
        backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
        backgroundView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        backgroundView.layer.shadowOpacity = 0.6f;
        [self.contentView addSubview:backgroundView];
        
        _datetimeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DATETIME_WIDTH, DATETIME_HEIGHT)];
        _datetimeImageView.backgroundColor = TRANSPARENT_COLOR;
        _datetimeImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _datetimeImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        _datetimeImageView.image = [UIImage imageNamed:@"date.png"];
        [backgroundView addSubview:_datetimeImageView];
        
        _weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WEEK_WIDTH, WEEK_HEIGHT)];
        _weekLabel.center = CGPointMake(_datetimeImageView.bounds.size.width/2, MARGIN*2+3);
        _weekLabel.backgroundColor = TRANSPARENT_COLOR;
        _weekLabel.font = FONT(13);
        _weekLabel.textColor = [UIColor whiteColor];
        //_weekLabel.textColor = [UIColor darkGrayColor];
        _weekLabel.textAlignment = UITextAlignmentCenter;
        _weekLabel.highlightedTextColor = [UIColor whiteColor];
        [_datetimeImageView addSubview:_weekLabel];
        
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DAY_WIDTH, DAY_HEIGHT)];
        _dayLabel.center = CGPointMake(_datetimeImageView.bounds.size.width/2, _datetimeImageView.bounds.size.height/2+3);
        _dayLabel.backgroundColor = TRANSPARENT_COLOR;
        _dayLabel.font = BOLD_FONT(22);
        _dayLabel.textAlignment = UITextAlignmentCenter;
        [_datetimeImageView addSubview:_dayLabel];
        
        _monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MONTH_WIDTH, MONTH_HEIGHT)];
        _monthLabel.center = CGPointMake(_datetimeImageView.bounds.size.width/2, _datetimeImageView.bounds.size.height - MARGIN * 3 + 3);
        _monthLabel.backgroundColor = TRANSPARENT_COLOR;
        _monthLabel.font = FONT(12);
        _monthLabel.textAlignment = UITextAlignmentCenter;
        [_datetimeImageView addSubview:_monthLabel];  
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 4 + DATETIME_WIDTH + MARGIN, MARGIN * 2 + 3, LIST_WIDTH - MARGIN * 4 - (MARGIN * 4 + DATETIME_WIDTH + MARGIN * 5), TITLE_HEIGHT)];
        _titleLabel.backgroundColor = TRANSPARENT_COLOR;
        _titleLabel.font = Arial_FONT(FONT_SIZE);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 4;
        _titleLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        _shortDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.size.height, _titleLabel.frame.size.width - MARGIN, SHORT_DESC_HEIGHT)];
        _shortDescLabel.backgroundColor = TRANSPARENT_COLOR;
        _shortDescLabel.font = FONT(15);
        _shortDescLabel.textColor = [UIColor grayColor];
        _shortDescLabel.numberOfLines = 2;
        _shortDescLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _shortDescLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_shortDescLabel];
        
        _readIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, NEWS_LIST_CELL_HEIGHT - INDICATOR_TOP, INDICATOR_WIDTH, INDICATOR_HEIGHT)];
        _readIndicator.image = [UIImage imageNamed:@"eye.png"];
        _readIndicator.backgroundColor = TRANSPARENT_COLOR;
        //      [self.contentView addSubview:_readIndicator];
        
        _readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 4 + DATETIME_WIDTH + MARGIN, _readIndicator.frame.origin.y-2, 80, 20)];
        _readCountLabel.backgroundColor = TRANSPARENT_COLOR;
        _readCountLabel.font = FONT(14);
        _readCountLabel.textColor = [UIColor blackColor];
        _readCountLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_readCountLabel];
        
        _likeIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, _readIndicator.frame.origin.y, INDICATOR_WIDTH, INDICATOR_HEIGHT)];
        _likeIndicator.image = [UIImage imageNamed:@"like.png"];
        _likeIndicator.backgroundColor = TRANSPARENT_COLOR;
        //      [self.contentView addSubview:_likeIndicator];
        
        _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_likeIndicator.frame.size.width + _likeIndicator.frame.origin.x+2, _likeIndicator.frame.origin.y-2, 80, 20)];
        _likeCountLabel.backgroundColor = TRANSPARENT_COLOR;
        _likeCountLabel.font = FONT(14);
        _likeCountLabel.textColor = [UIColor blackColor];
        _likeCountLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_likeCountLabel];

    }
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(_weekLabel);
    RELEASE_OBJ(_dayLabel);
    RELEASE_OBJ(_monthLabel);
    RELEASE_OBJ(_datetimeImageView);
    RELEASE_OBJ(_separator);
    RELEASE_OBJ(_titleLabel);
    RELEASE_OBJ(_shortDescLabel);
    RELEASE_OBJ(_readIndicator);
    RELEASE_OBJ(_likeIndicator);
    RELEASE_OBJ(_readCountLabel);
    RELEASE_OBJ(_likeCountLabel);
    
    [super dealloc];
}

- (void)drawReport:(Report*)report{
    
    _titleLabel.text = report.title;
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font 
                               constrainedToSize:CGSizeMake(_titleLabel.frame.size.width, 68.0f)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size.height);
    
    NSDate *datetime = [CommonUtils NSStringDateToNSDate:report.date];
    _weekLabel.text = [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime];
    _dayLabel.text = [CommonUtils datetimeWithFormat:@"d" datetime:datetime];
    _monthLabel.text = [NSString stringWithFormat:@"%@/%@", 
                        [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime], 
                        [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime]];
    
    [self setCellStyle:NEWS_LIST_CELL_HEIGHT];
}

- (void)drawUpcoming:(Upcoming*)upcoming{
    
    _titleLabel.text = upcoming.title;
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font 
                               constrainedToSize:CGSizeMake(_titleLabel.frame.size.width, 68.0f)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size.height);
    
    NSDate *datetime = [CommonUtils NSStringDateToNSDate:upcoming.date];
    _weekLabel.text = [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime];
    _dayLabel.text = [CommonUtils datetimeWithFormat:@"d" datetime:datetime];
    _monthLabel.text = [NSString stringWithFormat:@"%@/%@", 
                        [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime], 
                        [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime]];
    
    [self setCellStyle:NEWS_LIST_CELL_HEIGHT];
}

@end
