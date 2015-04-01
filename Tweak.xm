#import "Instagram/IGFeedPhotoView.h"
#import "Instagram/IGImageProgressView.h"
#import "Instagram/IGImageView.h"
#import "Instagram/IGFeedItemVideoCell.h"
#import "Instagram/IGFeedItemVideoView.h"
#import "Instagram/IGFeedVideoPlayer.h"
#import <AssetsLibrary/AssetsLibrary.h>


%hook IGFeedPhotoView
- (void)onTap:(id)arg1{
%orig;
NSLog(@"tap");

}

- (void)onDoubleTap:(id)arg1{
NSLog(@"double tap");
UIImage *image=[[[self photoImageView] photoImageView] image];
NSLog(@"image info:%@",image);
UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Image Saved" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
[alert show];
}

%end


%hook IGFeedItemVideoCell


- (void)feedItemVideoViewDidDoubleTapToLike:(id)arg1{

NSLog(@"double tap video");
NSLog(@"%@",self.videoView.player);
NSString *url=self.videoView.player.URL.absoluteString;
url=[url componentsSeparatedByString:@"http"][2];
url=[@"http" stringByAppendingString:url];
NSLog(@"URL=%@",url);

//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

//NSData *yourVideoData=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
NSData *yourVideoData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];

if (yourVideoData) {
NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
NSString *documentsDirectory = [paths objectAtIndex:0];
NSString *name=[[url componentsSeparatedByString:@"/"] lastObject];
NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,name];

if([yourVideoData writeToFile:filePath atomically:YES])
{
NSLog(@"write successfull");
NSLog(@"%@",filePath);
ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
[library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath]
completionBlock:^(NSURL *assetURL, NSError *error) {
if (error) {
NSLog(@"Save video fail:%@",error);
} else {
NSLog(@"Save video succeed.");
dispatch_async(dispatch_get_main_queue(), ^{
UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Video Saved" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
[alert show];

});
}
NSError *removeError = nil;
[[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
NSLog(@"%@",[removeError localizedDescription]);
}];

}
else{
UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Write to Album Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
[alert show];
}
}else{
UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Download Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
[alert show];
}
//});
}


%end
