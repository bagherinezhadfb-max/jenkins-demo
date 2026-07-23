
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
