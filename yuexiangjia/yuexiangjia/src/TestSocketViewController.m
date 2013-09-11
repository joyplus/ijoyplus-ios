//
//  TestSocketViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-2-27.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "TestSocketViewController.h"
#import "AsyncUdpSocket.h"

@interface TestSocketViewController () <AsyncUdpSocketDelegate>{
    AsyncUdpSocket *receiveSocket;
}
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) IBOutlet UITextField *receiveTextField;

@end

@implementation TestSocketViewController
@synthesize sendTextField;
@synthesize receiveTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    receiveSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    NSError *error = nil;
    [receiveSocket bindToAddress:@"0.0.0.0" port:5678 error:&error];
    if (error) {
        NSLog(@"error: %@",error);
    }
    [receiveSocket receiveWithTimeout:-1 tag:1];
    NSLog(@"start udp server");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendBtnClicked:(id)sender {
    AsyncUdpSocket *sendSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    Byte type[5];
    type[0] = 5;
    NSData *data = [[NSData alloc] initWithBytes:type length:5];
    [sendSocket sendData:data toHost:@"192.168.9.164" port:1202 withTimeout:-1 tag:1];
//    [sendSocket sendData:data toHost:@"0.0.0.0" port:5555 withTimeout:-1 tag:1];
    NSLog(@"send upd complete.");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    [sock close];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    [sock close];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    self.receiveTextField.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return YES;
}

- (void)viewDidUnload {
    [self setSendTextField:nil];
    [self setReceiveTextField:nil];
    [super viewDidUnload];
}
@end
