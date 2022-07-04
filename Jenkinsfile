pipeline {
    agent { docker { image 'jenkins-docker' } }
    stages {
        stage('build') {
            steps {
                sh 'python --version'
            }
        }
    }
}
