//
//  OriginalImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-5.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "OriginalImageViewController.h"

@interface OriginalImageViewController ()

@end

@implementation OriginalImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (nil != self.localPath && [[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
        self.imageView.localPath = self.localPath;
    } else {
        self.imageView.cacheDirectory = ALImageViewCacheDirectoryForDemo;
        self.imageView.localPath = self.thumbnailPath;
        self.imageView.remotePath = self.remotePath;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
