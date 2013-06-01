//
//  OriginalImageViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-5.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//
//  Contact:jiachunke@gmail.com
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

- (void)dealloc
{
    self.imageView = nil;
    self.thumbnailURL = nil;
    self.url = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"Original", @"title");
    
    self.imageView.queuePriority = ALImageQueuePriorityHigh;
    self.imageView.localCacheEnabled = NO;
    self.imageView.indicatorEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.imageView loadImage:self.url placeholderImage:[UIImage imageNamed:@"img_pld"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
