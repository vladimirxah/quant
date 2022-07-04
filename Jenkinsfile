pipeline {
    agent { docker { image 'bash' } }
    stages {
        stage('build') {
            steps {
		sh '/bin/ls /bin'
		sh '/usr/local/bin/bash substitute.sh --template=template1 -r test1'
		sh '/bin/cat test1'
		sh '/usr/local/bin/bash substitute.sh --template=template2 -r test2'
                sh '/bin/cat test2'
            }
        }
    }
}
