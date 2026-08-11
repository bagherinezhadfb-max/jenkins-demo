
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
          echo "Application version: $APP_VERSION" > app-version.txt

        '''
      }
    }

    stage('Test') {
      steps {
      
        sh 'echo "Running tests..."'
        sh 'echo "Tests passed successfully"'
          
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
  post {
    
    success {
      echo 'pipeline SUCCESS'
    }
      
    failure {
      echo 'pipeline FAILURE'
    }

    always {
      echo 'pipeline execution finished'
      archiveArtifacts artifact: 'app-version.txt'
      cleanWs() 
    }
  }
}
