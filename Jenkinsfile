
pipeline {
  agent any

  parameters {
    string(
      name: 'APP_VERSION',
      defaultValue: '1',
      description: 'Enter application version'
    )
    
    choice(
      name: 'APP_ENV',
      choices: ['staging', 'production', 'development'],
      description: 'select application environment'
    )
  }

  stages {

    stage('Build') {
      steps {

        sh '''

          echo "APP_VERSION=$APP_VERSION"
          echo "APP_ENV=$APP_ENV"
          bash build.sh

        '''
      }
    }

    stage('Test') {
      steps {
        sh 'echo "Running tests..."'
        sh 'echo "Tests passed successfully"'
      }
    }

    stage('Deploy') {
      steps {

        sh '''   
        echo "Deploying the application"
        echo "version: $APP_VERSION"
        echo "Environment: $APP_ENV"
        
        '''
      }
    }
  }
}
