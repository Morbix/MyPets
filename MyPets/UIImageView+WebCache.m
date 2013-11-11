/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
//#import "TMPhotoQuiltViewCell.h"

@implementation UIImageView (WebCache)

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)setImageWithURL:(NSURL *)url
{    
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}


- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if ((self.contentMode == UIViewContentModeBottom)||(self.contentMode == UIViewContentModeTop)) {
        if (image.size.width > self.frame.size.width) {
            float relacao = self.frame.size.width / image.size.width;
            
            self.image = [self imageWithImage:image scaledToSize:CGSizeMake(image.size.width*relacao, image.size.height*relacao)];
        }else{
            self.image = image;
        }
    }else{
        self.image = image;
    }
    
    
    /*if (self.tag >= 1000) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTPSNotificationResizeFoto object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.image.size.height],@"size", [NSNumber numberWithInt:self.tag-1000], @"index", nil]];
    }*/
}

@end
