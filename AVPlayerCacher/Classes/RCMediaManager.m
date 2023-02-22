//
//  RCCacheManager.m
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/21.
//

#import "NSString+RCMD5.h"
#import "RCMediaManager.h"
#import "RCQueueUtils.h"
@interface RCAsset ()
- (instancetype)initWithUrl:(NSString *)url
                   delegate:(id<RCAssetDelegate>)delegate;
@end
static RCMediaManager *share_obj = nil;

@interface RCMediaManager ()<RCAssetDelegate>
@property (nonatomic, strong) dispatch_queue_t sourceLoaderQueue;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RCAsset *> *assetMap;


@property (nonatomic, strong) NSMutableArray<RCAsset *> *taskQueue;
@property (nonatomic, strong) NSLock *umlock;


@end
@implementation RCMediaManager

#pragma mark -

- (NSMutableArray<RCAsset *> *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = [[NSMutableArray alloc] init];
    }

    return _taskQueue;
}

- (dispatch_queue_t)sourceLoaderQueue {
    if (_sourceLoaderQueue == nil) {
        _sourceLoaderQueue = dispatch_queue_create("com.rc.sourceloader", DISPATCH_QUEUE_CONCURRENT);
    }

    return _sourceLoaderQueue;
}

- (NSMutableDictionary<NSString *, RCAsset *> *)assetMap {
    if (!_assetMap) {
        _assetMap = [[NSMutableDictionary alloc] init];
    }

    return _assetMap;
}
- (void)setMaxPlayTaskNum:(NSInteger)maxPlayTaskNum {
    _maxPlayTaskNum = maxPlayTaskNum;
    [RCQueueUtils globalPlayQueue].maxConcurrentOperationCount = _maxPlayTaskNum;
}
- (void)setMaxPreLoadingTaskNum:(NSInteger)maxPreLoadingTaskNum {
    _maxPreLoadingTaskNum = maxPreLoadingTaskNum;
    [RCQueueUtils globalPreloadQueue].maxConcurrentOperationCount = _maxPreLoadingTaskNum;
}
#pragma mark -

+ (instancetype)manager {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        share_obj = [[RCMediaManager alloc] init];
    });
    return share_obj;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.umlock = [[NSLock alloc] init];
        self.maxPlayTaskNum = 1;
        self.maxPreLoadingTaskNum = 5;
        
    }
    return self;
}

- (RCAsset *)createAsset:(NSString *)url {
    RCAsset *asset = [self assetForUrl:url];

    if (!asset) {
        asset = [[RCAsset alloc] initWithUrl:url
                                    delegate:self];
        [self setAsset:asset forUrl:url];
    }

    return asset;
}

- (void)cancelAsset:(NSString *)url {
    RCAsset *asset = [self assetForUrl:url];

    if (asset) {
        [asset cancelAll];
    }
}

- (RCAsset *)assetForUrl:(NSString *)url {
    [self lock];
    RCAsset *asset = [self.assetMap objectForKey:[url rc_md5]];
    [self unlock];
    return asset;
}

- (void)setAsset:(RCAsset *)asset forUrl:(NSString *)url {
    if (asset == nil || url.length <= 0) {
        return;
    }

    [self lock];
    [self.assetMap setObject:asset forKey:[url rc_md5]];
    [self unlock];
}

- (void)lock {
    [self.umlock lock];
}

- (void)unlock {
    [self.umlock unlock];
}

#pragma mark-
- (BOOL)assetCanPreLoading:(RCAsset *)asset {
    [self lock];
    [self.taskQueue addObject:asset];
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (RCAsset *asset in self.taskQueue) {
        if (asset.status == PreLoading) {
            [tmp addObject:asset];
        }
    }
    NSInteger delCount = tmp.count - self.maxPreLoadingTaskNum;
    [self deleteAsset:delCount willDeleteArray:tmp];
    [self unlock];
    return YES;
}
- (BOOL)assetCanPlayerLoading:(RCAsset *)asset {
    [self lock];
    [self.taskQueue addObject:asset];
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for (RCAsset *asset in self.taskQueue) {
        if (asset.status == play) {
            [tmp addObject:asset];
        }
    }
    NSInteger delCount = tmp.count - self.maxPlayTaskNum;
    [self deleteAsset:delCount willDeleteArray:tmp];
    [self unlock];
    return YES;
}

- (void)deleteAsset:(NSInteger)count willDeleteArray:(NSMutableArray *) delArray {
    
    while (count > 0) {
        RCAsset * asset = delArray.firstObject;
        if(asset) {
            [self.taskQueue removeObject:asset];
            [delArray removeObject:asset];
        }
        count --;
    }
    
}
@end
