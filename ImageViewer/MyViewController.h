//
//  MyViewController.h
//  NewPageControl
//
//  Created by Khaino on 5/25/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSArray *contentList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
