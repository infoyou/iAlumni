//
//  UserIconViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserIconViewController.h"
#import "AlumniDetail.h"
#import "CommonUtils.h" 

@interface UserIconViewController ()
@property (nonatomic, retain) AlumniDetail *user;
@property (nonatomic, copy) NSString *userImageUrl;
@property (nonatomic, copy) NSString *userType;
@end

@implementation UserIconViewController
@synthesize user = _user;
@synthesize userImageUrl = _userImageUrl;
@synthesize userType = _userType;

- (id)initWithUser:(AlumniDetail *)user
{
    self = [super initWithMOC:nil holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {
        // Custom initialization
        self.user = user;
        self.userImageUrl = user.imageUrl;
        self.userType = user.userType;
    }
    return self;
}

- (id)initWithMsg:(NSString *)imageUrl userType:(NSString *)userType
{
    self = [super initWithMOC:nil holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {
        // Custom initialization
        self.userImageUrl = imageUrl;
        self.userType = userType;
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_user);
    self.userImageUrl = nil;
    self.userType = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    CGRect mFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    canvasView = [[UIView alloc] initWithFrame:mFrame];
    canvasView.backgroundColor = [UIColor blackColor];
    
    UIGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] 
                                       initWithTarget:self action:@selector(closeImage:)] autorelease];
    singleTap.delegate = self;
    UIImage *image = nil;
    NSString *mUrl = nil;
    
    if(self.userImageUrl && ![self.userImageUrl isEqualToString:NULL_PARAM_VALUE]){
        if (![@"1" isEqualToString:self.userType]) {
            mUrl = self.userImageUrl;
        }else {
            mUrl = [CommonUtils geneUrl:self.userImageUrl itemType:IMAGE_TY];    
        }
        
        image = [[WXWImageManager instance].imageCache getImage:mUrl];
    }else{
        image = [UIImage imageNamed:@"defaultUser.png"];
    }
    
    UIImageView *showImageView = [[[UIImageView alloc] init] autorelease];
    
    CGRect mImgFrame;
    if (image.size.height>SCREEN_HEIGHT) {
        mImgFrame = CGRectMake((SCREEN_WIDTH-image.size.width)/2, 0, image.size.width, SCREEN_HEIGHT);
        showImageView.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        mImgFrame = CGRectMake((SCREEN_WIDTH-image.size.width)/2, (SCREEN_HEIGHT-image.size.height)/2, image.size.width, image.size.height);
        showImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    showImageView.frame = mImgFrame;
    showImageView.image = image;
    [canvasView addSubview:showImageView];
    
    [canvasView addGestureRecognizer:singleTap];
    [self.view addSubview:canvasView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeImage:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
