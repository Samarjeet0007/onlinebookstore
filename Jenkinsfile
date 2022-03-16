
pipeline{
    agent any
    
    tools {
        maven 'maven_1'
    }
    
    environment {
        docker_tag = getVersion()
    }
    stages{
        stage('MVN BUILD'){
            steps{
                sh "mvn clean package"
            } 
        }
        stage('DOCKER BUILD'){
            steps{
                sh "docker build . -t 996622/warfromjenkins:${docker_tag}"
            }
        }
        stage('DOCKER PUSH'){
            steps{
                withCredentials([string(credentialsId: 'docker-pass', variable: 'dockerpass')]) {
                sh "docker login -u 996622 -p ${dockerpass}"
                }
                sh "docker push 996622/warfromjenkins:${docker_tag}"
            }
        }
        stage('ANSIBLE_to_DEPLOY_CONTAINER'){
            steps{
                ansiblePlaybook colorized: true, credentialsId: 'ec2_instance_key', 
                disableHostKeyChecking: true, extras: "-e docker_tag=${docker_tag}", installation: 'ansible_', 
                inventory: 'hosts.ini', playbook: 'docker-container-playbook'
            }
        }
    }
}
def getVersion(){
    def getuniqe = sh returnStdout: true, script: 'echo $RANDOM'
    return getuniqe
}
