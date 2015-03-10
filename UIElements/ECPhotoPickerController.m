//
//  ECPhotoPickerController.m
//  iAlumni
//
//  Created by Adam on 11-11-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECPhotoPickerController.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "ComposerViewController.h"

enum {
	DIFF_ORI,
	LANDSCAPE_ORI,
	PORTRAIT_ORI,
};

#define DEVICE_IS_LANDSCAPE	[CommonUtils currentOrientationIsLandscape]
#define IMAGE_IS_LANDSCAPE	[self imageOrientationIsLandscape]

#define WIDTH               self.view.bounds.size.width
#define HEIGHT              400

#define LANDSCAPE_W_H_RATIO	1.5
#define PORTRAIT_W_H_RATIO	2/3

#define IND_ORIGINAL_X      6.0f 
#define IND_BW_X            180.0f
#define IND_Y               410.0f
#define IND_BW_WIDTH        133.0f
#define IND_ORI_WIDTH       63.0f
#define IND_HEIGHT          2.0f

#define VERTICAL_Y          44.0f

@interface ECPhotoPickerController()
@property(nonatomic, retain) UIImage *originalImage;

- (void)arrangeImageView;
@end

@implementation ECPhotoPickerController

@synthesize delegate = _delegate;
@synthesize imagePicker = _imagePicker;
@synthesize originalImage = _originalImage;

#pragma mark - user action

- (void)selectOriginalImage {
  
  _imageView.image = self.originalImage;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5f];
  
  _selectionIndicator.frame = _originalImageIndicatorFrame;
  
  [UIView commitAnimations];
  
  _bwImageSelected = NO;
}

- (void)selectBWImage {
  
  _handledImage = [CommonUtils effectedImageWithType:INKWELL_PHOTO_TY
                                       originalImage:self.originalImage];
  _imageView.image = _handledImage;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5f];
  
  _selectionIndicator.frame = _bWImageIndicatorFrame;
  
  [UIView commitAnimations];
  
  _bwImageSelected = YES;
}

- (void)finish {
  
  UIImage *selectedImage = nil;
  if (_bwImageSelected) {
    selectedImage = _handledImage;
  } else {
    selectedImage = self.originalImage;
  }
  [_delegate selectPhoto:selectedImage];
  
  [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)initToolbar {
  
  CGFloat y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT;
  
  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, y, [CommonUtils screenWidth], 44)];
  toolbar.barStyle = UIBarStyleBlack;
  
  UIButton *originalImageBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, IND_ORI_WIDTH, 30)] autorelease];
  [originalImageBtn addTarget:self 
                       action:@selector(selectOriginalImage) 
             forControlEvents:UIControlEventTouchUpInside];
  [originalImageBtn setTitle:LocaleStringForKey(NSOriginalImageTitle, nil) 
                    forState:UIControlStateNormal];
  [originalImageBtn setShowsTouchWhenHighlighted:YES];
  
  UIBarButtonItem *originalImageBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:originalImageBtn] autorelease];
  originalImageBarBtn.style = UIBarButtonItemStyleBordered;
  
  
  UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                         target:nil
                                                                         action:nil];
  
  UIButton *bWImageBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, IND_BW_WIDTH, 30)] autorelease];
  [bWImageBtn addTarget:self 
                 action:@selector(selectBWImage) 
       forControlEvents:UIControlEventTouchUpInside];
  [bWImageBtn setTitle:LocaleStringForKey(NSBWImageTitle, nil) 
              forState:UIControlStateNormal];
  [bWImageBtn setShowsTouchWhenHighlighted:YES];
  
  UIBarButtonItem *bWImageBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:bWImageBtn] autorelease];
  bWImageBarBtn.style = UIBarButtonItemStyleBordered;
  
  NSArray *items = [[NSArray alloc] initWithObjects:originalImageBarBtn, space, bWImageBarBtn, nil];
  [toolbar setItems:items];
  RELEASE_OBJ(space);
  RELEASE_OBJ(items);
  
  [self.view addSubview:toolbar];
    
  RELEASE_OBJ(toolbar);
}

- (void)initSelectionIndicator {
  
  _originalImageIndicatorFrame = CGRectMake(IND_ORIGINAL_X, IND_Y, IND_ORI_WIDTH, IND_HEIGHT);
  _bWImageIndicatorFrame = CGRectMake(IND_BW_X, IND_Y, IND_BW_WIDTH, IND_HEIGHT);
  
  _selectionIndicator = [[UIView alloc] initWithFrame:_originalImageIndicatorFrame];
  _selectionIndicator.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:_selectionIndicator];
}

- (void)initDoneBtn {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSDoneTitle, nil)
                            target:self
                            action:@selector(finish)];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor blackColor];
  
  _imageView = [[UIImageView alloc] init];
  [self.view addSubview:_imageView];
  
  [self initToolbar];
  
  [self initSelectionIndicator];
  
  [self initDoneBtn];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)sourceType {
  self = [super init];
  if (self) {
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = sourceType;
    _imagePicker.delegate = self;
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  
  RELEASE_OBJ(_imagePicker)
	
  self.originalImage = nil;
  
  RELEASE_OBJ(_imageView);
  
  RELEASE_OBJ(_selectionIndicator);
  
	[super dealloc];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
  
  self.originalImage = [CommonUtils scaleAndRotateImage:image sourceType:picker.sourceType];
  
  _imageView.image = self.originalImage;
  
  [self arrangeImageView];
  
  [self dismissModalViewControllerAnimated:YES];
  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark arrange the view location

- (BOOL)imageIsBigWithSameOrientation:(NSInteger)orientation width:(float)width height:(float)height {
	
	switch (orientation) {
		case LANDSCAPE_ORI:
			return (width > WIDTH || height > HEIGHT);
			
		case PORTRAIT_ORI:
			return (width > WIDTH || height > HEIGHT);
			
		default:
			return NO;
	}
}

- (BOOL)imageIsBigWithDifferentOrientation:(float)width height:(float)height {
	if (DEVICE_IS_LANDSCAPE) {
		// means image is portrait
		if (height > HEIGHT) {
			return YES;
		} else {
			return NO;
		}
	} else {
		// means image is landscape
		if (width > WIDTH) {
			return YES;
		} else {
			return NO;
		}
	}
}

- (BOOL)imageIsBigWithSameOrientationForZoom:(NSInteger)orientation width:(float)width height:(float)height {
	
	switch (orientation) {
		case LANDSCAPE_ORI:
			
			return (width > WIDTH && height > HEIGHT);
			
		case PORTRAIT_ORI:
			
			return (width > WIDTH && height > HEIGHT);
			
		default:
			return NO;
	}
}

- (BOOL)imageIsBigWithDifferentOrientationForZoom:(float)width height:(float)height {
	if (DEVICE_IS_LANDSCAPE) {
		// means image is portrait
		if (height > HEIGHT && width > WIDTH) {
			return YES;
		} else {
			return NO;
		}
	} else {
		// means image is landscape
		if (width > WIDTH && height > HEIGHT) {
			return YES;
		} else {
			return NO;
		}
	}
}

- (BOOL)imageOrientationIsLandscape {
	return self.originalImage.size.width > self.originalImage.size.height;
}

- (NSInteger)currentSameOrientation {
  
	if (DEVICE_IS_LANDSCAPE && IMAGE_IS_LANDSCAPE) {
		return LANDSCAPE_ORI;
	}  
	
	if (!DEVICE_IS_LANDSCAPE && !IMAGE_IS_LANDSCAPE) {
		return PORTRAIT_ORI;
	} 
	
	return DIFF_ORI;
}

- (void)arrangeImageView {
	
	float width = 0;
	float height = 0;
	float x = 0;
	float y = VERTICAL_Y;
	
	NSInteger currentSameOrientation = [self currentSameOrientation];
	
	BOOL isBigImage = NO;
	if (currentSameOrientation == DIFF_ORI) {
		isBigImage = [self imageIsBigWithDifferentOrientation:self.originalImage.size.width height:self.originalImage.size.height]; 
	} else {
		isBigImage = [self imageIsBigWithSameOrientation:currentSameOrientation width:self.originalImage.size.width height:self.originalImage.size.height];
	}
  
	switch (currentSameOrientation) {
		case LANDSCAPE_ORI:
		{
			// both device and image are landscape orientation
			if (isBigImage) {
				if (self.originalImage.size.width/self.originalImage.size.height > LANDSCAPE_W_H_RATIO) {
					// means the width is the base, height should be calculated according to the ratio 
					width = WIDTH;
					height = (self.originalImage.size.height/self.originalImage.size.width)*width;
					x = 0;
					y = (HEIGHT - height) / 2;
				} else if (self.originalImage.size.width/self.originalImage.size.height < LANDSCAPE_W_H_RATIO) {
					// means the height is the base, width should be calculated according to the ratio
					height = HEIGHT;
					width = (self.originalImage.size.width/self.originalImage.size.height)*height;
					y = 0;
					x = (WIDTH - width)/2;
				} else {
					// image width/height is same as current device width/height, then the displayed width and height
					// could be the same as the width and height of device
					x = 0;
					y = VERTICAL_Y;
					width = WIDTH;
					height = HEIGHT;
				}
				
			} else {
				// image size is smaller than the screen size, so the actual displayed x and y could be 
				// calculated according to the actual width and height of image and screen size
				height = self.originalImage.size.height;
				width = self.originalImage.size.width;
				x = (WIDTH - width)/2;
				y = (HEIGHT - height)/2;
			}
      
			break;
		}
			
		case PORTRAIT_ORI:
		{
			// both device and image are portrait
			if (isBigImage) {
				if (self.originalImage.size.width/self.originalImage.size.height > PORTRAIT_W_H_RATIO) {
					width = WIDTH;
					height = (self.originalImage.size.height/self.originalImage.size.width)*width;
					x = 0;
					y = (HEIGHT - height)/2;
				} else if (self.originalImage.size.width/self.originalImage.size.height < PORTRAIT_W_H_RATIO) {
					height = HEIGHT;
					width = (self.originalImage.size.width/self.originalImage.size.height)*height;
					y = 0;
					x = (WIDTH - width)/2;
				} else {
					x = 0;
					y = VERTICAL_Y;
					width = WIDTH;
					height = HEIGHT;					
				}
				
			} else {
				height = self.originalImage.size.height;
				width = self.originalImage.size.width;
				x = (WIDTH - width)/2;
				y = (HEIGHT - height)/2;
			}
      
			break;
		}
      
		case DIFF_ORI:
		{
			if (isBigImage) {
				if (DEVICE_IS_LANDSCAPE) {
					// image is portrait
					height = HEIGHT;
					width = (self.originalImage.size.width/self.originalImage.size.height)*height;
					x = (WIDTH - width)/2;
					y = VERTICAL_Y;
				} else {
					// image is landscape
					width = WIDTH;
					height = (self.originalImage.size.height/self.originalImage.size.width)*width;
					x = 0;
					y = (HEIGHT - height)/2;
				}
        
			} else {
				height = self.originalImage.size.height;
				width = self.originalImage.size.width;
				if (DEVICE_IS_LANDSCAPE) {
					x = (WIDTH - width)/2;
					y = (HEIGHT - height)/2;
				} else {
					x = (WIDTH - width)/2;
					y = (HEIGHT - height)/2;
				}
			}
			break;
		}
      
		default:
			break;
	}
  
	_imageView.frame = CGRectMake(x, y, width, height);
	
}

@end
