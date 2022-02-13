#import "ViewController.h"
#import "Foundation/Foundation.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *gameTimeLabel;
@property (weak, nonatomic) IBOutlet UIStepper *timeStepper;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIView *gameFieldView;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end

@implementation ViewController {
    int defaultGameTime;
    int currentScore;
    BOOL isGameStarted;
    
    NSTimeInterval gameTimeInterval;
    NSTimer *timer;
    
    NSString *gameTime;
    NSString *remainingGameTime;
    NSString *gameTimeFullText;
    NSString *second;
    NSString *startGame;
    NSString *stopGame;
    NSString *lastScore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initFields];
    [self initUi];
    [self addListeners];
}

#pragma mark - Init

- (void) initFields {
    defaultGameTime = 30;
    currentScore = 0;
    isGameStarted = NO;
    gameTimeInterval = 0;
    
    gameTime = @"Время";
    remainingGameTime = @"Оставшееся время";
    gameTimeFullText =  @"%@ : %d сек";
    
    startGame = @"Начать";
    stopGame = @"Завершить";
    
    lastScore = @"Последний счет: %d";
}

- (void) initUi {
    self.timeStepper.value = defaultGameTime;
    self.timeStepper.stepValue = 1;
    self.timeStepper.maximumValue = 60;
    self.timeStepper.minimumValue = 10;
    
    self.gameFieldView.layer.borderWidth = 1;
    self.gameFieldView.layer.cornerRadius = 12;
    self.gameFieldView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    [self updateUi];
}

#pragma mark - Listeners

- (void) addListeners {
    [self.timeStepper addTarget:self action: @selector(stepperTapped) forControlEvents: UIControlEventTouchUpInside];
    [self.actionButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void) stepperTapped {
    [self setGameTimeInterval];
}

- (void) actionButtonTapped {
    if(isGameStarted == YES) {
        [self stopGame];
    } else {
        [self startGame];
    }
}

- (void) startGame {
    isGameStarted = YES;
    [self updateUi];
    if(timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeUiByTimer) userInfo:nil repeats:YES];
}

- (void) stopGame {
    isGameStarted = NO;
    if(timer != nil) {
        [timer invalidate];
    }
    [self updateUi];
}

- (void) updateUi {
    [self setGameTimeInterval];
    [self changeActionButtonTitle];
    [self setStepperEnabled: !isGameStarted];
    [self setImageVisibility: isGameStarted];
    [self setScore: currentScore];
}

- (void) changeUiByTimer {
    if(gameTimeInterval == 0) {
        [self stopGame];
    } else {
        gameTimeInterval -= 1;
        [self setGameTime: gameTimeInterval];
    }
}

#pragma mark - State

- (void) setGameTimeInterval {
    gameTimeInterval = self.timeStepper.value;
    [self setGameTime: gameTimeInterval];
}

- (void) setGameTime:(int) seconds {
    NSString *text = isGameStarted? remainingGameTime : gameTime;
    NSString *gameTime = [[NSString alloc] initWithFormat: gameTimeFullText, text, seconds];
    self.gameTimeLabel.text = gameTime;
}

- (void) changeActionButtonTitle {
    NSString *text = isGameStarted? stopGame : startGame;
    [self.actionButton setTitle:text forState:UIControlStateNormal];
}

- (void) setScore: (int) value {
    NSString *scoreText = [[NSString alloc] initWithFormat:  lastScore, value];
    self.scoreLabel.text = scoreText;
}

- (void) setImageVisibility: (BOOL) isVisible {
    self.image.hidden = !isVisible;
}

- (void) setStepperEnabled: (BOOL) isEnabled {
    self.timeStepper.enabled = isEnabled;
}

@end
