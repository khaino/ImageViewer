//
//  IVGridLayout.m
//  ImageViewer
//
//  Created by Khaino on 5/26/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import "IVGridLayout.h"

@interface IVGridLayout()



@property(strong, nonatomic)NSMutableArray *cache;
@property(nonatomic)NSInteger numberOfColumns;
@property(nonatomic)CGFloat cellPadding;
@property(nonatomic)CGFloat contentHeight;
@property(nonatomic)CGFloat contentWidth;

@end

@implementation IVGridLayout

// ContentWidth setter
- (CGFloat)contentWidth {
    
    UIEdgeInsets inset = self.collectionView.contentInset;
    return CGRectGetWidth(self.collectionView.bounds) - (inset.left + inset.right);
}

// Override Layout method
-(void)prepareLayout {
    self.cellPadding = 6.0;
    self.numberOfColumns = 3;
    self.contentWidth = 0;
    
    if (self.cache == nil) {
        self.cache = [NSMutableArray array];
        
        CGFloat columnWidth = self.contentWidth / self.numberOfColumns;
        NSMutableArray *xOffset = [NSMutableArray array];
        
        for (int column = 0; column < self.numberOfColumns; column++) {

            [xOffset addObject: [NSNumber numberWithFloat:(column * columnWidth)]];
        }
        
        int column = 0;
        NSMutableArray *yOffset = [NSMutableArray array];
        for (int column = 0; column < self.numberOfColumns; column++) {
            
            [yOffset addObject: [NSNumber numberWithFloat:0.0]];
        }
        
        
        
        for (int item = 0 ; item < [self.collectionView numberOfItemsInSection:0]; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            
            CGFloat width = columnWidth - self.cellPadding * 2;
            CGFloat photoHeight = [self.delegate collectionView:self.collectionView heightForPhotoAtIndexPath:indexPath withWidth:width];
            CGFloat annotationHeight = [self.delegate collectionView:self.collectionView heightForAnnotationAtIndexPath:indexPath withWidth:width];
            CGFloat height = self.cellPadding + photoHeight + annotationHeight + self.cellPadding;
            CGRect frame = CGRectMake([[xOffset objectAtIndex:column] floatValue], [[yOffset objectAtIndex:column] floatValue], width, height);
            CGRectInset(frame, self.cellPadding, self.cellPadding);
            
            UICollectionViewLayoutAttributes  *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectInset(frame, self.cellPadding, self.cellPadding);
            
            [self.cache addObject:attributes];
          
//            self.contentHeight = MAX(self.contentHeight, CGRectGetHeight(frame));
            CGFloat tempHeight = [[yOffset objectAtIndex:column] floatValue] + height;
            yOffset[column] = [NSNumber numberWithFloat:tempHeight];

            if (column == (self.numberOfColumns -1)) {
                column = 0;
                self.contentHeight += frame.size.height;
            } else {
                column += 1;
            }
        }
        
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentWidth, self.contentHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in self.cache) {
        [layoutAttributes addObject:attributes];
    }
    return layoutAttributes;
}

@end
