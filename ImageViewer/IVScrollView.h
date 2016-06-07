//
//  IVScrollView.h
//  NewPageControl
//
//  Created by Khaino on 5/25/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVScrollView : UIViewController
@property (nonatomic, strong) NSArray *contentList;
@property (nonatomic, assign) int currentImage;
- (IBAction)shareButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@end

