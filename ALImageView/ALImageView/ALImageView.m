//
//  ALImageView.m
//  ALImageView
//
//  Created by SpringOx on 12-8-2.
//  Copyright (c) 2012年 SpringOx. All rights reserved.
//

#import "ALImageView.h"

#define REQUEST_RETRY_COUNT   2

@interface ALImageCache : NSCache

+ (ALImageCache *)sharedInstance;

- (UIImage *)cachedImageForImageURL:(NSString *)url;

- (void)cacheImage:(UIImage *)image forImageURL:(NSString *)url;

@end

@implementation ALImageCache

+ (ALImageCache *)sharedInstance {
    static ALImageCache *_imageCache = nil;
    static dispatch_once_t _oncePredicate;
    dispatch_once(&_oncePredicate, ^{
        _imageCache = [[ALImageCache alloc] init];
    });
    return _imageCache;
}

- (UIImage *)cachedImageForImageURL:(NSString *)url
{
	return [self objectForKey:url];
}

- (void)cacheImage:(UIImage *)image forImageURL:(NSString *)url
{
    if (image && url) {
        [self setObject:image forKey:url];
    }
}

@end


@interface ALImageView ()
{
    UIImage *_placeholderImage;
    UIActivityIndicatorView *_activityView;
    id _target;
    SEL _action;
    NSInteger _requestCount;   // Add the count to reload a picture when the object is complex,
                               // the old block, in effect, equivalent cancel
}

- (UIImage *)insertBgImage:(UIImage *)bgImage toImage:(UIImage *)image;

@end

@implementation ALImageView

- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (_placeholderImage == placeholderImage) {
        return;
    }
    
    if (nil != _placeholderImage) {
        [_placeholderImage release];
        _placeholderImage = nil;
    }
    
    if (nil != placeholderImage) {
        _placeholderImage = [placeholderImage retain];
    }
    
    self.image = _placeholderImage;
}

- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL == imageURL) {
        return;
    }
    
    if (nil != _imageURL) {
        if (nil != _placeholderImage) {
            self.image = _placeholderImage;
        } else {
            self.image = nil;
            self.backgroundColor = [UIColor whiteColor];
        }
        [_imageURL release];
        _imageURL = nil;
    }
    
    if (nil != imageURL) {
        _imageURL = [imageURL retain];
    }
    
    if (0 < [_imageURL length]) {
        UIImage *img = [[ALImageCache sharedInstance] cachedImageForImageURL:_imageURL];
        if (nil != img) {
            [self setImageWithPlaceholder:img];
            NSLog(@"load memory cache image!");
            return;
        }
        if (_localCacheEnabled) {
            NSString *imgCachePath = [[ALImageView localCacheDirectory] stringByAppendingPathComponent:[_imageURL lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:imgCachePath]) {
                UIImage *img = [UIImage imageWithContentsOfFile:imgCachePath];
                [self setImageWithPlaceholder:img];
                [[ALImageCache sharedInstance] cacheImage:img forImageURL:_imageURL];
                NSLog(@"load local cache image!");
                return;
            }
        }
        [self asyncLoadImageWithURL:[NSURL URLWithString:[_imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSLog(@"load remote image!");
    }
}

- (void)setIndicatorEnabled:(BOOL)indicatorEnabled
{
    _indicatorEnabled = indicatorEnabled;
    if (!_indicatorEnabled) {
        if (nil != _activityView) {
            [_activityView stopAnimating];
            [_activityView release];
            _activityView = nil;
        }
    }
}

- (void)setIsCorner:(BOOL)isCorner
{
    _isCorner = isCorner;
    if (_isCorner) {
        self.layer.cornerRadius = 10.0f;
        self.clipsToBounds = YES;
    } else {
        self.layer.cornerRadius = 0.0f;
        self.clipsToBounds = NO;
    }
}

+ (NSString *)localCacheDirectory
{    
    static NSString *_localCacheDirectory = nil;
    static dispatch_once_t _oncePredicate;
    dispatch_once(&_oncePredicate, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        if (0 < [cachesPath length]) {
            _localCacheDirectory = [[cachesPath stringByAppendingPathComponent:AL_IMAGE_VIEW_LOCAL_CAHCE_DIRECTORY] retain];
            
            BOOL isDirectory = YES;
            if (![[NSFileManager defaultManager] fileExistsAtPath:_localCacheDirectory isDirectory:&isDirectory] || !isDirectory) {
                NSError *error = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:_localCacheDirectory withIntermediateDirectories:YES attributes:nil error:&error];
            }
        }
        NSLog(@"localCacheDirectory %@", _localCacheDirectory);
    });
    return _localCacheDirectory;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
//    self.backgroundColor = [UIColor whiteColor];
    
    _index = -UINT_MAX;
    _queuePriority = ALImageQueuePriorityNormal;
    _localCacheEnabled = YES;
    _indicatorEnabled = YES;
}

- (void)dealloc
{
    self.imageURL = nil;
    if (nil != _activityView) {
        [_activityView stopAnimating];
        [_activityView release];
        _activityView = nil;
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

- (UIImage *)insertBgImage:(UIImage *)bgImage toImage:(UIImage *)image
{
    if (_contentEdgeInsets.top || _contentEdgeInsets.left || _contentEdgeInsets.bottom || _contentEdgeInsets.right) {
        CGFloat s = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(s*self.bounds.size.width, s*self.bounds.size.height);
        UIGraphicsBeginImageContext(size);
        [bgImage drawInRect:CGRectMake(0.f, 0.f, s*self.bounds.size.width, s*self.bounds.size.height)];
        [image drawInRect:CGRectMake(s*_contentEdgeInsets.left, s*_contentEdgeInsets.top, s*(self.bounds.size.width-_contentEdgeInsets.left-_contentEdgeInsets.right), s*(self.bounds.size.height-_contentEdgeInsets.top-_contentEdgeInsets.bottom))];
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage;
    } else {
        return image;
    }
}

- (void)setImageWithPlaceholder:(UIImage *)img
{
    if (nil == img) {
        return;
    }
    
    if (nil != _placeholderImage) {
        self.image = [self insertBgImage:_placeholderImage toImage:img];
    } else {
        self.image = img;
    }
}

- (void)setImageWithAnimation:(UIImage *)img
{
    [self setImageWithPlaceholder:img];
    
    self.alpha = 0.1f;
    [UIView animateWithDuration:0.32f
                          delay:0.16f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 1.f;
                     }
                     completion:nil];
}

- (void)loadImage:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage
{
    self.placeholderImage = placeholderImage;
    self.imageURL = imageURL;
}

- (void)asyncLoadImageWithURL:(NSURL *)url
{
    if (_indicatorEnabled && nil == _activityView) {
        if (nil == _placeholderImage) {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        } else {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _activityView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:_activityView];
    }
    [_activityView startAnimating];
    
    _requestCount++;
    dispatch_block_t loadImageBlock = ^(void) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSInteger countStamp = _requestCount;
        int retryCount = -1;
        NSData *data = nil;
        UIImage *img = nil;
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        do {
            if (REQUEST_RETRY_COUNT <= retryCount) {break;}
            else if (0 <= retryCount) {usleep(200);}
            else {/*do nothing */}
            response = nil;
            error = nil;
            data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            retryCount++;
            NSLog(@"asyncLoadImage connection request retry count:%d", retryCount);
        } while (nil != error || 0 == [data length]);
        NSLog(@"asyncLoadImage connection finished:%d error:%@", [data length], error);
        
        if (nil == error && 0 < [data length]) {  // Tested may return the length of the data is empty
            if (_localCacheEnabled) {
                NSString *targetPath = [[ALImageView localCacheDirectory] stringByAppendingPathComponent:[[url absoluteString] lastPathComponent]];
                NSError *error = nil;
                [data writeToFile:targetPath options:NSDataWritingFileProtectionComplete error:&error];
                NSLog(@"asyncLoadImage targetPath:%@ error:%@", targetPath, error);
            }
            img = [UIImage imageWithData:data];
        } else {
            data = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil != img) {
                if (countStamp == _requestCount) {   // Add the count to reload a picture when the object is complex,
                                                     // the old block, in effect, equivalent cancel
                    [self setImageWithAnimation:img];
                    _asyncLoadImageFinished = YES;
                    [_activityView stopAnimating];
                    
                    if ([_delegate respondsToSelector:@selector(imageView:didAsynchronousLoadImage:)]) {
                        [_delegate imageView:self didAsynchronousLoadImage:img];
                    }
                    
                    [[ALImageCache sharedInstance] cacheImage:img forImageURL:[url absoluteString]];
                    NSLog(@"asyncLoadImage finish!");
                }
            } else {
                _asyncLoadImageFinished = NO;
                [_activityView stopAnimating];
                NSLog(@"asyncLoadImage finish without setImage!");
            }
        });
    };
    
    if (ALImageQueuePriorityHigh == _queuePriority) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), loadImageBlock);
    } else if (ALImageQueuePriorityNormal == _queuePriority) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadImageBlock);
    } else {
        static dispatch_queue_t imageQueue = NULL;
        
        if (NULL == imageQueue) {
            imageQueue = dispatch_queue_create("asynchronous_load_image", nil);
        }
        dispatch_async(imageQueue, loadImageBlock);
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGestureRecognizer:)];
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
}

- (void)didTapGestureRecognizer:(id)sender
{
    if (nil == self.image || _activityView.isAnimating) {
        return;
    }
    [_target performSelector:_action withObject:self];
}

@end
