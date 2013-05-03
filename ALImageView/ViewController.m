//
//  ViewController.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ViewController.h"
#import "PreviewImageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressStartButtonAction:(id)sender
{    
    PreviewImageViewController *pVC = [[PreviewImageViewController alloc] initWithNibName:@"PreviewImageViewController" bundle:nil];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:pVC];
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:nv animated:YES completion:nil];
    } else {
        [self presentModalViewController:nv animated:YES];
    }
    [pVC release];
    [nv release];
}

@end
