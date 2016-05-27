//
//  GridCell.h
//  ImageViewer
//
//  Created by Khaino on 5/19/16.
//  Copyright © 2016 khaino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *collectionName
;

@end
