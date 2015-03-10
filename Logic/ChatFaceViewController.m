#import "ChatFaceViewController.h"
#import "ChatListViewController.h"

@implementation ChatFaceViewController
@synthesize phraseArray = _phraseArray;
@synthesize chatViewController = _chatViewController;
@synthesize faceScrollView = _faceScrollView;

- (id)initWithObject:(ChatListViewController*)aChatViewController
{
    if ((self = [super init])) {
        self.chatViewController = aChatViewController;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.faceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height)];
    self.faceScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	self.faceScrollView.dataSource = self;
	self.faceScrollView.delegate = self;
    [self.view addSubview:self.faceScrollView];
    
	NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i = 0;i<105;i++){
        UIImage *face = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]];
        NSMutableDictionary *dicFace = [NSMutableDictionary dictionary];
//        if (i<10){
//        [dicFace setValue:face forKey:[NSString stringWithFormat:@"</00%d>",i]];
//        }else if (i<100){
//            [dicFace setValue:face forKey:[NSString stringWithFormat:@"</0%d>",i]];
//        }else
//        {
            [dicFace setValue:face forKey:[NSString stringWithFormat:@"[/%d]",i]];
//        }
        
        [temp addObject:dicFace];
    }
    self.phraseArray = temp;
	[temp release];
    [self showEmojiView];
    
}

-(void)dismissMyselfAction:(id)sender{

	[self dismissModalViewControllerAnimated:YES];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setFaceScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_chatViewController release];
	[_phraseArray release];
    [_faceScrollView release];
    [super dealloc];
}


- (void)showEmojiView{
    
    int xIndex = 0;
    
    int yIndex = 0;

    int emojiRangeArray[12] = {0,10,20,30,40,50,60,70,80,90,100,104};    
    for (int j = 0 ; j<12 ; j++ ) {
        int startIndex = emojiRangeArray[j];
        int endIndex = emojiRangeArray[j+1];
        
        for (int i = startIndex ; i<= endIndex ; i++ ) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.frame = CGRectMake(10 + xIndex*32, 10 + yIndex*32, 32.0f, 32.0f);
            NSMutableDictionary *tempdic = (self.phraseArray)[i];
//            if (i<10){
//            UIImage *tempImage = [tempdic valueForKey:[NSString stringWithFormat:@"</00%d>",i]];
//            [button setBackgroundImage:tempImage forState:UIControlStateNormal];
//            } else if (i<100){
//                UIImage *tempImage = [tempdic valueForKey:[NSString stringWithFormat:@"</0%d>",i]];
//                [button setBackgroundImage:tempImage forState:UIControlStateNormal];
//            }else
//            {
                UIImage *tempImage = [tempdic valueForKey:[NSString stringWithFormat:@"[/%d]",i]];
                [button setBackgroundImage:tempImage forState:UIControlStateNormal];
//            }
            button.tag = i;
            
            [button addTarget:self action:@selector(didSelectAFace:)forControlEvents:UIControlEventTouchUpInside];
            
            [self.faceScrollView addSubview:button];
            
            xIndex += 1;
            
            if (xIndex == 9) {                
                xIndex = 0;
                yIndex += 1;
            }
        }
    }
    
    [self.faceScrollView setContentSize:CGSizeMake(300.0f, 12 + (yIndex+1)*32)];
}


-(void)didSelectAFace:(id)sender
{
    UIButton *tempbtn = (UIButton *)sender;
    NSMutableDictionary *tempdic = (self.phraseArray)[tempbtn.tag];
    NSArray *temparray = [tempdic allKeys];
//    NSString *faceStr = [NSString stringWithFormat:@"%@",[temparray objectAtIndex:0]];
    NSString *faceStr = [[[NSString alloc] initWithFormat:@"%@",temparray[0]] autorelease];
    
    self.chatViewController.phraseString = faceStr;
    [self.chatViewController.messageString appendString:self.chatViewController.phraseString];
    NSLog(@"self.messageString is %@",faceStr);
    NSLog(@"self.messageString is %@",self.chatViewController.phraseString);
    NSLog(@"self.messageString is %@",self.chatViewController.messageString);
    [self dismissModalViewControllerAnimated:YES];
}

@end
