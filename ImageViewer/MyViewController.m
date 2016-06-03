//
//  MyViewController.m
//  NewPageControl
//
//  Created by Khaino on 5/25/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "MyViewController.h"

@interface MyViewController ()

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Image download activity indicator
    self.activityIndicator.hidesWhenStopped = YES;
    self.pageScrollView.delegate = self;
    [self.activityIndicator startAnimating];
    
    // Do any additional setup after loading the view from its nib.
    
    // Add double touch gesture to pageScrollView
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.pageScrollView addGestureRecognizer:doubleTap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Set imageView as object to zoom
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

// When slide to another image, image zoom is reset.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView setZoomScale:0.1f animated:YES];
}

// Double tap handler
- (void)handleDoubleTap:(CGPoint)touchPoint {

    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:self.imageView];
    
    // If image is zoomed,
    if (self.pageScrollView.zoomScale == self.pageScrollView.maximumZoomScale) {
        
        // image is back to normal
        [self.pageScrollView setZoomScale:self.pageScrollView.minimumZoomScale animated:YES];
    } else {
        
        // If image is not zoomed, zooming happens
        [self.pageScrollView setZoomScale:self.pageScrollView.maximumZoomScale animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
