//
//  UserDetailCell.m
//  CEIBS
//
//  Created by Adam on 11-2-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserDetailCell.h"
#import "GlobalConstants.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "ECGradientButton.h"

#define CTNT_X		50.0f
#define CTNT_Y		12.0f
#define CTNT_WIDTH	200.0f
#define CTNT_HEIGHT 20.0f

#define TIPS_X		230.0f
#define TIPS_Y		12.0f
#define TIPS_WIDTH	100.0f
#define TIPS_HEIGHT 20.0f

#define ACTION_NAME_X       220.0f
#define ACTION_NAME_Y       12.0f
#define ACTION_NAME_WIDTH   60.0f
#define ACTION_NAME_HEIGHT  20.0f

#define BTN_X               10.0f
#define BTN_Y               7.0f
#define BTN_WIDTH           80.0f
#define BTN_HEIGHT          30.0f

#define CELL_WIDTH	280.0f

#define TITLE_WIDTH	100.0f

static NSInteger contentTag	= 2;
static NSInteger tipsTag	= 3;
static NSInteger actionTag  = 4;

@implementation UserDetailCell

@synthesize content;
@synthesize tips;
@synthesize button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		content = [[UILabel alloc] initWithFrame:CGRectMake(CTNT_X, CTNT_Y, CTNT_WIDTH, CTNT_HEIGHT)];
		content.tag = contentTag;
		content.font = FONT(15);
		content.textColor = [UIColor blackColor];
		content.highlightedTextColor = [UIColor whiteColor];
		content.backgroundColor = TRANSPARENT_COLOR;
		[self.contentView addSubview:content];
		
		tips = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, TIPS_Y, TIPS_WIDTH, TIPS_HEIGHT)];
		tips.tag = tipsTag;
		tips.font = FONT(15);
		tips.highlightedTextColor = [UIColor whiteColor];
		tips.backgroundColor = TRANSPARENT_COLOR;
		[self.contentView addSubview:tips];
		
		self.textLabel.font = BOLD_FONT(15);
		self.textLabel.backgroundColor = TRANSPARENT_COLOR;
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	[self setBackgroundColor:[UIColor whiteColor]];
}

- (CGRect)getContentFrame
{
    CGRect backVal;
    CGSize constraint =	CGSizeMake(TITLE_WIDTH, CGFLOAT_MAX);
	CGSize size = [self.textLabel.text sizeWithFont:BOLD_FONT(15)
								  constrainedToSize:constraint 
									  lineBreakMode:NSLineBreakByWordWrapping];
	float x = size.width + MARGIN * 3;
    float black = 62;
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        backVal = CGRectMake(x, CTNT_Y, CELL_WIDTH - x + 10 - black, CTNT_HEIGHT);
    } else {
        backVal = CGRectMake(x, CTNT_Y, CELL_WIDTH - x - black, CTNT_HEIGHT);		
    }

    return backVal;
}

- (void)setContent:(NSString *)text breakLine:(BOOL)breakLine {
	content.text = text;
	
	CGSize constraint =	CGSizeMake(TITLE_WIDTH, CGFLOAT_MAX);
	CGSize size = [self.textLabel.text sizeWithFont:BOLD_FONT(15)
								  constrainedToSize:constraint 
									  lineBreakMode:NSLineBreakByWordWrapping];
	float x = size.width + MARGIN * 3;
	if (tips.hidden) {
        if (self.accessoryType == UITableViewCellAccessoryNone) {
            content.frame = CGRectMake(x, CTNT_Y, CELL_WIDTH - x + 10, CTNT_HEIGHT);
        } else {
            content.frame = CGRectMake(x, CTNT_Y, CELL_WIDTH - x, CTNT_HEIGHT);		
        }

	} else {
        if (breakLine) {
            content.frame = CGRectMake(x, TIPS_HEIGHT + MARGIN * 2, CELL_WIDTH - x - 50, CTNT_HEIGHT);
        } else {
            content.frame = CGRectMake(x, CTNT_Y, CELL_WIDTH - x - 50, CTNT_HEIGHT);
        }
	}
}

- (void)setButtonValues:(id)target action:(SEL)action imageName:(NSString *)imageName title:(NSString *)title contentType:(NSString *)contentType tipsText:(NSString *)tipsText actionNameText:(NSString *)actionNameText {
    
    // set button
    if (nil == button) {
        /*
        button = [UIUtils drawButton:CGRectMake(BTN_X, BTN_Y, BTN_WIDTH, BTN_HEIGHT)
                               imageName:imageName 
                                   title:title 
                                  target:target 
                                  action:action 
                                   isBig:NO];
        */
        
      button = [[[ECGradientButton alloc] initWithFrame:CGRectMake(BTN_X, BTN_Y, BTN_WIDTH, BTN_HEIGHT)
                                               target:target
                                               action:action
                                            colorType:RED_BTN_COLOR_TY
                                                title:title
                                                image:nil
                                           titleColor:RED_BTN_TITLE_COLOR
                                     titleShadowColor:RED_BTN_TITLE_SHADOW_COLOR 
                                            titleFont:BOLD_FONT(14)
                                         roundedType:NO_ROUNDED
                                      imageEdgeInsert:ZERO_EDGE
                                      titleEdgeInsert:ZERO_EDGE] autorelease];
      
        [self.contentView addSubview:button];
    }
    [button setTitle:title forState:UIControlStateNormal];
    
    // set and adjust content
    content.textColor = COLOR(74,112,139);
    content.font = BOLD_FONT(15);
    content.text = contentType;
    CGRect contentFrame = content.frame;
    content.frame = CGRectMake(BTN_X + BTN_WIDTH + 20, contentFrame.origin.y, contentFrame.size.width, contentFrame.size.height);
    
    // set and adjust tips
    tips.font = BOLD_FONT(13);
    tips.text = tipsText;
    tips.textColor = COLOR(74,112,139);
    tips.frame = CGRectMake(200, tips.frame.origin.y, tips.frame.size.width, tips.frame.size.height);
    
    
    // set and adjust action name
    if (nil == actionName) {
        actionName = [[UILabel alloc] initWithFrame:CGRectMake(ACTION_NAME_X, ACTION_NAME_Y, ACTION_NAME_WIDTH, ACTION_NAME_HEIGHT)];
        actionName.backgroundColor = TRANSPARENT_COLOR;
        actionName.tag = actionTag;
		actionName.font = FONT(13);
        actionName.textColor = [UIColor darkGrayColor];
		actionName.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview:actionName];
    }
    actionName.text = actionNameText; 
}

- (void)dealloc {
	[content release];
	content = nil;
	
    if (tips) {
        [tips release];
        tips = nil;        
    }
	
	[super dealloc];
}

@end
