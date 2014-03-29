## ALImageView

A ImageView Class for loading image concurrently in iOS.You only need two source files(ALImageView.h/ALImageView.m).You can reuse a image view to reload different url in a tableview cell.

![Screenshot](https://dl.dropboxusercontent.com/u/59801943/Screenshots/ALImageView.png)

Support local and memory cache;
Support place holder;
Support tap touch(target-action);
Support corner for the image view;
Support multi-image container;


### Basic

``` objective-c
        ALImageView *alImageView = [[[ALImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)] autorelease];
        alImageView.contentEdgeInsets = UIEdgeInsetsMake(3.f, 4.f, 3.f, 4.f);
        alImageView.isCorner = YES;
        [alImageView addTarget:self action:@selector(didPressImageViewAction:)];
        alImageView.placeholderImage = [UIImage imageNamed:@"placeholder"];
        alImageView.imageURL = @"image_url";
        //[alImageView loadImage:@"image_url" placeholderImage:[UIImage imageNamed:@"placeholder"]];
```

There is also a good demo in the project.