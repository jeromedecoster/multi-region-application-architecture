browse() {
    cd "$PROJECT_DIR"

    RAND=$(cat RANDOM.txt)
    log RAND $RAND

    # Setup variables
    APP_NAME=mr-app-arch
    log APP_NAME $APP_NAME

    CLOUDFRONT_ID=$(aws cloudformation describe-stack-resources \
        --stack-name $APP_NAME-ui \
        --query "StackResources[?LogicalResourceId=='ConsoleCloudFront'].PhysicalResourceId" \
        --region us-east-1 \
        --output text)
    log CLOUDFRONT_ID $CLOUDFRONT_ID

    DOMAIN=$(aws cloudfront get-distribution \
        --id $CLOUDFRONT_ID \
        --query "Distribution.DomainName" \
        --output text)
    log DOMAIN $DOMAIN

    info BROWSE_URL https://$DOMAIN
}

browse
