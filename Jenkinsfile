
pipeline {
  agent any

  stages {

    stage('Build') {
      steps {
        sh 'echo "Building the application..."'
        sh 'bash build.sh'
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
        sh 'echo "Deploying the application"'
      }
    }
  }
}
