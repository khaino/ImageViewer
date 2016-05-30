//
//  RoundedConerView.m
//  ImageViewer
//
//  Created by Khaino on 5/30/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "RoundedConerView.h"

@implementation RoundedConerView

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

@end
