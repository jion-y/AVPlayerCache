//
//  RCSegmentDownloader.h
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import <Foundation/Foundation.h>

@class RCSegmentDownloader;

NS_ASSUME_NONNULL_BEGIN

@protocol RCSegmentDownloaderDelegate <NSObject>

@optional
- (void)segmentDownloader:(RCSegmentDownloader *)downloader didReceiveResponse:(NSURLResponse *)response;
- (void)segmentDownloader:(RCSegmentDownloader *)downloader didReceiveData:(NSData *)data;
- (void)segmentDownloader:(RCSegmentDownloader *)downloader didFinishedWithError:(NSError *)error;

@end

@interface RCSegmentDownloader : NSObject

@property(nonatomic,assign)uint64_t fileTotalSize;
@property(nonatomic,assign)uint64_t downloadSize;
@property(nonatomic,weak)id<RCSegmentDownloaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd;

- (void)cancel;
@end

NS_ASSUME_NONNULL_END
