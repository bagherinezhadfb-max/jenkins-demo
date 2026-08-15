pipeline {
  agent any
  
  environment {
    APP_NAME = 'jenkins-demo'
    STATE_DIR = '/opt/jenkins-deployment-state'
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
    
    booleanParam(
      name: 'ROLLBACK',
      defaultValue: false,
      description: 'Rollback production to the previous version'
    )
  }

  stages {
   
    stage('Build') {
      when {
        expression {
          !params.ROLLBACK
        }
      }
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
      when {
        expression {
          !params.ROLLBACK
        }
      }
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

    stage('Docker Build and push') {
      when {
        expression {
          !params.ROLLBACK
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
             docker build -t "$DOCKER_USER/$APP_NAME:$APP_VERSION" .
             echo "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin
             docker push "$DOCKER_USER/$APP_NAME:$APP_VERSION"

           '''
        }
      }
    }

 
    stage('Deploy to staging') {
     
      when {
        expression {
          params.APP_ENV == 'staging' && !params.ROLLBACK
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

    stage('Deploy to production') {
      when {
        expression {
          !params.ROLLBACK
        }
      }
      steps {
        script {
          try {
            timeout(time: 1, unit: 'MINUTES') {
              input message: 'Deploy to PRODUCTION?', ok: 'Deploy', submitter: 'admin'
            }
    
            catchError(
              buildResult: 'FAILURE',
              stageResult: 'FAILURE'
            ) {
 
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
                     docker run -d --name jenkins-demo-production -p 8082:80 "$DOCKER_USER/$APP_NAME:$APP_VERSION"
                     sleep 3
                     curl -f http://localhost:8082
                     echo "PRODUCTION health check passed"
      
                     if [ -f "$STATE_DIR/current-version" ]; then

                       cp "$STATE_DIR/current-version" "$STATE_DIR/previous-version"
                     fi
                     echo "$APP_VERSION" > "$STATE_DIR/current-version"
                     echo "current production version: $(cat "$STATE_DIR/current-version")"

                     if [ -f "$STATE_DIR/previous-version" ]; then

                     echo "previous production version: $(cat "$STATE_DIR/previous-version")"
                     fi
      
                   '''
                }
             }

          } catch (err) {
              echo "Production deployment was not approved in time."
              currentBuild.result = 'FAILURE'
          }
        }
      }
    }

    stage('Rollback production') {
      when {
        expression {
          params.ROLLBACK
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
            set -e
            if [ ! -f "$STATE_DIR/previous-version" ]; then
              echo "No previous production version found."
              exit 1
            fi
            ROLLBACK_VERSION=$(cat "$STATE_DIR/previous-version")
            CURRENT_VERSION=$(cat "$STATE_DIR/current-version")
            
            echo "Current production version: $CURRENT_VERSION"
            echo "Rolling back production to version $ROLLBACK_VERSION"

            docker pull "$DOCKER_USER/$APP_NAME:$ROLLBACK_VERSION"

            docker stop jenkins-demo-production || true
            docker rm jenkins-demo-production || true

            docker run -d --name jenkins-demo-production -p 8082:80 "$DOCKER_USER/$APP_NAME:$ROLLBACK_VERSION"

            sleep 3
            curl -f http://localhost:8082

            # update deployment state
            echo "$CURRENT_VERSION" > "$STATE_DIR/previous-version"
            echo "$ROLLBACK_VERSION" > "$STATE_DIR/current-version"

            echo "Current production version: $(cat "$STATE_DIR/current-version")"
            echo "Previous production version: $(cat "$STATE_DIR/previous-version")"
            echo "ROLLBACK completed successfully"
     
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
      archiveArtifacts(
        artifacts: 'dist/*.tar.gz',
        allowEmptyArchive: true
      )

      cleanWs() 
    }
  }
}
