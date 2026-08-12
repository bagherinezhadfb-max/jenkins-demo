
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
          mkdir -p dist
          echo "Application version: $APP_VERSION" > app-version.txt
          echo "Environment: $APP_ENV" > dist/app-info.txt
          tar -czf dist/app-v${APP_VERSION}.tar.gz dist/app-info.txt

        '''
      }
    }

    stage('Test') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'demo-user-pass',
            usernameVariable: 'MY_USER',
            passwordVariable: 'MY_PASSWORD'
          )
        ]) {
           sh '''
             echo "Username is available: $MY_USER"
             echo "Password is: $MY_PASSWORD"
           '''
        }
       
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

    stage('Docker Build') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'dockerhub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_TOKEN'
          )
        ]) {
           sh '''
             docker build -t "$DOCKER_USER/Jenkins-demo:$APP_VERSION"
           '''
        }
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
    
    stage('Docker Login') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'dockerhub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_TOKEN'
          )
        ]) {
           sh '''
             echo "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin
           '''
        }
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
      archiveArtifacts artifacts: 'app-version.txt'
      archiveArtifacts artifacts: 'dist/*.tar.gz'
      cleanWs() 
    }
  }
}
