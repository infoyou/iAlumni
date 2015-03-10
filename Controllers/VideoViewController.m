
#import "VideoViewController.h"
#import "DirectionMPMoviePlayer.h"
#import "CommonUtils.h"

@interface VideoViewController ()

@end

@implementation VideoViewController
@synthesize connection;
@synthesize connectionData;
@synthesize url;
@synthesize _moviePlayerVC;

-(id)initWithURL:(NSString *)videoUrl
{
	self = [super init];
	if(self != nil)
	{
		self.url = videoUrl;
        NSLog(@"videoUrl　%@", videoUrl);
	}
	return self;
}

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self play];
    
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        // 包含 ios5 以上版本
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        // 包含 ios5 以上版本
        UIImage *image = [UIImage imageNamed:@"navigationBarBackground.png"];
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
    self.connectionData = nil;
    RELEASE_OBJ(_moviePlayerVC);
    
    [super dealloc];
}

#pragma mark - business
- (void)play
{
    // maybe need handle specified case in different iOS version
    NSURL *urlpath = [NSURL URLWithString:self.url];
    
    _moviePlayerVC = [[DirectionMPMoviePlayer alloc] initWithContentURL:urlpath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayerVC.moviePlayer];
    
    if ([CommonUtils currentOSVersion] > 6.f && [CommonUtils currentOSVersion] < 7.f) {
        
        [self presentMoviePlayerViewControllerAnimated:_moviePlayerVC];
        _moviePlayerVC.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        _moviePlayerVC.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    } else {
        
        _moviePlayerVC.moviePlayer.view.transform = CGAffineTransformMakeRotation((M_PI / 2.0));
        [self presentModalViewController:_moviePlayerVC animated:YES];
        [[_moviePlayerVC moviePlayer] play];
    }
}

-(void)moviePlayBackDidFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_moviePlayerVC.moviePlayer];
    
    [_moviePlayerVC setWantsFullScreenLayout:NO];
    [self.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
#endif
}

#pragma mark - web
- (void) connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}

- (void) connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data{
    NSLog(@"Received data");
    [self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    /* 下载的数据 */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //获取文件路径
    NSArray *urlArray = [self.url componentsSeparatedByString:@"/"];
    int size = [urlArray count];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[urlArray objectAtIndex:(size-1)]];
    
    NSLog(@"%@ path = ",path);
    
    if ([self.connectionData writeToFile:path atomically:YES]) {
        NSLog(@"保存成功.");
    } else {
        NSLog(@"保存失败.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.connectionData setLength:0];
}

@end