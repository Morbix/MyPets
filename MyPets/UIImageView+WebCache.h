/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

//Import para implementações
//#import "UIImageView+WebCache.h"

#define MTPSNotificationResizeFoto @"br.com.moolab.mobtour.notification.resizefoto"

#import "SDWebImageCompat.h"
#import "SDWebImageManagerDelegate.h"

@interface UIImageView (WebCache) <SDWebImageManagerDelegate>


- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)cancelCurrentImageLoad;

@end
