//
//  OriginalImageViewController.h
//  ALImageView
//
//  Created by SpringOx on 12-12-5.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALImageView.h"

@interface OriginalImageViewController : UIViewController<ALImageViewDelegate>

@property (nonatomic, retain) IBOutlet ALImageView *imageView;
@property (nonatomic, retain) NSString *thumbnailPath;
@property (nonatomic, retain) NSString *path;

@end
