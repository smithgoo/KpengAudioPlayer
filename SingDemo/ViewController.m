//
//  ViewController.m
//  SingDemo
//
//  Created by 王朋 on 2017/9/30.
//  Copyright © 2017年 王朋. All rights reserved.
//

#import "ViewController.h"
#import "KpengSingShowView.h"
#import <AFNetworking/AFNetworking.h>
#import "KpengAudioPlayer.h"
@interface ViewController ()<KpengAudioPlayerDelegate>
{
    KpengSingShowView *view;
    // 下载任务句柄
    NSURLSessionDownloadTask *_downloadTask;
}
@property (weak, nonatomic) IBOutlet UILabel *hereLab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUIWithDuration:5 text:@"青青河边草"];
    if ([self fileManagerContaine:@"298092036247.m4a"]) {
        _hereLab.text =@"歌曲存在";
    }
}

- (void)setupUIWithDuration:(NSTimeInterval)duration text:(NSString*)text {
    view =[[KpengSingShowView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width,100)];
    view.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.3];
    [view showAnimationWithDuration:10 showText:text alignment:NSTextAlignmentCenter backColor:[UIColor whiteColor] foreColor:[UIColor blackColor] progressViewColor:[UIColor orangeColor] font:[UIFont systemFontOfSize:30]];
 
    [self.view addSubview:view];
}

- (IBAction)btnAction:(UIButton *)sender {
    [view removeFromSuperview];
    [self setupUIWithDuration:10 text:@"永远忘不了"];
    
    [self downFileFromServer:@"http://so1.111ttt.com:8282/2017/1/05m/09/298092036247.m4a?#.mp3"];
    
    
}



//递归文件下载
- (void)downFileFromServer:(NSString *)urlStr {
    __weak typeof(self) weakSelf = self;
 
    NSURL *URL = [NSURL URLWithString:urlStr];
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
     //下载Task操作
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
     
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // 要求返回一个URL, 这个URL就是文件的位置的路径
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        
        NSLog(@"文件路径：%@",path);
        //        self.path = path;
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //设置下载完成操作
        // filePath就是下载文件的位置, [filePath path];// 将NSURL转成NSString
        
        //下载完成后 进行下一个任务
        
        if ([self fileManagerContaine:@"298092036247.m4a"]) {
            _hereLab.text =@"歌曲存在";
        }
        
    }];
    [_downloadTask resume];
}




//判断NSFileManager 是否包含已经缓存的文件

- (BOOL)fileManagerContaine:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //    以上是判断cache文件夹，如果判断document文件将：
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:nil];
    __block BOOL result =NO;
    [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:fileName]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (IBAction)play:(UIButton *)sender {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *urlstr = [cachesPath stringByAppendingPathComponent:@"298092036247.m4a"];
    [[KpengAudioPlayer sharePLayer] playWithUrl:[NSURL fileURLWithPath:urlstr]];
    [[KpengAudioPlayer sharePLayer] setDelegate:self];
}

#pragma mark -player events

-(void)getPlayerTime:(NSTimeInterval )time andTotal:(NSTimeInterval)totalTime{
    _hereLab.text =[self toTimeFormatted:time];
    
}

-(void)getAudioPlayerFinished:(BOOL)success{
 
}

-(void)getPlayerError:(NSError *)error{
    NSLog(@"推诿错误:%@",error);
   
}

//转换成时分秒
- (NSString *)toTimeFormatted:(NSInteger)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    //    int hours = totalSeconds / 3600;
    //    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
