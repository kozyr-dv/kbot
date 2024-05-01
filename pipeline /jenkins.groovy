pipeline {
    agent any
    environment {
        REPO = 'https://github.com/kozyr-dv/kbot'
        BRANCH = 'main'
        REGISTRY = 'ghcr.io/kozyr-dv'
        APP = 'kbot'
        GHCR = 'https://ghcr.io'
    }

    parameters {
        choice(name: 'TARGETOS', choices: ['linux', 'darwin', 'windows', 'all'], description: 'Choose OS')
        choice(name: 'TARGETARCH', choices: ['amd64', 'arm64'], description: 'Choose architecture')

    }

    stages {
        stage("clone") {
            steps {
                echo 'ClONE REPOSITORY'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }

        stage("test") {
            steps {
                echo 'TEST STARTED'
                sh 'make test'
            }
        }

        stage("build") {
            steps {
                echo 'BUILD STARTED'
                sh 'make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}'
            }
        }

        stage("image") {
            steps {
                echo 'IMAGE STARTED'
                sh 'make image REGISTRY=${REGISTRY} APP=${APP}'
            }
        }

        stage("login to container registry") {
            steps {
                echo 'LOGIN TO GHCR'
                withCredentials([usernamePassword(credentialsId: 'ghcr', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'docker login -u $USERNAME -p $PASSWORD ${GHCR}'
                }

            }
        }

        stage("push to container registry") {
            steps {
                echo 'PUSH TO GHCR'
                sh 'make push REGISTRY=${REGISTRY} TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH}'
            }
        }
    }
}
