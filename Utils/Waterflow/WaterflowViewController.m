//
//  WaterflowViewController.m
//  WaterflowView
//
//  Created by Bruno Virlet on 7/20/12.
//
//  Copyright (c) 2012 1000memories

//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO 
//  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WaterflowViewController.h"

#import "WaterflowView.h"
#import "WaterflowViewCell.h"

@interface WaterflowViewController () <WaterflowViewDataSource, WaterflowViewDelegate>

@end

@implementation WaterflowViewController

@synthesize quiltView = _quiltView;

- (void)dealloc {
    [_quiltView release], _quiltView = nil;
    
    [super dealloc];
}

- (void)loadView {
    _quiltView = [[WaterflowView alloc] initWithFrame:CGRectZero];
    _quiltView.delegate = self;
    _quiltView.dataSource = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = _quiltView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.quiltView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.quiltView = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.quiltView reloadData];
}

#pragma mark - WaterflowViewDataSource

- (NSInteger)quiltViewNumberOfCells:(WaterflowView *)quiltView {
    return 0;
}

- (WaterflowViewCell *)quiltView:(WaterflowView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath {
    WaterflowViewCell *cell = [self.quiltView dequeueReusableCellWithReuseIdentifier:nil];
    if (!cell) {
        cell = [[[WaterflowViewCell alloc] initWithReuseIdentifier:nil] autorelease];
    }
    return cell;
}

@end
