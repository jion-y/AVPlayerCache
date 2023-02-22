//
//  RCQueueUtils.m
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import "RCQueueUtils.h"



@interface RCQueueUtils()
@property (nonatomic, strong) NSOperationQueue *playerQueue;
@property (nonatomic, strong) NSOperationQueue *preLoadingQueue;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end
@implementation RCQueueUtils

static RCQueueUtils * share_obj = nil;
+(instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      share_obj = [[RCQueueUtils alloc] init];
    });
    return share_obj;
}

- (NSOperationQueue *)playerQueue {
    if (!_playerQueue) {
        _playerQueue = [[NSOperationQueue alloc] init];
        _playerQueue.name = @"com.rc.playQueue";
        _playerQueue.qualityOfService  = NSQualityOfServiceUserInitiated;
    }
    return _playerQueue;
}

- (NSOperationQueue *)preLoadingQueue {
    if (!_preLoadingQueue) {
        _preLoadingQueue = [[NSOperationQueue alloc] init];
        _preLoadingQueue.name = @"com.rc.preloadQueue";
        _playerQueue.qualityOfService  = NSQualityOfServiceBackground;
    }

    return _preLoadingQueue;
}

- (NSOperationQueue *)downloadQueue {
    if(!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
    }
    return _downloadQueue;
}

+(NSOperationQueue *)globalPreloadQueue {
    return  [[self share] preLoadingQueue];
}
+(NSOperationQueue *)globalPlayQueue {
    return [[self share] playerQueue];
}
+(NSOperationQueue *)globalDownloadQueue {
    return [[self share] downloadQueue];
}
@end
