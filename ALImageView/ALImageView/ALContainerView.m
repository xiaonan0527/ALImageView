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

- (void)setRemotePaths:(NSArray *)remotePaths
{
    if (remotePaths == _remotePaths) {
        return;
    }
    
    if (nil != _remotePaths) {
        int i = 0;
        for (NSString *r in _remotePaths) {
            ALImageView *view = [_imageViews objectAtIndex:i];
            view.remotePath = nil;
            i++;
        }
        [_remotePaths release];
        _remotePaths = nil;
    }
    
    if (nil != remotePaths) {
        _remotePaths = [remotePaths retain];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != _remotePaths) {
                int i = 0;
                for (NSString *r in _remotePaths) {
                    if (0 < [r length]) {
                        ALImageView *view = [_imageViews objectAtIndex:i];
                        view.remotePath = r;
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
    self.remotePaths = nil;
    if (nil != _imageViews) {
        [_imageViews release];
        _imageViews = nil;
    }
    if (nil != _selectIndexBlock) {
        [_selectIndexBlock release];
        _selectIndexBlock = nil;
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
        int columns = AL_CONTAINER_VIEW_COLUMN_COUNT;
        int rows = AL_CONTAINER_VIEW_ROW_COUNT;
        CGFloat xLR = AL_CONTAINER_VIEW_MARGIN_LR;
        CGFloat yU = AL_CONTAINER_VIEW_MARGIN_UP;
        CGFloat yD = AL_CONTAINER_VIEW_MARGIN_DOWN;
        CGFloat xGap = AL_CONTAINER_VIEW_GAP_X;
        CGFloat yGap = AL_CONTAINER_VIEW_GAP_Y;
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
                    alImageView.placeholderImage = [UIImage imageNamed:@"img_pld"];
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
    if (_selectIndexBlock == block) {
        return;
    }
    
    if (nil != _selectIndexBlock) {
        [_selectIndexBlock release];
        _selectIndexBlock = nil;
    }
    
    if (nil != block) {
        _selectIndexBlock = [block copy];
    }
}

- (void)didPressImageViewAction:(id)sender
{
    ALImageView *alImageView = (ALImageView *)sender;
    NSLog(@"didPressImageViewAction:%d", alImageView.index);
    if ([_delegate respondsToSelector:@selector(containerView:didSelectIndex:)]) {
        [_delegate containerView:self didSelectIndex:alImageView.index];
    }
    if (_selectIndexBlock) {
		_selectIndexBlock(self, alImageView.index);
	}
}


@end
