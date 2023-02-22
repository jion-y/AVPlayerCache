//
//  RCSegmentDownloader.m
//  AVPlayerCacher
//
//  Created by yoyo on 2023/2/22.
//

#import "RCSegmentDownloader.h"
#import "RCQueueUtils.h"


@interface RCSegmentDownloader()<NSURLSessionDelegate>
@property(nonatomic,strong)NSURL * url;
@property(nonatomic,strong)NSURLSession * session;
@property(nonatomic,strong)NSURLSessionDataTask * task;
@property (nonatomic) NSInteger startOffset;
@end

@implementation RCSegmentDownloader

#pragma mark -

- (NSURLSession *)session {
    if(_session == nil) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[RCQueueUtils globalDownloadQueue]];
    }
    return _session;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)downloadTaskFromOffset:(unsigned long long)fromOffset
                        length:(NSUInteger)length
                         toEnd:(BOOL)toEnd {
    
    long long endOffset = fromOffset + length - 1;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-%lld", fromOffset, endOffset];
    if(toEnd) {
        range = [NSString stringWithFormat:@"bytes=%lld-", fromOffset];
    }
    [request setValue:range forHTTPHeaderField:@"Range"];
    self.startOffset = fromOffset;
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
    
}

- (void)cancel {
    if(self.task) {
        [self.task cancel];
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSString *mimeType = response.MIMEType;
    // Only download video/audio data
    if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
        [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
        [mimeType rangeOfString:@"application"].location == NSNotFound) {
        completionHandler(NSURLSessionResponseCancel);
    } else {
        
//        [response.allHeaderFields[@"Content-Length"] integerValue];
        self.fileTotalSize = response.expectedContentLength;
        NSLog(@"file total size = %llu",self.fileTotalSize);
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    self.downloadSize+= data.length;
    [self.delegate segmentDownloader:self didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    [self.delegate segmentDownloader:self didFinishedWithError:error];
}
@end
