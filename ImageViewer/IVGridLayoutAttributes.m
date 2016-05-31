//
//  IVGridLayoutAttributes.m
//  ImageViewer
//
//  Created by Khaino on 5/30/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVGridLayoutAttributes.h"

@interface IVGridLayoutAttributes()
@property(nonatomic)CGFloat photoHeight;

@end

@implementation IVGridLayoutAttributes

-(id)copyWithZone:(NSZone *)zone {
    IVGridLayoutAttributes *copy = (IVGridLayoutAttributes*)[super copyWithZone:zone];
    copy.photoHeight = self.photoHeight;
    return copy;
}

-(BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[IVGridLayoutAttributes class]]) {
        IVGridLayoutAttributes *obj = (IVGridLayoutAttributes*)object;
        if (obj.photoHeight == self.photoHeight) {
            return true;
        }
    }
    return false;
}

@end
