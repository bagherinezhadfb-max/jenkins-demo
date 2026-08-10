
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
      choices: ['staging', 'production'],
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
        script {
          try {
            sh 'echo "Running tests..."'
            sh 'exit 1'
            sh 'echo "Tests passed successfully"'
          } catch (Exception e) {
              echo "Test failured but we are handling the error"
            }
          } 
        }
      }

    stage('Deploy to staging') {

      when {
        expression {
          params.APP_ENV == 'staging'
        }
       }
 
      steps {

        sh '''   
          echo "Deploying to STAGING"
          echo "version: $APP_VERSION"
        
        '''
      }
    }

    stage('Deploy to production') {
   
      when {
        expression {
          params.APP_ENV == 'production'
        } 
      }
 
      steps {
   
        sh '''
          echo "Deploying to PRODUCTION"
          echo "version: $APP_VERSION"
      
        '''
      }
    }
  }
}
