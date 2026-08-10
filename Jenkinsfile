
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
  
    echo 'Build'
    echo 'Test'
    echo 'Deploy'
  
  }

  post {

    success {
      echo 'Pipeline SUCCESS'
    }

    failure {
      echo 'Pipeline FAILURE'
    }

    always {
      echo 'Pipeline execution finished'
    }
  }
}
