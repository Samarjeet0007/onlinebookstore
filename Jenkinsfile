
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
                slackSend channel: '#devops-github_jenkins_notification',  
                          message: "Tiggered Jenkins job number: ${currentBuild.number}", 
                          tokenCredentialId: 'cb0cd56b-731c-4ffb-9bee-861185826780', 
                          username: 'jenkinsTriggerNotification'
                sh "mvn clean package"
            } 
        }
        stage('DOCKER BUILD'){
            steps{
                sh "docker build . -t 996622/onlinebookstore:${docker_tag}"
            }
        }
        stage('DOCKER PUSH'){
            steps{
                withCredentials([string(credentialsId: 'docker-pass', variable: 'dockerpass')]) {
                sh "docker login -u 996622 -p ${dockerpass}"
                }
                sh "docker push 996622/onlinebookstore:${docker_tag}"
            }
        }
        stage('Sent_Notification_to_SLACK'){
            steps{
                slackSend channel: '#devops-github_jenkins_notification', 
                          color: 'good', failOnError: true, 
                          message: 'Docker Image deployed on DockerHub', 
                          tokenCredentialId: 'cb0cd56b-731c-4ffb-9bee-861185826780', 
                          username: 'notificationFromJenkins'
            }
        }
        stage('ANSIBLE_to_DEPLOY_CONTAINER'){
            steps{
                script{
                    try{
                        ansiblePlaybook colorized: true, credentialsId: 'ec2_instance_key', 
                                    disableHostKeyChecking: true, extras: "-e docker_tag=${docker_tag}", installation: 'ansible_', 
                                    inventory: 'hosts.ini', playbook: 'docker-container-playbook'   
                    }
                    catch(error){
                        slackSend channel: '#devops-github_jenkins_notification', 
                          color: 'danger', failOnError: true, 
                            message: "ANSIBLE FAILED", 
                          tokenCredentialId: 'cb0cd56b-731c-4ffb-9bee-861185826780', 
                          username: 'jenkinsNotification'
                    }
                }
            }
        }
        stage('Deploy_to_K8S'){
            steps{
                script{
                    try{
                            sh "chmod +x replacing_imgTag.sh && ./replacing_imgTag.sh ${docker_tag}"
                            sshagent(['ec2_instance_key']) {
                            sh "scp -o StrictHostKeyChecking=no K8S_services.yml K8S_pod__updated.yml ec2-user@3.91.46.51:~/"
                            try{
                                sh "ssh ec2-user@3.91.46.51 kubectl apply -f ."
                            }
                            catch(error){
                               sh "ssh ec2-user@3.91.46.51 kubectl create -f ."
                            }
                            slackSend channel: '#devops-github_jenkins_notification', 
                            color: 'good', failOnError: true, 
                            message: "PASSED, Deployment Completed!!!", 
                            tokenCredentialId: 'cb0cd56b-731c-4ffb-9bee-861185826780', 
                            username: 'jenkinsK8Snotification'
                        }
                        catch(error){
                            slackSend channel: '#devops-github_jenkins_notification', 
                            color: 'danger', failOnError: true, 
                            message: "FAILED at EKS", 
                            tokenCredentialId: 'cb0cd56b-731c-4ffb-9bee-861185826780', 
                            username: 'jenkinsK8Snotification'
                        }
                    }
                }
            }
        }
    }
}
def getVersion(){
    def getuniqe = sh returnStdout: true, script: 'echo $RANDOM'
    return getuniqe
}
 
