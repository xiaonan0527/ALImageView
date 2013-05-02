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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.imageView.remotePath = self.remotePath;
    self.imageView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark ALImageViewDelegate

- (void)imageView:(ALImageView *)imgView didAsynchronousLoadImage:(UIImage *)img
{
    NSLog(@"imageView: %@ didAsynchronousLoadImage: %@", imgView, img);
}

@end
