//
//  TaxiCardViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TaxiCardViewController.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@interface TaxiCardViewController()
@property (nonatomic, copy) NSString *part1;
@property (nonatomic, copy) NSString *part2;
@property (nonatomic, copy) NSString *part3;
@property (nonatomic, copy) NSString *name;
@end

@implementation TaxiCardViewController

@synthesize part1 = _part1;
@synthesize part2 = _part2;
@synthesize part3 = _part3;
@synthesize name = _name;

- (id)initWithAddressPart1:(NSString *)part1
                     part2:(NSString *)part2
                     part3:(NSString *)part3 
                      name:(NSString *)name 
                    holder:(id)holder   
          backToHomeAction:(SEL)backToHomeAction
                  latitude:(double)latitude
                 longitude:(double)longitude {
  
  self = [super initWithMOC:nil 
                     holder:holder
           backToHomeAction:backToHomeAction
                 needGoHome:NO];
  
  if (self) {
    self.part1 = part1;
    self.part2 = part2;
    self.part3 = part3;
    self.name = name;
    
    _latitude = latitude;
    _longitude = longitude;
  }
  
  return self;
}

- (void)dealloc
{
  self.part1 = nil;
  self.part2 = nil;
  self.part3 = nil;
  self.name = nil;
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - show map
- (void)lanuchGoogleMap:(id)sender {
  NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current%%20Location&daddr=%f,%f", 
                   _latitude, _longitude];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSRouteTitle, nil)
                            target:self
                            action:@selector(lanuchGoogleMap:)];
  
  UILabel *iwantLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 200/2, 20, 200, 30)] autorelease];
  iwantLabel.backgroundColor = TRANSPARENT_COLOR;
  iwantLabel.textColor = [UIColor whiteColor];
  iwantLabel.font = BOLD_FONT(20);
  iwantLabel.textAlignment = UITextAlignmentCenter;
  iwantLabel.text = @"您好，我想去";
  [self.view addSubview:iwantLabel];
  
  /*
  UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 300/2, 50, 300, 60)] autorelease];
  nameLabel.backgroundColor = TRANSPARENT_COLOR;
  nameLabel.textColor = [UIColor whiteColor];
  nameLabel.font = BOLD_FONT(20);
  nameLabel.textAlignment = UITextAlignmentCenter;
  nameLabel.numberOfLines = 0;
  nameLabel.text = self.name;
  [self.view addSubview:nameLabel];
  */
  UILabel *part1Label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  part1Label.backgroundColor = TRANSPARENT_COLOR;
  part1Label.numberOfLines = 2;
  part1Label.lineBreakMode = NSLineBreakByWordWrapping;
  part1Label.textColor = [UIColor whiteColor];
  part1Label.font = BOLD_FONT(23);
  part1Label.textAlignment = UITextAlignmentCenter;
  part1Label.text = self.part1;
  CGSize size = [part1Label.text sizeWithFont:part1Label.font
                            constrainedToSize:CGSizeMake(300, 70)
                                lineBreakMode:NSLineBreakByWordWrapping];
  part1Label.frame = CGRectMake(self.view.frame.size.width/2 - 300/2, /*160*/60, 300, size.height);
  [self.view addSubview:part1Label];
  
  UILabel *part2Label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  part2Label.backgroundColor = TRANSPARENT_COLOR;
  part2Label.numberOfLines = 2;
  part2Label.lineBreakMode = NSLineBreakByWordWrapping;
  part2Label.textColor = [UIColor whiteColor];
  part2Label.font = BOLD_FONT(23);
  part2Label.textAlignment = UITextAlignmentCenter;
  part2Label.text = self.part2;
  size = [part2Label.text sizeWithFont:part2Label.font
                     constrainedToSize:CGSizeMake(300, 70)
                         lineBreakMode:NSLineBreakByWordWrapping];
  part2Label.frame = CGRectMake(self.view.frame.size.width/2 - 300/2, 
                                part1Label.frame.origin.y + part1Label.frame.size.height + MARGIN, 300, size.height);
  [self.view addSubview:part2Label];
  
  /*
  UILabel *part3Label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  part3Label.backgroundColor = TRANSPARENT_COLOR;
  part3Label.numberOfLines = 2;
  part3Label.lineBreakMode = NSLineBreakByWordWrapping;
  part3Label.textColor = [UIColor whiteColor];
  part3Label.font = BOLD_FONT(23);
  part3Label.textAlignment = UITextAlignmentCenter;
  part3Label.text = self.part3;
  size = [part3Label.text sizeWithFont:part3Label.font 
                     constrainedToSize:CGSizeMake(300, 70) 
                         lineBreakMode:NSLineBreakByWordWrapping];
  part3Label.frame = CGRectMake(self.view.frame.size.width/2 - 300/2, part2Label.frame.origin.y + part2Label.frame.size.height + MARGIN, 300, size.height);
  [self.view addSubview:part3Label];
   */
  
  self.view.backgroundColor = [UIColor blackColor];
}


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
