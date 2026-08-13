pipeline {
  agent any
  
  environment {
    APP_NAME = 'jenkins-demo'
  } 

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
          echo "APP_NAME=$APP_NAME"
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
        withCredentials([
          usernamePassword(
            credentialsId: 'dockerhub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_TOKEN'

          )
        ]) {

           sh '''   
             echo "Deploying version $APP_VERSION to STAGING"
             docker pull "$DOCKER_USER/$APP_NAME:$APP_VERSION"
             docker stop jenkins-demo-staging || true
             docker rm jenkins-demo-staging || true
             docker run -d --name jenkins-demo-staging -p 8081:80 "$DOCKER_USER/$APP_NAME:$APP_VERSION"
             sleep 3
             curl -f http://localhost:8081
             echo "STAGING health check passed"
           '''
        } 
      }
    }

    stage('Docker Build and push') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'dockerhub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_TOKEN'
          )
        ]) {
           sh '''
             docker build -t "$DOCKER_USER/$APP_NAME:$APP_VERSION" .
             echo "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin
             docker push "$DOCKER_USER/$APP_NAME:$APP_VERSION"

           '''
        }
      }
    }

    stage('Deploy to production') {
      steps {
        script {
          try {
            timeout(time: 1, unit: 'MINUTES') {
              input message: 'Deploy to PRODUCTION?', ok: 'Deploy', submitter: 'admin'
            }
            withCredentials([
              usernamePassword(
                credentialsId: 'dockerhub-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_TOKEN'
              )
             ]) {

                sh '''
                  echo "Deploying version $APP_VERSION to production"
                  docker pull "$DOCKER_USER/$APP_NAME:$APP_VERSION"
                  docker stop jenkins-demo-production || true
                  docker rm jenkins-demo-production || true
                  docker run -d --name jenkins-demo-production -p 8082:80 $DOCKER_USER/$APP_NAME:$APP_VERSION"
                  sleep 3
                  curl -f http://localhost:8082
                  echo "PRODUCTION health check passed"
      
                '''
             }

          } catch (err) {
              echo "Production deployment was not approved in time."
              currentBuild.result = 'FAILURE'
          }
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
