//
//  RCQueueUtils.h
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCQueueUtils : NSObject

+(NSOperationQueue *)globalPreloadQueue;
+(NSOperationQueue *)globalPlayQueue;
+(NSOperationQueue *)globalDownloadQueue;

@end

NS_ASSUME_NONNULL_END
