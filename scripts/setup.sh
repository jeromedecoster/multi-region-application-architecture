step_0() {
    info compute project size
    # starting project size
    # 644K    .
    du --summarize --human-readable

    info compute files count
    # 67
    find . -type f | wc -l

    # Create random id
    if [[ ! -f RANDOM.txt ]]; then
        echo -n $RANDOM > RANDOM.txt
    fi
}

step_1() {
    # https://github.com/aws-solutions/multi-region-application-architecture#1-create-an-amazon-s3-bucket
    # Create an Amazon S3 Bucket
    info STEP_1 Create an Amazon S3 Bucket
    BUCKET_PREFIX=my-bucket-$RAND
    log BUCKET_PREFIX $BUCKET_PREFIX

    aws s3 mb s3://$BUCKET_PREFIX-us-east-1 --region us-east-1
    aws s3 mb s3://$BUCKET_PREFIX-ap-northeast-1 --region ap-northeast-1
}

step_2() {
    # https://github.com/aws-solutions/multi-region-application-architecture#2-create-the-deployment-packages
    # Create the deployment packages
    info STEP_2 Create the deployment packages
    log START $(date "+%Y-%d-%m %H:%M:%S")
    START=$SECONDS
    
    cd "$PROJECT_DIR/deployment"
    chmod +x ./build-s3-dist.sh
    
    
    ./build-s3-dist.sh $BUCKET_PREFIX $APP_NAME $VERSION

    # deploy
    aws s3 sync ./regional-s3-assets/ s3://$BUCKET_PREFIX-us-east-1/$APP_NAME/$VERSION/ 
    aws s3 sync ./global-s3-assets/ s3://$BUCKET_PREFIX-us-east-1/$APP_NAME/$VERSION/ 
    aws s3 sync ./regional-s3-assets/ s3://$BUCKET_PREFIX-ap-northeast-1/$APP_NAME/$VERSION/ 
    aws s3 sync ./global-s3-assets/ s3://$BUCKET_PREFIX-ap-northeast-1/$APP_NAME/$VERSION/

    # duration more than 1400 seconds !
    log END $(date "+%Y-%d-%m %H:%M:%S")
    info DURATION $(($SECONDS - $START)) seconds 
}

step_3() {
    # https://github.com/aws-solutions/multi-region-application-architecture#3-launch-the-cloudformation-template
    # Launch the CloudFormation template

    info create_stack $APP_NAME
    warn create_stack "https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks"
    warn create_stack_url "https://my-bucket-$RAND-us-east-1.s3.amazonaws.com/$APP_NAME/$VERSION/multi-region-application-architecture.template"
    warn set_stack_name $APP_NAME
    warn set_secondary_region_parameter ap-northeast-1
    warn allow_checkbox I acknowledge that AWS CloudFormation might create IAM resources

    # wait several minutes for the stack creation ...

    info create_stack $APP_NAME-ui
    warn create_another_stack "https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks"
    warn create_another_stack_url "https://my-bucket-$RAND-us-east-1.s3.amazonaws.com/$APP_NAME/$VERSION/multi-region-application-architecture-demo-ui.template"
    warn set_another_stack_name $APP_NAME-ui
    warn set_cognito_username '<your username>'
    warn set_cognito_email '<your email>'
    warn set_previous_stack_name $APP_NAME
    warn allow_checkbox I acknowledge that AWS CloudFormation might create IAM resources

    # wait several minutes for the stack creation ...
}

setup() {
    cd "$PROJECT_DIR"

    # Create random id
    step_0

    RAND=$(cat RANDOM.txt)
    log RAND $RAND

    # Setup variables
    APP_NAME=mr-app-arch
    log APP_NAME $APP_NAME

    VERSION=v1.0.0
    log VERSION $VERSION

    # Create an Amazon S3 Bucket
    step_1

    # Create the deployment packages
    step_2

    # Launch the CloudFormation template
    step_3

    cd "$PROJECT_DIR"
    # crazy project size !
    # 669M    .
    du --summarize --human-readable

    info compute files count
    # crazy files count !
    # 56281
    find . -type f | wc -l
}

setup
