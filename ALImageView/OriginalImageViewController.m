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
    
    [self.imageView loadImage:@"http://cn.tradekey.com/index.html?action=product_viewimages&uid=2096923&id=796568" placeholderImage:[UIImage imageNamed:@"img_pld"]];
    
    [self.imageView loadImage:@"http://jpp2.imghb.com/pic/pic/90/22/96/1396480590229611_a602x602.jpg" placeholderImage:[UIImage imageNamed:@"img_pld"]];
    
    [self.imageView loadImage:@"http://thumb1.yokacdn.com/p_660_660_3_10_/sp1//27/47/732245/photo_570387.jpg.jpg?t=001" placeholderImage:[UIImage imageNamed:@"img_pld"]];
    
//    [self.imageView loadImage:@"http://pic3.zhongsou.com/image/380bc16a6845e04371c.jpg" placeholderImage:[UIImage imageNamed:@"img_pld"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
