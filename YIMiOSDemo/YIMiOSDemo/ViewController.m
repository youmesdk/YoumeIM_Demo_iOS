//
//  ViewController.m
//  YIMiOSDemo
//
//  Created by 余俊澎 on 2016/11/10.
//  Copyright © 2016年 余俊澎. All rights reserved.
//

#import "ViewController.h"
#import "YIMClient.h"

@interface ViewController () <YIMCallbackProtocol>
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (retain,nonatomic) NSString* lastSendAudioPath;
@property (retain,nonatomic) NSString* lastRecvAudioPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    _lastSendAudioPath = NULL;
    _lastRecvAudioPath = NULL;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    // =================== YIM 初始化 =========================
    // 请使用自己的APPKey和用户ID来替换
    [[YIMClient GetInstance] InitWithAppKey:@"YOUMEBC2B3171A7A165DC10918A7B50A4B939F2A187D0" appSecurityKey:@"r1+ih9rvMEDD3jUoU+nj8C7VljQr7Tuk4TtcByIdyAqjdl5lhlESU0D+SoRZ30sopoaOBg9EsiIMdc8R16WpJPNwLYx2WDT5hI/HsLl1NJjQfa9ZPuz7c/xVb8GHJlMf/wtmuog3bHCpuninqsm3DRWiZZugBTEj2ryrhK7oZncBAAE=" serverZone:YouMeIMServerZone_China];
    //设置回调
    [[YIMClient GetInstance] SetDelegate:self];
    // ================= END YIM 初始化 ========================
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    
    [[YIMClient GetInstance] Login:@"uid_1234567" password:@"123456" token:@"" callback:^(YIMErrorcodeOC errorcode, NSString *userID) {
        
        if(errorcode == YouMeIMCode_Success){
            NSLog(@"登陆成功，现在进入房间");
            [_tipsLabel setText:[NSString stringWithFormat:@"OnLogin成功"]];
            [[YIMClient GetInstance] JoinChatRoom:@"room_w123" callback:^(YIMErrorcodeOC errorcode, NSString *roomID) {
                if(errorcode == YouMeIMCode_Success){
                    NSLog(@"进入房间成功");
                    [_tipsLabel setText:[NSString stringWithFormat:@"OnJoinChatRoom成功"]];
                }else{
                    NSLog(@"进入房间失败：%d",errorcode);
                    [_tipsLabel setText:[NSString stringWithFormat:@"OnJoinChatRoom失败:%d",errorcode]];
                }
            }];
            
        }else{
            NSLog(@"登陆失败，可以视情况重试登陆");
            [_tipsLabel setText:[NSString stringWithFormat:@"OnLogin失败:%d",errorcode]];
        }
    }];
    
//    if(errorcode != YouMeIMCode_Success){
//        NSLog(@"不能登陆，一般是已经登陆了");
//        [_tipsLabel setText:[NSString stringWithFormat:@"不能登陆:%d",errorcode]];
//    }else{
//        [_tipsLabel setText:[NSString stringWithFormat:@"Loging....."]];
//        //============ 登陆完成后触发 OnLogin 回调==============
//    }
}

- (IBAction)sendText:(id)sender {
    //给自己发一条语音
    unsigned long long reqID=0;
    
    reqID = [[YIMClient GetInstance] SendTextMessage: @"uid_1234567" chatType:YIMChatType_PrivateChat msgContent:@"I win!" attachParam:@"" callback:^(YIMErrorcodeOC errorcode, unsigned int sendTime, bool isForbidRoom, int reasonType, unsigned long long forbidEndTime) {
        if(errorcode ==YouMeIMCode_Success){
            NSLog(@"消息id：%lld 发送成功",reqID);
            [_tipsLabel setText:@"发送文本消息成功"];
        }else{
            NSLog(@"发送文本消息失败，一般是没有登陆:%d",errorcode);
            [_tipsLabel setText:[NSString stringWithFormat:@"发送文本失败:%d",errorcode]];
        }
    }];
    //YIMErrorcodeOC code = [[YIMClient GetInstance] SendTextMessage: @"room_w123" chatType:YIMChatType_RoomChat msgContent:@"I win!" requestID:&reqID];

//    if(code != YouMeIMCode_Success){
//        NSLog(@"启动Text，一般是没有登陆:%d",code);
//        [_tipsLabel setText:[NSString stringWithFormat:@"发送文本失败:%d",code]];
//    }else{
//        [_tipsLabel setText:@"发送文本消息"];
//    }
}

- (IBAction)startRecord:(id)sender {
    //给自己发一条语音
    unsigned long long reqID=0;
    reqID = [[YIMClient GetInstance] StartRecordAudioMessage:@"uid_1234567" chatType:YIMChatType_PrivateChat recognizeText:true isOpenOnlyRecognizeText:false callback:^(YIMErrorcodeOC errorcode, NSString *text, NSString *audioPath, unsigned int audioTime, unsigned int sendTime, bool isForbidRoom, int reasonType, unsigned long long forbidEndTime) {
        if(errorcode == YouMeIMCode_Success){
            _lastSendAudioPath = audioPath;
            [_tipsLabel setText:@"语音发送成功"];
        }else{
            [_tipsLabel setText:[NSString stringWithFormat:@"语音发送失败:%d",errorcode]];
        }
    } startSendCallback:^(YIMErrorcodeOC errorcode, NSString *text, NSString *audioPath, unsigned int audioTime) {
        
    }];
//    if(code != YouMeIMCode_Success){
//        NSLog(@"启动录音失败，一般是没有登陆或者还没有停止录音，也可能是用户没有允许录音:%d",code);
//        [_tipsLabel setText:[NSString stringWithFormat:@"启动录音失败:%d",code]];
//    }else{
//        [_tipsLabel setText:@"录音中"];
//    }
}

- (IBAction)stopAndSend:(id)sender {
    //停止录音并发送
    //参数是透传字符串，不传给个空串吧
    YIMErrorcodeOC code = [[YIMClient GetInstance] StopAndSendAudioMessage:@""];
    if(code != YouMeIMCode_Success){
        NSLog(@"发送录音失败，一般是没有登陆或者还没有开始录音，也可能是用户没有允许录音:%d",code);
        [_tipsLabel setText:[NSString stringWithFormat:@"停止录音失败:%d",code]];
    }else{
        [_tipsLabel setText:@"语音发送中"];
        //============ 发送成功后触发 OnSendAudioMessageStatus 回调==============
    }
}



- (IBAction)StartAudioSpeech: (id)sender{
    //给自己发一条语音
    unsigned long long reqID=0;
    reqID = [[YIMClient GetInstance] StartAudioSpeech:true callback:^(YIMErrorcodeOC errorcode, AudioSpeechInfo *audioSpeechInfo) {
        NSLog(@"OnStopAudioSpeechStatus,error:%d,%@_%@", (int)errorcode, audioSpeechInfo.textContent, audioSpeechInfo.downloadURL );
        if(errorcode != YouMeIMCode_Success){
            NSLog(@"启动录音失败，一般是没有登陆或者还没有停止录音，也可能是用户没有允许录音:%d",errorcode);
            [_tipsLabel setText:[NSString stringWithFormat:@"启动录音失败:%d",errorcode]];
        }
    }];
//    if(code != YouMeIMCode_Success){
//        NSLog(@"启动录音失败，一般是没有登陆或者还没有停止录音，也可能是用户没有允许录音:%d",code);
//        [_tipsLabel setText:[NSString stringWithFormat:@"启动录音失败:%d",code]];
//    }else{
//        [_tipsLabel setText:@"录音中"];
//    }

}

- (IBAction)StopAudioSpeech: (id)sender{
    //停止录音并发送
    //参数是透传字符串，不传给个空串吧
    YIMErrorcodeOC code = [[YIMClient GetInstance] StopAudioSpeech ];
    if(code != YouMeIMCode_Success){
        NSLog(@"发送录音失败，一般是没有登陆或者还没有开始录音，也可能是用户没有允许录音:%d",code);
        [_tipsLabel setText:[NSString stringWithFormat:@"停止录音失败:%d",code]];
    }else{
        [_tipsLabel setText:@"语音发送中"];
        //============ 发送成功后触发 OnStopAudioSpeech 回调==============
    }
}

- (IBAction)playMyVoiceMessage:(id)sender {
//    [[AudioPlayer GetInstance] Play:_lastSendAudioPath];
    [[YIMClient GetInstance] StartPlayAudio:_lastSendAudioPath callback:^(YIMErrorcodeOC errorcode, NSString *path) {
        
    }];
}
- (IBAction)playRecvVoiceMessage:(id)sender {
//    [[AudioPlayer GetInstance] Play:_lastRecvAudioPath];
    [[YIMClient GetInstance] StartPlayAudio:_lastRecvAudioPath callback:^(YIMErrorcodeOC errorcode, NSString *path) {
        
    }];
}

//回调监听
- (void) OnLogin:(YIMErrorcodeOC) errorcode userID:(NSString*) userID{
//    if(errorcode == YouMeIMCode_Success){
//         NSLog(@"登陆成功，现在进入房间");
//        [[YIMClient GetInstance] JoinChatRoom:@"room_w123"];
//         [_tipsLabel setText:[NSString stringWithFormat:@"OnLogin成功"]];
//    }else{
//        NSLog(@"登陆失败，可以视情况重试登陆");
//        [_tipsLabel setText:[NSString stringWithFormat:@"OnLogin失败:%d",errorcode]];
//    }
}
- (void) OnLogout:(YIMErrorcodeOC) errorcode{
    NSLog(@"退出了，如果平台还在线，可以重试登陆");
}

- (void) OnKickOff{
    
}

//IYIMMessageCallback
- (void) OnSendMessageStatus:(unsigned long long) iRequestID errorcode:(YIMErrorcodeOC) errorcode  isForbidRoom:(bool) isForbidRoom   reasonType:(int)reasonType forbidEndTime:(unsigned long long)forbidEndTime{
//    if(errorcode ==YouMeIMCode_Success){
//        NSLog(@"消息id：%lld 发送成功",iRequestID);
//    }
}

- (void) OnRecvMessage:(YIMMessage*) pMessage{
    //私聊消息 还是 房间消息的判断
    BOOL isPrivateMessage =( pMessage.chatType ==YIMChatType_PrivateChat) ;
    
    if(pMessage.messageBody.messageType == YIMMessageBodyType_TXT){
        //收到的是文本消息
        YIMMessageBodyText *tMessage = (YIMMessageBodyText *)pMessage.messageBody;
        [_tipsLabel setText:[NSString stringWithFormat:@"%@,%@", @"收到文本消息", [tMessage messageContent] ] ];
        NSLog(@"文字消息:%@",[tMessage messageContent]);
    }else if(pMessage.messageBody.messageType == YIMMessageBodyType_Voice){
        //收到的是语音消息
        YIMMessageBodyAudio *vMessage = (YIMMessageBodyAudio *)pMessage.messageBody;
        NSLog(@"文字识别结果:%@,fileSize:%d,audioTime:%d",[vMessage textContent], [vMessage fileSize], [vMessage audioTime] );
        //下载语音文件
        [[YIMClient GetInstance] DownloadAudio:pMessage.messageID strSavePath:[ViewController createUniqFilePath] callback:^(YIMErrorcodeOC errorcode, YIMMessage *msg, NSString *savePath) {
            _lastRecvAudioPath = savePath;
        }];
    }
    else if (pMessage.messageBody.messageType == YIMMessageBodyType_File ){
        YIMMessageBodyFile* fileMsg = (YIMMessageBodyFile *)pMessage.messageBody;
        NSLog(@"获得文件:" );
        
        
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [cachePaths objectAtIndex:0];
        
        NSString *fullCachePath = [cachePath stringByAppendingPathComponent:@"YIMVoiceCache/file.txt"];
        
        //下载语音文件
        //pMessage.messageID
        [[YIMClient GetInstance] DownloadAudio:1 strSavePath:fullCachePath callback:^(YIMErrorcodeOC errorcode, YIMMessage *msg, NSString *savePath) {
            
        }];
//        NSLog(@"down file :%d", code );
    }
    else if  (pMessage.messageBody.messageType == YIMMessageBodyType_Gift ){
        YIMMessageBodyGift* giftMsg = (YIMMessageBodyGift *)pMessage.messageBody;
        
        NSLog(@"获得礼物:%d,%d,anchor:%@,extraParam:%@", giftMsg.giftID, giftMsg.giftCount, giftMsg.anchor, giftMsg.extraParam );
    }
    else if ( pMessage.messageBody.messageType == YIMMessageBodyType_CustomMesssage ){
        YIMMessageBodyCustom* customMsg = (YIMMessageBodyCustom *)pMessage.messageBody;
        const char* cp = (const char*)customMsg.messageContent.bytes;
        int size = customMsg.messageContent.length;
        
        NSLog(@"获得自定义消息,size%d", size  );
    }
}

- (void) OnQueryHistoryMessage:(YIMErrorcodeOC) errorcode targetID:(NSString*) targetID  remain:(int) remain messageArray:( NSArray *) messageArray{
    NSLog(@"OnGetRecentContacts,count:%d", messageArray.count );
}

- (void) OnStopAudioSpeechStatus:(YIMErrorcodeOC) errorcode audioSpeechInfo:(AudioSpeechInfo*) audioSpeechInfo{
//    NSLog(@"OnStopAudioSpeechStatus,error:%d,%@_%@", (int)errorcode, audioSpeechInfo.textContent, audioSpeechInfo.downloadURL );
}

- (void) OnGetRecentContacts:(YIMErrorcodeOC) errorcode contactArray:( NSArray *) contactArray{
    NSLog(@"OnGetRecentContacts,count:%d", contactArray.count );
}

//新消息通知（只有SetReceiveMessageSwitch设置为不自动接收消息，才会收到该回调）
- (void) OnReceiveMessageNotify:(YIMChatTypeOC)chatType targetID:(NSString*)targetID;{
    NSLog(@"OnReceiveMessageNotify,...........");
}

//停止语音回调（调用StopAudioMessage停止语音之后，发送语音消息之前）
- (void) OnStartSendAudioMessage:(unsigned long long) iRequestID errorcode:(YIMErrorcodeOC) errorcode
                      strMessage:(NSString*)strMessage strAudioPath:(NSString*) strAudioPath audioTime:(unsigned int)audioTime{
    
}

- (void) OnSendAudioMessageStatus:(unsigned long long) iRequestID errorcode:(YIMErrorcodeOC) errorcode
                       strMessage:(NSString*)strMessage strAudioPath:(NSString*) strAudioPath  audioTime:(unsigned)audioTime   isForbidRoom:(bool) isForbidRoom   reasonType:(int)reasonType forbidEndTime:(unsigned long long)forbidEndTime{
//    if(errorcode == YouMeIMCode_Success){
//        _lastSendAudioPath = strAudioPath;
//        [_tipsLabel setText:@"语音发送成功"];
//    }else{
//        [_tipsLabel setText:[NSString stringWithFormat:@"语音发送失败:%d",errorcode]];
//    }
}

//IYIMDownloadCallback
- (void) OnDownload:(YIMErrorcodeOC)errorcode  pMessage:(YIMMessage*) pMessage strSavePath:(NSString*)strSavePath
{
    _lastRecvAudioPath = strSavePath;
}

- (void) OnDownloadByUrl:(YIMErrorcodeOC)errorcode strFromUrl:(NSString*)strFromUrl strSavePath:(NSString*)strSavePath{
    _lastRecvAudioPath = strSavePath;
}


//进入房间的回调，JoinChatRoom也在这个回调
- (void) OnJoinRoom:(YIMErrorcodeOC) errorcode roomID:(NSString*) roomID{
//    if(errorcode == YouMeIMCode_Success){
//        NSLog(@"进入房间成功");
//    }else{
//        NSLog(@"进入房间失败，基本上不会：%d",errorcode);
//    }
}

- (void) OnLeaveRoom:(YIMErrorcodeOC) errorcode roomID:(NSString*) roomID{
    
}
         
         
 +(NSString*)createUniqFilePath{
     NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
     NSString *cachePath = [cachePaths objectAtIndex:0];
     
     NSString *fullCachePath = [cachePath stringByAppendingPathComponent:@"YIMVoiceCache"];
     NSString *fileName = [NSString stringWithFormat:@"%@.wav", [[NSUUID UUID] UUIDString]];
     BOOL isDir = FALSE;
     NSFileManager *fileManager = [NSFileManager defaultManager];
     BOOL isDirExist = [fileManager fileExistsAtPath:fullCachePath
                                         isDirectory:&isDir];
     if(!isDirExist){
         BOOL bCreateDir = [fileManager createDirectoryAtPath:fullCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
         
         if(!bCreateDir){
             
             NSLog(@"YIM Create Audio Cache Directory Failed.");
             
         }
         
         NSLog(@"%@",fullCachePath);
     }
     return [fullCachePath stringByAppendingPathComponent:fileName];
 }

- (void) OnUserJoinRoom:(NSString*)roomId userID:(NSString*)userId
{
    
}
- (void) OnUserLeaveRoom:(NSString*)roomId userID:(NSString*)userId
{
    
}

// 接收公告
- (void) OnRecvNotice:(YIMNoticeOC*) notice
{
    
}
// 撤销公告（置顶公告）
- (void) OnCancelNotice:(unsigned long long) noticeID channelID:(NSString*)channelID
{
    
}

- (void) OnGetForbiddenSpeakInfo:(YIMErrorcodeOC)errorcode  forbiddenSpeakArray:(NSArray*) forbiddenSpeakArray
{
    
}

//IYIMAudioPlayCallback 播放回调
- (void) OnPlayCompletion:(YIMErrorcodeOC) errorcode  path:(NSString*) path
{
    
}
- (void) OnGetMicrophoneStatus:(AudioDeviceStatusOC)status
{
    
}


//IYIMLocationCallback 地理位置回调
// 获取自己位置回调
- (void) OnUpdateLocation:(YIMErrorcodeOC) errorcode  location:(GeographyLocationOC*) location{
    
}

// 获取附近目标回调neighbourList:(NSArray<RelativeLocationOC*>)
- (void) OnGetNearbyObjects:(YIMErrorcodeOC) errorcode neighbourList:(NSArray*) neighbourList  startDistance:(unsigned int) startDistance  endDistance:(unsigned int) endDistance {
    
}

//获取用户信息回调(用户信息为JSON格式)
- (void) OnGetUserInfo:(YIMErrorcodeOC)errorcode userID:(NSString*)userID userInfo:(NSString*) userInfo
{
    
}
//查询用户状态回调
- (void) OnQueryUserStatus:(YIMErrorcodeOC)errorcode userID:(NSString*)userID status:(YIMUserStatusOC) status
{
    
}


//文本翻译完成回调
- (void) OnTranslateTextComplete:(YIMErrorcodeOC) errorcode requestID:(unsigned int) requestID  text:(NSString*)text srcLangCode:(LanguageCodeOC) srcLangCode destLangCode:(LanguageCodeOC) destLangCode
{
    
}

// 举报处理结果通知
- (void)OnAccusationResultNotify:(AccusationDealResultOC)result userID:(NSString*)userID accusationTime:(unsigned int)accusationTime{
    
}






@end
