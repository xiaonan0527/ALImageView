//
//  ALContainerView.m
//  ALImageView
//
//  Created by SpringOx on 12-12-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ALContainerView.h"
#import "ALImageView.h"


@interface ALContainerView ()
{
    NSMutableArray *_imageViews;
    CSelectIndexBlock _selectIndexBlock;
}

@end

@implementation ALContainerView

- (void)setLocalPaths:(NSArray *)localPaths
{
    if (nil != _localPaths) {
        [_localPaths release];
        _localPaths = nil;
    }
    
    if (nil != localPaths) {
        _localPaths = [localPaths retain];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != _localPaths) {
                int i = 0;
                for (NSString *l in _localPaths) {
                    if (0 < [l length]) {
                        ALImageView *view = [_imageViews objectAtIndex:i];
                        view.localPath = l;
                    }
                    i++;
                }
            }
        });
        
    }
}

- (void)setRemotePaths:(NSArray *)remotePaths
{
    if (nil != _remotePaths) {
        [_remotePaths release];
        _remotePaths = nil;
    }
    
    if (nil != remotePaths) {
        _remotePaths = [remotePaths retain];
        
        if (nil == _imageCacheDirectory) {
            _imageCacheDirectory = ALImageViewCacheDirectoryForDemo;
            [_imageCacheDirectory retain];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != _remotePaths) {
                int i = 0;
                for (NSString *r in _remotePaths) {
                    if (0 < [r length]) {
                        ALImageView *view = [_imageViews objectAtIndex:i];
                        view.remotePath = r;
                        view.cacheDirectory = _imageCacheDirectory;
                    }
                    i++;
                }
            }
        });
        
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _fromIndex = -UINT_MAX;
    }
    return self;
}

- (void)dealloc
{
    self.localPaths = nil;
    self.remotePaths = nil;
    if (nil != _imageViews) {
        [_imageViews release];
        _imageViews = nil;
    }
    if (nil != _selectIndexBlock) {
        [_selectIndexBlock release];
        _selectIndexBlock = nil;
    }
    if (nil != _imageCacheDirectory) {
        [_imageCacheDirectory release];
        _imageCacheDirectory = nil;
    }
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setImageCount:(NSUInteger)count fromIndex:(NSInteger)index
{
    self.imageCount = count;
    self.fromIndex = index;
    
    if (_imageCount > 0) {
        int columns = ALContainerViewColumnCount;
        int rows = ALContainerViewRowCount;
        CGFloat xLR = 18.f;
        CGFloat yU = 20.f;
        CGFloat yD = 32.f;
        CGFloat xGap = 10.f;
        CGFloat yGap = 6.f;
        CGFloat width = (self.bounds.size.width-2*xLR-(columns-1)*xGap)/columns;
        CGFloat height = (self.bounds.size.height-yU-yD-(rows-1)*yGap)/rows;
        NSLog(@"width:%f height:%f", width, height);
        if (nil == _imageViews) {
            _imageViews = [[NSMutableArray alloc] init];
        }
        int tempCount = [_imageViews count];
        for (int j=0; j<rows; j++) {
            if (_imageCount <= columns*j) {  //排版到最后一个就跳出循环
                break;
            }
            for (int i=0; i<columns; i++) {
                NSLog(@"_imageCount:%d i+columns*j:%d", _imageCount, i+columns*j);
                if (_imageCount <= i+columns*j) {  //排版到最后一个就跳出循环
                    break;
                }
                ALImageView *alImageView = nil;
                if (tempCount > i+columns*j) {
                    alImageView = [[_imageViews objectAtIndex:i+columns*j] retain];
                } else {
                    alImageView = [[ALImageView alloc] initWithFrame:CGRectMake(xLR+(xGap+width)*i, yU+(yGap+height)*j, width, height)];
                    alImageView.bgImage = [UIImage imageNamed:@"img_bg"];
                    alImageView.index = i+j*columns;
                    [alImageView addTarget:self action:@selector(didPressImageViewAction:)];
                    [_imageViews addObject:alImageView];
                    [self addSubview:alImageView];
                }
                [alImageView release];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i=0; i<[_imageViews count]; i++) {
                ALImageView *alImageView = [_imageViews objectAtIndex:i];
                if (_imageCount > i) {
                    alImageView.hidden = NO;
                } else {
                    alImageView.hidden = YES;
                }
            }
        });
    }
}

- (void)setSelectIndexBlock:(CSelectIndexBlock)block
{
    [_selectIndexBlock release];
    _selectIndexBlock = [block copy];
}

- (void)didPressImageViewAction:(id)sender
{
    ALImageView *alImageView = (ALImageView *)sender;
    NSLog(@"didPressImageViewAction:%d", alImageView.index);
    if ([_delegate respondsToSelector:@selector(imageContentView:didSelectIndex:)]) {
        [_delegate containerView:self didSelectIndex:alImageView.index];
    }
    if (_selectIndexBlock) {
		_selectIndexBlock(self, alImageView.index);
	}
}


@end
