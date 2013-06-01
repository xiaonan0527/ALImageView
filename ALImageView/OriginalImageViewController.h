//
//  OriginalImageViewController.h
//  ALImageView
//
//  Created by SpringOx on 12-12-5.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
//

#import <UIKit/UIKit.h>
#import "ALImageView.h"

@interface OriginalImageViewController : UIViewController

@property (nonatomic, retain) IBOutlet ALImageView *imageView;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSString *url;

@end
