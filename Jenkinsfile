// Define variables
def scmVars

// Start Pipeline
pipeline {

  // Configure Jenkins Slave
  agent {
    // Use Kubernetes as dynamic Jenkins Slave
    kubernetes {
      // Kubernetes Manifest File to spin up Pod to do build
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: helm
    image: lachlanevenson/k8s-helm:v3.0.2
    command:
    - cat
    tty: true
  - name: docker
    image: docker:19.03.5-dind
    command:
    - dockerd
    - --host=unix:///var/run/docker.sock
    - --host=tcp://0.0.0.0:2375
    - --storage-driver=overlay2
    tty: true
    securityContext:
      privileged: true
"""
    } // End kubernetes
  } // End agent
    environment {
    ENV_NAME = "${BRANCH_NAME == "master" ? "uat" : "${BRANCH_NAME}"}"
  }

  // Start Pipeline
  stages {

    // ***** Stage Clone *****
    stage('Clone ratings source code') {
      // Steps to run build
      steps {
        // Run in Jenkins Slave container
        container('jnlp') {
          // Use script to run
          script {
            // Git clone repo and checkout branch as we put in parameter
            scmVars = git branch: "${BRANCH_NAME}",
                          credentialsId: 'gun-deploy-key',
                          url: 'git@github.com:gun082544/bookinfo-ratings.git'
          } // End script
        } // End container
      } // End steps
    } // End stage

    // ***** Stage Build *****
    stage('Build ratings Docker Image and push') {
      steps {
        container('docker') {
          script {
            // Do docker login authentication
            docker.withRegistry('https://ghcr.io', 'gun-github') {
              // Do docker build and docker push
              docker.build('ghcr.io/gun082544/bookinfo-ratings:${ENV_NAME}').push()
            } // End docker.withRegistry
          } // End script
        } // End container
      } // End steps
    } // End stage
    
    stage('Deploy ratings with Helm Chart') {
      steps {
        // Run on Helm container
        container('helm') {
          script {
            // Use kubeconfig from Jenkins Credential
            withKubeConfig([credentialsId: 'aks-k8s-kubeconfig']) {
              // Run Helm upgrade
              sh "helm upgrade -i -f helm/helm-values/values-bookinfo-${ENV_NAME}-ratings.yaml --wait \
                --set extraEnv.COMMIT_ID=${scmVars.GIT_COMMIT} \
              --namespace gun-bookinfo-${ENV_NAME} gun-ratings-${ENV_NAME} k8s/helm"
            } // End withKubeConfig
          } // End script
        } // End container
      } // End steps
    } // End stage


  } // End stages
} // End pipeline
